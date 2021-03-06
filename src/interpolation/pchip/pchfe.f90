!** PCHFE
PURE SUBROUTINE PCHFE(N,X,F,D,Incfd,Skip,Ne,Xe,Fe,Ierr)
  !> Evaluate a piecewise cubic Hermite function at an array of points.
  !  May be used by itself for Hermite interpolation, or as an evaluator for PCHIM or PCHIC.
  !***
  ! **Library:**   SLATEC (PCHIP)
  !***
  ! **Category:**  E3
  !***
  ! **Type:**      SINGLE PRECISION (PCHFE-S, DPCHFE-D)
  !***
  ! **Keywords:**  CUBIC HERMITE EVALUATION, HERMITE INTERPOLATION, PCHIP,
  !             PIECEWISE CUBIC EVALUATION
  !***
  ! **Author:**  Fritsch, F. N., (LLNL)
  !             Lawrence Livermore National Laboratory
  !             P.O. Box 808  (L-316)
  !             Livermore, CA  94550
  !             FTS 532-4275, (510) 422-4275
  !***
  ! **Description:**
  !
  !          PCHFE:  Piecewise Cubic Hermite Function Evaluator
  !
  !     Evaluates the cubic Hermite function defined by  N, X, F, D  at
  !     the points  XE(J), J=1(1)NE.
  !
  !     To provide compatibility with PCHIM and PCHIC, includes an
  !     increment between successive values of the F- and D-arrays.
  !
  ! ----------------------------------------------------------------------
  !
  !  Calling sequence:
  !
  !        PARAMETER  (INCFD = ...)
  !        INTEGER  N, NE, IERR
  !        REAL  X(N), F(INCFD,N), D(INCFD,N), XE(NE), FE(NE)
  !        LOGICAL  SKIP
  !
  !        CALL  PCHFE (N, X, F, D, INCFD, SKIP, NE, XE, FE, IERR)
  !
  !   Parameters:
  !
  !     N -- (input) number of data points.  (Error return if N<2 .)
  !
  !     X -- (input) real array of independent variable values.  The
  !           elements of X must be strictly increasing:
  !                X(I-1) < X(I),  I = 2(1)N.
  !           (Error return if not.)
  !
  !     F -- (input) real array of function values.  F(1+(I-1)*INCFD) is
  !           the value corresponding to X(I).
  !
  !     D -- (input) real array of derivative values.  D(1+(I-1)*INCFD) is
  !           the value corresponding to X(I).
  !
  !     INCFD -- (input) increment between successive values in F and D.
  !           (Error return if  INCFD<1 .)
  !
  !     SKIP -- (input/output) logical variable which should be set to
  !           .TRUE. if the user wishes to skip checks for validity of
  !           preceding parameters, or to .FALSE. otherwise.
  !           This will save time in case these checks have already
  !           been performed (say, in PCHIM or PCHIC).
  !           SKIP will be set to .TRUE. on normal return.
  !
  !     NE -- (input) number of evaluation points.  (Error return if
  !           NE<1 .)
  !
  !     XE -- (input) real array of points at which the function is to be
  !           evaluated.
  !
  !          NOTES:
  !           1. The evaluation will be most efficient if the elements
  !              of XE are increasing relative to X;
  !              that is,   XE(J) >= X(I)
  !              implies    XE(K) >= X(I),  all K>=J .
  !           2. If any of the XE are outside the interval [X(1),X(N)],
  !              values are extrapolated from the nearest extreme cubic,
  !              and a warning error is returned.
  !
  !     FE -- (output) real array of values of the cubic Hermite function
  !           defined by  N, X, F, D  at the points  XE.
  !
  !     IERR -- (output) error flag.
  !           Normal return:
  !              IERR = 0  (no errors).
  !           Warning error:
  !              IERR>0  means that extrapolation was performed at
  !                 IERR points.
  !           "Recoverable" errors:
  !              IERR = -1  if N<2 .
  !              IERR = -2  if INCFD<1 .
  !              IERR = -3  if the X-array is not strictly increasing.
  !              IERR = -4  if NE<1 .
  !             (The FE-array has not been changed in any of these cases.)
  !               NOTE:  The above errors are checked in the order listed,
  !                   and following arguments have **NOT** been validated.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  CHFEV, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   811020  DATE WRITTEN
  !   820803  Minor cosmetic changes for release 1.
  !   870707  Minor cosmetic changes to prologue.
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)

  !  Programming notes:
  !
  !     1. To produce a double precision version, simply:
  !        a. Change PCHFE to DPCHFE, and CHFEV to DCHFEV, wherever they
  !           occur,
  !        b. Change the real declaration to double precision,
  !
  !     2. Most of the coding between the call to CHFEV and the end of
  !        the IR-loop could be eliminated if it were permissible to
  !        assume that XE is ordered relative to X.
  !
  !     3. CHFEV does not assume that X1 is less than X2.  thus, it would
  !        be possible to write a version of PCHFE that assumes a strict-
  !        ly decreasing X-array by simply running the IR-loop backwards
  !        (and reversing the order of appropriate tests).
  !
  !     4. The present code has a minor bug, which I have decided is not
  !        worth the effort that would be required to fix it.
  !        If XE contains points in [X(N-1),X(N)], followed by points <
  !        X(N-1), followed by points >X(N), the extrapolation points
  !        will be counted (at least) twice in the total returned in IERR.
  !
  !  DECLARE ARGUMENTS.
  !
  INTEGER, INTENT(IN) :: N, Incfd, Ne
  INTEGER, INTENT(OUT) :: Ierr
  REAL(SP), INTENT(IN) :: X(N), F(Incfd,N), D(Incfd,N), Xe(Ne)
  REAL(SP), INTENT(OUT) :: Fe(Ne)
  LOGICAL, INTENT(INOUT) :: Skip
  !
  !  DECLARE LOCAL VARIABLES.
  !
  INTEGER :: i, ierc, ir, j, jfirst, next(2), nj
  !
  !  VALIDITY-CHECK ARGUMENTS.
  !
  !* FIRST EXECUTABLE STATEMENT  PCHFE
  IF( .NOT. (Skip) ) THEN
    !
    IF( N<2 ) THEN
      !
      !  ERROR RETURNS.
      !
      !     N<2 RETURN.
      Ierr = -1
      ERROR STOP 'PCHFE : NUMBER OF DATA POINTS LESS THAN TWO'
      RETURN
    ELSEIF( Incfd<1 ) THEN
      !
      !     INCFD<1 RETURN.
      Ierr = -2
      ERROR STOP 'PCHFE : INCREMENT LESS THAN ONE'
      RETURN
    ELSE
      DO i = 2, N
        IF( X(i)<=X(i-1) ) GOTO 500
      END DO
    END IF
  END IF
  !
  !  FUNCTION DEFINITION IS OK, GO ON.
  !
  IF( Ne<1 ) THEN
    !
    !     NE<1 RETURN.
    Ierr = -4
    ERROR STOP 'PCHFE : NUMBER OF EVALUATION POINTS LESS THAN ONE'
  ELSE
    Ierr = 0
    Skip = .TRUE.
    !
    !  LOOP OVER INTERVALS.        (   INTERVAL INDEX IS  IL = IR-1  . )
    !                              ( INTERVAL IS X(IL)<=X<X(IR) . )
    jfirst = 1
    ir = 2
  END IF
  !
  !     SKIP OUT OF LOOP IF HAVE PROCESSED ALL EVALUATION POINTS.
  !
  100 CONTINUE
  IF( jfirst>Ne ) GOTO 400
  !
  !     LOCATE ALL POINTS IN INTERVAL.
  !
  DO j = jfirst, Ne
    IF( Xe(j)>=X(ir) ) GOTO 200
  END DO
  j = Ne + 1
  GOTO 300
  !
  !     HAVE LOCATED FIRST POINT BEYOND INTERVAL.
  !
  200 CONTINUE
  IF( ir==N ) j = Ne + 1
  !
  300  nj = j - jfirst
  !
  !     SKIP EVALUATION IF NO POINTS IN INTERVAL.
  !
  IF( nj/=0 ) THEN
    !
    !     EVALUATE CUBIC AT XE(I),  I = JFIRST (1) J-1 .
    !
    !       ----------------------------------------------------------------
    CALL CHFEV(X(ir-1),X(ir),F(1,ir-1),F(1,ir),D(1,ir-1),D(1,ir),nj,&
      Xe(jfirst),Fe(jfirst),next,ierc)
    !       ----------------------------------------------------------------
    IF( ierc<0 ) GOTO 600
    !
    IF( next(2)/=0 ) THEN
      !        IF(NEXT(2) > 0)  THEN
      !           IN THE CURRENT SET OF XE-POINTS, THERE ARE NEXT(2) TO THE
      !           RIGHT OF X(IR).
      !
      IF( ir<N ) GOTO 600
      !           IF(IR = N)  THEN
      !              THESE ARE ACTUALLY EXTRAPOLATION POINTS.
      !           ELSE
      !              WE SHOULD NEVER HAVE GOTTEN HERE.
      Ierr = Ierr + next(2)
    END IF
    !           END IF
    !        END IF
    !
    IF( next(1)/=0 ) THEN
      !        IF(NEXT(1) > 0)  THEN
      !           IN THE CURRENT SET OF XE-POINTS, THERE ARE NEXT(1) TO THE
      !           LEFT OF X(IR-1).
      !
      IF( ir>2 ) THEN
        !           ELSE
        !              XE IS NOT ORDERED RELATIVE TO X, SO MUST ADJUST
        !              EVALUATION INTERVAL.
        !
        !              FIRST, LOCATE FIRST POINT TO LEFT OF X(IR-1).
        DO i = jfirst, j - 1
          IF( Xe(i)<X(ir-1) ) GOTO 320
        END DO
        !              NOTE-- CANNOT DROP THROUGH HERE UNLESS THERE IS AN ERROR
        !                     IN CHFEV.
        GOTO 600
      ELSE
        !           IF(IR = 2)  THEN
        !              THESE ARE ACTUALLY EXTRAPOLATION POINTS.
        Ierr = Ierr + next(1)
        GOTO 350
      END IF
      !
      !              RESET J.  (THIS WILL BE THE NEW JFIRST.)
      320  j = i
      !
      !              NOW FIND OUT HOW FAR TO BACK UP IN THE X-ARRAY.
      DO i = 1, ir - 1
        IF( Xe(j)<X(i) ) EXIT
      END DO
      !              NB-- CAN NEVER DROP THROUGH HERE, SINCE XE(J)<X(IR-1).
      !
      !              AT THIS POINT, EITHER  XE(J) < X(1)
      !                 OR      X(I-1) <= XE(J) < X(I) .
      !              RESET IR, RECOGNIZING THAT IT WILL BE INCREMENTED BEFORE
      !              CYCLING.
      ir = MAX(1,i-1)
    END IF
    !           END IF
    !        END IF
    !
    350  jfirst = j
  END IF
  !
  !     END OF IR-LOOP.
  !
  ir = ir + 1
  IF( ir<=N ) GOTO 100
  !
  !  NORMAL RETURN.
  !
  400  RETURN
  !
  !     X-ARRAY NOT STRICTLY INCREASING.
  500  Ierr = -3
  ERROR STOP 'PCHFE : X-ARRAY NOT STRICTLY INCREASING'
  RETURN
  !
  !     ERROR RETURN FROM CHFEV.
  !   *** THIS CASE SHOULD NEVER OCCUR ***
  600  Ierr = -5
  ERROR STOP 'PCHFE : ERROR RETURN FROM CHFEV -- FATAL'
  !------------- LAST LINE OF PCHFE FOLLOWS ------------------------------
END SUBROUTINE PCHFE
