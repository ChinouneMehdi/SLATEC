!** DUSRMT
PURE SUBROUTINE DUSRMT(I,J,Aij,Indcat,Dattrv,Iflag)
  !> Subsidiary to DSPLP
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      DOUBLE PRECISION (USRMAT-S, DUSRMT-D)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !   The user may supply this code
  !
  !***
  ! **See also:**  DSPLP
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   811215  DATE WRITTEN
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)

  INTEGER, INTENT(OUT) :: I, Indcat, J
  INTEGER, INTENT(INOUT) :: Iflag(4)
  REAL(DP), INTENT(IN) :: Dattrv(:)
  REAL(DP), INTENT(OUT) :: Aij
  INTEGER :: l
  !
  !* FIRST EXECUTABLE STATEMENT  DUSRMT
  IF( Iflag(1)==1 ) THEN
    !
    !     THIS IS THE INITIALIZATION STEP.  THE VALUES OF IFLAG(K),K=2,3,4,
    !     ARE RESPECTIVELY THE COLUMN INDEX, THE ROW INDEX (OR THE NEXT COL.
    !     INDEX), AND THE POINTER TO THE MATRIX ENTRY'S VALUE WITHIN
    !     DATTRV(*).  ALSO CHECK (DATTRV(1)=0.) SIGNIFYING NO DATA.
    IF( Dattrv(1)==0._DP ) THEN
      I = 0
      J = 0
      Iflag(1) = 3
    ELSE
      Iflag(2) = INT( -Dattrv(1) )
      Iflag(3) = INT( Dattrv(2) )
      Iflag(4) = 3
    END IF
    !
    RETURN
  ELSE
    J = Iflag(2)
    I = Iflag(3)
    l = Iflag(4)
    IF( I==0 ) THEN
      !
      !     SIGNAL THAT ALL OF THE NONZERO ENTRIES HAVE BEEN DEFINED.
      Iflag(1) = 3
      RETURN
    ELSEIF( I<0 ) THEN
      !
      !     SIGNAL THAT A SWITCH IS MADE TO A NEW COLUMN.
      J = -I
      I = INT( Dattrv(l) )
      l = l + 1
    END IF
    !
    Aij = Dattrv(l)
    !
    !     UPDATE THE INDICES AND POINTERS FOR THE NEXT ENTRY.
    Iflag(2) = J
    Iflag(3) = INT( Dattrv(l+1) )
    Iflag(4) = l + 2
    !
    !     INDCAT=0 DENOTES THAT ENTRIES OF THE MATRIX ARE ASSIGNED THE
    !     VALUES FROM DATTRV(*).  NO ACCUMULATION IS PERFORMED.
    Indcat = 0
    RETURN
  END IF

END SUBROUTINE DUSRMT