!** CNBSL
PURE SUBROUTINE CNBSL(Abe,Lda,N,Ml,Mu,Ipvt,B,Job)
  !> Solve a complex band system using the factors computed by CNBCO or CNBFA.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  D2C2
  !***
  ! **Type:**      COMPLEX (SNBSL-S, DNBSL-D, CNBSL-C)
  !***
  ! **Keywords:**  BANDED, LINEAR EQUATIONS, NONSYMMETRIC, SOLVE
  !***
  ! **Author:**  Voorhees, E. A., (LANL)
  !***
  ! **Description:**
  !
  !     CNBSL solves the complex band system
  !     A * X = B  or  CTRANS(A) * X = B
  !     using the factors computed by CNBCO or CNBFA.
  !
  !     On Entry
  !
  !        ABE     COMPLEX(LDA, NC)
  !                the output from CNBCO or CNBFA.
  !                NC must be >= 2*ML+MU+1 .
  !
  !        LDA     INTEGER
  !                the leading dimension of the array  ABE .
  !
  !        N       INTEGER
  !                the order of the original matrix.
  !
  !        ML      INTEGER
  !                number of diagonals below the main diagonal.
  !
  !        MU      INTEGER
  !                number of diagonals above the main diagonal.
  !
  !        IPVT    INTEGER(N)
  !                the pivot vector from CNBCO or CNBFA.
  !
  !        B       COMPLEX(N)
  !                the right hand side vector.
  !
  !        JOB     INTEGER
  !                = 0         to solve  A*X = B .
  !                = nonzero   to solve  CTRANS(A)*X = B, where
  !                            CTRANS(A)  is the conjugate transpose.
  !
  !     On Return
  !
  !        B       the solution vector  X .
  !
  !     Error Condition
  !
  !        A division by zero will occur if the input factor contains a
  !        zero on the diagonal.  Technically this indicates singularity
  !        but it is often caused by improper arguments or improper
  !        setting of LDA.  It will not occur if the subroutines are
  !        called correctly and if CNBCO has set RCOND > 0.0
  !        or CNBFA has set INFO = 0 .
  !
  !     To compute  INVERSE(A) * C  where  C  is a matrix
  !     with  P  columns
  !           CALL CNBCO(ABE,LDA,N,ML,MU,IPVT,RCOND,Z)
  !           IF(RCOND is too small) GO TO ...
  !           DO 10 J = 1, P
  !             CALL CNBSL(ABE,LDA,N,ML,MU,IPVT,C(1,J),0)
  !        10 CONTINUE
  !
  !***
  ! **References:**  J. J. Dongarra, J. R. Bunch, C. B. Moler, and G. W.
  !                 Stewart, LINPACK Users' Guide, SIAM, 1979.
  !***
  ! **Routines called:**  CAXPY, CDOTC

  !* REVISION HISTORY  (YYMMDD)
  !   800730  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE blas, ONLY : CAXPY

  INTEGER, INTENT(IN) :: Lda, N, Ml, Mu, Ipvt(N), Job
  COMPLEX(SP), INTENT(IN) :: Abe(Lda,2*Ml+Mu+1)
  COMPLEX(SP), INTENT(INOUT) :: B(N)
  !
  COMPLEX(SP) :: t, v(2*Ml+Mu+1)
  INTEGER :: k, kb, l, lb, ldb, lm, m, mlm, nm1, i
  !* FIRST EXECUTABLE STATEMENT  CNBSL
  m = Mu + Ml + 1
  nm1 = N - 1
  ldb = 1 - Lda
  IF( Job/=0 ) THEN
    !
    !       JOB = NONZERO, SOLVE CTRANS(A) * X = B
    !       FIRST SOLVE  CTRANS(U)*Y = B
    !
    DO k = 1, N
      lm = MIN(k,m) - 1
      lb = k - lm
      DO i = 0, lm-1
        v(i+1) = Abe(k-1+i,Ml+2-i)
      END DO
      t = DOT_PRODUCT(v(1:lm),B(lb:k-1))
      B(k) = (B(k)-t)/CONJG(Abe(k,Ml+1))
    END DO
    !
    !       NOW SOLVE CTRANS(L)*X = Y
    !
    IF( Ml/=0 ) THEN
      IF( nm1>=1 ) THEN
        DO kb = 1, nm1
          k = N - kb
          lm = MIN(Ml,N-k)
          mlm = Ml - (lm-1)
          DO i = 0, lm-1
            v(i+1) = Abe(k+lm+i,mlm-i)
          END DO
          B(k) = B(k) + DOT_PRODUCT(v(1:lm),B(k+1:k+lm))
          l = Ipvt(k)
          IF( l/=k ) THEN
            t = B(l)
            B(l) = B(k)
            B(k) = t
          END IF
        END DO
      END IF
    END IF
  ELSE
    !
    !       JOB = 0, SOLVE  A * X = B
    !       FIRST SOLVE L*Y = B
    !
    IF( Ml/=0 ) THEN
      IF( nm1>=1 ) THEN
        DO k = 1, nm1
          lm = MIN(Ml,N-k)
          l = Ipvt(k)
          t = B(l)
          IF( l/=k ) THEN
            B(l) = B(k)
            B(k) = t
          END IF
          mlm = Ml - (lm-1)
          CALL CAXPY(lm,t,Abe(k+lm,mlm),ldb,B(k+1),1)
        END DO
      END IF
    END IF
    !
    !       NOW SOLVE  U*X = Y
    !
    DO kb = 1, N
      k = N + 1 - kb
      B(k) = B(k)/Abe(k,Ml+1)
      lm = MIN(k,m) - 1
      lb = k - lm
      t = -B(k)
      IF(k<=1) CYCLE
      CALL CAXPY(lm,t,Abe(k-1,Ml+2),ldb,B(lb),1)
    END DO
  END IF

END SUBROUTINE CNBSL