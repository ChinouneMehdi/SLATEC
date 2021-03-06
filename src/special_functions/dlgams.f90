!** DLGAMS
ELEMENTAL SUBROUTINE DLGAMS(X,Dlgam,Sgngam)
  !> Compute the logarithm of the absolute value of the Gamma function.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C7A
  !***
  ! **Type:**      DOUBLE PRECISION (ALGAMS-S, DLGAMS-D)
  !***
  ! **Keywords:**  ABSOLUTE VALUE OF THE LOGARITHM OF THE GAMMA FUNCTION,
  !             FNLIB, SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! DLGAMS(X,DLGAM,SGNGAM) calculates the double precision natural
  ! logarithm of the absolute value of the Gamma function for
  ! double precision argument X and stores the result in double
  ! precision argument DLGAM.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  DLNGAM

  !* REVISION HISTORY  (YYMMDD)
  !   770701  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)

  REAL(DP), INTENT(IN) :: X
  REAL(DP), INTENT(OUT) :: Dlgam, Sgngam
  INTEGER :: i
  !* FIRST EXECUTABLE STATEMENT  DLGAMS
  Dlgam = LOG_GAMMA(X)
  Sgngam = 1._DP
  IF( X>0._DP ) RETURN
  !
  i = INT( MOD(-AINT(X),2._DP) + 0.1_DP )
  IF( i==0 ) Sgngam = -1._DP
  !
END SUBROUTINE DLGAMS