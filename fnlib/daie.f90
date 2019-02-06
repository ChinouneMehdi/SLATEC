!*==DAIE.f90  processed by SPAG 6.72Dc at 10:56 on  6 Feb 2019
!DECK DAIE
      DOUBLE PRECISION FUNCTION DAIE(X)
      IMPLICIT NONE
!*--DAIE5
!*** Start of declarations inserted by SPAG
      REAL eta
      INTEGER INITDS , naif , naig , naip1 , naip2
!*** End of declarations inserted by SPAG
!***BEGIN PROLOGUE  DAIE
!***PURPOSE  Calculate the Airy function for a negative argument and an
!            exponentially scaled Airy function for a non-negative
!            argument.
!***LIBRARY   SLATEC (FNLIB)
!***CATEGORY  C10D
!***TYPE      DOUBLE PRECISION (AIE-S, DAIE-D)
!***KEYWORDS  EXPONENTIALLY SCALED AIRY FUNCTION, FNLIB,
!             SPECIAL FUNCTIONS
!***AUTHOR  Fullerton, W., (LANL)
!***DESCRIPTION
!
! DAIE(X) calculates the Airy function or the exponentially scaled
! Airy function depending on the value of the argument.  The function
! and argument are both double precision.
!
! Evaluate AI(X) for X .LE. 0.0 and AI(X)*EXP(ZETA) where
! ZETA = 2/3 * X**(3/2)  for X .GE. 0.0
!
! Series for AIF        on the interval -1.00000E+00 to  1.00000E+00
!                                        with weighted error   8.37E-33
!                                         log weighted error  32.08
!                               significant figures required  30.87
!                                    decimal places required  32.63
!
! Series for AIG        on the interval -1.00000E+00 to  1.00000E+00
!                                        with weighted error   7.47E-34
!                                         log weighted error  33.13
!                               significant figures required  31.50
!                                    decimal places required  33.68
!
! Series for AIP1       on the interval  1.25000E-01 to  1.00000E+00
!                                        with weighted error   3.69E-32
!                                         log weighted error  31.43
!                               significant figures required  29.55
!                                    decimal places required  32.31
!
! Series for AIP2       on the interval  0.          to  1.25000E-01
!                                        with weighted error   3.48E-32
!                                         log weighted error  31.46
!                               significant figures required  28.74
!                                    decimal places required  32.24
!
!***REFERENCES  (NONE)
!***ROUTINES CALLED  D1MACH, D9AIMP, DCSEVL, INITDS
!***REVISION HISTORY  (YYMMDD)
!   770701  DATE WRITTEN
!   890531  Changed all specific intrinsics to generic.  (WRB)
!   890531  REVISION DATE from Version 3.2
!   891214  Prologue converted to Version 4.0 format.  (BAB)
!   920618  Removed space from variable names.  (RWC, WRB)
!***END PROLOGUE  DAIE
      DOUBLE PRECISION X , aifcs(13) , aigcs(13) , aip1cs(57) , aip2cs(37) , 
     &                 sqrtx , theta , xbig , xm , x3sml , x32sml , z , D1MACH , 
     &                 DCSEVL
      LOGICAL first
      SAVE aifcs , aigcs , aip1cs , aip2cs , naif , naig , naip1 , naip2 , 
     &  x3sml , x32sml , xbig , first
      DATA aifcs(1)/ - .37971358496669997496197089469414D-1/
      DATA aifcs(2)/ + .59191888537263638574319728013777D-1/
      DATA aifcs(3)/ + .98629280577279975365603891044060D-3/
      DATA aifcs(4)/ + .68488438190765667554854830182412D-5/
      DATA aifcs(5)/ + .25942025962194713019489279081403D-7/
      DATA aifcs(6)/ + .61766127740813750329445749697236D-10/
      DATA aifcs(7)/ + .10092454172466117901429556224601D-12/
      DATA aifcs(8)/ + .12014792511179938141288033225333D-15/
      DATA aifcs(9)/ + .10882945588716991878525295466666D-18/
      DATA aifcs(10)/ + .77513772196684887039238400000000D-22/
      DATA aifcs(11)/ + .44548112037175638391466666666666D-25/
      DATA aifcs(12)/ + .21092845231692343466666666666666D-28/
      DATA aifcs(13)/ + .83701735910741333333333333333333D-32/
      DATA aigcs(1)/ + .18152365581161273011556209957864D-1/
      DATA aigcs(2)/ + .21572563166010755534030638819968D-1/
      DATA aigcs(3)/ + .25678356987483249659052428090133D-3/
      DATA aigcs(4)/ + .14265214119792403898829496921721D-5/
      DATA aigcs(5)/ + .45721149200180426070434097558191D-8/
      DATA aigcs(6)/ + .95251708435647098607392278840592D-11/
      DATA aigcs(7)/ + .13925634605771399051150420686190D-13/
      DATA aigcs(8)/ + .15070999142762379592306991138666D-16/
      DATA aigcs(9)/ + .12559148312567778822703205333333D-19/
      DATA aigcs(10)/ + .83063073770821340343829333333333D-23/
      DATA aigcs(11)/ + .44657538493718567445333333333333D-26/
      DATA aigcs(12)/ + .19900855034518869333333333333333D-29/
      DATA aigcs(13)/ + .74702885256533333333333333333333D-33/
      DATA aip1cs(1)/ - .2146951858910538455460863467778D-1/
      DATA aip1cs(2)/ - .7535382535043301166219720865565D-2/
      DATA aip1cs(3)/ + .5971527949026380852035388881994D-3/
      DATA aip1cs(4)/ - .7283251254207610648502368291548D-4/
      DATA aip1cs(5)/ + .1110297130739299666517381821140D-4/
      DATA aip1cs(6)/ - .1950386152284405710346930314033D-5/
      DATA aip1cs(7)/ + .3786973885159515193885319670057D-6/
      DATA aip1cs(8)/ - .7929675297350978279039072879154D-7/
      DATA aip1cs(9)/ + .1762247638674256075568420122202D-7/
      DATA aip1cs(10)/ - .4110767539667195045029896593893D-8/
      DATA aip1cs(11)/ + .9984770057857892247183414107544D-9/
      DATA aip1cs(12)/ - .2510093251387122211349867730034D-9/
      DATA aip1cs(13)/ + .6500501929860695409272038601725D-10/
      DATA aip1cs(14)/ - .1727818405393616515478877107366D-10/
      DATA aip1cs(15)/ + .4699378842824512578362292872307D-11/
      DATA aip1cs(16)/ - .1304675656297743914491241246272D-11/
      DATA aip1cs(17)/ + .3689698478462678810473948382282D-12/
      DATA aip1cs(18)/ - .1061087206646806173650359679035D-12/
      DATA aip1cs(19)/ + .3098414384878187438660210070110D-13/
      DATA aip1cs(20)/ - .9174908079824139307833423547851D-14/
      DATA aip1cs(21)/ + .2752049140347210895693579062271D-14/
      DATA aip1cs(22)/ - .8353750115922046558091393301880D-15/
      DATA aip1cs(23)/ + .2563931129357934947568636168612D-15/
      DATA aip1cs(24)/ - .7950633762598854983273747289822D-16/
      DATA aip1cs(25)/ + .2489283634603069977437281175644D-16/
      DATA aip1cs(26)/ - .7864326933928735569664626221296D-17/
      DATA aip1cs(27)/ + .2505687311439975672324470645019D-17/
      DATA aip1cs(28)/ - .8047420364163909524537958682241D-18/
      DATA aip1cs(29)/ + .2604097118952053964443401104392D-18/
      DATA aip1cs(30)/ - .8486954164056412259482488834184D-19/
      DATA aip1cs(31)/ + .2784706882142337843359429186027D-19/
      DATA aip1cs(32)/ - .9195858953498612913687224151354D-20/
      DATA aip1cs(33)/ + .3055304318374238742247668225583D-20/
      DATA aip1cs(34)/ - .1021035455479477875902177048439D-20/
      DATA aip1cs(35)/ + .3431118190743757844000555680836D-21/
      DATA aip1cs(36)/ - .1159129341797749513376922463109D-21/
      DATA aip1cs(37)/ + .3935772844200255610836268229154D-22/
      DATA aip1cs(38)/ - .1342880980296717611956718989038D-22/
      DATA aip1cs(39)/ + .4603287883520002741659190305314D-23/
      DATA aip1cs(40)/ - .1585043927004064227810772499387D-23/
      DATA aip1cs(41)/ + .5481275667729675908925523755008D-24/
      DATA aip1cs(42)/ - .1903349371855047259064017948945D-24/
      DATA aip1cs(43)/ + .6635682302374008716777612115968D-25/
      DATA aip1cs(44)/ - .2322311650026314307975200986453D-25/
      DATA aip1cs(45)/ + .8157640113429179313142743695359D-26/
      DATA aip1cs(46)/ - .2875824240632900490057489929557D-26/
      DATA aip1cs(47)/ + .1017329450942901435079714319018D-26/
      DATA aip1cs(48)/ - .3610879108742216446575703490559D-27/
      DATA aip1cs(49)/ + .1285788540363993421256640342698D-27/
      DATA aip1cs(50)/ - .4592901037378547425160693022719D-28/
      DATA aip1cs(51)/ + .1645597033820713725812102485333D-28/
      DATA aip1cs(52)/ - .5913421299843501842087920271360D-29/
      DATA aip1cs(53)/ + .2131057006604993303479369509546D-29/
      DATA aip1cs(54)/ - .7701158157787598216982761745066D-30/
      DATA aip1cs(55)/ + .2790533307968930417581783777280D-30/
      DATA aip1cs(56)/ - .1013807715111284006452241367039D-30/
      DATA aip1cs(57)/ + .3692580158719624093658286216533D-31/
      DATA aip2cs(1)/ - .174314496929375513390355844011D-2/
      DATA aip2cs(2)/ - .167893854325541671632190613480D-2/
      DATA aip2cs(3)/ + .359653403352166035885983858114D-4/
      DATA aip2cs(4)/ - .138081860273922835457399383100D-5/
      DATA aip2cs(5)/ + .741122807731505298848699095233D-7/
      DATA aip2cs(6)/ - .500238203900133013130422866325D-8/
      DATA aip2cs(7)/ + .400693917417184240675446866355D-9/
      DATA aip2cs(8)/ - .367331242795905044199318496207D-10/
      DATA aip2cs(9)/ + .376034439592373852439592002918D-11/
      DATA aip2cs(10)/ - .422321332718747538026564938968D-12/
      DATA aip2cs(11)/ + .513509454033657070919618754120D-13/
      DATA aip2cs(12)/ - .669095850390477595651681356676D-14/
      DATA aip2cs(13)/ + .926667545641290648239550724382D-15/
      DATA aip2cs(14)/ - .135514382416070576333397356591D-15/
      DATA aip2cs(15)/ + .208115496312830995299006549335D-16/
      DATA aip2cs(16)/ - .334116499159176856871277570256D-17/
      DATA aip2cs(17)/ + .558578584585924316868032946585D-18/
      DATA aip2cs(18)/ - .969219040152365247518658209109D-19/
      DATA aip2cs(19)/ + .174045700128893206465696557738D-19/
      DATA aip2cs(20)/ - .322640979731130400247846333098D-20/
      DATA aip2cs(21)/ + .616074471106625258533259618986D-21/
      DATA aip2cs(22)/ - .120936347982490059076420676266D-21/
      DATA aip2cs(23)/ + .243632763310138108261570095786D-22/
      DATA aip2cs(24)/ - .502914221497457468943403144533D-23/
      DATA aip2cs(25)/ + .106224175543635689495470626133D-23/
      DATA aip2cs(26)/ - .229284284895989241509856324266D-24/
      DATA aip2cs(27)/ + .505181733929503744986884778666D-25/
      DATA aip2cs(28)/ - .113498123714412404979793920000D-25/
      DATA aip2cs(29)/ + .259765565985606980698374144000D-26/
      DATA aip2cs(30)/ - .605124621542939506172231679999D-27/
      DATA aip2cs(31)/ + .143359777966772800720295253333D-27/
      DATA aip2cs(32)/ - .345147757060899986280721066666D-28/
      DATA aip2cs(33)/ + .843875190213646740427025066666D-29/
      DATA aip2cs(34)/ - .209396142298188169434453333333D-29/
      DATA aip2cs(35)/ + .527008873478945503182848000000D-30/
      DATA aip2cs(36)/ - .134457433014553385789030399999D-30/
      DATA aip2cs(37)/ + .347570964526601147340117333333D-31/
      DATA first/.TRUE./
