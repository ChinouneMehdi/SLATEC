!DECK COT
FUNCTION COT(X)
  IMPLICIT NONE
  REAL ainty, ainty2, COT, cotcs, CSEVL, pi2rec, prodbg, R1MACH, &
    sqeps, X, xmax, xmin, xsml, y, yrem
  INTEGER ifn, INITS, nterms
  !***BEGIN PROLOGUE  COT
  !***PURPOSE  Compute the cotangent.
  !***LIBRARY   SLATEC (FNLIB)
  !***CATEGORY  C4A
  !***TYPE      SINGLE PRECISION (COT-S, DCOT-D, CCOT-C)
  !***KEYWORDS  COTANGENT, ELEMENTARY FUNCTIONS, FNLIB, TRIGONOMETRIC
  !***AUTHOR  Fullerton, W., (LANL)
  !***DESCRIPTION
  !
  ! COT(X) calculates the cotangent of the real argument X.  X is in
  ! units of radians.
  !
  ! Series for COT        on the interval  0.          to  6.25000D-02
  !                                        with weighted error   3.76E-17
  !                                         log weighted error  16.42
  !                               significant figures required  15.51
  !                                    decimal places required  16.88
  !
  !***REFERENCES  (NONE)
  !***ROUTINES CALLED  CSEVL, INITS, R1MACH, XERMSG
  !***REVISION HISTORY  (YYMMDD)
  !   770601  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   920618  Removed space from variable names.  (RWC, WRB)
  !***END PROLOGUE  COT
  DIMENSION cotcs(8)
  LOGICAL first
  SAVE cotcs, pi2rec, nterms, xmax, xsml, xmin, sqeps, first
  DATA cotcs(1)/.24025916098295630E0/
  DATA cotcs(2)/ - .016533031601500228E0/
  DATA cotcs(3)/ - .000042998391931724E0/
  DATA cotcs(4)/ - .000000159283223327E0/
  DATA cotcs(5)/ - .000000000619109313E0/
  DATA cotcs(6)/ - .000000000002430197E0/
  DATA cotcs(7)/ - .000000000000009560E0/
  DATA cotcs(8)/ - .000000000000000037E0/
  DATA pi2rec/.0116197723675813430E0/
  DATA first/.TRUE./
  !***FIRST EXECUTABLE STATEMENT  COT
  IF ( first ) THEN
    nterms = INITS(cotcs,8,0.1*R1MACH(3))
    xmax = 1.0/R1MACH(4)
    xsml = SQRT(3.0*R1MACH(3))
    xmin = EXP(MAX(LOG(R1MACH(1)),-LOG(R1MACH(2)))+0.01)
    sqeps = SQRT(R1MACH(4))
  ENDIF
  first = .FALSE.
  !
  y = ABS(X)
  IF ( ABS(X)<xmin ) CALL XERMSG('SLATEC','COT',&
    'ABS(X) IS ZERO OR SO SMALL COT OVERFLOWS',&
    2,2)
  IF ( y>xmax ) CALL XERMSG('SLATEC','COT',&
    'NO PRECISION BECAUSE ABS(X) IS TOO BIG',3,2)
  !
  ! CAREFULLY COMPUTE Y * (2/PI) = (AINT(Y) + REM(Y)) * (.625 + PI2REC)
  ! = AINT(.625*Y) + REM(.625*Y) + Y*PI2REC  =  AINT(.625*Y) + Z
  ! = AINT(.625*Y) + AINT(Z) + REM(Z)
  !
  ainty = AINT(y)
  yrem = y - ainty
  prodbg = 0.625*ainty
  ainty = AINT(prodbg)
  y = (prodbg-ainty) + 0.625*yrem + y*pi2rec
  ainty2 = AINT(y)
  ainty = ainty + ainty2
  y = y - ainty2
  !
  ifn = MOD(ainty,2.)
  IF ( ifn==1 ) y = 1.0 - y
  !
  IF ( ABS(X)>0.5.AND.y<ABS(X)*sqeps ) CALL XERMSG('SLATEC','COT',&
    'ANSWER LT HALF PRECISION, ABS(X) TOO BIG OR X NEAR N*PI '//&
    '(N.NE.0)',1,1)
  !
  IF ( y<=0.25 ) THEN
    COT = 1.0/X
    IF ( y>xsml ) COT = (0.5+CSEVL(32.0*y*y-1.,cotcs,nterms))/y
    !
  ELSEIF ( y>0.5 ) THEN
    !
    COT = (0.5+CSEVL(2.0*y*y-1.,cotcs,nterms))/(0.25*y)
    COT = (COT**2-1.0)*0.5/COT
    COT = (COT**2-1.0)*0.5/COT
  ELSE
    COT = (0.5+CSEVL(8.0*y*y-1.,cotcs,nterms))/(0.5*y)
    COT = (COT**2-1.0)*0.5/COT
  ENDIF
  !
  IF ( X/=0. ) COT = SIGN(COT,X)
  IF ( ifn==1 ) COT = -COT
  !
END FUNCTION COT