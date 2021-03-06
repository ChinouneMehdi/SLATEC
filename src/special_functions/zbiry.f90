!** ZBIRY
ELEMENTAL SUBROUTINE ZBIRY(Z,Id,Kode,Bi,Ierr)
  !> Compute the Airy function Bi(z) or its derivative dBi/dz for complex argument z.
  !  A scaling option is available to help avoid overflow.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  C10D
  !***
  ! **Type:**      COMPLEX (CBIRY-C, ZBIRY-C)
  !***
  ! **Keywords:**  AIRY FUNCTION, BESSEL FUNCTION OF ORDER ONE THIRD,
  !             BESSEL FUNCTION OF ORDER TWO THIRDS
  !***
  ! **Author:**  Amos, D. E., (SNL)
  !***
  ! **Description:**
  !
  !                      ***A DOUBLE PRECISION ROUTINE***
  !         On KODE=1, ZBIRY computes the complex Airy function Bi(z)
  !         or its derivative dBi/dz on ID=0 or ID=1 respectively.
  !         On KODE=2, a scaling option exp(abs(Re(zeta)))*Bi(z) or
  !         exp(abs(Re(zeta)))*dBi/dz is provided to remove the
  !         exponential behavior in both the left and right half planes
  !         where zeta=(2/3)*z**(3/2).
  !
  !         The Airy functions Bi(z) and dBi/dz are analytic in the
  !         whole z-plane, and the scaling option does not destroy this
  !         property.
  !
  !         Input
  !           ZR     - DOUBLE PRECISION real part of argument Z
  !           ZI     - DOUBLE PRECISION imag part of argument Z
  !           ID     - Order of derivative, ID=0 or ID=1
  !           KODE   - A parameter to indicate the scaling option
  !                    KODE=1  returns
  !                            BI=Bi(z)  on ID=0
  !                            BI=dBi/dz on ID=1
  !                            at z=Z
  !                        =2  returns
  !                            BI=exp(abs(Re(zeta)))*Bi(z)  on ID=0
  !                            BI=exp(abs(Re(zeta)))*dBi/dz on ID=1
  !                            at z=Z where zeta=(2/3)*z**(3/2)
  !
  !         Output
  !           BIR    - DOUBLE PRECISION real part of result
  !           BII    - DOUBLE PRECISION imag part of result
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
  !         Bi(z) and dBi/dz are computed from I Bessel functions by
  !
  !                Bi(z) =  c*sqrt(z)*( I(-1/3,zeta) + I(1/3,zeta) )
  !               dBi/dz =  c*   z   *( I(-2/3,zeta) + I(2/3,zeta) )
  !                    c =  1/sqrt(3)
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
  ! **Routines called:**  D1MACH, I1MACH, ZABS, ZBINU, ZDIV, ZSQRT

  !* REVISION HISTORY  (YYMMDD)
  !   830501  DATE WRITTEN
  !   890801  REVISION DATE from Version 3.2
  !   910415  Prologue converted to Version 4.0 format.  (BAB)
  !   920128  Category corrected.  (WRB)
  !   920811  Prologue revised.  (DWL)
  !   930122  Added ZSQRT to EXTERNAL statement.  (RWC)
  USE service, ONLY : eps_dp, log10_radix_dp, digits_dp, huge_int, max_exp_dp, min_exp_dp
  !
  INTEGER, INTENT(IN) :: Id, Kode
  INTEGER, INTENT(OUT) :: Ierr
  COMPLEX(DP), INTENT(IN) :: Z
  COMPLEX(DP), INTENT(OUT) :: Bi
  !
  INTEGER :: k, k1, k2, nz
  REAL(DP) :: aa, ad, ak, alim, atrm, az, az3, bb, bk, ck, dig, dk, d1, d2, elim, fid, &
    fmr, fnu, fnul, rl, r1m5, sfac, tol, zi, zr, z3i, z3r
  COMPLEX(DP) :: csq, cy(2), s1, s2, trm1, trm2, zta, z3
  REAL(DP), PARAMETER :: tth = 6.66666666666666667E-01_DP, c1 = 6.14926627446000736E-01_DP, &
    c2 = 4.48288357353826359E-01_DP, coef = 5.77350269189625765E-01_DP, &
    pi = 3.14159265358979324_DP
  !* FIRST EXECUTABLE STATEMENT  ZBIRY
  Ierr = 0
  nz = 0
  IF( Id<0 .OR. Id>1 .OR. Kode<1 .OR. Kode>2 ) THEN
    Ierr = 1
    RETURN
  END IF
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
    !     FNUL IS THE LOWER BOUNDARY OF THE ASYMPTOTIC SERIES FOR LARGE FNU.
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
    fnul = 10._DP + 6._DP*(dig-3._DP)
    !-----------------------------------------------------------------------
    !     TEST FOR RANGE
    !-----------------------------------------------------------------------
    aa = 0.5_DP/tol
    bb = 0.5_DP*huge_int
    aa = MIN(aa,bb)
    aa = aa**tth
    IF( az>aa ) THEN
      Ierr = 4
      nz = 0
      RETURN
    ELSE
      aa = SQRT(aa)
      IF( az>aa ) Ierr = 3
      csq = SQRT(Z)
      zta = Z*csq*CMPLX(tth,0._DP,DP)
      !-----------------------------------------------------------------------
      !     RE(ZTA)<=0 WHEN RE(Z)<0, ESPECIALLY WHEN IM(Z) IS SMALL
      !-----------------------------------------------------------------------
      sfac = 1._DP
      zi = AIMAG(Z)
      zr = REAL(Z,DP)
      ak = AIMAG(zta)
      IF( zr<0._DP ) THEN
        bk = REAL(zta,DP)
        ck = -ABS(bk)
        zta = CMPLX(ck,ak,DP)
      END IF
      IF( zi==0._DP .AND. zr<=0._DP ) zta = CMPLX(0._DP,ak,DP)
      aa = REAL(zta,DP)
      IF( Kode/=2 ) THEN
        !-----------------------------------------------------------------------
        !     OVERFLOW TEST
        !-----------------------------------------------------------------------
        bb = ABS(aa)
        IF( bb>=alim ) THEN
          bb = bb + 0.25_DP*LOG(az)
          sfac = tol
          IF( bb>elim ) GOTO 50
        END IF
      END IF
      fmr = 0._DP
      IF( aa<0._DP .OR. zr<=0._DP ) THEN
        fmr = pi
        IF( zi<0._DP ) fmr = -pi
        zta = -zta
      END IF
      !-----------------------------------------------------------------------
      !     AA=FACTOR FOR ANALYTIC CONTINUATION OF I(FNU,ZTA)
      !     KODE=2 RETURNS EXP(-ABS(XZTA))*I(FNU,ZTA) FROM ZBINU
      !-----------------------------------------------------------------------
      CALL ZBINU(zta,fnu,Kode,1,cy,nz,rl,fnul,tol,elim,alim)
      IF( nz>=0 ) THEN
        aa = fmr*fnu
        z3 = CMPLX(sfac,0._DP,DP)
        s1 = cy(1)*CMPLX(COS(aa),SIN(aa),DP)*z3
        fnu = (2._DP-fid)/3._DP
        CALL ZBINU(zta,fnu,Kode,2,cy,nz,rl,fnul,tol,elim,alim)
        cy(1) = cy(1)*z3
        cy(2) = cy(2)*z3
        !-----------------------------------------------------------------------
        !     BACKWARD RECUR ONE STEP FOR ORDERS -1/3 OR -2/3
        !-----------------------------------------------------------------------
        s2 = cy(1)*CMPLX(fnu+fnu,0._DP,DP)/zta + cy(2)
        aa = fmr*(fnu-1._DP)
        s1 = (s1+s2*CMPLX(COS(aa),SIN(aa),DP))*CMPLX(coef,0._DP,DP)
        IF( Id==1 ) THEN
          s1 = Z*s1
          Bi = s1*CMPLX(1._DP/sfac,0._DP,DP)
          RETURN
        ELSE
          s1 = csq*s1
          Bi = s1*CMPLX(1._DP/sfac,0._DP,DP)
          RETURN
        END IF
      ELSEIF( nz/=(-1) ) THEN
        GOTO 100
      END IF
    END IF
    50  nz = 0
    Ierr = 2
    RETURN
  ELSE
    !-----------------------------------------------------------------------
    !     POWER SERIES FOR ABS(Z)<=1.
    !-----------------------------------------------------------------------
    s1 = (1._DP,0._DP)
    s2 = (1._DP,0._DP)
    IF( az<tol ) THEN
      aa = c1*(1._DP-fid) + fid*c2
      Bi = CMPLX(aa,0._DP,DP)
      RETURN
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
        Bi = s2*CMPLX(c2,0._DP,DP)
        IF( az>tol ) Bi = Bi + Z*Z*s1*CMPLX(c1/(1._DP+fid),0._DP,DP)
        IF( Kode==1 ) RETURN
        zta = Z*SQRT(Z)*CMPLX(tth,0._DP,DP)
        aa = REAL(zta,DP)
        aa = -ABS(aa)
        Bi = Bi*CMPLX(EXP(aa),0._DP,DP)
        RETURN
      ELSE
        Bi = s1*CMPLX(c1,0._DP,DP) + Z*s2*CMPLX(c2,0._DP,DP)
        IF( Kode==1 ) RETURN
        zta = Z*SQRT(Z)*CMPLX(tth,0._DP,DP)
        aa = REAL(zta,DP)
        aa = -ABS(aa)
        Bi = Bi*CMPLX(EXP(aa),0._DP,DP)
        RETURN
      END IF
    END IF
  END IF
  100  nz = 0
  Ierr = 5
  !
  RETURN
END SUBROUTINE ZBIRY