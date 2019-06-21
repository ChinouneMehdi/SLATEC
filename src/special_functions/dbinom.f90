!** DBINOM
REAL(DP) FUNCTION DBINOM(N,M)
  !> Compute the binomial coefficients.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C1
  !***
  ! **Type:**      DOUBLE PRECISION (BINOM-S, DBINOM-D)
  !***
  ! **Keywords:**  BINOMIAL COEFFICIENTS, FNLIB, SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! DBINOM(N,M) calculates the double precision binomial coefficient
  ! for integer arguments N and M.  The result is (N!)/((M!)(N-M)!).
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  D1MACH, D9LGMC, DLNREL, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   770601  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  USE service, ONLY : XERMSG, D1MACH
  INTEGER :: M, N
  INTEGER :: i, k
  REAL(DP) :: corr, xk, xn, xnk
  REAL(DP), PARAMETER :: bilnmx = LOG(D1MACH(2)) - 0.0001_DP, &
    fintmx = 0.9_DP/D1MACH(3)
  REAL(DP), PARAMETER :: sq2pil = 0.91893853320467274178032973640562_DP
  !* FIRST EXECUTABLE STATEMENT  DBINOM
  !
  IF( N<0 .OR. M<0 ) CALL XERMSG('DBINOM','N OR M LT ZERO',1,2)
  IF( N<M ) CALL XERMSG('DBINOM','N LT M',2,2)
  !
  k = MIN(M,N-M)
  IF( k<=20 ) THEN
    IF( k*LOG(AMAX0(N,1))<=bilnmx ) THEN
      !
      DBINOM = 1._DP
      IF( k==0 ) RETURN
      DO i = 1, k
        xn = N - i + 1
        xk = i
        DBINOM = DBINOM*(xn/xk)
      END DO
      !
      IF( DBINOM<fintmx ) DBINOM = AINT(DBINOM+0.5_DP)
      RETURN
    END IF
  END IF
  !
  ! IF K<9, APPROX IS NOT VALID AND ANSWER IS CLOSE TO THE OVERFLOW LIM
  IF( k<9 ) CALL XERMSG('DBINOM','RESULT OVERFLOWS BECAUSE N AND/OR M TOO BIG',3,2)
  !
  xn = N + 1
  xk = k + 1
  xnk = N - k + 1
  !
  corr = D9LGMC(xn) - D9LGMC(xk) - D9LGMC(xnk)
  DBINOM = xk*LOG(xnk/xk) - xn*DLNREL(-(xk-1._DP)/xn) - 0.5_DP*LOG(xn*xnk/xk)&
    + 1._DP - sq2pil + corr
  !
  IF( DBINOM>bilnmx ) CALL XERMSG('DBINOM',&
    'RESULT OVERFLOWS BECAUSE N AND/OR M TOO BIG',3,2)
  !
  DBINOM = EXP(DBINOM)
  IF( DBINOM<fintmx ) DBINOM = AINT(DBINOM+0.5_DP)
  !
END FUNCTION DBINOM
