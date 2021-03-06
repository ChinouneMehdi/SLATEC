!** U12LS
PURE SUBROUTINE U12LS(A,Mda,M,N,B,Mdb,Nb,Mode,Krank,Rnorm,H,W,Ic,Ir)
  !> Subsidiary to LLSIA
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (U12LS-S, DU12LS-D)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !        Given the Householder QR factorization of A, this
  !        subroutine solves the system AX=B. If the system
  !        is of reduced rank, this routine returns a solution
  !        according to the selected mode.
  !
  !       Note - If MODE/=2, W is never accessed.
  !
  !***
  ! **See also:**  LLSIA
  !***
  ! **Routines called:**  SAXPY, SDOT, SNRM2, SSWAP

  !* REVISION HISTORY  (YYMMDD)
  !   810801  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  USE blas, ONLY : SAXPY, SSWAP

  INTEGER, INTENT(IN) :: Krank, M, Mda, Mdb, Mode, N, Nb
  INTEGER, INTENT(INOUT) :: Ic(N), Ir(M)
  REAL(SP), INTENT(IN) :: H(N), W(4*N)
  REAL(SP), INTENT(INOUT) :: A(Mda,N), B(Mdb,Nb)
  REAL(SP), INTENT(OUT) :: Rnorm(Nb)
  INTEGER :: i, ij, im1, j, jb, k, kp1, nmk
  REAL(SP) :: bb, tt
  !* FIRST EXECUTABLE STATEMENT  U12LS
  k = Krank
  kp1 = k + 1
  !
  !        RANK=0
  !
  IF( k>0 ) THEN
    !
    !     REORDER B TO REFLECT ROW INTERCHANGES
    !
    i = 0
    DO
      i = i + 1
      IF( i==M ) THEN
        DO i = 1, M
          Ir(i) = ABS(Ir(i))
        END DO
        !
        !     APPLY HOUSEHOLDER TRANSFORMATIONS TO B
        !
        DO j = 1, k
          tt = A(j,j)
          A(j,j) = H(j)
          DO i = 1, Nb
            bb = -DOT_PRODUCT(A(j:M,j),B(j:M,i))/H(j)
            CALL SAXPY(M-j+1,bb,A(j:M,j),1,B(j:M,i),1)
          END DO
          A(j,j) = tt
        END DO
        !
        !        FIND NORMS OF RESIDUAL VECTOR(S)..(BEFORE OVERWRITE B)
        !
        DO jb = 1, Nb
          Rnorm(jb) = NORM2(B(kp1:M,jb))
        END DO
        !
        !     BACK SOLVE UPPER TRIANGULAR R
        !
        i = k
        DO
          DO jb = 1, Nb
            B(i,jb) = B(i,jb)/A(i,i)
          END DO
          IF( i==1 ) THEN
            !
            !     RANK LT N
            !
            !      TRUNCATED SOLUTION
            !
            IF( k/=N ) THEN
              DO jb = 1, Nb
                DO i = kp1, N
                  B(i,jb) = 0._SP
                END DO
              END DO
              IF( Mode/=1 ) THEN
                !
                !      MINIMAL LENGTH SOLUTION
                !
                nmk = N - k
                DO jb = 1, Nb
                  DO i = 1, k
                    tt = -DOT_PRODUCT(A(i,kp1:N),B(kp1:N,jb))/W(i)
                    tt = tt - B(i,jb)
                    CALL SAXPY(nmk,tt,A(i,kp1:N),1,B(kp1:N,jb),1)
                    B(i,jb) = B(i,jb) + tt*W(i)
                  END DO
                END DO
              END IF
            END IF
            !
            !
            !     REORDER B TO REFLECT COLUMN INTERCHANGES
            !
            i = 0
            DO
              i = i + 1
              IF( i==N ) THEN
                DO i = 1, N
                  Ic(i) = ABS(Ic(i))
                END DO
                RETURN
              ELSE
                j = Ic(i)
                IF( j/=i ) THEN
                  IF( j>=0 ) THEN
                    Ic(i) = -Ic(i)
                    DO
                      CALL SSWAP(Nb,B(j,1),Mdb,B(i,1),Mdb)
                      ij = Ic(j)
                      Ic(j) = -Ic(j)
                      j = ij
                      IF( j==i ) EXIT
                    END DO
                  END IF
                END IF
              END IF
            END DO
          ELSE
            im1 = i - 1
            DO jb = 1, Nb
              CALL SAXPY(im1,-B(i,jb),A(1:im1,i),1,B(1:im1,jb),1)
            END DO
            i = im1
          END IF
        END DO
      ELSE
        j = Ir(i)
        IF( j/=i ) THEN
          IF( j>=0 ) THEN
            Ir(i) = -Ir(i)
            DO jb = 1, Nb
              Rnorm(jb) = B(i,jb)
            END DO
            ij = i
            DO
              DO jb = 1, Nb
                B(ij,jb) = B(j,jb)
              END DO
              ij = j
              j = Ir(ij)
              Ir(ij) = -Ir(ij)
              IF( j==i ) THEN
                DO jb = 1, Nb
                  B(ij,jb) = Rnorm(jb)
                END DO
                EXIT
              END IF
            END DO
          END IF
        END IF
      END IF
    END DO
  ELSE
    DO jb = 1, Nb
      Rnorm(jb) = NORM2(B(1:M,jb))
    END DO
    DO jb = 1, Nb
      DO i = 1, N
        B(i,jb) = 0._SP
      END DO
    END DO
    RETURN
  END IF
  !
  !        SOLUTION VECTORS ARE IN FIRST N ROWS OF B(,)
  !
  RETURN
END SUBROUTINE U12LS