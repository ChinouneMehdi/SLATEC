!** DBSI1E
REAL(DP) FUNCTION DBSI1E(X)
  !> Compute the exponentially scaled modified (hyperbolic)
  !            Bessel function of the first kind of order one.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C10B1
  !***
  ! **Type:**      DOUBLE PRECISION (BESI1E-S, DBSI1E-D)
  !***
  ! **Keywords:**  EXPONENTIALLY SCALED, FIRST KIND, FNLIB,
  !             HYPERBOLIC BESSEL FUNCTION, MODIFIED BESSEL FUNCTION,
  !             ORDER ONE, SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! DBSI1E(X) calculates the double precision exponentially scaled
  ! modified (hyperbolic) Bessel function of the first kind of order
  ! one for double precision argument X.  The result is I1(X)
  ! multiplied by EXP(-ABS(X)).
  !
  ! Series for BI1        on the interval  0.          to  9.00000E+00
  !                                        with weighted error   1.44E-32
  !                                         log weighted error  31.84
  !                               significant figures required  31.45
  !                                    decimal places required  32.46
  !
  ! Series for AI1        on the interval  1.25000E-01 to  3.33333E-01
  !                                        with weighted error   2.81E-32
  !                                         log weighted error  31.55
  !                               significant figures required  29.93
  !                                    decimal places required  32.38
  !
  ! Series for AI12       on the interval  0.          to  1.25000E-01
  !                                        with weighted error   1.83E-32
  !                                         log weighted error  31.74
  !                               significant figures required  29.97
  !                                    decimal places required  32.66
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
  USE service, ONLY : XERMSG, D1MACH
  REAL(DP) :: X
  REAL(DP) :: y
  INTEGER, SAVE :: nti1, ntai1, ntai12
  REAL(DP), PARAMETER :: eta = 0.1_DP*D1MACH(3), xmin = 2._DP*D1MACH(1), &
    xsml = SQRT(4.5_DP*D1MACH(3))
  REAL(DP), PARAMETER :: bi1cs(17) = [ -.19717132610998597316138503218149E-2_DP, &
    +.40734887667546480608155393652014E+0_DP, +.34838994299959455866245037783787E-1_DP, &
    +.15453945563001236038598401058489E-2_DP, +.41888521098377784129458832004120E-4_DP, &
    +.76490267648362114741959703966069E-6_DP, +.10042493924741178689179808037238E-7_DP, &
    +.99322077919238106481371298054863E-10_DP, +.76638017918447637275200171681349E-12_DP, &
    +.47414189238167394980388091948160E-14_DP, +.24041144040745181799863172032000E-16_DP, &
    +.10171505007093713649121100799999E-18_DP, +.36450935657866949458491733333333E-21_DP, &
    +.11205749502562039344810666666666E-23_DP, +.29875441934468088832000000000000E-26_DP, &
    +.69732310939194709333333333333333E-29_DP, +.14367948220620800000000000000000E-31_DP ]
  REAL(DP), PARAMETER :: ai1cs(46) = [ -.2846744181881478674100372468307E-1_DP, &
    -.1922953231443220651044448774979E-1_DP, -.6115185857943788982256249917785E-3_DP, &
    -.2069971253350227708882823777979E-4_DP, +.8585619145810725565536944673138E-5_DP, &
    +.1049498246711590862517453997860E-5_DP, -.2918338918447902202093432326697E-6_DP, &
    -.1559378146631739000160680969077E-7_DP, +.1318012367144944705525302873909E-7_DP, &
    -.1448423418183078317639134467815E-8_DP, -.2908512243993142094825040993010E-9_DP, &
    +.1266388917875382387311159690403E-9_DP, -.1664947772919220670624178398580E-10_DP, &
    -.1666653644609432976095937154999E-11_DP, +.1242602414290768265232168472017E-11_DP, &
    -.2731549379672432397251461428633E-12_DP, +.2023947881645803780700262688981E-13_DP, &
    +.7307950018116883636198698126123E-14_DP, -.3332905634404674943813778617133E-14_DP, &
    +.7175346558512953743542254665670E-15_DP, -.6982530324796256355850629223656E-16_DP, &
    -.1299944201562760760060446080587E-16_DP, +.8120942864242798892054678342860E-17_DP, &
    -.2194016207410736898156266643783E-17_DP, +.3630516170029654848279860932334E-18_DP, &
    -.1695139772439104166306866790399E-19_DP, -.1288184829897907807116882538222E-19_DP, &
    +.5694428604967052780109991073109E-20_DP, -.1459597009090480056545509900287E-20_DP, &
    +.2514546010675717314084691334485E-21_DP, -.1844758883139124818160400029013E-22_DP, &
    -.6339760596227948641928609791999E-23_DP, +.3461441102031011111108146626560E-23_DP, &
    -.1017062335371393547596541023573E-23_DP, +.2149877147090431445962500778666E-24_DP, &
    -.3045252425238676401746206173866E-25_DP, +.5238082144721285982177634986666E-27_DP, &
    +.1443583107089382446416789503999E-26_DP, -.6121302074890042733200670719999E-27_DP, &
    +.1700011117467818418349189802666E-27_DP, -.3596589107984244158535215786666E-28_DP, &
    +.5448178578948418576650513066666E-29_DP, -.2731831789689084989162564266666E-30_DP, &
    -.1858905021708600715771903999999E-30_DP, +.9212682974513933441127765333333E-31_DP, &
    -.2813835155653561106370833066666E-31_DP ]
  REAL(DP), PARAMETER :: ai12cs(69) = [ +.2857623501828012047449845948469E-1_DP, &
    -.9761097491361468407765164457302E-2_DP, -.1105889387626237162912569212775E-3_DP, &
    -.3882564808877690393456544776274E-5_DP, -.2512236237870208925294520022121E-6_DP, &
    -.2631468846889519506837052365232E-7_DP, -.3835380385964237022045006787968E-8_DP, &
    -.5589743462196583806868112522229E-9_DP, -.1897495812350541234498925033238E-10_DP, &
    +.3252603583015488238555080679949E-10_DP, +.1412580743661378133163366332846E-10_DP, &
    +.2035628544147089507224526136840E-11_DP, -.7198551776245908512092589890446E-12_DP, &
    -.4083551111092197318228499639691E-12_DP, -.2101541842772664313019845727462E-13_DP, &
    +.4272440016711951354297788336997E-13_DP, +.1042027698412880276417414499948E-13_DP, &
    -.3814403072437007804767072535396E-14_DP, -.1880354775510782448512734533963E-14_DP, &
    +.3308202310920928282731903352405E-15_DP, +.2962628997645950139068546542052E-15_DP, &
    -.3209525921993423958778373532887E-16_DP, -.4650305368489358325571282818979E-16_DP, &
    +.4414348323071707949946113759641E-17_DP, +.7517296310842104805425458080295E-17_DP, &
    -.9314178867326883375684847845157E-18_DP, -.1242193275194890956116784488697E-17_DP, &
    +.2414276719454848469005153902176E-18_DP, +.2026944384053285178971922860692E-18_DP, &
    -.6394267188269097787043919886811E-19_DP, -.3049812452373095896084884503571E-19_DP, &
    +.1612841851651480225134622307691E-19_DP, +.3560913964309925054510270904620E-20_DP, &
    -.3752017947936439079666828003246E-20_DP, -.5787037427074799345951982310741E-22_DP, &
    +.7759997511648161961982369632092E-21_DP, -.1452790897202233394064459874085E-21_DP, &
    -.1318225286739036702121922753374E-21_DP, +.6116654862903070701879991331717E-22_DP, &
    +.1376279762427126427730243383634E-22_DP, -.1690837689959347884919839382306E-22_DP, &
    +.1430596088595433153987201085385E-23_DP, +.3409557828090594020405367729902E-23_DP, &
    -.1309457666270760227845738726424E-23_DP, -.3940706411240257436093521417557E-24_DP, &
    +.4277137426980876580806166797352E-24_DP, -.4424634830982606881900283123029E-25_DP, &
    -.8734113196230714972115309788747E-25_DP, +.4045401335683533392143404142428E-25_DP, &
    +.7067100658094689465651607717806E-26_DP, -.1249463344565105223002864518605E-25_DP, &
    +.2867392244403437032979483391426E-26_DP, +.2044292892504292670281779574210E-26_DP, &
    -.1518636633820462568371346802911E-26_DP, +.8110181098187575886132279107037E-28_DP, &
    +.3580379354773586091127173703270E-27_DP, -.1692929018927902509593057175448E-27_DP, &
    -.2222902499702427639067758527774E-28_DP, +.5424535127145969655048600401128E-28_DP, &
    -.1787068401578018688764912993304E-28_DP, -.6565479068722814938823929437880E-29_DP, &
    +.7807013165061145280922067706839E-29_DP, -.1816595260668979717379333152221E-29_DP, &
    -.1287704952660084820376875598959E-29_DP, +.1114548172988164547413709273694E-29_DP, &
    -.1808343145039336939159368876687E-30_DP, -.2231677718203771952232448228939E-30_DP, &
    +.1619029596080341510617909803614E-30_DP, -.1834079908804941413901308439210E-31_DP ]
  LOGICAL, SAVE :: first = .TRUE.
  !* FIRST EXECUTABLE STATEMENT  DBSI1E
  IF( first ) THEN
    nti1 = INITDS(bi1cs,17,eta)
    ntai1 = INITDS(ai1cs,46,eta)
    ntai12 = INITDS(ai12cs,69,eta)
    first = .FALSE.
  END IF
  !
  y = ABS(X)
  IF( y>3._DP ) THEN
    !
    IF( y<=8._DP ) DBSI1E = (0.375_DP+DCSEVL((48._DP/y-11._DP)/5._DP,ai1cs,ntai1))/SQRT(y)
    IF( y>8._DP ) DBSI1E = (0.375_DP+DCSEVL(16._DP/y-1._DP,ai12cs,ntai12))/SQRT(y)
    DBSI1E = SIGN(DBSI1E,X)
    RETURN
  END IF
  !
  DBSI1E = 0._DP
  IF( y==0._DP ) RETURN
  !
  IF( y<=xmin ) CALL XERMSG('DBSI1E',&
    'ABS(X) SO SMALL I1 UNDERFLOWS',1,1)
  IF( y>xmin ) DBSI1E = 0.5_DP*X
  IF( y>xsml ) DBSI1E = X*(0.875_DP+DCSEVL(y*y/4.5_DP-1._DP,bi1cs,nti1))
  DBSI1E = EXP(-y)*DBSI1E
  RETURN
END FUNCTION DBSI1E
