!** DPINIT
SUBROUTINE DPINIT(Mrelas,Nvars,Costs,Bl,Bu,Ind,Primal,Amat,Csc,&
    Costsc,Colnrm,Xlamda,Anorm,Rhs,Rhsnrm,Ibasis,Ibb,Imat,Lopt)
  !> Subsidiary to DSPLP
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      DOUBLE PRECISION (SPINIT-S, DPINIT-D)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     THE EDITING REQUIRED TO CONVERT THIS SUBROUTINE FROM SINGLE TO
  !     DOUBLE PRECISION INVOLVES THE FOLLOWING CHARACTER STRING CHANGES.
  !
  !     USE AN EDITING COMMAND (CHANGE) /STRING-1/(TO)STRING-2/.
  !     /REAL (12 BLANKS)/DOUBLE PRECISION/,/SCOPY/DCOPY/
  !     REVISED 810519-0900
  !     REVISED YYMMDD-HHMM
  !
  !     INITIALIZATION SUBROUTINE FOR DSPLP(*) PACKAGE.
  !
  !***
  ! **See also:**  DSPLP
  !***
  ! **Routines called:**  DASUM, DCOPY, DPNNZR

  !* REVISION HISTORY  (YYMMDD)
  !   811215  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890605  Removed unreferenced labels.  (WRB)
  !   891009  Removed unreferenced variable.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  INTEGER :: Mrelas, Nvars
  REAL(DP) :: Anorm, Costsc, Rhsnrm, Xlamda
  INTEGER :: Ibasis(Nvars+Mrelas), Ibb(Nvars+Mrelas), Imat(:), Ind(Nvars+Mrelas)
  REAL(DP) :: Amat(:), Bl(Nvars+Mrelas), Bu(Nvars+Mrelas), Colnrm(Nvars), Costs(Nvars), &
    Csc(Nvars), Primal(Nvars+Mrelas), Rhs(Mrelas)
  LOGICAL :: Lopt(8)
  INTEGER :: i, ip, iplace, j, n20007, n20019, n20028, n20041, n20056, n20066, &
    n20070, n20074, n20078
  REAL(DP) :: aij, cmax, csum, scalr, testsc
  REAL(DP), PARAMETER :: zero = 0._DP, one = 1._DP
  LOGICAL :: contin, usrbas, colscp, cstscp, minprb
  !
  !* FIRST EXECUTABLE STATEMENT  DPINIT
  contin = Lopt(1)
  usrbas = Lopt(2)
  colscp = Lopt(5)
  cstscp = Lopt(6)
  !
  !     SCALE DATA. NORMALIZE BOUNDS. FORM COLUMN CHECK SUMS.
  !
  !     INITIALIZE ACTIVE BASIS MATRIX.
  minprb = Lopt(7)
  !
  !     PROCEDURE (SCALE DATA. NORMALIZE BOUNDS. FORM COLUMN CHECK SUMS)
  !
  !     DO COLUMN SCALING IF NOT PROVIDED BY THE USER.
  IF( .NOT. colscp ) THEN
    j = 1
    n20007 = Nvars
    DO WHILE( (n20007-j)>=0 )
      cmax = zero
      i = 0
      DO
        CALL DPNNZR(i,aij,iplace,Amat,Imat,j)
        IF( i/=0 ) THEN
          cmax = MAX(cmax,ABS(aij))
        ELSE
          IF( cmax/=zero ) THEN
            Csc(j) = one/cmax
          ELSE
            Csc(j) = one
          END IF
          j = j + 1
          EXIT
        END IF
      END DO
    END DO
  END IF
  !
  !     FORM CHECK SUMS OF COLUMNS. COMPUTE MATRIX NORM OF SCALED MATRIX.
  Anorm = zero
  j = 1
  n20019 = Nvars
  DO WHILE( (n20019-j)>=0 )
    Primal(j) = zero
    csum = zero
    i = 0
    DO
      CALL DPNNZR(i,aij,iplace,Amat,Imat,j)
      IF( i>0 ) THEN
        Primal(j) = Primal(j) + aij
        csum = csum + ABS(aij)
      ELSE
        IF( Ind(j)==2 ) Csc(j) = -Csc(j)
        Primal(j) = Primal(j)*Csc(j)
        Colnrm(j) = ABS(Csc(j)*csum)
        Anorm = MAX(Anorm,Colnrm(j))
        j = j + 1
        EXIT
      END IF
    END DO
  END DO
  !
  !     IF THE USER HAS NOT PROVIDED COST VECTOR SCALING THEN SCALE IT
  !     USING THE MAX. NORM OF THE TRANSFORMED COST VECTOR, IF NONZERO.
  testsc = zero
  j = 1
  n20028 = Nvars
  DO WHILE( (n20028-j)>=0 )
    testsc = MAX(testsc,ABS(Csc(j)*Costs(j)))
    j = j + 1
  END DO
  IF( .NOT. cstscp ) THEN
    IF( testsc<=zero ) THEN
      Costsc = one
    ELSE
      Costsc = one/testsc
    END IF
  END IF
  Xlamda = (Costsc+Costsc)*testsc
  IF( Xlamda==zero ) Xlamda = one
  !
  !     IF MAXIMIZATION PROBLEM, THEN CHANGE SIGN OF COSTSC AND LAMDA
  !     =WEIGHT FOR PENALTY-FEASIBILITY METHOD.
  IF( .NOT. minprb ) Costsc = -Costsc
  !:CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
  !     PROCEDURE (INITIALIZE RHS(*),IBASIS(*), AND IBB(*))
  !
  !     INITIALLY SET RIGHT-HAND SIDE VECTOR TO ZERO.
  Rhs(1:Mrelas) = zero
  !
  !     TRANSLATE RHS ACCORDING TO CLASSIFICATION OF INDEPENDENT VARIABLES
  j = 1
  n20041 = Nvars
  DO WHILE( (n20041-j)>=0 )
    IF( Ind(j)==1 ) THEN
      scalr = -Bl(j)
    ELSEIF( Ind(j)==2 ) THEN
      scalr = -Bu(j)
    ELSEIF( Ind(j)==3 ) THEN
      scalr = -Bl(j)
    ELSEIF( Ind(j)==4 ) THEN
      scalr = zero
    END IF
    IF( scalr==zero ) THEN
      j = j + 1
    ELSE
      i = 0
      DO
        CALL DPNNZR(i,aij,iplace,Amat,Imat,j)
        IF( i>0 ) THEN
          Rhs(i) = scalr*aij + Rhs(i)
        ELSE
          j = j + 1
          EXIT
        END IF
      END DO
    END IF
  END DO
  !
  !     TRANSLATE RHS ACCORDING TO CLASSIFICATION OF DEPENDENT VARIABLES.
  i = Nvars + 1
  n20056 = Nvars + Mrelas
  DO WHILE( (n20056-i)>=0 )
    IF( Ind(i)==1 ) THEN
      scalr = Bl(i)
    ELSEIF( Ind(i)==2 ) THEN
      scalr = Bu(i)
    ELSEIF( Ind(i)==3 ) THEN
      scalr = Bl(i)
    ELSEIF( Ind(i)==4 ) THEN
      scalr = zero
    END IF
    Rhs(i-Nvars) = Rhs(i-Nvars) + scalr
    i = i + 1
  END DO
  Rhsnrm = SUM(ABS(Rhs(1:Mrelas)))
  !
  !     IF THIS IS NOT A CONTINUATION OR THE USER HAS NOT PROVIDED THE
  !     INITIAL BASIS, THEN THE INITIAL BASIS IS COMPRISED OF THE
  !     DEPENDENT VARIABLES.
  IF( .NOT. (contin .OR. usrbas) ) THEN
    j = 1
    n20066 = Mrelas
    DO WHILE( (n20066-j)>=0 )
      Ibasis(j) = Nvars + j
      j = j + 1
    END DO
  END IF
  !
  !     DEFINE THE ARRAY IBB(*)
  j = 1
  n20070 = Nvars + Mrelas
  DO WHILE( (n20070-j)>=0 )
    Ibb(j) = 1
    j = j + 1
  END DO
  j = 1
  n20074 = Mrelas
  DO WHILE( (n20074-j)>=0 )
    Ibb(Ibasis(j)) = -1
    j = j + 1
  END DO
  !
  !     DEFINE THE REST OF IBASIS(*)
  ip = Mrelas
  j = 1
  n20078 = Nvars + Mrelas
  DO WHILE( (n20078-j)>=0 )
    IF( Ibb(j)>0 ) THEN
      ip = ip + 1
      Ibasis(ip) = j
    END IF
    j = j + 1
  END DO
  RETURN
END SUBROUTINE DPINIT
