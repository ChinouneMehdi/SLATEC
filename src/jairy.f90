!*==JAIRY.f90  processed by SPAG 6.72Dc at 11:01 on  6 Feb 2019
!DECK JAIRY
      SUBROUTINE JAIRY(X,Rx,C,Ai,Dai)
      IMPLICIT NONE
!*--JAIRY5
!***BEGIN PROLOGUE  JAIRY
!***SUBSIDIARY
!***PURPOSE  Subsidiary to BESJ and BESY
!***LIBRARY   SLATEC
!***TYPE      SINGLE PRECISION (JAIRY-S, DJAIRY-D)
!***AUTHOR  Amos, D. E., (SNLA)
!           Daniel, S. L., (SNLA)
!           Weston, M. K., (SNLA)
!***DESCRIPTION
!
!                  JAIRY computes the Airy function AI(X)
!                   and its derivative DAI(X) for ASYJY
!
!                                   INPUT
!
!         X - Argument, computed by ASYJY, X unrestricted
!        RX - RX=SQRT(ABS(X)), computed by ASYJY
!         C - C=2.*(ABS(X)**1.5)/3., computed by ASYJY
!
!                                  OUTPUT
!
!        AI - Value of function AI(X)
!       DAI - Value of the derivative DAI(X)
!
!***SEE ALSO  BESJ, BESY
!***ROUTINES CALLED  (NONE)
!***REVISION HISTORY  (YYMMDD)
!   750101  DATE WRITTEN
!   891009  Removed unreferenced variable.  (WRB)
!   891214  Prologue converted to Version 4.0 format.  (BAB)
!   900328  Added TYPE section.  (WRB)
!   910408  Updated the AUTHOR section.  (WRB)
!***END PROLOGUE  JAIRY
!
      INTEGER i , j , m1 , m1d , m2 , m2d , m3 , m3d , m4 , m4d , n1 , n1d , 
     &        n2 , n2d , n3 , n3d , n4 , n4d
      REAL a , Ai , ajn , ajp , ak1 , ak2 , ak3 , b , C , ccv , con2 , con3 , 
     &     con4 , con5 , cv , da , Dai , dajn , dajp , dak1 , dak2 , dak3 , db , 
     &     ec , e1 , e2 , fpi12 , f1 , f2 , rtrx , Rx , scv , t , temp1 , 
     &     temp2 , tt , X
      DIMENSION ajp(19) , ajn(19) , a(15) , b(15)
      DIMENSION ak1(14) , ak2(23) , ak3(14)
      DIMENSION dajp(19) , dajn(19) , da(15) , db(15)
      DIMENSION dak1(14) , dak2(24) , dak3(14)
      SAVE n1 , n2 , n3 , n4 , m1 , m2 , m3 , m4 , fpi12 , con2 , con3 , con4 , 
     &  con5 , ak1 , ak2 , ak3 , ajp , ajn , a , b , n1d , n2d , n3d , n4d , 
     &  m1d , m2d , m3d , m4d , dak1 , dak2 , dak3 , dajp , dajn , da , db
      DATA n1 , n2 , n3 , n4/14 , 23 , 19 , 15/
      DATA m1 , m2 , m3 , m4/12 , 21 , 17 , 13/
      DATA fpi12 , con2 , con3 , con4 , con5/1.30899693899575E+00 , 
     &     5.03154716196777E+00 , 3.80004589867293E-01 , 8.33333333333333E-01 , 
     &     8.66025403784439E-01/
      DATA ak1(1) , ak1(2) , ak1(3) , ak1(4) , ak1(5) , ak1(6) , ak1(7) , ak1(8)
     &     , ak1(9) , ak1(10) , ak1(11) , ak1(12) , ak1(13) , ak1(14)
     &     /2.20423090987793E-01 , -1.25290242787700E-01 , 
     &     1.03881163359194E-02 , 8.22844152006343E-04 , -2.34614345891226E-04 , 
     &     1.63824280172116E-05 , 3.06902589573189E-07 , -1.29621999359332E-07 , 
     &     8.22908158823668E-09 , 1.53963968623298E-11 , -3.39165465615682E-11 , 
     &     2.03253257423626E-12 , -1.10679546097884E-14 , -5.16169497785080E-15/
      DATA ak2(1) , ak2(2) , ak2(3) , ak2(4) , ak2(5) , ak2(6) , ak2(7) , ak2(8)
     &     , ak2(9) , ak2(10) , ak2(11) , ak2(12) , ak2(13) , ak2(14) , ak2(15)
     &     , ak2(16) , ak2(17) , ak2(18) , ak2(19) , ak2(20) , ak2(21) , ak2(22)
     &     , ak2(23)/2.74366150869598E-01 , 5.39790969736903E-03 , 
     &     -1.57339220621190E-03 , 4.27427528248750E-04 , 
     &     -1.12124917399925E-04 , 2.88763171318904E-05 , 
     &     -7.36804225370554E-06 , 1.87290209741024E-06 , 
     &     -4.75892793962291E-07 , 1.21130416955909E-07 , 
     &     -3.09245374270614E-08 , 7.92454705282654E-09 , 
     &     -2.03902447167914E-09 , 5.26863056595742E-10 , 
     &     -1.36704767639569E-10 , 3.56141039013708E-11 , 
     &     -9.31388296548430E-12 , 2.44464450473635E-12 , 
     &     -6.43840261990955E-13 , 1.70106030559349E-13 , 
     &     -4.50760104503281E-14 , 1.19774799164811E-14 , -3.19077040865066E-15/
      DATA ak3(1) , ak3(2) , ak3(3) , ak3(4) , ak3(5) , ak3(6) , ak3(7) , ak3(8)
     &     , ak3(9) , ak3(10) , ak3(11) , ak3(12) , ak3(13) , ak3(14)
     &     /2.80271447340791E-01 , -1.78127042844379E-03 , 
     &     4.03422579628999E-05 , -1.63249965269003E-06 , 9.21181482476768E-08 , 
     &     -6.52294330229155E-09 , 5.47138404576546E-10 , 
     &     -5.24408251800260E-11 , 5.60477904117209E-12 , 
     &     -6.56375244639313E-13 , 8.31285761966247E-14 , 
     &     -1.12705134691063E-14 , 1.62267976598129E-15 , -2.46480324312426E-16/
      DATA ajp(1) , ajp(2) , ajp(3) , ajp(4) , ajp(5) , ajp(6) , ajp(7) , ajp(8)
     &     , ajp(9) , ajp(10) , ajp(11) , ajp(12) , ajp(13) , ajp(14) , ajp(15)
     &     , ajp(16) , ajp(17) , ajp(18) , ajp(19)/7.78952966437581E-02 , 
     &     -1.84356363456801E-01 , 3.01412605216174E-02 , 3.05342724277608E-02 , 
     &     -4.95424702513079E-03 , -1.72749552563952E-03 , 
     &     2.43137637839190E-04 , 5.04564777517082E-05 , -6.16316582695208E-06 , 
     &     -9.03986745510768E-07 , 9.70243778355884E-08 , 1.09639453305205E-08 , 
     &     -1.04716330588766E-09 , -9.60359441344646E-11 , 
     &     8.25358789454134E-12 , 6.36123439018768E-13 , -4.96629614116015E-14 , 
     &     -3.29810288929615E-15 , 2.35798252031104E-16/
      DATA ajn(1) , ajn(2) , ajn(3) , ajn(4) , ajn(5) , ajn(6) , ajn(7) , ajn(8)
     &     , ajn(9) , ajn(10) , ajn(11) , ajn(12) , ajn(13) , ajn(14) , ajn(15)
     &     , ajn(16) , ajn(17) , ajn(18) , ajn(19)/3.80497887617242E-02 , 
     &     -2.45319541845546E-01 , 1.65820623702696E-01 , 7.49330045818789E-02 , 
     &     -2.63476288106641E-02 , -5.92535597304981E-03 , 
     &     1.44744409589804E-03 , 2.18311831322215E-04 , -4.10662077680304E-05 , 
     &     -4.66874994171766E-06 , 7.15218807277160E-07 , 6.52964770854633E-08 , 
     &     -8.44284027565946E-09 , -6.44186158976978E-10 , 
     &     7.20802286505285E-11 , 4.72465431717846E-12 , -4.66022632547045E-13 , 
     &     -2.67762710389189E-14 , 2.36161316570019E-15/
      DATA a(1) , a(2) , a(3) , a(4) , a(5) , a(6) , a(7) , a(8) , a(9) , 
     &     a(10) , a(11) , a(12) , a(13) , a(14) , a(15)/4.90275424742791E-01 , 
     &     1.57647277946204E-03 , -9.66195963140306E-05 , 1.35916080268815E-07 , 
     &     2.98157342654859E-07 , -1.86824767559979E-08 , 
     &     -1.03685737667141E-09 , 3.28660818434328E-10 , 
     &     -2.57091410632780E-11 , -2.32357655300677E-12 , 
     &     9.57523279048255E-13 , -1.20340828049719E-13 , 
     &     -2.90907716770715E-15 , 4.55656454580149E-15 , -9.99003874810259E-16/
      DATA b(1) , b(2) , b(3) , b(4) , b(5) , b(6) , b(7) , b(8) , b(9) , 
     &     b(10) , b(11) , b(12) , b(13) , b(14) , b(15)/2.78593552803079E-01 , 
     &     -3.52915691882584E-03 , -2.31149677384994E-05 , 
     &     4.71317842263560E-06 , -1.12415907931333E-07 , 
     &     -2.00100301184339E-08 , 2.60948075302193E-09 , 
     &     -3.55098136101216E-11 , -3.50849978423875E-11 , 
     &     5.83007187954202E-12 , -2.04644828753326E-13 , 
     &     -1.10529179476742E-13 , 2.87724778038775E-14 , 
     &     -2.88205111009939E-15 , -3.32656311696166E-16/
      DATA n1d , n2d , n3d , n4d/14 , 24 , 19 , 15/
      DATA m1d , m2d , m3d , m4d/12 , 22 , 17 , 13/
      DATA dak1(1) , dak1(2) , dak1(3) , dak1(4) , dak1(5) , dak1(6) , dak1(7) , 
     &     dak1(8) , dak1(9) , dak1(10) , dak1(11) , dak1(12) , dak1(13) , 
     &     dak1(14)/2.04567842307887E-01 , -6.61322739905664E-02 , 
     &     -8.49845800989287E-03 , 3.12183491556289E-03 , 
     &     -2.70016489829432E-04 , -6.35636298679387E-06 , 
     &     3.02397712409509E-06 , -2.18311195330088E-07 , 
     &     -5.36194289332826E-10 , 1.13098035622310E-09 , 
     &     -7.43023834629073E-11 , 4.28804170826891E-13 , 2.23810925754539E-13 , 
     &     -1.39140135641182E-14/
      DATA dak2(1) , dak2(2) , dak2(3) , dak2(4) , dak2(5) , dak2(6) , dak2(7) , 
     &     dak2(8) , dak2(9) , dak2(10) , dak2(11) , dak2(12) , dak2(13) , 
     &     dak2(14) , dak2(15) , dak2(16) , dak2(17) , dak2(18) , dak2(19) , 
     &     dak2(20) , dak2(21) , dak2(22) , dak2(23) , dak2(24)
     &     /2.93332343883230E-01 , -8.06196784743112E-03 , 
     &     2.42540172333140E-03 , -6.82297548850235E-04 , 1.85786427751181E-04 , 
     &     -4.97457447684059E-05 , 1.32090681239497E-05 , 
     &     -3.49528240444943E-06 , 9.24362451078835E-07 , 
     &     -2.44732671521867E-07 , 6.49307837648910E-08 , 
     &     -1.72717621501538E-08 , 4.60725763604656E-09 , 
     &     -1.23249055291550E-09 , 3.30620409488102E-10 , 
     &     -8.89252099772401E-11 , 2.39773319878298E-11 , 
     &     -6.48013921153450E-12 , 1.75510132023731E-12 , 
     &     -4.76303829833637E-13 , 1.29498241100810E-13 , 
     &     -3.52679622210430E-14 , 9.62005151585923E-15 , -2.62786914342292E-15/
      DATA dak3(1) , dak3(2) , dak3(3) , dak3(4) , dak3(5) , dak3(6) , dak3(7) , 
     &     dak3(8) , dak3(9) , dak3(10) , dak3(11) , dak3(12) , dak3(13) , 
     &     dak3(14)/2.84675828811349E-01 , 2.53073072619080E-03 , 
     &     -4.83481130337976E-05 , 1.84907283946343E-06 , 
     &     -1.01418491178576E-07 , 7.05925634457153E-09 , 
     &     -5.85325291400382E-10 , 5.56357688831339E-11 , 
     &     -5.90889094779500E-12 , 6.88574353784436E-13 , 
     &     -8.68588256452194E-14 , 1.17374762617213E-14 , 
     &     -1.68523146510923E-15 , 2.55374773097056E-16/
      DATA dajp(1) , dajp(2) , dajp(3) , dajp(4) , dajp(5) , dajp(6) , dajp(7) , 
     &     dajp(8) , dajp(9) , dajp(10) , dajp(11) , dajp(12) , dajp(13) , 
     &     dajp(14) , dajp(15) , dajp(16) , dajp(17) , dajp(18) , dajp(19)
     &     /6.53219131311457E-02 , -1.20262933688823E-01 , 
     &     9.78010236263823E-03 , 1.67948429230505E-02 , -1.97146140182132E-03 , 
     &     -8.45560295098867E-04 , 9.42889620701976E-05 , 2.25827860945475E-05 , 
     &     -2.29067870915987E-06 , -3.76343991136919E-07 , 
     &     3.45663933559565E-08 , 4.29611332003007E-09 , -3.58673691214989E-10 , 
     &     -3.57245881361895E-11 , 2.72696091066336E-12 , 2.26120653095771E-13 , 
     &     -1.58763205238303E-14 , -1.12604374485125E-15 , 7.31327529515367E-17/
      DATA dajn(1) , dajn(2) , dajn(3) , dajn(4) , dajn(5) , dajn(6) , dajn(7) , 
     &     dajn(8) , dajn(9) , dajn(10) , dajn(11) , dajn(12) , dajn(13) , 
     &     dajn(14) , dajn(15) , dajn(16) , dajn(17) , dajn(18) , dajn(19)
     &     /1.08594539632967E-02 , 8.53313194857091E-02 , 
     &     -3.15277068113058E-01 , -8.78420725294257E-02 , 
     &     5.53251906976048E-02 , 9.41674060503241E-03 , -3.32187026018996E-03 , 
     &     -4.11157343156826E-04 , 1.01297326891346E-04 , 9.87633682208396E-06 , 
     &     -1.87312969812393E-06 , -1.50798500131468E-07 , 
     &     2.32687669525394E-08 , 1.59599917419225E-09 , -2.07665922668385E-10 , 
     &     -1.24103350500302E-11 , 1.39631765331043E-12 , 7.39400971155740E-14 , 
     &     -7.32887475627500E-15/
      DATA da(1) , da(2) , da(3) , da(4) , da(5) , da(6) , da(7) , da(8) , 
     &     da(9) , da(10) , da(11) , da(12) , da(13) , da(14) , da(15)
     &     /4.91627321104601E-01 , 3.11164930427489E-03 , 8.23140762854081E-05 , 
     &     -4.61769776172142E-06 , -6.13158880534626E-08 , 
     &     2.87295804656520E-08 , -1.81959715372117E-09 , 
     &     -1.44752826642035E-10 , 4.53724043420422E-11 , 
     &     -3.99655065847223E-12 , -3.24089119830323E-13 , 
     &     1.62098952568741E-13 , -2.40765247974057E-14 , 1.69384811284491E-16 , 
     &     8.17900786477396E-16/
      DATA db(1) , db(2) , db(3) , db(4) , db(5) , db(6) , db(7) , db(8) , 
     &     db(9) , db(10) , db(11) , db(12) , db(13) , db(14) , db(15)
     &     / - 2.77571356944231E-01 , 4.44212833419920E-03 , 
     &     -8.42328522190089E-05 , -2.58040318418710E-06 , 
     &     3.42389720217621E-07 , -6.24286894709776E-09 , 
     &     -2.36377836844577E-09 , 3.16991042656673E-10 , 
     &     -4.40995691658191E-12 , -5.18674221093575E-12 , 
     &     9.64874015137022E-13 , -4.90190576608710E-14 , 
     &     -1.77253430678112E-14 , 5.55950610442662E-15 , -7.11793337579530E-16/
