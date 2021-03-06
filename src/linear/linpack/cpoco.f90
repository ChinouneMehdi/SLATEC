!** CPOCO
PURE SUBROUTINE CPOCO(A,Lda,N,Rcond,Z,Info)
  !> Factor a complex Hermitian positive definite matrix
  !  and estimate the condition number of the matrix.
  !***
  ! **Library:**   SLATEC (LINPACK)
  !***
  ! **Category:**  D2D1B
  !***
  ! **Type:**      COMPLEX (SPOCO-S, DPOCO-D, CPOCO-C)
  !***
  ! **Keywords:**  CONDITION NUMBER, LINEAR ALGEBRA, LINPACK,
  !             MATRIX FACTORIZATION, POSITIVE DEFINITE
  !***
  ! **Author:**  Moler, C. B., (U. of New Mexico)
  !***
  ! **Description:**
  !
  !     CPOCO factors a complex Hermitian positive definite matrix
  !     and estimates the condition of the matrix.
  !
  !     If  RCOND  is not needed, CPOFA is slightly faster.
  !     To solve  A*X = B, follow CPOCO by CPOSL.
  !     To compute  INVERSE(A)*C, follow CPOCO by CPOSL.
  !     To compute  DETERMINANT(A), follow CPOCO by CPODI.
  !     To compute  INVERSE(A), follow CPOCO by CPODI.
  !
  !     On Entry
  !
  !        A       COMPLEX(LDA, N)
  !                the Hermitian matrix to be factored.  Only the
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
  !        A       an upper triangular matrix  R  so that  A =
  !                CTRANS(R)*R where  CTRANS(R)  is the conjugate
  !                transpose.  The strict lower triangle is unaltered.
  !                If  INFO /= 0, the factorization is not complete.
  !
  !        RCOND   REAL
  !                an estimate of the reciprocal condition of  A .
  !                For the system  A*X = B, relative perturbations
  !                in  A  and  B  of size  EPSILON  may cause
  !                relative perturbations in  X  of size  EPSILON/RCOND .
  !                If  RCOND  is so small that the logical expression
  !                           1.0 + RCOND = 1.0
  !                is true, then  A  may be singular to working
  !                precision.  In particular,  RCOND  is zero  if
  !                exact singularity is detected or the estimate
  !                underflows.  If INFO /= 0, RCOND is unchanged.
  !
  !        Z       COMPLEX(N)
  !                a work vector whose contents are usually unimportant.
  !                If  A  is close to a singular matrix, then  Z  is
  !                an approximate null vector in the sense that
  !                NORM(A*Z) = RCOND*NORM(A)*NORM(Z) .
  !                If  INFO /= 0, Z  is unchanged.
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
  ! **Routines called:**  CAXPY, CDOTC, CPOFA, CSSCAL, SCASUM

  !* REVISION HISTORY  (YYMMDD)
  !   780814  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900326  Removed duplicate information from DESCRIPTIONsection.  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE blas, ONLY : CAXPY, SCABS1, SCASUM

  INTEGER, INTENT(IN) :: Lda, N
  INTEGER, INTENT(OUT) :: Info
  REAL(SP), INTENT(OUT) :: Rcond
  COMPLEX(SP), INTENT(INOUT) :: A(Lda,N)
  COMPLEX(SP), INTENT(OUT) :: Z(N)
  !
  COMPLEX(SP) :: ek, t, wk, wkm
  REAL(SP) :: anorm, s, sm, ynorm
  INTEGER :: i, j, jm1, k, kb, kp1
  !
  !     FIND NORM OF A USING ONLY UPPER HALF
  !
  !* FIRST EXECUTABLE STATEMENT  CPOCO
  DO j = 1, N
    Z(j) = CMPLX(SCASUM(j,A(1,j),1),0._SP,SP)
    jm1 = j - 1
    IF( jm1>=1 ) THEN
      DO i = 1, jm1
        Z(i) = CMPLX(REAL(Z(i))+SCABS1(A(i,j)),0._SP,SP)
      END DO
    END IF
  END DO
  anorm = 0._SP
  DO j = 1, N
    anorm = MAX(anorm,REAL(Z(j)))
  END DO
  !
  !     FACTOR
  !
  CALL CPOFA(A,Lda,N,Info)
  IF( Info==0 ) THEN
    !
    !        RCOND = 1/(NORM(A)*(ESTIMATE OF NORM(INVERSE(A)))) .
    !        ESTIMATE = NORM(Z)/NORM(Y) WHERE  A*Z = Y  AND  A*Y = E .
    !        THE COMPONENTS OF  E  ARE CHOSEN TO CAUSE MAXIMUM LOCAL
    !        GROWTH IN THE ELEMENTS OF W  WHERE  CTRANS(R)*W = E .
    !        THE VECTORS ARE FREQUENTLY RESCALED TO AVOID OVERFLOW.
    !
    !        SOLVE CTRANS(R)*W = E
    !
    ek = (1._SP,0._SP)
    DO j = 1, N
      Z(j) = (0._SP,0._SP)
    END DO
    DO k = 1, N
      IF( SCABS1(Z(k))/=0._SP ) ek = CSIGN1(ek,-Z(k))
      IF( SCABS1(ek-Z(k))>REAL(A(k,k)) ) THEN
        s = REAL(A(k,k))/SCABS1(ek-Z(k))
        Z = s*Z
        ek = CMPLX(s,0._SP,SP)*ek
      END IF
      wk = ek - Z(k)
      wkm = -ek - Z(k)
      s = SCABS1(wk)
      sm = SCABS1(wkm)
      wk = wk/A(k,k)
      wkm = wkm/A(k,k)
      kp1 = k + 1
      IF( kp1<=N ) THEN
        DO j = kp1, N
          sm = sm + SCABS1(Z(j)+wkm*CONJG(A(k,j)))
          Z(j) = Z(j) + wk*CONJG(A(k,j))
          s = s + SCABS1(Z(j))
        END DO
        IF( s<sm ) THEN
          t = wkm - wk
          wk = wkm
          DO j = kp1, N
            Z(j) = Z(j) + t*CONJG(A(k,j))
          END DO
        END IF
      END IF
      Z(k) = wk
    END DO
    s = 1._SP/SCASUM(N,Z,1)
    Z = s*Z
    !
    !        SOLVE R*Y = W
    !
    DO kb = 1, N
      k = N + 1 - kb
      IF( SCABS1(Z(k))>REAL(A(k,k)) ) THEN
        s = REAL(A(k,k))/SCABS1(Z(k))
        Z = s*Z
      END IF
      Z(k) = Z(k)/A(k,k)
      t = -Z(k)
      CALL CAXPY(k-1,t,A(1,k),1,Z(1),1)
    END DO
    s = 1._SP/SCASUM(N,Z,1)
    Z = s*Z
    !
    ynorm = 1._SP
    !
    !        SOLVE CTRANS(R)*V = Y
    !
    DO k = 1, N
      Z(k) = Z(k) - DOT_PRODUCT(A(1:k-1,k),Z(1:k-1))
      IF( SCABS1(Z(k))>REAL(A(k,k)) ) THEN
        s = REAL(A(k,k))/SCABS1(Z(k))
        Z = s*Z
        ynorm = s*ynorm
      END IF
      Z(k) = Z(k)/A(k,k)
    END DO
    s = 1._SP/SCASUM(N,Z,1)
    Z = s*Z
    ynorm = s*ynorm
    !
    !        SOLVE R*Z = V
    !
    DO kb = 1, N
      k = N + 1 - kb
      IF( SCABS1(Z(k))>REAL(A(k,k)) ) THEN
        s = REAL(A(k,k))/SCABS1(Z(k))
        Z = s*Z
        ynorm = s*ynorm
      END IF
      Z(k) = Z(k)/A(k,k)
      t = -Z(k)
      CALL CAXPY(k-1,t,A(1,k),1,Z(1),1)
    END DO
    !        MAKE ZNORM = 1.0
    s = 1._SP/SCASUM(N,Z,1)
    Z = s*Z
    ynorm = s*ynorm
    !
    IF( anorm/=0._SP ) Rcond = ynorm/anorm
    IF( anorm==0._SP ) Rcond = 0._SP
  END IF

END SUBROUTINE CPOCO