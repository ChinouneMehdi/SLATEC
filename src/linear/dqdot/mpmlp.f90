!** MPMLP
PURE SUBROUTINE MPMLP(U,V,W,J)
  !> Subsidiary to DQDOTA and DQDOTI
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      ALL (MPMLP-A)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  ! Performs inner multiplication loop for MPMUL. Carries are not pro-
  ! pagated in inner loop, which saves time at the expense of space.
  !
  !***
  ! **See also:**  DQDOTA, DQDOTI
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   791001  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900402  Added TYPE section.  (WRB)

  INTEGER, INTENT(IN) :: J
  INTEGER, INTENT(IN) :: V(J), W
  INTEGER, INTENT(INOUT) :: U(J)
  INTEGER :: i
  !* FIRST EXECUTABLE STATEMENT  MPMLP
  DO i = 1, J
    U(i) = U(i) + W*V(i)
  END DO

END SUBROUTINE MPMLP