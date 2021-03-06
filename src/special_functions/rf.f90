!** RF
REAL(SP) ELEMENTAL FUNCTION RF(X,Y,Z)
  !> Compute the incomplete or complete elliptic integral of the
  !  1st kind.  For X, Y, and Z non-negative and at most one of
  !  them zero, RF(X,Y,Z) = Integral from zero to infinity of
  !                                -1/2     -1/2     -1/2
  !                      (1/2)(t+X)    (t+Y)    (t+Z)    dt.
  !  If X, Y or Z is zero, the integral is complete.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  C14
  !***
  ! **Type:**      SINGLE PRECISION (RF-S, DRF-D)
  !***
  ! **Keywords:**  COMPLETE ELLIPTIC INTEGRAL, DUPLICATION THEOREM,
  !             INCOMPLETE ELLIPTIC INTEGRAL, INTEGRAL OF THE FIRST KIND,
  !             TAYLOR SERIES
  !***
  ! **Author:**  Carlson, B. C.
  !             Ames Laboratory-DOE
  !             Iowa State University
  !             Ames, IA  50011
  !           Notis, E. M.
  !             Ames Laboratory-DOE
  !             Iowa State University
  !             Ames, IA  50011
  !           Pexton, R. L.
  !             Lawrence Livermore National Laboratory
  !             Livermore, CA  94550
  !***
  ! **Description:**
  !
  !   1.     RF
  !          Evaluate an INCOMPLETE (or COMPLETE) ELLIPTIC INTEGRAL
  !          of the first kind
  !          Standard FORTRAN function routine
  !          Single precision version
  !          The routine calculates an approximation result to
  !          RF(X,Y,Z) = Integral from zero to infinity of
  !
  !                               -1/2     -1/2     -1/2
  !                     (1/2)(t+X)    (t+Y)    (t+Z)    dt,
  !
  !          where X, Y, and Z are nonnegative and at most one of them
  !          is zero.  If one of them is zero, the integral is COMPLETE.
  !          The duplication theorem is iterated until the variables are
  !          nearly equal, and the function is then expanded in Taylor
  !          series to fifth order.
  !
  !   2.     Calling Sequence
  !          RF( X, Y, Z, IER )
  !
  !          Parameters on Entry
  !          Values assigned by the calling routine
  !
  !          X      - Single precision, nonnegative variable
  !
  !          Y      - Single precision, nonnegative variable
  !
  !          Z      - Single precision, nonnegative variable
  !
  !
  !
  !          On Return     (values assigned by the RF routine)
  !
  !          RF     - Single precision approximation to the integral
  !
  !          IER    - Integer
  !
  !                   IER = 0 Normal and reliable termination of the
  !                           routine.  It is assumed that the requested
  !                           accuracy has been achieved.
  !
  !                   IER >  0 Abnormal termination of the routine
  !
  !          X, Y, Z are unaltered.
  !
  !
  !   3.    Error Messages
  !
  !         Value of IER assigned by the RF routine
  !
  !                  Value assigned         Error Message Printed
  !                  IER = 1                MIN(X,Y,Z) < 0.0E0
  !                      = 2                MIN(X+Y,X+Z,Y+Z) < LOLIM
  !                      = 3                MAX(X,Y,Z) > UPLIM
  !
  !
  !
  !   4.     Control Parameters
  !
  !                  Values of LOLIM, UPLIM, and ERRTOL are set by the
  !                  routine.
  !
  !          LOLIM and UPLIM determine the valid range of X, Y and Z
  !
  !          LOLIM  - Lower limit of valid arguments
  !
  !                   Not less than 5 * (machine minimum).
  !
  !          UPLIM  - Upper limit of valid arguments
  !
  !                   Not greater than (machine maximum) / 5.
  !
  !
  !                     Acceptable Values For:   LOLIM      UPLIM
  !                     IBM 360/370 SERIES   :   3.0E-78     1.0E+75
  !                     CDC 6000/7000 SERIES :   1.0E-292    1.0E+321
  !                     UNIVAC 1100 SERIES   :   1.0E-37     1.0E+37
  !                     CRAY                 :   2.3E-2466   1.09E+2465
  !                     VAX 11 SERIES        :   1.5E-38     3.0E+37
  !
  !
  !
  !          ERRTOL determines the accuracy of the answer
  !
  !                 The value assigned by the routine will result
  !                 in solution precision within 1-2 decimals of
  !                 "machine precision".
  !
  !
  !
  !          ERRTOL - Relative error due to truncation is less than
  !                   ERRTOL ** 6 / (4 * (1-ERRTOL)  .
  !
  !
  !
  !              The accuracy of the computed approximation to the inte-
  !              gral can be controlled by choosing the value of ERRTOL.
  !              Truncation of a Taylor series after terms of fifth order
  !              introduces an error less than the amount shown in the
  !              second column of the following table for each value of
  !              ERRTOL in the first column.  In addition to the trunca-
  !              tion error there will be round-off error, but in prac-
  !              tice the total error from both sources is usually less
  !              than the amount given in the table.
  !
  !
  !
  !
  !
  !          Sample Choices:  ERRTOL   Relative Truncation
  !                                    error less than
  !                           1.0E-3    3.0E-19
  !                           3.0E-3    2.0E-16
  !                           1.0E-2    3.0E-13
  !                           3.0E-2    2.0E-10
  !                           1.0E-1    3.0E-7
  !
  !
  !                    Decreasing ERRTOL by a factor of 10 yields six more
  !                    decimal digits of accuracy at the expense of one or
  !                    two more iterations of the duplication theorem.
  !
  !- Long Description:
  !
  !   RF Special Comments
  !
  !
  !
  !          Check by addition theorem: RF(X,X+Z,X+W) + RF(Y,Y+Z,Y+W)
  !          = RF(0,Z,W), where X,Y,Z,W are positive and X * Y = Z * W.
  !
  !
  !          On Input:
  !
  !          X, Y, and Z are the variables in the integral RF(X,Y,Z).
  !
  !
  !          On Output:
  !
  !
  !          X, Y, and Z are unaltered.
  !
  !
  !
  !          ********************************************************
  !
  !          Warning: Changes in the program may improve speed at the
  !                   expense of robustness.
  !
  !
  !
  !   Special Functions via RF
  !
  !
  !                  Legendre form of ELLIPTIC INTEGRAL of 1st kind
  !                  ----------------------------------------------
  !
  !
  !                                            2         2   2
  !                  F(PHI,K) = SIN(PHI) RF(COS (PHI),1-K SIN (PHI),1)
  !
  !
  !                                 2
  !                  K(K) = RF(0,1-K ,1)
  !
  !                         PI/2     2   2      -1/2
  !                       = INT  (1-K SIN (PHI) )   D PHI
  !                          0
  !
  !
  !
  !
  !
  !                  Bulirsch form of ELLIPTIC INTEGRAL of 1st kind
  !                  ----------------------------------------------
  !
  !
  !                                         2 2    2
  !                  EL1(X,KC) = X RF(1,1+KC X ,1+X )
  !
  !
  !
  !
  !                  Lemniscate constant A
  !                  ---------------------
  !
  !
  !                       1      4 -1/2
  !                  A = INT (1-S )    DS = RF(0,1,2) = RF(0,2,1)
  !                       0
  !
  !
  !    -------------------------------------------------------------------
  !
  !***
  ! **References:**  B. C. Carlson and E. M. Notis, Algorithms for incomplete
  !                 elliptic integrals, ACM Transactions on Mathematical
  !                 Software 7, 3 (September 1981), pp. 398-403.
  !               B. C. Carlson, Computing elliptic integrals by
  !                 duplication, Numerische Mathematik 33, (1979),
  !                 pp. 1-16.
  !               B. C. Carlson, Elliptic integrals of the first kind,
  !                 SIAM Journal of Mathematical Analysis 8, (1977),
  !                 pp. 231-242.
  !***
  ! **Routines called:**  R1MACH, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   790801  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   891009  Removed unreferenced statement labels.  (WRB)
  !   891009  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900326  Removed duplicate information from DESCRIPTIONsection.  (WRB)
  !   900510  Changed calls to XERMSG to standard form, and some
  !           editorial changes.  (RWC))
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE service, ONLY : eps_2_sp, tiny_sp, huge_sp
  !
  REAL(SP), INTENT(IN) :: X, Y, Z
  !
  REAL(SP) :: epslon, e2, e3, lamda, mu, s, xn, xndev, xnroot, yn, yndev, ynroot, &
    zn, zndev, znroot
  CHARACTER(16) :: xern3, xern4, xern5, xern6
  REAL(SP), PARAMETER :: errtol = (4._SP*eps_2_sp)**(1._SP/6._SP), &
    lolim = 5._SP*tiny_sp, uplim = huge_sp/5._SP
  REAL(SP), PARAMETER :: c1 = 1._SP/24._SP, c2 = 3._SP/44._SP, c3 = 1._SP/14._SP
  !
  !* FIRST EXECUTABLE STATEMENT  RF
  !
  !         CALL ERROR HANDLER IF NECESSARY.
  !
  RF = 0._SP
  IF( MIN(X,Y,Z)<0._SP ) THEN
    WRITE (xern3,'(1PE15.6)') X
    WRITE (xern4,'(1PE15.6)') Y
    WRITE (xern5,'(1PE15.6)') Z
    ERROR STOP 'RF : MIN(X,Y,Z)<0'
    ! WHERE X = '//xern3//' Y = '//xern4//' AND Z = '//xern5
  END IF
  !
  IF( MAX(X,Y,Z)>uplim ) THEN
    WRITE (xern3,'(1PE15.6)') X
    WRITE (xern4,'(1PE15.6)') Y
    WRITE (xern5,'(1PE15.6)') Z
    WRITE (xern6,'(1PE15.6)') uplim
    ERROR STOP 'RF : MAX(X,Y,Z)>UPLIM'
    ! WHERE X = '//xern3//' Y = '//xern4//' Z = '//xern5//' AND UPLIM = '//xern6
  END IF
  !
  IF( MIN(X+Y,X+Z,Y+Z)<lolim ) THEN
    WRITE (xern3,'(1PE15.6)') X
    WRITE (xern4,'(1PE15.6)') Y
    WRITE (xern5,'(1PE15.6)') Z
    WRITE (xern6,'(1PE15.6)') lolim
    ERROR STOP 'RF : MIN(X+Y,X+Z,Y+Z)<LOLIM'
    ! WHERE X = '//xern3//' Y = '//xern4//' Z = '//xern5//' AND LOLIM = '//xern6
  END IF
  !
  xn = X
  yn = Y
  zn = Z
  DO
    !
    mu = (xn+yn+zn)/3._SP
    xndev = 2._SP - (mu+xn)/mu
    yndev = 2._SP - (mu+yn)/mu
    zndev = 2._SP - (mu+zn)/mu
    epslon = MAX(ABS(xndev),ABS(yndev),ABS(zndev))
    IF( epslon<errtol ) THEN
      !
      e2 = xndev*yndev - zndev*zndev
      e3 = xndev*yndev*zndev
      s = 1._SP + (c1*e2-0.10_SP-c2*e3)*e2 + c3*e3
      RF = s/SQRT(mu)
      EXIT
    ELSE
      xnroot = SQRT(xn)
      ynroot = SQRT(yn)
      znroot = SQRT(zn)
      lamda = xnroot*(ynroot+znroot) + ynroot*znroot
      xn = (xn+lamda)*0.250_SP
      yn = (yn+lamda)*0.250_SP
      zn = (zn+lamda)*0.250_SP
    END IF
  END DO
  !
END FUNCTION RF
