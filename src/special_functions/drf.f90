!** DRF
REAL(DP) ELEMENTAL FUNCTION DRF(X,Y,Z)
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
  ! **Type:**      DOUBLE PRECISION (RF-S, DRF-D)
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
  !   1.     DRF
  !          Evaluate an INCOMPLETE (or COMPLETE) ELLIPTIC INTEGRAL
  !          of the first kind
  !          Standard FORTRAN function routine
  !          Double precision version
  !          The routine calculates an approximation result to
  !          DRF(X,Y,Z) = Integral from zero to infinity of
  !
  !                               -1/2     -1/2     -1/2
  !                     (1/2)(t+X)    (t+Y)    (t+Z)    dt,
  !
  !          where X, Y, and Z are nonnegative and at most one of them
  !          is zero.  If one of them  is zero, the integral is COMPLETE.
  !          The duplication theorem is iterated until the variables are
  !          nearly equal, and the function is then expanded in Taylor
  !          series to fifth order.
  !
  !   2.     Calling sequence
  !          DRF( X, Y, Z, IER )
  !
  !          Parameters On entry
  !          Values assigned by the calling routine
  !
  !          X      - Double precision, nonnegative variable
  !
  !          Y      - Double precision, nonnegative variable
  !
  !          Z      - Double precision, nonnegative variable
  !
  !
  !
  !          On Return    (values assigned by the DRF routine)
  !
  !          DRF     - Double precision approximation to the integral
  !
  !          IER    - Integer
  !
  !                   IER = 0 Normal and reliable termination of the
  !                           routine. It is assumed that the requested
  !                           accuracy has been achieved.
  !
  !                   IER >  0 Abnormal termination of the routine
  !
  !          X, Y, Z are unaltered.
  !
  !
  !   3.    Error Messages
  !
  !
  !         Value of IER assigned by the DRF routine
  !
  !                  Value assigned         Error Message Printed
  !                  IER = 1                MIN(X,Y,Z) < 0.0D0
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
  !                     Acceptable values for:   LOLIM      UPLIM
  !                     IBM 360/370 SERIES   :   3.0D-78     1.0D+75
  !                     CDC 6000/7000 SERIES :   1.0D-292    1.0D+321
  !                     UNIVAC 1100 SERIES   :   1.0D-307    1.0D+307
  !                     CRAY                 :   2.3D-2466   1.09D+2465
  !                     VAX 11 SERIES        :   1.5D-38     3.0D+37
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
  !        The accuracy of the computed approximation to the integral
  !        can be controlled by choosing the value of ERRTOL.
  !        Truncation of a Taylor series after terms of fifth order
  !        introduces an error less than the amount shown in the
  !        second column of the following table for each value of
  !        ERRTOL in the first column.  In addition to the truncation
  !        error there will be round-off error, but in practice the
  !        total error from both sources is usually less than the
  !        amount given in the table.
  !
  !
  !
  !
  !
  !          Sample choices:  ERRTOL   Relative Truncation
  !                                    error less than
  !                           1.0D-3    3.0D-19
  !                           3.0D-3    2.0D-16
  !                           1.0D-2    3.0D-13
  !                           3.0D-2    2.0D-10
  !                           1.0D-1    3.0D-7
  !
  !
  !                    Decreasing ERRTOL by a factor of 10 yields six more
  !                    decimal digits of accuracy at the expense of one or
  !                    two more iterations of the duplication theorem.
  !
  !- Long Description:
  !
  !   DRF Special Comments
  !
  !
  !
  !          Check by addition theorem: DRF(X,X+Z,X+W) + DRF(Y,Y+Z,Y+W)
  !          = DRF(0,Z,W), where X,Y,Z,W are positive and X * Y = Z * W.
  !
  !
  !          On Input:
  !
  !          X, Y, and Z are the variables in the integral DRF(X,Y,Z).
  !
  !
  !          On Output:
  !
  !
  !          X, Y, Z are unaltered.
  !
  !
  !
  !          ********************************************************
  !
  !          WARNING: Changes in the program may improve speed at the
  !                   expense of robustness.
  !
  !
  !
  !   Special double precision functions via DRF
  !
  !
  !
  !
  !                  Legendre form of ELLIPTIC INTEGRAL of 1st kind
  !
  !                  -----------------------------------------
  !
  !
  !
  !                                             2         2   2
  !                  F(PHI,K) = SIN(PHI) DRF(COS (PHI),1-K SIN (PHI),1)
  !
  !
  !                                  2
  !                  K(K) = DRF(0,1-K ,1)
  !
  !
  !                         PI/2     2   2      -1/2
  !                       = INT  (1-K SIN (PHI) )   D PHI
  !                          0
  !
  !
  !
  !                  Bulirsch form of ELLIPTIC INTEGRAL of 1st kind
  !
  !                  -----------------------------------------
  !
  !
  !                                          2 2    2
  !                  EL1(X,KC) = X DRF(1,1+KC X ,1+X )
  !
  !
  !                  Lemniscate constant A
  !
  !                  -----------------------------------------
  !
  !
  !                       1      4 -1/2
  !                  A = INT (1-S )    DS = DRF(0,1,2) = DRF(0,2,1)
  !                       0
  !
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
  ! **Routines called:**  D1MACH, XERMSG

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
  USE service, ONLY : eps_2_dp, tiny_dp, huge_dp
  !
  REAL(DP), INTENT(IN) :: X, Y, Z
  !
  REAL(DP) :: epslon, e2, e3, lamda, mu, s, xn, xndev, xnroot, yn, yndev, ynroot, &
    zn, zndev, znroot
  CHARACTER(16) :: xern3, xern4, xern5, xern6
  REAL(DP), PARAMETER :: errtol = (4._DP*eps_2_dp)**(1._DP/6._DP), &
    lolim = 5._DP*tiny_dp, uplim = huge_dp/5._DP
  REAL(DP), PARAMETER :: c1 = 1._DP/24._DP, c2 = 3._DP/44._DP, c3 = 1._DP/14._DP
  !
  !* FIRST EXECUTABLE STATEMENT  DRF
  !
  !         CALL ERROR HANDLER IF NECESSARY.
  !
  DRF = 0._DP
  IF( MIN(X,Y,Z)<0._DP ) THEN
    WRITE (xern3,'(1PE15.6)') X
    WRITE (xern4,'(1PE15.6)') Y
    WRITE (xern5,'(1PE15.6)') Z
    ERROR STOP 'DRF : MIN(X,Y,Z)<0'
    ! WHERE X = '//xern3//' Y = '//xern4//' AND Z = '//xern5
  END IF
  !
  IF( MAX(X,Y,Z)>uplim ) THEN
    WRITE (xern3,'(1PE15.6)') X
    WRITE (xern4,'(1PE15.6)') Y
    WRITE (xern5,'(1PE15.6)') Z
    WRITE (xern6,'(1PE15.6)') uplim
    ERROR STOP 'DRF : MAX(X,Y,Z)>UPLIM'
    ! WHERE X = '//xern3//' Y = '//xern4//' Z = '//xern5//' AND UPLIM = '//xern6
  END IF
  !
  IF( MIN(X+Y,X+Z,Y+Z)<lolim ) THEN
    WRITE (xern3,'(1PE15.6)') X
    WRITE (xern4,'(1PE15.6)') Y
    WRITE (xern5,'(1PE15.6)') Z
    WRITE (xern6,'(1PE15.6)') lolim
    ERROR STOP 'DRF : MIN(X+Y,X+Z,Y+Z)<LOLIM'
    ! WHERE X = '//xern3//' Y = '//xern4//' Z = '//xern5//' AND LOLIM = '//xern6
  END IF
  !
  xn = X
  yn = Y
  zn = Z
  DO
    !
    mu = (xn+yn+zn)/3._DP
    xndev = 2._DP - (mu+xn)/mu
    yndev = 2._DP - (mu+yn)/mu
    zndev = 2._DP - (mu+zn)/mu
    epslon = MAX(ABS(xndev),ABS(yndev),ABS(zndev))
    IF( epslon<errtol ) THEN
      !
      e2 = xndev*yndev - zndev*zndev
      e3 = xndev*yndev*zndev
      s = 1._DP + (c1*e2-0.10_DP-c2*e3)*e2 + c3*e3
      DRF = s/SQRT(mu)
      EXIT
    ELSE
      xnroot = SQRT(xn)
      ynroot = SQRT(yn)
      znroot = SQRT(zn)
      lamda = xnroot*(ynroot+znroot) + ynroot*znroot
      xn = (xn+lamda)*0.250_DP
      yn = (yn+lamda)*0.250_DP
      zn = (zn+lamda)*0.250_DP
    END IF
  END DO

END FUNCTION DRF