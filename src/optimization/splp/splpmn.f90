!** SPLPMN
SUBROUTINE SPLPMN(USRMAT,Mrelas,Nvars,Costs,Prgopt,Dattrv,Bl,Bu,Ind,Info,&
    Primal,Duals,Amat,Csc,Colnrm,Erd,Erp,Basmat,Wr,Rz,Rg,&
    Rprim,Rhs,Ww,Lmx,Lbm,Ibasis,Ibb,Imat,Ibrc,Ipr,Iwr)
  !> Subsidiary to SPLP
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (SPLPMN-S, DPLPMN-D)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     MARVEL OPTION(S).. OUTPUT=YES/NO TO ELIMINATE PRINTED OUTPUT.
  !     THIS DOES NOT APPLY TO THE CALLS TO THE ERROR PROCESSOR.
  !
  !     MAIN SUBROUTINE FOR SPLP PACKAGE.
  !
  !***
  ! **See also:**  SPLP
  !***
  ! **Routines called:**  IVOUT, LA05BS, PINITM, PNNZRS, PRWPGE, SASUM,
  !                    SCLOSM, SCOPY, SDOT, SPINCW, SPINIT, SPLPCE,
  !                    SPLPDM, SPLPFE, SPLPFL, SPLPMU, SPLPUP, SPOPT,
  !                    SVOUT, XERMSG
  !***
  ! COMMON BLOCKS    LA05DS

  !* REVISION HISTORY  (YYMMDD)
  !   811215  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890605  Corrected references to XERRWV.  (WRB)
  !   890605  Removed unreferenced labels.  (WRB)
  !   891009  Removed unreferenced variable.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900328  Added TYPE section.  (WRB)
  !   900510  Convert XERRWV calls to XERMSG calls.  (RWC)
  USE service, ONLY : IVOUT, SVOUT
  USE LA05DS, ONLY : lp_com

  INTERFACE
    PURE SUBROUTINE USRMAT(I,J,Aij,Indcat,Dattrv,Iflag)
      IMPORT SP
      INTEGER, INTENT(OUT) :: I, J, Indcat
      INTEGER, INTENT(INOUT) :: Iflag(4)
      REAL(SP), INTENT(IN) :: Dattrv(:)
      REAL(SP), INTENT(OUT) :: Aij
    END SUBROUTINE USRMAT
  END INTERFACE
  INTEGER, INTENT(IN) :: Lbm, Lmx, Mrelas, Nvars
  INTEGER, INTENT(OUT) :: Info
  INTEGER, INTENT(INOUT) :: Ibasis(Nvars+Mrelas), Ibrc(Lbm,2), Imat(Lmx), &
    Ind(Nvars+Mrelas), Ipr(2*Mrelas), Iwr(8*Mrelas)
  INTEGER, INTENT(OUT) :: Ibb(Nvars+Mrelas)
  REAL(SP), INTENT(IN) :: Costs(Nvars), Dattrv(:), Prgopt(:)
  REAL(SP), INTENT(INOUT) :: Amat(Lmx), Basmat(Lbm), Bl(Nvars+Mrelas), Bu(Nvars+Mrelas), &
    Erp(Mrelas), Rprim(Mrelas), Ww(Mrelas)
  REAL(SP), INTENT(OUT) :: Colnrm(Nvars), Csc(Nvars), Duals(Nvars+Mrelas), &
    Erd(Mrelas), Primal(Nvars+Mrelas), Rg(Nvars+Mrelas), Rhs(Mrelas), Rz(Nvars+Mrelas), &
    Wr(Mrelas)
  INTEGER :: i, ibas, ienter, ileave, iopt, ipage, iplace, itlp, j, jstrt, k, &
    key, lpg, lpr, lpr1, n20046, n20058, n20080, n20098, n20119, &
    n20172, n20206, n20247, n20252, n20271, n20276, n20283, n20290, nerr, np, &
    nparm, npr004, npr005, npr006, npr007, npr008, npr009, npr010, npr011, npr012, &
    npr013, npr014, npr015, nredc, ntries, nx0066, nx0091, nx0106, idum(01)
  INTEGER, TARGET :: intopt(08)
  INTEGER, POINTER :: idg, ipagef, isave, mxitlp, kprint, itbrc, npp, lprg
  REAL(SP) :: aij, anorm,  dirnrm, dulnrm, erdnrm, factor, gg, resnrm, rhsnrm, &
    rprnrm, rzj, scalr, scosts, sizee, theta, upbnd, uu, xlamda, xval, rdum(01)
  REAL(SP), TARGET :: ropt(07)
  REAL(SP), POINTER :: eps, asmall, abig, costsc, tolls, tune, tolabs
  !
  !
  !     ARRAY LOCAL VARIABLES
  !     NAME(LENGTH)          DESCRIPTION
  !
  !     COSTS(NVARS)          COST COEFFICIENTS
  !     PRGOPT( )             OPTION VECTOR
  !     DATTRV( )             DATA TRANSFER VECTOR
  !     PRIMAL(NVARS+MRELAS)  AS OUTPUT IT IS PRIMAL SOLUTION OF LP.
  !                           INTERNALLY, THE FIRST NVARS POSITIONS HOLD
  !                           THE COLUMN CHECK SUMS.  THE NEXT MRELAS
  !                           POSITIONS HOLD THE CLASSIFICATION FOR THE
  !                           BASIC VARIABLES  -1 VIOLATES LOWER
  !                           BOUND, 0 FEASIBLE, +1 VIOLATES UPPER BOUND
  !     DUALS(MRELAS+NVARS)   DUAL SOLUTION. INTERNALLY HOLDS R.H. SIDE
  !                           AS FIRST MRELAS ENTRIES.
  !     AMAT(LMX)             SPARSE FORM OF DATA MATRIX
  !     IMAT(LMX)             SPARSE FORM OF DATA MATRIX
  !     BL(NVARS+MRELAS)      LOWER BOUNDS FOR VARIABLES
  !     BU(NVARS+MRELAS)      UPPER BOUNDS FOR VARIABLES
  !     IND(NVARS+MRELAS)     INDICATOR FOR VARIABLES
  !     CSC(NVARS)            COLUMN SCALING
  !     IBASIS(NVARS+MRELAS)  COLS. 1-MRELAS ARE BASIC, REST ARE NON-BASIC
  !     IBB(NVARS+MRELAS)     INDICATOR FOR NON-BASIC VARS., POLARITY OF
  !                           VARS., AND POTENTIALLY INFINITE VARS.
  !                           IF IBB(J)<0, VARIABLE J IS BASIC
  !                           IF IBB(J)>0, VARIABLE J IS NON-BASIC
  !                           IF IBB(J)=0, VARIABLE J HAS TO BE IGNORED
  !                           BECAUSE IT WOULD CAUSE UNBOUNDED SOLN.
  !                           WHEN MOD(IBB(J),2)=0, VARIABLE IS AT ITS
  !                           UPPER BOUND, OTHERWISE IT IS AT ITS LOWER
  !                           BOUND
  !     COLNRM(NVARS)         NORM OF COLUMNS
  !     ERD(MRELAS)           ERRORS IN DUAL VARIABLES
  !     ERP(MRELAS)           ERRORS IN PRIMAL VARIABLES
  !     BASMAT(LBM)           BASIS MATRIX FOR HARWELL SPARSE CODE
  !     IBRC(LBM,2)           ROW AND COLUMN POINTERS FOR BASMAT(*)
  !     IPR(2*MRELAS)         WORK ARRAY FOR HARWELL SPARSE CODE
  !     IWR(8*MRELAS)         WORK ARRAY FOR HARWELL SPARSE CODE
  !     WR(MRELAS)            WORK ARRAY FOR HARWELL SPARSE CODE
  !     RZ(NVARS+MRELAS)      REDUCED COSTS
  !     RPRIM(MRELAS)         INTERNAL PRIMAL SOLUTION
  !     RG(NVARS+MRELAS)      COLUMN WEIGHTS
  !     WW(MRELAS)            WORK ARRAY
  !     RHS(MRELAS)           HOLDS TRANSLATED RIGHT HAND SIDE
  !
  !     SCALAR LOCAL VARIABLES
  !     NAME       TYPE         DESCRIPTION
  !
  !     LMX        INTEGER      LENGTH OF AMAT(*)
  !     LPG        INTEGER      LENGTH OF PAGE FOR AMAT(*)
  !     EPS        REAL         MACHINE PRECISION
  !     TUNE       REAL         PARAMETER TO SCALE ERROR ESTIMATES
  !     TOLLS      REAL         RELATIVE TOLERANCE FOR SMALL RESIDUALS
  !     TOLABS     REAL         ABSOLUTE TOLERANCE FOR SMALL RESIDUALS.
  !                             USED IF RELATIVE ERROR TEST FAILS.
  !                             IN CONSTRAINT EQUATIONS
  !     FACTOR     REAL         .01--DETERMINES IF BASIS IS SINGULAR
  !                             OR COMPONENT IS FEASIBLE.  MAY NEED TO
  !                             BE INCREASED TO 1.E0 ON SHORT WORD
  !                             LENGTH MACHINES.
  !     ASMALL     REAL         LOWER BOUND FOR NON-ZERO MAGN. IN AMAT(*)
  !     ABIG       REAL         UPPER BOUND FOR NON-ZERO MAGN. IN AMAT(*)
  !     MXITLP     INTEGER      MAXIMUM NUMBER OF ITERATIONS FOR LP
  !     ITLP       INTEGER      ITERATION COUNTER FOR TOTAL LP ITERS
  !     COSTSC     REAL         COSTS(*) SCALING
  !     SCOSTS     REAL         TEMP LOC. FOR COSTSC.
  !     XLAMDA     REAL         WEIGHT PARAMETER FOR PEN. METHOD.
  !     ANORM      REAL         NORM OF DATA MATRIX AMAT(*)
  !     RPRNRM     REAL         NORM OF THE SOLUTION
  !     DULNRM     REAL         NORM OF THE DUALS
  !     ERDNRM     REAL         NORM OF ERROR IN DUAL VARIABLES
  !     DIRNRM     REAL         NORM OF THE DIRECTION VECTOR
  !     RHSNRM     REAL         NORM OF TRANSLATED RIGHT HAND SIDE VECTOR
  !     RESNRM     REAL         NORM OF RESIDUAL VECTOR FOR CHECKING
  !                             FEASIBILITY
  !     NZBM       INTEGER      NUMBER OF NON-ZEROS IN BASMAT(*)
  !     LBM        INTEGER      LENGTH OF BASMAT(*)
  !     SMALL      REAL         EPS*ANORM  USED IN HARWELL SPARSE CODE
  !     LP         INTEGER      USED IN HARWELL LA05*() PACK AS OUTPUT
  !                             FILE NUMBER. SET=ERROR_UNIT NOW.
  !     UU         REAL         0.1--USED IN HARWELL SPARSE CODE
  !                             FOR RELATIVE PIVOTING TOLERANCE.
  !     GG         REAL         OUTPUT INFO FLAG IN HARWELL SPARSE CODE
  !     IPLACE     INTEGER      INTEGER USED BY SPARSE MATRIX CODES
  !     IENTER     INTEGER      NEXT COLUMN TO ENTER BASIS
  !     NREDC      INTEGER      NO. OF FULL REDECOMPOSITIONS
  !     KPRINT     INTEGER      LEVEL OF OUTPUT, =0-3
  !     IDG        INTEGER      FORMAT AND PRECISION OF OUTPUT
  !     ITBRC      INTEGER      NO. OF ITERS. BETWEEN RECALCULATING
  !                             THE ERROR IN THE PRIMAL SOLUTION.
  !     NPP        INTEGER      NO. OF NEGATIVE REDUCED COSTS REQUIRED
  !                             IN PARTIAL PRICING
  !     JSTRT      INTEGER      STARTING PLACE FOR PARTIAL PRICING.
  !
  LOGICAL, TARGET :: lopt(8)
  LOGICAL, POINTER :: colscp, savedt, contin, cstscp, minprb, sizeup, stpedg, usrbas
  LOGICAL :: unbnd, feas, finite, found, redbas, singlr, trans, zerolv
  CHARACTER(8) :: xern1, xern2

  contin => lopt(1)
  usrbas => lopt(2)
  sizeup => lopt(3)
  savedt => lopt(4)
  colscp => lopt(5)
  cstscp => lopt(6)
  minprb => lopt(7)
  stpedg => lopt(8)
  idg => intopt(1)
  ipagef => intopt(2)
  isave => intopt(3)
  mxitlp => intopt(4)
  kprint => intopt(5)
  itbrc => intopt(6)
  npp => intopt(7)
  lprg => intopt(8)
  eps => ropt(1)
  asmall => ropt(2)
  abig => ropt(3)
  costsc => ropt(4)
  tolls => ropt(5)
  tune => ropt(6)
  tolabs => ropt(7)
  !
  !     SET LP=0 SO NO ERROR MESSAGES WILL PRINT WITHIN LA05 () PACKAGE.
  !* FIRST EXECUTABLE STATEMENT  SPLPMN
  lp_com = 0
  !
  !     THE VALUES ZERO AND ONE.
  factor = 0.01_SP
  lpg = Lmx - (Nvars+4)
  iopt = 1
  Info = 0
  unbnd = .FALSE.
  jstrt = 1
  !
  !     PROCESS USER OPTIONS IN PRGOPT(*).
  !     CHECK THAT ANY USER-GIVEN CHANGES ARE WELL-DEFINED.
  CALL SPOPT(Prgopt,Mrelas,Nvars,Info,Csc,Ibasis,ropt,intopt,lopt)
  IF( Info<0 ) GOTO 4600
  IF( .NOT. (contin) ) THEN
    !
    !     INITIALIZE SPARSE DATA MATRIX, AMAT(*) AND IMAT(*).
    CALL PINITM(Mrelas,Nvars,Amat,Imat,Lmx,ipagef)
  ELSE
    ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
    !     PROCEDURE (RETRIEVE SAVED DATA FROM FILE ISAVE)
    lpr = Nvars + 4
    REWIND isave
    READ (isave) (Amat(i),i=1,lpr), (Imat(i),i=1,lpr)
    key = 2
    ipage = 1
    GOTO 2500
  END IF
  !
  !     UPDATE MATRIX DATA AND CHECK BOUNDS FOR CONSISTENCY.
  100  CALL SPLPUP(USRMAT,Mrelas,Nvars,Dattrv,Bl,Bu,Ind,Info,Amat,Imat,&
    sizeup,asmall,abig)
  IF( Info<0 ) GOTO 4600
  !
  !++  CODE FOR OUTPUT=YES IS ACTIVE
  IF( kprint>=1 ) THEN
    ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
    !++  CODE FOR OUTPUT=YES IS ACTIVE
    !     PROCEDURE (PRINT PROLOGUE)
    idum(1) = Mrelas
    CALL IVOUT(1,idum,'(''1NUM. OF DEPENDENT VARS., MRELAS'')',idg)
    idum(1) = Nvars
    CALL IVOUT(1,idum,'('' NUM. OF INDEPENDENT VARS., NVARS'')',idg)
    CALL IVOUT(1,idum,'('' DIMENSION OF COSTS(*)='')',idg)
    idum(1) = Nvars + Mrelas
    CALL IVOUT(1,idum,&
      '('' DIMENSIONS OF BL(*),BU(*),IND(*)''/'' PRIMAL(*),DUALS(*) ='')',idg)
    CALL IVOUT(1,idum,'('' DIMENSION OF IBASIS(*)='')',idg)
    idum(1) = lprg + 1
    CALL IVOUT(1,idum,'('' DIMENSION OF PRGOPT(*)='')',idg)
    CALL IVOUT(0,idum,'('' 1-NVARS=INDEPENDENT VARIABLE INDICES.''/&
      &'' (NVARS+1)-(NVARS+MRELAS)=DEPENDENT VARIABLE INDICES.''/&
      &'' CONSTRAINT INDICATORS ARE 1-4 AND MEAN'')',idg)
    CALL IVOUT(0,idum,'('' 1=VARIABLE HAS ONLY LOWER BOUND.''/&
      &'' 2=VARIABLE HAS ONLY UPPER BOUND.''/&
      &'' 3=VARIABLE HAS BOTH BOUNDS.''/&
      &'' 4=VARIABLE HAS NO BOUNDS, IT IS FREE.'')',idg)
    CALL SVOUT(Nvars,Costs,'('' ARRAY OF COSTS'')',idg)
    CALL IVOUT(Nvars+Mrelas,Ind,'('' CONSTRAINT INDICATORS'')',idg)
    CALL SVOUT(Nvars+Mrelas,Bl,&
      '('' LOWER BOUNDS FOR VARIABLES  (IGNORE UNUSED ENTRIES.)'')',idg)
    CALL SVOUT(Nvars+Mrelas,Bu,&
      '('' UPPER BOUNDS FOR VARIABLES  (IGNORE UNUSED ENTRIES.)'')',idg)
    IF( kprint>=2 ) THEN
      CALL IVOUT(0,idum,'(''0NON-BASIC INDICES THAT ARE NEGATIVE SHOW VARIABLES&
        & EXCHANGED AT A ZERO''/&
        &'' STEP LENGTH'')',idg)
      CALL IVOUT(0,idum,'('' WHEN COL. NO. LEAVING=COL. NO. ENTERING,&
        &THE ENTERING VARIABLE MOVED''/&
        &'' TO ITS BOUND.  IT REMAINS NON-BASIC.''/&
        &'' WHEN COL. NO. OF BASIS EXCHANGED IS NEGATIVE, THE LEAVING''/&
        &'' VARIABLE IS AT ITS UPPER BOUND.'')',idg)
    END IF
  END IF
  !++  CODE FOR OUTPUT=NO IS INACTIVE
  !++  END
  !
  !     INITIALIZATION. SCALE DATA, NORMALIZE BOUNDS, FORM COLUMN
  !     CHECK SUMS, AND FORM INITIAL BASIS MATRIX.
  CALL SPINIT(Mrelas,Nvars,Costs,Bl,Bu,Ind,Primal,Amat,Csc,costsc,&
    Colnrm,xlamda,anorm,Rhs,rhsnrm,Ibasis,Ibb,Imat,lopt)
  IF( Info<0 ) GOTO 4600
  !
  nredc = 0
  npr004 = 200
  GOTO 2700
  200 CONTINUE
  IF( .NOT. (singlr) ) THEN
    npr005 = 300
    ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
    !     PROCEDURE (COMPUTE ERROR IN DUAL AND PRIMAL SYSTEMS)
    ntries = 1
    GOTO 3000
  ELSE
    nerr = 23
    ERROR STOP 'SPLPMN : IN SPLP,  A SINGULAR INITIAL BASIS WAS ENCOUNTERED.'
    Info = -nerr
    GOTO 4600
  END IF
  300  npr006 = 400
  GOTO 4000
  400  npr007 = 500
  GOTO 2800
  500 CONTINUE
  IF( .NOT. (usrbas) ) GOTO 700
  npr008 = 600
  GOTO 3100
  600 CONTINUE
  IF( .NOT. feas ) THEN
    nerr = 24
    ERROR STOP 'SPLPMN : IN SPLP, AN INFEASIBLE INITIAL BASIS WAS ENCOUNTERED.'
    Info = -nerr
    GOTO 4600
  END IF
  700  itlp = 0
  !
  !     LAMDA HAS BEEN SET TO A CONSTANT, PERFORM PENALTY METHOD.
  npr009 = 800
  !     PROCEDURE (PERFORM SIMPLEX STEPS)
  npr013 = 2000
  GOTO 4100
  800  npr010 = 900
  GOTO 1900
  900  npr006 = 1000
  GOTO 4000
  1000 npr008 = 1100
  GOTO 3100
  1100 CONTINUE
  IF( feas ) THEN
    !     CHECK IF ANY BASIC VARIABLES ARE STILL CLASSIFIED AS
    !     INFEASIBLE.  IF ANY ARE, THEN THIS MAY NOT YET BE AN
    !     OPTIMAL POINT.  THEREFORE SET LAMDA TO ZERO AND TRY
    !     TO PERFORM MORE SIMPLEX STEPS.
    i = 1
    n20046 = Mrelas
    DO WHILE( (n20046-i)>=0 )
      IF( Primal(i+Nvars)/=0._SP ) THEN
        xlamda = 0._SP
        npr009 = 1700
        npr013= 2000
        GOTO 4100
      ELSE
        i = i + 1
      END IF
    END DO
    GOTO 1700
  ELSE
    !
    !     SET LAMDA TO INFINITY BY SETTING COSTSC TO ZERO (SAVE THE VALUE OF
    !     COSTSC) AND PERFORM STANDARD PHASE-1.
    IF( kprint>=2 ) CALL IVOUT(0,idum,'('' ENTER STANDARD PHASE-1'')',idg)
    scosts = costsc
    costsc = 0._SP
    npr007 = 1200
    GOTO 2800
  END IF
  1200 npr009 = 1300
  npr013 = 2000
  GOTO 4100
  1300 npr010 = 1400
  GOTO 1900
  1400 npr006 = 1500
  GOTO 4000
  1500 npr008 = 1600
  GOTO 3100
  1600 CONTINUE
  IF( feas ) THEN
    !
    !     SET LAMDA TO ZERO, COSTSC=SCOSTS, PERFORM STANDARD PHASE-2.
    IF( kprint>1 ) CALL IVOUT(0,idum,'('' ENTER STANDARD PHASE-2'')',idg)
    xlamda = 0._SP
    costsc = scosts
    npr009 = 1700
    npr013 = 2000
    GOTO 4100
  END IF
  !
  1700 npr011 = 1800
  ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
  !     PROCEDURE(RESCALE AND REARRANGE VARIABLES)
  !
  !     RESCALE THE DUAL VARIABLES.
  npr013 = 4300
  GOTO 4100
  1800 CONTINUE
  IF( feas .AND. ( .NOT. unbnd) ) THEN
    Info = 1
  ELSEIF( ( .NOT. feas) .AND. ( .NOT. unbnd) ) THEN
    nerr = 1
    Info = -nerr
    ERROR STOP 'SPLPMN : IN SPLP, THE PROBLEM APPEARS TO BE INFEASIBLE'
  ELSEIF( feas .AND. unbnd ) THEN
    nerr = 2
    Info = -nerr
    ERROR STOP 'SPLPMN : IN SPLP, THE PROBLEM APPEARS TO HAVE NO FINITE SOLUTION.'
  ELSEIF( ( .NOT. feas) .AND. unbnd ) THEN
    nerr = 3
    Info = -nerr
    ERROR STOP 'SPLPMN : IN SPLP, THE PROBLEM APPEARS TO BE INFEASIBLE AND TO HAVE NO FINITE SOLUTION.'
  END IF
  !
  IF( Info==(-1) .OR. Info==(-3) ) THEN
    sizee = SUM(ABS(Primal(1:Nvars)))*anorm
    sizee = sizee/SUM(ABS(Csc(1:Nvars)))
    sizee = sizee + SUM(ABS(Primal(Nvars+1:Nvars+Mrelas)))
    i = 1
    n20058 = Nvars + Mrelas
    DO WHILE( (n20058-i)>=0 )
      nx0066 = Ind(i)
      IF( nx0066>=1 .AND. nx0066<=4 ) THEN
        SELECT CASE (nx0066)
          CASE (2)
            IF( sizee+ABS(Primal(i)-Bu(i))*factor/=sizee ) THEN
              IF( Primal(i)>=Bu(i) ) Ind(i) = -4
            END IF
          CASE (3)
            IF( sizee+ABS(Primal(i)-Bl(i))*factor/=sizee ) THEN
              IF( Primal(i)<Bl(i) ) THEN
                Ind(i) = -4
              ELSEIF( sizee+ABS(Primal(i)-Bu(i))*factor/=sizee ) THEN
                IF( Primal(i)>Bu(i) ) Ind(i) = -4
              END IF
            END IF
          CASE (4)
          CASE DEFAULT
            IF( sizee+ABS(Primal(i)-Bl(i))*factor/=sizee ) THEN
              IF( Primal(i)<=Bl(i) ) Ind(i) = -4
            END IF
        END SELECT
      END IF
      i = i + 1
    END DO
  END IF
  !
  IF( Info==(-2) .OR. Info==(-3) ) THEN
    j = 1
    n20080 = Nvars
    DO WHILE( (n20080-j)>=0 )
      IF( Ibb(j)==0 ) THEN
        nx0091 = Ind(j)
        IF( nx0091>=1 .AND. nx0091<=4 ) THEN
          SELECT CASE (nx0091)
            CASE (2)
              Bl(j) = Bu(j)
              Ind(j) = -3
            CASE (3)
            CASE (4)
              Bl(j) = 0._SP
              Bu(j) = 0._SP
              Ind(j) = -3
            CASE DEFAULT
              Bu(j) = Bl(j)
              Ind(j) = -3
          END SELECT
        END IF
      END IF
      j = j + 1
    END DO
  END IF
  !++  CODE FOR OUTPUT=YES IS ACTIVE
  IF( kprint<1 ) GOTO 4600
  npr012 = 4600
  !++  CODE FOR OUTPUT=NO IS INACTIVE
  !++  END
  GOTO 4500
  ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
  !     PROCEDURE (COMPUTE RIGHT HAND SIDE)
  1900 Rhs(1:Mrelas) = 0._SP
  j = 1
  n20098 = Nvars + Mrelas
  DO WHILE( (n20098-j)>=0 )
    nx0106 = Ind(j)
    IF( nx0106>=1 .AND. nx0106<=4 ) THEN
      SELECT CASE (nx0106)
        CASE (2)
          scalr = -Bu(j)
        CASE (3)
          scalr = -Bl(j)
        CASE (4)
          scalr = 0._SP
        CASE DEFAULT
          scalr = -Bl(j)
      END SELECT
    END IF
    IF( scalr==0._SP ) THEN
      j = j + 1
    ELSEIF( j>Nvars ) THEN
      Rhs(j-Nvars) = Rhs(j-Nvars) - scalr
      j = j + 1
    ELSE
      i = 0
      DO
        CALL PNNZRS(i,aij,iplace,Amat,Imat,j)
        IF( i>0 ) THEN
          Rhs(i) = Rhs(i) + aij*scalr
        ELSE
          j = j + 1
          EXIT
        END IF
      END DO
    END IF
  END DO
  j = 1
  n20119 = Nvars + Mrelas
  DO WHILE( (n20119-j)>=0 )
    scalr = 0._SP
    IF( Ind(j)==3 .AND. MOD(Ibb(j),2)==0 ) scalr = Bu(j) - Bl(j)
    IF( scalr==0._SP ) THEN
      j = j + 1
    ELSEIF( j>Nvars ) THEN
      Rhs(j-Nvars) = Rhs(j-Nvars) + scalr
      j = j + 1
    ELSE
      i = 0
      DO
        CALL PNNZRS(i,aij,iplace,Amat,Imat,j)
        IF( i>0 ) THEN
          Rhs(i) = Rhs(i) - aij*scalr
        ELSE
          j = j + 1
          EXIT
        END IF
      END DO
    END IF
  END DO
  SELECT CASE(npr010)
    CASE(900)
      GOTO 900
    CASE(1400)
      GOTO 1400
  END SELECT
  2000 npr014 = 2100
  GOTO 3200
  2100 CONTINUE
  IF( kprint>2 ) THEN
    CALL SVOUT(Mrelas,Duals,'('' BASIC (INTERNAL) DUAL SOLN.'')',idg)
    CALL SVOUT(Nvars+Mrelas,Rz,'('' REDUCED COSTS'')',idg)
  END IF
  npr015 = 2200
  GOTO 4200
  2200 CONTINUE
  IF( .NOT. found ) THEN
    ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
    !     PROCEDURE (REDECOMPOSE BASIS MATRIX AND TRY AGAIN)
    IF( redbas ) GOTO 3900
    npr004 = 3500
    GOTO 2700
  END IF
  2300 CONTINUE
  IF( .NOT. (found) ) THEN
    SELECT CASE(npr009)
      CASE(800)
        GOTO 800
      CASE(1300)
        GOTO 1300
      CASE(1700)
        GOTO 1700
    END SELECT
  ELSE
    IF( kprint>=3 ) CALL SVOUT(Mrelas,Ww,'('' SEARCH DIRECTION'')',idg)
    ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
    !     PROCEDURE (CHOOSE VARIABLE TO LEAVE BASIS)
    CALL SPLPFL(Mrelas,Nvars,ienter,ileave,Ibasis,Ind,theta,dirnrm,&
      rprnrm,Csc,Ww,Bl,Bu,Erp,Rprim,Primal,finite,zerolv)
    IF( .NOT. (finite) ) THEN
      unbnd = .TRUE.
      Ibb(Ibasis(ienter)) = 0
    ELSE
      ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      !     PROCEDURE (MAKE MOVE AND UPDATE)
      CALL SPLPMU(Mrelas,Nvars,Lmx,Lbm,nredc,Info,ienter,ileave,npp,&
        jstrt,Ibasis,Imat,Ibrc,Ipr,Iwr,Ind,Ibb,anorm,eps,uu,gg,&
        rprnrm,erdnrm,dulnrm,theta,costsc,xlamda,rhsnrm,Amat,&
        Basmat,Csc,Wr,Rprim,Ww,Bu,Bl,Rhs,Erd,Erp,Rz,Rg,Colnrm,&
        Costs,Primal,Duals,singlr,redbas,zerolv,stpedg)
      IF( Info==(-26) ) GOTO 4600
      !++  CODE FOR OUTPUT=YES IS ACTIVE
      IF( kprint>=2 ) THEN
        ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
        !     PROCEDURE (PRINT ITERATION SUMMARY)
        idum(1) = itlp + 1
        CALL IVOUT(1,idum,'(''0ITERATION NUMBER'')',idg)
        idum(1) = Ibasis(ABS(ileave))
        CALL IVOUT(1,idum,'('' INDEX OF VARIABLE ENTERING THE BASIS'')',idg)
        idum(1) = ileave
        CALL IVOUT(1,idum,'('' COLUMN OF THE BASIS EXCHANGED'')',idg)
        idum(1) = Ibasis(ienter)
        CALL IVOUT(1,idum,'('' INDEX OF VARIABLE LEAVING THE BASIS'')',idg)
        rdum(1) = theta
        CALL SVOUT(1,rdum,'('' LENGTH OF THE EXCHANGE STEP'')',idg)
        IF( kprint>=3 ) THEN
          CALL SVOUT(Mrelas,Rprim,'('' BASIC (INTERNAL) PRIMAL SOLN.'')',idg)
          CALL IVOUT(Nvars+Mrelas,Ibasis,&
            '('' VARIABLE INDICES IN POSITIONS 1-MRELAS ARE BASIC.'')',idg)
          CALL IVOUT(Nvars+Mrelas,Ibb,'('' IBB ARRAY'')',idg)
          CALL SVOUT(Mrelas,Rhs,'('' TRANSLATED RHS'')',idg)
          CALL SVOUT(Mrelas,Duals,'('' BASIC (INTERNAL) DUAL SOLN.'')',idg)
        END IF
        !++  CODE FOR OUTPUT=NO IS INACTIVE
        !++  END
      END IF
      npr005 = 2400
      ntries = 1
      GOTO 3000
    END IF
  END IF
  2400 itlp = itlp + 1
  ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
  !     PROCEDURE (CHECK AND RETURN WITH EXCESS ITERATIONS)
  IF( itlp<=mxitlp ) THEN
    npr015 = 2200
    GOTO 4200
  ELSE
    nerr = 25
    npr011 = 3300
    npr013 = 4300
    GOTO 4100
  END IF
  2500 lpr1 = lpr + 1
  READ (isave) (Amat(i),i=lpr1,Lmx), (Imat(i),i=lpr1,Lmx)
  np = Imat(Lmx-1)
  ipage = ipage + 1
  IF( np>=0 ) GOTO 2500
  nparm = Nvars + Mrelas
  READ (isave) (Ibasis(i),i=1,nparm)
  REWIND isave
  GOTO 100
  2600 CONTINUE
  lpr1 = lpr + 1
  WRITE (isave) (Amat(i),i=lpr1,Lmx), (Imat(i),i=lpr1,Lmx)
  np = Imat(Lmx-1)
  ipage = ipage + 1
  IF( np>=0 ) GOTO 2600
  nparm = Nvars + Mrelas
  WRITE (isave) (Ibasis(i),i=1,nparm)
  ENDFILE isave
  RETURN
  ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
  !     PROCEDURE (DECOMPOSE BASIS MATRIX)
  !++  CODE FOR OUTPUT=YES IS ACTIVE
  2700 CONTINUE
  IF( kprint>=2 ) CALL IVOUT(Mrelas,Ibasis,&
    '('' SUBSCRIPTS OF BASIC VARIABLES DURING REDECOMPOSITION'')',idg)
  !++  CODE FOR OUTPUT=NO IS INACTIVE
  !++  END
  !
  !     SET RELATIVE PIVOTING FACTOR FOR USE IN LA05 () PACKAGE.
  uu = 0.1_SP
  CALL SPLPDM(Mrelas,Nvars,Lbm,nredc,Info,Ibasis,Imat,Ibrc,Ipr,Iwr,&
    Ind,anorm,eps,uu,gg,Amat,Basmat,Csc,Wr,singlr,redbas)
  IF( Info<0 ) GOTO 4600
  SELECT CASE(npr004)
    CASE(200)
      GOTO 200
    CASE(2900)
      GOTO 2900
    CASE(3500)
      GOTO 3500
  END SELECT
  ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
  !     PROCEDURE (CLASSIFY VARIABLES)
  !
  !     DEFINE THE CLASSIFICATION OF THE BASIC VARIABLES
  !     -1 VIOLATES LOWER BOUND, 0 FEASIBLE, +1 VIOLATES UPPER BOUND.
  !     (THIS INFO IS STORED IN PRIMAL(NVARS+1)-PRIMAL(NVARS+MRELAS))
  !     TRANSLATE VARIABLE TO ITS UPPER BOUND, IF > UPPER BOUND
  2800 Primal(Nvars+1:Nvars+Mrelas) = 0._SP
  i = 1
  n20172 = Mrelas
  DO WHILE( (n20172-i)>=0 )
    j = Ibasis(i)
    IF( Ind(j)/=4 ) THEN
      IF( Rprim(i)<0._SP ) THEN
        Primal(i+Nvars) = -1._SP
      ELSEIF( Ind(j)==3 ) THEN
        upbnd = Bu(j) - Bl(j)
        IF( j<=Nvars ) upbnd = upbnd/Csc(j)
        IF( Rprim(i)>upbnd ) THEN
          Rprim(i) = Rprim(i) - upbnd
          IF( j>Nvars ) THEN
            Rhs(j-Nvars) = Rhs(j-Nvars) + upbnd
          ELSE
            k = 0
            DO
              CALL PNNZRS(k,aij,iplace,Amat,Imat,j)
              IF( k<=0 ) EXIT
              Rhs(k) = Rhs(k) - upbnd*aij*Csc(j)
            END DO
          END IF
          Primal(i+Nvars) = 1._SP
        END IF
      END IF
    END IF
    i = i + 1
  END DO
  SELECT CASE(npr007)
    CASE(500)
      GOTO 500
    CASE(1200)
      GOTO 1200
  END SELECT
  2900 ntries = ntries + 1
  3000 CONTINUE
  IF( (2-ntries)>=0 ) THEN
    CALL SPLPCE(Mrelas,Nvars,Lmx,Lbm,itlp,itbrc,Ibasis,Imat,Ibrc,Ipr,Iwr,&
      Ind,Ibb,erdnrm,eps,tune,gg,Amat,Basmat,Csc,Wr,Ww,Primal,Erd,Erp,singlr,redbas)
    IF( .NOT. singlr ) THEN
      !++  CODE FOR OUTPUT=YES IS ACTIVE
      IF( kprint>=3 ) THEN
        CALL SVOUT(Mrelas,Erp,'('' EST. ERROR IN PRIMAL COMPS.'')',idg)
        !++  CODE FOR OUTPUT=NO IS INACTIVE
        !++  END
        CALL SVOUT(Mrelas,Erd,'('' EST. ERROR IN DUAL COMPS.'')',idg)
      END IF
      SELECT CASE(npr005)
        CASE(300)
          GOTO 300
        CASE(2400)
          GOTO 2400
        CASE(3600)
          GOTO 3600
      END SELECT
    ELSEIF( ntries/=2 ) THEN
      npr004 = 2900
      GOTO 2700
    END IF
  END IF
  nerr = 26
  Info = -nerr
  ERROR STOP 'SPLPMN : IN SPLP, MOVED TO A SINGULAR POINT.  THIS SHOULD NOT HAPPEN.'
  GOTO 4600
  ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
  !     PROCEDURE (CHECK FEASIBILITY)
  !
  !     SEE IF NEARBY FEASIBLE POINT SATISFIES THE CONSTRAINT
  !     EQUATIONS.
  !
  !     COPY RHS INTO WW(*), THEN UPDATE WW(*).
  3100 Ww(1:Mrelas) = Rhs(1:Mrelas)
  j = 1
  n20206 = Mrelas
  DO WHILE( (n20206-j)>=0 )
    ibas = Ibasis(j)
    xval = Rprim(j)
    !
    !     ALL VARIABLES BOUNDED BELOW HAVE ZERO AS THAT BOUND.
    IF( Ind(ibas)<=3 ) xval = MAX(0._SP,xval)
    !
    !     IF THE VARIABLE HAS AN UPPER BOUND, COMPUTE THAT BOUND.
    IF( Ind(ibas)==3 ) THEN
      upbnd = Bu(ibas) - Bl(ibas)
      IF( ibas<=Nvars ) upbnd = upbnd/Csc(ibas)
      xval = MIN(upbnd,xval)
    END IF
    !
    !     SUBTRACT XVAL TIMES COLUMN VECTOR FROM RIGHT-HAND SIDE IN WW(*)
    IF( xval==0._SP ) THEN
      j = j + 1
    ELSEIF( ibas>Nvars ) THEN
      IF( Ind(ibas)/=2 ) THEN
        Ww(ibas-Nvars) = Ww(ibas-Nvars) + xval
      ELSE
        Ww(ibas-Nvars) = Ww(ibas-Nvars) - xval
      END IF
      j = j + 1
    ELSE
      i = 0
      DO
        CALL PNNZRS(i,aij,iplace,Amat,Imat,ibas)
        IF( i>0 ) THEN
          Ww(i) = Ww(i) - xval*aij*Csc(ibas)
        ELSE
          j = j + 1
          EXIT
        END IF
      END DO
    END IF
  END DO
  !
  !   COMPUTE NORM OF DIFFERENCE AND CHECK FOR FEASIBILITY.
  resnrm = SUM(ABS(Ww(1:Mrelas)))
  feas = resnrm<=tolls*(rprnrm*anorm+rhsnrm)
  !
  !     TRY AN ABSOLUTE ERROR TEST IF THE RELATIVE TEST FAILS.
  IF( .NOT. feas ) feas = resnrm<=tolabs
  IF( feas ) THEN
    Primal(Nvars+1:Nvars+Mrelas) = 0._SP
  END IF
  SELECT CASE(npr008)
    CASE(600)
      GOTO 600
    CASE(1100)
      GOTO 1100
    CASE(1600)
      GOTO 1600
  END SELECT
  ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
  !     PROCEDURE (INITIALIZE REDUCED COSTS AND STEEPEST EDGE WEIGHTS)
  3200 CALL SPINCW(Mrelas,Nvars,Lmx,Lbm,npp,jstrt,Imat,Ibrc,Ipr,Iwr,Ind,&
    Ibb,costsc,gg,erdnrm,dulnrm,Amat,Basmat,Csc,Wr,Ww,Rz,Rg,Costs,Colnrm,Duals,stpedg)
  !
  SELECT CASE(npr014)
    CASE(2100)
      GOTO 2100
    CASE(3900)
      GOTO 3900
  END SELECT
  !++  CODE FOR OUTPUT=YES IS ACTIVE
  3300 CONTINUE
  IF( kprint>=1 ) THEN
    npr012 = 3400
    GOTO 4500
  END IF
  !++  CODE FOR OUTPUT=NO IS INACTIVE
  !++  END
  3400 idum(1) = 0
  IF( savedt ) idum(1) = isave
  WRITE (xern1,'(I8)') mxitlp
  WRITE (xern2,'(I8)') idum(1)
  PRINT*,'SPLPMN : IN SPLP, MAX ITERATIONS = '//xern1//&
    ' TAKEN.  UP-TO-DATE RESULTS SAVED ON FILE NO. '//xern2//&
    '.  IF FILE NO. = 0, NO SAVE.'
  Info = -nerr
  GOTO 4600
  3500 npr005 = 3600
  ntries = 1
  GOTO 3000
  3600 npr006 = 3700
  GOTO 4000
  3700 npr013 = 3800
  GOTO 4100
  3800 npr014 = 3900
  GOTO 3200
  !
  !     ERASE NON-CYCLING MARKERS NEAR COMPLETION.
  3900 i = Mrelas + 1
  n20247 = Mrelas + Nvars
  DO WHILE( (n20247-i)>=0 )
    Ibasis(i) = ABS(Ibasis(i))
    i = i + 1
  END DO
  npr015 = 2300
  GOTO 4200
  ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
  !     PROCEDURE (COMPUTE NEW PRIMAL)
  !
  !     COPY RHS INTO WW(*), SOLVE SYSTEM.
  4000 Ww(1:Mrelas) = Rhs(1:Mrelas)
  trans = .FALSE.
  CALL LA05BS(Basmat,Ibrc,Lbm,Mrelas,Ipr,Iwr,Wr,gg,Ww,trans)
  Rprim(1:Mrelas) = Ww(1:Mrelas)
  rprnrm = SUM(ABS(Rprim(1:Mrelas)))
  SELECT CASE(npr006)
    CASE(400)
      GOTO 400
    CASE(1000)
      GOTO 1000
    CASE(1500)
      GOTO 1500
    CASE(3700)
      GOTO 3700
    CASE(4400)
      GOTO 4400
  END SELECT
  ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
  !     PROCEDURE (COMPUTE NEW DUALS)
  !
  !     SOLVE FOR DUAL VARIABLES. FIRST COPY COSTS INTO DUALS(*).
  4100 i = 1
  n20252 = Mrelas
  DO WHILE( (n20252-i)>=0 )
    j = Ibasis(i)
    IF( j>Nvars ) THEN
      Duals(i) = xlamda*Primal(i+Nvars)
    ELSE
      Duals(i) = costsc*Costs(j)*Csc(j) + xlamda*Primal(i+Nvars)
    END IF
    i = i + 1
  END DO
  !
  trans = .TRUE.
  CALL LA05BS(Basmat,Ibrc,Lbm,Mrelas,Ipr,Iwr,Wr,gg,Duals,trans)
  dulnrm = SUM(ABS(Duals(1:Mrelas)))
  SELECT CASE(npr013)
    CASE(2000)
      GOTO 2000
    CASE(3800)
      GOTO 3800
    CASE(4300)
      GOTO 4300
  END SELECT
  ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
  !     PROCEDURE (FIND VARIABLE TO ENTER BASIS AND GET SEARCH DIRECTION)
  4200 CALL SPLPFE(Mrelas,Nvars,Lmx,Lbm,ienter,Ibasis,Imat,Ibrc,Ipr,Iwr,Ind,Ibb,&
    erdnrm,eps,gg,dulnrm,dirnrm,Amat,Basmat,Csc,Wr,Ww,Bl,Bu,Rz,Rg,Colnrm,Duals,found)
  SELECT CASE(npr015)
    CASE(2200)
      GOTO 2200
    CASE(2300)
      GOTO 2300
  END SELECT
  4300 CONTINUE
  IF( costsc==0._SP ) THEN
    npr006 = 4400
    GOTO 4000
  ELSE
    i = 1
    n20271 = Mrelas
    DO WHILE( (n20271-i)>=0 )
      Duals(i) = Duals(i)/costsc
      i = i + 1
    END DO
    npr006 = 4400
    GOTO 4000
  END IF
  !
  !     REAPPLY COLUMN SCALING TO PRIMAL.
  4400 i = 1
  n20276 = Mrelas
  DO WHILE( (n20276-i)>=0 )
    j = Ibasis(i)
    IF( j<=Nvars ) THEN
      scalr = Csc(j)
      IF( Ind(j)==2 ) scalr = -scalr
      Rprim(i) = Rprim(i)*scalr
    END IF
    i = i + 1
  END DO
  !
  !     REPLACE TRANSLATED BASIC VARIABLES INTO ARRAY PRIMAL(*)
  Primal(1:Nvars+Mrelas) = 0._SP
  j = 1
  n20283 = Nvars + Mrelas
  DO WHILE( (n20283-j)>=0 )
    ibas = ABS(Ibasis(j))
    xval = 0._SP
    IF( j<=Mrelas ) xval = Rprim(j)
    IF( Ind(ibas)==1 ) xval = xval + Bl(ibas)
    IF( Ind(ibas)==2 ) xval = Bu(ibas) - xval
    IF( Ind(ibas)==3 ) THEN
      IF( MOD(Ibb(ibas),2)==0 ) xval = Bu(ibas) - Bl(ibas) - xval
      xval = xval + Bl(ibas)
    END IF
    Primal(ibas) = xval
    j = j + 1
  END DO
  !
  !     COMPUTE DUALS FOR INDEPENDENT VARIABLES WITH BOUNDS.
  !     OTHER ENTRIES ARE ZERO.
  j = 1
  n20290 = Nvars
  DO WHILE( (n20290-j)>=0 )
    rzj = 0._SP
    IF( Ibb(j)>0._SP .AND. Ind(j)/=4 ) THEN
      rzj = Costs(j)
      i = 0
      DO
        CALL PNNZRS(i,aij,iplace,Amat,Imat,j)
        IF( i<=0 ) EXIT
        rzj = rzj - aij*Duals(i)
      END DO
    END IF
    Duals(Mrelas+j) = rzj
    j = j + 1
  END DO
  SELECT CASE(npr011)
    CASE(1800)
      GOTO 1800
    CASE(3300)
      GOTO 3300
  END SELECT
  ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
  !     PROCEDURE (PRINT SUMMARY)
  4500 idum(1) = Info
  CALL IVOUT(1,idum,'('' THE OUTPUT VALUE OF INFO IS'')',idg)
  IF( .NOT. (minprb) ) THEN
    CALL IVOUT(0,idum,'('' THIS IS A MAXIMIZATION PROBLEM.'')',idg)
  ELSE
    CALL IVOUT(0,idum,'('' THIS IS A MINIMIZATION PROBLEM.'')',idg)
  END IF
  IF( .NOT. (stpedg) ) THEN
    CALL IVOUT(0,idum,'('' MINIMUM REDUCED COST PRICING WAS USED.'')',idg)
  ELSE
    CALL IVOUT(0,idum,'('' STEEPEST EDGE PRICING WAS USED.'')',idg)
  END IF
  rdum(1) = DOT_PRODUCT(Costs(1:Nvars),Primal(1:Nvars))
  CALL SVOUT(1,rdum,'('' OUTPUT VALUE OF THE OBJECTIVE FUNCTION'')',idg)
  CALL SVOUT(Nvars+Mrelas,Primal,&
    '('' THE OUTPUT INDEPENDENT AND DEPENDENT VARIABLES'')',idg)
  CALL SVOUT(Mrelas+Nvars,Duals,'('' THE OUTPUT DUAL VARIABLES'')',idg)
  CALL IVOUT(Nvars+Mrelas,Ibasis,&
    '('' VARIABLE INDICES IN POSITIONS 1-MRELAS ARE BASIC.'')',idg)
  idum(1) = itlp
  CALL IVOUT(1,idum,'('' NO. OF ITERATIONS'')',idg)
  idum(1) = nredc
  CALL IVOUT(1,idum,'('' NO. OF FULL REDECOMPS'')',idg)
  SELECT CASE(npr012)
    CASE(3400)
      GOTO 3400
    CASE(4600)
      GOTO 4600
  END SELECT
  !++  CODE FOR OUTPUT=NO IS INACTIVE
  !++  END
  ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
  !     PROCEDURE (RETURN TO USER)
  4600 CONTINUE
  IF( savedt ) THEN
    ! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
    !     PROCEDURE (SAVE DATA ON FILE ISAVE)
    !
    !     FORCE PAGE FILE TO BE OPENED ON RESTARTS.
    key = INT( Amat(4) )
    Amat(4) = 0._SP
    lpr = Nvars + 4
    WRITE (isave) (Amat(i),i=1,lpr), (Imat(i),i=1,lpr)
    Amat(4) = key
    ipage = 1
    key = 1
    GOTO 2600
  END IF
  !
  !     THIS TEST IS THERE ONLY TO AVOID DIAGNOSTICS ON SOME FORTRAN
  !     COMPILERS.
  RETURN
END SUBROUTINE SPLPMN