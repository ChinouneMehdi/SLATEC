!** ZBESK
PURE SUBROUTINE ZBESK(Z,Fnu,Kode,N,Cy,Nz,Ierr)
  !> Compute a sequence of the Bessel functions K(a,z) for complex argument z
  !  and real nonnegative orders a=b,b+1, b+2,... where b>0.
  !  A scaling option is available to help avoid overflow.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  C10B4
  !***
  ! **Type:**      COMPLEX (CBESK-C, ZBESK-C)
  !***
  ! **Keywords:**  BESSEL FUNCTIONS OF COMPLEX ARGUMENT, K BESSEL FUNCTIONS,
  !             MODIFIED BESSEL FUNCTIONS
  !***
  ! **Author:**  Amos, D. E., (SNL)
  !***
  ! **Description:**
  !
  !                      ***A DOUBLE PRECISION ROUTINE***
  !         On KODE=1, ZBESK computes an N member sequence of complex
  !         Bessel functions CY(L)=K(FNU+L-1,Z) for real nonnegative
  !         orders FNU+L-1, L=1,...,N and complex Z/=0 in the cut
  !         plane -pi<arg(Z)<=pi where Z=ZR+i*ZI.  On KODE=2, CBESJ
  !         returns the scaled functions
  !
  !            CY(L) = exp(Z)*K(FNU+L-1,Z),  L=1,...,N
  !
  !         which remove the exponential growth in both the left and
  !         right half planes as Z goes to infinity.  Definitions and
  !         notation are found in the NBS Handbook of Mathematical
  !         Functions (Ref. 1).
  !
  !         Input
  !           ZR     - DOUBLE PRECISION real part of nonzero argument Z
  !           ZI     - DOUBLE PRECISION imag part of nonzero argument Z
  !           FNU    - DOUBLE PRECISION initial order, FNU>=0
  !           KODE   - A parameter to indicate the scaling option
  !                    KODE=1  returns
  !                            CY(L)=K(FNU+L-1,Z), L=1,...,N
  !                        =2  returns
  !                            CY(L)=K(FNU+L-1,Z)*EXP(Z), L=1,...,N
  !           N      - Number of terms in the sequence, N>=1
  !
  !         Output
  !           CYR    - DOUBLE PRECISION real part of result vector
  !           CYI    - DOUBLE PRECISION imag part of result vector
  !           NZ     - Number of underflows set to zero
  !                    NZ=0    Normal return
  !                    NZ>0    CY(L)=0 for NZ values of L (if Re(Z)>0
  !                            then CY(L)=0 for L=1,...,NZ; in the
  !                            complementary half plane the underflows
  !                            may not be in an uninterrupted sequence)
  !           IERR   - Error flag
  !                    IERR=0  Normal return     - COMPUTATION COMPLETED
  !                    IERR=1  Input error       - NO COMPUTATION
  !                    IERR=2  Overflow          - NO COMPUTATION
  !                            (abs(Z) too small and/or FNU+N-1
  !                            too large)
  !                    IERR=3  Precision warning - COMPUTATION COMPLETED
  !                            (Result has half precision or less
  !                            because abs(Z) or FNU+N-1 is large)
  !                    IERR=4  Precision error   - NO COMPUTATION
  !                            (Result has no precision because
  !                            abs(Z) or FNU+N-1 is too large)
  !                    IERR=5  Algorithmic error - NO COMPUTATION
  !                            (Termination condition not met)
  !
  !- Long Description:
  !
  !         Equations of the reference are implemented to compute K(a,z)
  !         for small orders a and a+1 in the right half plane Re(z)>=0.
  !         Forward recurrence generates higher orders.  The formula
  !
  !            K(a,z*exp((t)) = exp(-t)*K(a,z) - t*I(a,z),  Re(z)>0
  !                         t = i*pi or -i*pi
  !
  !         continues K to the left half plane.
  !
  !         For large orders, K(a,z) is computed by means of its uniform
  !         asymptotic expansion.
  !
  !         For negative orders, the formula
  !
  !            K(-a,z) = K(a,z)
  !
  !         can be used.
  !
  !         CBESK assumes that a significant digit sinh function is
  !         available.
  !
  !         In most complex variable computation, one must evaluate ele-
  !         mentary functions.  When the magnitude of Z or FNU+N-1 is
  !         large, losses of significance by argument reduction occur.
  !         Consequently, if either one exceeds U1=SQRT(0.5/UR), then
  !         losses exceeding half precision are likely and an error flag
  !         IERR=3 is triggered where UR=MAX(eps_dp,1.0D-18) is double
  !         precision unit roundoff limited to 18 digits precision.  Also,
  !         if either is larger than U2=0.5/UR, then all significance is
  !         lost and IERR=4.  In order to use the INT function, arguments
  !         must be further restricted not to exceed the largest machine
  !         integer, U3=huge_int.  Thus, the magnitude of Z and FNU+N-1
  !         is restricted by MIN(U2,U3).  In IEEE arithmetic, U1,U2, and
  !         U3 approximate 2.0E+3, 4.2E+6, 2.1E+9 in single precision
  !         and 4.7E+7, 2.3E+15 and 2.1E+9 in double precision.  This
  !         makes U2 limiting in single precision and U3 limiting in
  !         double precision.  This means that one can expect to retain,
  !         in the worst cases on IEEE machines, no digits in single pre-
  !         cision and only 6 digits in double precision.  Similar con-
  !         siderations hold for other machines.
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
  !         magnitude of the larger component.  In these extreme cases,
  !         the principal phase angle is on the order of +P, -P, PI/2-P,
  !         or -PI/2+P.
  !
  !***
  ! **References:**  1. M. Abramowitz and I. A. Stegun, Handbook of Mathe-
  !                 matical Functions, National Bureau of Standards
  !                 Applied Mathematics Series 55, U. S. Department
  !                 of Commerce, Tenth Printing (1972) or later.
  !               2. D. E. Amos, Computation of Bessel Functions of
  !                 Complex Argument, Report SAND83-0086, Sandia National
  !                 Laboratories, Albuquerque, NM, May 1983.
  !               3. D. E. Amos, Computation of Bessel Functions of
  !                 Complex Argument and Large Order, Report SAND83-0643,
  !                 Sandia National Laboratories, Albuquerque, NM, May
  !                 1983.
  !               4. D. E. Amos, A Subroutine Package for Bessel Functions
  !                 of a Complex Argument and Nonnegative Order, Report
  !                 SAND85-1018, Sandia National Laboratory, Albuquerque,
  !                 NM, May 1985.
  !               5. D. E. Amos, A portable package for Bessel functions
  !                 of a complex argument and nonnegative order, ACM
  !                 Transactions on Mathematical Software, 12 (September
  !                 1986), pp. 265-273.
  !
  !***
  ! **Routines called:**  D1MACH, I1MACH, ZABS, ZACON, ZBKNU, ZBUNK, ZUOIK

  !* REVISION HISTORY  (YYMMDD)
  !   830501  DATE WRITTEN
  !   890801  REVISION DATE from Version 3.2
  !   910415  Prologue converted to Version 4.0 format.  (BAB)
  !   920128  Category corrected.  (WRB)
  !   920811  Prologue revised.  (DWL)
  USE service, ONLY : eps_dp, log10_radix_dp, tiny_dp, digits_dp, huge_int, &
    max_exp_dp, min_exp_dp
  !
  INTEGER, INTENT(IN) :: Kode, N
  INTEGER, INTENT(OUT) :: Ierr, Nz
  REAL(DP), INTENT(IN) :: Fnu
  COMPLEX(DP), INTENT(IN) :: Z
  COMPLEX(DP), INTENT(OUT) :: Cy(N)
  !
  INTEGER :: k, k1, k2, mr, nn, nuf, nw
  REAL(DP) :: aa, alim, aln, arg, az, dig, elim, fn, fnul, rl, &
    r1m5, tol, ufl, xx, yy, bb
  !* FIRST EXECUTABLE STATEMENT  ZBESK
  Ierr = 0
  Nz = 0
  xx = REAL(Z,DP)
  yy = AIMAG(Z)
  IF( Z==(0._DP,0._DP) .OR. Fnu<0._DP .OR. Kode<1 .OR. Kode>2 .OR. N<1 ) THEN
    Ierr = 1
    RETURN
  END IF
  nn = N
  !-----------------------------------------------------------------------
  !     SET PARAMETERS RELATED TO MACHINE CONSTANTS.
  !     TOL IS THE APPROXIMATE UNIT ROUNDOFF LIMITED TO 1.0E-18.
  !     ELIM IS THE APPROXIMATE EXPONENTIAL OVER- AND UNDERFLOW LIMIT.
  !     EXP(-ELIM)<EXP(-ALIM)=EXP(-ELIM)/TOL    AND
  !     EXP(ELIM)>EXP(ALIM)=EXP(ELIM)*TOL       ARE INTERVALS NEAR
  !     UNDERFLOW AND OVERFLOW LIMITS WHERE SCALED ARITHMETIC IS DONE.
  !     RL IS THE LOWER BOUNDARY OF THE ASYMPTOTIC EXPANSION FOR LARGE Z.
  !     DIG = NUMBER OF BASE 10 DIGITS IN TOL = 10**(-DIG).
  !     FNUL IS THE LOWER BOUNDARY OF THE ASYMPTOTIC SERIES FOR LARGE FNU
  !-----------------------------------------------------------------------
  tol = MAX(eps_dp,1.E-18_DP)
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
  fnul = 10._DP + 6._DP*(dig-3._DP)
  rl = 1.2_DP*dig + 3._DP
  az = ABS(Z)
  fn = Fnu + (nn-1)
  !-----------------------------------------------------------------------
  !     TEST FOR RANGE
  !-----------------------------------------------------------------------
  aa = 0.5_DP/tol
  bb = huge_int*0.5_DP
  aa = MIN(aa,bb)
  IF( az>aa ) GOTO 300
  IF( fn>aa ) GOTO 300
  aa = SQRT(aa)
  IF( az>aa ) Ierr = 3
  IF( fn>aa ) Ierr = 3
  !-----------------------------------------------------------------------
  !     OVERFLOW TEST ON THE LAST MEMBER OF THE SEQUENCE
  !-----------------------------------------------------------------------
  !     UFL = EXP(-ELIM)
  ufl = tiny_dp*1.E3_DP
  IF( az>=ufl ) THEN
    IF( Fnu>fnul ) THEN
      !-----------------------------------------------------------------------
      !     UNIFORM ASYMPTOTIC EXPANSIONS FOR FNU>FNUL
      !-----------------------------------------------------------------------
      mr = 0
      IF( xx<0._DP ) THEN
        mr = 1
        IF( yy<0._DP ) mr = -1
      END IF
      CALL ZBUNK(Z,Fnu,Kode,mr,nn,Cy,nw,tol,elim,alim)
      IF( nw<0 ) GOTO 200
      Nz = Nz + nw
      RETURN
    ELSE
      IF( fn>1._DP ) THEN
        IF( fn>2._DP ) THEN
          CALL ZUOIK(Z,Fnu,Kode,2,nn,Cy,nuf,tol,elim,alim)
          IF( nuf<0 ) GOTO 100
          Nz = Nz + nuf
          nn = nn - nuf
          !-----------------------------------------------------------------------
          !     HERE NN=N OR NN=0 SINCE NUF=0,NN, OR -1 ON RETURN FROM CUOIK
          !     IF NUF=NN, THEN CY(I)=CZERO FOR ALL I
          !-----------------------------------------------------------------------
          IF( nn==0 ) THEN
            IF( xx<0._DP ) GOTO 100
            RETURN
          END IF
        ELSEIF( az<=tol ) THEN
          arg = 0.5_DP*az
          aln = -fn*LOG(arg)
          IF( aln>elim ) GOTO 100
        END IF
      END IF
      IF( xx>=0._DP ) THEN
        !-----------------------------------------------------------------------
        !     RIGHT HALF PLANE COMPUTATION, REAL(Z)>=0.
        !-----------------------------------------------------------------------
        CALL ZBKNU(Z,Fnu,Kode,nn,Cy,nw,tol,elim,alim)
        IF( nw<0 ) GOTO 200
        Nz = nw
        RETURN
        !-----------------------------------------------------------------------
        !     LEFT HALF PLANE COMPUTATION
        !     PI/2<ARG(Z)<=PI AND -PI<ARG(Z)<-PI/2.
        !-----------------------------------------------------------------------
      ELSEIF( Nz==0 ) THEN
        mr = 1
        IF( yy<0._DP ) mr = -1
        CALL ZACON(Z,Fnu,Kode,mr,nn,Cy,nw,rl,fnul,tol,elim,alim)
        IF( nw<0 ) GOTO 200
        Nz = nw
        RETURN
      END IF
    END IF
  END IF
  100  Nz = 0
  Ierr = 2
  RETURN
  200 CONTINUE
  IF( nw==(-1) ) GOTO 100
  Nz = 0
  Ierr = 5
  RETURN
  300  Nz = 0
  Ierr = 4
  !
END SUBROUTINE ZBESK