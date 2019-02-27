!DECK ZBUNI
SUBROUTINE ZBUNI(Zr,Zi,Fnu,Kode,N,Yr,Yi,Nz,Nui,Nlast,Fnul,Tol,Elim,Alim)
  IMPLICIT NONE
  !***BEGIN PROLOGUE  ZBUNI
  !***SUBSIDIARY
  !***PURPOSE  Subsidiary to ZBESI and ZBESK
  !***LIBRARY   SLATEC
  !***TYPE      ALL (CBUNI-A, ZBUNI-A)
  !***AUTHOR  Amos, D. E., (SNL)
  !***DESCRIPTION
  !
  !     ZBUNI COMPUTES THE I BESSEL FUNCTION FOR LARGE ABS(Z).GT.
  !     FNUL AND FNU+N-1.LT.FNUL. THE ORDER IS INCREASED FROM
  !     FNU+N-1 GREATER THAN FNUL BY ADDING NUI AND COMPUTING
  !     ACCORDING TO THE UNIFORM ASYMPTOTIC EXPANSION FOR I(FNU,Z)
  !     ON IFORM=1 AND THE EXPANSION FOR J(FNU,Z) ON IFORM=2
  !
  !***SEE ALSO  ZBESI, ZBESK
  !***ROUTINES CALLED  D1MACH, ZABS, ZUNI1, ZUNI2
  !***REVISION HISTORY  (YYMMDD)
  !   830501  DATE WRITTEN
  !   910415  Prologue converted to Version 4.0 format.  (BAB)
  !***END PROLOGUE  ZBUNI
  !     COMPLEX CSCL,CSCR,CY,RZ,ST,S1,S2,Y,Z
  REAL(8) :: Alim, ax, ay, csclr, cscrr, cyi, cyr, dfnu, &
    Elim, Fnu, fnui, Fnul, gnu, raz, rzi, rzr, sti, &
    str, s1i, s1r, s2i, s2r, Tol, Yi, Yr, Zi, Zr, &
    ZABS, ascle, bry, c1r, c1i, c1m, D1MACH
  INTEGER i, iflag, iform, k, Kode, N, nl, Nlast, Nui, nw, Nz
  DIMENSION Yr(N), Yi(N), cyr(2), cyi(2), bry(3)
  EXTERNAL ZABS
  !***FIRST EXECUTABLE STATEMENT  ZBUNI
  Nz = 0
  ax = ABS(Zr)*1.7321D0
  ay = ABS(Zi)
  iform = 1
  IF ( ay>ax ) iform = 2
  IF ( Nui==0 ) THEN
    IF ( iform==2 ) THEN
      !-----------------------------------------------------------------------
      !     ASYMPTOTIC EXPANSION FOR J(FNU,Z*EXP(M*HPI)) FOR LARGE FNU
      !     APPLIED IN PI/3.LT.ABS(ARG(Z)).LE.PI/2 WHERE M=+I OR -I
      !     AND HPI=PI/2
      !-----------------------------------------------------------------------
      CALL ZUNI2(Zr,Zi,Fnu,Kode,N,Yr,Yi,nw,Nlast,Fnul,Tol,Elim,Alim)
    ELSE
      !-----------------------------------------------------------------------
      !     ASYMPTOTIC EXPANSION FOR I(FNU,Z) FOR LARGE FNU APPLIED IN
      !     -PI/3.LE.ARG(Z).LE.PI/3
      !-----------------------------------------------------------------------
      CALL ZUNI1(Zr,Zi,Fnu,Kode,N,Yr,Yi,nw,Nlast,Fnul,Tol,Elim,Alim)
    ENDIF
    IF ( nw>=0 ) GOTO 100
  ELSE
    fnui = Nui
    dfnu = Fnu + (N-1)
    gnu = dfnu + fnui
    IF ( iform==2 ) THEN
      !-----------------------------------------------------------------------
      !     ASYMPTOTIC EXPANSION FOR J(FNU,Z*EXP(M*HPI)) FOR LARGE FNU
      !     APPLIED IN PI/3.LT.ABS(ARG(Z)).LE.PI/2 WHERE M=+I OR -I
      !     AND HPI=PI/2
      !-----------------------------------------------------------------------
      CALL ZUNI2(Zr,Zi,gnu,Kode,2,cyr,cyi,nw,Nlast,Fnul,Tol,Elim,Alim)
    ELSE
      !-----------------------------------------------------------------------
      !     ASYMPTOTIC EXPANSION FOR I(FNU,Z) FOR LARGE FNU APPLIED IN
      !     -PI/3.LE.ARG(Z).LE.PI/3
      !-----------------------------------------------------------------------
      CALL ZUNI1(Zr,Zi,gnu,Kode,2,cyr,cyi,nw,Nlast,Fnul,Tol,Elim,Alim)
    ENDIF
    IF ( nw>=0 ) THEN
      IF ( nw/=0 ) THEN
        Nlast = N
        GOTO 99999
      ELSE
        str = ZABS(cyr(1),cyi(1))
        !----------------------------------------------------------------------
        !     SCALE BACKWARD RECURRENCE, BRY(3) IS DEFINED BUT NEVER USED
        !----------------------------------------------------------------------
        bry(1) = 1.0D+3*D1MACH(1)/Tol
        bry(2) = 1.0D0/bry(1)
        bry(3) = bry(2)
        iflag = 2
        ascle = bry(2)
        csclr = 1.0D0
        IF ( str<=bry(1) ) THEN
          iflag = 1
          ascle = bry(1)
          csclr = 1.0D0/Tol
        ELSEIF ( str>=bry(2) ) THEN
          iflag = 3
          ascle = bry(3)
          csclr = Tol
        ENDIF
        cscrr = 1.0D0/csclr
        s1r = cyr(2)*csclr
        s1i = cyi(2)*csclr
        s2r = cyr(1)*csclr
        s2i = cyi(1)*csclr
        raz = 1.0D0/ZABS(Zr,Zi)
        str = Zr*raz
        sti = -Zi*raz
        rzr = (str+str)*raz
        rzi = (sti+sti)*raz
        DO i = 1, Nui
          str = s2r
          sti = s2i
          s2r = (dfnu+fnui)*(rzr*str-rzi*sti) + s1r
          s2i = (dfnu+fnui)*(rzr*sti+rzi*str) + s1i
          s1r = str
          s1i = sti
          fnui = fnui - 1.0D0
          IF ( iflag<3 ) THEN
            str = s2r*cscrr
            sti = s2i*cscrr
            c1r = ABS(str)
            c1i = ABS(sti)
            c1m = MAX(c1r,c1i)
            IF ( c1m>ascle ) THEN
              iflag = iflag + 1
              ascle = bry(iflag)
              s1r = s1r*cscrr
              s1i = s1i*cscrr
              s2r = str
              s2i = sti
              csclr = csclr*Tol
              cscrr = 1.0D0/csclr
              s1r = s1r*csclr
              s1i = s1i*csclr
              s2r = s2r*csclr
              s2i = s2i*csclr
            ENDIF
          ENDIF
        ENDDO
        Yr(N) = s2r*cscrr
        Yi(N) = s2i*cscrr
        IF ( N==1 ) RETURN
        nl = N - 1
        fnui = nl
        k = nl
        DO i = 1, nl
          str = s2r
          sti = s2i
          s2r = (Fnu+fnui)*(rzr*str-rzi*sti) + s1r
          s2i = (Fnu+fnui)*(rzr*sti+rzi*str) + s1i
          s1r = str
          s1i = sti
          str = s2r*cscrr
          sti = s2i*cscrr
          Yr(k) = str
          Yi(k) = sti
          fnui = fnui - 1.0D0
          k = k - 1
          IF ( iflag<3 ) THEN
            c1r = ABS(str)
            c1i = ABS(sti)
            c1m = MAX(c1r,c1i)
            IF ( c1m>ascle ) THEN
              iflag = iflag + 1
              ascle = bry(iflag)
              s1r = s1r*cscrr
              s1i = s1i*cscrr
              s2r = str
              s2i = sti
              csclr = csclr*Tol
              cscrr = 1.0D0/csclr
              s1r = s1r*csclr
              s1i = s1i*csclr
              s2r = s2r*csclr
              s2i = s2i*csclr
            ENDIF
          ENDIF
        ENDDO
        RETURN
      ENDIF
    ENDIF
  ENDIF
  Nz = -1
  IF ( nw==(-2) ) Nz = -2
  RETURN
  100  Nz = nw
  RETURN
  99999 CONTINUE
  END SUBROUTINE ZBUNI