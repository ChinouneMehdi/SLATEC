!** ZAIRY
ELEMENTAL SUBROUTINE ZAIRY(Z,Id,Kode,Ai,Nz,Ierr)
  !> Compute the Airy function Ai(z) or its derivative dAi/dz for complex argument z.
  !  A scaling option is available to help avoid underflow and overflow.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  C10D
  !***
  ! **Type:**      COMPLEX (CAIRY-C, ZAIRY-C)
  !***
  ! **Keywords:**  AIRY FUNCTION, BESSEL FUNCTION OF ORDER ONE THIRD,
  !             BESSEL FUNCTION OF ORDER TWO THIRDS
  !***
  ! **Author:**  Amos, D. E., (SNL)
  !***
  ! **Description:**
  !
  !                      ***A DOUBLE PRECISION ROUTINE***
  !         On KODE=1, ZAIRY computes the complex Airy function Ai(z)
  !         or its derivative dAi/dz on ID=0 or ID=1 respectively. On
  !         KODE=2, a scaling option exp(zeta)*Ai(z) or exp(zeta)*dAi/dz
  !         is provided to remove the exponential decay in -pi/3<arg(z)
  !         <pi/3 and the exponential growth in pi/3<abs(arg(z))<pi where
  !         zeta=(2/3)*z**(3/2).
  !
  !         While the Airy functions Ai(z) and dAi/dz are analytic in
  !         the whole z-plane, the corresponding scaled functions defined
  !         for KODE=2 have a cut along the negative real axis.
  !
  !         Input
  !           ZR     - DOUBLE PRECISION real part of argument Z
  !           ZI     - DOUBLE PRECISION imag part of argument Z
  !           ID     - Order of derivative, ID=0 or ID=1
  !           KODE   - A parameter to indicate the scaling option
  !                    KODE=1  returns
  !                            AI=Ai(z)  on ID=0
  !                            AI=dAi/dz on ID=1
  !                            at z=Z
  !                        =2  returns
  !                            AI=exp(zeta)*Ai(z)  on ID=0
  !                            AI=exp(zeta)*dAi/dz on ID=1
  !                            at z=Z where zeta=(2/3)*z**(3/2)
  !
  !         Output
  !           AIR    - DOUBLE PRECISION real part of result
  !           AII    - DOUBLE PRECISION imag part of result
  !           NZ     - Underflow indicator
  !                    NZ=0    Normal return
  !                    NZ=1    AI=0 due to underflow in
  !                            -pi/3<arg(Z)<pi/3 on KODE=1
  !           IERR   - Error flag
  !                    IERR=0  Normal return     - COMPUTATION COMPLETED
  !                    IERR=1  Input error       - NO COMPUTATION
  !                    IERR=2  Overflow          - NO COMPUTATION
  !                            (Re(Z) too large with KODE=1)
  !                    IERR=3  Precision warning - COMPUTATION COMPLETED
  !                            (Result has less than half precision)
  !                    IERR=4  Precision error   - NO COMPUTATION
  !                            (Result has no precision)
  !                    IERR=5  Algorithmic error - NO COMPUTATION
  !                            (Termination condition not met)
  !
  !- Long Description:
  !
  !         Ai(z) and dAi/dz are computed from K Bessel functions by
  !
  !                Ai(z) =  c*sqrt(z)*K(1/3,zeta)
  !               dAi/dz = -c*   z   *K(2/3,zeta)
  !                    c =  1/(pi*sqrt(3))
  !                 zeta =  (2/3)*z**(3/2)
  !
  !         when abs(z)>1 and from power series when abs(z)<=1.
  !
  !         In most complex variable computation, one must evaluate ele-
  !         mentary functions.  When the magnitude of Z is large, losses
  !         of significance by argument reduction occur.  Consequently, if
  !         the magnitude of ZETA=(2/3)*Z**(3/2) exceeds U1=SQRT(0.5/UR),
  !         then losses exceeding half precision are likely and an error
  !         flag IERR=3 is triggered where UR=MAX(eps_dp,1.0D-18) is
  !         double precision unit roundoff limited to 18 digits precision.
  !         Also, if the magnitude of ZETA is larger than U2=0.5/UR, then
  !         all significance is lost and IERR=4.  In order to use the INT
  !         function, ZETA must be further restricted not to exceed
  !         U3=huge_int=LARGEST INTEGER.  Thus, the magnitude of ZETA
  !         must be restricted by MIN(U2,U3).  In IEEE arithmetic, U1,U2,
  !         and U3 are approximately 2.0E+3, 4.2E+6, 2.1E+9 in single
  !         precision and 4.7E+7, 2.3E+15, 2.1E+9 in double precision.
  !         This makes U2 limiting is single precision and U3 limiting
  !         in double precision.  This means that the magnitude of Z
  !         cannot exceed approximately 3.4E+4 in single precision and
  !         2.1E+6 in double precision.  This also means that one can
  !         expect to retain, in the worst cases on 32-bit machines,
  !         no digits in single precision and only 6 digits in double
  !         precision.
  !
  !         The approximate relative error in the magnitude of a complex
  !         Bessel function can be expressed as P*10**S where P=MAX(UNIT
  !         ROUNDOFF,1.0E-18) is the nominal precision and 10**S repre-
  !         sents the increase in error due to argument reduction in the
  !         elementary functions.  Here, S=MAX(1,ABS(LOG10(ABS(Z))),
  !         ABS(LOG10(FNU))) approximately (i.e., S=MAX(1,ABS(EXPONENT OF
  !         ABS(Z),ABS(EXPONENT OF FNU)) ).  However, the phase angle may
  !         have only absolute accuracy.  This is most likely to occur
  !         when one component (in magnitude) is larger than the other by
  !         several orders of magnitude.  If one component is 10**K larger
  !         than the other, then one can expect only MAX(ABS(LOG10(P))-K,
  !         0) significant digits; or, stated another way, when K exceeds
  !         the exponent of P, no significant digits remain in the smaller
  !         component.  However, the phase angle retains absolute accuracy
  !         because, in complex arithmetic with precision P, the smaller
  !         component will not (as a rule) decrease below P times the
  !         magnitude of the larger component. In these extreme cases,
  !         the principal phase angle is on the order of +P, -P, PI/2-P,
  !         or -PI/2+P.
  !
  !***
  ! **References:**  1. M. Abramowitz and I. A. Stegun, Handbook of Mathe-
  !                 matical Functions, National Bureau of Standards
  !                 Applied Mathematics Series 55, U. S. Department
  !                 of Commerce, Tenth Printing (1972) or later.
  !               2. D. E. Amos, Computation of Bessel Functions of
  !                 Complex Argument and Large Order, Report SAND83-0643,
  !                 Sandia National Laboratories, Albuquerque, NM, May
  !                 1983.
  !               3. D. E. Amos, A Subroutine Package for Bessel Functions
  !                 of a Complex Argument and Nonnegative Order, Report
  !                 SAND85-1018, Sandia National Laboratory, Albuquerque,
  !                 NM, May 1985.
  !               4. D. E. Amos, A portable package for Bessel functions
  !                 of a complex argument and nonnegative order, ACM
  !                 Transactions on Mathematical Software, 12 (September
  !                 1986), pp. 265-273.
  !
  !***
  ! **Routines called:**  D1MACH, I1MACH, ZABS, ZACAI, ZBKNU, ZEXP, ZSQRT

  !* REVISION HISTORY  (YYMMDD)
  !   830501  DATE WRITTEN
  !   890801  REVISION DATE from Version 3.2
  !   910415  Prologue converted to Version 4.0 format.  (BAB)
  !   920128  Category corrected.  (WRB)
  !   920811  Prologue revised.  (DWL)
  !   930122  Added ZEXP and ZSQRT to EXTERNAL statement.  (RWC)
  USE service, ONLY : eps_dp, log10_radix_dp, tiny_dp, digits_dp, huge_int, &
    max_exp_dp, min_exp_dp
  !
  INTEGER, INTENT(IN) :: Id, Kode
  INTEGER, INTENT(OUT) :: Ierr, Nz
  COMPLEX(DP), INTENT(IN) :: Z
  COMPLEX(DP), INTENT(OUT) :: Ai
  !
  INTEGER :: iflag, k, k1, k2, mr, nn
  REAL(DP) :: aa, ad, ak, alim, atrm, az, az3, bk, ck, dig, dk, d1, d2, elim, fid, fnu, &
  rl, r1m5, sfac, tol, zi, zr, z3i, z3r, bb, alaz
  COMPLEX(DP) :: csq, cy(1), s1, s2, trm1, trm2, zta, z3
  REAL(DP), PARAMETER :: tth = 6.66666666666666667E-01_DP, &
    c1 = 3.55028053887817240E-01_DP, c2 = 2.58819403792806799E-01_DP, &
    coef = 1.83776298473930683E-01_DP
  !* FIRST EXECUTABLE STATEMENT  ZAIRY
  Ierr = 0
  Nz = 0
  IF( Id<0 .OR. Id>1 ) Ierr = 1
  IF( Kode<1 .OR. Kode>2 ) Ierr = 1
  IF( Ierr/=0 ) RETURN
  az = ABS(Z)
  tol = MAX(eps_dp,1.E-18_DP)
  fid = Id
  IF( az>1._DP ) THEN
    !-----------------------------------------------------------------------
    !     CASE FOR ABS(Z)>1.0
    !-----------------------------------------------------------------------
    fnu = (1._DP+fid)/3._DP
    !-----------------------------------------------------------------------
    !     SET PARAMETERS RELATED TO MACHINE CONSTANTS.
    !     TOL IS THE APPROXIMATE UNIT ROUNDOFF LIMITED TO 1.0E-18.
    !     ELIM IS THE APPROXIMATE EXPONENTIAL OVER- AND UNDERFLOW LIMIT.
    !     EXP(-ELIM)<EXP(-ALIM)=EXP(-ELIM)/TOL    AND
    !     EXP(ELIM)>EXP(ALIM)=EXP(ELIM)*TOL       ARE INTERVALS NEAR
    !     UNDERFLOW AND OVERFLOW LIMITS WHERE SCALED ARITHMETIC IS DONE.
    !     RL IS THE LOWER BOUNDARY OF THE ASYMPTOTIC EXPANSION FOR LARGE Z.
    !     DIG = NUMBER OF BASE 10 DIGITS IN TOL = 10**(-DIG).
    !-----------------------------------------------------------------------
    k1 = min_exp_dp
    k2 = max_exp_dp
    r1m5 = log10_radix_dp
    k = MIN(ABS(k1),ABS(k2))
    elim = 2.303_DP*(k*r1m5-3._DP)
    k1 = digits_dp - 1
    aa = r1m5*k1
    dig = MIN(aa,18._DP)
    aa = aa*2.303_DP
    alim = elim + MAX(-aa,-41.45_DP)
    rl = 1.2_DP*dig + 3._DP
    alaz = LOG(az)
    !-----------------------------------------------------------------------
    !     TEST FOR RANGE
    !-----------------------------------------------------------------------
    aa = 0.5_DP/tol
    bb = 0.5_DP*huge_int
    aa = MIN(aa,bb)
    aa = aa**tth
    IF( az>aa ) THEN
      Ierr = 4
      Nz = 0
      RETURN
    ELSE
      aa = SQRT(aa)
      IF( az>aa ) Ierr = 3
      csq = SQRT(Z)
      zta = Z*csq*CMPLX(tth,0._DP,DP)
      !-----------------------------------------------------------------------
      !     RE(ZTA)<=0 WHEN RE(Z)<0, ESPECIALLY WHEN IM(Z) IS SMALL
      !-----------------------------------------------------------------------
      iflag = 0
      sfac = 1._DP
      zi = AIMAG(Z)
      zr = REAL(Z,DP)
      ak = AIMAG(zta)
      IF( zr<0._DP ) THEN
        bk = REAL(zta,DP)
        ck = -ABS(bk)
        zta = CMPLX(ck,ak,DP)
      END IF
      IF( zi==0._DP ) THEN
        IF( zr<=0._DP ) zta = CMPLX(0._DP,ak,DP)
      END IF
      aa = REAL(zta,DP)
      IF( aa<0._DP .OR. zr<=0._DP ) THEN
        IF( Kode/=2 ) THEN
          !-----------------------------------------------------------------------
          !     OVERFLOW TEST
          !-----------------------------------------------------------------------
          IF( aa<=(-alim) ) THEN
            aa = -aa + 0.25_DP*alaz
            iflag = 1
            sfac = tol
            IF( aa>elim ) GOTO 50
          END IF
        END IF
        !-----------------------------------------------------------------------
        !     ZBKNU AND ZACAI RETURN EXP(ZTA)*K(FNU,ZTA) ON KODE=2
        !-----------------------------------------------------------------------
        mr = 1
        IF( zi<0._DP ) mr = -1
        CALL ZACAI(zta,fnu,Kode,mr,1,cy,nn,rl,tol,elim,alim)
        IF( nn<0 ) THEN
          IF( nn/=(-1) ) GOTO 100
          GOTO 50
        ELSE
          Nz = Nz + nn
        END IF
      ELSEIF( Kode==2 ) THEN
        CALL ZBKNU(zta,fnu,Kode,1,cy,Nz,tol,elim,alim)
        !-----------------------------------------------------------------------
        !     UNDERFLOW TEST
        !-----------------------------------------------------------------------
      ELSEIF( aa<alim ) THEN
        CALL ZBKNU(zta,fnu,Kode,1,cy,Nz,tol,elim,alim)
      ELSE
        aa = -aa - 0.25_DP*alaz
        iflag = 2
        sfac = 1._DP/tol
        IF( aa<(-elim) ) THEN
          Nz = 1
          Ai = CMPLX(0._DP,0._DP,DP)
          RETURN
        ELSE
          CALL ZBKNU(zta,fnu,Kode,1,cy,Nz,tol,elim,alim)
        END IF
      END IF
      s1 = cy(1)*CMPLX(coef,0._DP,DP)
      IF( iflag/=0 ) THEN
        s1 = s1*CMPLX(sfac,0._DP,DP)
        IF( Id==1 ) THEN
          s1 = -s1*Z
          Ai = s1*CMPLX(1._DP/sfac,0._DP,DP)
          RETURN
        ELSE
          s1 = s1*csq
          Ai = s1*CMPLX(1._DP/sfac,0._DP,DP)
          RETURN
        END IF
      ELSEIF( Id==1 ) THEN
        Ai = -Z*s1
        RETURN
      ELSE
        Ai = csq*s1
        RETURN
      END IF
    END IF
    50  Nz = 0
    Ierr = 2
    RETURN
  ELSE
    !-----------------------------------------------------------------------
    !     POWER SERIES FOR ABS(Z)<=1.
    !-----------------------------------------------------------------------
    s1 = (1._DP,0._DP)
    s2 = (1._DP,0._DP)
    IF( az<tol ) THEN
      aa = 1.E+3_DP*tiny_dp
      s1 = CMPLX(0._DP,0._DP,DP)
      IF( Id==1 ) THEN
        Ai = -CMPLX(c2,0._DP,DP)
        aa = SQRT(aa)
        IF( az>aa ) s1 = Z*Z*CMPLX(0.5_DP,0._DP,DP)
        Ai = Ai + s1*CMPLX(c1,0._DP,DP)
        RETURN
      ELSE
        IF( az>aa ) s1 = CMPLX(c2,0._DP,DP)*Z
        Ai = CMPLX(c1,0._DP,DP) - s1
        RETURN
      END IF
    ELSE
      aa = az*az
      IF( aa>=tol/az ) THEN
        trm1 = (1._DP,0._DP)
        trm2 = (1._DP,0._DP)
        atrm = 1._DP
        z3 = Z*Z*Z
        az3 = az*aa
        ak = 2._DP + fid
        bk = 3._DP - fid - fid
        ck = 4._DP - fid
        dk = 3._DP + fid + fid
        d1 = ak*dk
        d2 = bk*ck
        ad = MIN(d1,d2)
        ak = 24._DP + 9._DP*fid
        bk = 30._DP - 9._DP*fid
        z3r = REAL(z3,DP)
        z3i = AIMAG(z3)
        DO k = 1, 25
          trm1 = trm1*CMPLX(z3r/d1,z3i/d1,DP)
          s1 = s1 + trm1
          trm2 = trm2*CMPLX(z3r/d2,z3i/d2,DP)
          s2 = s2 + trm2
          atrm = atrm*az3/ad
          d1 = d1 + ak
          d2 = d2 + bk
          ad = MIN(d1,d2)
          IF( atrm<tol*ad ) EXIT
          ak = ak + 18._DP
          bk = bk + 18._DP
        END DO
      END IF
      IF( Id==1 ) THEN
        Ai = -s2*CMPLX(c2,0._DP,DP)
        IF( az>tol ) Ai = Ai + Z*Z*s1*CMPLX(c1/(1._DP+fid),0._DP,DP)
        IF( Kode==1 ) RETURN
        zta = Z*SQRT(Z)*CMPLX(tth,0._DP,DP)
        Ai = Ai*EXP(zta)
        RETURN
      ELSE
        Ai = s1*CMPLX(c1,0._DP,DP) - Z*s2*CMPLX(c2,0._DP,DP)
        IF( Kode==1 ) RETURN
        zta = Z*SQRT(Z)*CMPLX(tth,0._DP,DP)
        Ai = Ai*EXP(zta)
        RETURN
      END IF
    END IF
  END IF
  100  Nz = 0
  Ierr = 5
  !
  RETURN
END SUBROUTINE ZAIRY