!** CUNI2
PURE SUBROUTINE CUNI2(Z,Fnu,Kode,N,Y,Nz,Nlast,Fnul,Tol,Elim,Alim)
  !> Subsidiary to CBESI and CBESK
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      ALL (CUNI2-A, ZUNI2-A)
  !***
  ! **Author:**  Amos, D. E., (SNL)
  !***
  ! **Description:**
  !
  !     CUNI2 COMPUTES I(FNU,Z) IN THE RIGHT HALF PLANE BY MEANS OF
  !     UNIFORM ASYMPTOTIC EXPANSION FOR J(FNU,ZN) WHERE ZN IS Z*I
  !     OR -Z*I AND ZN IS IN THE RIGHT HALF PLANE ALSO.
  !
  !     FNUL IS THE SMALLEST ORDER PERMITTED FOR THE ASYMPTOTIC
  !     EXPANSION. NLAST=0 MEANS ALL OF THE Y VALUES WERE SET.
  !     NLAST/=0 IS THE NUMBER LEFT TO BE COMPUTED BY ANOTHER
  !     FORMULA FOR ORDERS FNU TO FNU+NLAST-1 BECAUSE FNU+NLAST-1<FNUL.
  !     Y(I)=CZERO FOR I=NLAST+1,N
  !
  !***
  ! **See also:**  CBESI, CBESK
  !***
  ! **Routines called:**  CAIRY, CUCHK, CUNHJ, CUOIK, R1MACH

  !* REVISION HISTORY  (YYMMDD)
  !   830501  DATE WRITTEN
  !   910415  Prologue converted to Version 4.0 format.  (BAB)
  USE service, ONLY : tiny_sp, huge_sp
  !
  INTEGER, INTENT(IN) :: Kode, N
  INTEGER, INTENT(OUT) :: Nlast, Nz
  REAL(SP), INTENT(IN) :: Alim, Elim, Fnu, Fnul, Tol
  COMPLEX(SP), INTENT(IN) :: Z
  COMPLEX(SP), INTENT(OUT) :: Y(N)
  !
  INTEGER :: i, iflag, in, inu, j, k, nai, nd, ndai, nn, nuf, nw, idum
  COMPLEX(SP) :: ai, arg, asum, bsum, cfn, cid, crsc, cscl, csr(3), css(3), cy(2), c1, &
    c2, dai, phi, rz, s1, s2, zb, zeta1, zeta2, zn, zar
  REAL(SP) :: aarg, ang, aphi, ascle, ay, bry(3), car, c2i, c2m, c2r, fn, &
    rs1, sar, yy
  COMPLEX(SP), PARAMETER :: ci= (0._SP,1._SP)
  COMPLEX(SP), PARAMETER :: cip(4) = [ (1._SP,0._SP), (0._SP,1._SP), &
    (-1._SP,0._SP), (0._SP,-1._SP) ]
  REAL(SP), PARAMETER :: hpi = 1.57079632679489662_SP, aic = 1.265512123484645396_SP
  !* FIRST EXECUTABLE STATEMENT  CUNI2
  Nz = 0
  nd = N
  Nlast = 0
  !-----------------------------------------------------------------------
  !     COMPUTED VALUES WITH EXPONENTS BETWEEN ALIM AND ELIM IN MAG-
  !     NITUDE ARE SCALED TO KEEP INTERMEDIATE ARITHMETIC ON SCALE,
  !     EXP(ALIM)=EXP(ELIM)*TOL
  !-----------------------------------------------------------------------
  cscl = CMPLX(1._SP/Tol,0._SP,SP)
  crsc = CMPLX(Tol,0._SP,SP)
  css(1) = cscl
  css(2) = (1._SP,0._SP)
  css(3) = crsc
  csr(1) = crsc
  csr(2) = (1._SP,0._SP)
  csr(3) = cscl
  bry(1) = 1.E+3_SP*tiny_sp/Tol
  yy = AIMAG(Z)
  !-----------------------------------------------------------------------
  !     ZN IS IN THE RIGHT HALF PLANE AFTER ROTATION BY CI OR -CI
  !-----------------------------------------------------------------------
  zn = -Z*ci
  zb = Z
  cid = -ci
  inu = INT( Fnu )
  ang = hpi*(Fnu-inu)
  car = COS(ang)
  sar = SIN(ang)
  c2 = CMPLX(car,sar,SP)
  zar = c2
  in = inu + N - 1
  in = MOD(in,4)
  c2 = c2*cip(in+1)
  IF( yy<=0._SP ) THEN
    zn = CONJG(-zn)
    zb = CONJG(zb)
    cid = -cid
    c2 = CONJG(c2)
  END IF
  !-----------------------------------------------------------------------
  !     CHECK FOR UNDERFLOW AND OVERFLOW ON FIRST MEMBER
  !-----------------------------------------------------------------------
  fn = MAX(Fnu,1._SP)
  CALL CUNHJ(zn,fn,1,Tol,phi,arg,zeta1,zeta2,asum,bsum)
  IF( Kode==1 ) THEN
    s1 = -zeta1 + zeta2
  ELSE
    cfn = CMPLX(Fnu,0._SP,SP)
    s1 = -zeta1 + cfn*(cfn/(zb+zeta2))
  END IF
  rs1 = REAL(s1,SP)
  IF( ABS(rs1)>Elim ) THEN
    IF( rs1>0._SP ) GOTO 400
    Nz = N
    DO i = 1, N
      Y(i) = (0._SP,0._SP)
    END DO
    RETURN
  END IF
  100  nn = MIN(2,nd)
  DO i = 1, nn
    fn = Fnu + (nd-i)
    CALL CUNHJ(zn,fn,0,Tol,phi,arg,zeta1,zeta2,asum,bsum)
    IF( Kode==1 ) THEN
      s1 = -zeta1 + zeta2
    ELSE
      cfn = CMPLX(fn,0._SP,SP)
      ay = ABS(yy)
      s1 = -zeta1 + cfn*(cfn/(zb+zeta2)) + CMPLX(0._SP,ay,SP)
    END IF
    !-----------------------------------------------------------------------
    !     TEST FOR UNDERFLOW AND OVERFLOW
    !-----------------------------------------------------------------------
    rs1 = REAL(s1,SP)
    IF( ABS(rs1)>Elim ) GOTO 300
    IF( i==1 ) iflag = 2
    IF( ABS(rs1)>=Alim ) THEN
      !-----------------------------------------------------------------------
      !     REFINE  TEST AND SCALE
      !-----------------------------------------------------------------------
      !-----------------------------------------------------------------------
      aphi = ABS(phi)
      aarg = ABS(arg)
      rs1 = rs1 + LOG(aphi) - 0.25_SP*LOG(aarg) - aic
      IF( ABS(rs1)>Elim ) GOTO 300
      IF( i==1 ) iflag = 1
      IF( rs1>=0._SP ) THEN
        IF( i==1 ) iflag = 3
      END IF
    END IF
    !-----------------------------------------------------------------------
    !     SCALE S1 TO KEEP INTERMEDIATE ARITHMETIC ON SCALE NEAR
    !     EXPONENT EXTREMES
    !-----------------------------------------------------------------------
    CALL CAIRY(arg,0,2,ai,nai,idum)
    CALL CAIRY(arg,1,2,dai,ndai,idum)
    s2 = phi*(ai*asum+dai*bsum)
    c2r = REAL(s1,SP)
    c2i = AIMAG(s1)
    c2m = EXP(c2r)*REAL(css(iflag),SP)
    s1 = CMPLX(c2m,0._SP,SP)*CMPLX(COS(c2i),SIN(c2i),SP)
    s2 = s2*s1
    IF( iflag==1 ) THEN
      CALL CUCHK(s2,nw,bry(1),Tol)
      IF( nw/=0 ) GOTO 300
    END IF
    IF( yy<=0._SP ) s2 = CONJG(s2)
    j = nd - i + 1
    s2 = s2*c2
    cy(i) = s2
    Y(j) = s2*csr(iflag)
    c2 = c2*cid
  END DO
  IF( nd>2 ) THEN
    rz = CMPLX(2._SP,0._SP,SP)/Z
    bry(2) = 1._SP/bry(1)
    bry(3) = huge_sp
    s1 = cy(1)
    s2 = cy(2)
    c1 = csr(iflag)
    ascle = bry(iflag)
    k = nd - 2
    fn = k
    DO i = 3, nd
      c2 = s2
      s2 = s1 + CMPLX(Fnu+fn,0._SP,SP)*rz*s2
      s1 = c2
      c2 = s2*c1
      Y(k) = c2
      k = k - 1
      fn = fn - 1._SP
      IF( iflag<3 ) THEN
        c2r = REAL(c2,SP)
        c2i = AIMAG(c2)
        c2r = ABS(c2r)
        c2i = ABS(c2i)
        c2m = MAX(c2r,c2i)
        IF( c2m>ascle ) THEN
          iflag = iflag + 1
          ascle = bry(iflag)
          s1 = s1*c1
          s2 = c2
          s1 = s1*css(iflag)
          s2 = s2*css(iflag)
          c1 = csr(iflag)
        END IF
      END IF
    END DO
  END IF
  200  RETURN
  300 CONTINUE
  IF( rs1<=0._SP ) THEN
    !-----------------------------------------------------------------------
    !     SET UNDERFLOW AND UPDATE PARAMETERS
    !-----------------------------------------------------------------------
    Y(nd) = (0._SP,0._SP)
    Nz = Nz + 1
    nd = nd - 1
    IF( nd==0 ) GOTO 200
    CALL CUOIK(Z,Fnu,Kode,1,nd,Y,nuf,Tol,Elim,Alim)
    IF( nuf>=0 ) THEN
      nd = nd - nuf
      Nz = Nz + nuf
      IF( nd==0 ) GOTO 200
      fn = Fnu + (nd-1)
      IF( fn<Fnul ) THEN
        Nlast = nd
        RETURN
      ELSE
        !      FN = AIMAG(CID)
        !      J = NUF + 1
        !      K = MOD(J,4) + 1
        !      S1 = CIP(K)
        !      IF(FN<0.0E0) S1 = CONJG(S1)
        !      C2 = C2*S1
        in = inu + nd - 1
        in = MOD(in,4) + 1
        c2 = zar*cip(in)
        IF( yy<=0._SP ) c2 = CONJG(c2)
        GOTO 100
      END IF
    END IF
  END IF
  400  Nz = -1
  !
  RETURN
END SUBROUTINE CUNI2