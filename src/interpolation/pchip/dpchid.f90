!** DPCHID
REAL(DP) PURE FUNCTION DPCHID(N,X,F,D,Incfd,Ia,Ib)
  !> Evaluate the definite integral of a piecewise cubic Hermite function over
  !  an interval whose endpoints are data points.
  !***
  ! **Library:**   SLATEC (PCHIP)
  !***
  ! **Category:**  E3, H2A1B2
  !***
  ! **Type:**      DOUBLE PRECISION (PCHID-S, DPCHID-D)
  !***
  ! **Keywords:**  CUBIC HERMITE INTERPOLATION, NUMERICAL INTEGRATION, PCHIP,
  !             QUADRATURE
  !***
  ! **Author:**  Fritsch, F. N., (LLNL)
  !             Lawrence Livermore National Laboratory
  !             P.O. Box 808  (L-316)
  !             Livermore, CA  94550
  !             FTS 532-4275, (510) 422-4275
  !***
  ! **Description:**
  !
  !          DPCHID:  Piecewise Cubic Hermite Integrator, Data limits
  !
  !     Evaluates the definite integral of the cubic Hermite function
  !     defined by  N, X, F, D  over the interval [X(IA), X(IB)].
  !
  !     To provide compatibility with DPCHIM and DPCHIC, includes an
  !     increment between successive values of the F- and D-arrays.
  !
  ! ----------------------------------------------------------------------
  !
  !  Calling sequence:
  !
  !        PARAMETER  (INCFD = ...)
  !        INTEGER  N, IA, IB, IERR
  !        DOUBLE PRECISION  X(N), F(INCFD,N), D(INCFD,N)
  !        LOGICAL  SKIP
  !
  !        VALUE = DPCHID (N, X, F, D, INCFD, SKIP, IA, IB, IERR)
  !
  !   Parameters:
  !
  !     VALUE -- (output) value of the requested integral.
  !
  !     N -- (input) number of data points.  (Error return if N<2 .)
  !
  !     X -- (input) real*8 array of independent variable values.  The
  !           elements of X must be strictly increasing:
  !                X(I-1) < X(I),  I = 2(1)N.
  !           (Error return if not.)
  !
  !     F -- (input) real*8 array of function values.  F(1+(I-1)*INCFD) is
  !           the value corresponding to X(I).
  !
  !     D -- (input) real*8 array of derivative values.  D(1+(I-1)*INCFD)
  !           is the value corresponding to X(I).
  !
  !     INCFD -- (input) increment between successive values in F and D.
  !           (Error return if  INCFD<1 .)
  !
  !     SKIP -- (input/output) logical variable which should be set to
  !           .TRUE. if the user wishes to skip checks for validity of
  !           preceding parameters, or to .FALSE. otherwise.
  !           This will save time in case these checks have already
  !           been performed (say, in DPCHIM or DPCHIC).
  !           SKIP will be set to .TRUE. on return with IERR = 0 or -4.
  !
  !     IA,IB -- (input) indices in X-array for the limits of integration.
  !           both must be in the range [1,N].  (Error return if not.)
  !           No restrictions on their relative values.
  !
  !     IERR -- (output) error flag.
  !           Normal return:
  !              IERR = 0  (no errors).
  !           "Recoverable" errors:
  !              IERR = -1  if N<2 .
  !              IERR = -2  if INCFD<1 .
  !              IERR = -3  if the X-array is not strictly increasing.
  !              IERR = -4  if IA or IB is out of range.
  !                (VALUE will be zero in any of these cases.)
  !               NOTE:  The above errors are checked in the order listed,
  !                   and following arguments have **NOT** been validated.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   820723  DATE WRITTEN
  !   820804  Converted to SLATEC library version.
  !   870707  Corrected XERROR calls for d.p. name(s).
  !   870813  Minor cosmetic changes.
  !   890206  Corrected XERROR calls.
  !   890411  Added SAVE statements (Vers. 3.2).
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890703  Corrected category record.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   891006  Cosmetic changes to prologue.  (WRB)
  !   891006  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   930504  Corrected to set VALUE=0 when IERR/=0.  (FNF)

  !
  !  Programming notes:
  !  1. This routine uses a special formula that is valid only for
  !     integrals whose limits coincide with data values.  This is
  !     mathematically equivalent to, but much more efficient than,
  !     calls to DCHFIE.
  !**End
  !
  !  DECLARE ARGUMENTS.
  !
  INTEGER, INTENT(IN) :: N, Incfd, Ia, Ib
  REAL(DP), INTENT(IN) :: X(N), F(Incfd,N), D(Incfd,N)
  !
  !  DECLARE LOCAL VARIABLES.
  !
  INTEGER :: i, iup, low
  REAL(DP) :: h, summ, value
  LOGICAL, PARAMETER :: Skip = .FALSE.
  !* FIRST EXECUTABLE STATEMENT  DPCHID
  value = 0._DP
  !
  !  VALIDITY-CHECK ARGUMENTS.
  !
  IF( .NOT. (Skip) ) THEN
    !
    IF( N<2 ) THEN
      !
      !  ERROR RETURNS.
      !
      !     N<2 RETURN.
      ERROR STOP 'DPCHID : NUMBER OF DATA POINTS LESS THAN TWO'
    ELSEIF( Incfd<1 ) THEN
      !
      !     INCFD<1 RETURN.
      ERROR STOP 'DPCHID : INCREMENT LESS THAN ONE'
    ELSE
      DO i = 2, N
        IF( X(i)<=X(i-1) ) GOTO 200
      END DO
    END IF
  END IF
  !
  !  FUNCTION DEFINITION IS OK, GO ON.
  !
  IF( (Ia<1) .OR. (Ia>N) ) GOTO 300
  IF( (Ib<1) .OR. (Ib>N) ) GOTO 300
  !
  !  COMPUTE INTEGRAL VALUE.
  !
  IF( Ia/=Ib ) THEN
    low = MIN(Ia,Ib)
    iup = MAX(Ia,Ib) - 1
    summ = 0._DP
    DO i = low, iup
      h = X(i+1) - X(i)
      summ = summ + h*((F(1,i)+F(1,i+1))+(D(1,i)-D(1,i+1))*(h/6._DP))
    END DO
    value = 0.5_DP*summ
    IF( Ia>Ib ) value = -value
  END IF
  !
  !  NORMAL RETURN.
  !
  DPCHID = value
  RETURN
  !
  !     X-ARRAY NOT STRICTLY INCREASING.
  200 ERROR STOP 'DPCHID : X-ARRAY NOT STRICTLY INCREASING'
  !
  !     IA OR IB OUT OF RANGE RETURN.
  300 ERROR STOP 'DPCHID : IA OR IB OUT OF RANGE'
  !------------- LAST LINE OF DPCHID FOLLOWS -----------------------------
END FUNCTION DPCHID