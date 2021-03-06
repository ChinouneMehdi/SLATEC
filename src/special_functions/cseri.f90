!** CSERI
PURE SUBROUTINE CSERI(Z,Fnu,Kode,N,Y,Nz,Tol,Elim,Alim)
  !> Subsidiary to CBESI and CBESK
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      ALL (CSERI-A, ZSERI-A)
  !***
  ! **Author:**  Amos, D. E., (SNL)
  !***
  ! **Description:**
  !
  !     CSERI COMPUTES THE I BESSEL FUNCTION FOR REAL(Z)>=0.0 BY
  !     MEANS OF THE POWER SERIES FOR LARGE ABS(Z) IN THE
  !     REGION ABS(Z)<=2*SQRT(FNU+1). NZ=0 IS A NORMAL RETURN.
  !     NZ>0 MEANS THAT THE LAST NZ COMPONENTS WERE SET TO ZERO
  !     DUE TO UNDERFLOW. NZ<0 MEANS UNDERFLOW OCCURRED, BUT THE
  !     CONDITION ABS(Z)<=2*SQRT(FNU+1) WAS VIOLATED AND THE
  !     COMPUTATION MUST BE COMPLETED IN ANOTHER ROUTINE WITH N=N-ABS(NZ).
  !
  !***
  ! **See also:**  CBESI, CBESK
  !***
  ! **Routines called:**  CUCHK, GAMLN, R1MACH

  !* REVISION HISTORY  (YYMMDD)
  !   830501  DATE WRITTEN
  !   910415  Prologue converted to Version 4.0 format.  (BAB)
  USE service, ONLY : tiny_sp
  !
  INTEGER, INTENT(IN) :: Kode, N
  INTEGER, INTENT(OUT) :: Nz
  REAL(SP), INTENT(IN) :: Alim, Elim, Fnu, Tol
  COMPLEX(SP), INTENT(IN) :: Z
  COMPLEX(SP), INTENT(OUT) :: Y(N)
  !
  INTEGER :: i, ib, iflag, il, k, l, m, nn, nw
  COMPLEX(SP) :: ak1, ck, coef, crsc, cz, hz, rz, s1, s2, w(2)
  REAL(SP) :: aa, acz, ak, arm, ascle, atol, az, dfnu, &
    fnup, rak1, rs, rtr1, s, ss, x
  !* FIRST EXECUTABLE STATEMENT  CSERI
  Nz = 0
  az = ABS(Z)
  IF( az==0._SP ) GOTO 500
  x = REAL(Z,SP)
  arm = 1.E+3_SP*tiny_sp
  rtr1 = SQRT(arm)
  crsc = CMPLX(1._SP,0._SP,SP)
  iflag = 0
  IF( az<arm ) THEN
    Nz = N
    IF( Fnu==0._SP ) Nz = Nz - 1
    GOTO 500
  ELSE
    hz = Z*CMPLX(0.5_SP,0._SP,SP)
    cz = (0._SP,0._SP)
    IF( az>rtr1 ) cz = hz*hz
    acz = ABS(cz)
    nn = N
    ck = LOG(hz)
  END IF
  100  dfnu = Fnu + (nn-1)
  fnup = dfnu + 1._SP
  !-----------------------------------------------------------------------
  !     UNDERFLOW TEST
  !-----------------------------------------------------------------------
  ak1 = ck*CMPLX(dfnu,0._SP,SP)
  ak = LOG_GAMMA(fnup)
  ak1 = ak1 - CMPLX(ak,0._SP,SP)
  IF( Kode==2 ) ak1 = ak1 - CMPLX(x,0._SP,SP)
  rak1 = REAL(ak1,SP)
  IF( rak1>(-Elim) ) THEN
    IF( rak1<=(-Alim) ) THEN
      iflag = 1
      ss = 1._SP/Tol
      crsc = CMPLX(Tol,0._SP,SP)
      ascle = arm*ss
    END IF
    ak = AIMAG(ak1)
    aa = EXP(rak1)
    IF( iflag==1 ) aa = aa*ss
    coef = CMPLX(aa,0._SP,SP)*CMPLX(COS(ak),SIN(ak),SP)
    atol = Tol*acz/fnup
    il = MIN(2,nn)
    DO i = 1, il
      dfnu = Fnu + (nn-i)
      fnup = dfnu + 1._SP
      s1 = (1._SP,0._SP)
      IF( acz>=Tol*fnup ) THEN
        ak1 = (1._SP,0._SP)
        ak = fnup + 2._SP
        s = fnup
        aa = 2._SP
        DO
          rs = 1._SP/s
          ak1 = ak1*cz*CMPLX(rs,0._SP,SP)
          s1 = s1 + ak1
          s = s + ak
          ak = ak + 2._SP
          aa = aa*acz*rs
          IF( aa<=atol ) EXIT
        END DO
      END IF
      m = nn - i + 1
      s2 = s1*coef
      w(i) = s2
      IF( iflag/=0 ) THEN
        CALL CUCHK(s2,nw,ascle,Tol)
        IF( nw/=0 ) GOTO 200
      END IF
      Y(m) = s2*crsc
      IF( i/=il ) coef = coef*CMPLX(dfnu,0._SP,SP)/hz
    END DO
    IF( nn<=2 ) RETURN
    k = nn - 2
    ak = k
    rz = (2._SP,0._SP)/Z
    IF( iflag==1 ) THEN
      !-----------------------------------------------------------------------
      !     RECUR BACKWARD WITH SCALED VALUES
      !-----------------------------------------------------------------------
      !-----------------------------------------------------------------------
      !     EXP(-ALIM)=EXP(-ELIM)/TOL=APPROX. ONE PRECISION ABOVE THE
      !     UNDERFLOW LIMIT = ASCLE = tiny_sp*CSCL*1.0E+3
      !-----------------------------------------------------------------------
      s1 = w(1)
      s2 = w(2)
      DO l = 3, nn
        ck = s2
        s2 = s1 + CMPLX(ak+Fnu,0._SP,SP)*rz*s2
        s1 = ck
        ck = s2*crsc
        Y(k) = ck
        ak = ak - 1._SP
        k = k - 1
        IF( ABS(ck)>ascle ) GOTO 400
      END DO
      RETURN
    ELSE
      ib = 3
      GOTO 300
    END IF
  END IF
  200  Nz = Nz + 1
  Y(nn) = (0._SP,0._SP)
  IF( acz>dfnu ) THEN
    !-----------------------------------------------------------------------
    !     RETURN WITH NZ<0 IF ABS(Z*Z/4)>FNU+N-NZ-1 COMPLETE
    !     THE CALCULATION IN CBINU WITH N=N-ABS(NZ)
    !-----------------------------------------------------------------------
    Nz = -Nz
    RETURN
  ELSE
    nn = nn - 1
    IF( nn==0 ) RETURN
    GOTO 100
  END IF
  300 CONTINUE
  DO i = ib, nn
    Y(k) = CMPLX(ak+Fnu,0._SP,SP)*rz*Y(k+1) + Y(k+2)
    ak = ak - 1._SP
    k = k - 1
  END DO
  RETURN
  400  ib = l + 1
  IF( ib>nn ) RETURN
  GOTO 300
  500  Y(1) = (0._SP,0._SP)
  IF( Fnu==0._SP ) Y(1) = (1._SP,0._SP)
  IF( N==1 ) RETURN
  Y = (0._SP,0._SP)
  !
  RETURN
END SUBROUTINE CSERI