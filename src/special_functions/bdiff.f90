!** BDIFF
PURE SUBROUTINE BDIFF(L,V)
  !> Subsidiary to BSKIN
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (BDIFF-S, DBDIFF-D)
  !***
  ! **Author:**  Amos, D. E., (SNLA)
  !***
  ! **Description:**
  !
  !     BDIFF computes the sum of B(L,K)*V(K)*(-1)**K where B(L,K)
  !     are the binomial coefficients.  Truncated sums are computed by
  !     setting last part of the V vector to zero. On return, the binomial
  !     sum is in V(L).
  !
  !***
  ! **See also:**  BSKIN
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   820601  DATE WRITTEN
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)

  INTEGER, INTENT(IN) :: L
  REAL(SP), INTENT(INOUT) :: V(L)
  INTEGER :: i, j, k
  !* FIRST EXECUTABLE STATEMENT  BDIFF
  IF( L==1 ) RETURN
  DO j = 2, L
    k = L
    DO i = j, L
      V(k) = V(k-1) - V(k)
      k = k - 1
    END DO
  END DO

END SUBROUTINE BDIFF