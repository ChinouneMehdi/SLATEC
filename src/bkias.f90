!*==BKIAS.f90  processed by SPAG 6.72Dc at 11:01 on  6 Feb 2019
!DECK BKIAS
      SUBROUTINE BKIAS(X,N,Ktrms,T,Ans,Ind,Ms,Gmrn,H,Ierr)
      IMPLICIT NONE
!*--BKIAS5
!***BEGIN PROLOGUE  BKIAS
!***SUBSIDIARY
!***PURPOSE  Subsidiary to BSKIN
!***LIBRARY   SLATEC
!***TYPE      SINGLE PRECISION (BKIAS-S, DBKIAS-D)
!***AUTHOR  Amos, D. E., (SNLA)
!***DESCRIPTION
!
!     BKIAS computes repeated integrals of the K0 Bessel function
!     by the asymptotic expansion
!
!***SEE ALSO  BSKIN
!***ROUTINES CALLED  BDIFF, GAMRN, HKSEQ, R1MACH
!***REVISION HISTORY  (YYMMDD)
!   820601  DATE WRITTEN
!   890531  Changed all specific intrinsics to generic.  (WRB)
!   891214  Prologue converted to Version 4.0 format.  (BAB)
!   900328  Added TYPE section.  (WRB)
!   910722  Updated AUTHOR section.  (ALS)
!***END PROLOGUE  BKIAS
      INTEGER i , ii , Ind , j , jmi , jn , k , kk , km , Ktrms , mm , mp , Ms , 
     &        N , Ierr
      REAL Ans , b , bnd , den1 , den2 , den3 , er , err , fj , fk , fln , fm1 , 
     &     Gmrn , g1 , gs , H , hn , hrtpi , rat , rg1 , rxp , rz , rzx , s , 
     &     ss , sumi , sumj , T , tol , v , w , X , xp , z
      REAL GAMRN , R1MACH
      DIMENSION b(120) , xp(16) , s(31) , H(*) , v(52) , w(52) , T(50) , bnd(15)
      SAVE b , bnd , hrtpi
