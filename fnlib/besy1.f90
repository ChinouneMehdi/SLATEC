!DECK BESY1
FUNCTION BESY1(X)
  IMPLICIT NONE
  REAL ampl, BESJ1, BESY1, bm1cs, bth1cs, by1cs, CSEVL, pi4, &
    R1MACH, theta, twodpi, X, xmax, xmin, xsml, y, z
  INTEGER INITS, ntm1, ntth1, nty1
  !***BEGIN PROLOGUE  BESY1
  !***PURPOSE  Compute the Bessel function of the second kind of order
  !            one.
  !***LIBRARY   SLATEC (FNLIB)
  !***CATEGORY  C10A1
  !***TYPE      SINGLE PRECISION (BESY1-S, DBESY1-D)
  !***KEYWORDS  BESSEL FUNCTION, FNLIB, ORDER ONE, SECOND KIND,
  !             SPECIAL FUNCTIONS
  !***AUTHOR  Fullerton, W., (LANL)
  !***DESCRIPTION
  !
  ! BESY1(X) calculates the Bessel function of the second kind of
  ! order one for real argument X.
  !
  ! Series for BY1        on the interval  0.          to  1.60000D+01
  !                                        with weighted error   1.87E-18
  !                                         log weighted error  17.73
  !                               significant figures required  17.83
  !                                    decimal places required  18.30
  !
  ! Series for BM1        on the interval  0.          to  6.25000D-02
  !                                        with weighted error   5.61E-17
  !                                         log weighted error  16.25
  !                               significant figures required  14.97
  !                                    decimal places required  16.91
  !
  ! Series for BTH1       on the interval  0.          to  6.25000D-02
  !                                        with weighted error   4.10E-17
  !                                         log weighted error  16.39
  !                               significant figures required  15.96
  !                                    decimal places required  17.08
  !
  !***REFERENCES  (NONE)
  !***ROUTINES CALLED  BESJ1, CSEVL, INITS, R1MACH, XERMSG
  !***REVISION HISTORY  (YYMMDD)
  !   770401  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900326  Removed duplicate information from DESCRIPTION section.
  !           (WRB)
  !***END PROLOGUE  BESY1
  DIMENSION by1cs(14), bm1cs(21), bth1cs(24)
  LOGICAL first
  SAVE by1cs, bm1cs, bth1cs, twodpi, pi4, nty1, ntm1, ntth1, xmin, &
    xsml, xmax, first
  DATA by1cs(1)/.03208047100611908629E0/
  DATA by1cs(2)/1.262707897433500450E0/
  DATA by1cs(3)/.00649996189992317500E0/
  DATA by1cs(4)/ - .08936164528860504117E0/
  DATA by1cs(5)/.01325088122175709545E0/
  DATA by1cs(6)/ - .00089790591196483523E0/
  DATA by1cs(7)/.00003647361487958306E0/
  DATA by1cs(8)/ - .00000100137438166600E0/
  DATA by1cs(9)/.00000001994539657390E0/
  DATA by1cs(10)/ - .00000000030230656018E0/
  DATA by1cs(11)/.00000000000360987815E0/
  DATA by1cs(12)/ - .00000000000003487488E0/
  DATA by1cs(13)/.00000000000000027838E0/
  DATA by1cs(14)/ - .00000000000000000186E0/
  DATA bm1cs(1)/.1047362510931285E0/
  DATA bm1cs(2)/.00442443893702345E0/
  DATA bm1cs(3)/ - .00005661639504035E0/
  DATA bm1cs(4)/.00000231349417339E0/
  DATA bm1cs(5)/ - .00000017377182007E0/
  DATA bm1cs(6)/.00000001893209930E0/
  DATA bm1cs(7)/ - .00000000265416023E0/
  DATA bm1cs(8)/.00000000044740209E0/
  DATA bm1cs(9)/ - .00000000008691795E0/
  DATA bm1cs(10)/.00000000001891492E0/
  DATA bm1cs(11)/ - .00000000000451884E0/
  DATA bm1cs(12)/.00000000000116765E0/
  DATA bm1cs(13)/ - .00000000000032265E0/
  DATA bm1cs(14)/.00000000000009450E0/
  DATA bm1cs(15)/ - .00000000000002913E0/
  DATA bm1cs(16)/.00000000000000939E0/
  DATA bm1cs(17)/ - .00000000000000315E0/
  DATA bm1cs(18)/.00000000000000109E0/
  DATA bm1cs(19)/ - .00000000000000039E0/
  DATA bm1cs(20)/.00000000000000014E0/
  DATA bm1cs(21)/ - .00000000000000005E0/
  DATA bth1cs(1)/.74060141026313850E0/
  DATA bth1cs(2)/ - .004571755659637690E0/
  DATA bth1cs(3)/.000119818510964326E0/
  DATA bth1cs(4)/ - .000006964561891648E0/
  DATA bth1cs(5)/.000000655495621447E0/
  DATA bth1cs(6)/ - .000000084066228945E0/
  DATA bth1cs(7)/.000000013376886564E0/
  DATA bth1cs(8)/ - .000000002499565654E0/
  DATA bth1cs(9)/.000000000529495100E0/
  DATA bth1cs(10)/ - .000000000124135944E0/
  DATA bth1cs(11)/.000000000031656485E0/
  DATA bth1cs(12)/ - .000000000008668640E0/
  DATA bth1cs(13)/.000000000002523758E0/
  DATA bth1cs(14)/ - .000000000000775085E0/
  DATA bth1cs(15)/.000000000000249527E0/
  DATA bth1cs(16)/ - .000000000000083773E0/
  DATA bth1cs(17)/.000000000000029205E0/
  DATA bth1cs(18)/ - .000000000000010534E0/
  DATA bth1cs(19)/.000000000000003919E0/
  DATA bth1cs(20)/ - .000000000000001500E0/
  DATA bth1cs(21)/.000000000000000589E0/
  DATA bth1cs(22)/ - .000000000000000237E0/
  DATA bth1cs(23)/.000000000000000097E0/
  DATA bth1cs(24)/ - .000000000000000040E0/
  DATA twodpi/0.63661977236758134E0/
  DATA pi4/0.78539816339744831E0/
  DATA first/.TRUE./
  !***FIRST EXECUTABLE STATEMENT  BESY1
  IF ( first ) THEN
    nty1 = INITS(by1cs,14,0.1*R1MACH(3))
    ntm1 = INITS(bm1cs,21,0.1*R1MACH(3))
    ntth1 = INITS(bth1cs,24,0.1*R1MACH(3))
    !
    xmin = 1.571*EXP(MAX(LOG(R1MACH(1)),-LOG(R1MACH(2)))+.01)
    xsml = SQRT(4.0*R1MACH(3))
    xmax = 1.0/R1MACH(4)
  ENDIF
  first = .FALSE.
  !
  IF ( X<=0. ) CALL XERMSG('SLATEC','BESY1','X IS ZERO OR NEGATIVE',1,2)
  IF ( X>4.0 ) THEN
    !
    IF ( X>xmax ) CALL XERMSG('SLATEC','BESY1',&
      'NO PRECISION BECAUSE X IS BIG',2,2)
    !
    z = 32.0/X**2 - 1.0
    ampl = (0.75+CSEVL(z,bm1cs,ntm1))/SQRT(X)
    theta = X - 3.0*pi4 + CSEVL(z,bth1cs,ntth1)/X
    BESY1 = ampl*SIN(theta)
    GOTO 99999
  ENDIF
  !
  IF ( X<xmin ) CALL XERMSG('SLATEC','BESY1','X SO SMALL Y1 OVERFLOWS',3,2)
  y = 0.
  IF ( X>xsml ) y = X*X
  BESY1 = twodpi*LOG(0.5*X)*BESJ1(X) + (0.5+CSEVL(.125*y-1.,by1cs,nty1))/X
  RETURN
  !
  99999 CONTINUE
  END FUNCTION BESY1