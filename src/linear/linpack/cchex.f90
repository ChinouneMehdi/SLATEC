!** CCHEX
SUBROUTINE CCHEX(R,Ldr,P,K,L,Z,Ldz,Nz,C,S,Job)
  IMPLICIT NONE
  !>
  !***
  !  Update the Cholesky factorization  A=TRANS(R)*R  of a
  !            positive definite matrix A of order P under diagonal
  !            permutations of the form  TRANS(E)*A*E, where E is a
  !            permutation matrix.
  !***
  ! **Library:**   SLATEC (LINPACK)
  !***
  ! **Category:**  D7B
  !***
  ! **Type:**      COMPLEX (SCHEX-S, DCHEX-D, CCHEX-C)
  !***
  ! **Keywords:**  CHOLESKY DECOMPOSITION, EXCHANGE, LINEAR ALGEBRA, LINPACK,
  !             MATRIX, POSITIVE DEFINITE
  !***
  ! **Author:**  Stewart, G. W., (U. of Maryland)
  !***
  ! **Description:**
  !
  !     CCHEX updates the Cholesky factorization
  !
  !                   A = CTRANS(R)*R
  !
  !     of a positive definite matrix A of order P under diagonal
  !     permutations of the form
  !
  !                   TRANS(E)*A*E
  !
  !     where E is a permutation matrix.  Specifically, given
  !     an upper triangular matrix R and a permutation matrix
  !     E (which is specified by K, L, and JOB), CCHEX determines
  !     a unitary matrix U such that
  !
  !                           U*R*E = RR,
  !
  !     where RR is upper triangular.  At the users option, the
  !     transformation U will be multiplied into the array Z.
  !     If A = CTRANS(X)*X, so that R is the triangular part of the
  !     QR factorization of X, then RR is the triangular part of the
  !     QR factorization of X*E, i.e. X with its columns permuted.
  !     For a less terse description of what CCHEX does and how
  !     it may be applied, see the LINPACK Guide.
  !
  !     The matrix Q is determined as the product U(L-K)*...*U(1)
  !     of plane rotations of the form
  !
  !                           (    C(I)       S(I) )
  !                           (                    ) ,
  !                           ( -CONJG(S(I))  C(I) )
  !
  !     where C(I) is real.  The rows these rotations operate on
  !     are described below.
  !
  !     There are two types of permutations, which are determined
  !     by the value of JOB.
  !
  !     1. Right circular shift (JOB = 1).
  !
  !         The columns are rearranged in the following order.
  !
  !                1,...,K-1,L,K,K+1,...,L-1,L+1,...,P.
  !
  !         U is the product of L-K rotations U(I), where U(I)
  !         acts in the (L-I,L-I+1)-plane.
  !
  !     2. Left circular shift (JOB = 2).
  !         The columns are rearranged in the following order
  !
  !                1,...,K-1,K+1,K+2,...,L,K,L+1,...,P.
  !
  !         U is the product of L-K rotations U(I), where U(I)
  !         acts in the (K+I-1,K+I)-plane.
  !
  !     On Entry
  !
  !         R      COMPLEX(LDR,P), where LDR .GE. P.
  !                R contains the upper triangular factor
  !                that is to be updated.  Elements of R
  !                below the diagonal are not referenced.
  !
  !         LDR    INTEGER.
  !                LDR is the leading dimension of the array R.
  !
  !         P      INTEGER.
  !                P is the order of the matrix R.
  !
  !         K      INTEGER.
  !                K is the first column to be permuted.
  !
  !         L      INTEGER.
  !                L is the last column to be permuted.
  !                L must be strictly greater than K.
  !
  !         Z      COMPLEX(LDZ,NZ), where LDZ .GE. P.
  !                Z is an array of NZ P-vectors into which the
  !                transformation U is multiplied.  Z is
  !                not referenced if NZ = 0.
  !
  !         LDZ    INTEGER.
  !                LDZ is the leading dimension of the array Z.
  !
  !         NZ     INTEGER.
  !                NZ is the number of columns of the matrix Z.
  !
  !         JOB    INTEGER.
  !                JOB determines the type of permutation.
  !                       JOB = 1  right circular shift.
  !                       JOB = 2  left circular shift.
  !
  !     On Return
  !
  !         R      contains the updated factor.
  !
  !         Z      contains the updated matrix Z.
  !
  !         C      REAL(P).
  !                C contains the cosines of the transforming rotations.
  !
  !         S      COMPLEX(P).
  !                S contains the sines of the transforming rotations.
  !
  !***
  ! **References:**  J. J. Dongarra, J. R. Bunch, C. B. Moler, and G. W.
  !                 Stewart, LINPACK Users' Guide, SIAM, 1979.
  !***
  ! **Routines called:**  CROTG

  !* REVISION HISTORY  (YYMMDD)
  !   780814  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900326  Removed duplicate information from DESCRIPTION section.
  !           (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER Ldr, P, K, L, Ldz, Nz, Job
  COMPLEX R(Ldr,*), Z(Ldz,*), S(*)
  REAL C(*)
  !
  INTEGER i, ii, il, iu, j, jj, km1, kp1, lmk, lm1
  COMPLEX t
  !
  !     INITIALIZE
  !
  !* FIRST EXECUTABLE STATEMENT  CCHEX
  km1 = K - 1
  kp1 = K + 1
  lmk = L - K
  lm1 = L - 1
  !
  !     PERFORM THE APPROPRIATE TASK.
  !
  IF ( Job==2 ) THEN
    !
    !     LEFT CIRCULAR SHIFT
    !
    !
    !        REORDER THE COLUMNS
    !
    DO i = 1, K
      ii = lmk + i
      S(ii) = R(i,K)
    END DO
    DO j = K, lm1
      DO i = 1, j
        R(i,j) = R(i,j+1)
      END DO
      jj = j - km1
      S(jj) = R(j+1,j+1)
    END DO
    DO i = 1, K
      ii = lmk + i
      R(i,L) = S(ii)
    END DO
    DO i = kp1, L
      R(i,L) = (0.0E0,0.0E0)
    END DO
    !
    !        REDUCTION LOOP.
    !
    DO j = K, P
      IF ( j/=K ) THEN
        !
        !              APPLY THE ROTATIONS.
        !
        iu = MIN(j-1,L-1)
        DO i = K, iu
          ii = i - K + 1
          t = C(ii)*R(i,j) + S(ii)*R(i+1,j)
          R(i+1,j) = C(ii)*R(i+1,j) - CONJG(S(ii))*R(i,j)
          R(i,j) = t
        END DO
      END IF
      IF ( j<L ) THEN
        jj = j - K + 1
        t = S(jj)
        CALL CROTG(R(j,j),t,C(jj),S(jj))
      END IF
    END DO
    !
    !        APPLY THE ROTATIONS TO Z.
    !
    IF ( Nz>=1 ) THEN
      DO j = 1, Nz
        DO i = K, lm1
          ii = i - km1
          t = C(ii)*Z(i,j) + S(ii)*Z(i+1,j)
          Z(i+1,j) = C(ii)*Z(i+1,j) - CONJG(S(ii))*Z(i,j)
          Z(i,j) = t
        END DO
      END DO
    END IF
  ELSE
    !
    !     RIGHT CIRCULAR SHIFT.
    !
    !
    !        REORDER THE COLUMNS.
    !
    DO i = 1, L
      ii = L - i + 1
      S(i) = R(ii,L)
    END DO
    DO jj = K, lm1
      j = lm1 - jj + K
      DO i = 1, j
        R(i,j+1) = R(i,j)
      END DO
      R(j+1,j+1) = (0.0E0,0.0E0)
    END DO
    IF ( K/=1 ) THEN
      DO i = 1, km1
        ii = L - i + 1
        R(i,K) = S(ii)
      END DO
    END IF
    !
    !        CALCULATE THE ROTATIONS.
    !
    t = S(1)
    DO i = 1, lmk
      CALL CROTG(S(i+1),t,C(i),S(i))
      t = S(i+1)
    END DO
    R(K,K) = t
    DO j = kp1, P
      il = MAX(1,L-j+1)
      DO ii = il, lmk
        i = L - ii
        t = C(ii)*R(i,j) + S(ii)*R(i+1,j)
        R(i+1,j) = C(ii)*R(i+1,j) - CONJG(S(ii))*R(i,j)
        R(i,j) = t
      END DO
    END DO
    !
    !        IF REQUIRED, APPLY THE TRANSFORMATIONS TO Z.
    !
    IF ( Nz>=1 ) THEN
      DO j = 1, Nz
        DO ii = 1, lmk
          i = L - ii
          t = C(ii)*Z(i,j) + S(ii)*Z(i+1,j)
          Z(i+1,j) = C(ii)*Z(i+1,j) - CONJG(S(ii))*Z(i,j)
          Z(i,j) = t
        END DO
      END DO
    END IF
  END IF
END SUBROUTINE CCHEX