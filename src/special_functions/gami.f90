!** GAMI
REAL(SP) ELEMENTAL FUNCTION GAMI(A,X)
  !> Evaluate the incomplete Gamma function.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C7E
  !***
  ! **Type:**      SINGLE PRECISION (GAMI-S, DGAMI-D)
  !***
  ! **Keywords:**  FNLIB, INCOMPLETE GAMMA FUNCTION, SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! Evaluate the incomplete gamma function defined by
  !
  ! GAMI = integral from T = 0 to X of EXP(-T) * T**(A-1.0) .
  !
  ! GAMI is evaluated for positive values of A and non-negative values
  ! of X.  A slight deterioration of 2 or 3 digits accuracy will occur
  ! when GAMI is very large or very small, because logarithmic variables
  ! are used.  GAMI, A, and X are single precision.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  GAMIT, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   770701  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  REAL(SP), INTENT(IN) :: A, X
  REAL(SP) :: factor
  !* FIRST EXECUTABLE STATEMENT  GAMI
  IF( A<=0._SP ) ERROR STOP 'GAMI : A MUST BE >= 0'

  IF( X<0._SP ) THEN
    ERROR STOP 'GAMI : X MUST BE >= 0'
  ELSEIF( X==0._SP ) THEN
    GAMI = 0._SP
  ELSE
    ! THE ONLY ERROR POSSIBLE IN THE EXPRESSION BELOW IS A FATAL OVERFLOW.
    factor = EXP(LOG_GAMMA(A)+A*LOG(X))
    GAMI = factor*GAMIT(A,X)
  END IF

END FUNCTION GAMI