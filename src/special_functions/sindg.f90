!** SINDG
REAL(SP) ELEMENTAL FUNCTION SINDG(X)
  !> Compute the sine of an argument in degrees.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C4A
  !***
  ! **Type:**      SINGLE PRECISION (SINDG-S, DSINDG-D)
  !***
  ! **Keywords:**  DEGREES, ELEMENTARY FUNCTIONS, FNLIB, SINE, TRIGONOMETRIC
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! SINDG(X) evaluates the single precision sine of X where
  ! X is in degrees.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   770601  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)

  ! JUNE 1977 EDITION.   W. FULLERTON, C3, LOS ALAMOS SCIENTIFIC LAB.
  REAL(SP), INTENT(IN) :: X
  INTEGER :: n
  REAL(SP), PARAMETER :: raddeg = .017453292519943296_SP
  !
  !* FIRST EXECUTABLE STATEMENT  SINDG
  SINDG = SIN(raddeg*X)
  !
  IF( MOD(X,90._SP)/=0. ) RETURN
  n = INT( ABS(X)/90._SP + 0.5_SP )
  n = MOD(n,2)
  IF( n==0 ) SINDG = 0.
  IF( n==1 ) SINDG = SIGN(1._SP,SINDG)
  !
END FUNCTION SINDG