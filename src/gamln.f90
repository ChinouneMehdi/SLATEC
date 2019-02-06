!*==GAMLN.f90  processed by SPAG 6.72Dc at 11:01 on  6 Feb 2019
!DECK GAMLN
      REAL FUNCTION GAMLN(Z,Ierr)
      IMPLICIT NONE
!*--GAMLN5
!***BEGIN PROLOGUE  GAMLN
!***SUBSIDIARY
!***PURPOSE  Compute the logarithm of the Gamma function
!***LIBRARY   SLATEC
!***CATEGORY  C7A
!***TYPE      SINGLE PRECISION (GAMLN-S, DGAMLN-D)
!***KEYWORDS  LOGARITHM OF GAMMA FUNCTION
!***AUTHOR  Amos, D. E., (SNL)
!***DESCRIPTION
!
!         GAMLN COMPUTES THE NATURAL LOG OF THE GAMMA FUNCTION FOR
!         Z.GT.0.  THE ASYMPTOTIC EXPANSION IS USED TO GENERATE VALUES
!         GREATER THAN ZMIN WHICH ARE ADJUSTED BY THE RECURSION
!         G(Z+1)=Z*G(Z) FOR Z.LE.ZMIN.  THE FUNCTION WAS MADE AS
!         PORTABLE AS POSSIBLE BY COMPUTING ZMIN FROM THE NUMBER OF BASE
!         10 DIGITS IN A WORD, RLN=MAX(-ALOG10(R1MACH(4)),0.5E-18)
!         LIMITED TO 18 DIGITS OF (RELATIVE) ACCURACY.
!
!         SINCE INTEGER ARGUMENTS ARE COMMON, A TABLE LOOK UP ON 100
!         VALUES IS USED FOR SPEED OF EXECUTION.
!
!     DESCRIPTION OF ARGUMENTS
!
!         INPUT
!           Z      - REAL ARGUMENT, Z.GT.0.0E0
!
!         OUTPUT
!           GAMLN  - NATURAL LOG OF THE GAMMA FUNCTION AT Z
!           IERR   - ERROR FLAG
!                    IERR=0, NORMAL RETURN, COMPUTATION COMPLETED
!                    IERR=1, Z.LE.0.0E0,    NO COMPUTATION
!
!***REFERENCES  COMPUTATION OF BESSEL FUNCTIONS OF COMPLEX ARGUMENT
!                 BY D. E. AMOS, SAND83-0083, MAY, 1983.
!***ROUTINES CALLED  I1MACH, R1MACH
!***REVISION HISTORY  (YYMMDD)
!   830501  DATE WRITTEN
!   830501  REVISION DATE from Version 3.2
!   910415  Prologue converted to Version 4.0 format.  (BAB)
!   920128  Category corrected.  (WRB)
!   921215  GAMLN defined for Z negative.  (WRB)
!***END PROLOGUE  GAMLN
!
      INTEGER i , i1m , k , mz , nz , Ierr , I1MACH
      REAL cf , con , fln , fz , gln , rln , s , tlg , trm , tst , t1 , wdtol , 
     &     Z , zdmy , zinc , zm , zmin , zp , zsq
      REAL R1MACH
      DIMENSION cf(22) , gln(100)
