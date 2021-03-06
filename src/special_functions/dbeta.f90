!** DBETA
REAL(DP) ELEMENTAL FUNCTION DBETA(A,B)
  !> Compute the complete Beta function.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C7B
  !***
  ! **Type:**      DOUBLE PRECISION (BETA-S, DBETA-D, CBETA-C)
  !***
  ! **Keywords:**  COMPLETE BETA FUNCTION, FNLIB, SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! DBETA(A,B) calculates the double precision complete beta function
  ! for double precision arguments A and B.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  D1MACH, DGAMLM, DLBETA, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   770601  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900727  Added EXTERNAL statement.  (WRB)
  USE service, ONLY : tiny_dp
  !
  REAL(DP), INTENT(IN) :: A, B
  !
  REAL(DP), PARAMETER :: xmax = 171.61447887182297_DP
  REAL(DP), PARAMETER :: alnsml = LOG(tiny_dp)
  !* FIRST EXECUTABLE STATEMENT  DBETA
  !
  IF( A<=0._DP .OR. B<=0._DP ) ERROR STOP 'DBETA : BOTH ARGUMENTS MUST BE > 0'
  !
  IF( A+B<xmax ) THEN
    DBETA = GAMMA(A)*GAMMA(B)/GAMMA(A+B)
  ELSE
    DBETA = DLBETA(A,B)
    IF( DBETA<alnsml ) THEN
      DBETA = 0._DP
      ! CALL XERMSG('DBETA : A AND/OR B SO BIG BETA UNDERFLOWS',1,1)
    ELSE
      DBETA = EXP(DBETA)
    END IF
  END IF

  RETURN
END FUNCTION DBETA