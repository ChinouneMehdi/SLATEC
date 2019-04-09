!** SPOCO
SUBROUTINE SPOCO(A,Lda,N,Rcond,Z,Info)
  IMPLICIT NONE
  !>
  !***
  !  Factor a real symmetric positive definite matrix
  !            and estimate the condition number of the matrix.
  !***
  ! **Library:**   SLATEC (LINPACK)
  !***
  ! **Category:**  D2B1B
  !***
  ! **Type:**      SINGLE PRECISION (SPOCO-S, DPOCO-D, CPOCO-C)
  !***
  ! **Keywords:**  CONDITION NUMBER, LINEAR ALGEBRA, LINPACK,
  !             MATRIX FACTORIZATION, POSITIVE DEFINITE
  !***
  ! **Author:**  Moler, C. B., (U. of New Mexico)
  !***
  ! **Description:**
  !
  !     SPOCO factors a real symmetric positive definite matrix
  !     and estimates the condition of the matrix.
  !
  !     If  RCOND  is not needed, SPOFA is slightly faster.
  !     To solve  A*X = B, follow SPOCO by SPOSL.
  !     To compute  INVERSE(A)*C, follow SPOCO by SPOSL.
  !     To compute  DETERMINANT(A), follow SPOCO by SPODI.
  !     To compute  INVERSE(A), follow SPOCO by SPODI.
  !
  !     On Entry
  !
  !        A       REAL(LDA, N)
  !                the symmetric matrix to be factored.  Only the
  !                diagonal and upper triangle are used.
  !
  !        LDA     INTEGER
  !                the leading dimension of the array  A .
  !
  !        N       INTEGER
  !                the order of the matrix  A .
  !
  !     On Return
  !
  !        A       an upper triangular matrix  R  so that  A = TRANS(R)*R
  !                where  TRANS(R)  is the transpose.
  !                The strict lower triangle is unaltered.
  !                If  INFO .NE. 0, the factorization is not complete.
  !
  !        RCOND   REAL
  !                an estimate of the reciprocal condition of  A .
  !                For the system  A*X = B, relative perturbations
  !                in  A  and  B  of size  EPSILON  may cause
  !                relative perturbations in  X  of size  EPSILON/RCOND .
  !                If  RCOND  is so small that the logical expression
  !                           1.0 + RCOND .EQ. 1.0
  !                is true, then  A  may be singular to working
  !                precision.  In particular,  RCOND  is zero  if
  !                exact singularity is detected or the estimate
  !                underflows.  If INFO .NE. 0, RCOND is unchanged.
  !
  !        Z       REAL(N)
  !                a work vector whose contents are usually unimportant.
  !                If  A  is close to a singular matrix, then  Z  is
  !                an approximate null vector in the sense that
  !                NORM(A*Z) = RCOND*NORM(A)*NORM(Z) .
  !                If  INFO .NE. 0, Z  is unchanged.
  !
  !        INFO    INTEGER
  !                = 0  for normal return.
  !                = K  signals an error condition.  The leading minor
  !                     of order  K  is not positive definite.
  !
  !***
  ! **References:**  J. J. Dongarra, J. R. Bunch, C. B. Moler, and G. W.
  !                 Stewart, LINPACK Users' Guide, SIAM, 1979.
  !***
  ! **Routines called:**  SASUM, SAXPY, SDOT, SPOFA, SSCAL

  !* REVISION HISTORY  (YYMMDD)
  !   780814  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900326  Removed duplicate information from DESCRIPTION section.
  !           (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER Lda, N, Info
  REAL A(Lda,*), Z(*)
  REAL Rcond
  !
  REAL SDOT, ek, t, wk, wkm
  REAL anorm, s, SASUM, sm, ynorm
  INTEGER i, j, jm1, k, kb, kp1
  !
  !     FIND NORM OF A USING ONLY UPPER HALF
  !
  !* FIRST EXECUTABLE STATEMENT  SPOCO
  DO j = 1, N
    Z(j) = SASUM(j,A(1,j),1)
    jm1 = j - 1
    IF ( jm1>=1 ) THEN
      DO i = 1, jm1
        Z(i) = Z(i) + ABS(A(i,j))
      END DO
    END IF
  END DO
  anorm = 0.0E0
  DO j = 1, N
    anorm = MAX(anorm,Z(j))
  END DO
  !
  !     FACTOR
  !
  CALL SPOFA(A,Lda,N,Info)
  IF ( Info==0 ) THEN
    !
    !        RCOND = 1/(NORM(A)*(ESTIMATE OF NORM(INVERSE(A)))) .
    !        ESTIMATE = NORM(Z)/NORM(Y) WHERE  A*Z = Y  AND  A*Y = E .
    !        THE COMPONENTS OF  E  ARE CHOSEN TO CAUSE MAXIMUM LOCAL
    !        GROWTH IN THE ELEMENTS OF W  WHERE  TRANS(R)*W = E .
    !        THE VECTORS ARE FREQUENTLY RESCALED TO AVOID OVERFLOW.
    !
    !        SOLVE TRANS(R)*W = E
    !
    ek = 1.0E0
    DO j = 1, N
      Z(j) = 0.0E0
    END DO
    DO k = 1, N
      IF ( Z(k)/=0.0E0 ) ek = SIGN(ek,-Z(k))
      IF ( ABS(ek-Z(k))>A(k,k) ) THEN
        s = A(k,k)/ABS(ek-Z(k))
        CALL SSCAL(N,s,Z,1)
        ek = s*ek
      END IF
      wk = ek - Z(k)
      wkm = -ek - Z(k)
      s = ABS(wk)
      sm = ABS(wkm)
      wk = wk/A(k,k)
      wkm = wkm/A(k,k)
      kp1 = k + 1
      IF ( kp1<=N ) THEN
        DO j = kp1, N
          sm = sm + ABS(Z(j)+wkm*A(k,j))
          Z(j) = Z(j) + wk*A(k,j)
          s = s + ABS(Z(j))
        END DO
        IF ( s<sm ) THEN
          t = wkm - wk
          wk = wkm
          DO j = kp1, N
            Z(j) = Z(j) + t*A(k,j)
          END DO
        END IF
      END IF
      Z(k) = wk
    END DO
    s = 1.0E0/SASUM(N,Z,1)
    CALL SSCAL(N,s,Z,1)
    !
    !        SOLVE R*Y = W
    !
    DO kb = 1, N
      k = N + 1 - kb
      IF ( ABS(Z(k))>A(k,k) ) THEN
        s = A(k,k)/ABS(Z(k))
        CALL SSCAL(N,s,Z,1)
      END IF
      Z(k) = Z(k)/A(k,k)
      t = -Z(k)
      CALL SAXPY(k-1,t,A(1,k),1,Z(1),1)
    END DO
    s = 1.0E0/SASUM(N,Z,1)
    CALL SSCAL(N,s,Z,1)
    !
    ynorm = 1.0E0
    !
    !        SOLVE TRANS(R)*V = Y
    !
    DO k = 1, N
      Z(k) = Z(k) - SDOT(k-1,A(1,k),1,Z(1),1)
      IF ( ABS(Z(k))>A(k,k) ) THEN
        s = A(k,k)/ABS(Z(k))
        CALL SSCAL(N,s,Z,1)
        ynorm = s*ynorm
      END IF
      Z(k) = Z(k)/A(k,k)
    END DO
    s = 1.0E0/SASUM(N,Z,1)
    CALL SSCAL(N,s,Z,1)
    ynorm = s*ynorm
    !
    !        SOLVE R*Z = V
    !
    DO kb = 1, N
      k = N + 1 - kb
      IF ( ABS(Z(k))>A(k,k) ) THEN
        s = A(k,k)/ABS(Z(k))
        CALL SSCAL(N,s,Z,1)
        ynorm = s*ynorm
      END IF
      Z(k) = Z(k)/A(k,k)
      t = -Z(k)
      CALL SAXPY(k-1,t,A(1,k),1,Z(1),1)
    END DO
    !        MAKE ZNORM = 1.0
    s = 1.0E0/SASUM(N,Z,1)
    CALL SSCAL(N,s,Z,1)
    ynorm = s*ynorm
    !
    IF ( anorm/=0.0E0 ) Rcond = ynorm/anorm
    IF ( anorm==0.0E0 ) Rcond = 0.0E0
  END IF
END SUBROUTINE SPOCO