!           LNGAMMA(N), N=1,100
      DATA gln(1) , gln(2) , gln(3) , gln(4) , gln(5) , gln(6) , gln(7) , gln(8)
     &     , gln(9) , gln(10) , gln(11) , gln(12) , gln(13) , gln(14) , gln(15)
     &     , gln(16) , gln(17) , gln(18) , gln(19) , gln(20) , gln(21) , gln(22)
     &     /0.00000000000000000E+00 , 0.00000000000000000E+00 , 
     &     6.93147180559945309E-01 , 1.79175946922805500E+00 , 
     &     3.17805383034794562E+00 , 4.78749174278204599E+00 , 
     &     6.57925121201010100E+00 , 8.52516136106541430E+00 , 
     &     1.06046029027452502E+01 , 1.28018274800814696E+01 , 
     &     1.51044125730755153E+01 , 1.75023078458738858E+01 , 
     &     1.99872144956618861E+01 , 2.25521638531234229E+01 , 
     &     2.51912211827386815E+01 , 2.78992713838408916E+01 , 
     &     3.06718601060806728E+01 , 3.35050734501368889E+01 , 
     &     3.63954452080330536E+01 , 3.93398841871994940E+01 , 
     &     4.23356164607534850E+01 , 4.53801388984769080E+01/
      DATA gln(23) , gln(24) , gln(25) , gln(26) , gln(27) , gln(28) , gln(29) , 
     &     gln(30) , gln(31) , gln(32) , gln(33) , gln(34) , gln(35) , gln(36) , 
     &     gln(37) , gln(38) , gln(39) , gln(40) , gln(41) , gln(42) , gln(43) , 
     &     gln(44)/4.84711813518352239E+01 , 5.16066755677643736E+01 , 
     &     5.47847293981123192E+01 , 5.80036052229805199E+01 , 
     &     6.12617017610020020E+01 , 6.45575386270063311E+01 , 
     &     6.78897431371815350E+01 , 7.12570389671680090E+01 , 
     &     7.46582363488301644E+01 , 7.80922235533153106E+01 , 
     &     8.15579594561150372E+01 , 8.50544670175815174E+01 , 
     &     8.85808275421976788E+01 , 9.21361756036870925E+01 , 
     &     9.57196945421432025E+01 , 9.93306124547874269E+01 , 
     &     1.02968198614513813E+02 , 1.06631760260643459E+02 , 
     &     1.10320639714757395E+02 , 1.14034211781461703E+02 , 
     &     1.17771881399745072E+02 , 1.21533081515438634E+02/
      DATA gln(45) , gln(46) , gln(47) , gln(48) , gln(49) , gln(50) , gln(51) , 
     &     gln(52) , gln(53) , gln(54) , gln(55) , gln(56) , gln(57) , gln(58) , 
     &     gln(59) , gln(60) , gln(61) , gln(62) , gln(63) , gln(64) , gln(65) , 
     &     gln(66)/1.25317271149356895E+02 , 1.29123933639127215E+02 , 
     &     1.32952575035616310E+02 , 1.36802722637326368E+02 , 
     &     1.40673923648234259E+02 , 1.44565743946344886E+02 , 
     &     1.48477766951773032E+02 , 1.52409592584497358E+02 , 
     &     1.56360836303078785E+02 , 1.60331128216630907E+02 , 
     &     1.64320112263195181E+02 , 1.68327445448427652E+02 , 
     &     1.72352797139162802E+02 , 1.76395848406997352E+02 , 
     &     1.80456291417543771E+02 , 1.84533828861449491E+02 , 
     &     1.88628173423671591E+02 , 1.92739047287844902E+02 , 
     &     1.96866181672889994E+02 , 2.01009316399281527E+02 , 
     &     2.05168199482641199E+02 , 2.09342586752536836E+02/
      DATA gln(67) , gln(68) , gln(69) , gln(70) , gln(71) , gln(72) , gln(73) , 
     &     gln(74) , gln(75) , gln(76) , gln(77) , gln(78) , gln(79) , gln(80) , 
     &     gln(81) , gln(82) , gln(83) , gln(84) , gln(85) , gln(86) , gln(87) , 
     &     gln(88)/2.13532241494563261E+02 , 2.17736934113954227E+02 , 
     &     2.21956441819130334E+02 , 2.26190548323727593E+02 , 
     &     2.30439043565776952E+02 , 2.34701723442818268E+02 , 
     &     2.38978389561834323E+02 , 2.43268849002982714E+02 , 
     &     2.47572914096186884E+02 , 2.51890402209723194E+02 , 
     &     2.56221135550009525E+02 , 2.60564940971863209E+02 , 
     &     2.64921649798552801E+02 , 2.69291097651019823E+02 , 
     &     2.73673124285693704E+02 , 2.78067573440366143E+02 , 
     &     2.82474292687630396E+02 , 2.86893133295426994E+02 , 
     &     2.91323950094270308E+02 , 2.95766601350760624E+02 , 
     &     3.00220948647014132E+02 , 3.04686856765668715E+02/
      DATA gln(89) , gln(90) , gln(91) , gln(92) , gln(93) , gln(94) , gln(95) , 
     &     gln(96) , gln(97) , gln(98) , gln(99) , gln(100)
     &     /3.09164193580146922E+02 , 3.13652829949879062E+02 , 
     &     3.18152639620209327E+02 , 3.22663499126726177E+02 , 
     &     3.27185287703775217E+02 , 3.31717887196928473E+02 , 
     &     3.36261181979198477E+02 , 3.40815058870799018E+02 , 
     &     3.45379407062266854E+02 , 3.49954118040770237E+02 , 
     &     3.54539085519440809E+02 , 3.59134205369575399E+02/
