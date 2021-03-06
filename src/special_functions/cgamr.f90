!** CGAMR
COMPLEX(SP) ELEMENTAL FUNCTION CGAMR(Z)
  !> Compute the reciprocal of the Gamma function.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C7A
  !***
  ! **Type:**      COMPLEX (GAMR-S, DGAMR-D, CGAMR-C)
  !***
  ! **Keywords:**  FNLIB, RECIPROCAL GAMMA FUNCTION, SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! CGAMR(Z) calculates the reciprocal gamma function for COMPLEX
  ! argument Z.  This is a preliminary version that is not accurate.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  CLNGAM, XERCLR, XGETF, XSETF

  !* REVISION HISTORY  (YYMMDD)
  !   770701  DATE WRITTEN
  !   861211  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  COMPLEX(SP), INTENT(IN) :: Z
  REAL(SP) :: x
  !* FIRST EXECUTABLE STATEMENT  CGAMR

  x = REAL(Z)
  IF( x<=0._SP .AND. AINT(x)==x .AND. AIMAG(Z)==0._SP ) THEN
    CGAMR = (0._SP,0._SP)
  ELSE
    CGAMR = EXP(-CLNGAM(Z))
  END IF

END FUNCTION CGAMR