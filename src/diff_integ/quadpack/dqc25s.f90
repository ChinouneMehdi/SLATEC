!** DQC25S
PURE SUBROUTINE DQC25S(F,A,B,Bl,Br,Alfa,Beta,Ri,Rj,Rg,Rh,Result,Abserr,Resasc,&
    Integr,Nev)
  !> To compute I = Integral of F*W over (BL,BR), with error estimate,
  !  where the weight function W has a singular behaviour of ALGEBRAICO-LOGARITHMIC
  !  type at the points A and/or B. (BL,BR) is a part of (A,B).
  !***
  ! **Library:**   SLATEC (QUADPACK)
  !***
  ! **Category:**  H2A2A2
  !***
  ! **Type:**      DOUBLE PRECISION (QC25S-S, DQC25S-D)
  !***
  ! **Keywords:**  25-POINT CLENSHAW-CURTIS INTEGRATION, QUADPACK, QUADRATURE
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
  !        Integration rules for integrands having ALGEBRAICO-LOGARITHMIC
  !        end point singularities
  !        Standard fortran subroutine
  !        Double precision version
  !
  !        PARAMETERS
  !           F      - Double precision
  !                    Function subprogram defining the integrand
  !                    F(X). The actual name for F needs to be declared
  !                    E X T E R N A L  in the driver program.
  !
  !           A      - Double precision
  !                    Left end point of the original interval
  !
  !           B      - Double precision
  !                    Right end point of the original interval, B>A
  !
  !           BL     - Double precision
  !                    Lower limit of integration, BL>=A
  !
  !           BR     - Double precision
  !                    Upper limit of integration, BR<=B
  !
  !           ALFA   - Double precision
  !                    PARAMETER IN THE WEIGHT FUNCTION
  !
  !           BETA   - Double precision
  !                    Parameter in the weight function
  !
  !           RI,RJ,RG,RH - Double precision
  !                    Modified CHEBYSHEV moments for the application
  !                    of the generalized CLENSHAW-CURTIS
  !                    method (computed in subroutine DQMOMO)
  !
  !           RESULT - Double precision
  !                    Approximation to the integral
  !                    RESULT is computed by using a generalized
  !                    CLENSHAW-CURTIS method if B1 = A or BR = B.
  !                    in all other cases the 15-POINT KRONROD
  !                    RULE is applied, obtained by optimal addition of
  !                    Abscissae to the 7-POINT GAUSS RULE.
  !
  !           ABSERR - Double precision
  !                    Estimate of the modulus of the absolute error,
  !                    which should equal or exceed ABS(I-RESULT)
  !
  !           RESASC - Double precision
  !                    Approximation to the integral of ABS(F*W-I/(B-A))
  !
  !           INTEGR - Integer
  !                    Which determines the weight function
  !                    = 1   W(X) = (X-A)**ALFA*(B-X)**BETA
  !                    = 2   W(X) = (X-A)**ALFA*(B-X)**BETA*LOG(X-A)
  !                    = 3   W(X) = (X-A)**ALFA*(B-X)**BETA*LOG(B-X)
  !                    = 4   W(X) = (X-A)**ALFA*(B-X)**BETA*LOG(X-A)*
  !                                 LOG(B-X)
  !
  !           NEV    - Integer
  !                    Number of integrand evaluations
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  DQCHEB, DQK15W, DQWGTS

  !* REVISION HISTORY  (YYMMDD)
  !   810101  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)

  !
  INTERFACE
    REAL(DP) PURE FUNCTION F(X)
      IMPORT DP
      REAL(DP), INTENT(IN) :: X
    END FUNCTION F
  END INTERFACE
  INTEGER, INTENT(IN) :: Integr
  INTEGER, INTENT(OUT) :: Nev
  REAL(DP), INTENT(IN) :: A, Alfa, B, Beta, Bl, Br
  REAL(DP), INTENT(OUT) :: Abserr, Resasc, Result
  REAL(DP), INTENT(IN) :: Rg(25), Rh(25), Ri(25), Rj(25)
  !
  INTEGER :: i, isym
  REAL(DP) :: centr, cheb12(13), cheb24(25), dc, factor, fix, fval(25), hlgth, &
    resabs, res12, res24, u
  !
  !           THE VECTOR X CONTAINS THE VALUES COS(K*PI/24)
  !           K = 1, ..., 11, TO BE USED FOR THE COMPUTATION OF THE
  !           CHEBYSHEV SERIES EXPANSION OF F.
  !
  REAL(DP), PARAMETER :: x(11) = [ 0.9914448613738104E+00_DP, 0.9659258262890683E+00_DP, &
    0.9238795325112868E+00_DP, 0.8660254037844386E+00_DP, 0.7933533402912352E+00_DP, &
    0.7071067811865475E+00_DP, 0.6087614290087206E+00_DP, 0.5000000000000000E+00_DP, &
    0.3826834323650898E+00_DP, 0.2588190451025208E+00_DP, 0.1305261922200516E+00_DP ]
  !
  !           LIST OF MAJOR VARIABLES
  !           -----------------------
  !
  !           FVAL   - VALUE OF THE FUNCTION F AT THE POINTS
  !                    (BR-BL)*0.5*COS(K*PI/24)+(BR+BL)*0.5
  !                    K = 0, ..., 24
  !           CHEB12 - COEFFICIENTS OF THE CHEBYSHEV SERIES EXPANSION
  !                    OF DEGREE 12, FOR THE FUNCTION F, IN THE
  !                    INTERVAL (BL,BR)
  !           CHEB24 - COEFFICIENTS OF THE CHEBYSHEV SERIES EXPANSION
  !                    OF DEGREE 24, FOR THE FUNCTION F, IN THE
  !                    INTERVAL (BL,BR)
  !           RES12  - APPROXIMATION TO THE INTEGRAL OBTAINED FROM CHEB12
  !           RES24  - APPROXIMATION TO THE INTEGRAL OBTAINED FROM CHEB24
  !           DQWGTS - EXTERNAL FUNCTION SUBPROGRAM DEFINING
  !                    THE FOUR POSSIBLE WEIGHT FUNCTIONS
  !           HLGTH  - HALF-LENGTH OF THE INTERVAL (BL,BR)
  !           CENTR  - MID POINT OF THE INTERVAL (BL,BR)
  !
  !* FIRST EXECUTABLE STATEMENT  DQC25S
  Nev = 25
  IF( Bl==A .AND. (Alfa/=0._DP .OR. Integr==2 .OR. Integr==4) ) THEN
    !
    !           THIS PART OF THE PROGRAM IS EXECUTED ONLY IF A = BL.
    !           ----------------------------------------------------
    !
    !           COMPUTE THE CHEBYSHEV SERIES EXPANSION OF THE
    !           FOLLOWING FUNCTION
    !           F1 = (0.5*(B+B-BR-A)-0.5*(BR-A)*X)**BETA
    !                  *F(0.5*(BR-A)*X+0.5*(BR+A))
    !
    hlgth = 0.5_DP*(Br-Bl)
    centr = 0.5_DP*(Br+Bl)
    fix = B - centr
    fval(1) = 0.5_DP*F(hlgth+centr)*(fix-hlgth)**Beta
    fval(13) = F(centr)*(fix**Beta)
    fval(25) = 0.5_DP*F(centr-hlgth)*(fix+hlgth)**Beta
    DO i = 2, 12
      u = hlgth*x(i-1)
      isym = 26 - i
      fval(i) = F(u+centr)*(fix-u)**Beta
      fval(isym) = F(centr-u)*(fix+u)**Beta
    END DO
    factor = hlgth**(Alfa+1._DP)
    Result = 0._DP
    Abserr = 0._DP
    res12 = 0._DP
    res24 = 0._DP
    IF( Integr>2 ) THEN
      !
      !           COMPUTE THE CHEBYSHEV SERIES EXPANSION OF THE
      !           FOLLOWING FUNCTION
      !           F4 = F1*LOG(0.5*(B+B-BR-A)-0.5*(BR-A)*X)
      !
      fval(1) = fval(1)*LOG(fix-hlgth)
      fval(13) = fval(13)*LOG(fix)
      fval(25) = fval(25)*LOG(fix+hlgth)
      DO i = 2, 12
        u = hlgth*x(i-1)
        isym = 26 - i
        fval(i) = fval(i)*LOG(fix-u)
        fval(isym) = fval(isym)*LOG(fix+u)
      END DO
      CALL DQCHEB(x,fval,cheb12,cheb24)
      !
      !           INTEGR = 3  (OR 4)
      !
      DO i = 1, 13
        res12 = res12 + cheb12(i)*Ri(i)
        res24 = res24 + cheb24(i)*Ri(i)
      END DO
      DO i = 14, 25
        res24 = res24 + cheb24(i)*Ri(i)
      END DO
      IF( Integr/=3 ) THEN
        !
        !           INTEGR = 4
        !
        dc = LOG(Br-Bl)
        Result = res24*dc
        Abserr = ABS((res24-res12)*dc)
        res12 = 0._DP
        res24 = 0._DP
        DO i = 1, 13
          res12 = res12 + cheb12(i)*Rg(i)
          res24 = res24 + cheb24(i)*Rg(i)
        END DO
        DO i = 14, 25
          res24 = res24 + cheb24(i)*Rg(i)
        END DO
      END IF
    ELSE
      CALL DQCHEB(x,fval,cheb12,cheb24)
      !
      !           INTEGR = 1  (OR 2)
      !
      DO i = 1, 13
        res12 = res12 + cheb12(i)*Ri(i)
        res24 = res24 + cheb24(i)*Ri(i)
      END DO
      DO i = 14, 25
        res24 = res24 + cheb24(i)*Ri(i)
      END DO
      IF( Integr/=1 ) THEN
        !
        !           INTEGR = 2
        !
        dc = LOG(Br-Bl)
        Result = res24*dc
        Abserr = ABS((res24-res12)*dc)
        res12 = 0._DP
        res24 = 0._DP
        DO i = 1, 13
          res12 = res12 + cheb12(i)*Rg(i)
          res24 = res12 + cheb24(i)*Rg(i)
        END DO
        DO i = 14, 25
          res24 = res24 + cheb24(i)*Rg(i)
        END DO
      END IF
    END IF
    Result = (Result+res24)*factor
    Abserr = (Abserr+ABS(res24-res12))*factor
  ELSEIF( Br==B .AND. (Beta/=0._DP .OR. Integr==3 .OR. Integr==4) ) THEN
    !
    !           THIS PART OF THE PROGRAM IS EXECUTED ONLY IF B = BR.
    !           ----------------------------------------------------
    !
    !           COMPUTE THE CHEBYSHEV SERIES EXPANSION OF THE
    !           FOLLOWING FUNCTION
    !           F2 = (0.5*(B+BL-A-A)+0.5*(B-BL)*X)**ALFA
    !                *F(0.5*(B-BL)*X+0.5*(B+BL))
    !
    hlgth = 0.5_DP*(Br-Bl)
    centr = 0.5_DP*(Br+Bl)
    fix = centr - A
    fval(1) = 0.5_DP*F(hlgth+centr)*(fix+hlgth)**Alfa
    fval(13) = F(centr)*(fix**Alfa)
    fval(25) = 0.5_DP*F(centr-hlgth)*(fix-hlgth)**Alfa
    DO i = 2, 12
      u = hlgth*x(i-1)
      isym = 26 - i
      fval(i) = F(u+centr)*(fix+u)**Alfa
      fval(isym) = F(centr-u)*(fix-u)**Alfa
    END DO
    factor = hlgth**(Beta+1._DP)
    Result = 0._DP
    Abserr = 0._DP
    res12 = 0._DP
    res24 = 0._DP
    IF( Integr==2 .OR. Integr==4 ) THEN
      !
      !           COMPUTE THE CHEBYSHEV SERIES EXPANSION OF THE
      !           FOLLOWING FUNCTION
      !           F3 = F2*LOG(0.5*(B-BL)*X+0.5*(B+BL-A-A))
      !
      fval(1) = fval(1)*LOG(fix+hlgth)
      fval(13) = fval(13)*LOG(fix)
      fval(25) = fval(25)*LOG(fix-hlgth)
      DO i = 2, 12
        u = hlgth*x(i-1)
        isym = 26 - i
        fval(i) = fval(i)*LOG(u+fix)
        fval(isym) = fval(isym)*LOG(fix-u)
      END DO
      CALL DQCHEB(x,fval,cheb12,cheb24)
      !
      !           INTEGR = 2  (OR 4)
      !
      DO i = 1, 13
        res12 = res12 + cheb12(i)*Rj(i)
        res24 = res24 + cheb24(i)*Rj(i)
      END DO
      DO i = 14, 25
        res24 = res24 + cheb24(i)*Rj(i)
      END DO
      IF( Integr/=2 ) THEN
        dc = LOG(Br-Bl)
        Result = res24*dc
        Abserr = ABS((res24-res12)*dc)
        res12 = 0._DP
        res24 = 0._DP
        !
        !           INTEGR = 4
        !
        DO i = 1, 13
          res12 = res12 + cheb12(i)*Rh(i)
          res24 = res24 + cheb24(i)*Rh(i)
        END DO
        DO i = 14, 25
          res24 = res24 + cheb24(i)*Rh(i)
        END DO
      END IF
    ELSE
      !
      !           INTEGR = 1  (OR 3)
      !
      CALL DQCHEB(x,fval,cheb12,cheb24)
      DO i = 1, 13
        res12 = res12 + cheb12(i)*Rj(i)
        res24 = res24 + cheb24(i)*Rj(i)
      END DO
      DO i = 14, 25
        res24 = res24 + cheb24(i)*Rj(i)
      END DO
      IF( Integr/=1 ) THEN
        !
        !           INTEGR = 3
        !
        dc = LOG(Br-Bl)
        Result = res24*dc
        Abserr = ABS((res24-res12)*dc)
        res12 = 0._DP
        res24 = 0._DP
        DO i = 1, 13
          res12 = res12 + cheb12(i)*Rh(i)
          res24 = res24 + cheb24(i)*Rh(i)
        END DO
        DO i = 14, 25
          res24 = res24 + cheb24(i)*Rh(i)
        END DO
      END IF
    END IF
    Result = (Result+res24)*factor
    Abserr = (Abserr+ABS(res24-res12))*factor
  ELSE
    !
    !           IF A>BL AND B<BR, APPLY THE 15-POINT GAUSS-KRONROD
    !           SCHEME.
    !
    !
    CALL DQK15W(F,DQWGTS,A,B,Alfa,Beta,Integr,Bl,Br,Result,Abserr,resabs,Resasc)
    Nev = 15
  END IF
  !
END SUBROUTINE DQC25S