!** QK31
PURE SUBROUTINE QK31(F,A,B,Result,Abserr,Resabs,Resasc)
  !> To compute I = Integral of F over (A,B) with error estimate
  !  J = Integral of ABS(F) over (A,B)
  !***
  ! **Library:**   SLATEC (QUADPACK)
  !***
  ! **Category:**  H2A1A2
  !***
  ! **Type:**      SINGLE PRECISION (QK31-S, DQK31-D)
  !***
  ! **Keywords:**  31-POINT GAUSS-KRONROD RULES, QUADPACK, QUADRATURE
  !***
  ! **Author:**  Piessens, Robert
  !             Applied Mathematics and Programming Division
  !             K. U. Leuven
  !           de Doncker, Elise
  !             Applied Mathematics and Programming Division
  !             K. U. Leuven
  !***
  ! **Description:**
  !
  !           Integration rules
  !           Standard fortran subroutine
  !           Real version
  !
  !           PARAMETERS
  !            ON ENTRY
  !              F      - Real
  !                       Function subprogram defining the integrand
  !                       FUNCTION F(X). The actual name for F needs to be
  !                       Declared E X T E R N A L in the calling program.
  !
  !              A      - Real
  !                       Lower limit of integration
  !
  !              B      - Real
  !                       Upper limit of integration
  !
  !            ON RETURN
  !              RESULT - Real
  !                       Approximation to the integral I
  !                       RESULT is computed by applying the 31-POINT
  !                       GAUSS-KRONROD RULE (RESK), obtained by optimal
  !                       addition of abscissae to the 15-POINT GAUSS
  !                       RULE (RESG).
  !
  !              ABSERR - Real
  !                       Estimate of the modulus of the modulus,
  !                       which should not exceed ABS(I-RESULT)
  !
  !              RESABS - Real
  !                       Approximation to the integral J
  !
  !              RESASC - Real
  !                       Approximation to the integral of ABS(F-I/(B-A))
  !                       over (A,B)
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  R1MACH

  !* REVISION HISTORY  (YYMMDD)
  !   800101  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  USE service, ONLY : tiny_sp, eps_sp
  !
  INTERFACE
    REAL(SP) PURE FUNCTION F(X)
      IMPORT SP
      REAL(SP), INTENT(IN) :: X
    END FUNCTION F
  END INTERFACE
  REAL(SP), INTENT(IN) :: A, B
  REAL(SP), INTENT(OUT) :: Abserr, Resabs, Resasc, Result
  !
  INTEGER :: j, jtw, jtwm1
  REAL(SP) :: absc, centr, dhlgth, epmach, fc, fsum, fval1, fval2, fv1(15), &
    fv2(15), hlgth, resg, resk, reskh, uflow
  !
  !           THE ABSCISSAE AND WEIGHTS ARE GIVEN FOR THE INTERVAL (-1,1).
  !           BECAUSE OF SYMMETRY ONLY THE POSITIVE ABSCISSAE AND THEIR
  !           CORRESPONDING WEIGHTS ARE GIVEN.
  !
  !           XGK    - ABSCISSAE OF THE 31-POINT KRONROD RULE
  !                    XGK(2), XGK(4), ...  ABSCISSAE OF THE 15-POINT
  !                    GAUSS RULE
  !                    XGK(1), XGK(3), ...  ABSCISSAE WHICH ARE OPTIMALLY
  !                    ADDED TO THE 15-POINT GAUSS RULE
  !
  !           WGK    - WEIGHTS OF THE 31-POINT KRONROD RULE
  !
  !           WG     - WEIGHTS OF THE 15-POINT GAUSS RULE
  !
  REAL(SP), PARAMETER :: xgk(16) = [ 0.9980022986933971_SP, 0.9879925180204854_SP, &
    0.9677390756791391_SP, 0.9372733924007059_SP, 0.8972645323440819_SP, &
    0.8482065834104272_SP, 0.7904185014424659_SP, 0.7244177313601700_SP, &
    0.6509967412974170_SP, 0.5709721726085388_SP, 0.4850818636402397_SP, &
    0.3941513470775634_SP, 0.2991800071531688_SP, 0.2011940939974345_SP, &
    0.1011420669187175_SP, 0._SP ]
  REAL(SP), PARAMETER :: wgk(16) = [ 0.5377479872923349E-02_SP, 0.1500794732931612E-01_SP, &
    0.2546084732671532E-01_SP, 0.3534636079137585E-01_SP, 0.4458975132476488E-01_SP, &
    0.5348152469092809E-01_SP, 0.6200956780067064E-01_SP, 0.6985412131872826E-01_SP, &
    0.7684968075772038E-01_SP, 0.8308050282313302E-01_SP, 0.8856444305621177E-01_SP, &
    0.9312659817082532E-01_SP, 0.9664272698362368E-01_SP, 0.9917359872179196E-01_SP, &
    0.1007698455238756_SP, 0.1013300070147915_SP ]
  REAL(SP), PARAMETER :: wg(8) = [ 0.3075324199611727E-01_SP, 0.7036604748810812E-01_SP, &
    0.1071592204671719_SP, 0.1395706779261543_SP, 0.1662692058169939_SP, &
    0.1861610000155622_SP, 0.1984314853271116_SP, 0.2025782419255613_SP ]
  !
  !
  !           LIST OF MAJOR VARIABLES
  !           -----------------------
  !           CENTR  - MID POINT OF THE INTERVAL
  !           HLGTH  - HALF-LENGTH OF THE INTERVAL
  !           ABSC   - ABSCISSA
  !           FVAL*  - FUNCTION VALUE
  !           RESG   - RESULT OF THE 15-POINT GAUSS FORMULA
  !           RESK   - RESULT OF THE 31-POINT KRONROD FORMULA
  !           RESKH  - APPROXIMATION TO THE MEAN VALUE OF F OVER (A,B),
  !                    I.E. TO I/(B-A)
  !
  !           MACHINE DEPENDENT CONSTANTS
  !           ---------------------------
  !           EPMACH IS THE LARGEST RELATIVE SPACING.
  !           UFLOW IS THE SMALLEST POSITIVE MAGNITUDE.
  !
  !* FIRST EXECUTABLE STATEMENT  QK31
  epmach = eps_sp
  uflow = tiny_sp
  !
  centr = 0.5_SP*(A+B)
  hlgth = 0.5_SP*(B-A)
  dhlgth = ABS(hlgth)
  !
  !           COMPUTE THE 31-POINT KRONROD APPROXIMATION TO
  !           THE INTEGRAL, AND ESTIMATE THE ABSOLUTE ERROR.
  !
  fc = F(centr)
  resg = wg(8)*fc
  resk = wgk(16)*fc
  Resabs = ABS(resk)
  DO j = 1, 7
    jtw = j*2
    absc = hlgth*xgk(jtw)
    fval1 = F(centr-absc)
    fval2 = F(centr+absc)
    fv1(jtw) = fval1
    fv2(jtw) = fval2
    fsum = fval1 + fval2
    resg = resg + wg(j)*fsum
    resk = resk + wgk(jtw)*fsum
    Resabs = Resabs + wgk(jtw)*(ABS(fval1)+ABS(fval2))
  END DO
  DO j = 1, 8
    jtwm1 = j*2 - 1
    absc = hlgth*xgk(jtwm1)
    fval1 = F(centr-absc)
    fval2 = F(centr+absc)
    fv1(jtwm1) = fval1
    fv2(jtwm1) = fval2
    fsum = fval1 + fval2
    resk = resk + wgk(jtwm1)*fsum
    Resabs = Resabs + wgk(jtwm1)*(ABS(fval1)+ABS(fval2))
  END DO
  reskh = resk*0.5_SP
  Resasc = wgk(16)*ABS(fc-reskh)
  DO j = 1, 15
    Resasc = Resasc + wgk(j)*(ABS(fv1(j)-reskh)+ABS(fv2(j)-reskh))
  END DO
  Result = resk*hlgth
  Resabs = Resabs*dhlgth
  Resasc = Resasc*dhlgth
  Abserr = ABS((resk-resg)*hlgth)
  IF( Resasc/=0._SP .AND. Abserr/=0._SP )&
    Abserr = Resasc*MIN(1._SP,(200._SP*Abserr/Resasc)**1.5_SP)
  IF( Resabs>uflow/(50._SP*epmach) ) Abserr = MAX((epmach*50._SP)*Resabs,Abserr)
  !
END SUBROUTINE QK31