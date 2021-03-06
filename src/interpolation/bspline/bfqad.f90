!** BFQAD
PURE SUBROUTINE BFQAD(F,T,Bcoef,N,K,Id,X1,X2,Tol,Quad,Ierr)
  !> Compute the integral of a product of a function and a derivative of a B-spline.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  H2A2A1, E3, K6
  !***
  ! **Type:**      SINGLE PRECISION (BFQAD-S, DBFQAD-D)
  !***
  ! **Keywords:**  INTEGRAL OF B-SPLINE, QUADRATURE
  !***
  ! **Author:**  Amos, D. E., (SNLA)
  !***
  ! **Description:**
  !
  !     Abstract
  !         BFQAD computes the integral on (X1,X2) of a product of a
  !         function F and the ID-th derivative of a K-th order B-spline,
  !         using the B-representation (T,BCOEF,N,K).  (X1,X2) must be
  !         a subinterval of T(K) <= X <= T(N+1).  An integration
  !         routine BSGQ8 (a modification
  !         of GAUS8), integrates the product on sub-
  !         intervals of (X1,X2) formed by included (distinct) knots.
  !
  !     Description of Arguments
  !         Input
  !           F      - external function of one argument for the
  !                    integrand BF(X)=F(X)*BVALU(T,BCOEF,N,K,ID,X,INBV,
  !                    WORK)
  !           T      - knot array of length N+K
  !           BCOEF  - coefficient array of length N
  !           N      - length of coefficient array
  !           K      - order of B-spline, K >= 1
  !           ID     - order of the spline derivative, 0 <= ID <= K-1
  !                    ID=0 gives the spline function
  !           X1,X2  - end points of quadrature interval in
  !                    T(K) <= X <= T(N+1)
  !           TOL    - desired accuracy for the quadrature, suggest
  !                    10.*STOL < TOL <= 0.1 where STOL is the single
  !                    precision unit roundoff for the machine = eps_sp
  !
  !         Output
  !           QUAD   - integral of BF(X) on (X1,X2)
  !           IERR   - a status code
  !                    IERR=1  normal return
  !                         2  some quadrature on (X1,X2) does not meet
  !                            the requested tolerance.
  !           WORK   - work vector of length 3*K
  !
  !     Error Conditions
  !         X1 or X2 not in T(K) <= X <= T(N+1) is a fatal error.
  !         TOL not greater than the single precision unit roundoff or
  !         less than 0.1 is a fatal error.
  !         Some quadrature fails to meet the requested tolerance.
  !
  !***
  ! **References:**  D. E. Amos, Quadrature subroutines for splines and
  !                 B-splines, Report SAND79-1825, Sandia Laboratories,
  !                 December 1979.
  !***
  ! **Routines called:**  BSGQ8, INTRV, R1MACH, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   800901  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900326  Removed duplicate information from DESCRIPTION section.  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE service, ONLY : eps_sp
  !
  INTERFACE
    PURE REAL(SP) FUNCTION F(X)
      IMPORT SP
      REAL(SP), INTENT(IN) :: X
    END FUNCTION F
  END INTERFACE
  INTEGER, INTENT(IN) :: Id, K, N
  INTEGER, INTENT(OUT) :: Ierr
  REAL(SP), INTENT(IN) :: Bcoef(N), T(N+K), X1, X2
  REAL(SP), INTENT(INOUT) :: Tol
  REAL(SP), INTENT(OUT) :: Quad
  !
  INTEGER :: inbv, iflg, ilo, il1, il2, left, mflag, npk, np1
  REAL(SP) :: a, aa, ans, b, bb, q, ta, tb, wtol
  !* FIRST EXECUTABLE STATEMENT  BFQAD
  Ierr = 1
  Quad = 0._SP
  IF( K<1 ) THEN
    ERROR STOP 'BFQAD : K DOES NOT SATISFY K>=1'
  ELSEIF( N<K ) THEN
    ERROR STOP 'BFQAD : N DOES NOT SATISFY N>=K'
  ELSEIF( Id<0 .OR. Id>=K ) THEN
    ERROR STOP 'BFQAD : ID DOES NOT SATISFY 0 <= ID < K'
  ELSE
    wtol = eps_sp
    IF( Tol>=wtol .AND. Tol<=0.1_SP ) THEN
      aa = MIN(X1,X2)
      bb = MAX(X1,X2)
      IF( aa>=T(K) ) THEN
        np1 = N + 1
        IF( bb<=T(np1) ) THEN
          IF( aa==bb ) RETURN
          npk = N + K
          !
          ilo = 1
          CALL INTRV(T,npk,aa,ilo,il1,mflag)
          CALL INTRV(T,npk,bb,ilo,il2,mflag)
          IF( il2>=np1 ) il2 = N
          inbv = 1
          q = 0._SP
          DO left = il1, il2
            ta = T(left)
            tb = T(left+1)
            IF( ta/=tb ) THEN
              a = MAX(aa,ta)
              b = MIN(bb,tb)
              CALL BSGQ8(F,T,Bcoef,N,K,Id,a,b,Tol,ans,iflg)
              IF( iflg>1 ) Ierr = 2
              q = q + ans
            END IF
          END DO
          IF( X1>X2 ) q = -q
          Quad = q
          RETURN
        END IF
      END IF
      ERROR STOP 'BFQAD : X1 OR X2 OR BOTH DO NOT SATISFY T(K)<=X<=T(N+1)'
      RETURN
    END IF
  END IF
  ERROR STOP 'BFQAD : TOL IS LESS THAN THE SINGLE PRECISION TOLERANCE OR GREATER THAN 0.1'

  RETURN
END SUBROUTINE BFQAD