!** CPEVLR
PURE SUBROUTINE CPEVLR(N,M,A,X,C)
  !> Subsidiary to CPZERO
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (CPEVLR-S)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **See also:**  CPZERO
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   810223  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900402  Added TYPE section.  (WRB)

  INTEGER, INTENT(IN) :: M, N
  REAL(SP), INTENT(IN) :: X, A(N+1)
  REAL(SP), INTENT(INOUT) :: C(MIN(M+1,N+1))
  INTEGER :: i, j, mini, np1
  REAL(SP) :: ci, cim1
  !* FIRST EXECUTABLE STATEMENT  CPEVLR
  np1 = N + 1
  DO j = 1, np1
    ci = 0._SP
    cim1 = A(j)
    mini = MIN(M+1,N+2-j)
    DO i = 1, mini
      IF( j/=1 ) ci = C(i)
      IF( i/=1 ) cim1 = C(i-1)
      C(i) = cim1 + X*ci
    END DO
  END DO

END SUBROUTINE CPEVLR