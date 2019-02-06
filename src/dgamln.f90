!*==DGAMLN.f90  processed by SPAG 6.72Dc at 11:01 on  6 Feb 2019
!DECK DGAMLN
      DOUBLE PRECISION FUNCTION DGAMLN(Z,Ierr)
      IMPLICIT NONE
!*--DGAMLN5
!***BEGIN PROLOGUE  DGAMLN
!***SUBSIDIARY
!***PURPOSE  Compute the logarithm of the Gamma function
!***LIBRARY   SLATEC
!***CATEGORY  C7A
!***TYPE      DOUBLE PRECISION (GAMLN-S, DGAMLN-D)
!***KEYWORDS  LOGARITHM OF GAMMA FUNCTION
!***AUTHOR  Amos, D. E., (SNL)
!***DESCRIPTION
!
!               **** A DOUBLE PRECISION ROUTINE ****
!         DGAMLN COMPUTES THE NATURAL LOG OF THE GAMMA FUNCTION FOR
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
!         INPUT      Z IS D0UBLE PRECISION
!           Z      - ARGUMENT, Z.GT.0.0D0
!
!         OUTPUT      DGAMLN IS DOUBLE PRECISION
!           DGAMLN  - NATURAL LOG OF THE GAMMA FUNCTION AT Z.NE.0.0D0
!           IERR    - ERROR FLAG
!                     IERR=0, NORMAL RETURN, COMPUTATION COMPLETED
!                     IERR=1, Z.LE.0.0D0,    NO COMPUTATION
!
!
!***REFERENCES  COMPUTATION OF BESSEL FUNCTIONS OF COMPLEX ARGUMENT
!                 BY D. E. AMOS, SAND83-0083, MAY, 1983.
!***ROUTINES CALLED  D1MACH, I1MACH
!***REVISION HISTORY  (YYMMDD)
!   830501  DATE WRITTEN
!   830501  REVISION DATE from Version 3.2
!   910415  Prologue converted to Version 4.0 format.  (BAB)
!   920128  Category corrected.  (WRB)
!   921215  DGAMLN defined for Z negative.  (WRB)
!***END PROLOGUE  DGAMLN
      DOUBLE PRECISION cf , con , fln , fz , gln , rln , s , tlg , trm , tst , 
     &                 t1 , wdtol , Z , zdmy , zinc , zm , zmin , zp , zsq , 
     &                 D1MACH
      INTEGER i , Ierr , i1m , k , mz , nz , I1MACH
      DIMENSION cf(22) , gln(100)
!           LNGAMMA(N), N=1,100
      DATA gln(1) , gln(2) , gln(3) , gln(4) , gln(5) , gln(6) , gln(7) , gln(8)
     &     , gln(9) , gln(10) , gln(11) , gln(12) , gln(13) , gln(14) , gln(15)
     &     , gln(16) , gln(17) , gln(18) , gln(19) , gln(20) , gln(21) , gln(22)
     &     /0.00000000000000000D+00 , 0.00000000000000000D+00 , 
     &     6.93147180559945309D-01 , 1.79175946922805500D+00 , 
     &     3.17805383034794562D+00 , 4.78749174278204599D+00 , 
     &     6.57925121201010100D+00 , 8.52516136106541430D+00 , 
     &     1.06046029027452502D+01 , 1.28018274800814696D+01 , 
     &     1.51044125730755153D+01 , 1.75023078458738858D+01 , 
     &     1.99872144956618861D+01 , 2.25521638531234229D+01 , 
     &     2.51912211827386815D+01 , 2.78992713838408916D+01 , 
     &     3.06718601060806728D+01 , 3.35050734501368889D+01 , 
     &     3.63954452080330536D+01 , 3.93398841871994940D+01 , 
     &     4.23356164607534850D+01 , 4.53801388984769080D+01/
      DATA gln(23) , gln(24) , gln(25) , gln(26) , gln(27) , gln(28) , gln(29) , 
     &     gln(30) , gln(31) , gln(32) , gln(33) , gln(34) , gln(35) , gln(36) , 
     &     gln(37) , gln(38) , gln(39) , gln(40) , gln(41) , gln(42) , gln(43) , 
     &     gln(44)/4.84711813518352239D+01 , 5.16066755677643736D+01 , 
     &     5.47847293981123192D+01 , 5.80036052229805199D+01 , 
     &     6.12617017610020020D+01 , 6.45575386270063311D+01 , 
     &     6.78897431371815350D+01 , 7.12570389671680090D+01 , 
     &     7.46582363488301644D+01 , 7.80922235533153106D+01 , 
     &     8.15579594561150372D+01 , 8.50544670175815174D+01 , 
     &     8.85808275421976788D+01 , 9.21361756036870925D+01 , 
     &     9.57196945421432025D+01 , 9.93306124547874269D+01 , 
     &     1.02968198614513813D+02 , 1.06631760260643459D+02 , 
     &     1.10320639714757395D+02 , 1.14034211781461703D+02 , 
     &     1.17771881399745072D+02 , 1.21533081515438634D+02/
      DATA gln(45) , gln(46) , gln(47) , gln(48) , gln(49) , gln(50) , gln(51) , 
     &     gln(52) , gln(53) , gln(54) , gln(55) , gln(56) , gln(57) , gln(58) , 
     &     gln(59) , gln(60) , gln(61) , gln(62) , gln(63) , gln(64) , gln(65) , 
     &     gln(66)/1.25317271149356895D+02 , 1.29123933639127215D+02 , 
     &     1.32952575035616310D+02 , 1.36802722637326368D+02 , 
     &     1.40673923648234259D+02 , 1.44565743946344886D+02 , 
     &     1.48477766951773032D+02 , 1.52409592584497358D+02 , 
     &     1.56360836303078785D+02 , 1.60331128216630907D+02 , 
     &     1.64320112263195181D+02 , 1.68327445448427652D+02 , 
     &     1.72352797139162802D+02 , 1.76395848406997352D+02 , 
     &     1.80456291417543771D+02 , 1.84533828861449491D+02 , 
     &     1.88628173423671591D+02 , 1.92739047287844902D+02 , 
     &     1.96866181672889994D+02 , 2.01009316399281527D+02 , 
     &     2.05168199482641199D+02 , 2.09342586752536836D+02/
      DATA gln(67) , gln(68) , gln(69) , gln(70) , gln(71) , gln(72) , gln(73) , 
     &     gln(74) , gln(75) , gln(76) , gln(77) , gln(78) , gln(79) , gln(80) , 
     &     gln(81) , gln(82) , gln(83) , gln(84) , gln(85) , gln(86) , gln(87) , 
     &     gln(88)/2.13532241494563261D+02 , 2.17736934113954227D+02 , 
     &     2.21956441819130334D+02 , 2.26190548323727593D+02 , 
     &     2.30439043565776952D+02 , 2.34701723442818268D+02 , 
     &     2.38978389561834323D+02 , 2.43268849002982714D+02 , 
     &     2.47572914096186884D+02 , 2.51890402209723194D+02 , 
     &     2.56221135550009525D+02 , 2.60564940971863209D+02 , 
     &     2.64921649798552801D+02 , 2.69291097651019823D+02 , 
     &     2.73673124285693704D+02 , 2.78067573440366143D+02 , 
     &     2.82474292687630396D+02 , 2.86893133295426994D+02 , 
     &     2.91323950094270308D+02 , 2.95766601350760624D+02 , 
     &     3.00220948647014132D+02 , 3.04686856765668715D+02/
      DATA gln(89) , gln(90) , gln(91) , gln(92) , gln(93) , gln(94) , gln(95) , 
     &     gln(96) , gln(97) , gln(98) , gln(99) , gln(100)
     &     /3.09164193580146922D+02 , 3.13652829949879062D+02 , 
     &     3.18152639620209327D+02 , 3.22663499126726177D+02 , 
     &     3.27185287703775217D+02 , 3.31717887196928473D+02 , 
     &     3.36261181979198477D+02 , 3.40815058870799018D+02 , 
     &     3.45379407062266854D+02 , 3.49954118040770237D+02 , 
     &     3.54539085519440809D+02 , 3.59134205369575399D+02/
