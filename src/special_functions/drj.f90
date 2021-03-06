!** DRJ
REAL(DP) ELEMENTAL FUNCTION DRJ(X,Y,Z,P)
  !> Compute the incomplete or complete (X or Y or Z is zero)
  !  elliptic integral of the 3rd kind.  For X, Y, and Z non-negative,
  !  at most one of them zero, and P positive,
  !  RJ(X,Y,Z,P) = Integral from zero to infinity of
  !                              -1/2     -1/2     -1/2     -1
  !                    (3/2)(t+X)    (t+Y)    (t+Z)    (t+P)  dt.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  C14
  !***
  ! **Type:**      DOUBLE PRECISION (RJ-S, DRJ-D)
  !***
  ! **Keywords:**  COMPLETE ELLIPTIC INTEGRAL, DUPLICATION THEOREM,
  !             INCOMPLETE ELLIPTIC INTEGRAL, INTEGRAL OF THE THIRD KIND,
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
  !   1.     DRJ
  !          Standard FORTRAN function routine
  !          Double precision version
  !          The routine calculates an approximation result to
  !          DRJ(X,Y,Z,P) = Integral from zero to infinity of
  !
  !                                -1/2     -1/2     -1/2     -1
  !                      (3/2)(t+X)    (t+Y)    (t+Z)    (t+P)  dt,
  !
  !          where X, Y, and Z are nonnegative, at most one of them is
  !          zero, and P is positive.  If X or Y or Z is zero, the
  !          integral is COMPLETE.  The duplication theorem is iterated
  !          until the variables are nearly equal, and the function is
  !          then expanded in Taylor series to fifth order.
  !
  !
  !   2.     Calling Sequence
  !          DRJ( X, Y, Z, P, IER )
  !
  !          Parameters on Entry
  !          Values assigned by the calling routine
  !
  !          X      - Double precision, nonnegative variable
  !
  !          Y      - Double precision, nonnegative variable
  !
  !          Z      - Double precision, nonnegative variable
  !
  !          P      - Double precision, positive variable
  !
  !
  !          On  Return    (values assigned by the DRJ routine)
  !
  !          DRJ     - Double precision approximation to the integral
  !
  !          IER    - Integer
  !
  !                   IER = 0 Normal and reliable termination of the
  !                           routine. It is assumed that the requested
  !                           accuracy has been achieved.
  !
  !                   IER >  0 Abnormal termination of the routine
  !
  !
  !          X, Y, Z, P are unaltered.
  !
  !
  !   3.    Error Messages
  !
  !         Value of IER assigned by the DRJ routine
  !
  !              Value assigned         Error Message printed
  !              IER = 1                MIN(X,Y,Z) < 0.0D0
  !                  = 2                MIN(X+Y,X+Z,Y+Z,P) < LOLIM
  !                  = 3                MAX(X,Y,Z,P) > UPLIM
  !
  !
  !
  !   4.     Control Parameters
  !
  !                  Values of LOLIM, UPLIM, and ERRTOL are set by the
  !                  routine.
  !
  !
  !          LOLIM and UPLIM determine the valid range of X, Y, Z, and P
  !
  !          LOLIM is not less than the cube root of the value
  !          of LOLIM used in the routine for DRC.
  !
  !          UPLIM is not greater than 0.3 times the cube root of
  !          the value of UPLIM used in the routine for DRC.
  !
  !
  !                     Acceptable values for:   LOLIM      UPLIM
  !                     IBM 360/370 SERIES   :   2.0D-26     3.0D+24
  !                     CDC 6000/7000 SERIES :   5.0D-98     3.0D+106
  !                     UNIVAC 1100 SERIES   :   5.0D-103    6.0D+101
  !                     CRAY                 :   1.32D-822   1.4D+821
  !                     VAX 11 SERIES        :   2.5D-13     9.0D+11
  !
  !
  !
  !          ERRTOL determines the accuracy of the answer
  !
  !                 the value assigned by the routine will result
  !                 in solution precision within 1-2 decimals of
  !                 "machine precision".
  !
  !
  !
  !
  !          Relative error due to truncation of the series for DRJ
  !          is less than 3 * ERRTOL ** 6 / (1 - ERRTOL) ** 3/2.
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
  !          Sample choices:  ERRTOL   Relative truncation
  !                                    error less than
  !                           1.0D-3    4.0D-18
  !                           3.0D-3    3.0D-15
  !                           1.0D-2    4.0D-12
  !                           3.0D-2    3.0D-9
  !                           1.0D-1    4.0D-6
  !
  !                    Decreasing ERRTOL by a factor of 10 yields six more
  !                    decimal digits of accuracy at the expense of one or
  !                    two more iterations of the duplication theorem.
  !
  !- Long Description:
  !
  !   DRJ Special Comments
  !
  !
  !     Check by addition theorem: DRJ(X,X+Z,X+W,X+P)
  !     + DRJ(Y,Y+Z,Y+W,Y+P) + (A-B) * DRJ(A,B,B,A) + 3.0D0 / SQRT(A)
  !     = DRJ(0,Z,W,P), where X,Y,Z,W,P are positive and X * Y
  !     = Z * W,  A = P * P * (X+Y+Z+W),  B = P * (P+X) * (P+Y),
  !     and B - A = P * (P-Z) * (P-W).  The sum of the third and
  !     fourth terms on the left side is 3.0D0 * DRC(A,B).
  !
  !
  !          On Input:
  !
  !     X, Y, Z, and P are the variables in the integral DRJ(X,Y,Z,P).
  !
  !
  !          On Output:
  !
  !
  !          X, Y, Z, P are unaltered.
  !
  !          ********************************************************
  !
  !          WARNING: Changes in the program may improve speed at the
  !                   expense of robustness.
  !
  !    -------------------------------------------------------------------
  !
  !
  !   Special double precision functions via DRJ and DRF
  !
  !
  !                  Legendre form of ELLIPTIC INTEGRAL of 3rd kind
  !                  -----------------------------------------
  !
  !
  !                          PHI         2         -1
  !             P(PHI,K,N) = INT (1+N SIN (THETA) )   *
  !                           0
  !
  !
  !                                  2    2         -1/2
  !                             *(1-K  SIN (THETA) )     D THETA
  !
  !
  !                                           2          2   2
  !                        = SIN (PHI) DRF(COS (PHI), 1-K SIN (PHI),1)
  !
  !                                   3             2         2   2
  !                         -(N/3) SIN (PHI) DRJ(COS (PHI),1-K SIN (PHI),
  !
  !                                  2
  !                         1,1+N SIN (PHI))
  !
  !
  !
  !                  Bulirsch form of ELLIPTIC INTEGRAL of 3rd kind
  !                  -----------------------------------------
  !
  !
  !                                            2 2    2
  !                  EL3(X,KC,P) = X DRF(1,1+KC X ,1+X ) +
  !
  !                                            3           2 2    2     2
  !                               +(1/3)(1-P) X  DRJ(1,1+KC X ,1+X ,1+PX )
  !
  !
  !                                           2
  !                  CEL(KC,P,A,B) = A RF(0,KC ,1) +
  !
  !
  !                                                      2
  !                                 +(1/3)(B-PA) DRJ(0,KC ,1,P)
  !
  !
  !                  Heuman's LAMBDA function
  !                  -----------------------------------------
  !
  !
  !                                2                      2      2    1/2
  !                  L(A,B,P) =(COS (A)SIN(B)COS(B)/(1-COS (A)SIN (B))   )
  !
  !                                            2         2       2
  !                            *(SIN(P) DRF(COS (P),1-SIN (A) SIN (P),1)
  !
  !                                 2       3            2       2
  !                            +(SIN (A) SIN (P)/(3(1-COS (A) SIN (B))))
  !
  !                                    2         2       2
  !                            *DRJ(COS (P),1-SIN (A) SIN (P),1,1-
  !
  !                                2       2          2       2
  !                            -SIN (A) SIN (P)/(1-COS (A) SIN (B))))
  !
  !
  !
  !                  (PI/2) LAMBDA0(A,B) =L(A,B,PI/2) =
  !
  !                   2                         2       2    -1/2
  !              = COS (A)  SIN(B) COS(B) (1-COS (A) SIN (B))
  !
  !                           2                  2       2
  !                 *DRF(0,COS (A),1) + (1/3) SIN (A) COS (A)
  !
  !                                      2       2    -3/2
  !                 *SIN(B) COS(B) (1-COS (A) SIN (B))
  !
  !                           2         2       2          2       2
  !                 *DRJ(0,COS (A),1,COS (A) COS (B)/(1-COS (A) SIN (B)))
  !
  !
  !                  Jacobi ZETA function
  !                  -----------------------------------------
  !
  !                        2                     2   2    1/2
  !             Z(B,K) = (K/3) SIN(B) COS(B) (1-K SIN (B))
  !
  !
  !                                  2      2   2                 2
  !                        *DRJ(0,1-K ,1,1-K SIN (B)) / DRF (0,1-K ,1)
  !
  !
  !  ---------------------------------------------------------------------
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
  ! **Routines called:**  D1MACH, DRC, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   790801  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   891009  Removed unreferenced statement labels.  (WRB)
  !   891009  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900326  Removed duplicate information from DESCRIPTIONsection.  (WRB)
  !   900510  Changed calls to XERMSG to standard form, and some
  !           editorial changes.  (RWC)).
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE service, ONLY : eps_2_dp, tiny_dp, huge_dp
  !
  REAL(DP), INTENT(IN) :: P, X, Y, Z
  !
  REAL(DP) :: alfa, beta, ea, eb, ec, e2, e3, epslon, lamda, mu, pn, pndev, power4, &
    sigma, s1, s2, s3, xn, xndev,xnroot, yn, yndev, ynroot, zn, zndev, znroot
  CHARACTER(16) :: xern3, xern4, xern5, xern6, xern7
  REAL(DP), PARAMETER :: errtol = (eps_2_dp/3._DP)**(1._DP/6._DP), &
    lolim = (5._DP*tiny_dp)**(1._DP/3._DP), &
    uplim = 0.30_DP*(huge_dp/5._DP)**(1._DP/3._DP)
  REAL(DP), PARAMETER :: c1 = 3._DP/14._DP, c2 = 1._DP/3._DP, c3 = 3._DP/22._DP, &
    c4 = 3._DP/26._DP
  !
  !* FIRST EXECUTABLE STATEMENT  DRJ
  !
  !         CALL ERROR HANDLER IF NECESSARY.
  !
  DRJ = 0._DP
  IF( MIN(X,Y,Z)<0._DP ) THEN
    WRITE (xern3,'(1PE15.6)') X
    WRITE (xern4,'(1PE15.6)') Y
    WRITE (xern5,'(1PE15.6)') Z
    ERROR STOP 'DRJ : MIN(X,Y,Z)<0'
    ! WHERE X = '//xern3//' Y = '//xern4//' AND Z = '//xern5
  END IF
  !
  IF( MAX(X,Y,Z,P)>uplim ) THEN
    WRITE (xern3,'(1PE15.6)') X
    WRITE (xern4,'(1PE15.6)') Y
    WRITE (xern5,'(1PE15.6)') Z
    WRITE (xern6,'(1PE15.6)') P
    WRITE (xern7,'(1PE15.6)') uplim
    ERROR STOP 'DRJ : MAX(X,Y,Z,P)>UPLIM'
    ! WHERE X = '//xern3//&
      ! ' Y = '//xern4//' Z = '//xern5//' P = '//xern6//' AND UPLIM = '//xern7
  END IF
  !
  IF( MIN(X+Y,X+Z,Y+Z,P)<lolim ) THEN
    WRITE (xern3,'(1PE15.6)') X
    WRITE (xern4,'(1PE15.6)') Y
    WRITE (xern5,'(1PE15.6)') Z
    WRITE (xern6,'(1PE15.6)') P
    WRITE (xern7,'(1PE15.6)') lolim
    ERROR STOP 'RJ : MIN(X+Y,X+Z,Y+Z,P)<LOLIM'
    ! WHERE X = '//&
      ! xern3//' Y = '//xern4//' Z = '//xern5//' P = '//xern6//' AND LOLIM = '//xern7
  END IF
  !
  xn = X
  yn = Y
  zn = Z
  pn = P
  sigma = 0._DP
  power4 = 1._DP
  DO
    !
    mu = (xn+yn+zn+pn+pn)*0.20_DP
    xndev = (mu-xn)/mu
    yndev = (mu-yn)/mu
    zndev = (mu-zn)/mu
    pndev = (mu-pn)/mu
    epslon = MAX(ABS(xndev),ABS(yndev),ABS(zndev),ABS(pndev))
    IF( epslon<errtol ) THEN
      !
      ea = xndev*(yndev+zndev) + yndev*zndev
      eb = xndev*yndev*zndev
      ec = pndev*pndev
      e2 = ea - 3._DP*ec
      e3 = eb + 2._DP*pndev*(ea-ec)
      s1 = 1._DP + e2*(-c1+0.750_DP*c3*e2-1.50_DP*c4*e3)
      s2 = eb*(0.50_DP*c2+pndev*(-c3-c3+pndev*c4))
      s3 = pndev*ea*(c2-pndev*c3) - c2*pndev*ec
      DRJ = 3._DP*sigma + power4*(s1+s2+s3)/(mu*SQRT(mu))
      EXIT
    ELSE
      xnroot = SQRT(xn)
      ynroot = SQRT(yn)
      znroot = SQRT(zn)
      lamda = xnroot*(ynroot+znroot) + ynroot*znroot
      alfa = pn*(xnroot+ynroot+znroot) + xnroot*ynroot*znroot
      alfa = alfa*alfa
      beta = pn*(pn+lamda)*(pn+lamda)
      sigma = sigma + power4*DRC(alfa,beta)
      power4 = power4*0.250_DP
      xn = (xn+lamda)*0.250_DP
      yn = (yn+lamda)*0.250_DP
      zn = (zn+lamda)*0.250_DP
      pn = (pn+lamda)*0.250_DP
    END IF
  END DO

END FUNCTION DRJ