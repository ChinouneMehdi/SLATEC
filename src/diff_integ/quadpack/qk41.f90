!** QK41
PURE SUBROUTINE QK41(F,A,B,Result,Abserr,Resabs,Resasc)
  !> To compute I = Integral of F over (A,B) with error estimate
  !  J = Integral of ABS(F) over (A,B)
  !***
  ! **Library:**   SLATEC (QUADPACK)
  !***
  ! **Category:**  H2A1A2
  !***
  ! **Type:**      SINGLE PRECISION (QK41-S, DQK41-D)
  !***
  ! **Keywords:**  41-POINT GAUSS-KRONROD RULES, QUADPACK, QUADRATURE
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
  !                       declared E X T E R N A L in the calling program.
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
  !                       RESULT is computed by applying the 41-POINT
  !                       GAUSS-KRONROD RULE (RESK) obtained by optimal
  !                       addition of abscissae to the 20-POINT GAUSS
  !                       RULE (RESG).
  !
  !              ABSERR - Real
  !                       Estimate of the modulus of the absolute error,
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
  REAL(SP) :: absc, centr, dhlgth, epmach, fc, fsum, fval1, fval2, fv1(20), &
    fv2(20), hlgth, resg, resk, reskh, uflow
  !
  !           THE ABSCISSAE AND WEIGHTS ARE GIVEN FOR THE INTERVAL (-1,1).
  !           BECAUSE OF SYMMETRY ONLY THE POSITIVE ABSCISSAE AND THEIR
  !           CORRESPONDING WEIGHTS ARE GIVEN.
  !
  !           XGK    - ABSCISSAE OF THE 41-POINT GAUSS-KRONROD RULE
  !                    XGK(2), XGK(4), ...  ABSCISSAE OF THE 20-POINT
  !                    GAUSS RULE
  !                    XGK(1), XGK(3), ...  ABSCISSAE WHICH ARE OPTIMALLY
  !                    ADDED TO THE 20-POINT GAUSS RULE
  !
  !           WGK    - WEIGHTS OF THE 41-POINT GAUSS-KRONROD RULE
  !
  !           WG     - WEIGHTS OF THE 20-POINT GAUSS RULE
  !
  REAL(SP), PARAMETER :: xgk(21) = [ 0.9988590315882777_SP, 0.9931285991850949_SP, &
    0.9815078774502503_SP, 0.9639719272779138_SP, 0.9408226338317548_SP, &
    0.9122344282513259_SP, 0.8782768112522820_SP, 0.8391169718222188_SP, &
    0.7950414288375512_SP, 0.7463319064601508_SP, 0.6932376563347514_SP, &
    0.6360536807265150_SP, 0.5751404468197103_SP, 0.5108670019508271_SP, &
    0.4435931752387251_SP, 0.3737060887154196_SP, 0.3016278681149130_SP, &
    0.2277858511416451_SP, 0.1526054652409227_SP, 0.7652652113349733E-01_SP, &
    0._SP ]
  REAL(SP), PARAMETER :: wgk(21) = [ 0.3073583718520532E-02_SP, 0.8600269855642942E-02_SP, &
    0.1462616925697125E-01_SP, 0.2038837346126652E-01_SP, 0.2588213360495116E-01_SP, &
    0.3128730677703280E-01_SP, 0.3660016975820080E-01_SP, 0.4166887332797369E-01_SP, &
    0.4643482186749767E-01_SP, 0.5094457392372869E-01_SP, 0.5519510534828599E-01_SP, &
    0.5911140088063957E-01_SP, 0.6265323755478117E-01_SP, 0.6583459713361842E-01_SP, &
    0.6864867292852162E-01_SP, 0.7105442355344407E-01_SP, 0.7303069033278667E-01_SP, &
    0.7458287540049919E-01_SP, 0.7570449768455667E-01_SP, 0.7637786767208074E-01_SP, &
    0.7660071191799966E-01_SP ]
  REAL(SP), PARAMETER :: wg(10) = [ 0.1761400713915212E-01_SP, 0.4060142980038694E-01_SP, &
    0.6267204833410906E-01_SP, 0.8327674157670475E-01_SP, 0.1019301198172404_SP, &
    0.1181945319615184_SP, 0.1316886384491766_SP, 0.1420961093183821_SP, &
    0.1491729864726037_SP, 0.1527533871307259_SP ]
  !
  !
  !           LIST OF MAJOR VARIABLES
  !           -----------------------
  !
  !           CENTR  - MID POINT OF THE INTERVAL
  !           HLGTH  - HALF-LENGTH OF THE INTERVAL
  !           ABSC   - ABSCISSA
  !           FVAL*  - FUNCTION VALUE
  !           RESG   - RESULT OF THE 20-POINT GAUSS FORMULA
  !           RESK   - RESULT OF THE 41-POINT KRONROD FORMULA
  !           RESKH  - APPROXIMATION TO MEAN VALUE OF F OVER (A,B), I.E.
  !                    TO I/(B-A)
  !
  !           MACHINE DEPENDENT CONSTANTS
  !           ---------------------------
  !
  !           EPMACH IS THE LARGEST RELATIVE SPACING.
  !           UFLOW IS THE SMALLEST POSITIVE MAGNITUDE.
  !
  !* FIRST EXECUTABLE STATEMENT  QK41
  epmach = eps_sp
  uflow = tiny_sp
  !
  centr = 0.5_SP*(A+B)
  hlgth = 0.5_SP*(B-A)
  dhlgth = ABS(hlgth)
  !
  !           COMPUTE THE 41-POINT GAUSS-KRONROD APPROXIMATION TO
  !           THE INTEGRAL, AND ESTIMATE THE ABSOLUTE ERROR.
  !
  resg = 0._SP
  fc = F(centr)
  resk = wgk(21)*fc
  Resabs = ABS(resk)
  DO j = 1, 10
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
  DO j = 1, 10
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
  Resasc = wgk(21)*ABS(fc-reskh)
  DO j = 1, 20
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
END SUBROUTINE QK41