!** SPINCW
SUBROUTINE SPINCW(Mrelas,Nvars,Lmx,Lbm,Npp,Jstrt,Imat,Ibrc,Ipr,Iwr,&
    Ind,Ibb,Costsc,Gg,Erdnrm,Dulnrm,Amat,Basmat,Csc,Wr,Ww,&
    Rz,Rg,Costs,Colnrm,Duals,Stpedg)
  !> Subsidiary to SPLP
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (SPINCW-S, DPINCW-D)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     THE EDITING REQUIRED TO CONVERT THIS SUBROUTINE FROM SINGLE TO
  !     DOUBLE PRECISION INVOLVES THE FOLLOWING CHARACTER STRING CHANGES.
  !
  !     USE AN EDITING COMMAND (CHANGE) /STRING-1/(TO)STRING-2/,
  !     REAL (12 BLANKS)/DOUBLE PRECISION/,/SCOPY/DCOPY/,/SDOT/DDOT/.
  !
  !     THIS SUBPROGRAM IS PART OF THE SPLP( ) PACKAGE.
  !     IT IMPLEMENTS THE PROCEDURE (INITIALIZE REDUCED COSTS AND
  !     STEEPEST EDGE WEIGHTS).
  !
  !***
  ! **See also:**  SPLP
  !***
  ! **Routines called:**  IPLOC, LA05BS, PRWPGE, SCOPY, SDOT

  !* REVISION HISTORY  (YYMMDD)
  !   811215  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890605  Removed unreferenced labels.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  INTEGER, INTENT(IN) :: Lbm, Lmx, Mrelas, Npp, Nvars
  INTEGER, INTENT(INOUT) :: Jstrt
  REAL(SP), INTENT(IN) :: Costsc, Erdnrm, Dulnrm, Gg
  LOGICAL, INTENT(IN) :: Stpedg
  INTEGER, INTENT(IN) :: Imat(Lmx), Ibrc(Lbm,2), Iwr(8*Mrelas), Ind(Nvars+Mrelas), &
    Ibb(Nvars+Mrelas)
  INTEGER, INTENT(INOUT) :: Ipr(2*Mrelas)
  REAL(SP), INTENT(IN) :: Amat(Lmx), Basmat(Lbm), Csc(Nvars), Costs(Nvars), &
    Colnrm(Nvars), Duals(Nvars+Mrelas)
  REAL(SP), INTENT(OUT) :: Rg(Nvars+Mrelas), Rz(Nvars+Mrelas), Wr(Mrelas), Ww(Mrelas)
  INTEGER :: i, ihi, il1, ilow, ipage, iu1, j, key, lpg, nnegrc
  REAL(SP) :: rzj, scalr, rcost, cnorm
  LOGICAL :: pagepl, trans
  !* FIRST EXECUTABLE STATEMENT  SPINCW
  lpg = Lmx - (Nvars+4)
  !
  !     FORM REDUCED COSTS, RZ(*), AND STEEPEST EDGE WEIGHTS, RG(*).
  pagepl = .TRUE.
  Rz(1:Nvars+Mrelas) = 0._SP
  Rg(1:Nvars+Mrelas) = 1._SP
  nnegrc = 0
  j = Jstrt
  100 CONTINUE
  IF( Ibb(j)<=0 ) THEN
    pagepl = .TRUE.
    !
    !     THESE ARE NONBASIC INDEPENDENT VARIABLES. THE COLS. ARE IN SPARSE
    !     MATRIX FORMAT.
  ELSEIF( j>Nvars ) THEN
    pagepl = .TRUE.
    Ww(1:Mrelas) = 0._SP
    scalr = -1._SP
    IF( Ind(j)==2 ) scalr = 1._SP
    i = j - Nvars
    Rz(j) = -scalr*Duals(i)
    Ww(i) = scalr
    IF( Stpedg ) THEN
      trans = .FALSE.
      CALL LA05BS(Basmat,Ibrc,Lbm,Mrelas,Ipr,Iwr,Wr,Gg,Ww,trans)
      Rg(j) = NORM2(Ww(1:Mrelas)) + 1._SP
    END IF
  ELSE
    rzj = Costsc*Costs(j)
    Ww(1:Mrelas) = 0._SP
    IF( j/=1 ) THEN
      ilow = Imat(j+3) + 1
    ELSE
      ilow = Nvars + 5
    END IF
    IF( .NOT. (pagepl) ) THEN
      il1 = ihi + 1
    ELSE
      il1 = IPLOC(ilow,Imat)
      IF( il1>=Lmx-1 ) THEN
        ilow = ilow + 2
        il1 = IPLOC(ilow,Imat)
      END IF
      ipage = ABS(Imat(Lmx-1))
    END IF
    ihi = Imat(j+4) - (ilow-il1)
    DO
      iu1 = MIN(Lmx-2,ihi)
      IF( il1>iu1 ) EXIT
      DO i = il1, iu1
        rzj = rzj - Amat(i)*Duals(Imat(i))
        Ww(Imat(i)) = Amat(i)*Csc(j)
      END DO
      IF( ihi<=Lmx-2 ) EXIT
      ipage = ipage + 1
      key = 1
      il1 = Nvars + 5
      ihi = ihi - lpg
    END DO
    pagepl = ihi==(Lmx-2)
    Rz(j) = rzj*Csc(j)
    IF( Stpedg ) THEN
      trans = .FALSE.
      CALL LA05BS(Basmat,Ibrc,Lbm,Mrelas,Ipr,Iwr,Wr,Gg,Ww,trans)
      !
      !     THESE ARE NONBASIC DEPENDENT VARIABLES. THE COLS. ARE IMPLICITLY
      !     DEFINED.
      Rg(j) = NORM2(Ww(1:Mrelas))**2 + 1._SP
    END IF
  END IF
  !
  rcost = Rz(j)
  IF( MOD(Ibb(j),2)==0 ) rcost = -rcost
  IF( Ind(j)==4 ) rcost = -ABS(rcost)
  cnorm = 1._SP
  IF( j<=Nvars ) cnorm = Colnrm(j)
  IF( rcost+Erdnrm*Dulnrm*cnorm<0._SP ) nnegrc = nnegrc + 1
  j = MOD(j,Mrelas+Nvars) + 1
  IF( nnegrc<Npp .AND. j/=Jstrt ) GOTO 100
  Jstrt = j

END SUBROUTINE SPINCW