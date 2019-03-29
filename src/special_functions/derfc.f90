!** DERFC
REAL(8) FUNCTION DERFC(X)
  IMPLICIT NONE
  !>
  !***
  !  Compute the complementary error function.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C8A, L5A1E
  !***
  ! **Type:**      DOUBLE PRECISION (ERFC-S, DERFC-D)
  !***
  ! **Keywords:**  COMPLEMENTARY ERROR FUNCTION, ERFC, FNLIB,
  !             SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
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
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  D1MACH, DCSEVL, INITDS, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   770701  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   920618  Removed space from variable names.  (RWC, WRB)

  REAL eta
  INTEGER INITDS, nterc2, nterf, nterfc
  REAL(8) :: X, sqeps, xmax, txmax, xsml, y, D1MACH, DCSEVL
  SAVE nterf, nterfc, nterc2, xsml, xmax, sqeps
  REAL(8), PARAMETER :: erfcs(21) = [ -.49046121234691808039984544033376D-1, &
    -.14226120510371364237824741899631D+0, +.10035582187599795575754676712933D-1, &
    -.57687646997674847650827025509167D-3, +.27419931252196061034422160791471D-4, &
    -.11043175507344507604135381295905D-5, +.38488755420345036949961311498174D-7, &
    -.11808582533875466969631751801581D-8, +.32334215826050909646402930953354D-10, &
    -.79910159470045487581607374708595D-12, +.17990725113961455611967245486634D-13, &
    -.37186354878186926382316828209493D-15, +.71035990037142529711689908394666D-17, &
    -.12612455119155225832495424853333D-18, +.20916406941769294369170500266666D-20, &
    -.32539731029314072982364160000000D-22, +.47668672097976748332373333333333D-24, &
    -.65980120782851343155199999999999D-26, +.86550114699637626197333333333333D-28, &
    -.10788925177498064213333333333333D-29, +.12811883993017002666666666666666D-31 ]
  REAL(8), PARAMETER :: erc2cs(49) = [ -.6960134660230950112739150826197D-1, &
    -.4110133936262089348982212084666D-1, +.3914495866689626881561143705244D-2, &
    -.4906395650548979161280935450774D-3, +.7157479001377036380760894141825D-4, &
    -.1153071634131232833808232847912D-4, +.1994670590201997635052314867709D-5, &
    -.3642666471599222873936118430711D-6, +.6944372610005012589931277214633D-7, &
    -.1371220902104366019534605141210D-7, +.2788389661007137131963860348087D-8, &
    -.5814164724331161551864791050316D-9, +.1238920491752753181180168817950D-9, &
    -.2690639145306743432390424937889D-10, +.5942614350847910982444709683840D-11, &
    -.1332386735758119579287754420570D-11, +.3028046806177132017173697243304D-12, &
    -.6966648814941032588795867588954D-13, +.1620854541053922969812893227628D-13, &
    -.3809934465250491999876913057729D-14, +.9040487815978831149368971012975D-15, &
    -.2164006195089607347809812047003D-15, +.5222102233995854984607980244172D-16, &
    -.1269729602364555336372415527780D-16, +.3109145504276197583836227412951D-17, &
    -.7663762920320385524009566714811D-18, +.1900819251362745202536929733290D-18, &
    -.4742207279069039545225655999965D-19, +.1189649200076528382880683078451D-19, &
    -.3000035590325780256845271313066D-20, +.7602993453043246173019385277098D-21, &
    -.1935909447606872881569811049130D-21, +.4951399124773337881000042386773D-22, &
    -.1271807481336371879608621989888D-22, +.3280049600469513043315841652053D-23, &
    -.8492320176822896568924792422399D-24, +.2206917892807560223519879987199D-24, &
    -.5755617245696528498312819507199D-25, +.1506191533639234250354144051199D-25, &
    -.3954502959018796953104285695999D-26, +.1041529704151500979984645051733D-26, &
    -.2751487795278765079450178901333D-27, +.7290058205497557408997703680000D-28, &
    -.1936939645915947804077501098666D-28, +.5160357112051487298370054826666D-29, &
    -.1378419322193094099389644800000D-29, +.3691326793107069042251093333333D-30, &
    -.9909389590624365420653226666666D-31, +.2666491705195388413323946666666D-31 ]
  REAL(8), PARAMETER :: erfccs(59) = [ +.715179310202924774503697709496D-1, &
    -.265324343376067157558893386681D-1, +.171115397792085588332699194606D-2, &
    -.163751663458517884163746404749D-3, +.198712935005520364995974806758D-4, &
    -.284371241276655508750175183152D-5, +.460616130896313036969379968464D-6, &
    -.822775302587920842057766536366D-7, +.159214187277090112989358340826D-7, &
    -.329507136225284321486631665072D-8, +.722343976040055546581261153890D-9, &
    -.166485581339872959344695966886D-9, +.401039258823766482077671768814D-10, &
    -.100481621442573113272170176283D-10, +.260827591330033380859341009439D-11, &
    -.699111056040402486557697812476D-12, +.192949233326170708624205749803D-12, &
    -.547013118875433106490125085271D-13, +.158966330976269744839084032762D-13, &
    -.472689398019755483920369584290D-14, +.143587337678498478672873997840D-14, &
    -.444951056181735839417250062829D-15, +.140481088476823343737305537466D-15, &
    -.451381838776421089625963281623D-16, +.147452154104513307787018713262D-16, &
    -.489262140694577615436841552532D-17, +.164761214141064673895301522827D-17, &
    -.562681717632940809299928521323D-18, +.194744338223207851429197867821D-18, &
    -.682630564294842072956664144723D-19, +.242198888729864924018301125438D-19, &
    -.869341413350307042563800861857D-20, +.315518034622808557122363401262D-20, &
    -.115737232404960874261239486742D-20, +.428894716160565394623737097442D-21, &
    -.160503074205761685005737770964D-21, +.606329875745380264495069923027D-22, &
    -.231140425169795849098840801367D-22, +.888877854066188552554702955697D-23, &
    -.344726057665137652230718495566D-23, +.134786546020696506827582774181D-23, &
    -.531179407112502173645873201807D-24, +.210934105861978316828954734537D-24, &
    -.843836558792378911598133256738D-25, +.339998252494520890627359576337D-25, &
    -.137945238807324209002238377110D-25, +.563449031183325261513392634811D-26, &
    -.231649043447706544823427752700D-26, +.958446284460181015263158381226D-27, &
    -.399072288033010972624224850193D-27, +.167212922594447736017228709669D-27, &
    -.704599152276601385638803782587D-28, +.297976840286420635412357989444D-28, &
    -.126252246646061929722422632994D-28, +.539543870454248793985299653154D-29, &
    -.238099288253145918675346190062D-29, +.109905283010276157359726683750D-29, &
    -.486771374164496572732518677435D-30, +.152587726411035756763200828211D-30 ]
  REAL(8), PARAMETER :: sqrtpi = 1.77245385090551602729816748334115D0
  LOGICAL :: first = .TRUE.
  !* FIRST EXECUTABLE STATEMENT  DERFC
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
    first = .FALSE.
  ENDIF
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
    RETURN
  ELSE
    y = ABS(X)
    IF ( y<=1.0D0 ) THEN
      !
      ! ERFC(X) = 1.0 - ERF(X)  FOR ABS(X) .LE. 1.0
      !
      IF ( y<sqeps ) DERFC = 1.0D0 - 2.0D0*X/sqrtpi
      IF ( y>=sqeps ) DERFC = 1.0D0 - X*(1.0D0+DCSEVL(2.D0*X*X-1.D0,erfcs,nterf))
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
END FUNCTION DERFC
