!** CBUNI
PURE SUBROUTINE CBUNI(Z,Fnu,Kode,N,Y,Nz,Nui,Nlast,Fnul,Tol,Elim,Alim)
  !> Subsidiary to CBESI and CBESK
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      ALL (CBUNI-A, ZBUNI-A)
  !***
  ! **Author:**  Amos, D. E., (SNL)
  !***
  ! **Description:**
  !
  !     CBUNI COMPUTES THE I BESSEL FUNCTION FOR LARGE ABS(Z)>
  !     FNUL AND FNU+N-1<FNUL. THE ORDER IS INCREASED FROM
  !     FNU+N-1 GREATER THAN FNUL BY ADDING NUI AND COMPUTING
  !     ACCORDING TO THE UNIFORM ASYMPTOTIC EXPANSION FOR I(FNU,Z)
  !     ON IFORM=1 AND THE EXPANSION FOR J(FNU,Z) ON IFORM=2
  !
  !***
  ! **See also:**  CBESI, CBESK
  !***
  ! **Routines called:**  CUNI1, CUNI2, R1MACH

  !* REVISION HISTORY  (YYMMDD)
  !   830501  DATE WRITTEN
  !   910415  Prologue converted to Version 4.0 format.  (BAB)
  USE service, ONLY : huge_sp, tiny_sp
  USE IEEE_ARITHMETIC, ONLY : IEEE_IS_FINITE
  !
  INTEGER, INTENT(IN) :: Kode, N, Nui
  INTEGER, INTENT(OUT) :: Nlast, Nz
  REAL(SP), INTENT(IN) :: Alim, Elim, Fnu, Fnul, Tol
  COMPLEX(SP), INTENT(IN) :: Z
  COMPLEX(SP), INTENT(OUT) :: Y(N)
  !
  INTEGER :: i, iflag, iform, k, nl, nw
  COMPLEX(SP) :: cscl, cscr, cy(2), rz, st, s1, s2
  REAL(SP) :: ax, ay, dfnu, fnui, gnu, xx, yy, ascle, bry(3), str, sti, stm
  REAL(SP), PARAMETER :: sqrt_huge = SQRT( huge_sp )
  !* FIRST EXECUTABLE STATEMENT  CBUNI
  Nz = 0
  xx = REAL(Z,SP)
  yy = AIMAG(Z)
  ax = ABS(xx)*1.7321_SP
  ay = ABS(yy)
  iform = 1
  IF( ay>ax ) iform = 2
  IF( Nui==0 ) THEN
    IF( iform==2 ) THEN
      !-----------------------------------------------------------------------
      !     ASYMPTOTIC EXPANSION FOR J(FNU,Z*EXP(M*HPI)) FOR LARGE FNU
      !     APPLIED IN PI/3<ABS(ARG(Z))<=PI/2 WHERE M=+I OR -I AND HPI=PI/2
      !-----------------------------------------------------------------------
      CALL CUNI2(Z,Fnu,Kode,N,Y,nw,Nlast,Fnul,Tol,Elim,Alim)
    ELSE
      !-----------------------------------------------------------------------
      !     ASYMPTOTIC EXPANSION FOR I(FNU,Z) FOR LARGE FNU APPLIED IN
      !     -PI/3<=ARG(Z)<=PI/3
      !-----------------------------------------------------------------------
      CALL CUNI1(Z,Fnu,Kode,N,Y,nw,Nlast,Fnul,Tol,Elim,Alim)
    END IF
    IF( nw>=0 ) GOTO 100
  ELSE
    fnui = Nui
    dfnu = Fnu + (N-1)
    gnu = dfnu + fnui
    IF( iform==2 ) THEN
      !-----------------------------------------------------------------------
      !     ASYMPTOTIC EXPANSION FOR J(FNU,Z*EXP(M*HPI)) FOR LARGE FNU
      !     APPLIED IN PI/3<ABS(ARG(Z))<=PI/2 WHERE M=+I OR -I AND HPI=PI/2
      !-----------------------------------------------------------------------
      CALL CUNI2(Z,gnu,Kode,2,cy,nw,Nlast,Fnul,Tol,Elim,Alim)
    ELSE
      !-----------------------------------------------------------------------
      !     ASYMPTOTIC EXPANSION FOR I(FNU,Z) FOR LARGE FNU APPLIED IN
      !     -PI/3<=ARG(Z)<=PI/3
      !-----------------------------------------------------------------------
      CALL CUNI1(Z,gnu,Kode,2,cy,nw,Nlast,Fnul,Tol,Elim,Alim)
    END IF
    IF( nw>=0 ) THEN
      IF( nw/=0 ) THEN
        Nlast = N
        RETURN
      ELSE
        ay = ABS(cy(1))
        IF( .NOT. IEEE_IS_FINITE(ay) ) ay = ABS( cy(1)/sqrt_huge ) *sqrt_huge
        !----------------------------------------------------------------------
        !     SCALE BACKWARD RECURRENCE, BRY(3) IS DEFINED BUT NEVER USED
        !----------------------------------------------------------------------
        bry(1) = 1.E+3_SP*tiny_sp/Tol
        bry(2) = 1._SP/bry(1)
        bry(3) = bry(2)
        iflag = 2
        ascle = bry(2)
        ax = 1._SP
        cscl = CMPLX(ax,0._SP,SP)
        IF( ay<=bry(1) ) THEN
          iflag = 1
          ascle = bry(1)
          ax = 1._SP/Tol
          cscl = CMPLX(ax,0._SP,SP)
        ELSEIF( ay>=bry(2) ) THEN
          iflag = 3
          ascle = bry(3)
          ax = Tol
          cscl = CMPLX(ax,0._SP,SP)
        END IF
        ay = 1._SP/ax
        cscr = CMPLX(ay,0._SP,SP)
        s1 = cy(2)*cscl
        s2 = cy(1)*cscl
        rz = CMPLX(2._SP,0._SP,SP)/Z
        DO i = 1, Nui
          st = s2
          s2 = CMPLX(dfnu+fnui,0._SP,SP)*rz*s2 + s1
          s1 = st
          fnui = fnui - 1._SP
          IF( iflag<3 ) THEN
            st = s2*cscr
            str = REAL(st,SP)
            sti = AIMAG(st)
            str = ABS(str)
            sti = ABS(sti)
            stm = MAX(str,sti)
            IF( stm>ascle ) THEN
              iflag = iflag + 1
              ascle = bry(iflag)
              s1 = s1*cscr
              s2 = st
              ax = ax*Tol
              ay = 1._SP/ax
              cscl = CMPLX(ax,0._SP,SP)
              cscr = CMPLX(ay,0._SP,SP)
              s1 = s1*cscl
              s2 = s2*cscl
            END IF
          END IF
        END DO
        Y(N) = s2*cscr
        IF( N==1 ) RETURN
        nl = N - 1
        fnui = nl
        k = nl
        DO i = 1, nl
          st = s2
          s2 = CMPLX(Fnu+fnui,0._SP,SP)*rz*s2 + s1
          s1 = st
          st = s2*cscr
          Y(k) = st
          fnui = fnui - 1._SP
          k = k - 1
          IF( iflag<3 ) THEN
            str = REAL(st,SP)
            sti = AIMAG(st)
            str = ABS(str)
            sti = ABS(sti)
            stm = MAX(str,sti)
            IF( stm>ascle ) THEN
              iflag = iflag + 1
              ascle = bry(iflag)
              s1 = s1*cscr
              s2 = st
              ax = ax*Tol
              ay = 1._SP/ax
              cscl = CMPLX(ax,0._SP,SP)
              cscr = CMPLX(ay,0._SP,SP)
              s1 = s1*cscl
              s2 = s2*cscl
            END IF
          END IF
        END DO
        RETURN
      END IF
    END IF
  END IF
  Nz = -1
  IF( nw==(-2) ) Nz = -2
  RETURN
  100  Nz = nw
  !
  RETURN
END SUBROUTINE CBUNI