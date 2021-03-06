!** YAIRY
PURE SUBROUTINE YAIRY(X,Rx,C,Bi,Dbi)
  !> Subsidiary to BESJ and BESY
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (YAIRY-S, DYAIRY-D)
  !***
  ! **Author:**  Amos, D. E., (SNLA)
  !           Daniel, S. L., (SNLA)
  !***
  ! **Description:**
  !
  !    YAIRY computes the Airy function BI(X) and its derivative DBI(X) for ASYJY
  !
  !                                     INPUT
  !
  !         X  - Argument, computed by ASYJY, X unrestricted
  !        RX  - RX=SQRT(ABS(X)), computed by ASYJY
  !         C  - C=2.*(ABS(X)**1.5)/3., computed by ASYJY
  !
  !                                    OUTPUT
  !        BI  - Value of function BI(X)
  !       DBI  - Value of the derivative DBI(X)
  !
  !***
  ! **See also:**  BESJ, BESY
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   750101  DATE WRITTEN
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  !   910408  Updated the AUTHOR section.  (WRB)

  !
  REAL(SP), INTENT(IN) :: X
  REAL(SP), INTENT(INOUT) :: C, Rx
  REAL(SP), INTENT(OUT) :: Bi, Dbi
  INTEGER :: i, j
  REAL(SP) :: ax, cv, d1, d2, ex, e1, e2, f1, f2, rtrx, s1, s2, t, tc, temp1, temp2, tt
  INTEGER, PARAMETER :: n1 = 20, n2 = 19, n3 = 14
  INTEGER, PARAMETER :: m1 = 18, m2 = 17, m3 = 12
  INTEGER, PARAMETER :: n1d = 21, n2d = 20, n3d = 19, n4d = 14
  INTEGER, PARAMETER :: m1d = 19, m2d = 18, m3d = 17, m4d = 12
  REAL(SP), PARAMETER :: fpi12 = 1.30899693899575E+00_SP, spi12 = 1.83259571459405_SP, &
    con1 = 6.66666666666667E-01_SP, con2 = 7.74148278841779_SP, &
    con3 = 3.64766105490356E-01_SP
  REAL(SP), PARAMETER :: bk1(20) = [ 2.43202846447449E+00_SP, 2.57132009754685E+00_SP, &
    1.02802341258616E+00_SP, 3.41958178205872E-01_SP, 8.41978629889284E-02_SP, &
    1.93877282587962E-02_SP, 3.92687837130335E-03_SP, 6.83302689948043E-04_SP, &
    1.14611403991141E-04_SP, 1.74195138337086E-05_SP, 2.41223620956355E-06_SP, &
    3.24525591983273E-07_SP, 4.03509798540183E-08_SP, 4.70875059642296E-09_SP, &
    5.35367432585889E-10_SP, 5.70606721846334E-11_SP, 5.80526363709933E-12_SP, &
    5.76338988616388E-13_SP, 5.42103834518071E-14_SP, 4.91857330301677E-15_SP ]
  REAL(SP), PARAMETER :: bk2(20) = [ 5.74830555784088E-01_SP, -6.91648648376891E-03_SP, &
    1.97460263052093E-03_SP, -5.24043043868823E-04_SP, 1.22965147239661E-04_SP, &
    -2.27059514462173E-05_SP, 2.23575555008526E-06_SP, 4.15174955023899E-07_SP, &
    -2.84985752198231E-07_SP, 8.50187174775435E-08_SP,-1.70400826891326E-08_SP, &
    2.25479746746889E-09_SP, -1.09524166577443E-10_SP, -3.41063845099711E-11_SP, &
    1.11262893886662E-11_SP, -1.75542944241734E-12_SP, 1.36298600401767E-13_SP, &
    8.76342105755664E-15_SP, -4.64063099157041E-15_SP, 7.78772758732960E-16_SP ]
  REAL(SP), PARAMETER :: bk3(20) = [ 5.66777053506912E-01_SP, 2.63672828349579E-03_SP, &
    5.12303351473130E-05_SP, 2.10229231564492E-06_SP, 1.42217095113890E-07_SP, &
    1.28534295891264E-08_SP, 7.28556219407507E-10_SP, -3.45236157301011E-10_SP, &
    -2.11919115912724E-10_SP,-6.56803892922376E-11_SP,-8.14873160315074E-12_SP, &
    3.03177845632183E-12_SP, 1.73447220554115E-12_SP,  1.67935548701554E-13_SP, &
    -1.49622868806719E-13_SP,-5.15470458953407E-14_SP, 8.75741841857830E-15_SP, &
    7.96735553525720E-15_SP,-1.29566137861742E-16_SP, -1.11878794417520E-15_SP ]
  REAL(SP), PARAMETER :: bk4(14) = [ 4.85444386705114E-01_SP, -3.08525088408463E-03_SP, &
    6.98748404837928E-05_SP, -2.82757234179768E-06_SP, 1.59553313064138E-07_SP, &
    -1.12980692144601E-08_SP, 9.47671515498754E-10_SP,-9.08301736026423E-11_SP, &
    9.70776206450724E-12_SP, -1.13687527254574E-12_SP, 1.43982917533415E-13_SP, &
    -1.95211019558815E-14_SP, 2.81056379909357E-15_SP, -4.26916444775176E-16_SP ]
  REAL(SP), PARAMETER :: bjp(19) = [ 1.34918611457638E-01_SP, -3.19314588205813E-01_SP, &
    5.22061946276114E-02_SP, 5.28869112170312E-02_SP, -8.58100756077350E-03_SP, &
    -2.99211002025555E-03_SP, 4.21126741969759E-04_SP, 8.73931830369273E-05_SP, &
    -1.06749163477533E-05_SP,-1.56575097259349E-06_SP, 1.68051151983999E-07_SP, &
    1.89901103638691E-08_SP, -1.81374004961922E-09_SP, -1.66339134593739E-10_SP, &
    1.42956335780810E-11_SP, 1.10179811626595E-12_SP, -8.60187724192263E-14_SP, &
    -5.71248177285064E-15_SP, 4.08414552853803E-16_SP ]
  REAL(SP), PARAMETER :: bjn(19) = [ 6.59041673525697E-02_SP, -4.24905910566004E-01_SP, &
    2.87209745195830E-01_SP,  1.29787771099606E-01_SP,-4.56354317590358E-02_SP, &
    -1.02630175982540E-02_SP, 2.50704671521101E-03_SP, 3.78127183743483E-04_SP, &
    -7.11287583284084E-05_SP,-8.08651210688923E-06_SP, 1.23879531273285E-06_SP, &
    1.13096815867279E-07_SP, -1.46234283176310E-08_SP, -1.11576315688077E-09_SP, &
    1.24846618243897E-10_SP, 8.18334132555274E-12_SP, -8.07174877048484E-13_SP, &
    -4.63778618766425E-14_SP, 4.09043399081631E-15_SP ]
  REAL(SP), PARAMETER :: aa(14) = [ -2.78593552803079E-01_SP, 3.52915691882584E-03_SP, &
    2.31149677384994E-05_SP, -4.71317842263560E-06_SP, 1.12415907931333E-07_SP, &
    2.00100301184339E-08_SP, -2.60948075302193E-09_SP, 3.55098136101216E-11_SP, &
    3.50849978423875E-11_SP, -5.83007187954202E-12_SP, 2.04644828753326E-13_SP, &
    1.10529179476742E-13_SP, -2.87724778038775E-14_SP, 2.88205111009939E-15_SP ]
  REAL(SP), PARAMETER :: bb(14) = [ -4.90275424742791E-01_SP, -1.57647277946204E-03_SP, &
    9.66195963140306E-05_SP, -1.35916080268815E-07_SP, -2.98157342654859E-07_SP, &
    1.86824767559979E-08_SP, 1.03685737667141E-09_SP,  -3.28660818434328E-10_SP, &
    2.57091410632780E-11_SP, 2.32357655300677E-12_SP,  -9.57523279048255E-13_SP, &
    1.20340828049719E-13_SP, 2.90907716770715E-15_SP,  -4.55656454580149E-15_SP ]
  REAL(SP), PARAMETER :: dbk1(21) = [ 2.95926143981893E+00_SP, 3.86774568440103E+00_SP, &
    1.80441072356289E+00_SP, 5.78070764125328E-01_SP, 1.63011468174708E-01_SP, &
    3.92044409961855E-02_SP, 7.90964210433812E-03_SP, 1.50640863167338E-03_SP, &
    2.56651976920042E-04_SP, 3.93826605867715E-05_SP, 5.81097771463818E-06_SP, &
    7.86881233754659E-07_SP, 9.93272957325739E-08_SP, 1.21424205575107E-08_SP, &
    1.38528332697707E-09_SP, 1.50190067586758E-10_SP, 1.58271945457594E-11_SP, &
    1.57531847699042E-12_SP, 1.50774055398181E-13_SP, 1.40594335806564E-14_SP, &
    1.24942698777218E-15_SP ]
  REAL(SP), PARAMETER :: dbk2(20) = [ 5.49756809432471E-01_SP, 9.13556983276901E-03_SP, &
    -2.53635048605507E-03_SP, 6.60423795342054E-04_SP, -1.55217243135416E-04_SP, &
    3.00090325448633E-05_SP, -3.76454339467348E-06_SP, -1.33291331611616E-07_SP, &
    2.42587371049013E-07_SP, -8.07861075240228E-08_SP, 1.71092818861193E-08_SP, &
    -2.41087357570599E-09_SP, 1.53910848162371E-10_SP, 2.56465373190630E-11_SP, &
    -9.88581911653212E-12_SP, 1.60877986412631E-12_SP,-1.20952524741739E-13_SP, &
    -1.06978278410820E-14_SP, 5.02478557067561E-15_SP, -8.68986130935886E-16_SP ]
  REAL(SP), PARAMETER :: dbk3(20) = [ 5.60598509354302E-01_SP, -3.64870013248135E-03_SP, &
    -5.98147152307417E-05_SP,-2.33611595253625E-06_SP,-1.64571516521436E-07_SP, &
    -2.06333012920569E-08_SP,-4.27745431573110E-09_SP,-1.08494137799276E-09_SP, &
    -2.37207188872763E-10_SP,-2.22132920864966E-11_SP, 1.07238008032138E-11_SP, &
    5.71954845245808E-12_SP,  7.51102737777835E-13_SP,-3.81912369483793E-13_SP, &
    -1.75870057119257E-13_SP, 6.69641694419084E-15_SP, 2.26866724792055E-14_SP, &
    2.69898141356743E-15_SP, -2.67133612397359E-15_SP,-6.54121403165269E-16_SP ]
  REAL(SP), PARAMETER :: dbk4(14) = [ 4.93072999188036E-01_SP, 4.38335419803815E-03_SP, &
    -8.37413882246205E-05_SP, 3.20268810484632E-06_SP,-1.75661979548270E-07_SP, &
    1.22269906524508E-08_SP, -1.01381314366052E-09_SP, 9.63639784237475E-11_SP, &
    -1.02344993379648E-11_SP, 1.19264576554355E-12_SP,-1.50443899103287E-13_SP, &
    2.03299052379349E-14_SP,-2.91890652008292E-15_SP, 4.42322081975475E-16_SP ]
  REAL(SP), PARAMETER :: dbjp(19) = [ 1.13140872390745E-01_SP, -2.08301511416328E-01_SP, &
    1.69396341953138E-02_SP,  2.90895212478621E-02_SP,-3.41467131311549E-03_SP, &
    -1.46455339197417E-03_SP, 1.63313272898517E-04_SP, 3.91145328922162E-05_SP, &
    -3.96757190808119E-06_SP,-6.51846913772395E-07_SP, 5.98707495269280E-08_SP, &
    7.44108654536549E-09_SP, -6.21241056522632E-10_SP,-6.18768017313526E-11_SP, &
    4.72323484752324E-12_SP, 3.91652459802532E-13_SP, -2.74985937845226E-14_SP, &
    -1.95036497762750E-15_SP, 1.26669643809444E-16_SP ]
  REAL(SP), PARAMETER :: dbjn(19) = [ -1.88091260068850E-02_SP, -1.47798180826140E-01_SP, &
    5.46075900433171E-01_SP,  1.52146932663116E-01_SP,-9.58260412266886E-02_SP, &
    -1.63102731696130E-02_SP, 5.75364806680105E-03_SP, 7.12145408252655E-04_SP, &
    -1.75452116846724E-04_SP,-1.71063171685128E-05_SP, 3.24435580631680E-06_SP, &
    2.61190663932884E-07_SP, -4.03026865912779E-08_SP,-2.76435165853895E-09_SP, &
    3.59687929062312E-10_SP, 2.14953308456051E-11_SP, -2.41849311903901E-12_SP, &
    -1.28068004920751E-13_SP, 1.26939834401773E-14_SP ]
  REAL(SP), PARAMETER :: daa(14) = [ 2.77571356944231E-01_SP, -4.44212833419920E-03_SP, &
    8.42328522190089E-05_SP, 2.58040318418710E-06_SP, -3.42389720217621E-07_SP, &
    6.24286894709776E-09_SP, 2.36377836844577E-09_SP, -3.16991042656673E-10_SP, &
    4.40995691658191E-12_SP, 5.18674221093575E-12_SP, -9.64874015137022E-13_SP, &
    4.90190576608710E-14_SP, 1.77253430678112E-14_SP, -5.55950610442662E-15_SP ]
  REAL(SP), PARAMETER :: dbb(14) = [ 4.91627321104601E-01_SP, 3.11164930427489E-03_SP, &
    8.23140762854081E-05_SP,-4.61769776172142E-06_SP,-6.13158880534626E-08_SP, &
    2.87295804656520E-08_SP,-1.81959715372117E-09_SP,-1.44752826642035E-10_SP, &
    4.53724043420422E-11_SP,-3.99655065847223E-12_SP, -3.24089119830323E-13_SP, &
    1.62098952568741E-13_SP, -2.40765247974057E-14_SP, 1.69384811284491E-16_SP ]
  !* FIRST EXECUTABLE STATEMENT  YAIRY
  ax = ABS(X)
  Rx = SQRT(ax)
  C = con1*ax*Rx
  IF( X<0._SP ) THEN
    !
    IF( C>5._SP ) THEN
      !
      rtrx = SQRT(Rx)
      t = 10._SP/C - 1._SP
      tt = t + t
      j = n3
      f1 = aa(j)
      e1 = bb(j)
      f2 = 0._SP
      e2 = 0._SP
      DO i = 1, m3
        j = j - 1
        temp1 = f1
        temp2 = e1
        f1 = tt*f1 - f2 + aa(j)
        e1 = tt*e1 - e2 + bb(j)
        f2 = temp1
        e2 = temp2
      END DO
      temp1 = t*f1 - f2 + aa(1)
      temp2 = t*e1 - e2 + bb(1)
      cv = C - fpi12
      Bi = (temp1*COS(cv)+temp2*SIN(cv))/rtrx
      j = n4d
      f1 = daa(j)
      e1 = dbb(j)
      f2 = 0._SP
      e2 = 0._SP
      DO i = 1, m4d
        j = j - 1
        temp1 = f1
        temp2 = e1
        f1 = tt*f1 - f2 + daa(j)
        e1 = tt*e1 - e2 + dbb(j)
        f2 = temp1
        e2 = temp2
      END DO
      temp1 = t*f1 - f2 + daa(1)
      temp2 = t*e1 - e2 + dbb(1)
      cv = C - spi12
      Dbi = (temp1*COS(cv)-temp2*SIN(cv))*rtrx
      RETURN
    END IF
  ELSEIF( C>8._SP ) THEN
    !
    rtrx = SQRT(Rx)
    t = 16._SP/C - 1._SP
    tt = t + t
    j = n1
    f1 = bk3(j)
    f2 = 0._SP
    DO i = 1, m1
      j = j - 1
      temp1 = f1
      f1 = tt*f1 - f2 + bk3(j)
      f2 = temp1
    END DO
    s1 = t*f1 - f2 + bk3(1)
    j = n2d
    f1 = dbk3(j)
    f2 = 0._SP
    DO i = 1, m2d
      j = j - 1
      temp1 = f1
      f1 = tt*f1 - f2 + dbk3(j)
      f2 = temp1
    END DO
    d1 = t*f1 - f2 + dbk3(1)
    tc = C + C
    ex = EXP(C)
    IF( tc>35._SP ) THEN
      Bi = ex*s1/rtrx
      Dbi = ex*rtrx*d1
      RETURN
    ELSE
      t = 10._SP/C - 1._SP
      tt = t + t
      j = n3
      f1 = bk4(j)
      f2 = 0._SP
      DO i = 1, m3
        j = j - 1
        temp1 = f1
        f1 = tt*f1 - f2 + bk4(j)
        f2 = temp1
      END DO
      s2 = t*f1 - f2 + bk4(1)
      Bi = (s1+EXP(-tc)*s2)/rtrx
      Bi = Bi*ex
      j = n4d
      f1 = dbk4(j)
      f2 = 0._SP
      DO i = 1, m4d
        j = j - 1
        temp1 = f1
        f1 = tt*f1 - f2 + dbk4(j)
        f2 = temp1
      END DO
      d2 = t*f1 - f2 + dbk4(1)
      Dbi = rtrx*(d1+EXP(-tc)*d2)
      Dbi = Dbi*ex
      RETURN
    END IF
  ELSEIF( X>2.5_SP ) THEN
    rtrx = SQRT(Rx)
    t = (X+X-con2)*con3
    tt = t + t
    j = n1
    f1 = bk2(j)
    f2 = 0._SP
    DO i = 1, m1
      j = j - 1
      temp1 = f1
      f1 = tt*f1 - f2 + bk2(j)
      f2 = temp1
    END DO
    Bi = (t*f1-f2+bk2(1))/rtrx
    ex = EXP(C)
    Bi = Bi*ex
    j = n2d
    f1 = dbk2(j)
    f2 = 0._SP
    DO i = 1, m2d
      j = j - 1
      temp1 = f1
      f1 = tt*f1 - f2 + dbk2(j)
      f2 = temp1
    END DO
    Dbi = (t*f1-f2+dbk2(1))*rtrx
    Dbi = Dbi*ex
    RETURN
  ELSE
    t = (X+X-2.5E0_SP)*0.4_SP
    tt = t + t
    j = n1
    f1 = bk1(j)
    f2 = 0._SP
    DO i = 1, m1
      j = j - 1
      temp1 = f1
      f1 = tt*f1 - f2 + bk1(j)
      f2 = temp1
    END DO
    Bi = t*f1 - f2 + bk1(1)
    j = n1d
    f1 = dbk1(j)
    f2 = 0._SP
    DO i = 1, m1d
      j = j - 1
      temp1 = f1
      f1 = tt*f1 - f2 + dbk1(j)
      f2 = temp1
    END DO
    Dbi = t*f1 - f2 + dbk1(1)
    RETURN
  END IF
  t = 0.4_SP*C - 1._SP
  tt = t + t
  j = n2
  f1 = bjp(j)
  e1 = bjn(j)
  f2 = 0._SP
  e2 = 0._SP
  DO i = 1, m2
    j = j - 1
    temp1 = f1
    temp2 = e1
    f1 = tt*f1 - f2 + bjp(j)
    e1 = tt*e1 - e2 + bjn(j)
    f2 = temp1
    e2 = temp2
  END DO
  Bi = (t*e1-e2+bjn(1)) - ax*(t*f1-f2+bjp(1))
  j = n3d
  f1 = dbjp(j)
  e1 = dbjn(j)
  f2 = 0._SP
  e2 = 0._SP
  DO i = 1, m3d
    j = j - 1
    temp1 = f1
    temp2 = e1
    f1 = tt*f1 - f2 + dbjp(j)
    e1 = tt*e1 - e2 + dbjn(j)
    f2 = temp1
    e2 = temp2
  END DO
  Dbi = X*X*(t*f1-f2+dbjp(1)) + (t*e1-e2+dbjn(1))
  RETURN
END SUBROUTINE YAIRY