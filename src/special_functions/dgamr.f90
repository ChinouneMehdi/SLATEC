!** DGAMR
REAL(DP) FUNCTION DGAMR(X)
  !> Compute the reciprocal of the Gamma function.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C7A
  !***
  ! **Type:**      DOUBLE PRECISION (GAMR-S, DGAMR-D, CGAMR-C)
  !***
  ! **Keywords:**  FNLIB, RECIPROCAL GAMMA FUNCTION, SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! DGAMR(X) calculates the double precision reciprocal of the
  ! complete Gamma function for double precision argument X.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  DLGAMS, XERCLR, XGETF, XSETF

  !* REVISION HISTORY  (YYMMDD)
  !   770701  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900727  Added EXTERNAL statement.  (WRB)
  USE service, ONLY : XGETF, XSETF, XERCLR
  INTEGER :: irold
  REAL(DP) :: X, alngx, sgngx
  !* FIRST EXECUTABLE STATEMENT  DGAMR
  DGAMR = 0.0D0
  IF( X<=0.0D0 .AND. AINT(X)==X ) RETURN
  !
  CALL XGETF(irold)
  CALL XSETF(1)
  IF( ABS(X)>10.0D0 ) THEN
    !
    CALL DLGAMS(X,alngx,sgngx)
    CALL XERCLR
    CALL XSETF(irold)
    DGAMR = sgngx*EXP(-alngx)
    RETURN
  END IF
  DGAMR = 1.0D0/GAMMA(X)
  CALL XERCLR
  CALL XSETF(irold)
  RETURN
END FUNCTION DGAMR
