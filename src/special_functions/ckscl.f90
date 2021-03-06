!** CKSCL
PURE SUBROUTINE CKSCL(Zr,Fnu,N,Y,Nz,Rz,Ascle,Tol,Elim)
  !> Subsidiary to CBKNU, CUNK1 and CUNK2
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      ALL (CKSCL-A, ZKSCL-A)
  !***
  ! **Author:**  Amos, D. E., (SNL)
  !***
  ! **Description:**
  !
  !     SET K FUNCTIONS TO ZERO ON UNDERFLOW, CONTINUE RECURRENCE
  !     ON SCALED FUNCTIONS UNTIL TWO MEMBERS COME ON SCALE, THEN
  !     RETURN WITH MIN(NZ+2,N) VALUES SCALED BY 1/TOL.
  !
  !***
  ! **See also:**  CBKNU, CUNK1, CUNK2
  !***
  ! **Routines called:**  CUCHK

  !* REVISION HISTORY  (YYMMDD)
  !   ??????  DATE WRITTEN
  !   910415  Prologue converted to Version 4.0 format.  (BAB)

  INTEGER, INTENT(IN) :: N
  INTEGER, INTENT(OUT) :: Nz
  REAL(SP), INTENT(IN) :: Ascle, Elim, Fnu, Tol
  COMPLEX(SP), INTENT(IN) :: Rz, Zr
  COMPLEX(SP), INTENT(OUT) :: Y(N)
  !
  INTEGER :: i, ic, k, kk, nn, nw
  COMPLEX(SP) :: ck, cs, cy(2), s1, s2, zd, celm
  REAL(SP) :: aa, acs, as, csi, csr, fn, xx, zri, elm, alas, helim
  !* FIRST EXECUTABLE STATEMENT  CKSCL
  Nz = 0
  ic = 0
  xx = REAL(Zr,SP)
  nn = MIN(2,N)
  DO i = 1, nn
    s1 = Y(i)
    cy(i) = s1
    as = ABS(s1)
    acs = -xx + LOG(as)
    Nz = Nz + 1
    Y(i) = (0._SP,0._SP)
    IF( acs>=(-Elim) ) THEN
      cs = -Zr + LOG(s1)
      csr = REAL(cs,SP)
      csi = AIMAG(cs)
      aa = EXP(csr)/Tol
      cs = CMPLX(aa,0._SP,SP)*CMPLX(COS(csi),SIN(csi),SP)
      CALL CUCHK(cs,nw,Ascle,Tol)
      IF( nw==0 ) THEN
        Y(i) = cs
        Nz = Nz - 1
        ic = i
      END IF
    END IF
  END DO
  IF( N==1 ) RETURN
  IF( ic<=1 ) THEN
    Y(1) = (0._SP,0._SP)
    Nz = 2
  END IF
  IF( N==2 ) RETURN
  IF( Nz==0 ) RETURN
  fn = Fnu + 1._SP
  ck = CMPLX(fn,0._SP,SP)*Rz
  s1 = cy(1)
  s2 = cy(2)
  helim = 0.5_SP*Elim
  elm = EXP(-Elim)
  celm = CMPLX(elm,0._SP,SP)
  zri = AIMAG(Zr)
  zd = Zr
  !
  !     FIND TWO CONSECUTIVE Y VALUES ON SCALE. SCALE RECURRENCE IF
  !     S2 GETS LARGER THAN EXP(ELIM/2)
  !
  DO i = 3, N
    kk = i
    cs = s2
    s2 = ck*s2 + s1
    s1 = cs
    ck = ck + Rz
    as = ABS(s2)
    alas = LOG(as)
    acs = -xx + alas
    Nz = Nz + 1
    Y(i) = (0._SP,0._SP)
    IF( acs>=(-Elim) ) THEN
      cs = -zd + LOG(s2)
      csr = REAL(cs,SP)
      csi = AIMAG(cs)
      aa = EXP(csr)/Tol
      cs = CMPLX(aa,0._SP,SP)*CMPLX(COS(csi),SIN(csi),SP)
      CALL CUCHK(cs,nw,Ascle,Tol)
      IF( nw==0 ) THEN
        Y(i) = cs
        Nz = Nz - 1
        IF( ic==(kk-1) ) GOTO 100
        ic = kk
        CYCLE
      END IF
    END IF
    IF( alas>=helim ) THEN
      xx = xx - Elim
      s1 = s1*celm
      s2 = s2*celm
      zd = CMPLX(xx,zri,SP)
    END IF
  END DO
  Nz = N
  IF( ic==N ) Nz = N - 1
  GOTO 200
  100  Nz = kk - 2
  200 CONTINUE
  DO k = 1, Nz
    Y(k) = (0._SP,0._SP)
  END DO
  !
END SUBROUTINE CKSCL