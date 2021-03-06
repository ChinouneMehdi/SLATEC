!** INXCA
PURE SUBROUTINE INXCA(I,Ir,Idxa,Na)
  !> Subsidiary to CBLKTR
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      INTEGER (INXCA-I)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **See also:**  CBLKTR
  !***
  ! **Routines called:**  (NONE)
  !***
  ! COMMON BLOCKS    CCBLK

  !* REVISION HISTORY  (YYMMDD)
  !   801001  DATE WRITTEN
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900402  Added TYPE section.  (WRB)
  USE CCBLK, ONLY : nm_com
  !
  INTEGER, INTENT(IN) :: I, Ir
  INTEGER, INTENT(OUT) :: Idxa, Na
  !* FIRST EXECUTABLE STATEMENT  INXCA
  Na = 2**Ir
  Idxa = I - Na + 1
  IF( I>nm_com ) Na = 0
  !
END SUBROUTINE INXCA