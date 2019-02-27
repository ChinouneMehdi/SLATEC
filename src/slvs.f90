!DECK SLVS
SUBROUTINE SLVS(Wm,Iwm,X,Tem)
  IMPLICIT NONE
  !***BEGIN PROLOGUE  SLVS
  !***SUBSIDIARY
  !***PURPOSE  Subsidiary to DEBDF
  !***LIBRARY   SLATEC
  !***TYPE      SINGLE PRECISION (SLVS-S, DSLVS-D)
  !***AUTHOR  Watts, H. A., (SNLA)
  !***DESCRIPTION
  !
  !   SLVS solves the linear system in the iteration scheme for the
  !   integrator package DEBDF.
  !
  !***SEE ALSO  DEBDF
  !***ROUTINES CALLED  SGBSL, SGESL
  !***COMMON BLOCKS    DEBDF1
  !***REVISION HISTORY  (YYMMDD)
  !   800901  DATE WRITTEN
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  !   910722  Updated AUTHOR section.  (ALS)
  !   920422  Changed DIMENSION statement.  (WRB)
  !***END PROLOGUE  SLVS
  !
  !LLL. OPTIMIZE
  INTEGER Iwm, i, IER, IOWnd, IOWns, JSTart, KFLag, L, MAXord, &
    meband, METh, MITer, ml, mu, N, NFE, NJE, NQ, NQU, NST
  REAL Wm, X, Tem, ROWnd, ROWns, EL0, H, HMIn, HMXi, HU, TN, &
    UROund, di, hl0, phl0, r
  DIMENSION Wm(*), Iwm(*), X(*), Tem(*)
  COMMON /DEBDF1/ ROWnd, ROWns(210), EL0, H, HMIn, HMXi, HU, TN, &
    UROund, IOWnd(14), IOWns(6), IER, JSTart, KFLag, L, &
    METh, MITer, MAXord, N, NQ, NST, NFE, NJE, NQU
  !-----------------------------------------------------------------------
  ! THIS ROUTINE MANAGES THE SOLUTION OF THE LINEAR SYSTEM ARISING FROM
  ! A CHORD ITERATION.  IT IS CALLED BY STOD  IF MITER .NE. 0.
  ! IF MITER IS 1 OR 2, IT CALLS SGESL TO ACCOMPLISH THIS.
  ! IF MITER = 3 IT UPDATES THE COEFFICIENT H*EL0 IN THE DIAGONAL
  ! MATRIX, AND THEN COMPUTES THE SOLUTION.
  ! IF MITER IS 4 OR 5, IT CALLS SGBSL.
  ! COMMUNICATION WITH SLVS USES THE FOLLOWING VARIABLES..
  ! WM  = REAL WORK SPACE CONTAINING THE INVERSE DIAGONAL MATRIX IF MITER
  !       IS 3 AND THE LU DECOMPOSITION OF THE MATRIX OTHERWISE.
  !       STORAGE OF MATRIX ELEMENTS STARTS AT WM(3).
  !       WM ALSO CONTAINS THE FOLLOWING MATRIX-RELATED DATA..
  !       WM(1) = SQRT(UROUND) (NOT USED HERE),
  !       WM(2) = HL0, THE PREVIOUS VALUE OF H*EL0, USED IF MITER = 3.
  ! IWM = INTEGER WORK SPACE CONTAINING PIVOT INFORMATION, STARTING AT
  !       IWM(21), IF MITER IS 1, 2, 4, OR 5.  IWM ALSO CONTAINS THE
  !       BAND PARAMETERS ML = IWM(1) AND MU = IWM(2) IF MITER IS 4 OR 5.
  ! X   = THE RIGHT-HAND SIDE VECTOR ON INPUT, AND THE SOLUTION VECTOR
  !       ON OUTPUT, OF LENGTH N.
  ! TEM = VECTOR OF WORK SPACE OF LENGTH N, NOT USED IN THIS VERSION.
  ! IER = OUTPUT FLAG (IN COMMON).  IER = 0 IF NO TROUBLE OCCURRED.
  !       IER = -1 IF A SINGULAR MATRIX AROSE WITH MITER = 3.
  ! THIS ROUTINE ALSO USES THE COMMON VARIABLES EL0, H, MITER, AND N.
  !-----------------------------------------------------------------------
  !***FIRST EXECUTABLE STATEMENT  SLVS
  IER = 0
  SELECT CASE (MITer)
    CASE (3)
      !
      phl0 = Wm(2)
      hl0 = H*EL0
      Wm(2) = hl0
      IF ( hl0/=phl0 ) THEN
        r = hl0/phl0
        DO i = 1, N
          di = 1.0E0 - r*(1.0E0-1.0E0/Wm(i+2))
          IF ( ABS(di)==0.0E0 ) GOTO 100
          Wm(i+2) = 1.0E0/di
        ENDDO
      ENDIF
      DO i = 1, N
        X(i) = Wm(i+2)*X(i)
      ENDDO
      RETURN
    CASE (4,5)
      !
      ml = Iwm(1)
      mu = Iwm(2)
      meband = 2*ml + mu + 1
      CALL SGBSL(Wm(3),meband,N,ml,mu,Iwm(21),X,0)
      GOTO 99999
    CASE DEFAULT
      CALL SGESL(Wm(3),N,N,Iwm(21),X,0)
      RETURN
  END SELECT
  100  IER = -1
  RETURN
  !----------------------- END OF SUBROUTINE SLVS -----------------------
  99999 CONTINUE
  END SUBROUTINE SLVS