!** DQAWOE
PURE SUBROUTINE DQAWOE(F,A,B,Omega,Integr,Epsabs,Epsrel,Limit,Icall,Maxp1,Result,&
    Abserr,Neval,Ier,Last,Alist,Blist,Rlist,Elist,Iord,Nnlog,Momcom,Chebmo)
  !> Calculate an approximation to a given definite integral
  !  I = Integral of F(X)*W(X) over (A,B), where W(X) = COS(OMEGA*X) or
  !  W(X)=SIN(OMEGA*X), hopefully satisfying the following claim for accuracy
  !  ABS(I-RESULT)<=MAX(EPSABS,EPSREL*ABS(I)).
  !***
  ! **Library:**   SLATEC (QUADPACK)
  !***
  ! **Category:**  H2A2A1
  !***
  ! **Type:**      DOUBLE PRECISION (QAWOE-S, DQAWOE-D)
  !***
  ! **Keywords:**  AUTOMATIC INTEGRATOR, CLENSHAW-CURTIS METHOD,
  !             EXTRAPOLATION, GLOBALLY ADAPTIVE,
  !             INTEGRAND WITH OSCILLATORY COS OR SIN FACTOR, QUADPACK,
  !             QUADRATURE, SPECIAL-PURPOSE
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
  !        Computation of Oscillatory integrals
  !        Standard fortran subroutine
  !        Double precision version
  !
  !        PARAMETERS
  !         ON ENTRY
  !            F      - Double precision
  !                     Function subprogram defining the integrand
  !                     function F(X). The actual name for F needs to be
  !                     declared E X T E R N A L in the driver program.
  !
  !            A      - Double precision
  !                     Lower limit of integration
  !
  !            B      - Double precision
  !                     Upper limit of integration
  !
  !            OMEGA  - Double precision
  !                     Parameter in the integrand weight function
  !
  !            INTEGR - Integer
  !                     Indicates which of the WEIGHT functions is to be
  !                     used
  !                     INTEGR = 1      W(X) = COS(OMEGA*X)
  !                     INTEGR = 2      W(X) = SIN(OMEGA*X)
  !                     If INTEGR/=1 and INTEGR/=2, the routine
  !                     will end with IER = 6.
  !
  !            EPSABS - Double precision
  !                     Absolute accuracy requested
  !            EPSREL - Double precision
  !                     Relative accuracy requested
  !                     If  EPSABS<=0
  !                     and EPSREL<MAX(50*REL.MACH.ACC.,0.5D-28),
  !                     the routine will end with IER = 6.
  !
  !            LIMIT  - Integer
  !                     Gives an upper bound on the number of subdivisions
  !                     in the partition of (A,B), LIMIT>=1.
  !
  !            ICALL  - Integer
  !                     If DQAWOE is to be used only once, ICALL must
  !                     be set to 1.  Assume that during this call, the
  !                     Chebyshev moments (for CLENSHAW-CURTIS integration
  !                     of degree 24) have been computed for intervals of
  !                     lengths (ABS(B-A))*2**(-L), L=0,1,2,...MOMCOM-1.
  !                     If ICALL>1 this means that DQAWOE has been
  !                     called twice or more on intervals of the same
  !                     length ABS(B-A). The Chebyshev moments already
  !                     computed are then re-used in subsequent calls.
  !                     If ICALL<1, the routine will end with IER = 6.
  !
  !            MAXP1  - Integer
  !                     Gives an upper bound on the number of Chebyshev
  !                     moments which can be stored, i.e. for the
  !                     intervals of lengths ABS(B-A)*2**(-L),
  !                     L=0,1, ..., MAXP1-2, MAXP1>=1.
  !                     If MAXP1<1, the routine will end with IER = 6.
  !
  !         ON RETURN
  !            RESULT - Double precision
  !                     Approximation to the integral
  !
  !            ABSERR - Double precision
  !                     Estimate of the modulus of the absolute error,
  !                     which should equal or exceed ABS(I-RESULT)
  !
  !            NEVAL  - Integer
  !                     Number of integrand evaluations
  !
  !            IER    - Integer
  !                     IER = 0 Normal and reliable termination of the
  !                             routine. It is assumed that the
  !                             requested accuracy has been achieved.
  !                   - IER>0 Abnormal termination of the routine.
  !                             The estimates for integral and error are
  !                             less reliable. It is assumed that the
  !                             requested accuracy has not been achieved.
  !            ERROR MESSAGES
  !                     IER = 1 Maximum number of subdivisions allowed
  !                             has been achieved. One can allow more
  !                             subdivisions by increasing the value of
  !                             LIMIT (and taking according dimension
  !                             adjustments into account). However, if
  !                             this yields no improvement it is advised
  !                             to analyze the integrand, in order to
  !                             determine the integration difficulties.
  !                             If the position of a local difficulty can
  !                             be determined (e.g. SINGULARITY,
  !                             DISCONTINUITY within the interval) one
  !                             will probably gain from splitting up the
  !                             interval at this point and calling the
  !                             integrator on the subranges. If possible,
  !                             an appropriate special-purpose integrator
  !                             should be used which is designed for
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
  !                             It is presumed that the requested
  !                             tolerance cannot be achieved due to
  !                             roundoff in the extrapolation table,
  !                             and that the returned result is the
  !                             best which can be obtained.
  !                         = 5 The integral is probably divergent, or
  !                             slowly convergent. It must be noted that
  !                             divergence can occur with any other value
  !                             of IER>0.
  !                         = 6 The input is invalid, because
  !                             (EPSABS<=0 and
  !                              EPSREL<MAX(50*REL.MACH.ACC.,0.5D-28))
  !                             or (INTEGR/=1 and INTEGR/=2) or
  !                             ICALL<1 or MAXP1<1.
  !                             RESULT, ABSERR, NEVAL, LAST, RLIST(1),
  !                             ELIST(1), IORD(1) and NNLOG(1) are set
  !                             to ZERO. ALIST(1) and BLIST(1) are set
  !                             to A and B respectively.
  !
  !            LAST  -  Integer
  !                     On return, LAST equals the number of
  !                     subintervals produces in the subdivision
  !                     process, which determines the number of
  !                     significant elements actually in the
  !                     WORK ARRAYS.
  !            ALIST  - Double precision
  !                     Vector of dimension at least LIMIT, the first
  !                      LAST  elements of which are the left
  !                     end points of the subintervals in the partition
  !                     of the given integration range (A,B)
  !
  !            BLIST  - Double precision
  !                     Vector of dimension at least LIMIT, the first
  !                      LAST  elements of which are the right
  !                     end points of the subintervals in the partition
  !                     of the given integration range (A,B)
  !
  !            RLIST  - Double precision
  !                     Vector of dimension at least LIMIT, the first
  !                      LAST  elements of which are the integral
  !                     approximations on the subintervals
  !
  !            ELIST  - Double precision
  !                     Vector of dimension at least LIMIT, the first
  !                      LAST  elements of which are the moduli of the
  !                     absolute error estimates on the subintervals
  !
  !            IORD   - Integer
  !                     Vector of dimension at least LIMIT, the first K
  !                     elements of which are pointers to the error
  !                     estimates over the subintervals,
  !                     such that ELIST(IORD(1)), ...,
  !                     ELIST(IORD(K)) form a decreasing sequence, with
  !                     K = LAST if LAST<=(LIMIT/2+2), and
  !                     K = LIMIT+1-LAST otherwise.
  !
  !            NNLOG  - Integer
  !                     Vector of dimension at least LIMIT, containing the
  !                     subdivision levels of the subintervals, i.e.
  !                     IWORK(I) = L means that the subinterval
  !                     numbered I is of length ABS(B-A)*2**(1-L)
  !
  !         ON ENTRY AND RETURN
  !            MOMCOM - Integer
  !                     Indicating that the Chebyshev moments
  !                     have been computed for intervals of lengths
  !                     (ABS(B-A))*2**(-L), L=0,1,2, ..., MOMCOM-1,
  !                     MOMCOM<MAXP1
  !
  !            CHEBMO - Double precision
  !                     Array of dimension (MAXP1,25) containing the
  !                     Chebyshev moments
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  D1MACH, DQC25F, DQELG, DQPSRT

  !* REVISION HISTORY  (YYMMDD)
  !   800101  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  USE service, ONLY : tiny_dp, huge_dp, eps_dp
  !
  INTERFACE
    REAL(DP) PURE FUNCTION F(X)
      IMPORT DP
      REAL(DP), INTENT(IN) :: X
    END FUNCTION F
  END INTERFACE
  INTEGER, INTENT(IN) :: Icall, Integr, Limit, Maxp1
  INTEGER, INTENT(INOUT) :: Momcom
  INTEGER, INTENT(OUT) :: Ier, Last, Neval
  INTEGER, INTENT(OUT) :: Iord(Limit), Nnlog(Limit)
  REAL(DP), INTENT(IN) :: A, B, Epsabs, Epsrel, Omega
  REAL(DP), INTENT(OUT) :: Abserr, Result
  REAL(DP), INTENT(INOUT) :: Chebmo(Maxp1,25)
  REAL(DP), INTENT(OUT) :: Alist(Limit), Blist(Limit), Elist(Limit), Rlist(Limit)
  !
  INTEGER :: id, ierro, iroff1, iroff2, iroff3, jupbnd, k, ksgn, ktmin, maxerr, &
    nev, nres, nrmax, nrmom, numrl2
  REAL(DP) :: abseps, area, area1, area12, area2, a1, a2, b1, b2, correc, defab1, &
    defab2, defabs, domega, dres, epmach, erlarg, erlast, errbnd, errmax, error1, &
    erro12, error2, errsum, ertest, oflow, resabs, reseps, res3la(3), rlist2(52), &
    small, uflow, width
  LOGICAL :: extrap, noext, extall
  !
  !            THE DIMENSION OF RLIST2 IS DETERMINED BY  THE VALUE OF
  !            LIMEXP IN SUBROUTINE DQELG (RLIST2 SHOULD BE OF
  !            DIMENSION (LIMEXP+2) AT LEAST).
  !
  !            LIST OF MAJOR VARIABLES
  !            -----------------------
  !
  !           ALIST     - LIST OF LEFT END POINTS OF ALL SUBINTERVALS
  !                       CONSIDERED UP TO NOW
  !           BLIST     - LIST OF RIGHT END POINTS OF ALL SUBINTERVALS
  !                       CONSIDERED UP TO NOW
  !           RLIST(I)  - APPROXIMATION TO THE INTEGRAL OVER
  !                       (ALIST(I),BLIST(I))
  !           RLIST2    - ARRAY OF DIMENSION AT LEAST LIMEXP+2
  !                       CONTAINING THE PART OF THE EPSILON TABLE
  !                       WHICH IS STILL NEEDED FOR FURTHER COMPUTATIONS
  !           ELIST(I)  - ERROR ESTIMATE APPLYING TO RLIST(I)
  !           MAXERR    - POINTER TO THE INTERVAL WITH LARGEST
  !                       ERROR ESTIMATE
  !           ERRMAX    - ELIST(MAXERR)
  !           ERLAST    - ERROR ON THE INTERVAL CURRENTLY SUBDIVIDED
  !           AREA      - SUM OF THE INTEGRALS OVER THE SUBINTERVALS
  !           ERRSUM    - SUM OF THE ERRORS OVER THE SUBINTERVALS
  !           ERRBND    - REQUESTED ACCURACY MAX(EPSABS,EPSREL*
  !                       ABS(RESULT))
  !           *****1    - VARIABLE FOR THE LEFT SUBINTERVAL
  !           *****2    - VARIABLE FOR THE RIGHT SUBINTERVAL
  !           LAST      - INDEX FOR SUBDIVISION
  !           NRES      - NUMBER OF CALLS TO THE EXTRAPOLATION ROUTINE
  !           NUMRL2    - NUMBER OF ELEMENTS IN RLIST2. IF AN APPROPRIATE
  !                       APPROXIMATION TO THE COMPOUNDED INTEGRAL HAS
  !                       BEEN OBTAINED IT IS PUT IN RLIST2(NUMRL2) AFTER
  !                       NUMRL2 HAS BEEN INCREASED BY ONE
  !           SMALL     - LENGTH OF THE SMALLEST INTERVAL CONSIDERED
  !                       UP TO NOW, MULTIPLIED BY 1.5
  !           ERLARG    - SUM OF THE ERRORS OVER THE INTERVALS LARGER
  !                       THAN THE SMALLEST INTERVAL CONSIDERED UP TO NOW
  !           EXTRAP    - LOGICAL VARIABLE DENOTING THAT THE ROUTINE IS
  !                       ATTEMPTING TO PERFORM EXTRAPOLATION, I.E. BEFORE
  !                       SUBDIVIDING THE SMALLEST INTERVAL WE TRY TO
  !                       DECREASE THE VALUE OF ERLARG
  !           NOEXT     - LOGICAL VARIABLE DENOTING THAT EXTRAPOLATION
  !                       IS NO LONGER ALLOWED (TRUE  VALUE)
  !
  !            MACHINE DEPENDENT CONSTANTS
  !            ---------------------------
  !
  !           EPMACH IS THE LARGEST RELATIVE SPACING.
  !           UFLOW IS THE SMALLEST POSITIVE MAGNITUDE.
  !           OFLOW IS THE LARGEST POSITIVE MAGNITUDE.
  !
  !* FIRST EXECUTABLE STATEMENT  DQAWOE
  epmach = eps_dp
  !
  !         TEST ON VALIDITY OF PARAMETERS
  !         ------------------------------
  !
  Ier = 0
  Neval = 0
  Last = 0
  Result = 0._DP
  Abserr = 0._DP
  Alist(1) = A
  Blist(1) = B
  Rlist(1) = 0._DP
  Elist(1) = 0._DP
  Iord(1) = 0
  Nnlog(1) = 0
  IF( (Integr/=1 .AND. Integr/=2) .OR. &
    (Epsabs<=0._DP .AND. Epsrel<MAX(0.5E+02_DP*epmach,0.5E-28_DP)) .OR. &
    Icall<1 .OR. Maxp1<1 ) Ier = 6
  IF( Ier/=6 ) THEN
    !
    !           FIRST APPROXIMATION TO THE INTEGRAL
    !           -----------------------------------
    !
    domega = ABS(Omega)
    nrmom = 0
    IF( Icall<=1 ) Momcom = 0
    CALL DQC25F(F,A,B,domega,Integr,nrmom,Maxp1,0,Result,Abserr,Neval,&
      defabs,resabs,Momcom,Chebmo)
    !
    !           TEST ON ACCURACY.
    !
    dres = ABS(Result)
    errbnd = MAX(Epsabs,Epsrel*dres)
    Rlist(1) = Result
    Elist(1) = Abserr
    Iord(1) = 1
    IF( Abserr<=100._DP*epmach*defabs .AND. Abserr>errbnd ) Ier = 2
    IF( Limit==1 ) Ier = 1
    IF( Ier/=0 .OR. Abserr<=errbnd ) THEN
      IF( Integr==2 .AND. Omega<0._DP ) Result = -Result
      RETURN
    ELSE
      !
      !           INITIALIZATIONS
      !           ---------------
      !
      uflow = tiny_dp
      oflow = huge_dp
      errmax = Abserr
      maxerr = 1
      area = Result
      errsum = Abserr
      Abserr = oflow
      nrmax = 1
      extrap = .FALSE.
      noext = .FALSE.
      ierro = 0
      iroff1 = 0
      iroff2 = 0
      iroff3 = 0
      ktmin = 0
      small = ABS(B-A)*0.75_DP
      nres = 0
      numrl2 = 0
      extall = .FALSE.
      IF( 0.5_DP*ABS(B-A)*domega<=2._DP ) THEN
        numrl2 = 1
        extall = .TRUE.
        rlist2(1) = Result
      END IF
      IF( 0.25_DP*ABS(B-A)*domega<=2._DP ) extall = .TRUE.
      ksgn = -1
      IF( dres>=(1._DP-0.5E+02_DP*epmach)*defabs ) ksgn = 1
      !
      !           MAIN DO-LOOP
      !           ------------
      !
      DO Last = 2, Limit
        !
        !           BISECT THE SUBINTERVAL WITH THE NRMAX-TH LARGEST
        !           ERROR ESTIMATE.
        !
        nrmom = Nnlog(maxerr) + 1
        a1 = Alist(maxerr)
        b1 = 0.5_DP*(Alist(maxerr)+Blist(maxerr))
        a2 = b1
        b2 = Blist(maxerr)
        erlast = errmax
        CALL DQC25F(F,a1,b1,domega,Integr,nrmom,Maxp1,0,area1,error1,nev,&
          resabs,defab1,Momcom,Chebmo)
        Neval = Neval + nev
        CALL DQC25F(F,a2,b2,domega,Integr,nrmom,Maxp1,1,area2,error2,nev,&
          resabs,defab2,Momcom,Chebmo)
        Neval = Neval + nev
        !
        !           IMPROVE PREVIOUS APPROXIMATIONS TO INTEGRAL
        !           AND ERROR AND TEST FOR ACCURACY.
        !
        area12 = area1 + area2
        erro12 = error1 + error2
        errsum = errsum + erro12 - errmax
        area = area + area12 - Rlist(maxerr)
        IF( defab1/=error1 .AND. defab2/=error2 ) THEN
          IF( ABS(Rlist(maxerr)-area12)<=0.1D-04*ABS(area12) .AND. &
              erro12>=0.99_DP*errmax ) THEN
            IF( extrap ) iroff2 = iroff2 + 1
            IF( .NOT. extrap ) iroff1 = iroff1 + 1
          END IF
          IF( Last>10 .AND. erro12>errmax ) iroff3 = iroff3 + 1
        END IF
        Rlist(maxerr) = area1
        Rlist(Last) = area2
        Nnlog(maxerr) = nrmom
        Nnlog(Last) = nrmom
        errbnd = MAX(Epsabs,Epsrel*ABS(area))
        !
        !           TEST FOR ROUNDOFF ERROR AND EVENTUALLY SET ERROR FLAG.
        !
        IF( iroff1+iroff2>=10 .OR. iroff3>=20 ) Ier = 2
        IF( iroff2>=5 ) ierro = 3
        !
        !           SET ERROR FLAG IN THE CASE THAT THE NUMBER OF
        !           SUBINTERVALS EQUALS LIMIT.
        !
        IF( Last==Limit ) Ier = 1
        !
        !           SET ERROR FLAG IN THE CASE OF BAD INTEGRAND BEHAVIOUR
        !           AT A POINT OF THE INTEGRATION RANGE.
        !
        IF( MAX(ABS(a1),ABS(b2))<=(1._DP+100._DP*epmach)&
          *(ABS(a2)+0.1D+04*uflow) ) Ier = 4
        !
        !           APPEND THE NEWLY-CREATED INTERVALS TO THE LIST.
        !
        IF( error2>error1 ) THEN
          Alist(maxerr) = a2
          Alist(Last) = a1
          Blist(Last) = b1
          Rlist(maxerr) = area2
          Rlist(Last) = area1
          Elist(maxerr) = error2
          Elist(Last) = error1
        ELSE
          Alist(Last) = a2
          Blist(maxerr) = b1
          Blist(Last) = b2
          Elist(maxerr) = error1
          Elist(Last) = error2
        END IF
        !
        !           CALL SUBROUTINE DQPSRT TO MAINTAIN THE DESCENDING ORDERING
        !           IN THE LIST OF ERROR ESTIMATES AND SELECT THE SUBINTERVAL
        !           WITH NRMAX-TH LARGEST ERROR ESTIMATE (TO BISECTED NEXT).
        !
        CALL DQPSRT(Limit,Last,maxerr,errmax,Elist,Iord,nrmax)
        !- **JUMP OUT OF DO-LOOP
        IF( errsum<=errbnd ) GOTO 50
        IF( Ier/=0 ) EXIT
        IF( Last==2 .AND. extall ) THEN
          small = small*0.5_DP
          numrl2 = numrl2 + 1
          rlist2(numrl2) = area
        ELSE
          IF( noext ) CYCLE
          IF( extall ) THEN
            erlarg = erlarg - erlast
            IF( ABS(b1-a1)>small ) erlarg = erlarg + erro12
            IF( extrap ) GOTO 5
          END IF
          !
          !           TEST WHETHER THE INTERVAL TO BE BISECTED NEXT IS THE
          !           SMALLEST INTERVAL.
          !
          width = ABS(Blist(maxerr)-Alist(maxerr))
          IF( width>small ) CYCLE
          IF( extall ) THEN
            extrap = .TRUE.
            nrmax = 2
          ELSE
            !
            !           TEST WHETHER WE CAN START WITH THE EXTRAPOLATION PROCEDURE
            !           (WE DO THIS IF WE INTEGRATE OVER THE NEXT INTERVAL WITH
            !           USE OF A GAUSS-KRONROD RULE - SEE SUBROUTINE DQC25F).
            !
            small = small*0.5_DP
            IF( 0.25_DP*width*domega>2._DP ) CYCLE
            extall = .TRUE.
            GOTO 10
          END IF
          5 CONTINUE
          IF( ierro/=3 .AND. erlarg>ertest ) THEN
            !
            !           THE SMALLEST INTERVAL HAS THE LARGEST ERROR.
            !           BEFORE BISECTING DECREASE THE SUM OF THE ERRORS OVER
            !           THE LARGER INTERVALS (ERLARG) AND PERFORM EXTRAPOLATION.
            !
            jupbnd = Last
            IF( Last>(Limit/2+2) ) jupbnd = Limit + 3 - Last
            id = nrmax
            DO k = id, jupbnd
              maxerr = Iord(nrmax)
              errmax = Elist(maxerr)
              IF( ABS(Blist(maxerr)-Alist(maxerr))>small ) GOTO 20
              nrmax = nrmax + 1
            END DO
          END IF
          !
          !           PERFORM EXTRAPOLATION.
          !
          numrl2 = numrl2 + 1
          rlist2(numrl2) = area
          IF( numrl2>=3 ) THEN
            CALL DQELG(numrl2,rlist2,reseps,abseps,res3la,nres)
            ktmin = ktmin + 1
            IF( ktmin>5 .AND. Abserr<0.1D-02*errsum ) Ier = 5
            IF( abseps<Abserr ) THEN
              ktmin = 0
              Abserr = abseps
              Result = reseps
              correc = erlarg
              ertest = MAX(Epsabs,Epsrel*ABS(reseps))
              !- **JUMP OUT OF DO-LOOP
              IF( Abserr<=ertest ) EXIT
            END IF
            !
            !           PREPARE BISECTION OF THE SMALLEST INTERVAL.
            !
            IF( numrl2==1 ) noext = .TRUE.
            IF( Ier==5 ) EXIT
          END IF
          maxerr = Iord(1)
          errmax = Elist(maxerr)
          nrmax = 1
          extrap = .FALSE.
          small = small*0.5_DP
          erlarg = errsum
          CYCLE
        END IF
        10  ertest = errbnd
        erlarg = errsum
        20 CONTINUE
      END DO
      !
      !           SET THE FINAL RESULT.
      !           ---------------------
      !
      IF( Abserr/=oflow .AND. nres/=0 ) THEN
        IF( Ier+ierro/=0 ) THEN
          IF( ierro==3 ) Abserr = Abserr + correc
          IF( Ier==0 ) Ier = 3
          IF( Result==0._DP .OR. area==0._DP ) THEN
            IF( Abserr>errsum ) GOTO 50
            IF( area==0._DP ) THEN
              IF( Ier>2 ) Ier = Ier - 1
              IF( Integr==2 .AND. Omega<0._DP ) Result = -Result
              RETURN
            END IF
          ELSEIF( Abserr/ABS(Result)>errsum/ABS(area) ) THEN
            GOTO 50
          END IF
        END IF
        !
        !           TEST ON DIVERGENCE.
        !
        IF( ksgn/=(-1) .OR. MAX(ABS(Result),ABS(area))>defabs*0.1D-01 ) THEN
          IF( 0.1D-01>(Result/area) .OR. (Result/area)>0.1D+03 .OR. &
            errsum>=ABS(area) ) Ier = 6
        END IF
        IF( Ier>2 ) Ier = Ier - 1
        IF( Integr==2 .AND. Omega<0._DP ) Result = -Result
        RETURN
      END IF
    END IF
    !
    !           COMPUTE GLOBAL INTEGRAL SUM.
    !
    50  Result = 0._DP
    DO k = 1, Last
      Result = Result + Rlist(k)
    END DO
    Abserr = errsum
    IF( Ier>2 ) Ier = Ier - 1
    IF( Integr==2 .AND. Omega<0._DP ) Result = -Result
  END IF
  !
  RETURN
END SUBROUTINE DQAWOE