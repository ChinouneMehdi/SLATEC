!** PCHIA
REAL(SP) PURE FUNCTION PCHIA(N,X,F,D,Incfd,A,B)
  !> Evaluate the definite integral of a piecewise cubic
  !  Hermite function over an arbitrary interval.
  !***
  ! **Library:**   SLATEC (PCHIP)
  !***
  ! **Category:**  E3, H2A1B2
  !***
  ! **Type:**      SINGLE PRECISION (PCHIA-S, DPCHIA-D)
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
  !          PCHIA:  Piecewise Cubic Hermite Integrator, Arbitrary limits
  !
  !     Evaluates the definite integral of the cubic Hermite function
  !     defined by  N, X, F, D  over the interval [A, B].
  !
  !     To provide compatibility with PCHIM and PCHIC, includes an
  !     increment between successive values of the F- and D-arrays.
  !
  ! ----------------------------------------------------------------------
  !
  !  Calling sequence:
  !
  !        PARAMETER  (INCFD = ...)
  !        INTEGER  N, IERR
  !        REAL  X(N), F(INCFD,N), D(INCFD,N), A, B
  !        REAL  VALUE, PCHIA
  !        LOGICAL  SKIP
  !
  !        VALUE = PCHIA (N, X, F, D, INCFD, SKIP, A, B, IERR)
  !
  !   Parameters:
  !
  !     VALUE -- (output) value of the requested integral.
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
  !           SKIP will be set to .TRUE. on return with IERR>=0 .
  !
  !     A,B -- (input) the limits of integration.
  !           NOTE:  There is no requirement that [A,B] be contained in
  !                  [X(1),X(N)].  However, the resulting integral value
  !                  will be highly suspect, if not.
  !
  !     IERR -- (output) error flag.
  !           Normal return:
  !              IERR = 0  (no errors).
  !           Warning errors:
  !              IERR = 1  if  A  is outside the interval [X(1),X(N)].
  !              IERR = 2  if  B  is outside the interval [X(1),X(N)].
  !              IERR = 3  if both of the above are true.  (Note that this
  !                        means that either [A,B] contains data interval
  !                        or the intervals do not intersect at all.)
  !           "Recoverable" errors:
  !              IERR = -1  if N<2 .
  !              IERR = -2  if INCFD<1 .
  !              IERR = -3  if the X-array is not strictly increasing.
  !                (VALUE will be zero in any of these cases.)
  !               NOTE:  The above errors are checked in the order listed,
  !                   and following arguments have **NOT** been validated.
  !              IERR = -4  in case of an error return from PCHID (which
  !                         should never occur).
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  CHFIE, PCHID, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   820730  DATE WRITTEN
  !   820804  Converted to SLATEC library version.
  !   870707  Corrected double precision conversion instructions.
  !   870813  Minor cosmetic changes.
  !   890411  Added SAVE statements (Vers. 3.2).
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890703  Corrected category record.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   930503  Corrected to set VALUE=0 when IERR<0.  (FNF)
  !   930504  Changed CHFIV to CHFIE.  (FNF)

  !
  !  Programming notes:
  !  1. The error flag from PCHID is tested, because a logic flaw
  !     could conceivably result in IERD=-4, which should be reported.
  !**End
  !
  !  DECLARE ARGUMENTS.
  !
  INTEGER, INTENT(IN) :: N, Incfd
  REAL(SP), INTENT(IN) :: X(N), F(Incfd,N), D(Incfd,N), A, B
  !
  !  DECLARE LOCAL VARIABLES.
  !
  INTEGER :: i, ia, ib, il, ir
  REAL(SP) :: value, xa, xb
  LOGICAL, PARAMETER :: Skip = .FALSE.
  !* FIRST EXECUTABLE STATEMENT  PCHIA
  value = 0._SP
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
      ERROR STOP 'PCHIA : NUMBER OF DATA POINTS LESS THAN TWO'
    ELSEIF( Incfd<1 ) THEN
      !
      !     INCFD<1 RETURN.
      ERROR STOP 'PCHIA : INCREMENT LESS THAN ONE'
    ELSE
      DO i = 2, N
        IF( X(i)<=X(i-1) ) GOTO 200
      END DO
    END IF
  END IF
  !
  !  FUNCTION DEFINITION IS OK, GO ON.
  !
  !
  !  COMPUTE INTEGRAL VALUE.
  !
  IF( A/=B ) THEN
    xa = MIN(A,B)
    xb = MAX(A,B)
    IF( xb<=X(2) ) THEN
      !           INTERVAL IS TO LEFT OF X(2), SO USE FIRST CUBIC.
      !                   --------------------------------------
      value = CHFIE(X(1),X(2),F(1,1),F(1,2),D(1,1),D(1,2),A,B)
      !                   --------------------------------------
    ELSEIF( xa>=X(N-1) ) THEN
      !           INTERVAL IS TO RIGHT OF X(N-1), SO USE LAST CUBIC.
      !                   -----------------------------------------
      value = CHFIE(X(N-1),X(N),F(1,N-1),F(1,N),D(1,N-1),D(1,N),A,B)
      !                   -----------------------------------------
    ELSE
      !           'NORMAL' CASE -- XA<XB, XA<X(N-1), XB>X(2).
      !      ......LOCATE IA AND IB SUCH THAT
      !               X(IA-1)<XA<=X(IA)<=X(IB)<=XB<=X(IB+1)
      ia = 1
      DO i = 1, N - 1
        IF( xa>X(i) ) ia = i + 1
      END DO
      !             IA = 1 IMPLIES XA<X(1) .  OTHERWISE,
      !             IA IS LARGEST INDEX SUCH THAT X(IA-1)<XA,.
      !
      ib = N
      DO i = N, ia, -1
        IF( xb<X(i) ) ib = i - 1
      END DO
      !             IB = N IMPLIES XB>X(N) .  OTHERWISE,
      !             IB IS SMALLEST INDEX SUCH THAT XB<X(IB+1) .
      !
      !     ......COMPUTE THE INTEGRAL.
      IF( ib<ia ) THEN
        !              THIS MEANS IB = IA-1 AND
        !                 (A,B) IS A SUBSET OF (X(IB),X(IA)).
        !                      ------------------------------------------
        value = CHFIE(X(ib),X(ia),F(1,ib),F(1,ia),D(1,ib),D(1,ia),A,B)
        !                      ------------------------------------------
      ELSE
        !
        !              FIRST COMPUTE INTEGRAL OVER (X(IA),X(IB)).
        !                (Case (IB = IA) is taken care of by initialization
        !                 of VALUE to ZERO.)
        IF( ib>ia ) THEN
          !                         ---------------------------------------------
          value = PCHID(N,X,F,D,Incfd,ia,ib)
          !                         ---------------------------------------------
        END IF
        !
        !              THEN ADD ON INTEGRAL OVER (XA,X(IA)).
        IF( xa<X(ia) ) THEN
          il = MAX(1,ia-1)
          ir = il + 1
          !                                 -------------------------------------
          value = value + CHFIE(X(il),X(ir),F(1,il),F(1,ir),D(1,il),D(1,ir),xa,X(ia))
          !                                 -------------------------------------
        END IF
        !
        !              THEN ADD ON INTEGRAL OVER (X(IB),XB).
        IF( xb>X(ib) ) THEN
          ir = MIN(ib+1,N)
          il = ir - 1
          !                                 -------------------------------------
          value = value + CHFIE(X(il),X(ir),F(1,il),F(1,ir),D(1,il),D(1,ir),X(ib),xb)
          !                                 -------------------------------------
        END IF
        !
        !              FINALLY, ADJUST SIGN IF NECESSARY.
        IF( A>B ) value = -value
      END IF
    END IF
  END IF
  !
  !  NORMAL RETURN.
  !
  PCHIA = value
  RETURN
  !
  !     X-ARRAY NOT STRICTLY INCREASING.
  200 ERROR STOP 'PCHIA : X-ARRAY NOT STRICTLY INCREASING'
  !------------- LAST LINE OF PCHIA FOLLOWS ------------------------------
END FUNCTION PCHIA