!-----------------------------------------------------------------------
!             COEFFICIENTS OF POLYNOMIAL P(J-1,X), J=1,15
!-----------------------------------------------------------------------
      DATA b(1) , b(2) , b(3) , b(4) , b(5) , b(6) , b(7) , b(8) , b(9) , 
     &     b(10) , b(11) , b(12) , b(13) , b(14) , b(15) , b(16) , b(17) , 
     &     b(18) , b(19) , b(20) , b(21) , b(22) , b(23) , 
     &     b(24)/1.00000000000000000E+00 , 1.00000000000000000E+00 , 
     &     -2.00000000000000000E+00 , 1.00000000000000000E+00 , 
     &     -8.00000000000000000E+00 , 6.00000000000000000E+00 , 
     &     1.00000000000000000E+00 , -2.20000000000000000E+01 , 
     &     5.80000000000000000E+01 , -2.40000000000000000E+01 , 
     &     1.00000000000000000E+00 , -5.20000000000000000E+01 , 
     &     3.28000000000000000E+02 , -4.44000000000000000E+02 , 
     &     1.20000000000000000E+02 , 1.00000000000000000E+00 , 
     &     -1.14000000000000000E+02 , 1.45200000000000000E+03 , 
     &     -4.40000000000000000E+03 , 3.70800000000000000E+03 , 
     &     -7.20000000000000000E+02 , 1.00000000000000000E+00 , 
     &     -2.40000000000000000E+02 , 5.61000000000000000E+03/
      DATA b(25) , b(26) , b(27) , b(28) , b(29) , b(30) , b(31) , b(32) , 
     &     b(33) , b(34) , b(35) , b(36) , b(37) , b(38) , b(39) , b(40) , 
     &     b(41) , b(42) , b(43) , b(44) , b(45) , b(46) , b(47) , 
     &     b(48)/ - 3.21200000000000000E+04 , 5.81400000000000000E+04 , 
     &     -3.39840000000000000E+04 , 5.04000000000000000E+03 , 
     &     1.00000000000000000E+00 , -4.94000000000000000E+02 , 
     &     1.99500000000000000E+04 , -1.95800000000000000E+05 , 
     &     6.44020000000000000E+05 , -7.85304000000000000E+05 , 
     &     3.41136000000000000E+05 , -4.03200000000000000E+04 , 
     &     1.00000000000000000E+00 , -1.00400000000000000E+03 , 
     &     6.72600000000000000E+04 , -1.06250000000000000E+06 , 
     &     5.76550000000000000E+06 , -1.24400640000000000E+07 , 
     &     1.10262960000000000E+07 , -3.73392000000000000E+06 , 
     &     3.62880000000000000E+05 , 1.00000000000000000E+00 , 
     &     -2.02600000000000000E+03 , 2.18848000000000000E+05/
      DATA b(49) , b(50) , b(51) , b(52) , b(53) , b(54) , b(55) , b(56) , 
     &     b(57) , b(58) , b(59) , b(60) , b(61) , b(62) , b(63) , b(64) , 
     &     b(65) , b(66) , b(67) , b(68) , b(69) , b(70) , b(71) , 
     &     b(72)/ - 5.32616000000000000E+06 , 4.47650000000000000E+07 , 
     &     -1.55357384000000000E+08 , 2.38904904000000000E+08 , 
     &     -1.62186912000000000E+08 , 4.43390400000000000E+07 , 
     &     -3.62880000000000000E+06 , 1.00000000000000000E+00 , 
     &     -4.07200000000000000E+03 , 6.95038000000000000E+05 , 
     &     -2.52439040000000000E+07 , 3.14369720000000000E+08 , 
     &     -1.64838430400000000E+09 , 4.00269508800000000E+09 , 
     &     -4.64216395200000000E+09 , 2.50748121600000000E+09 , 
     &     -5.68356480000000000E+08 , 3.99168000000000000E+07 , 
     &     1.00000000000000000E+00 , -8.16600000000000000E+03 , 
     &     2.17062600000000000E+06 , -1.14876376000000000E+08 , 
     &     2.05148277600000000E+09 , -1.55489607840000000E+10/
      DATA b(73) , b(74) , b(75) , b(76) , b(77) , b(78) , b(79) , b(80) , 
     &     b(81) , b(82) , b(83) , b(84) , b(85) , b(86) , b(87) , b(88) , 
     &     b(89) , b(90) , b(91) , b(92) , b(93) , b(94) , b(95) , 
     &     b(96)/5.60413987840000000E+10 , -1.01180433024000000E+11 , 
     &     9.21997902240000000E+10 , -4.07883018240000000E+10 , 
     &     7.82771904000000000E+09 , -4.79001600000000000E+08 , 
     &     1.00000000000000000E+00 , -1.63560000000000000E+04 , 
     &     6.69969600000000000E+06 , -5.07259276000000000E+08 , 
     &     1.26698177760000000E+10 , -1.34323420224000000E+11 , 
     &     6.87720046384000000E+11 , -1.81818864230400000E+12 , 
     &     2.54986547342400000E+12 , -1.88307966182400000E+12 , 
     &     6.97929436800000000E+11 , -1.15336085760000000E+11 , 
     &     6.22702080000000000E+09 , 1.00000000000000000E+00 , 
     &     -3.27380000000000000E+04 , 2.05079880000000000E+07 , 
     &     -2.18982980800000000E+09 , 7.50160522280000000E+10/
      DATA b(97) , b(98) , b(99) , b(100) , b(101) , b(102) , b(103) , b(104) , 
     &     b(105) , b(106) , b(107) , b(108) , b(109) , b(110) , b(111) , b(112)
     &     , b(113) , b(114) , b(115) , b(116) , b(117) , b(118)
     &     / - 1.08467651241600000E+12 , 7.63483214939200000E+12 , 
     &     -2.82999100661120000E+13 , 5.74943734645920000E+13 , 
     &     -6.47283751398720000E+13 , 3.96895780558080000E+13 , 
     &     -1.25509040179200000E+13 , 1.81099255680000000E+12 , 
     &     -8.71782912000000000E+10 , 1.00000000000000000E+00 , 
     &     -6.55040000000000000E+04 , 6.24078900000000000E+07 , 
     &     -9.29252692000000000E+09 , 4.29826006340000000E+11 , 
     &     -8.30844432796800000E+12 , 7.83913848313120000E+13 , 
     &     -3.94365587815520000E+14 , 1.11174747256968000E+15 , 
     &     -1.79717122069056000E+15 , 1.66642448627145600E+15 , 
     &     -8.65023253219584000E+14 , 2.36908271543040000E+14/
      DATA b(119) , b(120)/ - 3.01963769856000000E+13 , 1.30767436800000000E+12/
!-----------------------------------------------------------------------
!             BOUNDS B(M,K) , K=M-3
!-----------------------------------------------------------------------
      DATA bnd(1) , bnd(2) , bnd(3) , bnd(4) , bnd(5) , bnd(6) , bnd(7) , bnd(8)
     &     , bnd(9) , bnd(10) , bnd(11) , bnd(12) , bnd(13) , bnd(14) , bnd(15)
     &     /1.0E0 , 1.0E0 , 1.0E0 , 1.0E0 , 3.10E0 , 5.18E0 , 11.7E0 , 29.8E0 , 
     &     90.4E0 , 297.0E0 , 1070.0E0 , 4290.0E0 , 18100.0E0 , 84700.0E0 , 
     &     408000.0E0/
      DATA hrtpi/8.86226925452758014E-01/
