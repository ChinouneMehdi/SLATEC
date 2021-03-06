!** DPLPMU
SUBROUTINE DPLPMU(Mrelas,Nvars,Lmx,Lbm,Nredc,Info,Ienter,Ileave,Npp,&
    Jstrt,Ibasis,Imat,Ibrc,Ipr,Iwr,Ind,Ibb,Anorm,Eps,Uu,Gg,Rprnrm,Erdnrm,Dulnrm,&
    Theta,Costsc,Xlamda,Rhsnrm,Amat,Basmat,Csc,Wr,Rprim,Ww,Bu,Bl,Rhs,Erd,Erp,Rz,&
    Rg,Colnrm,Costs,Primal,Duals,Singlr,Redbas,Zerolv,Stpedg)
  !> Subsidiary to DSPLP
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      DOUBLE PRECISION (SPLPMU-S, DPLPMU-D)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     THE EDITING REQUIRED TO CONVERT THIS SUBROUTINE FROM SINGLE TO
  !     DOUBLE PRECISION INVOLVES THE FOLLOWING CHARACTER STRING CHANGES.
  !
  !     USE AN EDITING COMMAND (CHANGE) /STRING-1/(TO)STRING-2/.
  !     /REAL (12 BLANKS)/DOUBLE PRECISION/,
  !     /SASUM/DASUM/,/SCOPY/DCOPY/,/SDOT/DDOT/,
  !     /.E0/.D0/
  !
  !     THIS SUBPROGRAM IS FROM THE DSPLP( ) PACKAGE.  IT PERFORMS THE
  !     TASKS OF UPDATING THE PRIMAL SOLUTION, EDGE WEIGHTS, REDUCED
  !     COSTS, AND MATRIX DECOMPOSITION.
  !     IT IS THE MAIN PART OF THE PROCEDURE (MAKE MOVE AND UPDATE).
  !
  !     REVISED 821122-1100
  !     REVISED YYMMDD
  !
  !***
  ! **See also:**  DSPLP
  !***
  ! **Routines called:**  DASUM, DCOPY, DDOT, DPLPDM, DPNNZR, DPRWPG, IDLOC,
  !                    LA05BD, LA05CD, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   811215  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890605  Removed unreferenced labels.  (WRB)
  !   890606  Changed references from IPLOC to IDLOC.  (WRB)
  !   890606  Removed unused COMMON block LA05DD.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900328  Added TYPE section.  (WRB)

  INTEGER, INTENT(IN) :: Ienter, Ileave, Lbm, Lmx, Mrelas, Npp, Nvars
  INTEGER, INTENT(INOUT) :: Jstrt
  INTEGER, INTENT(OUT) :: Info, Nredc
  REAL(DP), INTENT(IN) :: Costsc, Erdnrm, Eps, Xlamda
  REAL(DP), INTENT(INOUT) :: Dulnrm, Gg, Rhsnrm, Rprnrm, Theta, Uu
  REAL(DP), INTENT(OUT) :: Anorm
  LOGICAL, INTENT(IN) :: Stpedg, Zerolv
  LOGICAL, INTENT(OUT) :: Redbas, Singlr
  INTEGER, INTENT(IN) :: Imat(Lmx), Ind(Nvars+Mrelas)
  INTEGER, INTENT(INOUT) :: Ibasis(Nvars+Mrelas), Ibb(Nvars+Mrelas), Ibrc(Lbm,2), &
    Ipr(2*Mrelas), Iwr(8*Mrelas)
  REAL(DP), INTENT(IN) :: Amat(Lmx), Csc(Nvars), Bu(Nvars+Mrelas), Bl(Nvars+Mrelas), &
    Erp(Mrelas), Costs(Nvars), Colnrm(Nvars)
  REAL(DP), INTENT(INOUT) :: Basmat(Lbm), Primal(Nvars+Mrelas), Rg(Nvars+Mrelas), &
    Rhs(Mrelas), Rprim(Mrelas), Rz(Nvars+Mrelas), Ww(Mrelas)
  REAL(DP), INTENT(OUT) :: Duals(Nvars+Mrelas), Erd(Mrelas), Wr(Mrelas)
  INTEGER :: i, ibas, ihi, il1, ilow, ipage, iplace, iu1, j, k, lpg, n20002, &
    n20018, n20121, nerr, nnegrc, npr001, npr003
  REAL(DP) :: aij, alpha, gama, gq, rzj, scalr, wp, rcost, cnorm
  LOGICAL :: pagepl, trans
  !
  !* FIRST EXECUTABLE STATEMENT  DPLPMU
  lpg = Lmx - (Nvars+4)
  !
  !     UPDATE THE PRIMAL SOLUTION WITH A MULTIPLE OF THE SEARCH
  !     DIRECTION.
  i = 1
  n20002 = Mrelas
  DO WHILE( (n20002-i)>=0 )
    Rprim(i) = Rprim(i) - Theta*Ww(i)
    i = i + 1
  END DO
  !
  !     IF EJECTED VARIABLE IS LEAVING AT AN UPPER BOUND,  THEN
  !     TRANSLATE RIGHT HAND SIDE.
  IF( Ileave>=0 ) GOTO 200
  ibas = Ibasis(ABS(Ileave))
  scalr = Rprim(ABS(Ileave))
  npr001 = 100
  GOTO 1800
  100  Ibb(ibas) = ABS(Ibb(ibas)) + 1
  !
  !     IF ENTERING VARIABLE IS RESTRICTED TO ITS UPPER BOUND, TRANSLATE
  !     RIGHT HAND SIDE.  IF THE VARIABLE DECREASED FROM ITS UPPER
  !     BOUND, A SIGN CHANGE IS REQUIRED IN THE TRANSLATION.
  200 CONTINUE
  IF( Ienter/=Ileave ) THEN
    ibas = Ibasis(Ienter)
    !
    !     IF ENTERING VARIABLE IS DECREASING FROM ITS UPPER BOUND,
    !     COMPLEMENT ITS PRIMAL VALUE.
    IF( Ind(ibas)/=3 .OR. MOD(Ibb(ibas),2)/=0 ) GOTO 500
    scalr = -(Bu(ibas)-Bl(ibas))
    IF( ibas<=Nvars ) scalr = scalr/Csc(ibas)
    npr001 = 400
    GOTO 1800
  ELSE
    ibas = Ibasis(Ienter)
    scalr = Theta
    IF( MOD(Ibb(ibas),2)==0 ) scalr = -scalr
    npr001 = 300
    GOTO 1800
  END IF
  300  Ibb(ibas) = Ibb(ibas) + 1
  GOTO 600
  400  Theta = -scalr - Theta
  Ibb(ibas) = Ibb(ibas) + 1
  500  Rprim(ABS(Ileave)) = Theta
  Ibb(ibas) = -ABS(Ibb(ibas))
  i = Ibasis(ABS(Ileave))
  Ibb(i) = ABS(Ibb(i))
  IF( Primal(ABS(Ileave)+Nvars)>0._DP ) Ibb(i) = Ibb(i) + 1
  !
  !     INTERCHANGE COLUMN POINTERS TO NOTE EXCHANGE OF COLUMNS.
  600  ibas = Ibasis(Ienter)
  Ibasis(Ienter) = Ibasis(ABS(Ileave))
  Ibasis(ABS(Ileave)) = ibas
  !
  !     IF VARIABLE WAS EXCHANGED AT A ZERO LEVEL, MARK IT SO THAT
  !     IT CAN'T BE BROUGHT BACK IN.  THIS IS TO HELP PREVENT CYCLING.
  IF( Zerolv ) Ibasis(Ienter) = -ABS(Ibasis(Ienter))
  Rprnrm = MAX(Rprnrm,SUM(ABS(Rprim(1:Mrelas))) )
  k = 1
  n20018 = Mrelas
  700 CONTINUE
  DO WHILE( (n20018-k)>=0 )
    !
    !     SEE IF VARIABLES THAT WERE CLASSIFIED AS INFEASIBLE HAVE NOW
    !     BECOME FEASIBLE.  THIS MAY REQUIRED TRANSLATING UPPER BOUNDED
    !     VARIABLES.
    IF( Primal(k+Nvars)==0._DP .OR. ABS(Rprim(k))>Rprnrm*Erp(k) ) THEN
      k = k + 1
    ELSE
      IF( Primal(k+Nvars)<=0._DP ) GOTO 900
      ibas = Ibasis(k)
      scalr = -(Bu(ibas)-Bl(ibas))
      IF( ibas<=Nvars ) scalr = scalr/Csc(ibas)
      npr001 = 800
      GOTO 1800
    END IF
  END DO
  !
  !     UPDATE REDUCED COSTS, EDGE WEIGHTS, AND MATRIX DECOMPOSITION.
  IF( Ienter==Ileave ) THEN
    !
    !     THIS IS NECESSARY ONLY FOR PRINTING OF INTERMEDIATE RESULTS.
    npr003 = 1700
    GOTO 1900
  ELSE
    !
    !     THE INCOMING VARIABLE IS ALWAYS CLASSIFIED AS FEASIBLE.
    Primal(ABS(Ileave)+Nvars) = 0._DP
    !
    wp = Ww(ABS(Ileave))
    gq = NORM2(Ww(1:Mrelas))**2 + 1._DP
    !
    !     COMPUTE INVERSE (TRANSPOSE) TIMES SEARCH DIRECTION.
    trans = .TRUE.
    CALL LA05BD(Basmat,Ibrc,Lbm,Mrelas,Ipr,Iwr,Wr,Gg,Ww,trans)
    !
    !     UPDATE THE MATRIX DECOMPOSITION.  COL. ABS(ILEAVE) IS LEAVING.
    !     THE ARRAY DUALS(*) CONTAINS INTERMEDIATE RESULTS FOR THE
    !     INCOMING COLUMN.
    CALL LA05CD(Basmat,Ibrc,Lbm,Mrelas,Ipr,Iwr,Duals,Gg,Uu,ABS(Ileave))
    Redbas = .FALSE.
    IF( Gg>=0._DP ) GOTO 1000
    !
    !     REDECOMPOSE BASIS MATRIX WHEN AN ERROR RETURN FROM
    !     LA05CD( ) IS NOTED.  THIS WILL PROBABLY BE DUE TO
    !     SPACE BEING EXHAUSTED, GG=-7.
    CALL DPLPDM(Mrelas,Nvars,Lbm,Nredc,Info,Ibasis,Imat,Ibrc,Ipr,&
      Iwr,Ind,Anorm,Eps,Uu,Gg,Amat,Basmat,Csc,Wr,Singlr,Redbas)
    IF( .NOT. (Singlr) ) THEN
      !     PROCEDURE (COMPUTE NEW PRIMAL)
      !
      !     COPY RHS INTO WW(*), SOLVE SYSTEM.
      Ww(1:Mrelas) = Rhs(1:Mrelas)
      trans = .FALSE.
      CALL LA05BD(Basmat,Ibrc,Lbm,Mrelas,Ipr,Iwr,Wr,Gg,Ww,trans)
      Rprim(1:Mrelas) = Ww(1:Mrelas)
      Rprnrm = SUM(ABS(Rprim(1:Mrelas)))
      GOTO 1000
    ELSE
      nerr = 26
      Info = -nerr
      ERROR STOP 'DPLPMU : IN DSPLP, MOVED TO A SINGULAR POINT. THIS SHOULD NOT HAPPEN.'
      RETURN
    END IF
  END IF
  800  Rprim(k) = -scalr
  Rprnrm = Rprnrm - scalr
  900  Primal(k+Nvars) = 0._DP
  k = k + 1
  GOTO 700
  !
  !     IF STEEPEST EDGE PRICING IS USED, UPDATE REDUCED COSTS
  !     AND EDGE WEIGHTS.
  1000 CONTINUE
  IF( .NOT. (Stpedg) ) THEN
    !
    !     COMPUTE THE UPDATED DUALS IN DUALS(*).
    npr003 = 1300
  ELSE
    !
    !     COMPUTE COL. ABS(ILEAVE) OF THE NEW INVERSE (TRANSPOSE) MATRIX
    !     HERE ABS(ILEAVE) POINTS TO THE EJECTED COLUMN.
    !     USE ERD(*) FOR TEMP. STORAGE.
    Erd(1:Mrelas) = 0._DP
    Erd(ABS(Ileave)) = 1._DP
    trans = .TRUE.
    CALL LA05BD(Basmat,Ibrc,Lbm,Mrelas,Ipr,Iwr,Wr,Gg,Erd,trans)
    !
    !     COMPUTE UPDATED DUAL VARIABLES IN DUALS(*).
    npr003 = 1100
  END IF
  GOTO 1900
  !
  !     COMPUTE THE DOT PRODUCT OF COL. J OF THE NEW INVERSE (TRANSPOSE)
  !     WITH EACH NON-BASIC COLUMN.  ALSO COMPUTE THE DOT PRODUCT OF THE
  !     INVERSE (TRANSPOSE) OF NON-UPDATED MATRIX (TIMES) THE
  !     SEARCH DIRECTION WITH EACH NON-BASIC COLUMN.
  !     RECOMPUTE REDUCED COSTS.
  1100 pagepl = .TRUE.
  Rz(1:Nvars+Mrelas) = 0._DP
  nnegrc = 0
  j = Jstrt
  1200 CONTINUE
  IF( Ibb(j)<=0 ) THEN
    pagepl = .TRUE.
    Rg(j) = 1._DP
    !
    !     NONBASIC INDEPENDENT VARIABLES (COLUMN IN SPARSE MATRIX STORAGE)
  ELSEIF( j>Nvars ) THEN
    pagepl = .TRUE.
    scalr = -1._DP
    IF( Ind(j)==2 ) scalr = 1._DP
    i = j - Nvars
    alpha = scalr*Erd(i)
    Rz(j) = -scalr*Duals(i)
    gama = scalr*Ww(i)
    Rg(j) = MAX(Rg(j)-2._DP*alpha*gama+alpha**2*gq,1._DP+alpha**2)
  ELSE
    rzj = Costs(j)*Costsc
    alpha = 0._DP
    gama = 0._DP
    !
    !     COMPUTE THE DOT PRODUCT OF THE SPARSE MATRIX NONBASIC COLUMNS
    !     WITH THREE VECTORS INVOLVED IN THE UPDATING STEP.
    IF( j/=1 ) THEN
      ilow = Imat(j+3) + 1
    ELSE
      ilow = Nvars + 5
    END IF
    IF( .NOT. (pagepl) ) THEN
      il1 = ihi + 1
    ELSE
      il1 = IDLOC(ilow,Imat)
      IF( il1>=Lmx-1 ) THEN
        ilow = ilow + 2
        il1 = IDLOC(ilow,Imat)
      END IF
      ipage = ABS(Imat(Lmx-1))
    END IF
    ihi = Imat(j+4) - (ilow-il1)
    DO
      iu1 = MIN(Lmx-2,ihi)
      IF( il1>iu1 ) EXIT
      DO i = il1, iu1
        rzj = rzj - Amat(i)*Duals(Imat(i))
        alpha = alpha + Amat(i)*Erd(Imat(i))
        gama = gama + Amat(i)*Ww(Imat(i))
      END DO
      IF( ihi<=Lmx-2 ) EXIT
      il1 = Nvars + 5
      ihi = ihi - lpg
    END DO
    pagepl = ihi==(Lmx-2)
    Rz(j) = rzj*Csc(j)
    alpha = alpha*Csc(j)
    gama = gama*Csc(j)
    !
    !     NONBASIC DEPENDENT VARIABLES (COLUMNS DEFINED IMPLICITLY)
    Rg(j) = MAX(Rg(j)-2._DP*alpha*gama+alpha**2*gq,1._DP+alpha**2)
  END IF
  !
  rcost = Rz(j)
  IF( MOD(Ibb(j),2)==0 ) rcost = -rcost
  IF( Ind(j)==3 ) THEN
    IF( Bu(j)==Bl(j) ) rcost = 0._DP
  END IF
  IF( Ind(j)==4 ) rcost = -ABS(rcost)
  cnorm = 1._DP
  IF( j<=Nvars ) cnorm = Colnrm(j)
  IF( rcost+Erdnrm*Dulnrm*cnorm<0._DP ) nnegrc = nnegrc + 1
  j = MOD(j,Mrelas+Nvars) + 1
  IF( nnegrc<Npp .AND. j/=Jstrt ) GOTO 1200
  Jstrt = j
  !
  !     UPDATE THE EDGE WEIGHT FOR THE EJECTED VARIABLE.
  Rg(ABS(Ibasis(Ienter))) = gq/wp**2
  !
  !     IF MINIMUM REDUCED COST (DANTZIG) PRICING IS USED,
  !     CALCULATE THE NEW REDUCED COSTS.
  GOTO 1700
  1300 Rz(1:Nvars+Mrelas) = 0._DP
  nnegrc = 0
  j = Jstrt
  pagepl = .TRUE.
  !
  1400 CONTINUE
  IF( Ibb(j)<=0 ) THEN
    pagepl = .TRUE.
    GOTO 1600
    !
    !     NONBASIC INDEPENDENT VARIABLE (COLUMN IN SPARSE MATRIX STORAGE)
  ELSEIF( j>Nvars ) THEN
    pagepl = .TRUE.
    scalr = -1._DP
    IF( Ind(j)==2 ) scalr = 1._DP
    i = j - Nvars
    Rz(j) = -scalr*Duals(i)
    GOTO 1600
  ELSE
    Rz(j) = Costs(j)*Costsc
    IF( j/=1 ) THEN
      ilow = Imat(j+3) + 1
    ELSE
      ilow = Nvars + 5
    END IF
    IF( .NOT. (pagepl) ) THEN
      il1 = ihi + 1
    ELSE
      il1 = IDLOC(ilow,Imat)
      IF( il1>=Lmx-1 ) THEN
        ilow = ilow + 2
        il1 = IDLOC(ilow,Imat)
      END IF
      ipage = ABS(Imat(Lmx-1))
    END IF
    ihi = Imat(j+4) - (ilow-il1)
  END IF
  1500 iu1 = MIN(Lmx-2,ihi)
  IF( iu1>=il1 .AND. MOD(iu1-il1,2)==0 ) THEN
    Rz(j) = Rz(j) - Amat(il1)*Duals(Imat(il1))
    il1 = il1 + 1
  END IF
  IF( il1<=iu1 ) THEN
    !
    !     UNROLL THE DOT PRODUCT LOOP TO A DEPTH OF TWO.  (THIS IS DONE
    !     FOR INCREASED EFFICIENCY).
    DO i = il1, iu1, 2
      Rz(j) = Rz(j) - Amat(i)*Duals(Imat(i)) - Amat(i+1)*Duals(Imat(i+1))
    END DO
    IF( ihi>Lmx-2 ) THEN
      il1 = Nvars + 5
      ihi = ihi - lpg
      GOTO 1500
    END IF
  END IF
  pagepl = ihi==(Lmx-2)
  !
  !     NONBASIC DEPENDENT VARIABLES (COLUMNS DEFINED IMPLICITLY)
  Rz(j) = Rz(j)*Csc(j)
  !
  1600 rcost = Rz(j)
  IF( MOD(Ibb(j),2)==0 ) rcost = -rcost
  IF( Ind(j)==3 ) THEN
    IF( Bu(j)==Bl(j) ) rcost = 0._DP
  END IF
  IF( Ind(j)==4 ) rcost = -ABS(rcost)
  cnorm = 1._DP
  IF( j<=Nvars ) cnorm = Colnrm(j)
  IF( rcost+Erdnrm*Dulnrm*cnorm<0._DP ) nnegrc = nnegrc + 1
  j = MOD(j,Mrelas+Nvars) + 1
  IF( nnegrc<Npp .AND. j/=Jstrt ) GOTO 1400
  Jstrt = j
  1700 RETURN
  !     PROCEDURE (TRANSLATE RIGHT HAND SIDE)
  !
  !     PERFORM THE TRANSLATION ON THE RIGHT-HAND SIDE.
  1800 CONTINUE
  IF( ibas>Nvars ) THEN
    i = ibas - Nvars
    IF( Ind(ibas)/=2 ) THEN
      Rhs(i) = Rhs(i) + scalr
    ELSE
      Rhs(i) = Rhs(i) - scalr
    END IF
  ELSE
    i = 0
    DO
      CALL DPNNZR(i,aij,iplace,Amat,Imat,ibas)
      IF( i<=0 ) EXIT
      Rhs(i) = Rhs(i) - scalr*aij*Csc(ibas)
    END DO
  END IF
  Rhsnrm = MAX(Rhsnrm,SUM(ABS(Rhs(1:Mrelas))) )
  SELECT CASE(npr001)
    CASE(100)
      GOTO 100
    CASE(300)
      GOTO 300
    CASE(400)
      GOTO 400
    CASE(800)
      GOTO 800
  END SELECT
  !     PROCEDURE (COMPUTE NEW DUALS)
  !
  !     SOLVE FOR DUAL VARIABLES. FIRST COPY COSTS INTO DUALS(*).
  1900 i = 1
  n20121 = Mrelas
  DO WHILE( (n20121-i)>=0 )
    j = Ibasis(i)
    IF( j>Nvars ) THEN
      Duals(i) = Xlamda*Primal(i+Nvars)
    ELSE
      Duals(i) = Costsc*Costs(j)*Csc(j) + Xlamda*Primal(i+Nvars)
    END IF
    i = i + 1
  END DO
  !
  trans = .TRUE.
  CALL LA05BD(Basmat,Ibrc,Lbm,Mrelas,Ipr,Iwr,Wr,Gg,Duals,trans)
  Dulnrm = SUM(ABS(Duals(1:Mrelas)))
  SELECT CASE(npr003)
    CASE(1100)
      GOTO 1100
    CASE(1300)
      GOTO 1300
    CASE(1700)
      GOTO 1700
  END SELECT

END SUBROUTINE DPLPMU