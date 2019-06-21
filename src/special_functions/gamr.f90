!** GAMR
REAL(SP) FUNCTION GAMR(X)
  !> Compute the reciprocal of the Gamma function.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C7A
  !***
  ! **Type:**      SINGLE PRECISION (GAMR-S, DGAMR-D, CGAMR-C)
  !***
  ! **Keywords:**  FNLIB, RECIPROCAL GAMMA FUNCTION, SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! GAMR is a single precision function that evaluates the reciprocal
  ! of the gamma function for single precision argument X.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  ALGAMS, XERCLR, XGETF, XSETF

  !* REVISION HISTORY  (YYMMDD)
  !   770701  DATE WRITTEN
  !   861211  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900727  Added EXTERNAL statement.  (WRB)
  USE service, ONLY : XGETF, XSETF, XERCLR
  REAL(SP) :: alngx, sgngx, X
  INTEGER :: irold
  !* FIRST EXECUTABLE STATEMENT  GAMR
  GAMR = 0._SP
  IF( X<=0._SP .AND. AINT(X)==X ) RETURN
  !
  CALL XGETF(irold)
  CALL XSETF(1)
  IF( ABS(X)>10._SP ) THEN
    !
    CALL ALGAMS(X,alngx,sgngx)
    CALL XERCLR
    CALL XSETF(irold)
    GAMR = sgngx*EXP(-alngx)
    RETURN
  END IF
  GAMR = 1._SP/GAMMA(X)
  CALL XERCLR
  CALL XSETF(irold)
  RETURN
END FUNCTION GAMR