!             COEFFICIENTS OF ASYMPTOTIC EXPANSION
      DATA cf(1) , cf(2) , cf(3) , cf(4) , cf(5) , cf(6) , cf(7) , cf(8) , 
     &     cf(9) , cf(10) , cf(11) , cf(12) , cf(13) , cf(14) , cf(15) , cf(16)
     &     , cf(17) , cf(18) , cf(19) , cf(20) , cf(21) , cf(22)
     &     /8.33333333333333333E-02 , -2.77777777777777778E-03 , 
     &     7.93650793650793651E-04 , -5.95238095238095238E-04 , 
     &     8.41750841750841751E-04 , -1.91752691752691753E-03 , 
     &     6.41025641025641026E-03 , -2.95506535947712418E-02 , 
     &     1.79644372368830573E-01 , -1.39243221690590112E+00 , 
     &     1.34028640441683920E+01 , -1.56848284626002017E+02 , 
     &     2.19310333333333333E+03 , -3.61087712537249894E+04 , 
     &     6.91472268851313067E+05 , -1.52382215394074162E+07 , 
     &     3.82900751391414141E+08 , -1.08822660357843911E+10 , 
     &     3.47320283765002252E+11 , -1.23696021422692745E+13 , 
     &     4.88788064793079335E+14 , -2.13203339609193739E+16/
!
!             LN(2*PI)
      DATA con/1.83787706640934548E+00/
!
!***FIRST EXECUTABLE STATEMENT  GAMLN
      Ierr = 0
      IF ( Z<=0.0E0 ) THEN
!
!
        GAMLN = R1MACH(2)
        Ierr = 1
        GOTO 99999
      ELSE
        IF ( Z<=101.0E0 ) THEN
          nz = Z
          fz = Z - nz
          IF ( fz<=0.0E0 ) THEN
            IF ( nz<=100 ) THEN
              GAMLN = gln(nz)
              RETURN
            ENDIF
          ENDIF
        ENDIF
        wdtol = R1MACH(4)
        wdtol = MAX(wdtol,0.5E-18)
        i1m = I1MACH(11)
        rln = R1MACH(5)*i1m
        fln = MIN(rln,20.0E0)
        fln = MAX(fln,3.0E0)
        fln = fln - 3.0E0
        zm = 1.8000E0 + 0.3875E0*fln
        mz = zm + 1
        zmin = mz
        zdmy = Z
        zinc = 0.0E0
        IF ( Z<zmin ) THEN
          zinc = zmin - nz
          zdmy = Z + zinc
        ENDIF
        zp = 1.0E0/zdmy
        t1 = cf(1)*zp
        s = t1
        IF ( zp>=wdtol ) THEN
          zsq = zp*zp
          tst = t1*wdtol
          DO k = 2 , 22
            zp = zp*zsq
            trm = cf(k)*zp
            IF ( ABS(trm)<tst ) EXIT
            s = s + trm
          ENDDO
        ENDIF
        IF ( zinc==0.0E0 ) THEN
          tlg = ALOG(Z)
          GAMLN = Z*(tlg-1.0E0) + 0.5E0*(con-tlg) + s
          RETURN
        ENDIF
      ENDIF
      zp = 1.0E0
      nz = zinc
      DO i = 1 , nz
        zp = zp*(Z+(i-1))
      ENDDO
      tlg = ALOG(zdmy)
      GAMLN = zdmy*(tlg-1.0E0) - ALOG(zp) + 0.5E0*(con-tlg) + s
      RETURN
99999 END FUNCTION GAMLN
