!** BSPVD
PURE SUBROUTINE BSPVD(T,K,Nderiv,X,Ileft,Ldvnik,Vnikx,Work)
  !> Calculate the value and all derivatives of order less than
  !  NDERIV of all basis functions which do not vanish at X.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  E3, K6
  !***
  ! **Type:**      SINGLE PRECISION (BSPVD-S, DBSPVD-D)
  !***
  ! **Keywords:**  DIFFERENTIATION OF B-SPLINE, EVALUATION OF B-SPLINE
  !***
  ! **Author:**  Amos, D. E., (SNLA)
  !***
  ! **Description:**
  !
  !     Written by Carl de Boor and modified by D. E. Amos
  !
  !     Abstract
  !         BSPVD is the BSPLVD routine of the reference.
  !
  !         BSPVD calculates the value and all derivatives of order
  !         less than NDERIV of all basis functions which do not
  !         (possibly) vanish at X.  ILEFT is input such that
  !         T(ILEFT) <= X < T(ILEFT+1).  A call to INTRV(T,N+1,X,
  !         ILO,ILEFT,MFLAG) will produce the proper ILEFT.  The output of
  !         BSPVD is a matrix VNIKX(I,J) of dimension at least (K,NDERIV)
  !         whose columns contain the K nonzero basis functions and
  !         their NDERIV-1 right derivatives at X, I=1,K, J=1,NDERIV.
  !         These basis functions have indices ILEFT-K+I, I=1,K,
  !         K <= ILEFT <= N. The nonzero part of the I-th basis
  !         function lies in (T(I),T(I+K)), I=1,N.
  !
  !         If X=T(ILEFT+1) then VNIKX contains left limiting values
  !         (left derivatives) at T(ILEFT+1).  In particular, ILEFT = N
  !         produces left limiting values at the right end point
  !         X=T(N+1). To obtain left limiting values at T(I), I=K+1,N+1,
  !         set X= next lower distinct knot, call INTRV to get ILEFT,
  !         set X=T(I), and then call BSPVD.
  !
  !     Description of Arguments
  !         Input
  !          T       - knot vector of length N+K, where
  !                    N = number of B-spline basis functions
  !                    N = sum of knot multiplicities-K
  !          K       - order of the B-spline, K >= 1
  !          NDERIV  - number of derivatives = NDERIV-1,
  !                    1 <= NDERIV <= K
  !          X       - argument of basis functions,
  !                    T(K) <= X <= T(N+1)
  !          ILEFT   - largest integer such that
  !                    T(ILEFT) <= X < T(ILEFT+1)
  !          LDVNIK  - leading dimension of matrix VNIKX
  !
  !         Output
  !          VNIKX   - matrix of dimension at least (K,NDERIV) contain-
  !                    ing the nonzero basis functions at X and their
  !                    derivatives columnwise.
  !          WORK    - a work vector of length (K+1)*(K+2)/2
  !
  !     Error Conditions
  !         Improper input is a fatal error
  !
  !***
  ! **References:**  Carl de Boor, Package for calculating with B-splines,
  !                 SIAM Journal on Numerical Analysis 14, 3 (June 1977),
  !                 pp. 441-472.
  !***
  ! **Routines called:**  BSPVN, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   800901  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900326  Removed duplicate information from DESCRIPTION section. (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER, INTENT(IN) :: Ldvnik, Ileft, K, Nderiv
  REAL(SP), INTENT(IN) :: T(Ileft+K), X
  REAL(SP), INTENT(OUT) :: Vnikx(Ldvnik,Nderiv), Work((K+1)*(K+2)/2)
  INTEGER :: iwork, i, ideriv, ipkmd, j, jj, jlow, jm, jp1mid, kmd, kp1, l, &
    ldummy, m, mhigh
  REAL(SP) :: factor, fkmd, v
  !     DIMENSION T(ILEFT+K), WORK((K+1)*(K+2)/2)
  !     A(I,J) = WORK(I+J*(J+1)/2),  I=1,J+1  J=1,K-1
  !     A(I,K) = W0RK(I+K*(K-1)/2)  I=1.K
  !     WORK(1) AND WORK((K+1)*(K+2)/2) ARE NOT USED.
  !* FIRST EXECUTABLE STATEMENT  BSPVD
  IF( K<1 ) THEN
    ERROR STOP 'BSPVD : K DOES NOT SATISFY K>=1'
  ELSEIF( Nderiv<1 .OR. Nderiv>K ) THEN
    ERROR STOP 'BSPVD : NDERIV DOES NOT SATISFY 1<=NDERIV<=K'
  ELSEIF( Ldvnik<K ) THEN
    ERROR STOP 'BSPVD : LDVNIK DOES NOT SATISFY LDVNIK>=K'
  ELSE
    ideriv = Nderiv
    kp1 = K + 1
    jj = kp1 - ideriv
    CALL BSPVN(T,jj,K,1,X,Ileft,Vnikx,Work,iwork)
    IF( ideriv/=1 ) THEN
      mhigh = ideriv
      DO m = 2, mhigh
        jp1mid = 1
        DO j = ideriv, K
          Vnikx(j,ideriv) = Vnikx(jp1mid,1)
          jp1mid = jp1mid + 1
        END DO
        ideriv = ideriv - 1
        jj = kp1 - ideriv
        CALL BSPVN(T,jj,K,2,X,Ileft,Vnikx,Work,iwork)
      END DO
      !
      jm = kp1*(kp1+1)/2
      DO l = 1, jm
        Work(l) = 0._SP
      END DO
      !     A(I,I) = WORK(I*(I+3)/2) = 1.0       I = 1,K
      l = 2
      j = 0
      DO i = 1, K
        j = j + l
        Work(j) = 1._SP
        l = l + 1
      END DO
      kmd = K
      DO m = 2, mhigh
        kmd = kmd - 1
        fkmd = kmd
        i = Ileft
        j = K
        jj = j*(j+1)/2
        jm = jj - j
        DO ldummy = 1, kmd
          ipkmd = i + kmd
          factor = fkmd/(T(ipkmd)-T(i))
          DO l = 1, j
            Work(l+jj) = (Work(l+jj)-Work(l+jm))*factor
          END DO
          i = i - 1
          j = j - 1
          jj = jm
          jm = jm - j
        END DO
        !
        DO i = 1, K
          v = 0._SP
          jlow = MAX(i,m)
          jj = jlow*(jlow+1)/2
          DO j = jlow, K
            v = Work(i+jj)*Vnikx(j,m) + v
            jj = jj + j + 1
          END DO
          Vnikx(i,m) = v
        END DO
      END DO
    END IF
  END IF

  RETURN
END SUBROUTINE BSPVD