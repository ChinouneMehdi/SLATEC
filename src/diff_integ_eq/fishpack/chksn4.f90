!** CHKSN4
PURE SUBROUTINE CHKSN4(Mbdcnd,Nbdcnd,Alpha,Beta,COFX,Singlr)
  !> Subsidiary to SEPX4
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (CHKSN4-S)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     This subroutine checks if the PDE SEPX4
  !     must solve is a singular operator.
  !
  !***
  ! **See also:**  SEPX4
  !***
  ! **Routines called:**  (NONE)
  !***
  ! COMMON BLOCKS    SPL4

  !* REVISION HISTORY  (YYMMDD)
  !   801001  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900402  Added TYPE section.  (WRB)
  USE SPL4, ONLY : ait_com, dlx_com, is_com, ms_com
  !
  INTERFACE
    PURE SUBROUTINE COFX(X,A,B,C)
      IMPORT SP
      REAL(SP), INTENT(IN) :: X
      REAL(SP), INTENT(OUT) :: A, B, C
    END SUBROUTINE COFX
  END INTERFACE
  INTEGER, INTENT(IN) :: Mbdcnd, Nbdcnd
  REAL(SP), INTENT(IN) :: Alpha, Beta
  LOGICAL, INTENT(OUT) :: Singlr
  !
  INTEGER :: i
  REAL(SP) :: ai, bi, ci, xi
  !* FIRST EXECUTABLE STATEMENT  CHKSN4
  Singlr = .FALSE.
  !
  !     CHECK IF THE BOUNDARY CONDITIONS ARE
  !     ENTIRELY PERIODIC AND/OR MIXED
  !
  IF( (Mbdcnd/=0 .AND. Mbdcnd/=3) .OR. (Nbdcnd/=0 .AND. Nbdcnd/=3) ) RETURN
  !
  !     CHECK THAT MIXED CONDITIONS ARE PURE NEUMAN
  !
  IF( Mbdcnd==3 ) THEN
    IF( Alpha/=0._SP .OR. Beta/=0._SP ) RETURN
  END IF
  !
  !     CHECK THAT NON-DERIVATIVE COEFFICIENT FUNCTIONS
  !     ARE ZERO
  !
  DO i = is_com, ms_com
    xi = ait_com + (i-1)*dlx_com
    CALL COFX(xi,ai,bi,ci)
    IF( ci/=0._SP ) RETURN
  END DO
  !
  !     THE OPERATOR MUST BE SINGULAR IF THIS POINT IS REACHED
  !
  Singlr = .TRUE.
  !
END SUBROUTINE CHKSN4