!** DQMOMO
PURE SUBROUTINE DQMOMO(Alfa,Beta,Ri,Rj,Rg,Rh,Integr)
  !> This routine computes modified Chebyshev moments. The K-th modified Chebyshev
  !  moment is defined as the integral over (-1,1) of W(X)*T(K,X),
  !  where T(K,X) is the Chebyshev polynomial of degree K.
  !***
  ! **Library:**   SLATEC (QUADPACK)
  !***
  ! **Category:**  H2A2A1, C3A2
  !***
  ! **Type:**      DOUBLE PRECISION (QMOMO-S, DQMOMO-D)
  !***
  ! **Keywords:**  MODIFIED CHEBYSHEV MOMENTS, QUADPACK, QUADRATURE
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
  !        MODIFIED CHEBYSHEV MOMENTS
  !        STANDARD FORTRAN SUBROUTINE
  !        DOUBLE PRECISION VERSION
  !
  !        PARAMETERS
  !           ALFA   - Double precision
  !                    Parameter in the weight function W(X), ALFA>(-1)
  !
  !           BETA   - Double precision
  !                    Parameter in the weight function W(X), BETA>(-1)
  !
  !           RI     - Double precision
  !                    Vector of dimension 25
  !                    RI(K) is the integral over (-1,1) of
  !                    (1+X)**ALFA*T(K-1,X), K = 1, ..., 25.
  !
  !           RJ     - Double precision
  !                    Vector of dimension 25
  !                    RJ(K) is the integral over (-1,1) of
  !                    (1-X)**BETA*T(K-1,X), K = 1, ..., 25.
  !
  !           RG     - Double precision
  !                    Vector of dimension 25
  !                    RG(K) is the integral over (-1,1) of
  !                    (1+X)**ALFA*LOG((1+X)/2)*T(K-1,X), K = 1, ..., 25.
  !
  !           RH     - Double precision
  !                    Vector of dimension 25
  !                    RH(K) is the integral over (-1,1) of
  !                    (1-X)**BETA*LOG((1-X)/2)*T(K-1,X), K = 1, ..., 25.
  !
  !           INTEGR - Integer
  !                    Input parameter indicating the modified
  !                    Moments to be computed
  !                    INTEGR = 1 compute RI, RJ
  !                           = 2 compute RI, RJ, RG
  !                           = 3 compute RI, RJ, RH
  !                           = 4 compute RI, RJ, RG, RH
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   820101  DATE WRITTEN
  !   891009  Removed unreferenced statement label.  (WRB)
  !   891009  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)

  !
  INTEGER, INTENT(IN) :: Integr
  REAL(DP), INTENT(IN) :: Alfa, Beta
  REAL(DP), INTENT(OUT) :: Rg(25), Rh(25), Ri(25), Rj(25)
  !
  INTEGER :: i, im1
  REAL(DP) :: alfp1, alfp2, an, anm1, betp1, betp2, ralf, rbet
  !
  !* FIRST EXECUTABLE STATEMENT  DQMOMO
  alfp1 = Alfa + 1._DP
  betp1 = Beta + 1._DP
  alfp2 = Alfa + 2._DP
  betp2 = Beta + 2._DP
  ralf = 2._DP**alfp1
  rbet = 2._DP**betp1
  !
  !           COMPUTE RI, RJ USING A FORWARD RECURRENCE RELATION.
  !
  Ri(1) = ralf/alfp1
  Rj(1) = rbet/betp1
  Ri(2) = Ri(1)*Alfa/alfp2
  Rj(2) = Rj(1)*Beta/betp2
  an = 2._DP
  anm1 = 1._DP
  DO i = 3, 25
    Ri(i) = -(ralf+an*(an-alfp2)*Ri(i-1))/(anm1*(an+alfp1))
    Rj(i) = -(rbet+an*(an-betp2)*Rj(i-1))/(anm1*(an+betp1))
    anm1 = an
    an = an + 1._DP
  END DO
  IF( Integr/=1 ) THEN
    IF( Integr/=3 ) THEN
      !
      !           COMPUTE RG USING A FORWARD RECURRENCE RELATION.
      !
      Rg(1) = -Ri(1)/alfp1
      Rg(2) = -(ralf+ralf)/(alfp2*alfp2) - Rg(1)
      an = 2._DP
      anm1 = 1._DP
      im1 = 2
      DO i = 3, 25
        Rg(i) = -(an*(an-alfp2)*Rg(im1)-an*Ri(im1)+anm1*Ri(i))/(anm1*(an+alfp1))
        anm1 = an
        an = an + 1._DP
        im1 = i
      END DO
      IF( Integr==2 ) GOTO 100
    END IF
    !
    !           COMPUTE RH USING A FORWARD RECURRENCE RELATION.
    !
    Rh(1) = -Rj(1)/betp1
    Rh(2) = -(rbet+rbet)/(betp2*betp2) - Rh(1)
    an = 2._DP
    anm1 = 1._DP
    im1 = 2
    DO i = 3, 25
      Rh(i) = -(an*(an-betp2)*Rh(im1)-an*Rj(im1)+anm1*Rj(i))/(anm1*(an+betp1))
      anm1 = an
      an = an + 1._DP
      im1 = i
    END DO
    DO i = 2, 25, 2
      Rh(i) = -Rh(i)
    END DO
  END IF
  100 CONTINUE
  DO i = 2, 25, 2
    Rj(i) = -Rj(i)
  END DO
  !
END SUBROUTINE DQMOMO