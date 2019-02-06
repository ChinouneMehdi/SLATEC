!*==RAND.f90  processed by SPAG 6.72Dc at 10:56 on  6 Feb 2019
!DECK RAND
      FUNCTION RAND(R)
      IMPLICIT NONE
!*--RAND5
!*** Start of declarations inserted by SPAG
      INTEGER ia0 , ia1 , ia1ma0 , ic , ix0 , ix1 , iy0 , iy1
      REAL R , RAND
!*** End of declarations inserted by SPAG
!***BEGIN PROLOGUE  RAND
!***PURPOSE  Generate a uniformly distributed random number.
!***LIBRARY   SLATEC (FNLIB)
!***CATEGORY  L6A21
!***TYPE      SINGLE PRECISION (RAND-S)
!***KEYWORDS  FNLIB, RANDOM NUMBER, SPECIAL FUNCTIONS, UNIFORM
!***AUTHOR  Fullerton, W., (LANL)
!***DESCRIPTION
!
!      This pseudo-random number generator is portable among a wide
! variety of computers.  RAND(R) undoubtedly is not as good as many
! readily available installation dependent versions, and so this
! routine is not recommended for widespread usage.  Its redeeming
! feature is that the exact same random numbers (to within final round-
! off error) can be generated from machine to machine.  Thus, programs
! that make use of random numbers can be easily transported to and
! checked in a new environment.
!
!      The random numbers are generated by the linear congruential
! method described, e.g., by Knuth in Seminumerical Methods (p.9),
! Addison-Wesley, 1969.  Given the I-th number of a pseudo-random
! sequence, the I+1 -st number is generated from
!             X(I+1) = (A*X(I) + C) MOD M,
! where here M = 2**22 = 4194304, C = 1731 and several suitable values
! of the multiplier A are discussed below.  Both the multiplier A and
! random number X are represented in double precision as two 11-bit
! words.  The constants are chosen so that the period is the maximum
! possible, 4194304.
!
!      In order that the same numbers be generated from machine to
! machine, it is necessary that 23-bit integers be reducible modulo
! 2**11 exactly, that 23-bit integers be added exactly, and that 11-bit
! integers be multiplied exactly.  Furthermore, if the restart option
! is used (where R is between 0 and 1), then the product R*2**22 =
! R*4194304 must be correct to the nearest integer.
!
!      The first four random numbers should be .0004127026,
! .6750836372, .1614754200, and .9086198807.  The tenth random number
! is .5527787209, and the hundredth is .3600893021 .  The thousandth
! number should be .2176990509 .
!
!      In order to generate several effectively independent sequences
! with the same generator, it is necessary to know the random number
! for several widely spaced calls.  The I-th random number times 2**22,
! where I=K*P/8 and P is the period of the sequence (P = 2**22), is
! still of the form L*P/8.  In particular we find the I-th random
! number multiplied by 2**22 is given by
! I   =  0  1*P/8  2*P/8  3*P/8  4*P/8  5*P/8  6*P/8  7*P/8  8*P/8
! RAND=  0  5*P/8  2*P/8  7*P/8  4*P/8  1*P/8  6*P/8  3*P/8  0
! Thus the 4*P/8 = 2097152 random number is 2097152/2**22.
!
!      Several multipliers have been subjected to the spectral test
! (see Knuth, p. 82).  Four suitable multipliers roughly in order of
! goodness according to the spectral test are
!    3146757 = 1536*2048 + 1029 = 2**21 + 2**20 + 2**10 + 5
!    2098181 = 1024*2048 + 1029 = 2**21 + 2**10 + 5
!    3146245 = 1536*2048 +  517 = 2**21 + 2**20 + 2**9 + 5
!    2776669 = 1355*2048 + 1629 = 5**9 + 7**7 + 1
!
!      In the table below LOG10(NU(I)) gives roughly the number of
! random decimal digits in the random numbers considered I at a time.
! C is the primary measure of goodness.  In both cases bigger is better.
!
!                   LOG10 NU(I)              C(I)
!       A       I=2  I=3  I=4  I=5    I=2  I=3  I=4  I=5
!
!    3146757    3.3  2.0  1.6  1.3    3.1  1.3  4.6  2.6
!    2098181    3.3  2.0  1.6  1.2    3.2  1.3  4.6  1.7
!    3146245    3.3  2.2  1.5  1.1    3.2  4.2  1.1  0.4
!    2776669    3.3  2.1  1.6  1.3    2.5  2.0  1.9  2.6
!   Best
!    Possible   3.3  2.3  1.7  1.4    3.6  5.9  9.7  14.9
!
!             Input Argument --
! R      If R=0., the next random number of the sequence is generated.
!        If R .LT. 0., the last generated number will be returned for
!          possible use in a restart procedure.
!        If R .GT. 0., the sequence of random numbers will start with
!          the seed R mod 1.  This seed is also returned as the value of
!          RAND provided the arithmetic is done exactly.
!
!             Output Value --
! RAND   a pseudo-random number between 0. and 1.
!
!***REFERENCES  (NONE)
!***ROUTINES CALLED  (NONE)
!***REVISION HISTORY  (YYMMDD)
!   770401  DATE WRITTEN
!   890531  Changed all specific intrinsics to generic.  (WRB)
!   890531  REVISION DATE from Version 3.2
!   891214  Prologue converted to Version 4.0 format.  (BAB)
!***END PROLOGUE  RAND
      SAVE ia1 , ia0 , ia1ma0 , ic , ix1 , ix0
      DATA ia1 , ia0 , ia1ma0/1536 , 1029 , 507/
      DATA ic/1731/
      DATA ix1 , ix0/0 , 0/
!***FIRST EXECUTABLE STATEMENT  RAND
      IF ( R>=0. ) THEN
        IF ( R>0. ) THEN
!
          ix1 = MOD(R,1.)*4194304. + 0.5
          ix0 = MOD(ix1,2048)
          ix1 = (ix1-ix0)/2048
        ELSE
!
!           A*X = 2**22*IA1*IX1 + 2**11*(IA1*IX1 + (IA1-IA0)*(IX0-IX1)
!                   + IA0*IX0) + IA0*IX0
!
          iy0 = ia0*ix0
          iy1 = ia1*ix1 + ia1ma0*(ix0-ix1) + iy0
          iy0 = iy0 + ic
          ix0 = MOD(iy0,2048)
          iy1 = iy1 + (iy0-ix0)/2048
          ix1 = MOD(iy1,2048)
        ENDIF
      ENDIF
!
      RAND = ix1*2048 + ix0
      RAND = RAND/4194304.
      RETURN
!
      END FUNCTION RAND
