!** CGEFA
PURE SUBROUTINE CGEFA(A,Lda,N,Ipvt,Info)
  !> Factor a matrix using Gaussian elimination.
  !***
  ! **Library:**   SLATEC (LINPACK)
  !***
  ! **Category:**  D2C1
  !***
  ! **Type:**      COMPLEX (SGEFA-S, DGEFA-D, CGEFA-C)
  !***
  ! **Keywords:**  GENERAL MATRIX, LINEAR ALGEBRA, LINPACK, MATRIX FACTORIZATION
  !***
  ! **Author:**  Moler, C. B., (U. of New Mexico)
  !***
  ! **Description:**
  !
  !     CGEFA factors a complex matrix by Gaussian elimination.
  !
  !     CGEFA is usually called by CGECO, but it can be called
  !     directly with a saving in time if  RCOND  is not needed.
  !     (Time for CGECO) = (1 + 9/N)*(Time for CGEFA) .
  !
  !     On Entry
  !
  !        A       COMPLEX(LDA, N)
  !                the matrix to be factored.
  !
  !        LDA     INTEGER
  !                the leading dimension of the array  A .
  !
  !        N       INTEGER
  !                the order of the matrix  A .
  !
  !     On Return
  !
  !        A       an upper triangular matrix and the multipliers
  !                which were used to obtain it.
  !                The factorization can be written  A = L*U  where
  !                L  is a product of permutation and unit lower
  !                triangular matrices and  U  is upper triangular.
  !
  !        IPVT    INTEGER(N)
  !                an integer vector of pivot indices.
  !
  !        INFO    INTEGER
  !                = 0  normal value.
  !                = K  if  U(K,K) = 0.0 .  This is not an error
  !                     condition for this subroutine, but it does
  !                     indicate that CGESL or CGEDI will divide by zero
  !                     if called.  Use  RCOND  in CGECO for a reliable
  !                     indication of singularity.
  !
  !***
  ! **References:**  J. J. Dongarra, J. R. Bunch, C. B. Moler, and G. W.
  !                 Stewart, LINPACK Users' Guide, SIAM, 1979.
  !***
  ! **Routines called:**  CAXPY, CSCAL, ICAMAX

  !* REVISION HISTORY  (YYMMDD)
  !   780814  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900326  Removed duplicate information from DESCRIPTIONsection.  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE blas, ONLY : CAXPY, SCABS1, ICAMAX

  INTEGER, INTENT(IN) :: Lda, N
  INTEGER, INTENT(OUT) :: Ipvt(N), Info
  COMPLEX(SP), INTENT(INOUT) :: A(Lda,N)
  !
  COMPLEX(SP) :: t
  INTEGER :: j, k, kp1, l, nm1
  !
  !     GAUSSIAN ELIMINATION WITH PARTIAL PIVOTING
  !
  !* FIRST EXECUTABLE STATEMENT  CGEFA
  Info = 0
  nm1 = N - 1
  IF( nm1>=1 ) THEN
    DO k = 1, nm1
      kp1 = k + 1
      !
      !        FIND L = PIVOT INDEX
      !
      l = ICAMAX(N-k+1,A(k,k),1) + k - 1
      Ipvt(k) = l
      !
      !        ZERO PIVOT IMPLIES THIS COLUMN ALREADY TRIANGULARIZED
      !
      IF( SCABS1(A(l,k))==0._SP ) THEN
        Info = k
      ELSE
        !
        !           INTERCHANGE IF NECESSARY
        !
        IF( l/=k ) THEN
          t = A(l,k)
          A(l,k) = A(k,k)
          A(k,k) = t
        END IF
        !
        !           COMPUTE MULTIPLIERS
        !
        t = -(1._SP,0._SP)/A(k,k)
        A(k+1:N,k) = t*A(k+1:N,k)
        !
        !           ROW ELIMINATION WITH COLUMN INDEXING
        !
        DO j = kp1, N
          t = A(l,j)
          IF( l/=k ) THEN
            A(l,j) = A(k,j)
            A(k,j) = t
          END IF
          CALL CAXPY(N-k,t,A(k+1,k),1,A(k+1,j),1)
        END DO
      END IF
    END DO
  END IF
  Ipvt(N) = N
  IF( SCABS1(A(N,N))==0._SP ) Info = N

END SUBROUTINE CGEFA