!
!***FIRST EXECUTABLE STATEMENT  BKIAS
      Ierr = 0
      tol = MAX(R1MACH(4),1.0E-18)
      fln = N
      rz = 1.0E0/(X+fln)
      rzx = X*rz
      z = 0.5E0*(X+fln)
      IF ( Ind<=1 ) Gmrn = GAMRN(z)
      gs = hrtpi*Gmrn
      g1 = gs + gs
      rg1 = 1.0E0/g1
      Gmrn = (rz+rz)/Gmrn
      IF ( Ind>1 ) GOTO 200
!-----------------------------------------------------------------------
!     EVALUATE ERROR FOR M=MS
!-----------------------------------------------------------------------
      hn = 0.5E0*fln
      den2 = Ktrms + Ktrms + N
      den3 = den2 - 2.0E0
      den1 = X + den2
      err = rg1*(X+X)/(den1-1.0E0)
      IF ( N/=0 ) rat = 1.0E0/(fln*fln)
      IF ( Ktrms/=0 ) THEN
        fj = Ktrms
        rat = 0.25E0/(hrtpi*den3*SQRT(fj))
      ENDIF
      err = err*rat
      fj = -3.0E0
      DO j = 1 , 15
        IF ( j<=5 ) err = err/den1
        fm1 = MAX(1.0E0,fj)
        fj = fj + 1.0E0
        er = bnd(j)*err
        IF ( Ktrms==0 ) THEN
          er = er*(1.0E0+hn/fm1)
          IF ( er<tol ) GOTO 100
          IF ( j>=5 ) err = err/fln
        ELSE
          er = er/fm1
          IF ( er<tol ) GOTO 100
          IF ( j>=5 ) err = err/den3
        ENDIF
      ENDDO
      Ierr = 2
      GOTO 99999
 100  Ms = j
 200  mm = Ms + Ms
      mp = mm + 1
!-----------------------------------------------------------------------
!     H(K)=(-Z)**(K)*(PSI(K-1,Z)-PSI(K-1,Z+0.5))/GAMMA(K) , K=1,2,...,MM
!-----------------------------------------------------------------------
      IF ( Ind>1 ) THEN
        rat = z/(z-0.5E0)
        rxp = rat
        DO i = 1 , mm
          H(i) = rxp*(1.0E0-H(i))
          rxp = rxp*rat
        ENDDO
      ELSE
        CALL HKSEQ(z,mm,H,Ierr)
      ENDIF
!-----------------------------------------------------------------------
!     SCALED S SEQUENCE
!-----------------------------------------------------------------------
      s(1) = 1.0E0
      fk = 1.0E0
      DO k = 2 , mp
        ss = 0.0E0
        km = k - 1
        i = km
        DO j = 1 , km
          ss = ss + s(j)*H(i)
          i = i - 1
        ENDDO
        s(k) = ss/fk
        fk = fk + 1.0E0
      ENDDO
!-----------------------------------------------------------------------
!     SCALED S-TILDA SEQUENCE
!-----------------------------------------------------------------------
      IF ( Ktrms/=0 ) THEN
        fk = 0.0E0
        ss = 0.0E0
        rg1 = rg1/z
        DO k = 1 , Ktrms
          v(k) = z/(z+fk)
          w(k) = T(k)*v(k)
          ss = ss + w(k)
          fk = fk + 1.0E0
        ENDDO
        s(1) = s(1) - ss*rg1
        DO i = 2 , mp
          ss = 0.0E0
          DO k = 1 , Ktrms
            w(k) = w(k)*v(k)
            ss = ss + w(k)
          ENDDO
          s(i) = s(i) - ss*rg1
        ENDDO
      ENDIF
!-----------------------------------------------------------------------
!     SUM ON J
!-----------------------------------------------------------------------
      sumj = 0.0E0
      jn = 1
      rxp = 1.0E0
      xp(1) = 1.0E0
      DO j = 1 , Ms
        jn = jn + j - 1
        xp(j+1) = xp(j)*rzx
        rxp = rxp*rz
!-----------------------------------------------------------------------
!     SUM ON I
!-----------------------------------------------------------------------
        sumi = 0.0E0
        ii = jn
        DO i = 1 , j
          jmi = j - i + 1
          kk = j + i + 1
          DO k = 1 , jmi
            v(k) = s(kk)*xp(k)
            kk = kk + 1
          ENDDO
          CALL BDIFF(jmi,v)
          sumi = sumi + b(ii)*v(jmi)*xp(i+1)
          ii = ii + 1
        ENDDO
        sumj = sumj + sumi*rxp
      ENDDO
      Ans = gs*(s(1)-sumj)
      RETURN
99999 END SUBROUTINE BKIAS
