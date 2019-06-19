!** CUNHJ
SUBROUTINE CUNHJ(Z,Fnu,Ipmtr,Tol,Phi,Arg,Zeta1,Zeta2,Asum,Bsum)
  !> Subsidiary to CBESI and CBESK
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      ALL (CUNHJ-A, ZUNHJ-A)
  !***
  ! **Author:**  Amos, D. E., (SNL)
  !***
  ! **Description:**
  !
  !     REFERENCES
  !         HANDBOOK OF MATHEMATICAL FUNCTIONS BY M. ABRAMOWITZ AND I.A.
  !         STEGUN, AMS55, NATIONAL BUREAU OF STANDARDS, 1965, CHAPTER 9.
  !
  !         ASYMPTOTICS AND SPECIAL FUNCTIONS BY F.W.J. OLVER, ACADEMIC
  !         PRESS, N.Y., 1974, PAGE 420
  !
  !     ABSTRACT
  !         CUNHJ COMPUTES PARAMETERS FOR BESSEL FUNCTIONS C(FNU,Z) =
  !         J(FNU,Z), Y(FNU,Z) OR H(I,FNU,Z) I=1,2 FOR LARGE ORDERS FNU
  !         BY MEANS OF THE UNIFORM ASYMPTOTIC EXPANSION
  !
  !         C(FNU,Z)=C1*PHI*( ASUM*AIRY(ARG) + C2*BSUM*DAIRY(ARG) )
  !
  !         FOR PROPER CHOICES OF C1, C2, AIRY AND DAIRY WHERE AIRY IS
  !         AN AIRY FUNCTION AND DAIRY IS ITS DERIVATIVE.
  !
  !               (2/3)*FNU*ZETA**1.5 = ZETA1-ZETA2,
  !
  !         ZETA1=0.5*FNU*LOG((1+W)/(1-W)), ZETA2=FNU*W FOR SCALING
  !         PURPOSES IN AIRY FUNCTIONS FROM CAIRY OR CBIRY.
  !
  !         MCONJ=SIGN OF AIMAG(Z), BUT IS AMBIGUOUS WHEN Z IS REAL AND
  !         MUST BE SPECIFIED. IPMTR=0 RETURNS ALL PARAMETERS. IPMTR=
  !         1 COMPUTES ALL EXCEPT ASUM AND BSUM.
  !
  !***
  ! **See also:**  CBESI, CBESK
  !***
  ! **Routines called:**  R1MACH

  !* REVISION HISTORY  (YYMMDD)
  !   830501  DATE WRITTEN
  !   910415  Prologue converted to Version 4.0 format.  (BAB)
  USE service, ONLY : R1MACH
  COMPLEX(SP) :: Arg, Asum, Bsum, cfnu, cr(14), dr(14), p(30), Phi, &
    przth, ptfn, rfn13, rtzta, rzth, suma, sumb, tfn, t2, &
    up(14), w, w2, Z, za, zb, zc, zeta, Zeta1, Zeta2, zth
  REAL(SP) :: ang, ap(30), atol, aw2, azth, btol, Fnu, fn13, fn23, pp, rfnu, rfnu2, Tol, &
    wi, wr, zci, zcr, zetai, zetar, zthi, zthr, asumr, asumi, bsumr, bsumi, test, &
    tstr, tsti, ac
  INTEGER :: ias, ibs, Ipmtr, is, j, jr, ju, k, kmax, kp1, ks, l, &
    lr, lrp1, l1, l2, m
  REAL(SP), PARAMETER :: ar(14) = [ 1.00000000000000000E+00, 1.04166666666666667E-01, &
    8.35503472222222222E-02, 1.28226574556327160E-01, 2.91849026464140464E-01, &
    8.81627267443757652E-01, 3.32140828186276754E+00, 1.49957629868625547E+01, &
    7.89230130115865181E+01, 4.74451538868264323E+02, 3.20749009089066193E+03, &
    2.40865496408740049E+04, 1.98923119169509794E+05, 1.79190200777534383E+06 ]
  REAL(SP), PARAMETER :: br(14) = [ 1.00000000000000000E+00, -1.45833333333333333E-01, &
    -9.87413194444444444E-02, -1.43312053915895062E-01, -3.17227202678413548E-01, &
    -9.42429147957120249E-01, -3.51120304082635426E+00, -1.57272636203680451E+01, &
    -8.22814390971859444E+01, -4.92355370523670524E+02, -3.31621856854797251E+03, &
    -2.48276742452085896E+04, -2.04526587315129788E+05, -1.83844491706820990E+06 ]
  REAL(SP), PARAMETER :: c(105) = [ 1.00000000000000000E+00, -2.08333333333333333E-01, &
    1.25000000000000000E-01, 3.34201388888888889E-01, -4.01041666666666667E-01, &
    7.03125000000000000E-02, -1.02581259645061728E+00, 1.84646267361111111E+00, &
    -8.91210937500000000E-01, 7.32421875000000000E-02, 4.66958442342624743E+00, &
    -1.12070026162229938E+01, 8.78912353515625000E+00, -2.36408691406250000E+00, &
    1.12152099609375000E-01, -2.82120725582002449E+01, 8.46362176746007346E+01, &
    -9.18182415432400174E+01, 4.25349987453884549E+01, -7.36879435947963170E+00, &
    2.27108001708984375E-01, 2.12570130039217123E+02, -7.65252468141181642E+02, &
    1.05999045252799988E+03, -6.99579627376132541E+02, 2.18190511744211590E+02, &
    -2.64914304869515555E+01, 5.72501420974731445E-01, -1.91945766231840700E+03, &
    8.06172218173730938E+03, -1.35865500064341374E+04, 1.16553933368645332E+04, &
    -5.30564697861340311E+03, 1.20090291321635246E+03, -1.08090919788394656E+02, &
    1.72772750258445740E+00, 2.02042913309661486E+04, -9.69805983886375135E+04, &
    1.92547001232531532E+05, -2.03400177280415534E+05, 1.22200464983017460E+05, &
    -4.11926549688975513E+04, 7.10951430248936372E+03, -4.93915304773088012E+02, &
    6.07404200127348304E+00, -2.42919187900551333E+05, 1.31176361466297720E+06, &
    -2.99801591853810675E+06, 3.76327129765640400E+06, -2.81356322658653411E+06, &
    1.26836527332162478E+06, -3.31645172484563578E+05, 4.52187689813627263E+04, &
    -2.49983048181120962E+03, 2.43805296995560639E+01, 3.28446985307203782E+06, &
    -1.97068191184322269E+07, 5.09526024926646422E+07, -7.41051482115326577E+07, &
    6.63445122747290267E+07, -3.75671766607633513E+07, 1.32887671664218183E+07, &
    -2.78561812808645469E+06, 3.08186404612662398E+05, -1.38860897537170405E+04, &
    1.10017140269246738E+02, -4.93292536645099620E+07, 3.25573074185765749E+08, &
    -9.39462359681578403E+08, 1.55359689957058006E+09, -1.62108055210833708E+09, &
    1.10684281682301447E+09, -4.95889784275030309E+08, 1.42062907797533095E+08, &
    -2.44740627257387285E+07, 2.24376817792244943E+06, -8.40054336030240853E+04, &
    5.51335896122020586E+02, 8.14789096118312115E+08, -5.86648149205184723E+09, &
    1.86882075092958249E+10, -3.46320433881587779E+10, 4.12801855797539740E+10, &
    -3.30265997498007231E+10, 1.79542137311556001E+10, -6.56329379261928433E+09, &
    1.55927986487925751E+09, -2.25105661889415278E+08, 1.73951075539781645E+07, &
    -5.49842327572288687E+05, 3.03809051092238427E+03, -1.46792612476956167E+10, &
    1.14498237732025810E+11, -3.99096175224466498E+11, 8.19218669548577329E+11, &
    -1.09837515608122331E+12, 1.00815810686538209E+12, -6.45364869245376503E+11, &
    2.87900649906150589E+11, -8.78670721780232657E+10, 1.76347306068349694E+10, &
    -2.16716498322379509E+09, 1.43157876718888981E+08, -3.87183344257261262E+06, &
    1.82577554742931747E+04 ]
  REAL(SP), PARAMETER :: alfa(180) = [ -4.44444444444444444E-03, -9.22077922077922078E-04, &
    -8.84892884892884893E-05, 1.65927687832449737E-04, 2.46691372741792910E-04, &
    2.65995589346254780E-04, 2.61824297061500945E-04, 2.48730437344655609E-04, &
    2.32721040083232098E-04, 2.16362485712365082E-04, 2.00738858762752355E-04, &
    1.86267636637545172E-04, 1.73060775917876493E-04, 1.61091705929015752E-04, &
    1.50274774160908134E-04, 1.40503497391269794E-04, 1.31668816545922806E-04, &
    1.23667445598253261E-04, 1.16405271474737902E-04, 1.09798298372713369E-04, &
    1.03772410422992823E-04, 9.82626078369363448E-05, 9.32120517249503256E-05, &
    8.85710852478711718E-05, 8.42963105715700223E-05, 8.03497548407791151E-05, &
    7.66981345359207388E-05, 7.33122157481777809E-05, 7.01662625163141333E-05, &
    6.72375633790160292E-05, 6.93735541354588974E-04, 2.32241745182921654E-04, &
    -1.41986273556691197E-05, -1.16444931672048640E-04, -1.50803558053048762E-04, &
    -1.55121924918096223E-04, -1.46809756646465549E-04, -1.33815503867491367E-04, &
    -1.19744975684254051E-04, -1.06184319207974020E-04, -9.37699549891194492E-05, &
    -8.26923045588193274E-05, -7.29374348155221211E-05, -6.44042357721016283E-05, &
    -5.69611566009369048E-05, -5.04731044303561628E-05, -4.48134868008882786E-05, &
    -3.98688727717598864E-05, -3.55400532972042498E-05, -3.17414256609022480E-05, &
    -2.83996793904174811E-05, -2.54522720634870566E-05, -2.28459297164724555E-05, &
    -2.05352753106480604E-05, -1.84816217627666085E-05, -1.66519330021393806E-05, &
    -1.50179412980119482E-05, -1.35554031379040526E-05, -1.22434746473858131E-05, &
    -1.10641884811308169E-05, -3.54211971457743841E-04, -1.56161263945159416E-04, &
    3.04465503594936410E-05, 1.30198655773242693E-04, 1.67471106699712269E-04, &
    1.70222587683592569E-04, 1.56501427608594704E-04, 1.36339170977445120E-04, &
    1.14886692029825128E-04, 9.45869093034688111E-05, 7.64498419250898258E-05, &
    6.07570334965197354E-05, 4.74394299290508799E-05, 3.62757512005344297E-05, &
    2.69939714979224901E-05, 1.93210938247939253E-05, 1.30056674793963203E-05, &
    7.82620866744496661E-06, 3.59257485819351583E-06, 1.44040049814251817E-07, &
    -2.65396769697939116E-06, -4.91346867098485910E-06, -6.72739296091248287E-06, &
    -8.17269379678657923E-06, -9.31304715093561232E-06, -1.02011418798016441E-05, &
    -1.08805962510592880E-05, -1.13875481509603555E-05, -1.17519675674556414E-05, &
    -1.19987364870944141E-05, 3.78194199201772914E-04, 2.02471952761816167E-04, &
    -6.37938506318862408E-05, -2.38598230603005903E-04, -3.10916256027361568E-04, &
    -3.13680115247576316E-04, -2.78950273791323387E-04, -2.28564082619141374E-04, &
    -1.75245280340846749E-04, -1.25544063060690348E-04, -8.22982872820208365E-05, &
    -4.62860730588116458E-05, -1.72334302366962267E-05, 5.60690482304602267E-06, &
    2.31395443148286800E-05, 3.62642745856793957E-05, 4.58006124490188752E-05, &
    5.24595294959114050E-05, 5.68396208545815266E-05, 5.94349820393104052E-05, &
    6.06478527578421742E-05, 6.08023907788436497E-05, 6.01577894539460388E-05, &
    5.89199657344698500E-05, 5.72515823777593053E-05, 5.52804375585852577E-05, &
    5.31063773802880170E-05, 5.08069302012325706E-05, 4.84418647620094842E-05, &
    4.60568581607475370E-05, -6.91141397288294174E-04, -4.29976633058871912E-04, &
    1.83067735980039018E-04, 6.60088147542014144E-04, 8.75964969951185931E-04, &
    8.77335235958235514E-04, 7.49369585378990637E-04, 5.63832329756980918E-04, &
    3.68059319971443156E-04, 1.88464535514455599E-04, 3.70663057664904149E-05, &
    -8.28520220232137023E-05, -1.72751952869172998E-04, -2.36314873605872983E-04, &
    -2.77966150694906658E-04, -3.02079514155456919E-04, -3.12594712643820127E-04, &
    -3.12872558758067163E-04, -3.05678038466324377E-04, -2.93226470614557331E-04, &
    -2.77255655582934777E-04, -2.59103928467031709E-04, -2.39784014396480342E-04, &
    -2.20048260045422848E-04, -2.00443911094971498E-04, -1.81358692210970687E-04, &
    -1.63057674478657464E-04, -1.45712672175205844E-04, -1.29425421983924587E-04, &
    -1.14245691942445952E-04, 1.92821964248775885E-03, 1.35592576302022234E-03, &
    -7.17858090421302995E-04, -2.58084802575270346E-03, -3.49271130826168475E-03, &
    -3.46986299340960628E-03, -2.82285233351310182E-03, -1.88103076404891354E-03, &
    -8.89531718383947600E-04, 3.87912102631035228E-06, 7.28688540119691412E-04, &
    1.26566373053457758E-03, 1.62518158372674427E-03, 1.83203153216373172E-03, &
    1.91588388990527909E-03, 1.90588846755546138E-03, 1.82798982421825727E-03, &
    1.70389506421121530E-03, 1.55097127171097686E-03, 1.38261421852276159E-03, &
    1.20881424230064774E-03, 1.03676532638344962E-03, 8.71437918068619115E-04, &
    7.16080155297701002E-04, 5.72637002558129372E-04, 4.42089819465802277E-04, &
    3.24724948503090564E-04, 2.20342042730246599E-04, 1.28412898401353882E-04, &
    4.82005924552095464E-05 ]
  REAL(SP), PARAMETER :: beta(210) = [ 1.79988721413553309E-02, 5.59964911064388073E-03, &
    2.88501402231132779E-03, 1.80096606761053941E-03, 1.24753110589199202E-03, &
    9.22878876572938311E-04, 7.14430421727287357E-04, 5.71787281789704872E-04, &
    4.69431007606481533E-04, 3.93232835462916638E-04, 3.34818889318297664E-04, &
    2.88952148495751517E-04, 2.52211615549573284E-04, 2.22280580798883327E-04, &
    1.97541838033062524E-04, 1.76836855019718004E-04, 1.59316899661821081E-04, &
    1.44347930197333986E-04, 1.31448068119965379E-04, 1.20245444949302884E-04, &
    1.10449144504599392E-04, 1.01828770740567258E-04, 9.41998224204237509E-05, &
    8.74130545753834437E-05, 8.13466262162801467E-05, 7.59002269646219339E-05, &
    7.09906300634153481E-05, 6.65482874842468183E-05, 6.25146958969275078E-05, &
    5.88403394426251749E-05, -1.49282953213429172E-03, -8.78204709546389328E-04, &
    -5.02916549572034614E-04, -2.94822138512746025E-04, -1.75463996970782828E-04, &
    -1.04008550460816434E-04, -5.96141953046457895E-05, -3.12038929076098340E-05, &
    -1.26089735980230047E-05, -2.42892608575730389E-07, 8.05996165414273571E-06, &
    1.36507009262147391E-05, 1.73964125472926261E-05, 1.98672978842133780E-05, &
    2.14463263790822639E-05, 2.23954659232456514E-05, 2.28967783814712629E-05, &
    2.30785389811177817E-05, 2.30321976080909144E-05, 2.28236073720348722E-05, &
    2.25005881105292418E-05, 2.20981015361991429E-05, 2.16418427448103905E-05, &
    2.11507649256220843E-05, 2.06388749782170737E-05, 2.01165241997081666E-05, &
    1.95913450141179244E-05, 1.90689367910436740E-05, 1.85533719641636667E-05, &
    1.80475722259674218E-05, 5.52213076721292790E-04, 4.47932581552384646E-04, &
    2.79520653992020589E-04, 1.52468156198446602E-04, 6.93271105657043598E-05, &
    1.76258683069991397E-05, -1.35744996343269136E-05, -3.17972413350427135E-05, &
    -4.18861861696693365E-05, -4.69004889379141029E-05, -4.87665447413787352E-05, &
    -4.87010031186735069E-05, -4.74755620890086638E-05, -4.55813058138628452E-05, &
    -4.33309644511266036E-05, -4.09230193157750364E-05, -3.84822638603221274E-05, &
    -3.60857167535410501E-05, -3.37793306123367417E-05, -3.15888560772109621E-05, &
    -2.95269561750807315E-05, -2.75978914828335759E-05, -2.58006174666883713E-05, &
    -2.41308356761280200E-05, -2.25823509518346033E-05, -2.11479656768912971E-05, &
    -1.98200638885294927E-05, -1.85909870801065077E-05, -1.74532699844210224E-05, &
    -1.63997823854497997E-05, -4.74617796559959808E-04, -4.77864567147321487E-04, &
    -3.20390228067037603E-04, -1.61105016119962282E-04, -4.25778101285435204E-05, &
    3.44571294294967503E-05, 7.97092684075674924E-05, 1.03138236708272200E-04, &
    1.12466775262204158E-04, 1.13103642108481389E-04, 1.08651634848774268E-04, &
    1.01437951597661973E-04, 9.29298396593363896E-05, 8.40293133016089978E-05, &
    7.52727991349134062E-05, 6.69632521975730872E-05, 5.92564547323194704E-05, &
    5.22169308826975567E-05, 4.58539485165360646E-05, 4.01445513891486808E-05, &
    3.50481730031328081E-05, 3.05157995034346659E-05, 2.64956119950516039E-05, &
    2.29363633690998152E-05, 1.97893056664021636E-05, 1.70091984636412623E-05, &
    1.45547428261524004E-05, 1.23886640995878413E-05, 1.04775876076583236E-05, &
    8.79179954978479373E-06, 7.36465810572578444E-04, 8.72790805146193976E-04, &
    6.22614862573135066E-04, 2.85998154194304147E-04, 3.84737672879366102E-06, &
    -1.87906003636971558E-04, -2.97603646594554535E-04, -3.45998126832656348E-04, &
    -3.53382470916037712E-04, -3.35715635775048757E-04, -3.04321124789039809E-04, &
    -2.66722723047612821E-04, -2.27654214122819527E-04, -1.89922611854562356E-04, &
    -1.55058918599093870E-04, -1.23778240761873630E-04, -9.62926147717644187E-05, &
    -7.25178327714425337E-05, -5.22070028895633801E-05, -3.50347750511900522E-05, &
    -2.06489761035551757E-05, -8.70106096849767054E-06, 1.13698686675100290E-06, &
    9.16426474122778849E-06, 1.56477785428872620E-05, 2.08223629482466847E-05, &
    2.48923381004595156E-05, 2.80340509574146325E-05, 3.03987774629861915E-05, &
    3.21156731406700616E-05, -1.80182191963885708E-03, -2.43402962938042533E-03, &
    -1.83422663549856802E-03, -7.62204596354009765E-04, 2.39079475256927218E-04, &
    9.49266117176881141E-04, 1.34467449701540359E-03, 1.48457495259449178E-03, &
    1.44732339830617591E-03, 1.30268261285657186E-03, 1.10351597375642682E-03, &
    8.86047440419791759E-04, 6.73073208165665473E-04, 4.77603872856582378E-04, &
    3.05991926358789362E-04, 1.60315694594721630E-04, 4.00749555270613286E-05, &
    -5.66607461635251611E-05, -1.32506186772982638E-04, -1.90296187989614057E-04, &
    -2.32811450376937408E-04, -2.62628811464668841E-04, -2.82050469867598672E-04, &
    -2.93081563192861167E-04, -2.97435962176316616E-04, -2.96557334239348078E-04, &
    -2.91647363312090861E-04, -2.83696203837734166E-04, -2.73512317095673346E-04, &
    -2.61750155806768580E-04, 6.38585891212050914E-03, 9.62374215806377941E-03, &
    7.61878061207001043E-03, 2.83219055545628054E-03, -2.09841352012720090E-03, &
    -5.73826764216626498E-03, -7.70804244495414620E-03, -8.21011692264844401E-03, &
    -7.65824520346905413E-03, -6.47209729391045177E-03, -4.99132412004966473E-03, &
    -3.45612289713133280E-03, -2.01785580014170775E-03, -7.59430686781961401E-04, &
    2.84173631523859138E-04, 1.10891667586337403E-03, 1.72901493872728771E-03, &
    2.16812590802684701E-03, 2.45357710494539735E-03, 2.61281821058334862E-03, &
    2.67141039656276912E-03, 2.65203073395980430E-03, 2.57411652877287315E-03, &
    2.45389126236094427E-03, 2.30460058071795494E-03, 2.13684837686712662E-03, &
    1.95896528478870911E-03, 1.77737008679454412E-03, 1.59690280765839059E-03, &
    1.42111975664438546E-03 ]
  REAL(SP), PARAMETER :: gama(30) = [ 6.29960524947436582E-01, 2.51984209978974633E-01, &
    1.54790300415655846E-01, 1.10713062416159013E-01, 8.57309395527394825E-02, &
    6.97161316958684292E-02, 5.86085671893713576E-02, 5.04698873536310685E-02, &
    4.42600580689154809E-02, 3.93720661543509966E-02, 3.54283195924455368E-02, &
    3.21818857502098231E-02, 2.94646240791157679E-02, 2.71581677112934479E-02, &
    2.51768272973861779E-02, 2.34570755306078891E-02, 2.19508390134907203E-02, &
    2.06210828235646240E-02, 1.94388240897880846E-02, 1.83810633800683158E-02, &
    1.74293213231963172E-02, 1.65685837786612353E-02, 1.57865285987918445E-02, &
    1.50729501494095594E-02, 1.44193250839954639E-02, 1.38184805735341786E-02, &
    1.32643378994276568E-02, 1.27517121970498651E-02, 1.22761545318762767E-02, &
    1.18338262398482403E-02 ]
  REAL(SP), PARAMETER :: ex1 = 3.33333333333333333E-01, ex2 = 6.66666666666666667E-01, &
    hpi = 1.57079632679489662E+00, pi = 3.14159265358979324E+00, &
    thpi = 4.71238898038468986E+00
  COMPLEX(SP), PARAMETER :: czero = (0.0E0,0.0E0), cone = (1.0E0,0.0E0)
  !* FIRST EXECUTABLE STATEMENT  CUNHJ
  rfnu = 1.0E0/Fnu
  !     ZB = Z*CMPLX(RFNU,0.0E0)
  !-----------------------------------------------------------------------
  !     OVERFLOW TEST (Z/FNU TOO SMALL)
  !-----------------------------------------------------------------------
  tstr = REAL(Z)
  tsti = AIMAG(Z)
  test = R1MACH(1)*1.0E+3
  ac = Fnu*test
  IF( ABS(tstr)>ac .OR. ABS(tsti)>ac ) THEN
    zb = Z*CMPLX(rfnu,0.0E0)
    rfnu2 = rfnu*rfnu
    !-----------------------------------------------------------------------
    !     COMPUTE IN THE FOURTH QUADRANT
    !-----------------------------------------------------------------------
    fn13 = Fnu**ex1
    fn23 = fn13*fn13
    rfn13 = CMPLX(1.0E0/fn13,0.0E0)
    w2 = cone - zb*zb
    aw2 = ABS(w2)
    IF( aw2>0.25E0 ) THEN
      !-----------------------------------------------------------------------
      !     ABS(W2)>0.25E0
      !-----------------------------------------------------------------------
      w = SQRT(w2)
      wr = REAL(w)
      wi = AIMAG(w)
      IF( wr<0.0E0 ) wr = 0.0E0
      IF( wi<0.0E0 ) wi = 0.0E0
      w = CMPLX(wr,wi)
      za = (cone+w)/zb
      zc = LOG(za)
      zcr = REAL(zc)
      zci = AIMAG(zc)
      IF( zci<0.0E0 ) zci = 0.0E0
      IF( zci>hpi ) zci = hpi
      IF( zcr<0.0E0 ) zcr = 0.0E0
      zc = CMPLX(zcr,zci)
      zth = (zc-w)*CMPLX(1.5E0,0.0E0)
      cfnu = CMPLX(Fnu,0.0E0)
      Zeta1 = zc*cfnu
      Zeta2 = w*cfnu
      azth = ABS(zth)
      zthr = REAL(zth)
      zthi = AIMAG(zth)
      ang = thpi
      IF( zthr<0.0E0 .OR. zthi>=0.0E0 ) THEN
        ang = hpi
        IF( zthr/=0.0E0 ) THEN
          ang = ATAN(zthi/zthr)
          IF( zthr<0.0E0 ) ang = ang + pi
        END IF
      END IF
      pp = azth**ex2
      ang = ang*ex2
      zetar = pp*COS(ang)
      zetai = pp*SIN(ang)
      IF( zetai<0.0E0 ) zetai = 0.0E0
      zeta = CMPLX(zetar,zetai)
      Arg = zeta*CMPLX(fn23,0.0E0)
      rtzta = zth/zeta
      za = rtzta/w
      Phi = SQRT(za+za)*rfn13
      IF( Ipmtr/=1 ) THEN
        tfn = CMPLX(rfnu,0.0E0)/w
        rzth = CMPLX(rfnu,0.0E0)/zth
        zc = rzth*CMPLX(ar(2),0.0E0)
        t2 = cone/w2
        up(2) = (t2*CMPLX(c(2),0.0E0)+CMPLX(c(3),0.0E0))*tfn
        Bsum = up(2) + zc
        Asum = czero
        IF( rfnu>=Tol ) THEN
          przth = rzth
          ptfn = tfn
          up(1) = cone
          pp = 1.0E0
          bsumr = REAL(Bsum)
          bsumi = AIMAG(Bsum)
          btol = Tol*(ABS(bsumr)+ABS(bsumi))
          ks = 0
          kp1 = 2
          l = 3
          ias = 0
          ibs = 0
          DO lr = 2, 12, 2
            lrp1 = lr + 1
            !-----------------------------------------------------------------------
            !     COMPUTE TWO ADDITIONAL CR, DR, AND UP FOR TWO MORE TERMS IN
            !     NEXT SUMA AND SUMB
            !-----------------------------------------------------------------------
            DO k = lr, lrp1
              ks = ks + 1
              kp1 = kp1 + 1
              l = l + 1
              za = CMPLX(c(l),0.0E0)
              DO j = 2, kp1
                l = l + 1
                za = za*t2 + CMPLX(c(l),0.0E0)
              END DO
              ptfn = ptfn*tfn
              up(kp1) = ptfn*za
              cr(ks) = przth*CMPLX(br(ks+1),0.0E0)
              przth = przth*rzth
              dr(ks) = przth*CMPLX(ar(ks+2),0.0E0)
            END DO
            pp = pp*rfnu2
            IF( ias/=1 ) THEN
              suma = up(lrp1)
              ju = lrp1
              DO jr = 1, lr
                ju = ju - 1
                suma = suma + cr(jr)*up(ju)
              END DO
              Asum = Asum + suma
              asumr = REAL(Asum)
              asumi = AIMAG(Asum)
              test = ABS(asumr) + ABS(asumi)
              IF( pp<Tol .AND. test<Tol ) ias = 1
            END IF
            IF( ibs/=1 ) THEN
              sumb = up(lr+2) + up(lrp1)*zc
              ju = lrp1
              DO jr = 1, lr
                ju = ju - 1
                sumb = sumb + dr(jr)*up(ju)
              END DO
              Bsum = Bsum + sumb
              bsumr = REAL(Bsum)
              bsumi = AIMAG(Bsum)
              test = ABS(bsumr) + ABS(bsumi)
              IF( pp<btol .AND. test<Tol ) ibs = 1
            END IF
            IF( ias==1 .AND. ibs==1 ) EXIT
          END DO
        END IF
        Asum = Asum + cone
        Bsum = -Bsum*rfn13/rtzta
      END IF
    ELSE
      !-----------------------------------------------------------------------
      !     POWER SERIES FOR ABS(W2)<=0.25E0
      !-----------------------------------------------------------------------
      k = 1
      p(1) = cone
      suma = CMPLX(gama(1),0.0E0)
      ap(1) = 1.0E0
      IF( aw2>=Tol ) THEN
        DO k = 2, 30
          p(k) = p(k-1)*w2
          suma = suma + p(k)*CMPLX(gama(k),0.0E0)
          ap(k) = ap(k-1)*aw2
          IF( ap(k)<Tol ) GOTO 20
        END DO
        k = 30
      END IF
      20  kmax = k
      zeta = w2*suma
      Arg = zeta*CMPLX(fn23,0.0E0)
      za = SQRT(suma)
      Zeta2 = SQRT(w2)*CMPLX(Fnu,0.0E0)
      Zeta1 = Zeta2*(cone+zeta*za*CMPLX(ex2,0.0E0))
      za = za + za
      Phi = SQRT(za)*rfn13
      IF( Ipmtr/=1 ) THEN
        !-----------------------------------------------------------------------
        !     SUM SERIES FOR ASUM AND BSUM
        !-----------------------------------------------------------------------
        sumb = czero
        DO k = 1, kmax
          sumb = sumb + p(k)*CMPLX(beta(k),0.0E0)
        END DO
        Asum = czero
        Bsum = sumb
        l1 = 0
        l2 = 30
        btol = Tol*ABS(Bsum)
        atol = Tol
        pp = 1.0E0
        ias = 0
        ibs = 0
        IF( rfnu2>=Tol ) THEN
          DO is = 2, 7
            atol = atol/rfnu2
            pp = pp*rfnu2
            IF( ias/=1 ) THEN
              suma = czero
              DO k = 1, kmax
                m = l1 + k
                suma = suma + p(k)*CMPLX(alfa(m),0.0E0)
                IF( ap(k)<atol ) EXIT
              END DO
              Asum = Asum + suma*CMPLX(pp,0.0E0)
              IF( pp<Tol ) ias = 1
            END IF
            IF( ibs/=1 ) THEN
              sumb = czero
              DO k = 1, kmax
                m = l2 + k
                sumb = sumb + p(k)*CMPLX(beta(m),0.0E0)
                IF( ap(k)<atol ) EXIT
              END DO
              Bsum = Bsum + sumb*CMPLX(pp,0.0E0)
              IF( pp<btol ) ibs = 1
            END IF
            IF( ias==1 .AND. ibs==1 ) EXIT
            l1 = l1 + 30
            l2 = l2 + 30
          END DO
        END IF
        Asum = Asum + cone
        pp = rfnu*REAL(rfn13)
        Bsum = Bsum*CMPLX(pp,0.0E0)
      END IF
    END IF
  ELSE
    ac = 2.0E0*ABS(LOG(test)) + Fnu
    Zeta1 = CMPLX(ac,0.0E0)
    Zeta2 = CMPLX(Fnu,0.0E0)
    Phi = cone
    Arg = cone
    RETURN
  END IF
  RETURN
END SUBROUTINE CUNHJ
