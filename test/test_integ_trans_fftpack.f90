MODULE TEST51_MOD
  USE service, ONLY : SP, DP
  IMPLICIT NONE

CONTAINS
  !** FFTQX
  SUBROUTINE FFTQX(Lun,Kprint,Ipass)
    !> Quick check for the NCAR FFT routines.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Keywords:**  QUICK CHECK
    !***
    ! **Author:**  Swarztrauber, P. N., (NCAR)
    !***
    ! **Description:**
    !
    !     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    !
    !                       VERSION 4  APRIL 1985
    !
    !                         A TEST DRIVER FOR
    !          A PACKAGE OF FORTRAN SUBPROGRAMS FOR THE FAST FOURIER
    !           TRANSFORM OF PERIODIC AND OTHER SYMMETRIC SEQUENCES
    !
    !                              BY
    !
    !                       PAUL N SWARZTRAUBER
    !
    !    NATIONAL CENTER FOR ATMOSPHERIC RESEARCH  BOULDER, COLORADO 80307
    !
    !        WHICH IS SPONSORED BY THE NATIONAL SCIENCE FOUNDATION
    !
    !     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    !
    !
    !             THIS PROGRAM TESTS THE PACKAGE OF FAST FOURIER
    !     TRANSFORMS FOR BOTH COMPLEX AND REAL PERIODIC SEQUENCES AND
    !     CERTAIN OTHER SYMMETRIC SEQUENCES THAT ARE LISTED BELOW.
    !
    !     1.   RFFTI     INITIALIZE  RFFTF AND RFFTB
    !     2.   RFFTF     FORWARD TRANSFORM OF A REAL PERIODIC SEQUENCE
    !     3.   RFFTB     BACKWARD TRANSFORM OF A REAL COEFFICIENT ARRAY
    !
    !     4.   EZFFTI    INITIALIZE EZFFTF AND EZFFTB
    !     5.   EZFFTF    A SIMPLIFIED REAL PERIODIC FORWARD TRANSFORM
    !     6.   EZFFTB    A SIMPLIFIED REAL PERIODIC BACKWARD TRANSFORM
    !
    !     7.   SINTI     INITIALIZE SINT
    !     8.   SINT      SINE TRANSFORM OF A REAL ODD SEQUENCE
    !
    !     9.   COSTI     INITIALIZE COST
    !     10.  COST      COSINE TRANSFORM OF A REAL EVEN SEQUENCE
    !
    !     11.  SINQI     INITIALIZE SINQF AND SINQB
    !     12.  SINQF     FORWARD SINE TRANSFORM WITH ODD WAVE NUMBERS
    !     13.  SINQB     UNNORMALIZED INVERSE OF SINQF
    !
    !     14.  COSQI     INITIALIZE COSQF AND COSQB
    !     15.  COSQF     FORWARD COSINE TRANSFORM WITH ODD WAVE NUMBERS
    !     16.  COSQB     UNNORMALIZED INVERSE OF COSQF
    !
    !     17.  CFFTI     INITIALIZE CFFTF AND CFFTB
    !     18.  CFFTF     FORWARD TRANSFORM OF A COMPLEX PERIODIC SEQUENCE
    !     19.  CFFTB     UNNORMALIZED INVERSE OF CFFTF
    !
    !***
    ! **Routines called:**  CFFTB, CFFTF, CFFTI, COSQB, COSQF, COSQI, COST,
    !                    COSTI, EZFFTB, EZFFTF, EZFFTI, PIMACH, R1MACH,
    !                    RFFTB, RFFTF, RFFTI, SINQB, SINQF, SINQI, SINT,
    !                    SINTI

    !* REVISION HISTORY  (YYMMDD)
    !   790601  DATE WRITTEN
    !   890718  Changed computation of PI to use PIMACH.  (WRB)
    !   890911  Removed unnecessary intrinsics.  (WRB)
    !   890911  REVISION DATE from Version 3.2
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   901205  Changed usage of eps_2_sp to eps_sp.  (RWC)
    !   910708  Minor modifications in use of KPRINT.  (WRB)
    !   920211  Code cleaned up, an error in printing an error message fixed
    !           and comments on PASS/FAIL of individual tests added.  (WRB)
    !   920618  Code upgraded to "Version 4".  (BKS, WRB)
    !   930315  Modified RFFT* tests to compute "slow-transform" in DOUBLE PRECISION.  (WRB)
    USE service, ONLY : eps_sp
    USE integ_trans, ONLY : CFFTB, CFFTF, CFFTI, COSQB, COSQF, COSQI, COST, COSTI, &
      EZFFTB, EZFFTF, EZFFTI, RFFTB, RFFTF, RFFTI, SINQB, SINQF, SINQI, SINT, SINTI
    !     .. Scalar Arguments ..
    INTEGER :: Ipass, Kprint, Lun
    !     .. Local Scalars ..
    REAL(DP) :: arg, arg1, arg2, dt, summ, sum1, sum2, tpi
    REAL(SP) :: azero, azeroh, cf, cosqbt, cosqfb, cosqft, costfb, costt, &
      dcfb, dcfftb, dcfftf, dezb1, dezf1, dezfb, errmax, rftb, &
      rftf, rftfb, signn, sinqbt, sinqfb, sinqft, sintfb, sintt, sqrt2
    INTEGER :: i, j, k, modn, n, nm1, nns, np1, ns2, ns2m, nz
    !     .. Local Arrays ..
    COMPLEX(SP) :: cx(200), cy(200)
    REAL(SP) :: a(100), ah(100), b(100), bh(100), w(2000), x(200), xh(200), y(200)
    !     .. Intrinsic Functions ..
    INTRINSIC ABS, CABS, CMPLX, COS, MAX, MOD, SIN, SQRT
    !     .. Data statements ..
    INTEGER, PARAMETER :: nd(7) = [ 120, 54, 49, 32, 4, 3, 2 ]
    REAL(DP), PARAMETER :: pi = 3.14159265358979_DP
    !* FIRST EXECUTABLE STATEMENT  FFTQX
    sqrt2 = SQRT(2._SP)
    errmax = 2._SP*SQRT(eps_sp)
    nns = 7
    IF( Kprint>=2 ) WRITE (Lun,99001)
    !
    99001 FORMAT ('1'/' FFT QUICK CHECK')
    Ipass = 1
    DO nz = 1, nns
      n = nd(nz)
      IF( Kprint>=2 ) WRITE (Lun,99002) n
      99002 FORMAT (/' Test FFT routines with a sequence of length ',I3)
      modn = MOD(n,2)
      np1 = n + 1
      nm1 = n - 1
      DO j = 1, np1
        x(j) = SIN(j*sqrt2)
        y(j) = x(j)
        xh(j) = x(j)
      END DO
      !
      !       Test Subroutines RFFTI, RFFTF and RFFTB
      !
      CALL RFFTI(n,w)
      dt = (pi+pi)/n
      ns2 = (n+1)/2
      IF( ns2>=2 ) THEN
        DO k = 2, ns2
          sum1 = 0._DP
          sum2 = 0._DP
          arg = (k-1)*dt
          DO i = 1, n
            arg1 = (i-1)*arg
            sum1 = sum1 + x(i)*COS(arg1)
            sum2 = sum2 + x(i)*SIN(arg1)
          END DO
          y(2*k-2) = REAL( sum1, SP )
          y(2*k-1) = REAL( -sum2, SP )
        END DO
      END IF
      sum1 = 0._DP
      sum2 = 0._DP
      DO i = 1, nm1, 2
        sum1 = sum1 + x(i)
        sum2 = sum2 + x(i+1)
      END DO
      IF( modn==1 ) sum1 = sum1 + x(n)
      y(1) = REAL( sum1 + sum2, SP )
      IF( modn==0 ) y(n) = REAL( sum1 - sum2, SP )
      CALL RFFTF(n,x,w)
      rftf = 0._SP
      DO i = 1, n
        rftf = MAX(rftf,ABS(x(i)-y(i)))
        x(i) = xh(i)
      END DO
      rftf = rftf/n
      IF( rftf<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99003)
        99003 FORMAT (' Test of RFFTF PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99004)
        99004 FORMAT (' Test of RFFTF FAILED')
      END IF
      signn = 1._SP
      DO i = 1, n
        summ = 0.5_DP*x(1)
        arg = (i-1)*dt
        IF( ns2>=2 ) THEN
          DO k = 2, ns2
            arg1 = (k-1)*arg
            summ = summ + x(2*k-2)*COS(arg1) - x(2*k-1)*SIN(arg1)
          END DO
        END IF
        IF( modn==0 ) summ = summ + 0.5_DP*signn*x(n)
        y(i) = REAL( summ + summ, SP )
        signn = -signn
      END DO
      CALL RFFTB(n,x,w)
      rftb = 0._SP
      DO i = 1, n
        rftb = MAX(rftb,ABS(x(i)-y(i)))
        x(i) = xh(i)
        y(i) = xh(i)
      END DO
      rftb = rftb/n
      IF( rftb<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99005)
        99005 FORMAT (' Test of RFFTB PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99006)
        99006 FORMAT (' Test of RFFTB FAILED')
      END IF
      !
      CALL RFFTB(n,y,w)
      CALL RFFTF(n,y,w)
      cf = 1._SP/n
      rftfb = 0._SP
      DO i = 1, n
        rftfb = MAX(rftfb,ABS(cf*y(i)-x(i)))
      END DO
      IF( rftfb<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99007)
        99007 FORMAT (' Test of RFFTF and RFFTB PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99008)
        99008 FORMAT (' Test of RFFTF and RFFTB FAILED')
      END IF
      !
      !       Test Subroutines SINTI and SINT
      !
      dt = pi/n
      DO i = 1, nm1
        x(i) = xh(i)
      END DO
      DO i = 1, nm1
        y(i) = 0._SP
        arg1 = i*dt
        DO k = 1, nm1
          y(i) = y(i) + x(k)*REAL( SIN((k)*arg1), SP )
        END DO
        y(i) = y(i) + y(i)
      END DO
      CALL SINTI(nm1,w)
      CALL SINT(nm1,x,w)
      cf = 0.5_SP/n
      sintt = 0._SP
      DO i = 1, nm1
        sintt = MAX(sintt,ABS(x(i)-y(i)))
        x(i) = xh(i)
        y(i) = x(i)
      END DO
      sintt = cf*sintt
      IF( sintt<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99009)
        99009 FORMAT (' First test of SINT PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99010)
        99010 FORMAT (' First test of SINT FAILED')
      END IF
      CALL SINT(nm1,x,w)
      CALL SINT(nm1,x,w)
      sintfb = 0._SP
      DO i = 1, nm1
        sintfb = MAX(sintfb,ABS(cf*x(i)-y(i)))
      END DO
      IF( sintfb<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99011)
        99011 FORMAT (' Second test of SINT PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99012)
        99012 FORMAT (' Second test of SINT FAILED')
      END IF
      !
      !       Test Subroutines COSTI and COST
      !
      DO i = 1, np1
        x(i) = xh(i)
      END DO
      signn = 1._SP
      DO i = 1, np1
        y(i) = 0.5_SP*(x(1)+signn*x(n+1))
        arg = (i-1)*dt
        DO k = 2, n
          y(i) = y(i) + x(k)*REAL( COS((k-1)*arg), SP )
        END DO
        y(i) = y(i) + y(i)
        signn = -signn
      END DO
      CALL COSTI(np1,w)
      CALL COST(np1,x,w)
      costt = 0._SP
      DO i = 1, np1
        costt = MAX(costt,ABS(x(i)-y(i)))
        x(i) = xh(i)
        y(i) = xh(i)
      END DO
      costt = cf*costt
      IF( costt<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99013)
        99013 FORMAT (' First test of COST PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99014)
        99014 FORMAT (' First test of COST FAILED')
      END IF
      !
      CALL COST(np1,x,w)
      CALL COST(np1,x,w)
      costfb = 0._SP
      DO i = 1, np1
        costfb = MAX(costfb,ABS(cf*x(i)-y(i)))
      END DO
      IF( costfb<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99015)
        99015 FORMAT (' Second test of COST PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99016)
        99016 FORMAT (' Second test of COST FAILED')
      END IF
      !
      !       Test Subroutines SINQI, SINQF and SINQB
      !
      cf = 0.25_SP/n
      DO i = 1, n
        y(i) = xh(i)
      END DO
      dt = pi/(n+n)
      DO i = 1, n
        x(i) = 0._SP
        arg = i*dt
        DO k = 1, n
          x(i) = x(i) + y(k)*REAL( SIN((k+k-1)*arg), SP )
        END DO
        x(i) = 4._SP*x(i)
      END DO
      CALL SINQI(n,w)
      CALL SINQB(n,y,w)
      sinqbt = 0._SP
      DO i = 1, n
        sinqbt = MAX(sinqbt,ABS(y(i)-x(i)))
        x(i) = xh(i)
      END DO
      sinqbt = cf*sinqbt
      IF( sinqbt<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99017)
        99017 FORMAT (' Test of SINQB PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99018)
        99018 FORMAT (' Test of SINQB FAILED')
      END IF
      !
      signn = 1._SP
      DO i = 1, n
        arg = (i+i-1)*dt
        y(i) = 0.5_SP*signn*x(n)
        DO k = 1, nm1
          y(i) = y(i) + x(k)*REAL( SIN((k)*arg), SP )
        END DO
        y(i) = y(i) + y(i)
        signn = -signn
      END DO
      CALL SINQF(n,x,w)
      sinqft = 0._SP
      DO i = 1, n
        sinqft = MAX(sinqft,ABS(x(i)-y(i)))
        y(i) = xh(i)
        x(i) = xh(i)
      END DO
      IF( sinqft<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99019)
        99019 FORMAT (' Test of SINQF PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99020)
        99020 FORMAT (' Test of SINQF FAILED')
      END IF
      !
      CALL SINQF(n,y,w)
      CALL SINQB(n,y,w)
      sinqfb = 0._SP
      DO i = 1, n
        sinqfb = MAX(sinqfb,ABS(cf*y(i)-x(i)))
      END DO
      IF( sinqfb<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99021)
        99021 FORMAT (' Test of SINQF and SINQB PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99022)
        99022 FORMAT (' Test of SINQF and SINQB FAILED')
      END IF
      !
      !       Test Subroutines COSQI, COSQF and COSQB
      !
      DO i = 1, n
        y(i) = xh(i)
      END DO
      DO i = 1, n
        x(i) = 0._SP
        arg = (i-1)*dt
        DO k = 1, n
          x(i) = x(i) + y(k)*REAL( COS((k+k-1)*arg), SP )
        END DO
        x(i) = 4._SP*x(i)
      END DO
      CALL COSQI(n,w)
      CALL COSQB(n,y,w)
      cosqbt = 0._SP
      DO i = 1, n
        cosqbt = MAX(cosqbt,ABS(x(i)-y(i)))
        x(i) = xh(i)
      END DO
      cosqbt = cf*cosqbt
      IF( cosqbt<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99023)
        99023 FORMAT (' Test of COSQB PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99024)
        99024 FORMAT (' Test of COSQB FAILED')
      END IF
      !
      DO i = 1, n
        y(i) = 0.5_SP*x(1)
        arg = (i+i-1)*dt
        DO k = 2, n
          y(i) = y(i) + x(k)*REAL( COS((k-1)*arg), SP )
        END DO
        y(i) = y(i) + y(i)
      END DO
      CALL COSQF(n,x,w)
      cosqft = 0._SP
      DO i = 1, n
        cosqft = MAX(cosqft,ABS(y(i)-x(i)))
        x(i) = xh(i)
        y(i) = xh(i)
      END DO
      cosqft = cf*cosqft
      IF( cosqft<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99025)
        99025 FORMAT (' Test of COSQF PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99026)
        99026 FORMAT (' Test of COSQF FAILED')
      END IF
      !
      CALL COSQB(n,x,w)
      CALL COSQF(n,x,w)
      cosqfb = 0._SP
      DO i = 1, n
        cosqfb = MAX(cosqfb,ABS(cf*x(i)-y(i)))
      END DO
      IF( cosqfb<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99027)
        99027 FORMAT (' Test of COSQF and COSQB PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99028)
        99028 FORMAT (' Test of COSQF and COSQB FAILED')
      END IF
      !
      !       Test Subroutines EZFFTI, EZFFTF and EZFFTB
      !
      CALL EZFFTI(n,w)
      DO i = 1, n
        x(i) = xh(i)
      END DO
      tpi = 2._SP*pi
      dt = tpi/n
      ns2 = (n+1)/2
      cf = 2._SP/n
      ns2m = ns2 - 1
      IF( ns2m>0 ) THEN
        DO k = 1, ns2m
          sum1 = 0._DP
          sum2 = 0._DP
          arg = k*dt
          DO i = 1, n
            arg1 = (i-1)*arg
            sum1 = sum1 + x(i)*COS(arg1)
            sum2 = sum2 + x(i)*SIN(arg1)
          END DO
          a(k) = REAL( cf*sum1, SP )
          b(k) = REAL( cf*sum2, SP )
        END DO
      END IF
      nm1 = n - 1
      sum1 = 0._DP
      sum2 = 0._DP
      DO i = 1, nm1, 2
        sum1 = sum1 + x(i)
        sum2 = sum2 + x(i+1)
      END DO
      IF( modn==1 ) sum1 = sum1 + x(n)
      azero = REAL( 0.5_SP*cf*(sum1+sum2), SP )
      IF( modn==0 ) a(ns2) = REAL( 0.5_SP*cf*(sum1-sum2), SP )
      CALL EZFFTF(n,x,azeroh,ah,bh,w)
      dezf1 = ABS(azeroh-azero)
      IF( modn==0 ) dezf1 = MAX(dezf1,ABS(a(ns2)-ah(ns2)))
      IF( ns2m>0 ) THEN
        DO i = 1, ns2m
          dezf1 = MAX(dezf1,ABS(ah(i)-a(i)),ABS(bh(i)-b(i)))
        END DO
        IF( dezf1<=errmax ) THEN
          IF( Kprint>=3 ) WRITE (Lun,99029)
          99029 FORMAT (' Test of EZFFTF PASSED')
        ELSE
          Ipass = 0
          IF( Kprint>=2 ) WRITE (Lun,99030)
          99030 FORMAT (' Test of EZFFTF FAILED')
        END IF
      END IF
      !
      ns2 = n/2
      IF( modn==0 ) b(ns2) = 0._SP
      DO i = 1, n
        summ = azero
        arg1 = (i-1)*dt
        DO k = 1, ns2
          arg2 = k*arg1
          summ = summ + a(k)*COS(arg2) + b(k)*SIN(arg2)
        END DO
        x(i) = REAL( summ, SP )
      END DO
      CALL EZFFTB(n,y,azero,a,b,w)
      dezb1 = 0._SP
      DO i = 1, n
        dezb1 = MAX(dezb1,ABS(x(i)-y(i)))
        x(i) = xh(i)
      END DO
      IF( dezb1<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99031)
        99031 FORMAT (' Test of EZFFTB PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99032)
        99032 FORMAT (' Test of EZFFTB FAILED')
      END IF
      !
      CALL EZFFTF(n,x,azero,a,b,w)
      CALL EZFFTB(n,y,azero,a,b,w)
      dezfb = 0._SP
      DO i = 1, n
        dezfb = MAX(dezfb,ABS(x(i)-y(i)))
      END DO
      IF( dezfb<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99033)
        99033 FORMAT (' Test of EZFFTF and EZFFTB PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99034)
        99034 FORMAT (' Test of EZFFTF and EZFFTB FAILED')
      END IF
      !
      !       Test Subroutines CFFTI, CFFTF and CFFTB
      !
      DO i = 1, n
        cx(i) = CMPLX(COS(sqrt2*i),SIN(sqrt2*(i*i)),SP)
      END DO
      dt = (pi+pi)/n
      DO i = 1, n
        arg1 = -(i-1)*dt
        cy(i) = (0._SP,0._SP)
        DO k = 1, n
          arg2 = (k-1)*arg1
          cy(i) = cy(i) + CMPLX(COS(arg2),SIN(arg2),SP)*cx(k)
        END DO
      END DO
      CALL CFFTI(n,w)
      CALL CFFTF(n,cx,w)
      dcfftf = 0._SP
      DO i = 1, n
        dcfftf = MAX(dcfftf,ABS(cx(i)-cy(i)))
        cx(i) = cx(i)/n
      END DO
      dcfftf = dcfftf/n
      IF( dcfftf<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99035)
        99035 FORMAT (' Test of CFFTF PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99036)
        99036 FORMAT (' Test of CFFTF FAILED')
      END IF
      !
      DO i = 1, n
        arg1 = (i-1)*dt
        cy(i) = (0._SP,0._SP)
        DO k = 1, n
          arg2 = (k-1)*arg1
          cy(i) = cy(i) + CMPLX(COS(arg2),SIN(arg2),SP)*cx(k)
        END DO
      END DO
      CALL CFFTB(n,cx,w)
      dcfftb = 0._SP
      DO i = 1, n
        dcfftb = MAX(dcfftb,ABS(cx(i)-cy(i)))
        cx(i) = cy(i)
      END DO
      IF( dcfftb<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99037)
        99037 FORMAT (' Test of CFFTB PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99038)
        99038 FORMAT (' Test of CFFTB FAILED')
      END IF
      !
      cf = 1._SP/n
      CALL CFFTF(n,cx,w)
      CALL CFFTB(n,cx,w)
      dcfb = 0._SP
      DO i = 1, n
        dcfb = MAX(dcfb,ABS(cf*cx(i)-cy(i)))
      END DO
      IF( dcfb<=errmax ) THEN
        IF( Kprint>=3 ) WRITE (Lun,99039)
        99039 FORMAT (' Test of CFFTF and CFFTB PASSED')
      ELSE
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99040)
        99040 FORMAT (' Test of CFFTF and CFFTB FAILED')
      END IF
      IF( Kprint>=3 ) THEN
        WRITE (Lun,99041) n, rftf, rftb, rftfb, sintt, sintfb, costt, &
          costfb, sinqft, sinqbt, sinqfb, cosqft, &
          cosqbt, cosqfb, dezf1, dezb1, dezfb, dcfftf, dcfftb, dcfb
        99041 FORMAT ('0N',I5,'  RFFTF  ',E10.3,'  RFFTB  ',E10.3,'  RFFTFB ',E10.3/7X,&
          '  SINT   ',E10.3,'  SINTFB ',E10.3/7X,'  COST   ',E10.3,&
          '  COSTFB ',E10.3/7X,'  SINQF  ',E10.3,'  SINQB  ',E10.3,&
          '  SINQFB ',E10.3/7X,'  COSQF  ',E10.3,'  COSQB  ',E10.3,&
          '  COSQFB ',E10.3/7X,'  DEZF1  ',E10.3,'  DEZB1  ',E10.3,&
          '  DEZFB  ',E10.3/7X,'  CFFTF  ',E10.3,'  CFFTB  ',E10.3,&
          '  CFFTFB ',E10.3)
      END IF
    END DO
    IF( Kprint>=2 .AND. Ipass==1 ) WRITE (Lun,99042)
    99042 FORMAT (/' ***********FFT ROUTINES PASSED ALL TESTS************')
    IF( Kprint>=1 .AND. Ipass==0 ) WRITE (Lun,99043)
    99043 FORMAT (/' ***********FFT ROUTINES FAILED SOME TESTS***********')
    RETURN
  END SUBROUTINE FFTQX
END MODULE TEST51_MOD
!** TEST51
PROGRAM TEST51
  USE TEST51_MOD, ONLY : FFTQX
  USE ISO_FORTRAN_ENV, ONLY : INPUT_UNIT, OUTPUT_UNIT
  USE common_mod, ONLY : GET_ARGUMENT
  IMPLICIT NONE
  !> Driver for testing SLATEC subprograms
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  J1
  !***
  ! **Type:**      SINGLE PRECISION (TEST51-S)
  !***
  ! **Keywords:**  QUICK CHECK DRIVER
  !***
  ! **Author:**  SLATEC Common Mathematical Library Committee
  !***
  ! **Description:**
  !
  !- Usage:
  !     One input data record is required
  !         READ (LIN, '(I1)') KPRINT
  !
  !- Arguments:
  !     KPRINT = 0  Quick checks - No printing.
  !                 Driver       - Short pass or fail message printed.
  !              1  Quick checks - No message printed for passed tests,
  !                                short message printed for failed tests.
  !                 Driver       - Short pass or fail message printed.
  !              2  Quick checks - Print short message for passed tests,
  !                                fuller information for failed tests.
  !                 Driver       - Pass or fail message printed.
  !              3  Quick checks - Print complete quick check results.
  !                 Driver       - Pass or fail message printed.
  !
  !- Description:
  !     Driver for testing SLATEC subprograms
  !        COSQB    COSQF    COSQI    COST     COSTI    EZFFTB
  !        EZFFTF   RFFTB    RFFTF    RFFTI    SINQB    SINQF
  !        SINQI    SINT     SINTI
  !
  !***
  ! **References:**  Kirby W. Fong, Thomas H. Jefferson, Tokihiko Suyehiro
  !                 and Lee Walton, Guide to the SLATEC Common Mathema-
  !                 tical Library, April 10, 1990.
  !***
  ! **Routines called:**  FFTQX, I1MACH, XERMAX, XSETF

  !* REVISION HISTORY  (YYMMDD)
  !   890618  DATE WRITTEN
  !   890618  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900524  Cosmetic changes to code.  (WRB)
  INTEGER :: ipass, kprint, lin, lun, nfail
  !* FIRST EXECUTABLE STATEMENT  TEST51
  lun = OUTPUT_UNIT
  lin = INPUT_UNIT
  nfail = 0
  !
  !     Read KPRINT parameter
  !
  CALL GET_ARGUMENT(kprint)
  !
  !     Test FFT package
  !
  CALL FFTQX(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  !
  !     Write PASS or FAIL message
  !
  IF( nfail==0 ) THEN
    WRITE (lun,99001)
    99001 FORMAT (/' --------------TEST51 PASSED ALL TESTS----------------')
  ELSE
    WRITE (lun,99002) nfail
    99002 FORMAT (/' ************* WARNING -- ',I5,&
      ' TEST(S) FAILED IN PROGRAM TEST51 *************')
  END IF
  STOP
END PROGRAM TEST51