!***FIRST EXECUTABLE STATEMENT  JAIRY
      IF ( X<0.0E0 ) THEN
!
        IF ( C>5.0E0 ) THEN
!
          t = 10.0E0/C - 1.0E0
          tt = t + t
          j = n4
          f1 = a(j)
          e1 = b(j)
          f2 = 0.0E0
          e2 = 0.0E0
          DO i = 1 , m4
            j = j - 1
            temp1 = f1
            temp2 = e1
            f1 = tt*f1 - f2 + a(j)
            e1 = tt*e1 - e2 + b(j)
            f2 = temp1
            e2 = temp2
          ENDDO
          temp1 = t*f1 - f2 + a(1)
          temp2 = t*e1 - e2 + b(1)
          rtrx = SQRT(Rx)
          cv = C - fpi12
          ccv = COS(cv)
          scv = SIN(cv)
          Ai = (temp1*ccv-temp2*scv)/rtrx
          j = n4d
          f1 = da(j)
          e1 = db(j)
          f2 = 0.0E0
          e2 = 0.0E0
          DO i = 1 , m4d
            j = j - 1
            temp1 = f1
            temp2 = e1
            f1 = tt*f1 - f2 + da(j)
            e1 = tt*e1 - e2 + db(j)
            f2 = temp1
            e2 = temp2
          ENDDO
          temp1 = t*f1 - f2 + da(1)
          temp2 = t*e1 - e2 + db(1)
          e1 = ccv*con5 + 0.5E0*scv
          e2 = scv*con5 - 0.5E0*ccv
          Dai = (temp1*e1-temp2*e2)*rtrx
          GOTO 99999
        ENDIF
      ELSEIF ( C>5.0E0 ) THEN
