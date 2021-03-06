!** DBVALU
REAL(DP) PURE FUNCTION DBVALU(T,A,N,K,Ideriv,X)
  !> Evaluate the B-representation of a B-spline at X for the
  !  function value or any of its derivatives.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  E3, K6
  !***
  ! **Type:**      DOUBLE PRECISION (BVALU-S, DBVALU-D)
  !***
  ! **Keywords:**  DIFFERENTIATION OF B-SPLINE, EVALUATION OF B-SPLINE
  !***
  ! **Author:**  Amos, D. E., (SNLA)
  !***
  ! **Description:**
  !
  !     Written by Carl de Boor and modified by D. E. Amos
  !
  !     Abstract   **** a double precision routine ****
  !         DBVALU is the BVALUE function of the reference.
  !
  !         DBVALU evaluates the B-representation (T,A,N,K) of a B-spline
  !         at X for the function value on IDERIV=0 or any of its
  !         derivatives on IDERIV=1,2,...,K-1.  Right limiting values
  !         (right derivatives) are returned except at the right end
  !         point X=T(N+1) where left limiting values are computed.  The
  !         spline is defined on T(K) <= X <= T(N+1).  DBVALU returns
  !         a fatal error message when X is outside of this interval.
  !
  !         To compute left derivatives or left limiting values at a
  !         knot T(I), replace N by I-1 and set X=T(I), I=K+1,N+1.
  !
  !         DBVALU calls DINTRV
  !
  !     Description of Arguments
  !
  !         Input      T,A,X are double precision
  !          T       - knot vector of length N+K
  !          A       - B-spline coefficient vector of length N
  !          N       - number of B-spline coefficients
  !                    N = sum of knot multiplicities-K
  !          K       - order of the B-spline, K >= 1
  !          IDERIV  - order of the derivative, 0 <= IDERIV <= K-1
  !                    IDERIV = 0 returns the B-spline value
  !          X       - argument, T(K) <= X <= T(N+1)
  !          INBV    - an initialization parameter which must be set
  !                    to 1 the first time DBVALU is called.
  !
  !         Output     WORK,DBVALU are double precision
  !          INBV    - INBV contains information for efficient process-
  !                    ing after the initial call and INBV must not
  !                    be changed by the user.  Distinct splines require
  !                    distinct INBV parameters.
  !          WORK    - work vector of length 3*K.
  !          DBVALU  - value of the IDERIV-th derivative at X
  !
  !     Error Conditions
  !         An improper input is a fatal error
  !
  !***
  ! **References:**  Carl de Boor, Package for calculating with B-splines,
  !                 SIAM Journal on Numerical Analysis 14, 3 (June 1977),
  !                 pp. 441-472.
  !***
  ! **Routines called:**  DINTRV, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   800901  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   890911  Removed unnecessary intrinsics.  (WRB)
  !   890911  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER, INTENT(IN) :: Ideriv, K, N
  REAL(DP), INTENT(IN) :: A(N), T(N+K), X
  INTEGER :: i, iderp1, ihi, ihmkmj, ilo, imk, imkpj, inbv, &
    ipj, ip1, ip1mj, j, jj, j1, j2, kmider, kmj, km1, kpk, mflag
  REAL(DP) :: fkmj, Work(3*K)
  !* FIRST EXECUTABLE STATEMENT  DBVALU
  DBVALU = 0._DP
  inbv = 1
  IF( K<1 ) THEN
    ERROR STOP 'DBVALU : K DOES NOT SATISFY K>=1'
  ELSEIF( N<K ) THEN
    ERROR STOP 'DBVALU : N DOES NOT SATISFY N>=K'
  ELSEIF( Ideriv<0 .OR. Ideriv>=K ) THEN
    ERROR STOP 'DBVALU : IDERIV DOES NOT SATISFY 0<=IDERIV<K'
  ELSE
    kmider = K - Ideriv
    !
    !- ** FIND *I* IN (K,N) SUCH THAT T(I) <= X < T(I+1)
    !     (OR, <= T(I+1) IF T(I) < T(I+1) = T(N+1)).
    km1 = K - 1
    CALL DINTRV(T,N+1,X,inbv,i,mflag)
    IF( X<T(K) ) THEN
      ERROR STOP 'DBVALU : X IS N0T GREATER THAN OR EQUAL TO T(K)'
    ELSE
      IF( mflag/=0 ) THEN
        IF( X>T(i) ) THEN
          ERROR STOP 'DBVALU : X IS NOT LESS THAN OR EQUAL TO T(N+1)'
        ELSE
          DO WHILE( i/=K )
            i = i - 1
            IF( X/=T(i) ) GOTO 20
          END DO
          ERROR STOP 'DBVALU : A LEFT LIMITING VALUE CANNOT BE OBTAINED AT T(K)'
        END IF
      END IF
      !
      !- ** DIFFERENCE THE COEFFICIENTS *IDERIV* TIMES
      !     WORK(I) = AJ(I), WORK(K+I) = DP(I), WORK(K+K+I) = DM(I), I=1.K
      !
      20  imk = i - K
      DO j = 1, K
        imkpj = imk + j
        Work(j) = A(imkpj)
      END DO
      IF( Ideriv/=0 ) THEN
        DO j = 1, Ideriv
          kmj = K - j
          fkmj = kmj
          DO jj = 1, kmj
            ihi = i + jj
            ihmkmj = ihi - kmj
            Work(jj) = (Work(jj+1)-Work(jj))/(T(ihi)-T(ihmkmj))*fkmj
          END DO
        END DO
      END IF
      !
      !- ** COMPUTE VALUE AT *X* IN (T(I),(T(I+1)) OF IDERIV-TH DERIVATIVE,
      !     GIVEN ITS RELEVANT B-SPLINE COEFF. IN AJ(1),...,AJ(K-IDERIV).
      IF( Ideriv/=km1 ) THEN
        ip1 = i + 1
        kpk = K + K
        j1 = K + 1
        j2 = kpk + 1
        DO j = 1, kmider
          ipj = i + j
          Work(j1) = T(ipj) - X
          ip1mj = ip1 - j
          Work(j2) = X - T(ip1mj)
          j1 = j1 + 1
          j2 = j2 + 1
        END DO
        iderp1 = Ideriv + 1
        DO j = iderp1, km1
          kmj = K - j
          ilo = kmj
          DO jj = 1, kmj
            Work(jj) = (Work(jj+1)*Work(kpk+ilo)+Work(jj)*Work(K+jj))&
              /(Work(kpk+ilo)+Work(K+jj))
            ilo = ilo - 1
          END DO
        END DO
      END IF
    END IF
  END IF
  DBVALU = Work(1)

  RETURN
END FUNCTION DBVALU