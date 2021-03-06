!** DQAGE
PURE SUBROUTINE DQAGE(F,A,B,Epsabs,Epsrel,Key,Limit,Result,Abserr,Neval,Ier,&
    Alist,Blist,Rlist,Elist,Iord,Last)
  !> The routine calculates an approximation result to a given definite integral
  !  I = Integral of F over (A,B), hopefully satisfying following claim for accuracy
  !  ABS(I-RESLT)<=MAX(EPSABS,EPSREL*ABS(I)).
  !***
  ! **Library:**   SLATEC (QUADPACK)
  !***
  ! **Category:**  H2A1A1
  !***
  ! **Type:**      DOUBLE PRECISION (QAGE-S, DQAGE-D)
  !***
  ! **Keywords:**  AUTOMATIC INTEGRATOR, GAUSS-KRONROD RULES,
  !             GENERAL-PURPOSE, GLOBALLY ADAPTIVE, INTEGRAND EXAMINATOR,
  !             QUADPACK, QUADRATURE
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
  !        Computation of a definite integral
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
  !            EPSABS - Double precision
  !                     Absolute accuracy requested
  !            EPSREL - Double precision
  !                     Relative accuracy requested
  !                     If  EPSABS<=0
  !                     and EPSREL<MAX(50*REL.MACH.ACC.,0.5D-28),
  !                     the routine will end with IER = 6.
  !
  !            KEY    - Integer
  !                     Key for choice of local integration rule
  !                     A Gauss-Kronrod pair is used with
  !                          7 - 15 points if KEY<2,
  !                         10 - 21 points if KEY = 2,
  !                         15 - 31 points if KEY = 3,
  !                         20 - 41 points if KEY = 4,
  !                         25 - 51 points if KEY = 5,
  !                         30 - 61 points if KEY>5.
  !
  !            LIMIT  - Integer
  !                     Gives an upper bound on the number of subintervals
  !                     in the partition of (A,B), LIMIT>=1.
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
  !                             routine. It is assumed that the requested
  !                             accuracy has been achieved.
  !                     IER>0 Abnormal termination of the routine
  !                             The estimates for result and error are
  !                             less reliable. It is assumed that the
  !                             requested accuracy has not been achieved.
  !            ERROR MESSAGES
  !                     IER = 1 Maximum number of subdivisions allowed
  !                             has been achieved. One can allow more
  !                             subdivisions by increasing the value
  !                             of LIMIT.
  !                             However, if this yields no improvement it
  !                             is rather advised to analyze the integrand
  !                             in order to determine the integration
  !                             difficulties. If the position of a local
  !                             difficulty can be determined(e.g.
  !                             SINGULARITY, DISCONTINUITY within the
  !                             interval) one will probably gain from
  !                             splitting up the interval at this point
  !                             and calling the integrator on the
  !                             subranges. If possible, an appropriate
  !                             special-purpose integrator should be used
  !                             which is designed for handling the type of
  !                             difficulty involved.
  !                         = 2 The occurrence of roundoff error is
  !                             detected, which prevents the requested
  !                             tolerance from being achieved.
  !                         = 3 Extremely bad integrand behaviour occurs
  !                             at some points of the integration
  !                             interval.
  !                         = 6 The input is invalid, because
  !                             (EPSABS<=0 and
  !                              EPSREL<MAX(50*REL.MACH.ACC.,0.5D-28),
  !                             RESULT, ABSERR, NEVAL, LAST, RLIST(1) ,
  !                             ELIST(1) and IORD(1) are set to zero.
  !                             ALIST(1) and BLIST(1) are set to A and B
  !                             respectively.
  !
  !            ALIST   - Double precision
  !                      Vector of dimension at least LIMIT, the first
  !                       LAST  elements of which are the left
  !                      end points of the subintervals in the partition
  !                      of the given integration range (A,B)
  !
  !            BLIST   - Double precision
  !                      Vector of dimension at least LIMIT, the first
  !                       LAST  elements of which are the right
  !                      end points of the subintervals in the partition
  !                      of the given integration range (A,B)
  !
  !            RLIST   - Double precision
  !                      Vector of dimension at least LIMIT, the first
  !                       LAST  elements of which are the
  !                      integral approximations on the subintervals
  !
  !            ELIST   - Double precision
  !                      Vector of dimension at least LIMIT, the first
  !                       LAST  elements of which are the moduli of the
  !                      absolute error estimates on the subintervals
  !
  !            IORD    - Integer
  !                      Vector of dimension at least LIMIT, the first K
  !                      elements of which are pointers to the
  !                      error estimates over the subintervals,
  !                      such that ELIST(IORD(1)), ...,
  !                      ELIST(IORD(K)) form a decreasing sequence,
  !                      with K = LAST if LAST<=(LIMIT/2+2), and
  !                      K = LIMIT+1-LAST otherwise
  !
  !            LAST    - Integer
  !                      Number of subintervals actually produced in the
  !                      subdivision process
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  D1MACH, DQK15, DQK21, DQK31, DQK41, DQK51, DQK61,
  !                    DQPSRT

  !* REVISION HISTORY  (YYMMDD)
  !   800101  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  USE service, ONLY : tiny_dp, eps_dp
  !
  INTERFACE
    REAL(DP) PURE FUNCTION F(X)
      IMPORT DP
      REAL(DP), INTENT(IN) :: X
    END FUNCTION F
  END INTERFACE
  INTEGER, INTENT(IN) :: Key, Limit
  INTEGER, INTENT(OUT) :: Ier, Last, Neval
  INTEGER, INTENT(OUT) :: Iord(Limit)
  REAL(DP), INTENT(IN) :: A, B, Epsabs, Epsrel
  REAL(DP), INTENT(OUT) :: Abserr, Result
  REAL(DP), INTENT(OUT) :: Alist(Limit), Blist(Limit), Elist(Limit), Rlist(Limit)
  !
  INTEGER :: iroff1, iroff2, k, keyf, maxerr, nrmax
  REAL(DP) :: area, area1, area12, area2, a1, a2, b1, b2, defabs, defab1, defab2, &
    epmach, errbnd, errmax, error1, error2, erro12, errsum, resabs, uflow
  !
  !            LIST OF MAJOR VARIABLES
  !            -----------------------
  !
  !           ALIST     - LIST OF LEFT END POINTS OF ALL SUBINTERVALS
  !                       CONSIDERED UP TO NOW
  !           BLIST     - LIST OF RIGHT END POINTS OF ALL SUBINTERVALS
  !                       CONSIDERED UP TO NOW
  !           RLIST(I)  - APPROXIMATION TO THE INTEGRAL OVER
  !                      (ALIST(I),BLIST(I))
  !           ELIST(I)  - ERROR ESTIMATE APPLYING TO RLIST(I)
  !           MAXERR    - POINTER TO THE INTERVAL WITH LARGEST
  !                       ERROR ESTIMATE
  !           ERRMAX    - ELIST(MAXERR)
  !           AREA      - SUM OF THE INTEGRALS OVER THE SUBINTERVALS
  !           ERRSUM    - SUM OF THE ERRORS OVER THE SUBINTERVALS
  !           ERRBND    - REQUESTED ACCURACY MAX(EPSABS,EPSREL*
  !                       ABS(RESULT))
  !           *****1    - VARIABLE FOR THE LEFT SUBINTERVAL
  !           *****2    - VARIABLE FOR THE RIGHT SUBINTERVAL
  !           LAST      - INDEX FOR SUBDIVISION
  !
  !
  !           MACHINE DEPENDENT CONSTANTS
  !           ---------------------------
  !
  !           EPMACH  IS THE LARGEST RELATIVE SPACING.
  !           UFLOW  IS THE SMALLEST POSITIVE MAGNITUDE.
  !
  !* FIRST EXECUTABLE STATEMENT  DQAGE
  epmach = eps_dp
  uflow = tiny_dp
  !
  !           TEST ON VALIDITY OF PARAMETERS
  !           ------------------------------
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
  IF( Epsabs<=0._DP .AND. Epsrel<MAX(0.5E+02_DP*epmach,0.5E-28_DP) ) Ier = 6
  IF( Ier/=6 ) THEN
    !
    !           FIRST APPROXIMATION TO THE INTEGRAL
    !           -----------------------------------
    !
    keyf = Key
    IF( Key<=0 ) keyf = 1
    IF( Key>=7 ) keyf = 6
    Neval = 0
    IF( keyf==1 ) CALL DQK15(F,A,B,Result,Abserr,defabs,resabs)
    IF( keyf==2 ) CALL DQK21(F,A,B,Result,Abserr,defabs,resabs)
    IF( keyf==3 ) CALL DQK31(F,A,B,Result,Abserr,defabs,resabs)
    IF( keyf==4 ) CALL DQK41(F,A,B,Result,Abserr,defabs,resabs)
    IF( keyf==5 ) CALL DQK51(F,A,B,Result,Abserr,defabs,resabs)
    IF( keyf==6 ) CALL DQK61(F,A,B,Result,Abserr,defabs,resabs)
    Last = 1
    Rlist(1) = Result
    Elist(1) = Abserr
    Iord(1) = 1
    !
    !           TEST ON ACCURACY.
    !
    errbnd = MAX(Epsabs,Epsrel*ABS(Result))
    IF( Abserr<=0.5E+02_DP*epmach*defabs .AND. Abserr>errbnd ) Ier = 2
    IF( Limit==1 ) Ier = 1
    IF( .NOT. (Ier/=0 .OR. (Abserr<=errbnd .AND. Abserr/=resabs) .OR. &
        Abserr==0._DP) ) THEN
      !
      !           INITIALIZATION
      !           --------------
      !
      !
      errmax = Abserr
      maxerr = 1
      area = Result
      errsum = Abserr
      nrmax = 1
      iroff1 = 0
      iroff2 = 0
      !
      !           MAIN DO-LOOP
      !           ------------
      !
      DO Last = 2, Limit
        !
        !           BISECT THE SUBINTERVAL WITH THE LARGEST ERROR ESTIMATE.
        !
        a1 = Alist(maxerr)
        b1 = 0.5_DP*(Alist(maxerr)+Blist(maxerr))
        a2 = b1
        b2 = Blist(maxerr)
        IF( keyf==1 ) CALL DQK15(F,a1,b1,area1,error1,resabs,defab1)
        IF( keyf==2 ) CALL DQK21(F,a1,b1,area1,error1,resabs,defab1)
        IF( keyf==3 ) CALL DQK31(F,a1,b1,area1,error1,resabs,defab1)
        IF( keyf==4 ) CALL DQK41(F,a1,b1,area1,error1,resabs,defab1)
        IF( keyf==5 ) CALL DQK51(F,a1,b1,area1,error1,resabs,defab1)
        IF( keyf==6 ) CALL DQK61(F,a1,b1,area1,error1,resabs,defab1)
        IF( keyf==1 ) CALL DQK15(F,a2,b2,area2,error2,resabs,defab2)
        IF( keyf==2 ) CALL DQK21(F,a2,b2,area2,error2,resabs,defab2)
        IF( keyf==3 ) CALL DQK31(F,a2,b2,area2,error2,resabs,defab2)
        IF( keyf==4 ) CALL DQK41(F,a2,b2,area2,error2,resabs,defab2)
        IF( keyf==5 ) CALL DQK51(F,a2,b2,area2,error2,resabs,defab2)
        IF( keyf==6 ) CALL DQK61(F,a2,b2,area2,error2,resabs,defab2)
        !
        !           IMPROVE PREVIOUS APPROXIMATIONS TO INTEGRAL
        !           AND ERROR AND TEST FOR ACCURACY.
        !
        Neval = Neval + 1
        area12 = area1 + area2
        erro12 = error1 + error2
        errsum = errsum + erro12 - errmax
        area = area + area12 - Rlist(maxerr)
        IF( defab1/=error1 .AND. defab2/=error2 ) THEN
          IF( ABS(Rlist(maxerr)-area12)<=0.1D-04*ABS(area12) .AND. &
            erro12>=0.99_DP*errmax ) iroff1 = iroff1 + 1
          IF( Last>10 .AND. erro12>errmax ) iroff2 = iroff2 + 1
        END IF
        Rlist(maxerr) = area1
        Rlist(Last) = area2
        errbnd = MAX(Epsabs,Epsrel*ABS(area))
        IF( errsum>errbnd ) THEN
          !
          !           TEST FOR ROUNDOFF ERROR AND EVENTUALLY SET ERROR FLAG.
          !
          IF( iroff1>=6 .OR. iroff2>=20 ) Ier = 2
          !
          !           SET ERROR FLAG IN THE CASE THAT THE NUMBER OF SUBINTERVALS
          !           EQUALS LIMIT.
          !
          IF( Last==Limit ) Ier = 1
          !
          !           SET ERROR FLAG IN THE CASE OF BAD INTEGRAND BEHAVIOUR
          !           AT A POINT OF THE INTEGRATION RANGE.
          !
          IF( MAX(ABS(a1),ABS(b2))<=(1._DP+100._DP*epmach)&
            *(ABS(a2)+0.1D+04*uflow) ) Ier = 3
        END IF
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
        !           WITH THE LARGEST ERROR ESTIMATE (TO BE BISECTED NEXT).
        !
        CALL DQPSRT(Limit,Last,maxerr,errmax,Elist,Iord,nrmax)
        !- **JUMP OUT OF DO-LOOP
        IF( Ier/=0 .OR. errsum<=errbnd ) EXIT
      END DO
      !
      !           COMPUTE FINAL RESULT.
      !           ---------------------
      !
      Result = 0._DP
      DO k = 1, Last
        Result = Result + Rlist(k)
      END DO
      Abserr = errsum
    END IF
    IF( keyf/=1 ) Neval = (10*keyf+1)*(2*Neval+1)
    IF( keyf==1 ) Neval = 30*Neval + 15
  END IF
  !
END SUBROUTINE DQAGE