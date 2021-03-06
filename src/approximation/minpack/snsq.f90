!** SNSQ
PURE SUBROUTINE SNSQ(FCN,JAC,Iopt,N,X,Fvec,Fjac,Ldfjac,Xtol,Maxfev,Ml,Mu,&
    Epsfcn,Diag,Mode,Factor,Nprint,Info,Nfev,Njev,R,Lr,Qtf,Wa1,Wa2,Wa3,Wa4)
  !> Find a zero of a system of a N nonlinear functions in N variables
  !  by a modification of the Powell hybrid method.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  F2A
  !***
  ! **Type:**      SINGLE PRECISION (SNSQ-S, DNSQ-D)
  !***
  ! **Keywords:**  NONLINEAR SQUARE SYSTEM, POWELL HYBRID METHOD, ZEROS
  !***
  ! **Author:**  Hiebert, K. L., (SNLA)
  !***
  ! **Description:**
  !
  ! 1. Purpose.
  !
  !       The purpose of SNSQ is to find a zero of a system of N non-
  !       linear functions in N variables by a modification of the Powell
  !       hybrid method.  The user must provide a subroutine which calcu-
  !       lates the functions.  The user has the option of either to
  !       provide a subroutine which calculates the Jacobian or to let the
  !       code calculate it by a forward-difference approximation.
  !       This code is the combination of the MINPACK codes (Argonne)
  !       HYBRD and HYBRDJ.
  !
  !
  ! 2. Subroutine and Type Statements.
  !
  !       SUBROUTINE SNSQ(FCN,JAC,IOPT,N,X,FVEC,FJAC,LDFJAC,XTOL,MAXFEV,
  !      *                 ML,MU,EPSFCN,DIAG,MODE,FACTOR,NPRINT,INFO,NFEV,
  !      *                 NJEV,R,LR,QTF,WA1,WA2,WA3,WA4)
  !       INTEGER IOPT,N,MAXFEV,ML,MU,MODE,NPRINT,INFO,NFEV,LDFJAC,NJEV,LR
  !       REAL XTOL,EPSFCN,FACTOR
  !       REAL X(N),FVEC(N),DIAG(N),FJAC(LDFJAC,N),R(LR),QTF(N),
  !      *     WA1(N),WA2(N),WA3(N),WA4(N)
  !       EXTERNAL FCN,JAC
  !
  !
  ! 3. Parameters.
  !
  !       Parameters designated as input parameters must be specified on
  !       entry to SNSQ and are not changed on exit, while parameters
  !       designated as output parameters need not be specified on entry
  !       and are set to appropriate values on exit from SNSQ.
  !
  !       FCN is the name of the user-supplied subroutine which calculates
  !         the functions.  FCN must be declared in an EXTERNAL statement
  !         in the user calling program, and should be written as follows.
  !
  !         SUBROUTINE FCN(N,X,FVEC,IFLAG)
  !         INTEGER N,IFLAG
  !         REAL X(N),FVEC(N)
  !         ----------
  !         Calculate the functions at X and
  !         return this vector in FVEC.
  !         ----------
  !         RETURN
  !         END
  !
  !         The value of IFLAG should not be changed by FCN unless the
  !         user wants to terminate execution of SNSQ.  In this case, set
  !         IFLAG to a negative integer.
  !
  !       JAC is the name of the user-supplied subroutine which calculates
  !         the Jacobian.  If IOPT=1, then JAC must be declared in an
  !         EXTERNAL statement in the user calling program, and should be
  !         written as follows.
  !
  !         SUBROUTINE JAC(N,X,FVEC,FJAC,LDFJAC,IFLAG)
  !         INTEGER N,LDFJAC,IFLAG
  !         REAL X(N),FVEC(N),FJAC(LDFJAC,N)
  !         ----------
  !         Calculate the Jacobian at X and return this
  !         matrix in FJAC.  FVEC contains the function
  !         values at X and should not be altered.
  !         ----------
  !         RETURN
  !         END
  !
  !         The value of IFLAG should not be changed by JAC unless the
  !         user wants to terminate execution of SNSQ.  In this case, set
  !         IFLAG to a negative integer.
  !
  !         If IOPT=2, JAC can be ignored (treat it as a dummy argument).
  !
  !       IOPT is an input variable which specifies how the Jacobian will
  !         be calculated.  If IOPT=1, then the user must supply the
  !         Jacobian through the subroutine JAC.  If IOPT=2, then the
  !         code will approximate the Jacobian by forward-differencing.
  !
  !       N is a positive integer input variable set to the number of
  !         functions and variables.
  !
  !       X is an array of length N.  On input, X must contain an initial
  !         estimate of the solution vector.  On output, X contains the
  !         final estimate of the solution vector.
  !
  !       FVEC is an output array of length N which contains the functions
  !         evaluated at the output X.
  !
  !       FJAC is an output N by N array which contains the orthogonal
  !         matrix Q produced by the QR factorization of the final approx-
  !         imate Jacobian.
  !
  !       LDFJAC is a positive integer input variable not less than N
  !         which specifies the leading dimension of the array FJAC.
  !
  !       XTOL is a non-negative input variable.  Termination occurs when
  !         the relative error between two consecutive iterates is at most
  !         XTOL.  Therefore, XTOL measures the relative error desired in
  !         the approximate solution.  Section 4 contains more details
  !         about XTOL.
  !
  !       MAXFEV is a positive integer input variable.  Termination occurs
  !         when the number of calls to FCN is at least MAXFEV by the end
  !         of an iteration.
  !
  !       ML is a non-negative integer input variable which specifies the
  !         number of subdiagonals within the band of the Jacobian matrix.
  !         If the Jacobian is not banded or IOPT=1, set ML to at
  !         least N - 1.
  !
  !       MU is a non-negative integer input variable which specifies the
  !         number of superdiagonals within the band of the Jacobian
  !         matrix.  If the Jacobian is not banded or IOPT=1, set MU to at
  !         least N - 1.
  !
  !       EPSFCN is an input variable used in determining a suitable step
  !         for the forward-difference approximation.  This approximation
  !         assumes that the relative errors in the functions are of the
  !         order of EPSFCN.  If EPSFCN is less than the machine preci-
  !         sion, it is assumed that the relative errors in the functions
  !         are of the order of the machine precision.  If IOPT=1, then
  !         EPSFCN can be ignored (treat it as a dummy argument).
  !
  !       DIAG is an array of length N.  If MODE = 1 (see below), DIAG is
  !         internally set.  If MODE = 2, DIAG must contain positive
  !         entries that serve as implicit (multiplicative) scale factors
  !         for the variables.
  !
  !       MODE is an integer input variable.  If MODE = 1, the variables
  !         will be scaled internally.  If MODE = 2, the scaling is speci-
  !         fied by the input DIAG.  Other values of MODE are equivalent
  !         to MODE = 1.
  !
  !       FACTOR is a positive input variable used in determining the ini-
  !         tial step bound.  This bound is set to the product of FACTOR
  !         and the Euclidean norm of DIAG*X if nonzero, or else to FACTOR
  !         itself.  In most cases FACTOR should lie in the interval
  !         (.1,100.).  100. is a generally recommended value.
  !
  !       NPRINT is an integer input variable that enables controlled
  !         printing of iterates if it is positive.  In this case, FCN is
  !         called with IFLAG = 0 at the beginning of the first iteration
  !         and every NPRINT iteration thereafter and immediately prior
  !         to return, with X and FVEC available for printing. Appropriate
  !         print statements must be added to FCN(see example).  If NPRINT
  !         is not positive, no special calls of FCN with IFLAG = 0 are
  !         made.
  !
  !       INFO is an integer output variable.  If the user has terminated
  !         execution, INFO is set to the (negative) value of IFLAG.  See
  !         description of FCN and JAC. Otherwise, INFO is set as follows.
  !
  !         INFO = 0  improper input parameters.
  !
  !         INFO = 1  relative error between two consecutive iterates is
  !                   at most XTOL.
  !
  !         INFO = 2  number of calls to FCN has reached or exceeded
  !                   MAXFEV.
  !
  !         INFO = 3  XTOL is too small.  No further improvement in the
  !                   approximate solution X is possible.
  !
  !         INFO = 4  iteration is not making good progress, as measured
  !                   by the improvement from the last five Jacobian eval-
  !                   uations.
  !
  !         INFO = 5  iteration is not making good progress, as measured
  !                   by the improvement from the last ten iterations.
  !
  !         Sections 4 and 5 contain more details about INFO.
  !
  !       NFEV is an integer output variable set to the number of calls to
  !         FCN.
  !
  !       NJEV is an integer output variable set to the number of calls to
  !         JAC. (If IOPT=2, then NJEV is set to zero.)
  !
  !       R is an output array of length LR which contains the upper
  !         triangular matrix produced by the QR factorization of the
  !         final approximate Jacobian, stored rowwise.
  !
  !       LR is a positive integer input variable not less than
  !         (N*(N+1))/2.
  !
  !       QTF is an output array of length N which contains the vector
  !         (Q TRANSPOSE)*FVEC.
  !
  !       WA1, WA2, WA3, and WA4 are work arrays of length N.
  !
  !
  ! 4. Successful Completion.
  !
  !       The accuracy of SNSQ is controlled by the convergence parameter
  !       XTOL.  This parameter is used in a test which makes a comparison
  !       between the approximation X and a solution XSOL.  SNSQ termi-
  !       nates when the test is satisfied.  If the convergence parameter
  !       is less than the machine precision (as defined by the function
  !       eps_sp), then SNSQ only attempts to satisfy the test
  !       defined by the machine precision.  Further progress is not
  !       usually possible.
  !
  !       The test assumes that the functions are reasonably well behaved,
  !       and, if the Jacobian is supplied by the user, that the functions
  !       and the Jacobian are coded consistently.  If these conditions
  !       are not satisfied, then SNSQ may incorrectly indicate conver-
  !       gence.  The coding of the Jacobian can be checked by the
  !       subroutine CHKDER. If the Jacobian is coded correctly or IOPT=2,
  !       then the validity of the answer can be checked, for example, by
  !       rerunning SNSQ with a tighter tolerance.
  !
  !       Convergence Test.  If ENORM(Z) denotes the Euclidean norm of a
  !         vector Z and D is the diagonal matrix whose entries are
  !         defined by the array DIAG, then this test attempts to guaran-
  !         tee that
  !
  !               ENORM(D*(X-XSOL)) <= XTOL*ENORM(D*XSOL).
  !
  !         If this condition is satisfied with XTOL = 10**(-K), then the
  !         larger components of D*X have K significant decimal digits and
  !         INFO is set to 1.  There is a danger that the smaller compo-
  !         nents of D*X may have large relative errors, but the fast rate
  !         of convergence of SNSQ usually avoids this possibility.
  !         Unless high precision solutions are required, the recommended
  !         value for XTOL is the square root of the machine precision.
  !
  !
  ! 5. Unsuccessful Completion.
  !
  !       Unsuccessful termination of SNSQ can be due to improper input
  !       parameters, arithmetic interrupts, an excessive number of func-
  !       tion evaluations, or lack of good progress.
  !
  !       Improper Input Parameters.  INFO is set to 0 if IOPT < 1,
  !         or IOPT > 2, or N <= 0, or LDFJAC < N, or
  !         XTOL < 0.E0, or MAXFEV <= 0, or ML < 0, or MU < 0,
  !         or FACTOR <= 0.E0, or LR < (N*(N+1))/2.
  !
  !       Arithmetic Interrupts.  If these interrupts occur in the FCN
  !         subroutine during an early stage of the computation, they may
  !         be caused by an unacceptable choice of X by SNSQ.  In this
  !         case, it may be possible to remedy the situation by rerunning
  !         SNSQ with a smaller value of FACTOR.
  !
  !       Excessive Number of Function Evaluations.  A reasonable value
  !         for MAXFEV is 100*(N+1) for IOPT=1 and 200*(N+1) for IOPT=2.
  !         If the number of calls to FCN reaches MAXFEV, then this
  !         indicates that the routine is converging very slowly as
  !         measured by the progress of FVEC, and INFO is set to 2.  This
  !         situation should be unusual because, as indicated below, lack
  !         of good progress is usually diagnosed earlier by SNSQ,
  !         causing termination with INFO = 4 or INFO = 5.
  !
  !       Lack of Good Progress.  SNSQ searches for a zero of the system
  !         by minimizing the sum of the squares of the functions.  In so
  !         doing, it can become trapped in a region where the minimum
  !         does not correspond to a zero of the system and, in this situ-
  !         ation, the iteration eventually fails to make good progress.
  !         In particular, this will happen if the system does not have a
  !         zero.  If the system has a zero, rerunning SNSQ from a dif-
  !         ferent starting point may be helpful.
  !
  !
  ! 6. Characteristics of the Algorithm.
  !
  !       SNSQ is a modification of the Powell hybrid method.  Two of its
  !       main characteristics involve the choice of the correction as a
  !       convex combination of the Newton and scaled gradient directions,
  !       and the updating of the Jacobian by the rank-1 method of Broy-
  !       den.  The choice of the correction guarantees (under reasonable
  !       conditions) global convergence for starting points far from the
  !       solution and a fast rate of convergence.  The Jacobian is
  !       calculated at the starting point by either the user-supplied
  !       subroutine or a forward-difference approximation, but it is not
  !       recalculated until the rank-1 method fails to produce satis-
  !       factory progress.
  !
  !       Timing.  The time required by SNSQ to solve a given problem
  !         depends on N, the behavior of the functions, the accuracy
  !         requested, and the starting point.  The number of arithmetic
  !         operations needed by SNSQ is about 11.5*(N**2) to process
  !         each evaluation of the functions (call to FCN) and 1.3*(N**3)
  !         to process each evaluation of the Jacobian (call to JAC,
  !         if IOPT = 1).  Unless FCN and JAC can be evaluated quickly,
  !         the timing of SNSQ will be strongly influenced by the time
  !         spent in FCN and JAC.
  !
  !       Storage.  SNSQ requires (3*N**2 + 17*N)/2 single precision
  !         storage locations, in addition to the storage required by the
  !         program.  There are no internally declared storage arrays.
  !
  !
  ! 7. Example.
  !
  !       The problem is to determine the values of X(1), X(2), ..., X(9),
  !       which solve the system of tridiagonal equations
  !
  !       (3-2*X(1))*X(1)           -2*X(2)                   = -1
  !               -X(I-1) + (3-2*X(I))*X(I)         -2*X(I+1) = -1, I=2-8
  !                                   -X(8) + (3-2*X(9))*X(9) = -1
  ! C     **********
  !
  !       PROGRAM TEST
  ! C
  ! C     Driver for SNSQ example.
  ! C
  !       INTEGER J,IOPT,N,MAXFEV,ML,MU,MODE,NPRINT,INFO,NFEV,LDFJAC,LR,
  !      *        NWRITE
  !       REAL XTOL,EPSFCN,FACTOR,FNORM
  !       REAL X(9),FVEC(9),DIAG(9),FJAC(9,9),R(45),QTF(9),
  !      *     WA1(9),WA2(9),WA3(9),WA4(9)
  !       REAL ENORM,R1MACH
  !       EXTERNAL FCN
  !       DATA NWRITE /6/
  ! C
  !       IOPT = 2
  !       N = 9
  ! C
  ! C     The following starting values provide a rough solution.
  ! C
  !       DO 10 J = 1, 9
  !          X(J) = -1.E0
  !    10    CONTINUE
  ! C
  !       LDFJAC = 9
  !       LR = 45
  ! C
  ! C     Set XTOL to the square root of the machine precision.
  ! C     Unless high precision solutions are required,
  ! C     this is the recommended setting.
  ! C
  !       XTOL = SQRT(eps_sp)
  ! C
  !       MAXFEV = 2000
  !       ML = 1
  !       MU = 1
  !       EPSFCN = 0.E0
  !       MODE = 2
  !       DO 20 J = 1, 9
  !          DIAG(J) = 1.E0
  !    20    CONTINUE
  !       FACTOR = 1.E2
  !       NPRINT = 0
  ! C
  !       CALL SNSQ(FCN,JAC,IOPT,N,X,FVEC,FJAC,LDFJAC,XTOL,MAXFEV,ML,MU,
  !      *           EPSFCN,DIAG,MODE,FACTOR,NPRINT,INFO,NFEV,NJEV,
  !      *           R,LR,QTF,WA1,WA2,WA3,WA4)
  !       FNORM = ENORM(N,FVEC)
  !       WRITE (NWRITE,1000) FNORM,NFEV,INFO,(X(J),J=1,N)
  !       STOP
  !  1000 FORMAT (5X,' FINAL L2 NORM OF THE RESIDUALS',E15.7 //
  !      *        5X,' NUMBER OF FUNCTION EVALUATIONS',I10 //
  !      *        5X,' EXIT PARAMETER',16X,I10 //
  !      *        5X,' FINAL APPROXIMATE SOLUTION' // (5X,3E15.7))
  !       END
  !       SUBROUTINE FCN(N,X,FVEC,IFLAG)
  !       INTEGER N,IFLAG
  !       REAL X(N),FVEC(N)
  !       INTEGER K
  !       REAL ONE,TEMP,TEMP1,TEMP2,THREE,TWO,ZERO
  !       DATA ZERO,ONE,TWO,THREE /0.E0,1.E0,2.E0,3.E0/
  ! C
  !       IF(IFLAG /= 0) GO TO 5
  ! C
  ! C     Insert print statements here when NPRINT is positive.
  ! C
  !       RETURN
  !     5 CONTINUE
  !       DO 10 K = 1, N
  !          TEMP = (THREE - TWO*X(K))*X(K)
  !          TEMP1 = ZERO
  !          IF(K /= 1) TEMP1 = X(K-1)
  !          TEMP2 = ZERO
  !          IF(K /= N) TEMP2 = X(K+1)
  !          FVEC(K) = TEMP - TEMP1 - TWO*TEMP2 + ONE
  !    10    CONTINUE
  !       RETURN
  !       END
  !
  !       Results obtained with different compilers or machines
  !       may be slightly different.
  !
  !       FINAL L2 NORM OF THE RESIDUALS  0.1192636E-07
  !
  !       NUMBER OF FUNCTION EVALUATIONS        14
  !
  !       EXIT PARAMETER                         1
  !
  !       FINAL APPROXIMATE SOLUTION
  !
  !       -0.5706545E+00 -0.6816283E+00 -0.7017325E+00
  !       -0.7042129E+00 -0.7013690E+00 -0.6918656E+00
  !       -0.6657920E+00 -0.5960342E+00 -0.4164121E+00
  !
  !***
  ! **References:**  M. J. D. Powell, A hybrid method for nonlinear equa-
  !                 tions. In Numerical Methods for Nonlinear Algebraic
  !                 Equations, P. Rabinowitz, Editor.  Gordon and Breach,
  !                 1988.
  !***
  ! **Routines called:**  DOGLEG, ENORM, FDJAC1, QFORM, QRFAC, R1MACH,
  !                    R1MPYQ, R1UPDT, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   800301  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE service, ONLY : eps_sp
  !
  INTERFACE
    PURE SUBROUTINE FCN(N,X,Fvec,iflag)
      IMPORT SP
      INTEGER, INTENT(IN) :: N, Iflag
      REAL(SP), INTENT(IN) :: X(N)
      REAL(SP), INTENT(OUT) :: Fvec(N)
    END SUBROUTINE FCN
    PURE SUBROUTINE JAC(N,X,Fvec,Fjac,Ldfjac,Iflag)
      IMPORT SP
      INTEGER, INTENT(IN) :: N, Ldfjac, Iflag
      REAL(SP), INTENT(IN) :: X(N), Fvec(N)
      REAL(SP), INTENT(OUT) :: Fjac(Ldfjac,N)
    END SUBROUTINE JAC
  END INTERFACE
  INTEGER, INTENT(IN) :: Iopt, N, Maxfev, Ml, Mu, Mode, Nprint, Ldfjac, Lr
  INTEGER, INTENT(OUT) :: Info, Nfev, Njev
  REAL(SP), INTENT(IN) :: Xtol, Epsfcn, Factor
  REAL(SP), INTENT(INOUT) :: X(N), Diag(N)
  REAL(SP), INTENT(OUT) :: Fvec(N), Fjac(Ldfjac,N), Qtf(N), R(Lr), Wa1(N), Wa2(N), &
    Wa3(N), Wa4(N)
  !
  INTEGER :: i, iflag, iter, j, jm1, l, ncfail, ncsuc, nslow1, nslow2
  INTEGER :: iwa(1)
  LOGICAL :: jeval, sing
  REAL(SP) :: actred, delta, epsmch, fnorm, fnorm1, pnorm, prered, ratio, summ, &
    temp, xnorm
  REAL(SP), PARAMETER :: p1 = 1.E-1_SP, p5 = 5.E-1_SP, p001 = 1.E-3_SP, &
    p0001 = 1.E-4_SP
  !
  !* FIRST EXECUTABLE STATEMENT  SNSQ
  epsmch = eps_sp
  !
  Info = 0
  iflag = 0
  Nfev = 0
  Njev = 0
  !
  !     CHECK THE INPUT PARAMETERS FOR ERRORS.
  !
  IF( Iopt<1 .OR. Iopt>2 .OR. N<=0 .OR. Xtol<0._SP .OR. Maxfev<=0 .OR. Ml<0 .OR. &
    Mu<0 .OR. Factor<=0._SP .OR. Ldfjac<N .OR. Lr<(N*(N+1))/2 ) GOTO 300
  IF( Mode==2 ) THEN
    DO j = 1, N
      IF( Diag(j)<=0._SP ) GOTO 300
    END DO
  END IF
  !
  !     EVALUATE THE FUNCTION AT THE STARTING POINT
  !     AND CALCULATE ITS NORM.
  !
  iflag = 1
  CALL FCN(N,X,Fvec,iflag)
  Nfev = 1
  IF( iflag<0 ) GOTO 300
  fnorm = NORM2(Fvec)
  !
  !     INITIALIZE ITERATION COUNTER AND MONITORS.
  !
  iter = 1
  ncsuc = 0
  ncfail = 0
  nslow1 = 0
  nslow2 = 0
  !
  !     BEGINNING OF THE OUTER LOOP.
  !
  100  jeval = .TRUE.
  !
  !        CALCULATE THE JACOBIAN MATRIX.
  !
  IF( Iopt==2 ) THEN
    !
    !        CODE APPROXIMATES THE JACOBIAN
    !
    iflag = 2
    CALL FDJAC1(FCN,N,X,Fvec,Fjac,Ldfjac,iflag,Ml,Mu,Epsfcn,Wa1,Wa2)
    Nfev = Nfev + MIN(Ml+Mu+1,N)
  ELSE
    !
    !        USER SUPPLIES JACOBIAN
    !
    CALL JAC(N,X,Fvec,Fjac,Ldfjac,iflag)
    Njev = Njev + 1
  END IF
  !
  IF( iflag<0 ) GOTO 300
  !
  !        COMPUTE THE QR FACTORIZATION OF THE JACOBIAN.
  !
  CALL QRFAC(N,N,Fjac,Ldfjac,.FALSE.,iwa,1,Wa1,Wa2,Wa3)
  !
  !        ON THE FIRST ITERATION AND IF MODE IS 1, SCALE ACCORDING
  !        TO THE NORMS OF THE COLUMNS OF THE INITIAL JACOBIAN.
  !
  IF( iter==1 ) THEN
    IF( Mode/=2 ) THEN
      DO j = 1, N
        Diag(j) = Wa2(j)
        IF( Wa2(j)==0._SP ) Diag(j) = 1._SP
      END DO
    END IF
    !
    !        ON THE FIRST ITERATION, CALCULATE THE NORM OF THE SCALED X
    !        AND INITIALIZE THE STEP BOUND DELTA.
    !
    DO j = 1, N
      Wa3(j) = Diag(j)*X(j)
    END DO
    xnorm = NORM2(Wa3)
    delta = Factor*xnorm
    IF( delta==0._SP ) delta = Factor
  END IF
  !
  !        FORM (Q TRANSPOSE)*FVEC AND STORE IN QTF.
  !
  DO i = 1, N
    Qtf(i) = Fvec(i)
  END DO
  DO j = 1, N
    IF( Fjac(j,j)/=0._SP ) THEN
      summ = 0._SP
      DO i = j, N
        summ = summ + Fjac(i,j)*Qtf(i)
      END DO
      temp = -summ/Fjac(j,j)
      DO i = j, N
        Qtf(i) = Qtf(i) + Fjac(i,j)*temp
      END DO
    END IF
  END DO
  !
  !        COPY THE TRIANGULAR FACTOR OF THE QR FACTORIZATION INTO R.
  !
  sing = .FALSE.
  DO j = 1, N
    l = j
    jm1 = j - 1
    IF( jm1>=1 ) THEN
      DO i = 1, jm1
        R(l) = Fjac(i,j)
        l = l + N - i
      END DO
    END IF
    R(l) = Wa1(j)
    IF( Wa1(j)==0._SP ) sing = .TRUE.
  END DO
  !
  !        ACCUMULATE THE ORTHOGONAL FACTOR IN FJAC.
  !
  CALL QFORM(N,N,Fjac,Ldfjac,Wa1)
  !
  !        RESCALE IF NECESSARY.
  !
  IF( Mode/=2 ) THEN
    DO j = 1, N
      Diag(j) = MAX(Diag(j),Wa2(j))
    END DO
  END IF
  !
  !        BEGINNING OF THE INNER LOOP.
  !
  !
  !           IF REQUESTED, CALL FCN TO ENABLE PRINTING OF ITERATES.
  !
  200 CONTINUE
  IF( Nprint>0 ) THEN
    iflag = 0
    IF( MOD(iter-1,Nprint)==0 ) CALL FCN(N,X,Fvec,iflag)
    IF( iflag<0 ) GOTO 300
  END IF
  !
  !           DETERMINE THE DIRECTION P.
  !
  CALL DOGLEG(N,R,Lr,Diag,Qtf,delta,Wa1,Wa2,Wa3)
  !
  !           STORE THE DIRECTION P AND X + P. CALCULATE THE NORM OF P.
  !
  DO j = 1, N
    Wa1(j) = -Wa1(j)
    Wa2(j) = X(j) + Wa1(j)
    Wa3(j) = Diag(j)*Wa1(j)
  END DO
  pnorm = NORM2(Wa3)
  !
  !           ON THE FIRST ITERATION, ADJUST THE INITIAL STEP BOUND.
  !
  IF( iter==1 ) delta = MIN(delta,pnorm)
  !
  !           EVALUATE THE FUNCTION AT X + P AND CALCULATE ITS NORM.
  !
  iflag = 1
  CALL FCN(N,Wa2,Wa4,iflag)
  Nfev = Nfev + 1
  IF( iflag>=0 ) THEN
    fnorm1 = NORM2(Wa4)
    !
    !           COMPUTE THE SCALED ACTUAL REDUCTION.
    !
    actred = -1._SP
    IF( fnorm1<fnorm ) actred = 1._SP - (fnorm1/fnorm)**2
    !
    !           COMPUTE THE SCALED PREDICTED REDUCTION.
    !
    l = 1
    DO i = 1, N
      summ = 0._SP
      DO j = i, N
        summ = summ + R(l)*Wa1(j)
        l = l + 1
      END DO
      Wa3(i) = Qtf(i) + summ
    END DO
    temp = NORM2(Wa3)
    prered = 0._SP
    IF( temp<fnorm ) prered = 1._SP - (temp/fnorm)**2
    !
    !           COMPUTE THE RATIO OF THE ACTUAL TO THE PREDICTED
    !           REDUCTION.
    !
    ratio = 0._SP
    IF( prered>0._SP ) ratio = actred/prered
    !
    !           UPDATE THE STEP BOUND.
    !
    IF( ratio>=p1 ) THEN
      ncfail = 0
      ncsuc = ncsuc + 1
      IF( ratio>=p5 .OR. ncsuc>1 ) delta = MAX(delta,pnorm/p5)
      IF( ABS(ratio-1._SP)<=p1 ) delta = pnorm/p5
    ELSE
      ncsuc = 0
      ncfail = ncfail + 1
      delta = p5*delta
    END IF
    !
    !           TEST FOR SUCCESSFUL ITERATION.
    !
    IF( ratio>=p0001 ) THEN
      !
      !           SUCCESSFUL ITERATION. UPDATE X, FVEC, AND THEIR NORMS.
      !
      DO j = 1, N
        X(j) = Wa2(j)
        Wa2(j) = Diag(j)*X(j)
        Fvec(j) = Wa4(j)
      END DO
      xnorm = NORM2(Wa2)
      fnorm = fnorm1
      iter = iter + 1
    END IF
    !
    !           DETERMINE THE PROGRESS OF THE ITERATION.
    !
    nslow1 = nslow1 + 1
    IF( actred>=p001 ) nslow1 = 0
    IF( jeval ) nslow2 = nslow2 + 1
    IF( actred>=p1 ) nslow2 = 0
    !
    !           TEST FOR CONVERGENCE.
    !
    IF( delta<=Xtol*xnorm .OR. fnorm==0._SP ) Info = 1
    IF( Info==0 ) THEN
      !
      !           TESTS FOR TERMINATION AND STRINGENT TOLERANCES.
      !
      IF( Nfev>=Maxfev ) Info = 2
      IF( p1*MAX(p1*delta,pnorm)<=epsmch*xnorm ) Info = 3
      IF( nslow2==5 ) Info = 4
      IF( nslow1==10 ) Info = 5
      IF( Info==0 ) THEN
        !
        !           CRITERION FOR RECALCULATING JACOBIAN
        !
        IF( ncfail==2 ) GOTO 100
        !
        !           CALCULATE THE RANK ONE MODIFICATION TO THE JACOBIAN
        !           AND UPDATE QTF IF NECESSARY.
        !
        DO j = 1, N
          summ = 0._SP
          DO i = 1, N
            summ = summ + Fjac(i,j)*Wa4(i)
          END DO
          Wa2(j) = (summ-Wa3(j))/pnorm
          Wa1(j) = Diag(j)*((Diag(j)*Wa1(j))/pnorm)
          IF( ratio>=p0001 ) Qtf(j) = summ
        END DO
        !
        !           COMPUTE THE QR FACTORIZATION OF THE UPDATED JACOBIAN.
        !
        CALL R1UPDT(N,N,R,Lr,Wa1,Wa2,Wa3,sing)
        CALL R1MPYQ(N,N,Fjac,Ldfjac,Wa2,Wa3)
        CALL R1MPYQ(1,N,Qtf,1,Wa2,Wa3)
        !
        !           END OF THE INNER LOOP.
        !
        jeval = .FALSE.
        !
        !        END OF THE OUTER LOOP.
        !
        GOTO 200
      END IF
    END IF
  END IF
  !
  !     TERMINATION, EITHER NORMAL OR USER IMPOSED.
  !
  300 CONTINUE
  IF( iflag<0 ) Info = iflag
  iflag = 0
  IF( Nprint>0 ) CALL FCN(N,X,Fvec,iflag)
  IF( Info<0 ) ERROR STOP 'SNSQ : EXECUTION TERMINATED BECAUSE USER SET IFLAG NEGATIVE.'
  IF( Info==0 ) ERROR STOP 'SNSQ : INVALID INPUT PARAMETER.'
  IF( Info==2 ) ERROR STOP 'SNSQ : TOO MANY FUNCTION EVALUATIONS.'
  IF( Info==3 ) ERROR STOP 'SNSQ : XTOL TOO SMALL. NO FURTHER IMPROVEMENT POSSIBLE.'
  IF( Info>4 ) ERROR STOP 'SNSQ : ITERATION NOT MAKING GOOD PROGRESS.'
  !
  !     LAST CARD OF SUBROUTINE SNSQ.
  !
END SUBROUTINE SNSQ