!
        t = 10.0E0/C - 1.0E0
        tt = t + t
        j = n1
        f1 = ak3(j)
        f2 = 0.0E0
        DO i = 1 , m1
          j = j - 1
          temp1 = f1
          f1 = tt*f1 - f2 + ak3(j)
          f2 = temp1
        ENDDO
        rtrx = SQRT(Rx)
        ec = EXP(-C)
        Ai = ec*(t*f1-f2+ak3(1))/rtrx
        j = n1d
        f1 = dak3(j)
        f2 = 0.0E0
        DO i = 1 , m1d
          j = j - 1
          temp1 = f1
          f1 = tt*f1 - f2 + dak3(j)
          f2 = temp1
        ENDDO
        Dai = -rtrx*ec*(t*f1-f2+dak3(1))
        RETURN
      ELSEIF ( X>1.20E0 ) THEN
!
        t = (X+X-con2)*con3
        tt = t + t
        j = n2
        f1 = ak2(j)
        f2 = 0.0E0
        DO i = 1 , m2
          j = j - 1
          temp1 = f1
          f1 = tt*f1 - f2 + ak2(j)
          f2 = temp1
        ENDDO
        rtrx = SQRT(Rx)
        ec = EXP(-C)
        Ai = ec*(t*f1-f2+ak2(1))/rtrx
        j = n2d
        f1 = dak2(j)
        f2 = 0.0E0
        DO i = 1 , m2d
          j = j - 1
          temp1 = f1
          f1 = tt*f1 - f2 + dak2(j)
          f2 = temp1
        ENDDO
        Dai = -ec*(t*f1-f2+dak2(1))*rtrx
        RETURN
      ELSE
        t = (X+X-1.2E0)*con4
        tt = t + t
        j = n1
        f1 = ak1(j)
        f2 = 0.0E0
        DO i = 1 , m1
          j = j - 1
          temp1 = f1
          f1 = tt*f1 - f2 + ak1(j)
          f2 = temp1
        ENDDO
        Ai = t*f1 - f2 + ak1(1)
