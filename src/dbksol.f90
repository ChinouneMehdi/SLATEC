!DECK DBKSOL
SUBROUTINE DBKSOL(N,A,X)
  IMPLICIT NONE
  !***BEGIN PROLOGUE  DBKSOL
  !***SUBSIDIARY
  !***PURPOSE  Subsidiary to DBVSUP
  !***LIBRARY   SLATEC
  !***TYPE      DOUBLE PRECISION (BKSOL-S, DBKSOL-D)
  !***AUTHOR  Watts, H. A., (SNLA)
  !***DESCRIPTION
  !
  ! **********************************************************************
  !     Solution of an upper triangular linear system by
  !     back-substitution
  !
  !     The matrix A is assumed to be stored in a linear
  !     array proceeding in a row-wise manner. The
  !     vector X contains the given constant vector on input
  !     and contains the solution on return.
  !     The actual diagonal of A is unity while a diagonal
  !     scaling matrix is stored there.
  ! **********************************************************************
  !
  !***SEE ALSO  DBVSUP
  !***ROUTINES CALLED  DDOT
  !***REVISION HISTORY  (YYMMDD)
  !   750601  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  !   910722  Updated AUTHOR section.  (ALS)
  !***END PROLOGUE  DBKSOL
  !
  REAL(8) :: DDOT
  INTEGER j, k, m, N, nm1
  REAL(8) :: A(*), X(*)
  !
  !***FIRST EXECUTABLE STATEMENT  DBKSOL
  m = (N*(N+1))/2
  X(N) = X(N)*A(m)
  nm1 = N - 1
  IF ( nm1>=1 ) THEN
    DO k = 1, nm1
      j = N - k
      m = m - k - 1
      X(j) = X(j)*A(m) - DDOT(k,A(m+1),1,X(j+1),1)
    ENDDO
  ENDIF
  !
END SUBROUTINE DBKSOL