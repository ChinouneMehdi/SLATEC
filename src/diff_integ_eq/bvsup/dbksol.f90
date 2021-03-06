!** DBKSOL
PURE SUBROUTINE DBKSOL(N,A,X)
  !> Subsidiary to DBVSUP
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      DOUBLE PRECISION (BKSOL-S, DBKSOL-D)
  !***
  ! **Author:**  Watts, H. A., (SNLA)
  !***
  ! **Description:**
  !
  !- *********************************************************************
  !     Solution of an upper triangular linear system by
  !     back-substitution
  !
  !     The matrix A is assumed to be stored in a linear
  !     array proceeding in a row-wise manner. The
  !     vector X contains the given constant vector on input
  !     and contains the solution on return.
  !     The actual diagonal of A is unity while a diagonal
  !     scaling matrix is stored there.
  !- *********************************************************************
  !
  !***
  ! **See also:**  DBVSUP
  !***
  ! **Routines called:**  DDOT

  !* REVISION HISTORY  (YYMMDD)
  !   750601  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  !   910722  Updated AUTHOR section.  (ALS)
  !
  INTEGER, INTENT(IN) :: N
  REAL(DP), INTENT(IN) :: A(N*(N+1))
  REAL(DP), INTENT(INOUT) :: X(N)
  !
  INTEGER :: j, k, m, nm1
  !
  !* FIRST EXECUTABLE STATEMENT  DBKSOL
  m = (N*(N+1))/2
  X(N) = X(N)*A(m)
  nm1 = N - 1
  IF( nm1>=1 ) THEN
    DO k = 1, nm1
      j = N - k
      m = m - k - 1
      X(j) = X(j)*A(m) - DOT_PRODUCT(A(m+1:m+k),X(j+1:j+k))
    END DO
  END IF
  !
END SUBROUTINE DBKSOL