!
        j = n1d
        f1 = dak1(j)
        f2 = 0.0E0
        DO i = 1 , m1d
          j = j - 1
          temp1 = f1
          f1 = tt*f1 - f2 + dak1(j)
          f2 = temp1
        ENDDO
        Dai = -(t*f1-f2+dak1(1))
        RETURN
      ENDIF
      t = 0.4E0*C - 1.0E0
      tt = t + t
      j = n3
      f1 = ajp(j)
      e1 = ajn(j)
      f2 = 0.0E0
      e2 = 0.0E0
      DO i = 1 , m3
        j = j - 1
        temp1 = f1
        temp2 = e1
        f1 = tt*f1 - f2 + ajp(j)
        e1 = tt*e1 - e2 + ajn(j)
        f2 = temp1
        e2 = temp2
      ENDDO
      Ai = (t*e1-e2+ajn(1)) - X*(t*f1-f2+ajp(1))
      j = n3d
      f1 = dajp(j)
      e1 = dajn(j)
      f2 = 0.0E0
      e2 = 0.0E0
      DO i = 1 , m3d
        j = j - 1
        temp1 = f1
        temp2 = e1
        f1 = tt*f1 - f2 + dajp(j)
        e1 = tt*e1 - e2 + dajn(j)
        f2 = temp1
        e2 = temp2
      ENDDO
      Dai = X*X*(t*f1-f2+dajp(1)) + (t*e1-e2+dajn(1))
      RETURN
99999 END SUBROUTINE JAIRY
