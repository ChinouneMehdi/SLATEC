!** DBINTK
PURE SUBROUTINE DBINTK(X,Y,T,N,K,Bcoef,Q,Work)
  !> Compute the B-representation of a spline which interpolates given data.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  E1A
  !***
  ! **Type:**      DOUBLE PRECISION (BINTK-S, DBINTK-D)
  !***
  ! **Keywords:**  B-SPLINE, DATA FITTING, INTERPOLATION
  !***
  ! **Author:**  Amos, D. E., (SNLA)
  !***
  ! **Description:**
  !
  !     Written by Carl de Boor and modified by D. E. Amos
  !
  !     Abstract    **** a double precision routine ****
  !
  !         DBINTK is the SPLINT routine of the reference.
  !
  !         DBINTK produces the B-spline coefficients, BCOEF, of the
  !         B-spline of order K with knots T(I), I=1,...,N+K, which
  !         takes on the value Y(I) at X(I), I=1,...,N.  The spline or
  !         any of its derivatives can be evaluated by calls to DBVALU.
  !
  !         The I-th equation of the linear system A*BCOEF = B for the
  !         coefficients of the interpolant enforces interpolation at
  !         X(I), I=1,...,N.  Hence, B(I) = Y(I), for all I, and A is
  !         a band matrix with 2K-1 bands if A is invertible.  The matrix
  !         A is generated row by row and stored, diagonal by diagonal,
  !         in the rows of Q, with the main diagonal going into row K.
  !         The banded system is then solved by a call to DBNFAC (which
  !         constructs the triangular factorization for A and stores it
  !         again in Q), followed by a call to DBNSLV (which then
  !         obtains the solution BCOEF by substitution).  DBNFAC does no
  !         pivoting, since the total positivity of the matrix A makes
  !         this unnecessary.  The linear system to be solved is
  !         (theoretically) invertible if and only if
  !                 T(I) < X(I) < T(I+K),        for all I.
  !         Equality is permitted on the left for I=1 and on the right
  !         for I=N when K knots are used at X(1) or X(N).  Otherwise,
  !         violation of this condition is certain to lead to an error.
  !
  !     Description of Arguments
  !
  !         Input       X,Y,T are double precision
  !           X       - vector of length N containing data point abscissa
  !                     in strictly increasing order.
  !           Y       - corresponding vector of length N containing data
  !                     point ordinates.
  !           T       - knot vector of length N+K
  !                     Since T(1),..,T(K) <= X(1) and T(N+1),..,T(N+K)
  !                     >= X(N), this leaves only N-K knots (not nec-
  !                     essarily X(I) values) interior to (X(1),X(N))
  !           N       - number of data points, N >= K
  !           K       - order of the spline, K >= 1
  !
  !         Output      BCOEF,Q,WORK are double precision
  !           BCOEF   - a vector of length N containing the B-spline
  !                     coefficients
  !           Q       - a work vector of length (2*K-1)*N, containing
  !                     the triangular factorization of the coefficient
  !                     matrix of the linear system being solved.  The
  !                     coefficients for the interpolant of an
  !                     additional data set (X(I),YY(I)), I=1,...,N
  !                     with the same abscissa can be obtained by loading
  !                     YY into BCOEF and then executing
  !                         CALL DBNSLV (Q,2K-1,N,K-1,K-1,BCOEF)
  !           WORK    - work vector of length 2*K
  !
  !     Error Conditions
  !         Improper input is a fatal error
  !         Singular system of equations is a fatal error
  !
  !***
  ! **References:**  D. E. Amos, Computation with splines and B-splines,
  !                 Report SAND78-1968, Sandia Laboratories, March 1979.
  !               Carl de Boor, Package for calculating with B-splines,
  !                 SIAM Journal on Numerical Analysis 14, 3 (June 1977),
  !                 pp. 441-472.
  !               Carl de Boor, A Practical Guide to Splines, Applied
  !                 Mathematics Series 27, Springer-Verlag, New York,
  !                 1978.
  !***
  ! **Routines called:**  DBNFAC, DBNSLV, DBSPVN, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   800901  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900326  Removed duplicate information from DESCRIPTION section.  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER, INTENT(IN) :: K, N
  REAL(DP), INTENT(IN) :: Y(N), T(N+K), X(N)
  REAL(DP), INTENT(OUT) :: Bcoef(N), Q((2*K-1)*N), Work(2*K)
  INTEGER :: iflag, iwork, i, ilp1mx, j, jj, km1, kpkm2, left, lenq, np1
  REAL(DP) :: xi
  !     DIMENSION Q(2*K-1,N), T(N+K)
  !* FIRST EXECUTABLE STATEMENT  DBINTK
  IF( K<1 ) THEN
    ERROR STOP 'DBINTK : K DOES NOT SATISFY K>=1'
  ELSE
    IF( N<K ) THEN
      ERROR STOP 'DBINTK : N DOES NOT SATISFY N>=K'
    ELSE
      jj = N - 1
      IF( jj/=0 ) THEN
        DO i = 1, jj
          IF( X(i)>=X(i+1) ) GOTO 50
        END DO
      END IF
      np1 = N + 1
      km1 = K - 1
      kpkm2 = 2*km1
      left = K
      !                ZERO OUT ALL ENTRIES OF Q
      lenq = N*(K+km1)
      DO i = 1, lenq
        Q(i) = 0._DP
      END DO
      !
      !  ***   LOOP OVER I TO CONSTRUCT THE  N  INTERPOLATION EQUATIONS
      DO i = 1, N
        xi = X(i)
        ilp1mx = MIN(i+K,np1)
        !        *** FIND  LEFT  IN THE CLOSED INTERVAL (I,I+K-1) SUCH THAT
        !                T(LEFT) <= X(I) < T(LEFT+1)
        !        MATRIX IS SINGULAR IF THIS IS NOT POSSIBLE
        left = MAX(left,i)
        IF( xi<T(left) ) GOTO 20
        DO WHILE( xi>=T(left+1) )
          left = left + 1
          IF( left>=ilp1mx ) THEN
            left = left - 1
            IF( xi<=T(left+1) ) EXIT
            GOTO 20
          END IF
        END DO
        !        *** THE I-TH EQUATION ENFORCES INTERPOLATION AT XI, HENCE
        !        A(I,J) = B(J,K,T)(XI), ALL J. ONLY THE  K  ENTRIES WITH  J =
        !        LEFT-K+1,...,LEFT ACTUALLY MIGHT BE NONZERO. THESE  K  NUMBERS
        !        ARE RETURNED, IN  BCOEF (USED FOR TEMP. STORAGE HERE), BY THE
        !        FOLLOWING
        CALL DBSPVN(T,K,K,1,xi,left,Bcoef,Work,iwork)
        !        WE THEREFORE WANT  BCOEF(J) = B(LEFT-K+J)(XI) TO GO INTO
        !        A(I,LEFT-K+J), I.E., INTO  Q(I-(LEFT+J)+2*K,(LEFT+J)-K) SINCE
        !        A(I+J,J)  IS TO GO INTO  Q(I+K,J), ALL I,J,  IF WE CONSIDER  Q
        !        AS A TWO-DIM. ARRAY, WITH  2*K-1  ROWS (SEE COMMENTS IN
        !        DBNFAC). IN THE PRESENT PROGRAM, WE TREAT  Q  AS AN EQUIVALENT
        !        ONE-DIMENSIONAL ARRAY (BECAUSE OF FORTRAN RESTRICTIONS ON
        !        DIMENSION STATEMENTS) . WE THEREFORE WANT  BCOEF(J) TO GO INTO
        !        ENTRY
        !            I -(LEFT+J) + 2*K + ((LEFT+J) - K-1)*(2*K-1)
        !                   =  I-LEFT+1 + (LEFT -K)*(2*K-1) + (2*K-2)*J
        !        OF  Q .
        jj = i - left + 1 + (left-K)*(K+km1)
        DO j = 1, K
          jj = jj + kpkm2
          Q(jj) = Bcoef(j)
        END DO
      END DO
      !
      !     ***OBTAIN FACTORIZATION OF  A , STORED AGAIN IN  Q.
      CALL DBNFAC(Q,K+km1,N,km1,km1,iflag)
      IF( iflag==2 ) THEN
        ERROR STOP 'DBINTK : THE SYSTEM OF SOLVER DETECTS A SINGULAR SYSTEM ALTHOUGH '&
          &'THE THEORETICAL CONDITIONS FOR A SOLUTION WERE SATISFIED.'
      ELSE
        !     *** SOLVE  A*BCOEF = Y  BY BACKSUBSTITUTION
        DO i = 1, N
          Bcoef(i) = Y(i)
        END DO
        CALL DBNSLV(Q,K+km1,N,km1,km1,Bcoef)
        RETURN
      END IF
      !
      !
      20 ERROR STOP 'DBINTK : SOME ABSCISSA WAS NOT IN THE SUPPORT OF THE&
           & CORRESPONDING BASIS FUNCTION AND THE SYSTEM IS SINGULAR.'
    END IF
    50  ERROR STOP 'DBINTK : X(I) DOES NOT SATISFY X(I)<X(I+1) FOR SOME I'
  END IF

END SUBROUTINE DBINTK