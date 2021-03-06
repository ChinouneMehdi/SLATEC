!** CATAN2
COMPLEX(SP) ELEMENTAL FUNCTION CATAN2(Csn,Ccs)
  !> Compute the complex arc tangent in the proper quadrant.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C4A
  !***
  ! **Type:**      COMPLEX (CATAN2-C)
  !***
  ! **Keywords:**  ARC TANGENT, ELEMENTARY FUNCTIONS, FNLIB, POLAR ANGEL,
  !             QUADRANT, TRIGONOMETRIC
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! CATAN2(CSN,CCS) calculates the complex trigonometric arc
  ! tangent of the ratio CSN/CCS and returns a result whose real
  ! part is in the correct quadrant (within a multiple of 2*PI).  The
  ! result is in units of radians and the real part is between -PI and +PI.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  CATAN, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   770401  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900326  Removed duplicate information from DESCRIPTION section.  (WRB)
  COMPLEX(SP), INTENT(IN) :: Csn, Ccs
  REAL(SP), PARAMETER :: pi = 3.14159265358979323846_SP
  !* FIRST EXECUTABLE STATEMENT  CATAN2
  IF( ABS(Csn)==0. .AND. ABS(Ccs)==0. ) THEN
    ERROR STOP 'CATAN2 : CALLED WITH BOTH ARGUMENTS ZERO'
  ELSEIF( ABS(Ccs)==0. ) THEN
    CATAN2 = CMPLX(SIGN(0.5_SP*pi,REAL(Csn)),0._SP,SP)
  ELSE
    CATAN2 = ATAN(Csn/Ccs)
    IF( REAL(Ccs)<0. ) CATAN2 = CATAN2 + pi
    IF( REAL(CATAN2)>pi ) CATAN2 = CATAN2 - 2._SP*pi
  END IF

  RETURN
END FUNCTION CATAN2