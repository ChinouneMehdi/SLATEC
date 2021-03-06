!** DBOCLS
SUBROUTINE DBOCLS(W,Mdw,Mcon,Mrows,Ncols,Bl,Bu,Ind,Iopt,X,Rnormc,Rnorm,Mode,Rw,Iw)
  !> Solve the bounded and constrained least squares
  !  problem consisting of solving the equation  E*X = F  (in the least squares sense)
  !  subject to the linear constraints  C*X = Y.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  K1A2A, G2E, G2H1, G2H2
  !***
  ! **Type:**      DOUBLE PRECISION (SBOCLS-S, DBOCLS-D)
  !***
  ! **Keywords:**  BOUNDS, CONSTRAINTS, INEQUALITY, LEAST SQUARES, LINEAR
  !***
  ! **Author:**  Hanson, R. J., (SNLA)
  !***
  ! **Description:**
  !
  !   **** All INPUT and OUTPUT real variables are DOUBLE PRECISION ****
  !
  !     This subprogram solves the bounded and constrained least squares
  !     problem. The problem statement is:
  !
  !     Solve E*X = F (least squares sense), subject to constraints
  !     C*X=Y.
  !
  !     In this formulation both X and Y are unknowns, and both may
  !     have bounds on any of their components.  This formulation
  !     of the problem allows the user to have equality and inequality
  !     constraints as well as simple bounds on the solution components.
  !
  !     This constrained linear least squares subprogram solves E*X=F
  !     subject to C*X=Y, where E is MROWS by NCOLS, C is MCON by NCOLS.
  !
  !      The user must have dimension statements of the form
  !
  !      DIMENSION W(MDW,NCOLS+MCON+1), BL(NCOLS+MCON), BU(NCOLS+MCON),
  !     * X(2*(NCOLS+MCON)+2+NX), RW(6*NCOLS+5*MCON)
  !       INTEGER IND(NCOLS+MCON), IOPT(17+NI), IW(2*(NCOLS+MCON))
  !
  !     (here NX=number of extra locations required for the options; NX=0
  !     if no options are in use. Also NI=number of extra locations
  !     for options 1-9.)
  !
  !    INPUT
  !    -----
  !
  !    -------------------------
  !    W(MDW,*),MCON,MROWS,NCOLS
  !    -------------------------
  !     The array W contains the (possibly null) matrix [C:*] followed by
  !     [E:F].  This must be placed in W as follows:
  !          [C  :  *]
  !     W  = [       ]
  !          [E  :  F]
  !     The (*) after C indicates that this data can be undefined. The
  !     matrix [E:F] has MROWS rows and NCOLS+1 columns. The matrix C is
  !     placed in the first MCON rows of W(*,*) while [E:F]
  !     follows in rows MCON+1 through MCON+MROWS of W(*,*). The vector F
  !     is placed in rows MCON+1 through MCON+MROWS, column NCOLS+1. The
  !     values of MDW and NCOLS must be positive; the value of MCON must
  !     be nonnegative. An exception to this occurs when using option 1
  !     for accumulation of blocks of equations. In that case MROWS is an
  !     OUTPUT variable only, and the matrix data for [E:F] is placed in
  !     W(*,*), one block of rows at a time. See IOPT(*) contents, option
  !     number 1, for further details. The row dimension, MDW, of the
  !     array W(*,*) must satisfy the inequality:
  !
  !     If using option 1,
  !                     MDW >= MCON + max(max. number of
  !                     rows accumulated, NCOLS) + 1.
  !     If using option 8,
  !                     MDW >= MCON + MROWS.
  !     Else
  !                     MDW >= MCON + max(MROWS, NCOLS).
  !
  !     Other values are errors, but this is checked only when using
  !     option=2.  The value of MROWS is an output parameter when
  !     using option number 1 for accumulating large blocks of least
  !     squares equations before solving the problem.
  !     See IOPT(*) contents for details about option 1.
  !
  !    ------------------
  !    BL(*),BU(*),IND(*)
  !    ------------------
  !     These arrays contain the information about the bounds that the
  !     solution values are to satisfy. The value of IND(J) tells the
  !     type of bound and BL(J) and BU(J) give the explicit values for
  !     the respective upper and lower bounds on the unknowns X and Y.
  !     The first NVARS entries of IND(*), BL(*) and BU(*) specify
  !     bounds on X; the next MCON entries specify bounds on Y.
  !
  !    1.    For IND(J)=1, require X(J) >= BL(J);
  !          IF J>NCOLS,        Y(J-NCOLS) >= BL(J).
  !          (the value of BU(J) is not used.)
  !    2.    For IND(J)=2, require X(J) <= BU(J);
  !          IF J>NCOLS,        Y(J-NCOLS) <= BU(J).
  !          (the value of BL(J) is not used.)
  !    3.    For IND(J)=3, require X(J) >= BL(J) and
  !                                X(J) <= BU(J);
  !          IF J>NCOLS,        Y(J-NCOLS) >= BL(J) and
  !                                Y(J-NCOLS) <= BU(J).
  !          (to impose equality constraints have BL(J)=BU(J)=
  !          constraining value.)
  !    4.    For IND(J)=4, no bounds on X(J) or Y(J-NCOLS) are required.
  !          (the values of BL(J) and BU(J) are not used.)
  !
  !     Values other than 1,2,3 or 4 for IND(J) are errors. In the case
  !     IND(J)=3 (upper and lower bounds) the condition BL(J) > BU(J)
  !     is  an  error.   The values BL(J), BU(J), J > NCOLS, will be
  !     changed.  Significant changes mean that the constraints are
  !     infeasible.  (Users must make this decision themselves.)
  !     The new values for BL(J), BU(J), J > NCOLS, define a
  !     region such that the perturbed problem is feasible.  If users
  !     know that their problem is feasible, this step can be skipped
  !     by using option number 8 described below.
  !     See IOPT(*) description.
  !
  !
  !    -------
  !    IOPT(*)
  !    -------
  !     This is the array where the user can specify nonstandard options
  !     for DBOCLS( ). Most of the time this feature can be ignored by
  !     setting the input value IOPT(1)=99. Occasionally users may have
  !     needs that require use of the following subprogram options. For
  !     details about how to use the options see below: IOPT(*) CONTENTS.
  !
  !     Option Number   Brief Statement of Purpose
  !     ------ ------   ----- --------- -- -------
  !           1         Return to user for accumulation of blocks
  !                     of least squares equations.  The values
  !                     of IOPT(*) are changed with this option.
  !                     The changes are updates to pointers for
  !                     placing the rows of equations into position
  !                     for processing.
  !           2         Check lengths of all arrays used in the
  !                     subprogram.
  !           3         Column scaling of the data matrix, [C].
  !                                                        [E]
  !           4         User provides column scaling for matrix [C].
  !                                                             [E]
  !           5         Provide option array to the low-level
  !                     subprogram SBOLS( ).
  !           6         Provide option array to the low-level
  !                     subprogram SBOLSM( ).
  !           7         Move the IOPT(*) processing pointer.
  !           8         Do not preprocess the constraints to
  !                     resolve infeasibilities.
  !           9         Do not pretriangularize the least squares matrix.
  !          99         No more options to change.
  !
  !    ----
  !    X(*)
  !    ----
  !     This array is used to pass data associated with options 4,5 and
  !     6. Ignore this , PARAMETER :: on input) if no options are used.
  !     Otherwise see below: IOPT(*) CONTENTS.
  !
  !
  !    OUTPUT
  !    ------
  !
  !    -----------------
  !    X(*),RNORMC,RNORM
  !    -----------------
  !     The array X(*) contains a solution (if MODE >=0 or =-22) for
  !     the constrained least squares problem. The value RNORMC is the
  !     minimum residual vector length for the constraints C*X - Y = 0.
  !     The value RNORM is the minimum residual vector length for the
  !     least squares equations. Normally RNORMC=0, but in the case of
  !     inconsistent constraints this value will be nonzero.
  !     The values of X are returned in the first NVARS entries of X(*).
  !     The values of Y are returned in the last MCON entries of X(*).
  !
  !    ----
  !    MODE
  !    ----
  !     The sign of MODE determines whether the subprogram has completed
  !     normally, or encountered an error condition or abnormal status. A
  !     value of MODE >= 0 signifies that the subprogram has completed
  !     normally. The value of mode (>= 0) is the number of variables
  !     in an active status: not at a bound nor at the value zero, for
  !     the case of free variables. A negative value of MODE will be one
  !     of the cases (-57)-(-41), (-37)-(-22), (-19)-(-2). Values < -1
  !     correspond to an abnormal completion of the subprogram. These
  !     error messages are in groups for the subprograms DBOCLS(),
  !     SBOLSM(), and SBOLS().  An approximate solution will be returned
  !     to the user only when max. iterations is reached, MODE=-22.
  !
  !    -----------
  !    RW(*),IW(*)
  !    -----------
  !     These are working arrays.  (normally the user can ignore the
  !     contents of these arrays.)
  !
  !    IOPT(*) CONTENTS
  !    ------- --------
  !     The option array allows a user to modify some internal variables
  !     in the subprogram without recompiling the source code. A central
  !     goal of the initial software design was to do a good job for most
  !     people. Thus the use of options will be restricted to a select
  !     group of users. The processing of the option array proceeds as
  !     follows: a pointer, here called LP, is initially set to the value
  !     1. At the pointer position the option number is extracted and
  !     used for locating other information that allows for options to be
  !     changed. The portion of the array IOPT(*) that is used for each
  !     option is fixed; the user and the subprogram both know how many
  !     locations are needed for each option. The value of LP is updated
  !     for each option based on the amount of storage in IOPT(*) that is
  !     required. A great deal of error checking is done by the
  !     subprogram on the contents of the option array. Nevertheless it
  !     is still possible to give the subprogram optional input that is
  !     meaningless. For example option 4 uses the locations
  !     X(NCOLS+IOFF),...,X(NCOLS+IOFF+NCOLS-1) for passing scaling data.
  !     The user must manage the allocation of these locations.
  !
  !   1
  !   -
  !     This option allows the user to solve problems with a large number
  !     of rows compared to the number of variables. The idea is that the
  !     subprogram returns to the user (perhaps many times) and receives
  !     new least squares equations from the calling program unit.
  !     Eventually the user signals "that's all" and a solution is then
  !     computed. The value of MROWS is an output variable when this
  !     option is used. Its value is always in the range 0 <= MROWS
  !     <= NCOLS+1. It is the number of rows after the
  !     triangularization of the entire set of equations. If LP is the
  !     processing pointer for IOPT(*), the usage for the sequential
  !     processing of blocks of equations is
  !
  !
  !        IOPT(LP)=1
  !         Move block of equations to W(*,*) starting at
  !         the first row of W(*,*).
  !        IOPT(LP+3)=# of rows in the block; user defined
  !
  !     The user now calls DBOCLS( ) in a loop. The value of IOPT(LP+1)
  !     directs the user's action. The value of IOPT(LP+2) points to
  !     where the subsequent rows are to be placed in W(*,*). Both of
  !     these values are first defined in the subprogram. The user
  !     changes the value of IOPT(LP+1) (to 2) as a signal that all of
  !     the rows have been processed.
  !
  !
  !      .<LOOP
  !      . CALL DBOCLS( )
  !      . IF(IOPT(LP+1) = 1) THEN
  !      .    IOPT(LP+3)=# OF ROWS IN THE NEW BLOCK; USER DEFINED
  !      .    PLACE NEW BLOCK OF IOPT(LP+3) ROWS IN
  !      .    W(*,*) STARTING AT ROW MCON + IOPT(LP+2).
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
  !   2
  !   -
  !     This option is useful for checking the lengths of all arrays used
  !     by DBOCLS( ) against their actual requirements for this problem.
  !     The idea is simple: the user's program unit passes the declared
  !     dimension information of the arrays. These values are compared
  !     against the problem-dependent needs within the subprogram. If any
  !     of the dimensions are too small an error message is printed and a
  !     negative value of MODE is returned, -41 to -47. The printed error
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
  !        CALL DBOCLS( )
  !
  !     Use of this option adds 8 to the required length of IOPT(*).
  !
  !   3
  !   -
  !     This option can change the type of scaling for the data matrix.
  !     Nominally each nonzero column of the matrix is scaled so that the
  !     magnitude of its largest entry is equal to the value ONE. If LP
  !     is the processing pointer for IOPT(*),
  !
  !        IOPT(LP)=3
  !        IOPT(LP+1)=1,2 or 3
  !            1= Nominal scaling as noted;
  !            2= Each nonzero column scaled to have length ONE;
  !            3= Identity scaling; scaling effectively suppressed.
  !         .
  !        CALL DBOCLS( )
  !
  !     Use of this option adds 2 to the required length of IOPT(*).
  !
  !   4
  !   -
  !     This options allows the user to provide arbitrary (positive)
  !     column scaling for the matrix. If LP is the processing pointer
  !     for IOPT(*),
  !
  !        IOPT(LP)=4
  !        IOPT(LP+1)=IOFF
  !        X(NCOLS+IOFF),...,X(NCOLS+IOFF+NCOLS-1)
  !        = Positive scale factors for cols. of E.
  !         .
  !        CALL DBOCLS( )
  !
  !     Use of this option adds 2 to the required length of IOPT(*)
  !     and NCOLS to the required length of X(*).
  !
  !   5
  !   -
  !     This option allows the user to provide an option array to the
  !     low-level subprogram SBOLS( ). If LP is the processing pointer
  !     for IOPT(*),
  !
  !        IOPT(LP)=5
  !        IOPT(LP+1)= Position in IOPT(*) where option array
  !                    data for SBOLS( ) begins.
  !         .
  !        CALL DBOCLS( )
  !
  !     Use of this option adds 2 to the required length of IOPT(*).
  !
  !   6
  !   -
  !     This option allows the user to provide an option array to the
  !     low-level subprogram SBOLSM( ). If LP is the processing pointer
  !     for IOPT(*),
  !
  !        IOPT(LP)=6
  !        IOPT(LP+1)= Position in IOPT(*) where option array
  !                    data for SBOLSM( ) begins.
  !         .
  !        CALL DBOCLS( )
  !
  !     Use of this option adds 2 to the required length of IOPT(*).
  !
  !   7
  !   -
  !     Move the processing pointer (either forward or backward) to the
  !     location IOPT(LP+1). The processing pointer moves to locations
  !     LP+2 if option number 7 is used with the value -7.  For
  !     example to skip over locations 3,...,NCOLS+2,
  !
  !       IOPT(1)=7
  !       IOPT(2)=NCOLS+3
  !       (IOPT(I), I=3,...,NCOLS+2 are not defined here.)
  !       IOPT(NCOLS+3)=99
  !       CALL DBOCLS( )
  !
  !     CAUTION: Misuse of this option can yield some very hard-to-find
  !     bugs. Use it with care. It is intended to be used for passing
  !     option arrays to other subprograms.
  !
  !   8
  !   -
  !     This option allows the user to suppress the algorithmic feature
  !     of DBOCLS( ) that processes the constraint equations C*X = Y and
  !     resolves infeasibilities. The steps normally done are to solve
  !     C*X - Y = 0 in a least squares sense using the stated bounds on
  !     both X and Y. Then the "reachable" vector Y = C*X is computed
  !     using the solution X obtained. Finally the stated bounds for Y are
  !     enlarged to include C*X. To suppress the feature:
  !
  !
  !       IOPT(LP)=8
  !         .
  !       CALL DBOCLS( )
  !
  !     Use of this option adds 1 to the required length of IOPT(*).
  !
  !   9
  !   -
  !     This option allows the user to suppress the pretriangularizing
  !     step of the least squares matrix that is done within DBOCLS( ).
  !     This is primarily a means of enhancing the subprogram efficiency
  !     and has little effect on accuracy. To suppress the step, set:
  !
  !       IOPT(LP)=9
  !         .
  !       CALL DBOCLS( )
  !
  !     Use of this option adds 1 to the required length of IOPT(*).
  !
  !   99
  !   --
  !     There are no more options to change.
  !
  !     Only option numbers -99, -9,-8,...,-1, 1,2,...,9, and 99 are
  !     permitted. Other values are errors. Options -99,-1,...,-9 mean
  !     that the respective options 99,1,...,9 are left at their default
  !     values. An example is the option to suppress the preprocessing of
  !     constraints:
  !
  !       IOPT(1)=-8 Option is recognized but not changed
  !       IOPT(2)=99
  !       CALL DBOCLS( )
  !
  !    Error Messages for DBOCLS()
  !    ----- -------- --- --------
  !
  ! WARNING in...
  ! DBOCLS(). THE ROW DIMENSION OF W(,)=(I1) MUST BE >= THE NUMBER
  ! OF EFFECTIVE ROWS=(I2).
  !           IN ABOVE MESSAGE, I1=         1
  !           IN ABOVE MESSAGE, I2=         2
  ! ERROR NUMBER =        41
  !
  ! WARNING IN...
  ! DBOCLS(). THE COLUMN DIMENSION OF W(,)=(I1) MUST BE >= NCOLS+
  ! MCON+1=(I2).
  !           IN ABOVE MESSAGE, I1=         2
  !           IN ABOVE MESSAGE, I2=         3
  ! ERROR NUMBER =        42
  !
  ! WARNING IN...
  ! DBOCLS(). THE DIMENSIONS OF THE ARRAYS BL(),BU(), AND IND()=(I1)
  ! MUST BE >= NCOLS+MCON=(I2).
  !           IN ABOVE MESSAGE, I1=         1
  !           IN ABOVE MESSAGE, I2=         2
  ! ERROR NUMBER =        43
  !
  ! WARNING IN...
  ! DBOCLS(). THE DIMENSION OF X()=(I1) MUST BE
  ! >= THE REQD.LENGTH=(I2).
  !           IN ABOVE MESSAGE, I1=         1
  !           IN ABOVE MESSAGE, I2=         2
  ! ERROR NUMBER =        44
  !
  ! WARNING IN...
  ! DBOCLS(). THE .
  ! DBOCLS() THE DIMENSION OF IW()=(I1) MUST BE >= 2*NCOLS+2*MCON=(I2).
  !           IN ABOVE MESSAGE, I1=         1
  !           IN ABOVE MESSAGE, I2=         4
  ! ERROR NUMBER =        46
  !
  ! WARNING IN...
  ! DBOCLS(). THE DIMENSION OF IOPT()=(I1) MUST BE >= THE REQD.
  ! LEN.=(I2).
  !           IN ABOVE MESSAGE, I1=        16
  !           IN ABOVE MESSAGE, I2=        18
  ! ERROR NUMBER =        47
  !
  ! WARNING IN...
  ! DBOCLS(). ISCALE OPTION=(I1) MUST BE 1-3.
  !           IN ABOVE MESSAGE, I1=         0
  ! ERROR NUMBER =        48
  !
  ! WARNING IN...
  ! DBOCLS(). OFFSET PAST X(NCOLS) (I1) FOR USER-PROVIDED COLUMN SCALING
  ! MUST BE POSITIVE.
  !           IN ABOVE MESSAGE, I1=         0
  ! ERROR NUMBER =        49
  !
  ! WARNING IN...
  ! DBOCLS(). EACH PROVIDED COL. SCALE FACTOR MUST BE POSITIVE.
  !  COMPONENT (I1) NOW = (R1).
  !           IN ABOVE MESSAGE, I1=         1
  !           IN ABOVE MESSAGE, R1=    0.
  ! ERROR NUMBER =        50
  !
  ! WARNING IN...
  ! DBOCLS(). THE OPTION NUMBER=(I1) IS NOT DEFINED.
  !           IN ABOVE MESSAGE, I1=      1001
  ! ERROR NUMBER =        51
  !
  ! WARNING IN...
  ! DBOCLS(). NO. OF ROWS=(I1) MUST BE >= 0 .AND. <= MDW-MCON=(I2).
  !           IN ABOVE MESSAGE, I1=         2
  !           IN ABOVE MESSAGE, I2=         1
  ! ERROR NUMBER =        52
  !
  ! WARNING IN...
  ! DBOCLS(). MDW=(I1) MUST BE POSITIVE.
  !           IN ABOVE MESSAGE, I1=         0
  ! ERROR NUMBER =        53
  !
  ! WARNING IN...
  ! DBOCLS(). MCON=(I1) MUST BE NONNEGATIVE.
  !           IN ABOVE MESSAGE, I1=        -1
  ! ERROR NUMBER =        54
  !
  ! WARNING IN...
  ! DBOCLS(). NCOLS=(I1) THE NO. OF VARIABLES MUST BE POSITIVE.
  !           IN ABOVE MESSAGE, I1=         0
  ! ERROR NUMBER =        55
  !
  ! WARNING IN...
  ! DBOCLS(). FOR J=(I1), IND(J)=(I2) MUST BE 1-4.
  !           IN ABOVE MESSAGE, I1=         1
  !           IN ABOVE MESSAGE, I2=         0
  ! ERROR NUMBER =        56
  !
  ! WARNING IN...
  ! DBOCLS(). FOR J=(I1), BOUND BL(J)=(R1) IS > BU(J)=(R2).
  !           IN ABOVE MESSAGE, I1=         1
  !           IN ABOVE MESSAGE, R1=     .1000000000E+01
  !           IN ABOVE MESSAGE, R2=    0.
  ! ERROR NUMBER =        57
  !           LINEAR CONSTRAINTS, SNLA REPT. SAND82-1517, AUG., (1982).
  !
  !***
  ! **References:**  R. J. Hanson, Linear least squares with bounds and
  !                 linear constraints, Report SAND82-1517, Sandia
  !                 Laboratories, August 1982.
  !***
  ! **Routines called:**  D1MACH, DASUM, DBOLS, DCOPY, DDOT, DNRM2, DSCAL,
  !                    XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   821220  DATE WRITTEN
  !   891006  Cosmetic changes to prologue.  (WRB)
  !   891006  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900510  Convert XERRWV calls to XERMSG calls.  (RWC)
  !   910819  Added variable M for MOUT+MCON in reference to DBOLS.  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  !     REVISED 850604-0900
  !     REVISED YYMMDD-HHMM
  !
  !    PURPOSE
  !    -------
  !     THIS IS THE MAIN SUBPROGRAM THAT SOLVES THE LEAST SQUARES
  !     PROBLEM CONSISTING OF LINEAR CONSTRAINTS
  !
  !              C*X = Y
  !
  !     AND LEAST SQUARES EQUATIONS
  !
  !              E*X = F
  !
  !     IN THIS FORMULATION THE VECTORS X AND Y ARE BOTH UNKNOWNS.
  !     FURTHER, X AND Y MAY BOTH HAVE USER-SPECIFIED BOUNDS ON EACH
  !     COMPONENT.  THE USER MUST HAVE DIMENSION STATEMENTS OF THE
  !     FORM
  !
  !     DIMENSION W(MDW,NCOLS+MCON+1), BL(NCOLS+MCON),BU(NCOLS+MCON),
  !               X(2*(NCOLS+MCON)+2+NX), RW(6*NCOLS+5*MCON)
  !
  !     INTEGER IND(NCOLS+MCON), IOPT(16+NI), IW(2*(NCOLS+MCON))
  !
  !     TO CHANGE THIS SUBPROGRAM FROM SINGLE TO DOUBLE PRECISION BEGIN
  !     EDITING AT THE CARD 'C++'.
  !     CHANGE THIS SUBPROGRAM TO DBOCLS AND THE STRINGS
  !     /SDOT/ TO /DDOT/, /SNRM2/ TO /DNRM2/, /SRELPR/ TO /DRELPR/,
  !     /R1MACH/ TO /D1MACH/, /E0/ TO /D0/, /SCOPY/ TO /DCOPY/,
  !     /SSCAL/ TO /DSCAL/, /SASUM/ TO /DASUM/, /SBOLS/ TO /DBOLS/,
  !     /REAL            / TO /DOUBLE PRECISION/.
  ! ++
  USE service, ONLY : eps_dp
  !
  INTEGER, INTENT(IN) :: Mdw, Ncols
  INTEGER, INTENT(INOUT) :: Mcon, Mrows
  INTEGER, INTENT(OUT) :: Mode
  REAL(DP), INTENT(OUT) :: Rnorm, Rnormc
  INTEGER, INTENT(IN) :: Ind(Ncols+Mcon)
  INTEGER, INTENT(INOUT) :: Iopt(*)
  INTEGER, INTENT(OUT) :: Iw(2*(Ncols+Mcon))
  REAL(DP), INTENT(INOUT) :: Bl(Ncols+Mcon), Bu(Ncols+Mcon), W(Mdw,Ncols+Mcon+1), &
    X(2*(Ncols+Mcon)+7)
  REAL(DP), INTENT(OUT) :: Rw(6*Ncols+5*Mcon)
  INTEGER :: i, icase, iiw, inrows, ip, irw, iscale, j, jp, lbou, lboum, lds, lenx, &
    liopt, liw, llb, lliw, llrw, llx, lmdw, lndw, locacc, locdim, lopt, lp, lrw, &
    m, mdwl, mnew, modec, mopt, mout, nerr
  REAL(DP) :: anorm, cnorm, drelpr, t, t1, t2, wt
  LOGICAL :: filter, pretri
  CHARACTER(8) :: xern1, xern2
  INTEGER :: jopt(05)
  CHARACTER(16) :: xern3, xern4
  LOGICAL, SAVE :: accum, checkl
  INTEGER, SAVE :: igo = 0
  !* FIRST EXECUTABLE STATEMENT  DBOCLS
  nerr = 0
  Mode = 0
  IF( igo==0 ) THEN
    !     DO(CHECK VALIDITY OF INPUT DATA)
    !     PROCEDURE(CHECK VALIDITY OF INPUT DATA)
    !
    !     SEE THAT MDW IS >0. GROSS CHECK ONLY.
    IF( Mdw<=0 ) THEN
      WRITE (xern1,'(I8)') Mdw
      ERROR STOP 'DBOCLS : MDW MUST BE POSITIVE.'
      !     DO(RETURN TO USER PROGRAM UNIT)
      GOTO 100
    END IF
    !
    !     SEE THAT NUMBER OF CONSTRAINTS IS NONNEGATIVE.
    IF( Mcon<0 ) THEN
      WRITE (xern1,'(I8)') Mcon
      ERROR STOP 'DBOCLS : MCON MUST BE NON-NEGATIVE'
      !     DO(RETURN TO USER PROGRAM UNIT)
      GOTO 100
    END IF
    !
    !     SEE THAT NUMBER OF UNKNOWNS IS POSITIVE.
    IF( Ncols<=0 ) THEN
      WRITE (xern1,'(I8)') Ncols
      ERROR STOP 'DBOCLS : NCOLS THE NO. OF VARIABLES, MUST BE POSITIVE.'
      !     DO(RETURN TO USER PROGRAM UNIT)
      GOTO 100
    END IF
    !
    !     SEE THAT CONSTRAINT INDICATORS ARE ALL WELL-DEFINED.
    DO j = 1, Ncols + Mcon
      IF( Ind(j)<1 .OR. Ind(j)>4 ) THEN
        WRITE (xern1,'(I8)') j
        WRITE (xern2,'(I8)') Ind(j)
        ERROR STOP 'DBOCLS : IND(J) MUST BE 1-4.'
        !     DO(RETURN TO USER PROGRAM UNIT)
        GOTO 100
      END IF
    END DO
    !
    !     SEE THAT BOUNDS ARE CONSISTENT.
    DO j = 1, Ncols + Mcon
      IF( Ind(j)==3 ) THEN
        IF( Bl(j)>Bu(j) ) THEN
          WRITE (xern1,'(I8)') j
          WRITE (xern3,'(1PE15.6)') Bl(j)
          WRITE (xern4,'(1PE15.6)') Bu(j)
          ERROR STOP 'DBOCLS : BOUND BL(J) IS > BU(J)'
          !     DO(RETURN TO USER PROGRAM UNIT)
          GOTO 100
        END IF
      END IF
    END DO
    !     END PROCEDURE
    !     DO(PROCESS OPTION ARRAY)
    !     PROCEDURE(PROCESS OPTION ARRAY)
    drelpr = eps_dp
    checkl = .FALSE.
    filter = .TRUE.
    lenx = 2*(Ncols+Mcon) + 2
    iscale = 1
    igo = 1
    accum = .FALSE.
    pretri = .TRUE.
    lopt = 0
    mopt = 0
    lp = 0
    lds = 0
    DO
      !     DO FOREVER
      lp = lp + lds
      ip = Iopt(lp+1)
      jp = ABS(ip)
      !
      !     TEST FOR NO MORE OPTIONS TO CHANGE.
      IF( ip==99 ) THEN
        IF( lopt==0 ) lopt = -(lp+2)
        IF( mopt==0 ) mopt = -(ABS(lopt)+7)
        IF( lopt<0 ) THEN
          lbou = ABS(lopt)
        ELSE
          lbou = lopt - 15
        END IF
        !
        !     SEND COL. SCALING TO DBOLS().
        Iopt(lbou) = 4
        Iopt(lbou+1) = 1
        !
        !     PASS AN OPTION ARRAY FOR DBOLSM().
        Iopt(lbou+2) = 5
        !
        !     LOC. OF OPTION ARRAY FOR DBOLSM( ).
        Iopt(lbou+3) = 8
        !
        !     SKIP TO START OF USER-GIVEN OPTION ARRAY FOR DBOLS().
        Iopt(lbou+4) = 6
        Iopt(lbou+6) = 99
        IF( lopt>0 ) THEN
          Iopt(lbou+5) = lopt - lbou + 1
        ELSE
          Iopt(lbou+4) = -Iopt(lbou+4)
        END IF
        IF( mopt<0 ) THEN
          lboum = ABS(mopt)
        ELSE
          lboum = mopt - 8
        END IF
        !
        !     CHANGE PRETRIANGULARIZATION FACTOR IN DBOLSM().
        Iopt(lboum) = 5
        Iopt(lboum+1) = Ncols + Mcon + 1
        !
        !     PASS WEIGHT TO DBOLSM() FOR RANK TEST.
        Iopt(lboum+2) = 6
        Iopt(lboum+3) = Ncols + Mcon + 2
        Iopt(lboum+4) = Mcon
        !
        !     SKIP TO USER-GIVEN OPTION ARRAY FOR DBOLSM( ).
        Iopt(lboum+5) = 1
        Iopt(lboum+7) = 99
        IF( mopt>0 ) THEN
          Iopt(lboum+6) = mopt - lboum + 1
        ELSE
          Iopt(lboum+5) = -Iopt(lboum+5)
        END IF
        !     EXIT FOREVER
        EXIT
      ELSEIF( jp==99 ) THEN
        lds = 1
        !     CYCLE FOREVER
        EXIT
      ELSEIF( jp==1 ) THEN
        IF( ip>0 ) THEN
          !
          !     SET UP DIRECTION FLAG LOCATION, ROW STACKING POINTER
          !     LOCATION, AND LOCATION FOR NUMBER OF NEW ROWS.
          locacc = lp + 2
          !
          !                  IOPT(LOCACC-1)=OPTION NUMBER FOR SEQ. ACCUMULATION.
          !     CONTENTS..   IOPT(LOCACC  )=USER DIRECTION FLAG, 1 OR 2.
          !                  IOPT(LOCACC+1)=ROW STACKING POINTER.
          !                  IOPT(LOCACC+2)=NUMBER OF NEW ROWS TO PROCESS.
          !     USER ACTION WITH THIS OPTION..
          !      (SET UP OPTION DATA FOR SEQ. ACCUMULATION IN IOPT(*).)
          !      (MOVE BLOCK OF EQUATIONS INTO W(*,*)  STARTING AT FIRST
          !       ROW OF W(*,*) BELOW THE ROWS FOR THE CONSTRAINT MATRIX C.
          !       SET IOPT(LOCACC+2)=NO. OF LEAST SQUARES EQUATIONS IN BLOCK.
          !              LOOP
          !              CALL DBOCLS()
          !
          !                  IF(IOPT(LOCACC) = 1) THEN
          !                      STACK EQUAS. INTO W(*,*), STARTING AT
          !                      ROW IOPT(LOCACC+1).
          !                       INTO W(*,*).
          !                       SET IOPT(LOCACC+2)=NO. OF EQUAS.
          !                      IF LAST BLOCK OF EQUAS., SET IOPT(LOCACC)=2.
          !                  ELSE IF IOPT(LOCACC) = 2) THEN
          !                      (PROCESS IS OVER. EXIT LOOP.)
          !                  ELSE
          !                      (ERROR CONDITION. SHOULD NOT HAPPEN.)
          !                  END IF
          !              END LOOP
          Iopt(locacc+1) = Mcon + 1
          accum = .TRUE.
          Iopt(locacc) = igo
        END IF
        !     CYCLE FOREVER
        lds = 4
      ELSEIF( jp==2 ) THEN
        IF( ip>0 ) THEN
          !
          !     GET ACTUAL LENGTHS OF ARRAYS FOR CHECKING AGAINST NEEDS.
          locdim = lp + 2
          !
          !     LMDW>=MCON+MAX(MOUT,NCOLS), IF MCON>0 .AND FILTER
          !     LMDW>=MCON+MOUT, OTHERWISE
          !
          !     LNDW>=NCOLS+MCON+1
          !     LLB >=NCOLS+MCON
          !     LLX >=2*(NCOLS+MCON)+2+EXTRA REQD. IN OPTIONS.
          !     LLRW>=6*NCOLS+5*MCON
          !     LLIW>=2*(NCOLS+MCON)
          !     LIOP>= AMOUNT REQD. FOR OPTION ARRAY.
          lmdw = Iopt(locdim)
          lndw = Iopt(locdim+1)
          llb = Iopt(locdim+2)
          llx = Iopt(locdim+3)
          llrw = Iopt(locdim+4)
          lliw = Iopt(locdim+5)
          liopt = Iopt(locdim+6)
          checkl = .TRUE.
        END IF
        !     CYCLE FOREVER
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
            ERROR STOP 'DBOCLS : ISCALE OPTION MUST BE 1-3'
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
            ERROR STOP 'DBOCLS : OFFSET PAST X(NCOLS) FOR USER-PROVIDED COLUMN &
              &SCALING MUST BE POSITIVE.'
            !     DO(RETURN TO USER PROGRAM UNIT)
            GOTO 100
          END IF
          Rw(1:Ncols) = X(Ncols+Iopt(lp+2):2*Ncols+Iopt(lp+2)-1)
          lenx = lenx + Ncols
          DO j = 1, Ncols
            IF( Rw(j)<=0._DP ) THEN
              WRITE (xern1,'(I8)') j
              WRITE (xern3,'(1PE15.6)') Rw(j)
              ERROR STOP 'DBOCLS : EACH PROVIDED COLUMN SCALE FACTOR MUST BE POSITIVE.'
              !     DO(RETURN TO USER PROGRAM UNIT)
              GOTO 100
            END IF
          END DO
        END IF
        !     CYCLE FOREVER
        lds = 2
        !
        !     IN THIS OPTION AN OPTION ARRAY IS PROVIDED TO DBOLS().
      ELSEIF( jp==5 ) THEN
        IF( ip>0 ) lopt = Iopt(lp+2)
        !     CYCLE FOREVER
        lds = 2
        !
        !     IN THIS OPTION AN OPTION ARRAY IS PROVIDED TO DBOLSM().
      ELSEIF( jp==6 ) THEN
        IF( ip>0 ) mopt = Iopt(lp+2)
        !     CYCLE FOREVER
        lds = 2
        !
        !     THIS OPTION USES THE NEXT LOC OF IOPT(*) AS A
        !     POINTER VALUE TO SKIP TO NEXT.
      ELSEIF( jp==7 ) THEN
        IF( ip>0 ) THEN
          lp = Iopt(lp+2) - 1
          lds = 0
        ELSE
          lds = 2
          !     CYCLE FOREVER
        END IF
        !
        !     THIS OPTION AVOIDS THE CONSTRAINT RESOLVING PHASE FOR
        !     THE LINEAR CONSTRAINTS C*X=Y.
      ELSEIF( jp==8 ) THEN
        filter = .NOT. (ip>0)
        !     CYCLE FOREVER
        lds = 1
        !
        !     THIS OPTION SUPPRESSES PRE-TRIANGULARIZATION OF THE LEAST
        !     SQUARES EQUATIONS.
      ELSEIF( jp==9 ) THEN
        pretri = .NOT. (ip>0)
        !     CYCLE FOREVER
        lds = 1
        !
        !     NO VALID OPTION NUMBER WAS NOTED. THIS IS AN ERROR CONDITION.
      ELSE
        WRITE (xern1,'(I8)') jp
        ERROR STOP 'DBOCLS : OPTION NUMBER IS NOT DEFINED.'
        !     DO(RETURN TO USER PROGRAM UNIT)
        GOTO 100
      END IF
    END DO
    !     END FOREVER
    !     END PROCEDURE
    IF( checkl ) THEN
      !     DO(CHECK LENGTHS OF ARRAYS)
      !     PROCEDURE(CHECK LENGTHS OF ARRAYS)
      !
      !     THIS FEATURE ALLOWS THE USER TO MAKE SURE THAT THE
      !     ARRAYS ARE LONG ENOUGH FOR THE INTENDED PROBLEM SIZE AND USE.
      IF( filter .AND. .NOT. accum ) THEN
        mdwl = Mcon + MAX(Mrows,Ncols)
      ELSE
        mdwl = Mcon + Ncols + 1
      END IF
      IF( lmdw<mdwl ) THEN
        WRITE (xern1,'(I8)') lmdw
        WRITE (xern2,'(I8)') mdwl
        ERROR STOP 'DBOCLS : THE ROW DIMENSION OF W(,) MUST BE >= THE NUMBER OF &
          &EFFECTIVE ROWS'
        !     DO(RETURN TO USER PROGRAM UNIT)
        GOTO 100
      END IF
      IF( lndw<Ncols+Mcon+1 ) THEN
        WRITE (xern1,'(I8)') lndw
        WRITE (xern2,'(I8)') Ncols + Mcon + 1
        ERROR STOP 'DBOCLS : THE COLUMN DIMENSION OF W(,)  MUST BE >= NCOLS+MCON+1'
        !     DO(RETURN TO USER PROGRAM UNIT)
        GOTO 100
      END IF
      IF( llb<Ncols+Mcon ) THEN
        WRITE (xern1,'(I8)') llb
        WRITE (xern2,'(I8)') Ncols + Mcon
        ERROR STOP 'DBOCLS : THE DIMENSIONS OF THE ARRAYS BS(), BU(), AND IND() &
          &MUST BE >= NCOLS+MCON'
        !     DO(RETURN TO USER PROGRAM UNIT)
        GOTO 100
      END IF
      IF( llx<lenx ) THEN
        WRITE (xern1,'(I8)') llx
        WRITE (xern2,'(I8)') lenx
        ERROR STOP 'DBOCLS : THE DIMENSION OF X() MUST BE >= THE REQUIRED LENGTH'
        !     DO(RETURN TO USER PROGRAM UNIT)
        GOTO 100
      END IF
      IF( llrw<6*Ncols+5*Mcon ) THEN
        WRITE (xern1,'(I8)') llrw
        WRITE (xern2,'(I8)') 6*Ncols + 5*Mcon
        ERROR STOP 'DBOCLS : THE DIMENSION OF RW() MUST BE >= 6*NCOLS+5*MCON'
        !     DO(RETURN TO USER PROGRAM UNIT)
        GOTO 100
      END IF
      IF( lliw<2*Ncols+2*Mcon ) THEN
        WRITE (xern1,'(I8)') lliw
        WRITE (xern2,'(I8)') 2*Ncols + 2*Mcon
        ERROR STOP 'DBOCLS : THE DIMENSION OF IW() MUST BE >= 2*NCOLS+2*MCON'
        !     DO(RETURN TO USER PROGRAM UNIT)
        GOTO 100
      END IF
      IF( liopt<lp+17 ) THEN
        WRITE (xern1,'(I8)') liopt
        WRITE (xern2,'(I8)') lp + 17
        ERROR STOP 'DBOCLS : THE DIMENSION OF IOPT() MUST BE >= THE REQUIRED LEN'
        !     DO(RETURN TO USER PROGRAM UNIT)
        GOTO 100
      END IF
      !     END PROCEDURE
    END IF
  END IF
  !
  !     OPTIONALLY GO BACK TO THE USER FOR ACCUMULATION OF LEAST SQUARES
  !     EQUATIONS AND DIRECTIONS FOR PROCESSING THESE EQUATIONS.
  !     DO(ACCUMULATE LEAST SQUARES EQUATIONS)
  !     PROCEDURE(ACCUMULATE LEAST SQUARES EQUATIONS)
  IF( accum ) THEN
    Mrows = Iopt(locacc+1) - 1 - Mcon
    inrows = Iopt(locacc+2)
    mnew = Mrows + inrows
    IF( mnew<0 .OR. mnew+Mcon>Mdw ) THEN
      WRITE (xern1,'(I8)') mnew
      WRITE (xern2,'(I8)') Mdw - Mcon
      ERROR STOP 'DBOCLS : NO. OF ROWS MUST BE >= 0 .AND. <= MDW-MCON'
      !    (RETURN TO USER PROGRAM UNIT)
      GOTO 100
    END IF
  END IF
  !
  !     USE THE SOFTWARE OF DBOLS( ) FOR THE TRIANGULARIZATION OF THE
  !     LEAST SQUARES MATRIX.  THIS MAY INVOLVE A SYSTALTIC INTERCHANGE
  !     OF PROCESSING POINTERS BETWEEN THE CALLING AND CALLED (DBOLS())
  !     PROGRAM UNITS.
  jopt(01) = 1
  jopt(02) = 2
  jopt(04) = Mrows
  jopt(05) = 99
  irw = Ncols + 1
  iiw = 1
  IF( accum .OR. pretri ) THEN
    CALL DBOLS(W(Mcon+1,1),Mdw,mout,Ncols,Bl,Bu,Ind,jopt,X,Rnorm,Mode,Rw(irw),Iw(iiw))
  ELSE
    mout = Mrows
  END IF
  IF( accum ) THEN
    accum = Iopt(locacc)==1
    Iopt(locacc+1) = jopt(03) + Mcon
    Mrows = MIN(Ncols+1,mnew)
  END IF
  !     END PROCEDURE
  IF( accum ) RETURN
  !     DO(SOLVE CONSTRAINED AND BOUNDED LEAST SQUARES PROBLEM)
  !     PROCEDURE(SOLVE CONSTRAINED AND BOUNDED LEAST SQUARES PROBLEM)
  !
  !     MOVE RIGHT HAND SIDE OF LEAST SQUARES EQUATIONS.
  W(Mcon+1:Mcon+mout,Ncols+Mcon+1) = W(Mcon+1:Mcon+mout,Ncols+1)
  IF( Mcon>0 .AND. filter ) THEN
    !
    !     PROJECT THE LINEAR CONSTRAINTS INTO A REACHABLE SET.
    DO i = 1, Mcon
      W(Mcon+1:Mcon+Ncols,Ncols+i) = W(i,1:Ncols)
    END DO
    !
    !      PLACE (-)IDENTITY MATRIX AFTER CONSTRAINT DATA.
    DO j = Ncols + 1, Ncols + Mcon + 1
      W(1:Mcon,j) = 0._DP
    END DO
    DO j = 1, Mcon
      W(j,Ncols+j) = -1._DP
    END DO
    !
    !     OBTAIN A 'FEASIBLE POINT' FOR THE LINEAR CONSTRAINTS.
    jopt(01) = 99
    irw = Ncols + 1
    iiw = 1
    CALL DBOLS(W,Mdw,Mcon,Ncols+Mcon,Bl,Bu,Ind,jopt,X,Rnormc,modec,Rw(irw),Iw(iiw))
    !
    !     ENLARGE THE BOUNDS SET, IF REQUIRED, TO INCLUDE POINTS THAT
    !     CAN BE REACHED.
    DO j = Ncols + 1, Ncols + Mcon
      icase = Ind(j)
      IF( icase<4 ) t = DOT_PRODUCT(W(Mcon+1:Mcon+Ncols,j),X(1:Ncols))
      SELECT CASE (icase)
        CASE (1)
          !     CASE 1
          Bl(j) = MIN(t,Bl(j))
        CASE (2)
          !     CASE 2
          Bu(j) = MAX(t,Bu(j))
        CASE (3)
          !     CASE 3
          Bl(j) = MIN(t,Bl(j))
          Bu(j) = MAX(t,Bu(j))
        CASE DEFAULT
      END SELECT
      !     CASE 4
    END DO
    !
    !     MOVE CONSTRAINT DATA BACK TO THE ORIGINAL AREA.
    DO j = Ncols + 1, Ncols + Mcon
      W(j-Ncols,1:Ncols) = W(Mcon+1:Mcon+Ncols,j)
    END DO
  END IF
  IF( Mcon>0 ) THEN
    DO j = Ncols + 1, Ncols + Mcon
      W(Mcon+1:Mcon+mout,j) = 0._DP
    END DO
    !
    !     PUT IN (-)IDENTITY MATRIX (POSSIBLY) ONCE AGAIN.
    DO j = Ncols + 1, Ncols + Mcon + 1
      W(1:Mcon,j) = 0._DP
    END DO
    DO j = 1, Mcon
      W(j,Ncols+j) = -1._DP
    END DO
  END IF
  !
  !     COMPUTE NOMINAL COLUMN SCALING FOR THE UNWEIGHTED MATRIX.
  cnorm = 0._DP
  anorm = 0._DP
  DO j = 1, Ncols
    t1 = SUM(ABS(W(1:Mcon,j)))
    t2 = SUM(ABS(W(Mcon+1:Mcon+mout,1)))
    t = t1 + t2
    IF( t==0._DP ) t = 1._DP
    cnorm = MAX(cnorm,t1)
    anorm = MAX(anorm,t2)
    X(Ncols+Mcon+j) = 1._DP/t
  END DO
  SELECT CASE (iscale)
    CASE (2)
      !     CASE 2
      !
      !     SCALE COLS. (BEFORE WEIGHTING) TO HAVE LENGTH ONE.
      DO j = 1, Ncols
        t = NORM2(W(1:Mcon+mout,j))
        IF( t==0._DP ) t = 1._DP
        X(Ncols+Mcon+j) = 1._DP/t
      END DO
    CASE (3)
      !     CASE 3
      !
      !     SUPPRESS SCALING (USE UNIT MATRIX).
      X(Ncols+Mcon+1:2*Ncols+Mcon) = 1._DP
    CASE (4)
      !     CASE 4
      !
      !     THE USER HAS PROVIDED SCALING.
      X(Ncols+Mcon+1:2*Ncols+Mcon) = Rw(1:Ncols)
    CASE DEFAULT
      !     CASE 1
  END SELECT
  DO j = Ncols + 1, Ncols + Mcon
    X(Ncols+Mcon+j) = 1._DP
  END DO
  !
  !     WEIGHT THE LEAST SQUARES EQUATIONS.
  wt = drelpr
  IF( anorm>0._DP ) wt = wt/anorm
  IF( cnorm>0._DP ) wt = wt*cnorm
  DO i = 1, mout
    W(i+Mcon,1:Ncols) = W(i+Mcon,1:Ncols)*wt
  END DO
  W(Mcon+1:Mcon+mout,Mcon+Ncols+1) = W(Mcon+1:Mcon+mout,Mcon+Ncols+1)*wt
  lrw = 1
  liw = 1
  !
  !     SET THE NEW TRIANGULARIZATION FACTOR.
  X(2*(Ncols+Mcon)+1) = 0._DP
  !
  !     SET THE WEIGHT TO USE IN COMPONENTS > MCON,
  !     WHEN MAKING LINEAR INDEPENDENCE TEST.
  X(2*(Ncols+Mcon)+2) = 1._DP/wt
  m = mout + Mcon
  CALL DBOLS(W,Mdw,m,Ncols+Mcon,Bl,Bu,Ind,Iopt(lbou),X,Rnorm,Mode,Rw(lrw),Iw(liw))
  Rnorm = Rnorm/wt
  !     END PROCEDURE
  !     PROCEDURE(RETURN TO USER PROGRAM UNIT)
  100 CONTINUE
  IF( Mode>=0 ) Mode = -nerr
  igo = 0
  !     END PROGRAM
END SUBROUTINE DBOCLS