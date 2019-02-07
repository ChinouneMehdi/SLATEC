!*==CUNIK.f90  processed by SPAG 6.72Dc at 11:01 on  6 Feb 2019
!DECK CUNIK
SUBROUTINE CUNIK(Zr,Fnu,Ikflg,Ipmtr,Tol,Init,Phi,Zeta1,Zeta2,Sum,Cwrk)
  IMPLICIT NONE
  !*--CUNIK5
  !***BEGIN PROLOGUE  CUNIK
  !***SUBSIDIARY
  !***PURPOSE  Subsidiary to CBESI and CBESK
  !***LIBRARY   SLATEC
  !***TYPE      ALL (CUNIK-A, ZUNIK-A)
  !***AUTHOR  Amos, D. E., (SNL)
  !***DESCRIPTION
  !
  !        CUNIK COMPUTES PARAMETERS FOR THE UNIFORM ASYMPTOTIC
  !        EXPANSIONS OF THE I AND K FUNCTIONS ON IKFLG= 1 OR 2
  !        RESPECTIVELY BY
  !
  !        W(FNU,ZR) = PHI*EXP(ZETA)*SUM
  !
  !        WHERE       ZETA=-ZETA1 + ZETA2       OR
  !                          ZETA1 - ZETA2
  !
  !        THE FIRST CALL MUST HAVE INIT=0. SUBSEQUENT CALLS WITH THE
  !        SAME ZR AND FNU WILL RETURN THE I OR K FUNCTION ON IKFLG=
  !        1 OR 2 WITH NO CHANGE IN INIT. CWRK IS A COMPLEX WORK
  !        ARRAY. IPMTR=0 COMPUTES ALL PARAMETERS. IPMTR=1 COMPUTES PHI,
  !        ZETA1,ZETA2.
  !
  !***SEE ALSO  CBESI, CBESK
  !***ROUTINES CALLED  R1MACH
  !***REVISION HISTORY  (YYMMDD)
  !   830501  DATE WRITTEN
  !   910415  Prologue converted to Version 4.0 format.  (BAB)
  !***END PROLOGUE  CUNIK
  COMPLEX cfn, con, cone, crfn, Cwrk, czero, Phi, s, sr, Sum, t, &
    t2, Zeta1, Zeta2, zn, Zr
  REAL ac, c, Fnu, rfn, test, Tol, tstr, tsti, R1MACH
  INTEGER i, Ikflg, Init, Ipmtr, j, k, l
  DIMENSION c(120), Cwrk(16), con(2)
  DATA czero, cone/(0.0E0,0.0E0), (1.0E0,0.0E0)/
  DATA con(1), con(2)/(3.98942280401432678E-01,0.0E0), &
    (1.25331413731550025E+00,0.0E0)/
  DATA c(1), c(2), c(3), c(4), c(5), c(6), c(7), c(8), c(9), &
    c(10), c(11), c(12), c(13), c(14), c(15), c(16), c(17), &
    c(18), c(19), c(20), c(21), c(22), c(23), &
    c(24)/1.00000000000000000E+00, -2.08333333333333333E-01, &
    1.25000000000000000E-01, 3.34201388888888889E-01, &
    -4.01041666666666667E-01, 7.03125000000000000E-02, &
    -1.02581259645061728E+00, 1.84646267361111111E+00, &
    -8.91210937500000000E-01, 7.32421875000000000E-02, &
    4.66958442342624743E+00, -1.12070026162229938E+01, &
    8.78912353515625000E+00, -2.36408691406250000E+00, &
    1.12152099609375000E-01, -2.82120725582002449E+01, &
    8.46362176746007346E+01, -9.18182415432400174E+01, &
    4.25349987453884549E+01, -7.36879435947963170E+00, &
    2.27108001708984375E-01, 2.12570130039217123E+02, &
    -7.65252468141181642E+02, 1.05999045252799988E+03/
  DATA c(25), c(26), c(27), c(28), c(29), c(30), c(31), c(32), &
    c(33), c(34), c(35), c(36), c(37), c(38), c(39), c(40), &
    c(41), c(42), c(43), c(44), c(45), c(46), c(47), &
    c(48)/ - 6.99579627376132541E+02, 2.18190511744211590E+02, &
    -2.64914304869515555E+01, 5.72501420974731445E-01, &
    -1.91945766231840700E+03, 8.06172218173730938E+03, &
    -1.35865500064341374E+04, 1.16553933368645332E+04, &
    -5.30564697861340311E+03, 1.20090291321635246E+03, &
    -1.08090919788394656E+02, 1.72772750258445740E+00, &
    2.02042913309661486E+04, -9.69805983886375135E+04, &
    1.92547001232531532E+05, -2.03400177280415534E+05, &
    1.22200464983017460E+05, -4.11926549688975513E+04, &
    7.10951430248936372E+03, -4.93915304773088012E+02, &
    6.07404200127348304E+00, -2.42919187900551333E+05, &
    1.31176361466297720E+06, -2.99801591853810675E+06/
  DATA c(49), c(50), c(51), c(52), c(53), c(54), c(55), c(56), &
    c(57), c(58), c(59), c(60), c(61), c(62), c(63), c(64), &
    c(65), c(66), c(67), c(68), c(69), c(70), c(71), &
    c(72)/3.76327129765640400E+06, -2.81356322658653411E+06, &
    1.26836527332162478E+06, -3.31645172484563578E+05, &
    4.52187689813627263E+04, -2.49983048181120962E+03, &
    2.43805296995560639E+01, 3.28446985307203782E+06, &
    -1.97068191184322269E+07, 5.09526024926646422E+07, &
    -7.41051482115326577E+07, 6.63445122747290267E+07, &
    -3.75671766607633513E+07, 1.32887671664218183E+07, &
    -2.78561812808645469E+06, 3.08186404612662398E+05, &
    -1.38860897537170405E+04, 1.10017140269246738E+02, &
    -4.93292536645099620E+07, 3.25573074185765749E+08, &
    -9.39462359681578403E+08, 1.55359689957058006E+09, &
    -1.62108055210833708E+09, 1.10684281682301447E+09/
  DATA c(73), c(74), c(75), c(76), c(77), c(78), c(79), c(80), &
    c(81), c(82), c(83), c(84), c(85), c(86), c(87), c(88), &
    c(89), c(90), c(91), c(92), c(93), c(94), c(95), &
    c(96)/ - 4.95889784275030309E+08, 1.42062907797533095E+08, &
    -2.44740627257387285E+07, 2.24376817792244943E+06, &
    -8.40054336030240853E+04, 5.51335896122020586E+02, &
    8.14789096118312115E+08, -5.86648149205184723E+09, &
    1.86882075092958249E+10, -3.46320433881587779E+10, &
    4.12801855797539740E+10, -3.30265997498007231E+10, &
    1.79542137311556001E+10, -6.56329379261928433E+09, &
    1.55927986487925751E+09, -2.25105661889415278E+08, &
    1.73951075539781645E+07, -5.49842327572288687E+05, &
    3.03809051092238427E+03, -1.46792612476956167E+10, &
    1.14498237732025810E+11, -3.99096175224466498E+11, &
    8.19218669548577329E+11, -1.09837515608122331E+12/
  DATA c(97), c(98), c(99), c(100), c(101), c(102), c(103), c(104), &
    c(105), c(106), c(107), c(108), c(109), c(110), c(111), c(112)&
    , c(113), c(114), c(115), c(116), c(117), c(118)&
    /1.00815810686538209E+12, -6.45364869245376503E+11, &
    2.87900649906150589E+11, -8.78670721780232657E+10, &
    1.76347306068349694E+10, -2.16716498322379509E+09, &
    1.43157876718888981E+08, -3.87183344257261262E+06, &
    1.82577554742931747E+04, 2.86464035717679043E+11, &
    -2.40629790002850396E+12, 9.10934118523989896E+12, &
    -2.05168994109344374E+13, 3.05651255199353206E+13, &
    -3.16670885847851584E+13, 2.33483640445818409E+13, &
    -1.23204913055982872E+13, 4.61272578084913197E+12, &
    -1.19655288019618160E+12, 2.05914503232410016E+11, &
    -2.18229277575292237E+10, 1.24700929351271032E+09/
  DATA c(119), c(120)/ - 2.91883881222208134E+07, 1.18838426256783253E+05/
  !***FIRST EXECUTABLE STATEMENT  CUNIK
  IF ( Init==0 ) THEN
    !-----------------------------------------------------------------------
    !     INITIALIZE ALL VARIABLES
    !-----------------------------------------------------------------------
    rfn = 1.0E0/Fnu
    crfn = CMPLX(rfn,0.0E0)
    !     T = ZR*CRFN
    !-----------------------------------------------------------------------
    !     OVERFLOW TEST (ZR/FNU TOO SMALL)
    !-----------------------------------------------------------------------
    tstr = REAL(Zr)
    tsti = AIMAG(Zr)
    test = R1MACH(1)*1.0E+3
    ac = Fnu*test
    IF ( ABS(tstr)>ac.OR.ABS(tsti)>ac ) THEN
      t = Zr*crfn
      s = cone + t*t
      sr = CSQRT(s)
      cfn = CMPLX(Fnu,0.0E0)
      zn = (cone+sr)/t
      Zeta1 = cfn*CLOG(zn)
      Zeta2 = cfn*sr
      t = cone/sr
      sr = t*crfn
      Cwrk(16) = CSQRT(sr)
      Phi = Cwrk(16)*con(Ikflg)
      IF ( Ipmtr/=0 ) RETURN
      t2 = cone/s
      Cwrk(1) = cone
      crfn = cone
      ac = 1.0E0
      l = 1
      DO k = 2, 15
        s = czero
        DO j = 1, k
          l = l + 1
          s = s*t2 + CMPLX(c(l),0.0E0)
        ENDDO
        crfn = crfn*sr
        Cwrk(k) = crfn*s
        ac = ac*rfn
        tstr = REAL(Cwrk(k))
        tsti = AIMAG(Cwrk(k))
        test = ABS(tstr) + ABS(tsti)
        IF ( ac<Tol.AND.test<Tol ) GOTO 20
      ENDDO
      k = 15
      20       Init = k
    ELSE
      ac = 2.0E0*ABS(ALOG(test)) + Fnu
      Zeta1 = CMPLX(ac,0.0E0)
      Zeta2 = CMPLX(Fnu,0.0E0)
      Phi = cone
      RETURN
    ENDIF
  ENDIF
  IF ( Ikflg==2 ) THEN
    !-----------------------------------------------------------------------
    !     COMPUTE SUM FOR THE K FUNCTION
    !-----------------------------------------------------------------------
    s = czero
    t = cone
    DO i = 1, Init
      s = s + t*Cwrk(i)
      t = -t
    ENDDO
    Sum = s
    Phi = Cwrk(16)*con(2)
    GOTO 99999
  ENDIF
  !-----------------------------------------------------------------------
  !     COMPUTE SUM FOR THE I FUNCTION
  !-----------------------------------------------------------------------
  s = czero
  DO i = 1, Init
    s = s + Cwrk(i)
  ENDDO
  Sum = s
  Phi = Cwrk(16)*con(1)
  RETURN
  99999 CONTINUE
  END SUBROUTINE CUNIK
