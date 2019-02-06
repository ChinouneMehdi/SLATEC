!*==DGAMMA.f90  processed by SPAG 6.72Dc at 10:56 on  6 Feb 2019
!DECK DGAMMA
      DOUBLE PRECISION FUNCTION DGAMMA(X)
      IMPLICIT NONE
!*--DGAMMA5
!*** Start of declarations inserted by SPAG
      INTEGER i , INITDS , n , ngam
!*** End of declarations inserted by SPAG
!***BEGIN PROLOGUE  DGAMMA
!***PURPOSE  Compute the complete Gamma function.
!***LIBRARY   SLATEC (FNLIB)
!***CATEGORY  C7A
!***TYPE      DOUBLE PRECISION (GAMMA-S, DGAMMA-D, CGAMMA-C)
!***KEYWORDS  COMPLETE GAMMA FUNCTION, FNLIB, SPECIAL FUNCTIONS
!***AUTHOR  Fullerton, W., (LANL)
!***DESCRIPTION
!
! DGAMMA(X) calculates the double precision complete Gamma function
! for double precision argument X.
!
! Series for GAM        on the interval  0.          to  1.00000E+00
!                                        with weighted error   5.79E-32
!                                         log weighted error  31.24
!                               significant figures required  30.00
!                                    decimal places required  32.05
!
!***REFERENCES  (NONE)
!***ROUTINES CALLED  D1MACH, D9LGMC, DCSEVL, DGAMLM, INITDS, XERMSG
!***REVISION HISTORY  (YYMMDD)
!   770601  DATE WRITTEN
!   890531  Changed all specific intrinsics to generic.  (WRB)
!   890911  Removed unnecessary intrinsics.  (WRB)
!   890911  REVISION DATE from Version 3.2
!   891214  Prologue converted to Version 4.0 format.  (BAB)
!   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
!   920618  Removed space from variable name.  (RWC, WRB)
!***END PROLOGUE  DGAMMA
      DOUBLE PRECISION X , gamcs(42) , dxrel , pi , sinpiy , sq2pil , xmax , 
     &                 xmin , y , D9LGMC , DCSEVL , D1MACH
      LOGICAL first
!
      SAVE gamcs , pi , sq2pil , ngam , xmin , xmax , dxrel , first
      DATA gamcs(1)/ + .8571195590989331421920062399942D-2/
      DATA gamcs(2)/ + .4415381324841006757191315771652D-2/
      DATA gamcs(3)/ + .5685043681599363378632664588789D-1/
      DATA gamcs(4)/ - .4219835396418560501012500186624D-2/
      DATA gamcs(5)/ + .1326808181212460220584006796352D-2/
      DATA gamcs(6)/ - .1893024529798880432523947023886D-3/
      DATA gamcs(7)/ + .3606925327441245256578082217225D-4/
      DATA gamcs(8)/ - .6056761904460864218485548290365D-5/
      DATA gamcs(9)/ + .1055829546302283344731823509093D-5/
      DATA gamcs(10)/ - .1811967365542384048291855891166D-6/
      DATA gamcs(11)/ + .3117724964715322277790254593169D-7/
      DATA gamcs(12)/ - .5354219639019687140874081024347D-8/
      DATA gamcs(13)/ + .9193275519859588946887786825940D-9/
      DATA gamcs(14)/ - .1577941280288339761767423273953D-9/
      DATA gamcs(15)/ + .2707980622934954543266540433089D-10/
      DATA gamcs(16)/ - .4646818653825730144081661058933D-11/
      DATA gamcs(17)/ + .7973350192007419656460767175359D-12/
      DATA gamcs(18)/ - .1368078209830916025799499172309D-12/
      DATA gamcs(19)/ + .2347319486563800657233471771688D-13/
      DATA gamcs(20)/ - .4027432614949066932766570534699D-14/
      DATA gamcs(21)/ + .6910051747372100912138336975257D-15/
      DATA gamcs(22)/ - .1185584500221992907052387126192D-15/
      DATA gamcs(23)/ + .2034148542496373955201026051932D-16/
      DATA gamcs(24)/ - .3490054341717405849274012949108D-17/
      DATA gamcs(25)/ + .5987993856485305567135051066026D-18/
      DATA gamcs(26)/ - .1027378057872228074490069778431D-18/
      DATA gamcs(27)/ + .1762702816060529824942759660748D-19/
      DATA gamcs(28)/ - .3024320653735306260958772112042D-20/
      DATA gamcs(29)/ + .5188914660218397839717833550506D-21/
      DATA gamcs(30)/ - .8902770842456576692449251601066D-22/
      DATA gamcs(31)/ + .1527474068493342602274596891306D-22/
      DATA gamcs(32)/ - .2620731256187362900257328332799D-23/
      DATA gamcs(33)/ + .4496464047830538670331046570666D-24/
      DATA gamcs(34)/ - .7714712731336877911703901525333D-25/
      DATA gamcs(35)/ + .1323635453126044036486572714666D-25/
      DATA gamcs(36)/ - .2270999412942928816702313813333D-26/
      DATA gamcs(37)/ + .3896418998003991449320816639999D-27/
      DATA gamcs(38)/ - .6685198115125953327792127999999D-28/
      DATA gamcs(39)/ + .1146998663140024384347613866666D-28/
      DATA gamcs(40)/ - .1967938586345134677295103999999D-29/
      DATA gamcs(41)/ + .3376448816585338090334890666666D-30/
      DATA gamcs(42)/ - .5793070335782135784625493333333D-31/
      DATA pi/3.14159265358979323846264338327950D0/
      DATA sq2pil/0.91893853320467274178032973640562D0/
      DATA first/.TRUE./
