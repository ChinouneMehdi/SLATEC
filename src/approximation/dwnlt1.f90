!** DWNLT1
PURE SUBROUTINE DWNLT1(I,Lend,Mend,Ir,Mdw,Recalc,Imax,Hbar,H,Scalee,W)
  !> Subsidiary to WNLIT
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      DOUBLE PRECISION (WNLT1-S, DWNLT1-D)
  !***
  ! **Author:**  Hanson, R. J., (SNLA)
  !           Haskell, K. H., (SNLA)
  !***
  ! **Description:**
  !
  !     To update the column Sum Of Squares and find the pivot column.
  !     The column Sum of Squares Vector will be updated at each step.
  !     When numerically necessary, these values will be recomputed.
  !
  !***
  ! **See also:**  DWNLIT
  !***
  ! **Routines called:**  IDAMAX

  !* REVISION HISTORY  (YYMMDD)
  !   790701  DATE WRITTEN
  !   890620  Code extracted from WNLIT and made a subroutine.  (RWC)
  !   900604  DP version created from SP version.  (RWC)
  INTEGER, INTENT(IN) :: I, Ir, Lend, Mdw, Mend
  INTEGER, INTENT(INOUT) :: Imax
  REAL(DP), INTENT(IN) :: Scalee(Mend), W(Mdw,Mend)
  REAL(DP), INTENT(INOUT) :: Hbar, H(:)
  LOGICAL, INTENT(INOUT) :: Recalc
  !
  INTEGER :: j, k
  !
  !* FIRST EXECUTABLE STATEMENT  DWNLT1
  IF( Ir/=1 .AND. ( .NOT. Recalc) ) THEN
    !
    !        Update column SS=sum of squares.
    !
    DO j = I, Lend
      H(j) = H(j) - Scalee(Ir-1)*W(Ir-1,j)**2
    END DO
    !
    !        Test for numerical accuracy.
    !
    Imax = MAXLOC(H(I:Lend),1) + I - 1
    Recalc = (Hbar+1.E-3*H(Imax))==Hbar
  END IF
  !
  !     If required, recalculate column SS, using rows IR through MEND.
  !
  IF( Recalc ) THEN
    DO j = I, Lend
      H(j) = 0._DP
      DO k = Ir, Mend
        H(j) = H(j) + Scalee(k)*W(k,j)**2
      END DO
    END DO
    !
    !        Find column with largest SS.
    !
    Imax = MAXLOC(H(I:Lend),1) + I - 1
    Hbar = H(Imax)
  END IF
  !
END SUBROUTINE DWNLT1