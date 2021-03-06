!** BESI1
REAL(SP) ELEMENTAL FUNCTION BESI1(X)
  !> Compute the modified (hyperbolic) Bessel function of the first kind of order one.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C10B1
  !***
  ! **Type:**      SINGLE PRECISION (BESI1-S, DBESI1-D)
  !***
  ! **Keywords:**  FIRST KIND, FNLIB, HYPERBOLIC BESSEL FUNCTION,
  !             MODIFIED BESSEL FUNCTION, ORDER ONE, SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! BESI1(X) calculates the modified (hyperbolic) Bessel function
  ! of the first kind of order one for real argument X.
  !
  ! Series for BI1        on the interval  0.          to  9.00000D+00
  !                                        with weighted error   2.40E-17
  !                                         log weighted error  16.62
  !                               significant figures required  16.23
  !                                    decimal places required  17.14
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  BESI1E, CSEVL, INITS, R1MACH, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   770401  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900326  Removed duplicate information from DESCRIPTION section.  (WRB)
  USE service, ONLY : tiny_sp, huge_sp, eps_2_sp
  !
  REAL(SP), INTENT(IN) :: X
  !
  REAL(SP) :: y
  INTEGER, PARAMETER :: nti1 = 7
  REAL(SP), PARAMETER :: xmin = 2._SP*tiny_sp, xsml = SQRT(4.5_SP*eps_2_sp), &
    xmax = LOG(huge_sp)
  REAL(SP), PARAMETER :: bi1cs(11) = [ -.001971713261099859_SP, .40734887667546481_SP, &
    .034838994299959456_SP, .001545394556300123_SP, .000041888521098377_SP, &
    .000000764902676483_SP, .000000010042493924_SP, .000000000099322077_SP, &
    .000000000000766380_SP, .000000000000004741_SP, .000000000000000024_SP ]
  !* FIRST EXECUTABLE STATEMENT  BESI1
  ! nti1 = INITS(bi1cs,0.1_SP*eps_2_sp)
  !
  y = ABS(X)
  IF( y>xmax ) THEN
    ERROR STOP 'BESI1 : ABS(X) SO BIG I1 OVERFLOWS'
  ELSEIF( y>3._SP ) THEN
    BESI1 = EXP(y)*BESI1E(X)
  ELSEIF( y>xsml ) THEN
    BESI1 = X*(.875_SP+CSEVL(y*y/4.5_SP-1._SP,bi1cs(1:nti1)))
  ELSEIF( y>xmin ) THEN
    BESI1 = 0.5_SP*X
  ELSE
    BESI1 = 0._SP
    !CALL XERMSG('BESI1 : ABS(X) SO SMALL I1 UNDERFLOWS',1,1)
  END IF

  RETURN
END FUNCTION BESI1