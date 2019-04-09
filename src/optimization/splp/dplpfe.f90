!** DPLPFE
SUBROUTINE DPLPFE(Mrelas,Nvars,Lmx,Lbm,Ienter,Ibasis,Imat,Ibrc,Ipr,Iwr,&
    Ind,Ibb,Erdnrm,Eps,Gg,Dulnrm,Dirnrm,Amat,Basmat,Csc,Wr,&
    Ww,Bl,Bu,Rz,Rg,Colnrm,Duals,Found)
  IMPLICIT NONE
  !>
  !***
  !  Subsidiary to DSPLP
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      DOUBLE PRECISION (SPLPFE-S, DPLPFE-D)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     THE EDITING REQUIRED TO CONVERT THIS SUBROUTINE FROM SINGLE TO
  !     DOUBLE PRECISION INVOLVES THE FOLLOWING CHARACTER STRING CHANGES.
  !
  !     USE AN EDITING COMMAND (CHANGE) /STRING-1/(TO)STRING-2/.
  !     /REAL (12 BLANKS)/DOUBLE PRECISION/,/SASUM/DASUM/,
  !     /SCOPY/DCOPY/.
  !
  !     THIS SUBPROGRAM IS PART OF THE DSPLP( ) PACKAGE.
  !     IT IMPLEMENTS THE PROCEDURE (FIND VARIABLE TO ENTER BASIS
  !     AND GET SEARCH DIRECTION).
  !     REVISED 811130-1100
  !     REVISED YYMMDD-HHMM
  !
  !***
  ! **See also:**  DSPLP
  !***
  ! **Routines called:**  DASUM, DCOPY, DPRWPG, IDLOC, LA05BD

  !* REVISION HISTORY  (YYMMDD)
  !   811215  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890605  Removed unreferenced labels.  (WRB)
  !   890606  Changed references from IPLOC to IDLOC.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)

  INTEGER i, IDLOC, Ienter, ihi, il1, ilow, ipage, iu1, j, key, &
    Lbm, Lmx, lpg, Mrelas, n20002, n20050, Nvars
  INTEGER Ibasis(*), Imat(*), Ibrc(Lbm,2), Ipr(*), Iwr(*), Ind(*), Ibb(*)
  REAL(8) :: Amat(*), Basmat(*), Csc(*), Wr(*), Ww(*), Bl(*), &
    Bu(*), Rz(*), Rg(*), Colnrm(*), Duals(*), cnorm, &
    Dirnrm, Dulnrm, Eps, Erdnrm, Gg, one, ratio, rcost, rmax, zero
  REAL(8) :: DASUM
  LOGICAL Found, trans
  !* FIRST EXECUTABLE STATEMENT  DPLPFE
  lpg = Lmx - (Nvars+4)
  zero = 0.D0
  one = 1.D0
  rmax = zero
  Found = .FALSE.
  i = Mrelas + 1
  n20002 = Mrelas + Nvars
  DO WHILE ( (n20002-i)>=0 )
    j = Ibasis(i)
    !
    !     IF J=IBASIS(I) .LT. 0 THEN THE VARIABLE LEFT AT A ZERO LEVEL
    !     AND IS NOT CONSIDERED AS A CANDIDATE TO ENTER.
    IF ( j>0 ) THEN
      !
      !     DO NOT CONSIDER VARIABLES CORRESPONDING TO UNBOUNDED STEP LENGTHS.
      IF ( Ibb(j)/=0 ) THEN
        !
        !     IF A VARIABLE CORRESPONDS TO AN EQUATION(IND=3 AND BL=BU),
        !     THEN DO NOT CONSIDER IT AS A CANDIDATE TO ENTER.
        IF ( Ind(j)==3 ) THEN
          IF ( (Bu(j)-Bl(j))<=Eps*(ABS(Bl(j))+ABS(Bu(j))) ) GOTO 50
        END IF
        rcost = Rz(j)
        !
        !     IF VARIABLE IS AT UPPER BOUND IT CAN ONLY DECREASE.  THIS
        !     ACCOUNTS FOR THE POSSIBLE CHANGE OF SIGN.
        IF ( MOD(Ibb(j),2)==0 ) rcost = -rcost
        !
        !     IF THE VARIABLE IS FREE, USE THE NEGATIVE MAGNITUDE OF THE
        !     REDUCED COST FOR THAT VARIABLE.
        IF ( Ind(j)==4 ) rcost = -ABS(rcost)
        cnorm = one
        IF ( j<=Nvars ) cnorm = Colnrm(j)
        !
        !     TEST FOR NEGATIVITY OF REDUCED COSTS.
        IF ( rcost+Erdnrm*Dulnrm*cnorm<zero ) THEN
          Found = .TRUE.
          ratio = rcost**2/Rg(j)
          IF ( ratio>rmax ) THEN
            rmax = ratio
            Ienter = i
          END IF
        END IF
      END IF
    END IF
    50  i = i + 1
  END DO
  !
  !     USE COL. CHOSEN TO COMPUTE SEARCH DIRECTION.
  IF ( Found ) THEN
    j = Ibasis(Ienter)
    Ww(1) = zero
    CALL DCOPY(Mrelas,Ww,0,Ww,1)
    IF ( j<=Nvars ) THEN
      IF ( j/=1 ) THEN
        ilow = Imat(j+3) + 1
      ELSE
        ilow = Nvars + 5
      END IF
      il1 = IDLOC(ilow,Amat,Imat)
      IF ( il1>=Lmx-1 ) THEN
        ilow = ilow + 2
        il1 = IDLOC(ilow,Amat,Imat)
      END IF
      ipage = ABS(Imat(Lmx-1))
      ihi = Imat(j+4) - (ilow-il1)
      DO
        iu1 = MIN(Lmx-2,ihi)
        IF ( il1>iu1 ) EXIT
        DO i = il1, iu1
          Ww(Imat(i)) = Amat(i)*Csc(j)
        END DO
        IF ( ihi<=Lmx-2 ) EXIT
        ipage = ipage + 1
        key = 1
        CALL DPRWPG(key,ipage,lpg,Amat,Imat)
        il1 = Nvars + 5
        ihi = ihi - lpg
      END DO
    ELSEIF ( Ind(j)/=2 ) THEN
      Ww(j-Nvars) = -one
    ELSE
      Ww(j-Nvars) = one
    END IF
    !
    !     COMPUTE SEARCH DIRECTION.
    trans = .FALSE.
    CALL LA05BD(Basmat,Ibrc,Lbm,Mrelas,Ipr,Iwr,Wr,Gg,Ww,trans)
    !
    !     THE SEARCH DIRECTION REQUIRES THE FOLLOWING SIGN CHANGE IF EITHER
    !     VARIABLE ENTERING IS AT ITS UPPER BOUND OR IS FREE AND HAS
    !     POSITIVE REDUCED COST.
    IF ( MOD(Ibb(j),2)==0.OR.(Ind(j)==4.AND.Rz(j)>zero) ) THEN
      i = 1
      n20050 = Mrelas
      DO WHILE ( (n20050-i)>=0 )
        Ww(i) = -Ww(i)
        i = i + 1
      END DO
    END IF
    Dirnrm = DASUM(Mrelas,Ww,1)
    !
    !     COPY CONTENTS OF WR(*) TO DUALS(*) FOR USE IN
    !     ADD-DROP (EXCHANGE) STEP, LA05CD( ).
    CALL DCOPY(Mrelas,Wr,1,Duals,1)
  END IF
END SUBROUTINE DPLPFE