!** QAGI
PURE SUBROUTINE QAGI(F,Bound,Inf,Epsabs,Epsrel,Result,Abserr,Neval,Ier,Limit,&
    Lenw,Last,Iwork,Work)
  !> The routine calculates an approximation result to a given INTEGRAL
  !  I = Integral of F over (BOUND,+INFINITY)
  !  OR I = Integral of F over (-INFINITY,BOUND)
  !  OR I = Integral of F over (-INFINITY,+INFINITY)
  !  Hopefully satisfying following claim for accuracy
  !  ABS(I-RESULT)<=MAX(EPSABS,EPSREL*ABS(I)).
  !***
  ! **Library:**   SLATEC (QUADPACK)
  !***
  ! **Category:**  H2A3A1, H2A4A1
  !***
  ! **Type:**      SINGLE PRECISION (QAGI-S, DQAGI-D)
  !***
  ! **Keywords:**  AUTOMATIC INTEGRATOR, EXTRAPOLATION, GENERAL-PURPOSE,
  !             GLOBALLY ADAPTIVE, INFINITE INTERVALS, QUADPACK,
  !             QUADRATURE, TRANSFORMATION
  !***
  ! **Author:**  Piessens, Robert
  !             Applied Mathematics and Programming Division
  !             K. U. Leuven
  !           de Doncker, Elise
  !             Applied Mathematics and Programming Division
  !             K. U. Leuven
  !***
  ! **Description:**
  !
  !        Integration over infinite intervals
  !        Standard fortran subroutine
  !
  !        PARAMETERS
  !         ON ENTRY
  !            F      - Real
  !                     Function subprogram defining the integrand
  !                     function F(X). The actual name for F needs to be
  !                     declared E X T E R N A L in the driver program.
  !
  !            BOUND  - Real
  !                     Finite bound of integration range
  !                     (has no meaning if interval is doubly-infinite)
  !
  !            INF    - Integer
  !                     indicating the kind of integration range involved
  !                     INF = 1 corresponds to  (BOUND,+INFINITY),
  !                     INF = -1            to  (-INFINITY,BOUND),
  !                     INF = 2             to (-INFINITY,+INFINITY).
  !
  !            EPSABS - Real
  !                     Absolute accuracy requested
  !            EPSREL - Real
  !                     Relative accuracy requested
  !                     If  EPSABS<=0
  !                     and EPSREL<MAX(50*REL.MACH.ACC.,0.5D-28),
  !                     the routine will end with IER = 6.
  !
  !
  !         ON RETURN
  !            RESULT - Real
  !                     Approximation to the integral
  !
  !            ABSERR - Real
  !                     Estimate of the modulus of the absolute error,
  !                     which should equal or exceed ABS(I-RESULT)
  !
  !            NEVAL  - Integer
  !                     Number of integrand evaluations
  !
  !            IER    - Integer
  !                     IER = 0 normal and reliable termination of the
  !                             routine. It is assumed that the requested
  !                             accuracy has been achieved.
  !                   - IER>0 abnormal termination of the routine. The
  !                             estimates for result and error are less
  !                             reliable. It is assumed that the requested
  !                             accuracy has not been achieved.
  !            ERROR MESSAGES
  !                     IER = 1 Maximum number of subdivisions allowed
  !                             has been achieved. One can allow more
  !                             subdivisions by increasing the value of
  !                             LIMIT (and taking the according dimension
  !                             adjustments into account). However, if
  !                             this yields no improvement it is advised
  !                             to analyze the integrand in order to
  !                             determine the integration difficulties. If
  !                             the position of a local difficulty can be
  !                             determined (e.g. SINGULARITY,
  !                             DISCONTINUITY within the interval) one
  !                             will probably gain from splitting up the
  !                             interval at this point and calling the
  !                             integrator on the subranges. If possible,
  !                             an appropriate special-purpose integrator
  !                             should be used, which is designed for
  !                             handling the type of difficulty involved.
  !                         = 2 The occurrence of roundoff error is
  !                             detected, which prevents the requested
  !                             tolerance from being achieved.
  !                             The error may be under-estimated.
  !                         = 3 Extremely bad integrand behaviour occurs
  !                             at some points of the integration
  !                             interval.
  !                         = 4 The algorithm does not converge.
  !                             Roundoff error is detected in the
  !                             extrapolation table.
  !                             It is assumed that the requested tolerance
  !                             cannot be achieved, and that the returned
  !                             RESULT is the best which can be obtained.
  !                         = 5 The integral is probably divergent, or
  !                             slowly convergent. It must be noted that
  !                             divergence can occur with any other value
  !                             of IER.
  !                         = 6 The input is invalid, because
  !                             (EPSABS<=0 and
  !                              EPSREL<MAX(50*REL.MACH.ACC.,0.5D-28))
  !                              or LIMIT<1 or LENIW<LIMIT*4.
  !                             RESULT, ABSERR, NEVAL, LAST are set to
  !                             zero.  Except when LIMIT or LENIW is
  !                             invalid, IWORK(1), WORK(LIMIT*2+1) and
  !                             WORK(LIMIT*3+1) are set to ZERO, WORK(1)
  !                             is set to A and WORK(LIMIT+1) to B.
  !
  !         DIMENSIONING PARAMETERS
  !            LIMIT - Integer
  !                    Dimensioning parameter for IWORK
  !                    LIMIT determines the maximum number of subintervals
  !                    in the partition of the given integration interval
  !                    (A,B), LIMIT>=1.
  !                    If LIMIT<1, the routine will end with IER = 6.
  !
  !            LENW  - Integer
  !                    Dimensioning parameter for WORK
  !                    LENW must be at least LIMIT*4.
  !                    If LENW<LIMIT*4, the routine will end
  !                    with IER = 6.
  !
  !            LAST  - Integer
  !                    On return, LAST equals the number of subintervals
  !                    produced in the subdivision process, which
  !                    determines the number of significant elements
  !                    actually in the WORK ARRAYS.
  !
  !         WORK ARRAYS
  !            IWORK - Integer
  !                    Vector of dimension at least LIMIT, the first
  !                    K elements of which contain pointers
  !                    to the error estimates over the subintervals,
  !                    such that WORK(LIMIT*3+IWORK(1)),... ,
  !                    WORK(LIMIT*3+IWORK(K)) form a decreasing
  !                    sequence, with K = LAST if LAST<=(LIMIT/2+2), and
  !                    K = LIMIT+1-LAST otherwise
  !
  !            WORK  - Real
  !                    Vector of dimension at least LENW
  !                    on return
  !                    WORK(1), ..., WORK(LAST) contain the left
  !                     end points of the subintervals in the
  !                     partition of (A,B),
  !                    WORK(LIMIT+1), ..., WORK(LIMIT+LAST) Contain
  !                     the right end points,
  !                    WORK(LIMIT*2+1), ...,WORK(LIMIT*2+LAST) contain the
  !                     integral approximations over the subintervals,
  !                    WORK(LIMIT*3+1), ..., WORK(LIMIT*3)
  !                     contain the error estimates.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  QAGIE, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   800101  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)

  INTERFACE
    REAL(SP) PURE FUNCTION F(X)
      IMPORT SP
      REAL(SP), INTENT(IN) :: X
    END FUNCTION F
  END INTERFACE
  INTEGER, INTENT(IN) :: Inf, Lenw, Limit
  INTEGER, INTENT(OUT) :: Ier, Last, Neval, Iwork(Limit)
  REAL(SP), INTENT(IN) :: Bound, Epsabs, Epsrel
  REAL(SP), INTENT(OUT) :: Abserr, Result, Work(Lenw)
  !
  INTEGER :: lvl, l1, l2, l3
  !
  !         CHECK VALIDITY OF LIMIT AND LENW.
  !
  !* FIRST EXECUTABLE STATEMENT  QAGI
  Ier = 6
  Neval = 0
  Last = 0
  Result = 0._SP
  Abserr = 0._SP
  IF( Limit>=1 .AND. Lenw>=Limit*4 ) THEN
    !
    !         PREPARE CALL FOR QAGIE.
    !
    l1 = Limit + 1
    l2 = Limit + l1
    l3 = Limit + l2
    !
    CALL QAGIE(F,Bound,Inf,Epsabs,Epsrel,Limit,Result,Abserr,Neval,Ier,&
      Work(1),Work(l1),Work(l2),Work(l3),Iwork,Last)
    !
    !         CALL ERROR HANDLER IF NECESSARY.
    !
    lvl = 0
  END IF
  IF( Ier==6 ) lvl = 1
  IF( Ier/=0 ) ERROR STOP 'QAGI : ABNORMAL RETURN'
  !
END SUBROUTINE QAGI