!***FIRST EXECUTABLE STATEMENT  DAIE
      IF ( first ) THEN
        eta = 0.1*REAL(D1MACH(3))
        naif = INITDS(aifcs,13,eta)
        naig = INITDS(aigcs,13,eta)
        naip1 = INITDS(aip1cs,57,eta)
        naip2 = INITDS(aip2cs,37,eta)
!
        x3sml = eta**0.3333E0
        x32sml = 1.3104D0*x3sml**2
        xbig = D1MACH(2)**0.6666D0
      ENDIF
      first = .FALSE.
!
      IF ( X<(-1.0D0) ) THEN
        CALL D9AIMP(X,xm,theta)
        DAIE = xm*COS(theta)
        RETURN
!
      ELSEIF ( X<=1.0D0 ) THEN
        z = 0.0D0
        IF ( ABS(X)>x3sml ) z = X**3
        DAIE = 0.375D0 + (DCSEVL(z,aifcs,naif)-X*(0.25D0+DCSEVL(z,aigcs,naig)))
        IF ( X>x32sml ) DAIE = DAIE*EXP(2.0D0*X*SQRT(X)/3.0D0)
        RETURN
!
      ELSEIF ( X>4.0D0 ) THEN
!
        sqrtx = SQRT(X)
        z = -1.0D0
        IF ( X<xbig ) z = 16.0D0/(X*sqrtx) - 1.0D0
        DAIE = (0.28125D0+DCSEVL(z,aip2cs,naip2))/SQRT(sqrtx)
        GOTO 99999
      ENDIF
      sqrtx = SQRT(X)
      z = (16.D0/(X*sqrtx)-9.D0)/7.D0
      DAIE = (0.28125D0+DCSEVL(z,aip1cs,naip1))/SQRT(sqrtx)
      RETURN
!
99999 END FUNCTION DAIE