!             COEFFICIENTS OF ASYMPTOTIC EXPANSION
      DATA cf(1) , cf(2) , cf(3) , cf(4) , cf(5) , cf(6) , cf(7) , cf(8) , 
     &     cf(9) , cf(10) , cf(11) , cf(12) , cf(13) , cf(14) , cf(15) , cf(16)
     &     , cf(17) , cf(18) , cf(19) , cf(20) , cf(21) , cf(22)
     &     /8.33333333333333333D-02 , -2.77777777777777778D-03 , 
     &     7.93650793650793651D-04 , -5.95238095238095238D-04 , 
     &     8.41750841750841751D-04 , -1.91752691752691753D-03 , 
     &     6.41025641025641026D-03 , -2.95506535947712418D-02 , 
     &     1.79644372368830573D-01 , -1.39243221690590112D+00 , 
     &     1.34028640441683920D+01 , -1.56848284626002017D+02 , 
     &     2.19310333333333333D+03 , -3.61087712537249894D+04 , 
     &     6.91472268851313067D+05 , -1.52382215394074162D+07 , 
     &     3.82900751391414141D+08 , -1.08822660357843911D+10 , 
     &     3.47320283765002252D+11 , -1.23696021422692745D+13 , 
     &     4.88788064793079335D+14 , -2.13203339609193739D+16/
!
!             LN(2*PI)
      DATA con/1.83787706640934548D+00/
!
!***FIRST EXECUTABLE STATEMENT  DGAMLN
      Ierr = 0
      IF ( Z<=0.0D0 ) THEN
!
!
        DGAMLN = D1MACH(2)
        Ierr = 1
        GOTO 99999
      ELSE
        IF ( Z<=101.0D0 ) THEN
          nz = Z
          fz = Z - nz
          IF ( fz<=0.0D0 ) THEN
            IF ( nz<=100 ) THEN
              DGAMLN = gln(nz)
              RETURN
            ENDIF
          ENDIF
        ENDIF
        wdtol = D1MACH(4)
        wdtol = MAX(wdtol,0.5D-18)
        i1m = I1MACH(14)
        rln = D1MACH(5)*i1m
        fln = MIN(rln,20.0D0)
        fln = MAX(fln,3.0D0)
        fln = fln - 3.0D0
        zm = 1.8000D0 + 0.3875D0*fln
        mz = zm + 1
        zmin = mz
        zdmy = Z
        zinc = 0.0D0
        IF ( Z<zmin ) THEN
          zinc = zmin - nz
          zdmy = Z + zinc
        ENDIF
        zp = 1.0D0/zdmy
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
        IF ( zinc==0.0D0 ) THEN
          tlg = LOG(Z)
          DGAMLN = Z*(tlg-1.0D0) + 0.5D0*(con-tlg) + s
          RETURN
        ENDIF
      ENDIF
      zp = 1.0D0
      nz = zinc
      DO i = 1 , nz
        zp = zp*(Z+(i-1))
      ENDDO
      tlg = LOG(zdmy)
      DGAMLN = zdmy*(tlg-1.0D0) - LOG(zp) + 0.5D0*(con-tlg) + s
      RETURN
99999 END FUNCTION DGAMLN
