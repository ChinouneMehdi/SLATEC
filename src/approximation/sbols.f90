!** SBOLS
SUBROUTINE SBOLS(W,Mdw,Mrows,Ncols,Bl,Bu,Ind,Iopt,X,Rnorm,Mode,Rw,Iw)
  !> Solve the problem E*X = F (in the least  squares  sense)
  !  with bounds on selected X values.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  K1A2A, G2E, G2H1, G2H2
  !***
  ! **Type:**      SINGLE PRECISION (SBOLS-S, DBOLS-D)
  !***
  ! **Keywords:**  BOUNDS, CONSTRAINTS, INEQUALITY, LEAST SQUARES, LINEAR
  !***
  ! **Author:**  Hanson, R. J., (SNLA)
  !***
  ! **Description:**
  !
  !     The user must have dimension statements of the form:
  !
  !       DIMENSION W(MDW,NCOLS+1), BL(NCOLS), BU(NCOLS),
  !      * X(NCOLS+NX), RW(5*NCOLS)
  !       INTEGER IND(NCOLS), IOPT(1+NI), IW(2*NCOLS)
  !
  !     (here NX=number of extra locations required for option 4; NX=0
  !     for no options; NX=NCOLS if this option is in use. Here NI=number
  !     of extra locations required for options 1-6; NI=0 for no
  !     options.)
  !
  !   INPUT
  !   -----
  !
  !    --------------------
  !    W(MDW,*),MROWS,NCOLS
  !    --------------------
  !     The array W(*,*) contains the matrix [E:F] on entry. The matrix
  !     [E:F] has MROWS rows and NCOLS+1 columns. This data is placed in
  !     the array W(*,*) with E occupying the first NCOLS columns and the
  !     right side vector F in column NCOLS+1. The row dimension, MDW, of
  !     the array W(*,*) must satisfy the inequality MDW >= MROWS.
  !     Other values of MDW are errors. The values of MROWS and NCOLS
  !     must be positive. Other values are errors. There is an exception
  !     to this when using option 1 for accumulation of blocks of
  !     equations. In that case MROWS is an OUTPUT variable ONLY, and the
  !     matrix data for [E:F] is placed in W(*,*), one block of rows at a
  !     time.  MROWS contains the number of rows in the matrix after
  !     triangularizing several blocks of equations. This is an OUTPUT
  !     parameter ONLY when option 1 is used. See IOPT(*) CONTENTS
  !     for details about option 1.
  !
  !    ------------------
  !    BL(*),BU(*),IND(*)
  !    ------------------
  !     These arrays contain the information about the bounds that the
  !     solution values are to satisfy. The value of IND(J) tells the
  !     type of bound and BL(J) and BU(J) give the explicit values for
  !     the respective upper and lower bounds.
  !
  !    1.    For IND(J)=1, require X(J) >= BL(J).
  !          (the value of BU(J) is not used.)
  !    2.    For IND(J)=2, require X(J) <= BU(J).
  !          (the value of BL(J) is not used.)
  !    3.    For IND(J)=3, require X(J) >= BL(J) and
  !                                X(J) <= BU(J).
  !    4.    For IND(J)=4, no bounds on X(J) are required.
  !          (the values of BL(J) and BU(J) are not used.)
  !
  !     Values other than 1,2,3 or 4 for IND(J) are errors. In the case
  !     IND(J)=3 (upper and lower bounds) the condition BL(J) > BU(J)
  !     is an error.
  !
  !    -------
  !    IOPT(*)
  !    -------
  !     This is the array where the user can specify nonstandard options
  !     for SBOLSM( ). Most of the time this feature can be ignored by
  !     setting the input value IOPT(1)=99. Occasionally users may have
  !     needs that require use of the following subprogram options. For
  !     details about how to use the options see below: IOPT(*) CONTENTS.
  !
  !     Option Number   Brief Statement of Purpose
  !     ------ ------   ----- --------- -- -------
  !           1         Return to user for accumulation of blocks
  !                     of least squares equations.
  !           2         Check lengths of all arrays used in the
  !                     subprogram.
  !           3         Standard scaling of the data matrix, E.
  !           4         User provides column scaling for matrix E.
  !           5         Provide option array to the low-level
  !                     subprogram SBOLSM( ).
  !           6         Move the IOPT(*) processing pointer.
  !          99         No more options to change.
  !
  !    ----
  !    X(*)
  !    ----
  !     This array is used to pass data associated with option 4. Ignore
  !     this parameter if this option is not used. Otherwise see below:
  !     IOPT(*) CONTENTS.
  !
  !    OUTPUT
  !    ------
  !
  !    ----------
  !    X(*),RNORM
  !    ----------
  !     The array X(*) contains a solution (if MODE >=0 or =-22) for
  !     the constrained least squares problem. The value RNORM is the
  !     minimum residual vector length.
  !
  !    ----
  !    MODE
  !    ----
  !     The sign of MODE determines whether the subprogram has completed
  !     normally, or encountered an error condition or abnormal status. A
  !     value of MODE >= 0 signifies that the subprogram has completed
  !     normally. The value of MODE (>= 0) is the number of variables
  !     in an active status: not at a bound nor at the value ZERO, for
  !     the case of free variables. A negative value of MODE will be one
  !     of the cases -37,-36,...,-22, or -17,...,-2. Values < -1
  !     correspond to an abnormal completion of the subprogram. To
  !     understand the abnormal completion codes see below: ERROR
  !     MESSAGES for SBOLS( ). AN approximate solution will be returned
  !     to the user only when max. iterations is reached, MODE=-22.
  !     Values for MODE=-37,...,-22 come from the low-level subprogram
  !     SBOLSM(). See the section ERROR MESSAGES for SBOLSM() in the
  !     documentation for SBOLSM().
  !
  !    -----------
  !    RW(*),IW(*)
  !    -----------
  !     These are working arrays with 5*NCOLS and 2*NCOLS entries.
  !     (normally the user can ignore the contents of these arrays,
  !     but they must be dimensioned properly.)
  !
  !    IOPT(*) CONTENTS
  !    ------- --------
  !     The option array allows a user to modify internal variables in
  !     the subprogram without recompiling the source code. A central
  !     goal of the initial software design was to do a good job for most
  !     people. Thus the use of options will be restricted to a select
  !     group of users. The processing of the option array proceeds as
  !     follows: a pointer, here called LP, is initially set to the value
  !     1. This value is updated as each option is processed. At the
  !     pointer position the option number is extracted and used for
  !     locating other information that allows for options to be changed.
  !     The portion of the array IOPT(*) that is used for each option is
  !     fixed; the user and the subprogram both know how many locations
  !     are needed for each option. A great deal of error checking is
  !     done by the subprogram on the contents of the option array.
  !     Nevertheless it is still possible to give the subprogram optional
  !     input that is meaningless. For example option 4 uses the
  !     locations X(NCOLS+IOFF),...,X(NCOLS+IOFF+NCOLS-1) for passing
  !     scaling data. The user must manage the allocation of these
  !     locations.
  !
  !   1
  !   -
  !     This option allows the user to solve problems with a large number
  !     of rows compared to the number of variables. The idea is that the
  !     subprogram returns to the user (perhaps many times) and receives
  !     new least squares equations from the calling program unit.
  !     Eventually the user signals "that's all" and then computes the
  !     solution with one final call to subprogram SBOLS( ). The value of
  !     MROWS is an OUTPUT variable when this option is used. Its value
  !     is always in the range 0 <= MROWS <= NCOLS+1. It is equal to
  !     the number of rows after the triangularization of the entire set
  !     of equations. If LP is the processing pointer for IOPT(*), the
  !     usage for the sequential processing of blocks of equations is
  !
  !        IOPT(LP)=1
  !        Move block of equations to W(*,*) starting at
  !        the first row of W(*,*).
  !        IOPT(LP+3)=# of rows in the block; user defined
  !
  !     The user now calls SBOLS( ) in a loop. The value of IOPT(LP+1)
  !     directs the user's action. The value of IOPT(LP+2) points to
  !     where the subsequent rows are to be placed in W(*,*).
  !
  !      .<LOOP
  !      . CALL SBOLS()
  !      . IF(IOPT(LP+1) = 1) THEN
  !      .    IOPT(LP+3)=# OF ROWS IN THE NEW BLOCK; USER DEFINED
  !      .    PLACE NEW BLOCK OF IOPT(LP+3) ROWS IN
  !      .    W(*,*) STARTING AT ROW IOPT(LP+2).
  !      .
  !      .    IF( THIS IS THE LAST BLOCK OF EQUATIONS ) THEN
  !      .       IOPT(LP+1)=2
  !      .<------CYCLE LOOP
  !      .    ELSE IF(IOPT(LP+1) = 2) THEN
  !      <-------EXIT LOOP SOLUTION COMPUTED IF MODE >= 0
  !      . ELSE
  !      . ERROR CONDITION; SHOULD NOT HAPPEN.
  !      .<END LOOP
  !
  !     Use of this option adds 4 to the required length of IOPT(*).
  !
  !
  !   2
  !   -
  !     This option is useful for checking the lengths of all arrays used
  !     by SBOLS() against their actual requirements for this problem.
  !     The idea is simple: the user's program unit passes the declared
  !     dimension information of the arrays. These values are compared
  !     against the problem-dependent needs within the subprogram. If any
  !     of the dimensions are too small an error message is printed and a
  !     negative value of MODE is returned, -11 to -17. The printed error
  !     message tells how long the dimension should be. If LP is the
  !     processing pointer for IOPT(*),
  !
  !        IOPT(LP)=2
  !        IOPT(LP+1)=Row dimension of W(*,*)
  !        IOPT(LP+2)=Col. dimension of W(*,*)
  !        IOPT(LP+3)=Dimensions of BL(*),BU(*),IND(*)
  !        IOPT(LP+4)=Dimension of X(*)
  !        IOPT(LP+5)=Dimension of RW(*)
  !        IOPT(LP+6)=Dimension of IW(*)
  !        IOPT(LP+7)=Dimension of IOPT(*)
  !         .
  !        CALL SBOLS()
  !
  !     Use of this option adds 8 to the required length of IOPT(*).
  !
  !   3
  !   -
  !     This option changes the type of scaling for the data matrix E.
  !     Nominally each nonzero column of E is scaled so that the
  !     magnitude of its largest entry is equal to the value ONE. If LP
  !     is the processing pointer for IOPT(*),
  !
  !        IOPT(LP)=3
  !        IOPT(LP+1)=1,2 or 3
  !            1= Nominal scaling as noted;
  !            2= Each nonzero column scaled to have length ONE;
  !            3= Identity scaling; scaling effectively suppressed.
  !         .
  !        CALL SBOLS()
  !
  !     Use of this option adds 2 to the required length of IOPT(*).
  !
  !   4
  !   -
  !     This option allows the user to provide arbitrary (positive)
  !     column scaling for the matrix E. If LP is the processing pointer
  !     for IOPT(*),
  !
  !        IOPT(LP)=4
  !        IOPT(LP+1)=IOFF
  !        X(NCOLS+IOFF),...,X(NCOLS+IOFF+NCOLS-1)
  !        = Positive scale factors for cols. of E.
  !         .
  !        CALL SBOLS()
  !
  !     Use of this option adds 2 to the required length of IOPT(*) and
  !     NCOLS to the required length of X(*).
  !
  !   5
  !   -
  !     This option allows the user to provide an option array to the
  !     low-level subprogram SBOLSM(). If LP is the processing pointer
  !     for IOPT(*),
  !
  !        IOPT(LP)=5
  !        IOPT(LP+1)= Position in IOPT(*) where option array
  !                    data for SBOLSM() begins.
  !         .
  !        CALL SBOLS()
  !
  !     Use of this option adds 2 to the required length of IOPT(*).
  !
  !   6
  !   -
  !     Move the processing pointer (either forward or backward) to the
  !     location IOPT(LP+1). The processing point is moved to entry
  !     LP+2 of IOPT(*) if the option is left with -6 in IOPT(LP).  For
  !     example to skip over locations 3,...,NCOLS+2 of IOPT(*),
  !
  !       IOPT(1)=6
  !       IOPT(2)=NCOLS+3
  !       (IOPT(I), I=3,...,NCOLS+2 are not defined here.)
  !       IOPT(NCOLS+3)=99
  !       CALL SBOLS()
  !
  !     CAUTION: Misuse of this option can yield some very hard
  !     -to-find bugs.  Use it with care.
  !
  !   99
  !   --
  !     There are no more options to change.
  !
  !     Only option numbers -99, -6,-5,...,-1, 1,2,...,6, and 99 are
  !     permitted. Other values are errors. Options -99,-1,...,-6 mean
  !     that the respective options 99,1,...,6 are left at their default
  !     values. An example is the option to modify the (rank) tolerance:
  !
  !       IOPT(1)=-3 Option is recognized but not changed
  !       IOPT(2)=2  Scale nonzero cols. to have length ONE
  !       IOPT(3)=99
  !
  !    ERROR MESSAGES for SBOLS()
  !    ----- -------- --- -------
  !
  ! WARNING IN...
  ! SBOLS(). MDW=(I1) MUST BE POSITIVE.
  !           IN ABOVE MESSAGE, I1=         0
  ! ERROR NUMBER =         2
  ! (NORMALLY A RETURN TO THE USER TAKES PLACE FOLLOWING THIS MESSAGE.)
  !
  ! WARNING IN...
  ! SBOLS(). NCOLS=(I1) THE NO. OF VARIABLES MUST BE POSITIVE.
  !           IN ABOVE MESSAGE, I1=         0
  ! ERROR NUMBER =         3
  ! (NORMALLY A RETURN TO THE USER TAKES PLACE FOLLOWING THIS MESSAGE.)
  !
  ! WARNING IN...
  ! SBOLS(). FOR J=(I1), IND(J)=(I2) MUST BE 1-4.
  !           IN ABOVE MESSAGE, I1=         1
  !           IN ABOVE MESSAGE, I2=         0
  ! ERROR NUMBER =         4
  ! (NORMALLY A RETURN TO THE USER TAKES PLACE FOLLOWING THIS MESSAGE.)
  !
  ! WARNING IN...
  ! SBOLS(). FOR J=(I1), BOUND BL(J)=(R1) IS > BU(J)=(R2).
  !           IN ABOVE MESSAGE, I1=         1
  !           IN ABOVE MESSAGE, R1=    0.
  !           IN ABOVE MESSAGE, R2=    ABOVE MESSAGE, I1=         0
  ! ERROR NUMBER =         6
  ! (NORMALLY A RETURN TO THE USER TAKES PLACE FOLLOWING THIS MESSAGE.)
  !
  ! WARNING IN...
  ! SBOLS(). ISCALE OPTION=(I1) MUST BE 1-3.
  !           IN ABOVE MESSAGE, I1=         0
  ! ERROR NUMBER =         7
  ! (NORMALLY A RETURN TO THE USER TAKES PLACE FOLLOWING THIS MESSAGE.)
  !
  ! WARNING IN...
  ! SBOLS(). OFFSET PAST X(NCOLS) (I1) FOR USER-PROVIDED  COLUMN SCALING
  ! MUST BE POSITIVE.
  !           IN ABOVE MESSAGE, I1=         0
  ! ERROR NUMBER =         8
  ! (NORMALLY A RETURN TO THE USER TAKES PLACE FOLLOWING THIS MESSAGE.)
  !
  ! WARNING IN...
  ! SBOLS(). EACH PROVIDED COL. SCALE FACTOR MUST BE POSITIVE.
  ! COMPONENT (I1) NOW = (R1).
  !           IN ABOVE MESSAGE, I1=        ND. <= MDW=(I2).
  !           IN ABOVE MESSAGE, I1=         1
  !           IN ABOVE MESSAGE, I2=         0
  ! ERROR NUMBER =        10
  ! (NORMALLY A RETURN TO THE USER TAKES PLACE FOLLOWING THIS MESSAGE.)
  !
  ! WARNING IN...
  ! SBOLS().THE ROW DIMENSION OF W(,)=(I1) MUST BE >=THE NUMBER OF ROWS=
  ! (I2).
  !           IN ABOVE MESSAGE, I1=         0
  !           IN ABOVE MESSAGE, I2=         1
  ! ERROR NUMBER =        11
  ! (NORMALLY A RETURN TO THE USER TAKES PLACE FOLLOWING THIS MESSAGE.)
  !
  ! WARNING IN...
  ! SBOLS(). THE COLUMN DIMENSION OF W(,)=(I1) MUST BE >= NCOLS+1=(I2).
  !           IN ABOVE MESSAGE, I1=         0
  !           IN ABOVE MESSAGE, I2=         2
  ! ERROR NUMBER =        12
  ! (NORMALLY A RETURN TO THE USER TAKES PLACE FOLLOWING THIS MESSAGE.)
  !
  ! WARNING IN...
  ! SBOLS().THE DIMENSIONS OF THE ARRAYS BL(),BU(), AND IND()=(I1) MUST BE
  ! >= NCOLS=(I2).
  !           IN ABOVE MESSAGE, I1=         0
  !           IN ABOVE MESSAGE, I2=         1
  ! ERROR NUMBER =        13
  ! (NORMALLY A RETURN TO THE USER TAKES PLACE FOLLOWING THIS MESSAGE.)
  !
  ! WARNING IN...
  ! SBOLS(). THE DIMENSION OF X()=(I1) MUST BE >= THE REQD. LENGTH=(I2).
  !           IN ABOVE MESSAGE, I1=         0
  !           IN ABOVE MESSAGE, I2=         2
  ! ERROR NUMBER =        14
  ! (NORMALLY A RETURN TO THE USER TAKES PLACE FOLLOWING THIS MESSAGE.)
  !
  ! WARNING IN...
  ! SBOLS(). THE DIMENSION OF RW()=(I1) MUST BE >= 5*NCOLS=(I2).
  !           IN ABOVE MESSAGE, I1=         0
  !           IN ABOVE MESSAGE, I2=         3
  ! ERROR NUMBER =        15
  ! (NORMALLY A RETURN TO THE USER TAKES PLACE FOLLOWING THIS MESSAGE.)
  !
  ! WARNING IN...
  ! SBOLS() THE DIMENSION OF IW()=(I1) MUST BE >= 2*NCOLS=(I2).
  !           IN ABOVE MESSAGE, I1=         0
  !           IN ABOVE MESSAGE, I2=         2
  ! ERROR NUMBER =        16
  ! (NORMALLY A RETURN TO THE USER TAKES PLACE FOLLOWING THIS MESSAGE.)
  !
  ! WARNING IN...
  ! SBOLS() THE DIMENSION OF IOPT()=(I1) MUST BE >= THE REQD. LEN.=(I2).
  !           IN ABOVE MESSAGE, I1=         0
  !           IN ABOVE MESSAGE, I2=         1
  ! ERROR NUMBER =        17
  ! (NORMALLY A RETURN TO THE USER TAKES PLACE FOLLOWING THIS MESSAGE.)
  !
  !***
  ! **References:**  R. J. Hanson, Linear least squares with bounds and
  !                 linear constraints, Report SAND82-1517, Sandia
  !                 Laboratories, August 1982.
  !***
  ! **Routines called:**  ISAMAX, SBOLSM, SCOPY, SNRM2, SROT, SROTG, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   821220  DATE WRITTEN
  !   861211  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900510  Convert XERRWV calls to XERMSG calls.  (RWC)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  !
  !     SOLVE LINEAR LEAST SQUARES SYSTEM WITH BOUNDS ON
  !     SELECTED VARIABLES.
  !     REVISED 850329-1400
  !     REVISED YYMMDD-HHMM
  !     TO CHANGE THIS SUBPROGRAM FROM SINGLE TO DOUBLE PRECISION BEGIN
  !     EDITING AT THE CARD 'C++'.
  !     CHANGE THIS SUBPROGRAM NAME TO DBOLS AND THE STRINGS
  !     /SCOPY/ TO /DCOPY/, /SBOL/ TO /DBOL/,
  !     /SNRM2/ TO /DNRM2/, /ISAMAX/ TO /IDAMAX/,
  !     /SROTG/ TO /DROTG/, /SROT/ TO /DROT/, /E0/ TO /D0/,
  !     /REAL            / TO /DOUBLE PRECISION/.
  ! ++
  USE blas, ONLY : SROT, SROTG
  !
  INTEGER, INTENT(IN) :: Mdw, Ncols
  INTEGER, INTENT(INOUT) :: Mrows
  INTEGER, INTENT(OUT) :: Mode
  INTEGER, INTENT(IN) :: Ind(Ncols)
  INTEGER, INTENT(INOUT) :: Iopt(*)
  INTEGER, INTENT(OUT) :: Iw(2*Ncols)
  REAL(SP), INTENT(IN) :: Bl(Ncols), Bu(Ncols)
  REAL(SP), INTENT(INOUT) :: W(Mdw,Ncols+1), X(2*Ncols)
  REAL(SP), INTENT(OUT) :: Rnorm, Rw(5*Ncols)
  INTEGER :: i, ibig, inrows, ip, j, jp, lds, lenx, liopt, llb, lliw, llrw, &
    llx, lmdw, lndw, locdim, lp, mnew, nerr
  REAL(SP) :: sc, ss
  LOGICAL :: checkl
  CHARACTER(8) :: xern1, xern2
  CHARACTER(16) :: xern3, xern4
  INTEGER, SAVE :: locacc, lopt, iscale
  INTEGER, SAVE :: igo = 0
  !* FIRST EXECUTABLE STATEMENT  SBOLS
  nerr = 0
  Mode = 0
  IF( igo==0 ) THEN
    !     DO(CHECK VALIDITY OF INPUT DATA)
    !     PROCEDURE(CHECK VALIDITY OF INPUT DATA)
    !
    !     SEE THAT MDW IS >0. GROSS CHECK ONLY.
    IF( Mdw<=0 ) THEN
      WRITE (xern1,'(I8)') Mdw
      ERROR STOP 'SBOLS : MDW MUST BE POSITIVE.'
      !     DO(RETURN TO USER PROGRAM UNIT)
      GOTO 100
    END IF
    !
    !     SEE THAT NUMBER OF UNKNOWNS IS POSITIVE.
    IF( Ncols<=0 ) THEN
      WRITE (xern1,'(I8)') Ncols
      ERROR STOP 'SBOLS : NCOLS THE NO. OF VARIABLES MUST BE POSITIVE.'
      !     DO(RETURN TO USER PROGRAM UNIT)
      GOTO 100
    END IF
    !
    !     SEE THAT CONSTRAINT INDICATORS ARE ALL WELL-DEFINED.
    DO j = 1, Ncols
      IF( Ind(j)<1 .OR. Ind(j)>4 ) THEN
        WRITE (xern1,'(I8)') j
        WRITE (xern2,'(I8)') Ind(j)
        ERROR STOP 'SBOLS : IND(J) MUST BE 1-4.'
        !     DO(RETURN TO USER PROGRAM UNIT)
        GOTO 100
      END IF
    END DO
    !
    !     SEE THAT BOUNDS ARE CONSISTENT.
    DO j = 1, Ncols
      IF( Ind(j)==3 ) THEN
        IF( Bl(j)>Bu(j) ) THEN
          WRITE (xern1,'(I8)') j
          WRITE (xern3,'(1PE15.6)') Bl(j)
          WRITE (xern4,'(1PE15.6)') Bu(j)
          ERROR STOP 'SBOLS : BOUND BL(J) = IS > BU(J)'
          !     DO(RETURN TO USER PROGRAM UNIT)
          GOTO 100
        END IF
      END IF
    END DO
    !     END PROCEDURE
    !     DO(PROCESS OPTION ARRAY)
    !     PROCEDURE(PROCESS OPTION ARRAY)
    checkl = .FALSE.
    lenx = Ncols
    iscale = 1
    igo = 2
    lopt = 0
    lp = 0
    lds = 0
    DO
      lp = lp + lds
      ip = Iopt(lp+1)
      jp = ABS(ip)
      !
      !     TEST FOR NO MORE OPTIONS.
      IF( ip==99 ) THEN
        IF( lopt==0 ) lopt = lp + 1
        !     END PROCEDURE
        IF( checkl ) THEN
          !     DO(CHECK LENGTHS OF ARRAYS)
          !     PROCEDURE(CHECK LENGTHS OF ARRAYS)
          !
          !     THIS FEATURE ALLOWS THE USER TO MAKE SURE THAT THE
          !     ARRAYS ARE LONG ENOUGH FOR THE INTENDED PROBLEM SIZE AND USE.
          IF( lmdw<Mrows ) THEN
            WRITE (xern1,'(I8)') lmdw
            WRITE (xern2,'(I8)') Mrows
            ERROR STOP 'SBOLS : THE ROW DIMENSION OF W(,) MUST BE >= THE NUMBER OF ROWS'
            GOTO 100
          END IF
          IF( lndw<Ncols+1 ) THEN
            WRITE (xern1,'(I8)') lndw
            WRITE (xern2,'(I8)') Ncols + 1
            ERROR STOP 'SBOLS : THE COLUMN DIMENSION OF W(,) MUST BE >= NCOLS+1'
            !     DO(RETURN TO USER PROGRAM UNIT)
            GOTO 100
          END IF
          IF( llb<Ncols ) THEN
            WRITE (xern1,'(I8)') llb
            WRITE (xern2,'(I8)') Ncols
            ERROR STOP 'SBOLS : THE DIMENSIONS OF THE ARRAYS BL(), BU(), AND IND() &
              &MUST BE >= NCOLS'
            !     DO(RETURN TO USER PROGRAM UNIT)
            GOTO 100
          END IF
          IF( llx<lenx ) THEN
            WRITE (xern1,'(I8)') llx
            WRITE (xern2,'(I8)') lenx
            ERROR STOP 'SBOLS : THE DIMENSION OF X() MUST BE >= THE REQUIRED LENGTH'
            !     DO(RETURN TO USER PROGRAM UNIT)
            GOTO 100
          END IF
          IF( llrw<5*Ncols ) THEN
            WRITE (xern1,'(I8)') llrw
            WRITE (xern2,'(I8)') 5*Ncols
            ERROR STOP 'SBOLS : THE DIMENSION OF RW() MUST BE >= 5*NCOLS'
            !     DO(RETURN TO USER PROGRAM UNIT)
            GOTO 100
          END IF
          IF( lliw<2*Ncols ) THEN
            WRITE (xern1,'(I8)') lliw
            WRITE (xern2,'(I8)') 2*Ncols
            ERROR STOP 'SBOLS : THE DIMENSION OF IW() MUST BE >= 2*NCOLS'
            !     DO(RETURN TO USER PROGRAM UNIT)
            GOTO 100
          END IF
          IF( liopt<lp+1 ) THEN
            WRITE (xern1,'(I8)') liopt
            WRITE (xern2,'(I8)') lp + 1
            ERROR STOP 'SBOLS : THE DIMENSION OF IOPT() MUST BE >= THE REQD. LEN'
            !     DO(RETURN TO USER PROGRAM UNIT)
            GOTO 100
          END IF
          !     END PROCEDURE
        END IF
        EXIT
      ELSEIF( jp==99 ) THEN
        lds = 1
      ELSEIF( jp==1 ) THEN
        IF( ip>0 ) THEN
          !
          !     SET UP DIRECTION FLAG, ROW STACKING POINTER
          !     LOCATION, AND LOCATION FOR NUMBER OF NEW ROWS.
          locacc = lp + 2
          !
          !                  IOPT(LOCACC-1)=OPTION NUMBER FOR SEQ. ACCUMULATION.
          !     CONTENTS..   IOPT(LOCACC  )=USER DIRECTION FLAG, 1 OR 2.
          !                  IOPT(LOCACC+1)=ROW STACKING POINTER.
          !                  IOPT(LOCACC+2)=NUMBER OF NEW ROWS TO PROCESS.
          !     USER ACTION WITH THIS OPTION..
          !      (SET UP OPTION DATA FOR SEQ. ACCUMULATION IN IOPT(*).
          !      MUST ALSO START PROCESS WITH IOPT(LOCACC)=1.)
          !      (MOVE BLOCK OF EQUATIONS INTO W(*,*)  STARTING AT FIRST
          !       ROW OF W(*,*).  SET IOPT(LOCACC+2)=NO. OF ROWS IN BLOCK.)
          !              LOOP
          !              CALL SBOLS()
          !
          !                  IF(IOPT(LOCACC) = 1) THEN
          !                      STACK EQUAS., STARTING AT ROW IOPT(LOCACC+1),
          !                       INTO W(*,*).
          !                       SET IOPT(LOCACC+2)=NO. OF EQUAS.
          !                      IF LAST BLOCK OF EQUAS., SET IOPT(LOCACC)=2.
          !                  ELSE IF IOPT(LOCACC) = 2) THEN
          !                      (PROCESS IS OVER. EXIT LOOP.)
          !                  ELSE
          !                      (ERROR CONDITION. SHOULD NOT HAPPEN.)
          !                  END IF
          !              END LOOP
          !              SET IOPT(LOCACC-1)=-OPTION NUMBER FOR SEQ. ACCUMULATION.
          !              CALL SBOLS( )
          Iopt(locacc+1) = 1
          igo = 1
        END IF
        lds = 4
      ELSEIF( jp==2 ) THEN
        IF( ip>0 ) THEN
          !
          !     GET ACTUAL LENGTHS OF ARRAYS FOR CHECKING AGAINST NEEDS.
          locdim = lp + 2
          !
          !     LMDW>=MROWS
          !     LNDW>=NCOLS+1
          !     LLB >=NCOLS
          !     LLX >=NCOLS+EXTRA REQD. IN OPTIONS.
          !     LLRW>=5*NCOLS
          !     LLIW>=2*NCOLS
          !     LIOP>= AMOUNT REQD. FOR IOPTION ARRAY.
          lmdw = Iopt(locdim)
          lndw = Iopt(locdim+1)
          llb = Iopt(locdim+2)
          llx = Iopt(locdim+3)
          llrw = Iopt(locdim+4)
          lliw = Iopt(locdim+5)
          liopt = Iopt(locdim+6)
          checkl = .TRUE.
        END IF
        lds = 8
        !
        !     OPTION TO MODIFY THE COLUMN SCALING.
      ELSEIF( jp==3 ) THEN
        IF( ip>0 ) THEN
          iscale = Iopt(lp+2)
          !
          !     SEE THAT ISCALE IS 1 THRU 3.
          IF( iscale<1 .OR. iscale>3 ) THEN
            WRITE (xern1,'(I8)') iscale
            ERROR STOP 'SBOLS : ISCALE OPTION MUST BE 1-3'
            !     DO(RETURN TO USER PROGRAM UNIT)
            GOTO 100
          END IF
        END IF
        !     CYCLE FOREVER
        lds = 2
        !
        !     IN THIS OPTION THE USER HAS PROVIDED SCALING.  THE
        !     SCALE FACTORS FOR THE COLUMNS BEGIN IN X(NCOLS+IOPT(LP+2)).
      ELSEIF( jp==4 ) THEN
        IF( ip>0 ) THEN
          iscale = 4
          IF( Iopt(lp+2)<=0 ) THEN
            WRITE (xern1,'(I8)') Iopt(lp+2)
            ERROR STOP 'SBOLS : OFFSET PAST X(NCOLS)  FOR USER-PROVIDED COLUMN &
              &SCALING MUST BE POSITIVE.'
            !     DO(RETURN TO USER PROGRAM UNIT)
            GOTO 100
          END IF
          Rw(1:Ncols) = X(Ncols+Iopt(lp+2):2*Ncols+Iopt(lp+2)-1)
          lenx = lenx + Ncols
          DO j = 1, Ncols
            IF( Rw(j)<=0._SP ) THEN
              WRITE (xern1,'(I8)') j
              WRITE (xern3,'(1PE15.6)') Rw(j)
              ERROR STOP 'SBOLS : EACH PROVIDED COLUMN SCALE FACTOR MUST BE POSITIVE.'
              !     DO(RETURN TO USER PROGRAM UNIT)
              GOTO 100
            END IF
          END DO
        END IF
        !     CYCLE FOREVER
        lds = 2
        !
        !     IN THIS OPTION AN OPTION ARRAY IS PROVIDED TO SBOLSM().
      ELSEIF( jp==5 ) THEN
        IF( ip>0 ) lopt = Iopt(lp+2)
        !     CYCLE FOREVER
        lds = 2
        !
        !     THIS OPTION USES THE NEXT LOC OF IOPT(*) AS AN
        !     INCREMENT TO SKIP.
      ELSEIF( jp==6 ) THEN
        IF( ip>0 ) THEN
          lp = Iopt(lp+2) - 1
          lds = 0
        ELSE
          lds = 2
          !     CYCLE FOREVER
        END IF
        !
        !     NO VALID OPTION NUMBER WAS NOTED. THIS IS AN ERROR CONDITION.
      ELSE
        WRITE (xern1,'(I8)') jp
        ERROR STOP 'SBOLS : THE OPTION NUMBER IS NOT DEFINED.'
        !     DO(RETURN TO USER PROGRAM UNIT)
        GOTO 100
      END IF
    END DO
  END IF
  IF( igo==1 ) THEN
    !
    !     GO BACK TO THE USER FOR ACCUMULATION OF LEAST SQUARES
    !     EQUATIONS AND DIRECTIONS TO QUIT PROCESSING.
    !     CASE 1
    !     DO(ACCUMULATE LEAST SQUARES EQUATIONS)
    !     PROCEDURE(ACCUMULATE LEAST SQUARES EQUATIONS)
    Mrows = Iopt(locacc+1) - 1
    inrows = Iopt(locacc+2)
    mnew = Mrows + inrows
    IF( mnew<0 .OR. mnew>Mdw ) THEN
      WRITE (xern1,'(I8)') mnew
      WRITE (xern2,'(I8)') Mdw
      ERROR STOP 'SBOLS : NO. OF ROWS MUST BE >= 0 .AND. <= MDW'
      !     DO(RETURN TO USER PROGRAM UNIT)
      GOTO 100
    END IF
    DO j = 1, MIN(Ncols+1,mnew)
      DO i = mnew, MAX(Mrows,j) + 1, -1
        ibig = MAXLOC(W(j:i-1,j),1) + j - 1
        !
        !     PIVOT FOR INCREASED STABILITY.
        CALL SROTG(W(ibig,j),W(i,j),sc,ss)
        CALL SROT(Ncols+1-j,W(ibig,j+1),Mdw,W(i,j+1),Mdw,sc,ss)
        W(i,j) = 0._SP
      END DO
    END DO
    Mrows = MIN(Ncols+1,mnew)
    Iopt(locacc+1) = Mrows + 1
    igo = Iopt(locacc)
    !     END PROCEDURE
    IF( igo==2 ) igo = 0
  ELSEIF( igo==2 ) THEN
    !     CASE 2
    !     DO(INITIALIZE VARIABLES AND DATA VALUES)
    !     PROCEDURE(INITIALIZE VARIABLES AND DATA VALUES)
    DO j = 1, Ncols
      SELECT CASE (iscale)
        CASE (1)
          !     CASE 1
          !
          !     THIS IS THE NOMINAL SCALING. EACH NONZERO
          !     COL. HAS MAX. NORM EQUAL TO ONE.
          ibig = MAXLOC(W(1:Mrows,j),1)
          Rw(j) = ABS(W(ibig,j))
          IF( Rw(j)==0._SP ) THEN
            Rw(j) = 1._SP
          ELSE
            Rw(j) = 1._SP/Rw(j)
          END IF
        CASE (2)
          !     CASE 2
          !
          !     THIS CHOICE OF SCALING MAKES EACH NONZERO COLUMN
          !     HAVE EUCLIDEAN LENGTH EQUAL TO ONE.
          Rw(j) = NORM2(W(1:Mrows,j))
          IF( Rw(j)==0._SP ) THEN
            Rw(j) = 1._SP
          ELSE
            Rw(j) = 1._SP/Rw(j)
          END IF
        CASE (3)
          !     CASE 3
          !
          !     THIS CASE EFFECTIVELY SUPPRESSES SCALING BY SETTING
          !     THE SCALING MATRIX TO THE IDENTITY MATRIX.
          Rw(1:Ncols) = 1._SP
          !     CASE 4
          EXIT
        CASE (4)
          EXIT
        CASE DEFAULT
      END SELECT
    END DO
    !     END PROCEDURE
    !     DO(SOLVE BOUNDED LEAST SQUARES PROBLEM)
    !     PROCEDURE(SOLVE BOUNDED LEAST SQUARES PROBLEM)
    !
    !     INITIALIZE IBASIS(*), J=1,NCOLS, AND IBB(*), J=1,NCOLS,
    !     TO =J,AND =1, FOR USE IN SBOLSM( ).
    DO j = 1, Ncols
      Iw(j) = j
      Iw(j+Ncols) = 1
      Rw(3*Ncols+j) = Bl(j)
      Rw(4*Ncols+j) = Bu(j)
    END DO
    CALL SBOLSM(W,Mdw,Mrows,Ncols,Rw(3*Ncols+1),Rw(4*Ncols+1),Ind,Iopt(lopt)&
      ,X,Rnorm,Mode,Rw(Ncols+1),Rw(2*Ncols+1),Rw,Iw,Iw(Ncols+1))
    !     END PROCEDURE
    igo = 0
  END IF
  RETURN
  !     PROCEDURE(RETURN TO USER PROGRAM UNIT)
  100 CONTINUE
  IF( Mode>=0 ) Mode = -nerr
  igo = 0
  !     END PROCEDURE
END SUBROUTINE SBOLS