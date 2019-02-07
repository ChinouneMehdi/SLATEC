!*==DERFC.f90  processed by SPAG 6.72Dc at 10:56 on  6 Feb 2019
!DECK DERFC
REAL(8) FUNCTION DERFC(X)
  IMPLICIT NONE
  !*--DERFC5
  !*** Start of declarations inserted by SPAG
  REAL eta
  INTEGER INITDS, nterc2, nterf, nterfc
  !*** End of declarations inserted by SPAG
  !***BEGIN PROLOGUE  DERFC
  !***PURPOSE  Compute the complementary error function.
  !***LIBRARY   SLATEC (FNLIB)
  !***CATEGORY  C8A, L5A1E
  !***TYPE      DOUBLE PRECISION (ERFC-S, DERFC-D)
  !***KEYWORDS  COMPLEMENTARY ERROR FUNCTION, ERFC, FNLIB,
  !             SPECIAL FUNCTIONS
  !***AUTHOR  Fullerton, W., (LANL)
  !***DESCRIPTION
  !
  ! DERFC(X) calculates the double precision complementary error function
  ! for double precision argument X.
  !
  ! Series for ERF        on the interval  0.          to  1.00000E+00
  !                                        with weighted Error   1.28E-32
  !                                         log weighted Error  31.89
  !                               significant figures required  31.05
  !                                    decimal places required  32.55
  !
  ! Series for ERC2       on the interval  2.50000E-01 to  1.00000E+00
  !                                        with weighted Error   2.67E-32
  !                                         log weighted Error  31.57
  !                               significant figures required  30.31
  !                                    decimal places required  32.42
  !
  ! Series for ERFC       on the interval  0.          to  2.50000E-01
  !                                        with weighted error   1.53E-31
  !                                         log weighted error  30.82
  !                               significant figures required  29.47
  !                                    decimal places required  31.70
  !
  !***REFERENCES  (NONE)
  !***ROUTINES CALLED  D1MACH, DCSEVL, INITDS, XERMSG
  !***REVISION HISTORY  (YYMMDD)
  !   770701  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   920618  Removed space from variable names.  (RWC, WRB)
  !***END PROLOGUE  DERFC
  REAL(8) :: X, erfcs(21), erfccs(59), erc2cs(49), sqeps, &
    sqrtpi, xmax, txmax, xsml, y, D1MACH, DCSEVL
  LOGICAL first
  SAVE erfcs, erc2cs, erfccs, sqrtpi, nterf, nterfc, nterc2, xsml, &
    xmax, sqeps, first
  DATA erfcs(1)/ - .49046121234691808039984544033376D-1/
  DATA erfcs(2)/ - .14226120510371364237824741899631D+0/
  DATA erfcs(3)/ + .10035582187599795575754676712933D-1/
  DATA erfcs(4)/ - .57687646997674847650827025509167D-3/
  DATA erfcs(5)/ + .27419931252196061034422160791471D-4/
  DATA erfcs(6)/ - .11043175507344507604135381295905D-5/
  DATA erfcs(7)/ + .38488755420345036949961311498174D-7/
  DATA erfcs(8)/ - .11808582533875466969631751801581D-8/
  DATA erfcs(9)/ + .32334215826050909646402930953354D-10/
  DATA erfcs(10)/ - .79910159470045487581607374708595D-12/
  DATA erfcs(11)/ + .17990725113961455611967245486634D-13/
  DATA erfcs(12)/ - .37186354878186926382316828209493D-15/
  DATA erfcs(13)/ + .71035990037142529711689908394666D-17/
  DATA erfcs(14)/ - .12612455119155225832495424853333D-18/
  DATA erfcs(15)/ + .20916406941769294369170500266666D-20/
  DATA erfcs(16)/ - .32539731029314072982364160000000D-22/
  DATA erfcs(17)/ + .47668672097976748332373333333333D-24/
  DATA erfcs(18)/ - .65980120782851343155199999999999D-26/
  DATA erfcs(19)/ + .86550114699637626197333333333333D-28/
  DATA erfcs(20)/ - .10788925177498064213333333333333D-29/
  DATA erfcs(21)/ + .12811883993017002666666666666666D-31/
  DATA erc2cs(1)/ - .6960134660230950112739150826197D-1/
  DATA erc2cs(2)/ - .4110133936262089348982212084666D-1/
  DATA erc2cs(3)/ + .3914495866689626881561143705244D-2/
  DATA erc2cs(4)/ - .4906395650548979161280935450774D-3/
  DATA erc2cs(5)/ + .7157479001377036380760894141825D-4/
  DATA erc2cs(6)/ - .1153071634131232833808232847912D-4/
  DATA erc2cs(7)/ + .1994670590201997635052314867709D-5/
  DATA erc2cs(8)/ - .3642666471599222873936118430711D-6/
  DATA erc2cs(9)/ + .6944372610005012589931277214633D-7/
  DATA erc2cs(10)/ - .1371220902104366019534605141210D-7/
  DATA erc2cs(11)/ + .2788389661007137131963860348087D-8/
  DATA erc2cs(12)/ - .5814164724331161551864791050316D-9/
  DATA erc2cs(13)/ + .1238920491752753181180168817950D-9/
  DATA erc2cs(14)/ - .2690639145306743432390424937889D-10/
  DATA erc2cs(15)/ + .5942614350847910982444709683840D-11/
  DATA erc2cs(16)/ - .1332386735758119579287754420570D-11/
  DATA erc2cs(17)/ + .3028046806177132017173697243304D-12/
  DATA erc2cs(18)/ - .6966648814941032588795867588954D-13/
  DATA erc2cs(19)/ + .1620854541053922969812893227628D-13/
  DATA erc2cs(20)/ - .3809934465250491999876913057729D-14/
  DATA erc2cs(21)/ + .9040487815978831149368971012975D-15/
  DATA erc2cs(22)/ - .2164006195089607347809812047003D-15/
  DATA erc2cs(23)/ + .5222102233995854984607980244172D-16/
  DATA erc2cs(24)/ - .1269729602364555336372415527780D-16/
  DATA erc2cs(25)/ + .3109145504276197583836227412951D-17/
  DATA erc2cs(26)/ - .7663762920320385524009566714811D-18/
  DATA erc2cs(27)/ + .1900819251362745202536929733290D-18/
  DATA erc2cs(28)/ - .4742207279069039545225655999965D-19/
  DATA erc2cs(29)/ + .1189649200076528382880683078451D-19/
  DATA erc2cs(30)/ - .3000035590325780256845271313066D-20/
  DATA erc2cs(31)/ + .7602993453043246173019385277098D-21/
  DATA erc2cs(32)/ - .1935909447606872881569811049130D-21/
  DATA erc2cs(33)/ + .4951399124773337881000042386773D-22/
  DATA erc2cs(34)/ - .1271807481336371879608621989888D-22/
  DATA erc2cs(35)/ + .3280049600469513043315841652053D-23/
  DATA erc2cs(36)/ - .8492320176822896568924792422399D-24/
  DATA erc2cs(37)/ + .2206917892807560223519879987199D-24/
  DATA erc2cs(38)/ - .5755617245696528498312819507199D-25/
  DATA erc2cs(39)/ + .1506191533639234250354144051199D-25/
  DATA erc2cs(40)/ - .3954502959018796953104285695999D-26/
  DATA erc2cs(41)/ + .1041529704151500979984645051733D-26/
  DATA erc2cs(42)/ - .2751487795278765079450178901333D-27/
  DATA erc2cs(43)/ + .7290058205497557408997703680000D-28/
  DATA erc2cs(44)/ - .1936939645915947804077501098666D-28/
  DATA erc2cs(45)/ + .5160357112051487298370054826666D-29/
  DATA erc2cs(46)/ - .1378419322193094099389644800000D-29/
  DATA erc2cs(47)/ + .3691326793107069042251093333333D-30/
  DATA erc2cs(48)/ - .9909389590624365420653226666666D-31/
  DATA erc2cs(49)/ + .2666491705195388413323946666666D-31/
  DATA erfccs(1)/ + .715179310202924774503697709496D-1/
  DATA erfccs(2)/ - .265324343376067157558893386681D-1/
  DATA erfccs(3)/ + .171115397792085588332699194606D-2/
  DATA erfccs(4)/ - .163751663458517884163746404749D-3/
  DATA erfccs(5)/ + .198712935005520364995974806758D-4/
  DATA erfccs(6)/ - .284371241276655508750175183152D-5/
  DATA erfccs(7)/ + .460616130896313036969379968464D-6/
  DATA erfccs(8)/ - .822775302587920842057766536366D-7/
  DATA erfccs(9)/ + .159214187277090112989358340826D-7/
  DATA erfccs(10)/ - .329507136225284321486631665072D-8/
  DATA erfccs(11)/ + .722343976040055546581261153890D-9/
  DATA erfccs(12)/ - .166485581339872959344695966886D-9/
  DATA erfccs(13)/ + .401039258823766482077671768814D-10/
  DATA erfccs(14)/ - .100481621442573113272170176283D-10/
  DATA erfccs(15)/ + .260827591330033380859341009439D-11/
  DATA erfccs(16)/ - .699111056040402486557697812476D-12/
  DATA erfccs(17)/ + .192949233326170708624205749803D-12/
  DATA erfccs(18)/ - .547013118875433106490125085271D-13/
  DATA erfccs(19)/ + .158966330976269744839084032762D-13/
  DATA erfccs(20)/ - .472689398019755483920369584290D-14/
  DATA erfccs(21)/ + .143587337678498478672873997840D-14/
  DATA erfccs(22)/ - .444951056181735839417250062829D-15/
  DATA erfccs(23)/ + .140481088476823343737305537466D-15/
  DATA erfccs(24)/ - .451381838776421089625963281623D-16/
  DATA erfccs(25)/ + .147452154104513307787018713262D-16/
  DATA erfccs(26)/ - .489262140694577615436841552532D-17/
  DATA erfccs(27)/ + .164761214141064673895301522827D-17/
  DATA erfccs(28)/ - .562681717632940809299928521323D-18/
  DATA erfccs(29)/ + .194744338223207851429197867821D-18/
  DATA erfccs(30)/ - .682630564294842072956664144723D-19/
  DATA erfccs(31)/ + .242198888729864924018301125438D-19/
  DATA erfccs(32)/ - .869341413350307042563800861857D-20/
  DATA erfccs(33)/ + .315518034622808557122363401262D-20/
  DATA erfccs(34)/ - .115737232404960874261239486742D-20/
  DATA erfccs(35)/ + .428894716160565394623737097442D-21/
  DATA erfccs(36)/ - .160503074205761685005737770964D-21/
  DATA erfccs(37)/ + .606329875745380264495069923027D-22/
  DATA erfccs(38)/ - .231140425169795849098840801367D-22/
  DATA erfccs(39)/ + .888877854066188552554702955697D-23/
  DATA erfccs(40)/ - .344726057665137652230718495566D-23/
  DATA erfccs(41)/ + .134786546020696506827582774181D-23/
  DATA erfccs(42)/ - .531179407112502173645873201807D-24/
  DATA erfccs(43)/ + .210934105861978316828954734537D-24/
  DATA erfccs(44)/ - .843836558792378911598133256738D-25/
  DATA erfccs(45)/ + .339998252494520890627359576337D-25/
  DATA erfccs(46)/ - .137945238807324209002238377110D-25/
  DATA erfccs(47)/ + .563449031183325261513392634811D-26/
  DATA erfccs(48)/ - .231649043447706544823427752700D-26/
  DATA erfccs(49)/ + .958446284460181015263158381226D-27/
  DATA erfccs(50)/ - .399072288033010972624224850193D-27/
  DATA erfccs(51)/ + .167212922594447736017228709669D-27/
  DATA erfccs(52)/ - .704599152276601385638803782587D-28/
  DATA erfccs(53)/ + .297976840286420635412357989444D-28/
  DATA erfccs(54)/ - .126252246646061929722422632994D-28/
  DATA erfccs(55)/ + .539543870454248793985299653154D-29/
  DATA erfccs(56)/ - .238099288253145918675346190062D-29/
  DATA erfccs(57)/ + .109905283010276157359726683750D-29/
  DATA erfccs(58)/ - .486771374164496572732518677435D-30/
  DATA erfccs(59)/ + .152587726411035756763200828211D-30/
  DATA sqrtpi/1.77245385090551602729816748334115D0/
  DATA first/.TRUE./
  !***FIRST EXECUTABLE STATEMENT  DERFC
  IF ( first ) THEN
    eta = 0.1*REAL(D1MACH(3))
    nterf = INITDS(erfcs,21,eta)
    nterfc = INITDS(erfccs,59,eta)
    nterc2 = INITDS(erc2cs,49,eta)
    !
    xsml = -SQRT(-LOG(sqrtpi*D1MACH(3)))
    txmax = SQRT(-LOG(sqrtpi*D1MACH(1)))
    xmax = txmax - 0.5D0*LOG(txmax)/txmax - 0.01D0
    sqeps = SQRT(2.0D0*D1MACH(3))
  ENDIF
  first = .FALSE.
  !
  IF ( X<=xsml ) THEN
    !
    ! ERFC(X) = 1.0 - ERF(X)  FOR  X .LT. XSML
    !
    DERFC = 2.0D0
    RETURN
    !
  ELSEIF ( X>xmax ) THEN
    !
    CALL XERMSG('SLATEC','DERFC','X SO BIG ERFC UNDERFLOWS',1,1)
    DERFC = 0.D0
    GOTO 99999
  ELSE
    y = ABS(X)
    IF ( y<=1.0D0 ) THEN
      !
      ! ERFC(X) = 1.0 - ERF(X)  FOR ABS(X) .LE. 1.0
      !
      IF ( y<sqeps ) DERFC = 1.0D0 - 2.0D0*X/sqrtpi
      IF ( y>=sqeps ) DERFC = 1.0D0 - &
        X*(1.0D0+DCSEVL(2.D0*X*X-1.D0,erfcs,nterf))
      RETURN
    ENDIF
  ENDIF
  !
  ! ERFC(X) = 1.0 - ERF(X)  FOR  1.0 .LT. ABS(X) .LE. XMAX
  !
  y = y*y
  IF ( y<=4.D0 ) DERFC = EXP(-y)/ABS(X)&
    *(0.5D0+DCSEVL((8.D0/y-5.D0)/3.D0,erc2cs,nterc2))
  IF ( y>4.D0 ) DERFC = EXP(-y)/ABS(X)&
    *(0.5D0+DCSEVL(8.D0/y-1.D0,erfccs,nterfc))
  IF ( X<0.D0 ) DERFC = 2.0D0 - DERFC
  RETURN
  !
  99999 CONTINUE
  END FUNCTION DERFC
