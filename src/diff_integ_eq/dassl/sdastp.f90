!** SDASTP
PURE SUBROUTINE SDASTP(X,Y,Yprime,Neq,RES,JAC,H,Wt,Jstart,Idid,Phi,&
    Delta,E,Wm,Iwm,Alpha,Beta,Gama,Psi,Sigma,Cj,Cjold,Hold,&
    S,Hmin,Uround,Iphase,Jcalc,K,Kold,Ns,Nonneg,Ntemp)
  !> Perform one step of the SDASSL integration.
  !***
  ! **Library:**   SLATEC (DASSL)
  !***
  ! **Type:**      SINGLE PRECISION (SDASTP-S, DDASTP-D)
  !***
  ! **Author:**  Petzold, Linda R., (LLNL)
  !***
  ! **Description:**
  !-----------------------------------------------------------------------
  !     SDASTP SOLVES A SYSTEM OF DIFFERENTIAL/
  !     ALGEBRAIC EQUATIONS OF THE FORM
  !     G(X,Y,YPRIME) = 0,  FOR ONE STEP (NORMALLY
  !     FROM X TO X+H).
  !
  !     THE METHODS USED ARE MODIFIED DIVIDED
  !     DIFFERENCE,FIXED LEADING COEFFICIENT
  !     FORMS OF BACKWARD DIFFERENTIATION
  !     FORMULAS. THE CODE ADJUSTS THE STEPSIZE
  !     AND ORDER TO CONTROL THE LOCAL ERROR PER
  !     STEP.
  !
  !
  !     THE PARAMETERS REPRESENT
  !     X  --        INDEPENDENT VARIABLE
  !     Y  --        SOLUTION VECTOR AT X
  !     YPRIME --    DERIVATIVE OF SOLUTION VECTOR
  !                  AFTER SUCCESSFUL STEP
  !     NEQ --       NUMBER OF EQUATIONS TO BE INTEGRATED
  !     RES --       EXTERNAL USER-SUPPLIED SUBROUTINE
  !                  TO EVALUATE THE RESIDUAL.  THE CALL IS
  !                  CALL RES(X,Y,YPRIME,DELTA,IRES,RPAR,IPAR)
  !                  X,Y,YPRIME ARE INPUT.  DELTA IS OUTPUT.
  !                  ON INPUT, IRES=0.  RES SHOULD ALTER IRES ONLY
  !                  IF IT ENCOUNTERS AN ILLEGAL VALUE OF Y OR A
  !                  STOP CONDITION.  SET IRES=-1 IF AN INPUT VALUE
  !                  OF Y IS ILLEGAL, AND SDASTP WILL TRY TO SOLVE
  !                  THE PROBLEM WITHOUT GETTING IRES = -1.  IF
  !                  IRES=-2, SDASTP RETURNS CONTROL TO THE CALLING
  !                  PROGRAM WITH IDID = -11.
  !     JAC --       EXTERNAL USER-SUPPLIED ROUTINE TO EVALUATE
  !                  THE ITERATION MATRIX (THIS IS OPTIONAL)
  !                  THE CALL IS OF THE FORM
  !                  CALL JAC(X,Y,YPRIME,PD,CJ,RPAR,IPAR)
  !                  PD IS THE MATRIX OF PARTIAL DERIVATIVES,
  !                  PD=DG/DY+CJ*DG/DYPRIME
  !     H --         APPROPRIATE STEP SIZE FOR NEXT STEP.
  !                  NORMALLY DETERMINED BY THE CODE
  !     WT --        VECTOR OF WEIGHTS FOR ERROR CRITERION.
  !     JSTART --    INTEGER VARIABLE SET 0 FOR
  !                  FIRST STEP, 1 OTHERWISE.
  !     IDID --      COMPLETION CODE WITH THE FOLLOWING MEANINGS:
  !                  IDID= 1 -- THE STEP WAS COMPLETED SUCCESSFULLY
  !                  IDID=-6 -- THE ERROR TEST FAILED REPEATEDLY
  !                  IDID=-7 -- THE CORRECTOR COULD NOT CONVERGE
  !                  IDID=-8 -- THE ITERATION MATRIX IS SINGULAR
  !                  IDID=-9 -- THE CORRECTOR COULD NOT CONVERGE.
  !                             THERE WERE REPEATED ERROR TEST
  !                             FAILURES ON THIS STEP.
  !                  IDID=-10-- THE CORRECTOR COULD NOT CONVERGE
  !                             BECAUSE IRES WAS EQUAL TO MINUS ONE
  !                  IDID=-11-- IRES EQUAL TO -2 WAS ENCOUNTERED,
  !                             AND CONTROL IS BEING RETURNED TO
  !                             THE CALLING PROGRAM
  !     RPAR,IPAR -- REAL AND INTEGER PARAMETER ARRAYS THAT
  !                  ARE USED FOR COMMUNICATION BETWEEN THE
  !                  CALLING PROGRAM AND EXTERNAL USER ROUTINES
  !                  THEY ARE NOT ALTERED BY SDASTP
  !     PHI --       ARRAY OF DIVIDED DIFFERENCES USED BY
  !                  SDASTP. THE LENGTH IS NEQ*(K+1),WHERE
  !                  K IS THE MAXIMUM ORDER
  !     DELTA,E --   WORK VECTORS FOR SDASTP OF LENGTH NEQ
  !     WM,IWM --    REAL AND INTEGER ARRAYS STORING
  !                  MATRIX INFORMATION SUCH AS THE MATRIX
  !                  OF PARTIAL DERIVATIVES,PERMUTATION
  !                  VECTOR, AND VARIOUS OTHER INFORMATION.
  !
  !     THE OTHER PARAMETERS ARE INFORMATION
  !     WHICH IS NEEDED INTERNALLY BY SDASTP TO
  !     CONTINUE FROM STEP TO STEP.
  !
  !-----------------------------------------------------------------------
  !***
  ! **Routines called:**  SDAJAC, SDANRM, SDASLV, SDATRP

  !* REVISION HISTORY  (YYMMDD)
  !   830315  DATE WRITTEN
  !   901009  Finished conversion to SLATEC 4.0 format (F.N.Fritsch)
  !   901019  Merged changes made by C. Ulrich with SLATEC 4.0 format.
  !   901026  Added explicit declarations for all variables and minor
  !           cosmetic changes to prologue.  (FNF)
  !
  INTERFACE
    PURE SUBROUTINE RES(T,Y,Yprime,Delta,Ires)
      IMPORT SP
      INTEGER, INTENT(INOUT) :: Ires
      REAL(SP), INTENT(IN) :: T, Y(:), Yprime(:)
      REAL(SP), INTENT(OUT) :: Delta(:)
    END SUBROUTINE RES
    PURE SUBROUTINE JAC(T,Y,Yprime,Pd,Cj)
      IMPORT SP
      REAL(SP), INTENT(IN) :: T, Cj, Y(:), Yprime(:)
      REAL(SP), INTENT(OUT) :: Pd(:,:)
    END SUBROUTINE JAC
  END INTERFACE
  INTEGER, INTENT(IN) :: Neq, Nonneg, Ntemp
  INTEGER, INTENT(INOUT) :: Jstart, Iphase, Jcalc, K, Kold, Ns
  INTEGER, INTENT(OUT) :: Idid
  INTEGER, INTENT(INOUT) :: Iwm(:)
  REAL(SP), INTENT(IN) :: Hmin, Uround
  REAL(SP), INTENT(INOUT) :: X, H, Cj, Cjold, Hold, S
  REAL(SP), INTENT(IN) :: Wt(:)
  REAL(SP), INTENT(INOUT) :: Alpha(:), Beta(:), Gama(:), Sigma(:), Phi(Neq,*), &
    Psi(:), Wm(:)
  REAL(SP), INTENT(OUT) :: Y(Neq), Yprime(Neq), Delta(:), E(:)
  !
  INTEGER :: i, ier, ires, j, j1, kdiff, km1, knew, kp1, kp2, m, ncf, nef, nsf, nsp1
  REAL(SP) :: alpha0, alphas, cjlast, ck, delnrm, enorm, erk, erkm1, &
    erkm2, erkp1, err, est, hnew, oldnrm, pnorm, r, rate, &
    temp1, temp2, terk, terkm1, terkm2, terkp1, xold
  LOGICAL :: convgd
  !
  INTEGER, PARAMETER :: LMXORD = 3
  INTEGER, PARAMETER :: LNST = 11
  INTEGER, PARAMETER :: LNRE = 12
  INTEGER, PARAMETER :: LNJE = 13
  INTEGER, PARAMETER :: LETF = 14
  INTEGER, PARAMETER :: LCTF = 15
  !
  INTEGER, PARAMETER :: maxit = 4
  REAL(SP), PARAMETER :: xrate = 0.25_SP
  !-----------------------------------------------------------------------
  !     BLOCK 1.
  !     INITIALIZE. ON THE FIRST CALL,SET
  !     THE ORDER TO 1 AND INITIALIZE
  !     OTHER VARIABLES.
  !-----------------------------------------------------------------------
  !
  !     INITIALIZATIONS FOR ALL CALLS
  !* FIRST EXECUTABLE STATEMENT  SDASTP
  Idid = 1
  xold = X
  ncf = 0
  nsf = 0
  nef = 0
  IF( Jstart==0 ) THEN
    !
    !     IF THIS IS THE FIRST STEP,PERFORM
    !     OTHER INITIALIZATIONS
    Iwm(LETF) = 0
    Iwm(LCTF) = 0
    K = 1
    Kold = 0
    Hold = 0._SP
    Jstart = 1
    Psi(1) = H
    Cjold = 1._SP/H
    Cj = Cjold
    S = 100._SP
    Jcalc = -1
    delnrm = 1._SP
    Iphase = 0
    Ns = 0
  END IF
  !
  !
  !
  !
  !
  !-----------------------------------------------------------------------
  !     BLOCK 2
  !     COMPUTE COEFFICIENTS OF FORMULAS FOR
  !     THIS STEP.
  !-----------------------------------------------------------------------
  100  kp1 = K + 1
  kp2 = K + 2
  km1 = K - 1
  xold = X
  IF( H/=Hold .OR. K/=Kold ) Ns = 0
  Ns = MIN(Ns+1,Kold+2)
  nsp1 = Ns + 1
  IF( kp1>=Ns ) THEN
    !
    Beta(1) = 1._SP
    Alpha(1) = 1._SP
    temp1 = H
    Gama(1) = 0._SP
    Sigma(1) = 1._SP
    DO i = 2, kp1
      temp2 = Psi(i-1)
      Psi(i-1) = temp1
      Beta(i) = Beta(i-1)*Psi(i-1)/temp2
      temp1 = temp2 + H
      Alpha(i) = H/temp1
      Sigma(i) = (i-1)*Sigma(i-1)*Alpha(i)
      Gama(i) = Gama(i-1) + Alpha(i-1)/H
    END DO
    Psi(kp1) = temp1
  END IF
  !
  !     COMPUTE ALPHAS, ALPHA0
  alphas = 0._SP
  alpha0 = 0._SP
  DO i = 1, K
    alphas = alphas - 1._SP/i
    alpha0 = alpha0 - Alpha(i)
  END DO
  !
  !     COMPUTE LEADING COEFFICIENT CJ
  cjlast = Cj
  Cj = -alphas/H
  !
  !     COMPUTE VARIABLE STEPSIZE ERROR COEFFICIENT CK
  ck = ABS(Alpha(kp1)+alphas-alpha0)
  ck = MAX(ck,Alpha(kp1))
  !
  !     DECIDE WHETHER NEW JACOBIAN IS NEEDED
  temp1 = (1._SP-xrate)/(1._SP+xrate)
  temp2 = 1._SP/temp1
  IF( Cj/Cjold<temp1 .OR. Cj/Cjold>temp2 ) Jcalc = -1
  IF( Cj/=cjlast ) S = 100._SP
  !
  !     CHANGE PHI TO PHI STAR
  IF( kp1>=nsp1 ) THEN
    DO j = nsp1, kp1
      DO i = 1, Neq
        Phi(i,j) = Beta(j)*Phi(i,j)
      END DO
    END DO
  END IF
  !
  !     UPDATE TIME
  X = X + H
  DO
    !
    !
    !
    !
    !
    !-----------------------------------------------------------------------
    !     BLOCK 3
    !     PREDICT THE SOLUTION AND DERIVATIVE,
    !     AND SOLVE THE CORRECTOR EQUATION
    !-----------------------------------------------------------------------
    !
    !     FIRST,PREDICT THE SOLUTION AND DERIVATIVE
    DO i = 1, Neq
      Y(i) = Phi(i,1)
      Yprime(i) = 0._SP
    END DO
    DO j = 2, kp1
      DO i = 1, Neq
        Y(i) = Y(i) + Phi(i,j)
        Yprime(i) = Yprime(i) + Gama(j)*Phi(i,j)
      END DO
    END DO
    pnorm = SDANRM(Neq,Y,Wt)
    !
    !
    !
    !     SOLVE THE CORRECTOR EQUATION USING A
    !     MODIFIED NEWTON SCHEME.
    convgd = .TRUE.
    m = 0
    Iwm(LNRE) = Iwm(LNRE) + 1
    ires = 0
    CALL RES(X,Y,Yprime,Delta,ires)
    IF( ires<0 ) THEN
      !
      !
      !     EXITS FROM BLOCK 3
      !     NO CONVERGENCE WITH CURRENT ITERATION
      !     MATRIX,OR SINGULAR ITERATION MATRIX
      convgd = .FALSE.
      GOTO 300
    ELSE
      !
      !
      !     IF INDICATED,REEVALUATE THE
      !     ITERATION MATRIX PD = DG/DY + CJ*DG/DYPRIME
      !     (WHERE G(X,Y,YPRIME)=0). SET
      !     JCALC TO 0 AS AN INDICATOR THAT
      !     THIS HAS BEEN DONE.
      IF( Jcalc==-1 ) THEN
        Iwm(LNJE) = Iwm(LNJE) + 1
        Jcalc = 0
        CALL SDAJAC(Neq,X,Y,Yprime,Delta,Cj,H,ier,Wt,E,Wm,Iwm,RES,ires,&
          Uround,JAC,Ntemp)
        Cjold = Cj
        S = 100._SP
        IF( ires<0 ) THEN
          convgd = .FALSE.
          GOTO 300
        ELSEIF( ier/=0 ) THEN
          convgd = .FALSE.
          GOTO 300
        ELSE
          nsf = 0
        END IF
      END IF
      !
      !
      !     INITIALIZE THE ERROR ACCUMULATION VECTOR E.
      DO i = 1, Neq
        E(i) = 0._SP
      END DO
      DO
        !
        !
        !     CORRECTOR LOOP.
        !
        !     MULTIPLY RESIDUAL BY TEMP1 TO ACCELERATE CONVERGENCE
        temp1 = 2._SP/(1._SP+Cj/Cjold)
        DO i = 1, Neq
          Delta(i) = Delta(i)*temp1
        END DO
        !
        !     COMPUTE A NEW ITERATE (BACK-SUBSTITUTION).
        !     STORE THE CORRECTION IN DELTA.
        CALL SDASLV(Neq,Delta,Wm,Iwm)
        !
        !     UPDATE Y, E, AND YPRIME
        DO i = 1, Neq
          Y(i) = Y(i) - Delta(i)
          E(i) = E(i) - Delta(i)
          Yprime(i) = Yprime(i) - Cj*Delta(i)
        END DO
        !
        !     TEST FOR CONVERGENCE OF THE ITERATION
        delnrm = SDANRM(Neq,Delta,Wt)
        IF( delnrm<=100._SP*Uround*pnorm ) GOTO 200
        IF( m>0 ) THEN
          rate = (delnrm/oldnrm)**(1._SP/m)
          IF( rate>0.90_SP ) EXIT
          S = rate/(1._SP-rate)
        ELSE
          oldnrm = delnrm
        END IF
        IF( S*delnrm<=0.33_SP ) GOTO 200
        !
        !     THE CORRECTOR HAS NOT YET CONVERGED.
        !     UPDATE M AND TEST WHETHER THE
        !     MAXIMUM NUMBER OF ITERATIONS HAVE
        !     BEEN TRIED.
        m = m + 1
        IF( m>=maxit ) EXIT
        !
        !     EVALUATE THE RESIDUAL
        !     AND GO BACK TO DO ANOTHER ITERATION
        Iwm(LNRE) = Iwm(LNRE) + 1
        ires = 0
        CALL RES(X,Y,Yprime,Delta,ires)
        IF( ires<0 ) THEN
          convgd = .FALSE.
          GOTO 300
        END IF
      END DO
      !
      !
      !     THE CORRECTOR FAILED TO CONVERGE IN MAXIT
      !     ITERATIONS. IF THE ITERATION MATRIX
      !     IS NOT CURRENT,RE-DO THE STEP WITH
      !     A NEW ITERATION MATRIX.
      IF( Jcalc==0 ) THEN
        convgd = .FALSE.
        GOTO 300
      ELSE
        Jcalc = -1
      END IF
    END IF
  END DO
  !
  !
  !     THE ITERATION HAS CONVERGED.  IF NONNEGATIVITY OF SOLUTION IS
  !     REQUIRED, SET THE SOLUTION NONNEGATIVE, IF THE PERTURBATION
  !     TO DO IT IS SMALL ENOUGH.  IF THE CHANGE IS TOO LARGE, THEN
  !     CONSIDER THE CORRECTOR ITERATION TO HAVE FAILED.
  200 CONTINUE
  IF( Nonneg/=0 ) THEN
    DO i = 1, Neq
      Delta(i) = MIN(Y(i),0._SP)
    END DO
    delnrm = SDANRM(Neq,Delta,Wt)
    IF( delnrm>0.33_SP ) THEN
      convgd = .FALSE.
    ELSE
      DO i = 1, Neq
        E(i) = E(i) - Delta(i)
      END DO
    END IF
  END IF
  300  Jcalc = 1
  IF( convgd ) THEN
    !
    !
    !
    !
    !
    !-----------------------------------------------------------------------
    !     BLOCK 4
    !     ESTIMATE THE ERRORS AT ORDERS K,K-1,K-2
    !     AS IF CONSTANT STEPSIZE WAS USED. ESTIMATE
    !     THE LOCAL ERROR AT ORDER K AND TEST
    !     WHETHER THE CURRENT STEP IS SUCCESSFUL.
    !-----------------------------------------------------------------------
    !
    !     ESTIMATE ERRORS AT ORDERS K,K-1,K-2
    enorm = SDANRM(Neq,E,Wt)
    erk = Sigma(K+1)*enorm
    terk = (K+1)*erk
    est = erk
    knew = K
    IF( K/=1 ) THEN
      DO i = 1, Neq
        Delta(i) = Phi(i,kp1) + E(i)
      END DO
      erkm1 = Sigma(K)*SDANRM(Neq,Delta,Wt)
      terkm1 = K*erkm1
      IF( K>2 ) THEN
        DO i = 1, Neq
          Delta(i) = Phi(i,K) + Delta(i)
        END DO
        erkm2 = Sigma(K-1)*SDANRM(Neq,Delta,Wt)
        terkm2 = (K-1)*erkm2
        IF( MAX(terkm1,terkm2)>terk ) GOTO 350
      ELSEIF( terkm1>0.5_SP*terk ) THEN
        GOTO 350
      END IF
      !     LOWER THE ORDER
      knew = K - 1
      est = erkm1
    END IF
    !
    !
    !     CALCULATE THE LOCAL ERROR FOR THE CURRENT STEP
    !     TO SEE IF THE STEP WAS SUCCESSFUL
    350  err = ck*enorm
    IF( err>1._SP ) GOTO 500
    !
    !
    !
    !
    !
    !-----------------------------------------------------------------------
    !     BLOCK 5
    !     THE STEP IS SUCCESSFUL. DETERMINE
    !     THE BEST ORDER AND STEPSIZE FOR
    !     THE NEXT STEP. UPDATE THE DIFFERENCES
    !     FOR THE NEXT STEP.
    !-----------------------------------------------------------------------
    Idid = 1
    Iwm(LNST) = Iwm(LNST) + 1
    kdiff = K - Kold
    Kold = K
    Hold = H
    !
    !
    !     ESTIMATE THE ERROR AT ORDER K+1 UNLESS:
    !        ALREADY DECIDED TO LOWER ORDER, OR
    !        ALREADY USING MAXIMUM ORDER, OR
    !        STEPSIZE NOT CONSTANT, OR
    !        ORDER RAISED IN PREVIOUS STEP
    IF( knew==km1 .OR. K==Iwm(LMXORD) ) Iphase = 1
    IF( Iphase==0 ) THEN
      !
      !     IF IPHASE = 0, INCREASE ORDER BY ONE AND MULTIPLY STEPSIZE BY
      !     FACTOR TWO
      K = kp1
      hnew = H*2._SP
      H = hnew
      GOTO 450
    ELSE
      IF( knew/=km1 ) THEN
        IF( K/=Iwm(LMXORD) ) THEN
          IF( kp1<Ns .AND. kdiff/=1 ) THEN
            DO i = 1, Neq
              Delta(i) = E(i) - Phi(i,kp2)
            END DO
            erkp1 = (1._SP/(K+2))*SDANRM(Neq,Delta,Wt)
            terkp1 = (K+2)*erkp1
            IF( K>1 ) THEN
              IF( terkm1<=MIN(terk,terkp1) ) GOTO 360
              IF( terkp1>=terk .OR. K==Iwm(LMXORD) ) GOTO 400
            ELSEIF( terkp1>=0.5_SP*terk ) THEN
              GOTO 400
            END IF
            !
            !     RAISE ORDER
            K = kp1
            est = erkp1
          END IF
        END IF
        GOTO 400
      END IF
      !
      !     LOWER ORDER
      360  K = km1
      est = erkm1
    END IF
    !
    !
    !     DETERMINE THE APPROPRIATE STEPSIZE FOR
    !     THE NEXT STEP.
    400  hnew = H
    temp2 = K + 1
    r = (2._SP*est+0.0001_SP)**(-1._SP/temp2)
    IF( r>=2._SP ) THEN
      hnew = 2._SP*H
    ELSEIF( r<=1._SP ) THEN
      r = MAX(0.5_SP,MIN(0.9_SP,r))
      hnew = H*r
    END IF
    H = hnew
    !
    !
    !     UPDATE DIFFERENCES FOR NEXT STEP
    450 CONTINUE
    IF( Kold/=Iwm(LMXORD) ) THEN
      DO i = 1, Neq
        Phi(i,kp2) = E(i)
      END DO
    END IF
    DO i = 1, Neq
      Phi(i,kp1) = Phi(i,kp1) + E(i)
    END DO
    DO j1 = 2, kp1
      j = kp1 - j1 + 1
      DO i = 1, Neq
        Phi(i,j) = Phi(i,j) + Phi(i,j+1)
      END DO
    END DO
    RETURN
  END IF
  !
  !
  !
  !
  !
  !-----------------------------------------------------------------------
  !     BLOCK 6
  !     THE STEP IS UNSUCCESSFUL. RESTORE X,PSI,PHI
  !     DETERMINE APPROPRIATE STEPSIZE FOR
  !     CONTINUING THE INTEGRATION, OR EXIT WITH
  !     AN ERROR FLAG IF THERE HAVE BEEN MANY
  !     FAILURES.
  !-----------------------------------------------------------------------
  500  Iphase = 1
  !
  !     RESTORE X,PHI,PSI
  X = xold
  IF( kp1>=nsp1 ) THEN
    DO j = nsp1, kp1
      temp1 = 1._SP/Beta(j)
      DO i = 1, Neq
        Phi(i,j) = temp1*Phi(i,j)
      END DO
    END DO
  END IF
  DO i = 2, kp1
    Psi(i-1) = Psi(i) - H
  END DO
  !
  !
  !     TEST WHETHER FAILURE IS DUE TO CORRECTOR ITERATION
  !     OR ERROR TEST
  IF( convgd ) THEN
    !
    !
    !     THE NEWTON SCHEME CONVERGED, AND THE CAUSE
    !     OF THE FAILURE WAS THE ERROR ESTIMATE
    !     EXCEEDING THE TOLERANCE.
    nef = nef + 1
    Iwm(LETF) = Iwm(LETF) + 1
    IF( nef<=1 ) THEN
      !
      !     ON FIRST ERROR TEST FAILURE, KEEP CURRENT ORDER OR LOWER
      !     ORDER BY ONE.  COMPUTE NEW STEPSIZE BASED ON DIFFERENCES
      !     OF THE SOLUTION.
      K = knew
      temp2 = K + 1
      r = 0.90_SP*(2._SP*est+0.0001_SP)**(-1._SP/temp2)
      r = MAX(0.25_SP,MIN(0.9_SP,r))
      H = H*r
      IF( ABS(H)>=Hmin ) GOTO 100
      Idid = -6
      !
      !     ON SECOND ERROR TEST FAILURE, USE THE CURRENT ORDER OR
      !     DECREASE ORDER BY ONE.  REDUCE THE STEPSIZE BY A FACTOR OF
      !     FOUR.
    ELSEIF( nef>2 ) THEN
      !
      !     ON THIRD AND SUBSEQUENT ERROR TEST FAILURES, SET THE ORDER TO
      !     ONE AND REDUCE THE STEPSIZE BY A FACTOR OF FOUR.
      K = 1
      H = 0.25_SP*H
      IF( ABS(H)>=Hmin ) GOTO 100
      Idid = -6
    ELSE
      K = knew
      H = 0.25_SP*H
      IF( ABS(H)>=Hmin ) GOTO 100
      Idid = -6
    END IF
  ELSE
    Iwm(LCTF) = Iwm(LCTF) + 1
    !
    !
    !     THE NEWTON ITERATION FAILED TO CONVERGE WITH
    !     A CURRENT ITERATION MATRIX.  DETERMINE THE CAUSE
    !     OF THE FAILURE AND TAKE APPROPRIATE ACTION.
    IF( ier/=0 ) THEN
      !
      !     THE ITERATION MATRIX IS SINGULAR. REDUCE
      !     THE STEPSIZE BY A FACTOR OF 4. IF
      !     THIS HAPPENS THREE TIMES IN A ROW ON
      !     THE SAME STEP, RETURN WITH AN ERROR FLAG
      nsf = nsf + 1
      r = 0.25_SP
      H = H*r
      IF( nsf<3 .AND. ABS(H)>=Hmin ) GOTO 100
      Idid = -8
      !
      !
      !     THE NEWTON ITERATION FAILED TO CONVERGE FOR A REASON
      !     OTHER THAN A SINGULAR ITERATION MATRIX.  IF IRES = -2, THEN
      !     RETURN.  OTHERWISE, REDUCE THE STEPSIZE AND TRY AGAIN, UNLESS
      !     TOO MANY FAILURES HAVE OCCURRED.
    ELSEIF( ires>-2 ) THEN
      ncf = ncf + 1
      r = 0.25_SP
      H = H*r
      IF( ncf<10 .AND. ABS(H)>=Hmin ) GOTO 100
      Idid = -7
      IF( ires<0 ) Idid = -10
      IF( nef>=3 ) Idid = -9
    ELSE
      Idid = -11
    END IF
  END IF
  !
  !
  !
  !
  !     FOR ALL CRASHES, RESTORE Y TO ITS LAST VALUE,
  !     INTERPOLATE TO FIND YPRIME AT LAST X, AND RETURN
  CALL SDATRP(X,X,Y,Yprime,Neq,K,Phi,Psi)
  !
  !
  !     GO BACK AND TRY THIS STEP AGAIN
  RETURN
  !
  !------END OF SUBROUTINE SDASTP------
END SUBROUTINE SDASTP