!***FIRST EXECUTABLE STATEMENT  DGAMMA
      IF ( first ) THEN
        ngam = INITDS(gamcs,42,0.1*REAL(D1MACH(3)))
!
        CALL DGAMLM(xmin,xmax)
        dxrel = SQRT(D1MACH(4))
      ENDIF
      first = .FALSE.
!
      y = ABS(X)
      IF ( y>10.D0 ) THEN
!
! GAMMA(X) FOR ABS(X) .GT. 10.0.  RECALL Y = ABS(X).
!
        IF ( X>xmax ) CALL XERMSG('SLATEC','DGAMMA','X SO BIG GAMMA OVERFLOWS',
     &                            3,2)
!
        DGAMMA = 0.D0
        IF ( X<xmin ) CALL XERMSG('SLATEC','DGAMMA',
     &                            'X SO SMALL GAMMA UNDERFLOWS',2,1)
        IF ( X<xmin ) RETURN
!
        DGAMMA = EXP((y-0.5D0)*LOG(y)-y+sq2pil+D9LGMC(y))
        IF ( X>0.D0 ) RETURN
!
        IF ( ABS((X-AINT(X-0.5D0))/X)<dxrel ) CALL XERMSG('SLATEC','DGAMMA',
     &       'ANSWER LT HALF PRECISION, X TOO NEAR NEGATIVE INTEGER',1,1)
!
        sinpiy = SIN(pi*y)
        IF ( sinpiy==0.D0 ) CALL XERMSG('SLATEC','DGAMMA',
     &                                  'X IS A NEGATIVE INTEGER',4,2)
!
        DGAMMA = -pi/(y*sinpiy*DGAMMA)
        GOTO 99999
      ELSE
!
! COMPUTE GAMMA(X) FOR -XBND .LE. X .LE. XBND.  REDUCE INTERVAL AND FIND
! GAMMA(1+Y) FOR 0.0 .LE. Y .LT. 1.0 FIRST OF ALL.
!
        n = X
        IF ( X<0.D0 ) n = n - 1
        y = X - n
        n = n - 1
        DGAMMA = 0.9375D0 + DCSEVL(2.D0*y-1.D0,gamcs,ngam)
        IF ( n==0 ) RETURN
!
        IF ( n<=0 ) THEN
!
! COMPUTE GAMMA(X) FOR X .LT. 1.0
!
          n = -n
          IF ( X==0.D0 ) CALL XERMSG('SLATEC','DGAMMA','X IS 0',4,2)
          IF ( X<0.0.AND.X+n-2==0.D0 )
     &          CALL XERMSG('SLATEC','DGAMMA','X IS A NEGATIVE INTEGER',4,2)
          IF ( X<(-0.5D0).AND.ABS((X-AINT(X-0.5D0))/X)<dxrel )
     &          CALL XERMSG('SLATEC','DGAMMA',
     &         'ANSWER LT HALF PRECISION BECAUSE X TOO NEAR NEGATIVE INTEGER',1,
     &         1)
!
          DO i = 1 , n
            DGAMMA = DGAMMA/(X+i-1)
          ENDDO
          RETURN
        ENDIF
      ENDIF
!
! GAMMA(X) FOR X .GE. 2.0 AND X .LE. 10.0
!
      DO i = 1 , n
        DGAMMA = (y+i)*DGAMMA
      ENDDO
      RETURN
!
99999 END FUNCTION DGAMMA
