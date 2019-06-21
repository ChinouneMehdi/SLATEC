!** FAC
REAL(SP) FUNCTION FAC(N)
  !> Compute the factorial function.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C1
  !***
  ! **Type:**      SINGLE PRECISION (FAC-S, DFAC-D)
  !***
  ! **Keywords:**  FACTORIAL, FNLIB, SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! FAC(N) evaluates the factorial function of N.  FAC is single
  ! precision.  N must be an integer between 0 and 25 inclusive.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  GAMLIM, R9LGMC, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   770601  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  USE service, ONLY : XERMSG
  REAL(SP) :: x, xmax, xmin
  INTEGER :: N
  REAL(SP), PARAMETER :: facn(26) = [ 1._SP, 1._SP, 2._SP, 6._SP, 24._SP, 120._SP, &
    720._SP, 5040._SP, 40320._SP, 362880._SP, 3628800._SP, 39916800._SP, &
    479001600._SP, 6227020800._SP, 87178291200._SP, 1307674368000._SP, &
    20922789888000._SP,     355687428096000._SP,   6402373705728000._SP, &
    .12164510040883200E18_SP, .24329020081766400E19_SP, .51090942171709440E20_SP, &
    .11240007277776077E22_SP, .25852016738884977E23_SP, .62044840173323944E24_SP, &
    .15511210043330986E26_SP ]
  REAL(SP), PARAMETER :: sq2pil = 0.91893853320467274_SP
  INTEGER, SAVE :: nmax = 0
  !* FIRST EXECUTABLE STATEMENT  FAC
  IF( nmax==0 ) THEN
    CALL GAMLIM(xmin,xmax)
    nmax = INT( xmax ) - 1
  END IF
  !
  IF( N<0 ) CALL XERMSG('FAC',&
    'FACTORIAL OF NEGATIVE INTEGER UNDEFINED',1,2)
  !
  IF( N<=25 ) FAC = facn(N+1)
  IF( N<=25 ) RETURN
  !
  IF( N>nmax ) CALL XERMSG('FAC','N SO BIG FACTORIAL(N) OVERFLOWS',2,2)
  !
  x = N + 1
  FAC = EXP((x-0.5_SP)*LOG(x)-x+sq2pil+R9LGMC(x))
  !
END FUNCTION FAC
