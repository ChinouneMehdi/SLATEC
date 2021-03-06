!** DBSPEV
PURE SUBROUTINE DBSPEV(T,Ad,N,K,Nderiv,X,Inev,Svalue,Work)
  !> Calculate the value of the spline and its derivatives from the B-representation.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  E3, K6
  !***
  ! **Type:**      DOUBLE PRECISION (BSPEV-S, DBSPEV-D)
  !***
  ! **Keywords:**  B-SPLINE, DATA FITTING, INTERPOLATION, SPLINES
  !***
  ! **Author:**  Amos, D. E., (SNLA)
  !***
  ! **Description:**
  !
  !     Written by Carl de Boor and modified by D. E. Amos
  !
  !     Abstract    **** a double precision routine ****
  !         DBSPEV is the BSPLEV routine of the reference.
  !
  !         DBSPEV calculates the value of the spline and its derivatives
  !         at X from the B-representation (T,A,N,K) and returns them in
  !         SVALUE(I),I=1,NDERIV, T(K) <= X <= T(N+1).  AD(I) can be
  !         the B-spline coefficients A(I), I=1,N) if NDERIV=1.  Otherwise
  !         AD must be computed before hand by a call to DBSPDR (T,A,N,K,
  !         NDERIV,AD).  If X=T(I),I=K,N), right limiting values are
  !         obtained.
  !
  !         To compute left derivatives or left limiting values at a
  !         knot T(I), replace N by I-1 and set X=T(I), I=K+1,N+1.
  !
  !         DBSPEV calls DINTRV, DBSPVN
  !
  !     Description of Arguments
  !
  !         Input      T,AD,X, are double precision
  !          T       - knot vector of length N+K
  !          AD      - vector of length (2*N-NDERIV+1)*NDERIV/2 containing
  !                    the difference table from DBSPDR.
  !          N       - number of B-spline coefficients
  !                    N = sum of knot multiplicities-K
  !          K       - order of the B-spline, K >= 1
  !          NDERIV  - number of derivatives, 1 <= NDERIV <= K.
  !                    NDERIV=1 gives the zero-th derivative =
  !                    function value
  !          X       - argument, T(K) <= X <= T(N+1)
  !          INEV    - an initialization parameter which must be set
  !                    to 1 the first time DBSPEV is called.
  !
  !         Output     SVALUE,WORK are double precision
  !          INEV    - INEV contains information for efficient process-
  !                    ing after the initial call and INEV must not
  !                    be changed by the user.  Distinct splines require
  !                    distinct INEV parameters.
  !          SVALUE  - vector of length NDERIV containing the spline
  !                    value in SVALUE(1) and the NDERIV-1 derivatives
  !                    in the remaining components.
  !          WORK    - work vector of length 3*K
  !
  !     Error Conditions
  !         Improper input is a fatal error.
  !
  !***
  ! **References:**  Carl de Boor, Package for calculating with B-splines,
  !                 SIAM Journal on Numerical Analysis 14, 3 (June 1977),
  !                 pp. 441-472.
  !***
  ! **Routines called:**  DBSPVN, DINTRV, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   800901  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER, INTENT(IN) :: K, N, Nderiv
  INTEGER, INTENT(INOUT) :: Inev
  REAL(DP), INTENT(IN) :: Ad((2*N-Nderiv+1)*Nderiv/2), T(N+K), X
  REAL(DP), INTENT(OUT) :: Svalue(Nderiv), Work(3*K)
  INTEGER :: i, id, iwork, jj, kp1, kp1mn, l, left, ll, mflag
  REAL(DP) :: summ
  !     DIMENSION T(N+K)
  !* FIRST EXECUTABLE STATEMENT  DBSPEV
  IF( K<1 ) THEN
    ERROR STOP 'DBSPEV : K DOES NOT SATISFY K>=1'
  ELSEIF( N<K ) THEN
    ERROR STOP 'DBSPEV : N DOES NOT SATISFY N>=K'
  ELSEIF( Nderiv<1 .OR. Nderiv>K ) THEN
    ERROR STOP 'DBSPEV : NDERIV DOES NOT SATISFY 1<=NDERIV<=K'
  ELSE
    id = Nderiv
    CALL DINTRV(T,N+1,X,Inev,i,mflag)
    IF( X>=T(K) ) THEN
      IF( mflag/=0 ) THEN
        IF( X>T(i) ) GOTO 100
        DO WHILE( i/=K )
          i = i - 1
          IF( X/=T(i) ) GOTO 20
        END DO
        ERROR STOP 'DBSPEV : A LEFT LIMITING VALUE CANNOT BE OBTAINED AT T(K)'
      END IF
      !
      !- I* HAS BEEN FOUND IN (K,N) SO THAT T(I) <= X < T(I+1)
      !     (OR <= T(I+1), IF T(I) < T(I+1) = T(N+1) ).
      20  kp1mn = K + 1 - id
      kp1 = K + 1
      CALL DBSPVN(T,kp1mn,K,1,X,i,Work(1),Work(kp1),iwork)
      jj = (N+N-id+2)*(id-1)/2
      DO
        !     ADIF(LEFTPL,ID) = AD(LEFTPL-ID+1 + (2*N-ID+2)*(ID-1)/2)
        !     LEFTPL = LEFT + L
        left = i - kp1mn
        summ = 0._DP
        ll = left + jj + 2 - id
        DO l = 1, kp1mn
          summ = summ + Work(l)*Ad(ll)
          ll = ll + 1
        END DO
        Svalue(id) = summ
        id = id - 1
        IF( id==0 ) THEN
          !
          RETURN
        ELSE
          jj = jj - (N-id+1)
          kp1mn = kp1mn + 1
          CALL DBSPVN(T,kp1mn,K,2,X,i,Work(1),Work(kp1),iwork)
        END IF
      END DO
    END IF
  END IF
  100  ERROR STOP 'DBSPEV : X IS NOT IN T(K)<=X<=T(N+1)'

  RETURN
END SUBROUTINE DBSPEV