!** R9LGMC
REAL(SP) FUNCTION R9LGMC(X)
  !> Compute the log Gamma correction factor so that
  !            LOG(GAMMA(X)) = LOG(SQRT(2*PI)) + (X-.5)*LOG(X) - X
  !            + R9LGMC(X).
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C7E
  !***
  ! **Type:**      SINGLE PRECISION (R9LGMC-S, D9LGMC-D, C9LGMC-C)
  !***
  ! **Keywords:**  COMPLETE GAMMA FUNCTION, CORRECTION TERM, FNLIB,
  !             LOG GAMMA, LOGARITHM, SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! Compute the log gamma correction factor for X >= 10.0 so that
  !  LOG (GAMMA(X)) = LOG(SQRT(2*PI)) + (X-.5)*LOG(X) - X + R9LGMC(X)
  !
  ! Series for ALGM       on the interval  0.          to  1.00000D-02
  !                                        with weighted error   3.40E-16
  !                                         log weighted error  15.47
  !                               significant figures required  14.39
  !                                    decimal places required  15.86
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  CSEVL, INITS, R1MACH, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   770801  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900720  Routine changed from user-callable to subsidiary.  (WRB)
  USE service, ONLY : XERMSG, R1MACH
  REAL(SP) :: X
  INTEGER, SAVE :: nalgm
  REAL(SP), PARAMETER :: xmax = EXP(MIN(LOG(R1MACH(2)/12._SP),-LOG(12._SP*R1MACH(1)))), &
    xbig = 1._SP/SQRT(R1MACH(3))
  REAL(SP), PARAMETER :: algmcs(6) = [ .166638948045186_SP,-.0000138494817606_SP, &
    .0000000098108256_SP,-.0000000000180912_SP, .0000000000000622_SP, &
    -.0000000000000003_SP ]
  LOGICAL, SAVE :: first = .TRUE.
  !* FIRST EXECUTABLE STATEMENT  R9LGMC
  IF( first ) THEN
    nalgm = INITS(algmcs,6,R1MACH(3))
    first = .FALSE.
  END IF
  !
  IF( X<10._SP ) CALL XERMSG('R9LGMC','X MUST BE GE 10',1,2)
  IF( X>=xmax ) THEN
    !
    R9LGMC = 0._SP
    CALL XERMSG('R9LGMC','X SO BIG R9LGMC UNDERFLOWS',2,1)
    RETURN
  END IF
  !
  R9LGMC = 1._SP/(12._SP*X)
  IF( X<xbig ) R9LGMC = CSEVL(2._SP*(10._SP/X)**2-1._SP,algmcs,nalgm)/X
  RETURN
END FUNCTION R9LGMC
