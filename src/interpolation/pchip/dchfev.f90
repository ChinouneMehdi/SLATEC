!** DCHFEV
PURE SUBROUTINE DCHFEV(X1,X2,F1,F2,D1,D2,Ne,Xe,Fe,Next,Ierr)
  !> Evaluate a cubic polynomial given in Hermite form at an array of points.
  !  While designed for use by DPCHFE, it may be useful directly as an evaluator
  !  for a piecewise cubic Hermite function in applications, such as graphing,
  !  where the interval is known in advance.
  !***
  ! **Library:**   SLATEC (PCHIP)
  !***
  ! **Category:**  E3
  !***
  ! **Type:**      DOUBLE PRECISION (CHFEV-S, DCHFEV-D)
  !***
  ! **Keywords:**  CUBIC HERMITE EVALUATION, CUBIC POLYNOMIAL EVALUATION,
  !             PCHIP
  !***
  ! **Author:**  Fritsch, F. N., (LLNL)
  !             Lawrence Livermore National Laboratory
  !             P.O. Box 808  (L-316)
  !             Livermore, CA  94550
  !             FTS 532-4275, (510) 422-4275
  !***
  ! **Description:**
  !
  !          DCHFEV:  Cubic Hermite Function EValuator
  !
  !     Evaluates the cubic polynomial determined by function values
  !     F1,F2 and derivatives D1,D2 on interval (X1,X2) at the points
  !     XE(J), J=1(1)NE.
  !
  ! ----------------------------------------------------------------------
  !
  !  Calling sequence:
  !
  !        INTEGER  NE, NEXT(2), IERR
  !        DOUBLE PRECISION  X1, X2, F1, F2, D1, D2, XE(NE), FE(NE)
  !
  !        CALL  DCHFEV (X1,X2, F1,F2, D1,D2, NE, XE, FE, NEXT, IERR)
  !
  !   Parameters:
  !
  !     X1,X2 -- (input) endpoints of interval of definition of cubic.
  !           (Error return if  X1=X2 .)
  !
  !     F1,F2 -- (input) values of function at X1 and X2, respectively.
  !
  !     D1,D2 -- (input) values of derivative at X1 and X2, respectively.
  !
  !     NE -- (input) number of evaluation points.  (Error return if
  !           NE<1 .)
  !
  !     XE -- (input) real*8 array of points at which the function is to
  !           be evaluated.  If any of the XE are outside the interval
  !           [X1,X2], a warning error is returned in NEXT.
  !
  !     FE -- (output) real*8 array of values of the cubic function
  !           defined by  X1,X2, F1,F2, D1,D2  at the points  XE.
  !
  !     NEXT -- (output) integer array indicating number of extrapolation
  !           points:
  !            NEXT(1) = number of evaluation points to left of interval.
  !            NEXT(2) = number of evaluation points to right of interval.
  !
  !     IERR -- (output) error flag.
  !           Normal return:
  !              IERR = 0  (no errors).
  !           "Recoverable" errors:
  !              IERR = -1  if NE<1 .
  !              IERR = -2  if X1=X2 .
  !                (The FE-array has not been changed in either case.)
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   811019  DATE WRITTEN
  !   820803  Minor cosmetic changes for release 1.
  !   870813  Corrected XERROR calls for d.p. names(s).
  !   890206  Corrected XERROR calls.
  !   890411  Added SAVE statements (Vers. 3.2).
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890703  Corrected category record.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   891006  Cosmetic changes to prologue.  (WRB)
  !   891006  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)

  !  Programming notes:
  !
  !     To produce a single precision version, simply:
  !        a. Change DCHFEV to CHFEV wherever it occurs,
  !        b. Change the double precision declaration to REAL(SP), and
  !        c. Change the constant ZERO to single precision.
  !
  !  DECLARE ARGUMENTS.
  !
  INTEGER, INTENT(IN) :: Ne
  INTEGER, INTENT(OUT) :: Next(2), Ierr
  REAL(DP), INTENT(IN) :: X1, X2, F1, F2, D1, D2, Xe(Ne)
  REAL(DP), INTENT(OUT) :: Fe(Ne)
  !
  !  DECLARE LOCAL VARIABLES.
  !
  INTEGER :: i
  REAL(DP) :: c2, c3, del1, del2, delta, h, x, xmi, xma
  !
  !  VALIDITY-CHECK ARGUMENTS.
  !
  !* FIRST EXECUTABLE STATEMENT  DCHFEV
  IF( Ne<1 ) THEN
    !
    !  ERROR RETURNS.
    !
    !     NE<1 RETURN.
    Ierr = -1
    ERROR STOP 'DCHFEV : NUMBER OF EVALUATION POINTS LESS THAN ONE'
  ELSE
    h = X2 - X1
    IF( h==0._DP ) THEN
      !
      !     X1=X2 RETURN.
      Ierr = -2
      ERROR STOP 'DCHFEV : INTERVAL ENDPOINTS EQUAL'
    END IF
  END IF
  !
  !  INITIALIZE.
  !
  Ierr = 0
  Next(1) = 0
  Next(2) = 0
  xmi = MIN(0._DP,h)
  xma = MAX(0._DP,h)
  !
  !  COMPUTE CUBIC COEFFICIENTS (EXPANDED ABOUT X1).
  !
  delta = (F2-F1)/h
  del1 = (D1-delta)/h
  del2 = (D2-delta)/h
  !                                           (DELTA IS NO LONGER NEEDED.)
  c2 = -(del1+del1+del2)
  c3 = (del1+del2)/h
  !                               (H, DEL1 AND DEL2 ARE NO LONGER NEEDED.)
  !
  !  EVALUATION LOOP.
  !
  DO i = 1, Ne
    x = Xe(i) - X1
    Fe(i) = F1 + x*(D1+x*(c2+x*c3))
    !          COUNT EXTRAPOLATION POINTS.
    IF( x<xmi ) Next(1) = Next(1) + 1
    IF( x>xma ) Next(2) = Next(2) + 1
    !        (NOTE REDUNDANCY--IF EITHER CONDITION IS TRUE, OTHER IS FALSE.)
  END DO
  !
  !  NORMAL RETURN.
  !
  RETURN
  !------------- LAST LINE OF DCHFEV FOLLOWS -----------------------------
END SUBROUTINE DCHFEV