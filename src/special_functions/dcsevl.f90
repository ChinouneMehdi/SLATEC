!** DCSEVL
REAL(DP) PURE FUNCTION DCSEVL(X,Cs)
  !> Evaluate a Chebyshev series.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C3A2
  !***
  ! **Type:**      DOUBLE PRECISION (CSEVL-S, DCSEVL-D)
  !***
  ! **Keywords:**  CHEBYSHEV SERIES, FNLIB, SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  !  Evaluate the N-term Chebyshev series CS at X.  Adapted from
  !  a method presented in the paper by Broucke referenced below.
  !
  !       Input Arguments --
  !  X    value at which the series is to be evaluated.
  !  CS   array of N terms of a Chebyshev series.  In evaluating
  !       CS, only half the first coefficient is summed.
  !  N    number of terms in array CS.
  !
  !***
  ! **References:**  R. Broucke, Ten subroutines for the manipulation of
  !                 Chebyshev series, Algorithm 446, Communications of
  !                 the A.C.M. 16, (1973) pp. 254-256.
  !               L. Fox and I. B. Parker, Chebyshev Polynomials in
  !                 Numerical Analysis, Oxford University Press, 1968,
  !                 page 56.
  !***
  ! **Routines called:**  D1MACH, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   770401  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900329  Prologued revised extensively and code rewritten to allow
  !           X to be slightly outside interval (-1,+1).  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  !
  REAL(DP), INTENT(IN) :: X
  REAL(DP), INTENT(IN) :: Cs(:)
  !
  INTEGER :: i, ni, n
  REAL(DP) :: b0, b1, b2, twox
  !* FIRST EXECUTABLE STATEMENT  DCSEVL
  IF( ABS(X)>1._DP ) ERROR STOP 'DCSEVL : X OUTSIDE THE INTERVAL (-1,+1)'
  n = SIZE( Cs )
  !
  b1 = 0._DP
  b0 = 0._DP
  twox = 2._DP*X
  DO i = 1, n
    b2 = b1
    b1 = b0
    ni = n + 1 - i
    b0 = twox*b1 - b2 + Cs(ni)
  END DO
  !
  DCSEVL = 0.5_DP*(b0-b2)
  !
END FUNCTION DCSEVL
