!DECK ASYIK
SUBROUTINE ASYIK(X,Fnu,Kode,Flgik,Ra,Arg,In,Y)
  IMPLICIT NONE
  !***BEGIN PROLOGUE  ASYIK
  !***SUBSIDIARY
  !***PURPOSE  Subsidiary to BESI and BESK
  !***LIBRARY   SLATEC
  !***TYPE      SINGLE PRECISION (ASYIK-S, DASYIK-D)
  !***AUTHOR  Amos, D. E., (SNLA)
  !***DESCRIPTION
  !
  !                    ASYIK computes Bessel functions I and K
  !                  for arguments X.GT.0.0 and orders FNU.GE.35
  !                  on FLGIK = 1 and FLGIK = -1 respectively.
  !
  !                                    INPUT
  !
  !      X    - argument, X.GT.0.0E0
  !      FNU  - order of first Bessel function
  !      KODE - a parameter to indicate the scaling option
  !             KODE=1 returns Y(I)=        I/SUB(FNU+I-1)/(X), I=1,IN
  !                    or      Y(I)=        K/SUB(FNU+I-1)/(X), I=1,IN
  !                    on FLGIK = 1.0E0 or FLGIK = -1.0E0
  !             KODE=2 returns Y(I)=EXP(-X)*I/SUB(FNU+I-1)/(X), I=1,IN
  !                    or      Y(I)=EXP( X)*K/SUB(FNU+I-1)/(X), I=1,IN
  !                    on FLGIK = 1.0E0 or FLGIK = -1.0E0
  !     FLGIK - selection parameter for I or K function
  !             FLGIK =  1.0E0 gives the I function
  !             FLGIK = -1.0E0 gives the K function
  !        RA - SQRT(1.+Z*Z), Z=X/FNU
  !       ARG - argument of the leading exponential
  !        IN - number of functions desired, IN=1 or 2
  !
  !                                    OUTPUT
  !
  !         Y - a vector whose first in components contain the sequence
  !
  !     Abstract
  !         ASYIK implements the uniform asymptotic expansion of
  !         the I and K Bessel functions for FNU.GE.35 and real
  !         X.GT.0.0E0. The forms are identical except for a change
  !         in sign of some of the terms. This change in sign is
  !         accomplished by means of the flag FLGIK = 1 or -1.
  !
  !***SEE ALSO  BESI, BESK
  !***ROUTINES CALLED  R1MACH
  !***REVISION HISTORY  (YYMMDD)
  !   750101  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  !   910408  Updated the AUTHOR section.  (WRB)
  !***END PROLOGUE  ASYIK
  !
  INTEGER In, j, jn, k, kk, Kode, l
  REAL ak, ap, Arg, c, coef, con, etx, Flgik, fn, Fnu, gln, Ra, &
    s1, s2, t, tol, t2, X, Y, z
  REAL R1MACH
  DIMENSION Y(*), c(65), con(2)
  SAVE con, c
  DATA con(1), con(2)/3.98942280401432678E-01, 1.25331413731550025E+00/
  DATA c(1), c(2), c(3), c(4), c(5), c(6), c(7), c(8), c(9), &
    c(10), c(11), c(12), c(13), c(14), c(15), c(16), c(17), &
    c(18), c(19), c(20), c(21), c(22), c(23), &
    c(24)/ - 2.08333333333333E-01, 1.25000000000000E-01, &
    3.34201388888889E-01, -4.01041666666667E-01, 7.03125000000000E-02, &
    -1.02581259645062E+00, 1.84646267361111E+00, &
    -8.91210937500000E-01, 7.32421875000000E-02, 4.66958442342625E+00, &
    -1.12070026162230E+01, 8.78912353515625E+00, &
    -2.36408691406250E+00, 1.12152099609375E-01, &
    -2.82120725582002E+01, 8.46362176746007E+01, &
    -9.18182415432400E+01, 4.25349987453885E+01, &
    -7.36879435947963E+00, 2.27108001708984E-01, 2.12570130039217E+02, &
    -7.65252468141182E+02, 1.05999045252800E+03, -6.99579627376133E+02/
  DATA c(25), c(26), c(27), c(28), c(29), c(30), c(31), c(32), &
    c(33), c(34), c(35), c(36), c(37), c(38), c(39), c(40), &
    c(41), c(42), c(43), c(44), c(45), c(46), c(47), &
    c(48)/2.18190511744212E+02, -2.64914304869516E+01, &
    5.72501420974731E-01, -1.91945766231841E+03, 8.06172218173731E+03, &
    -1.35865500064341E+04, 1.16553933368645E+04, &
    -5.30564697861340E+03, 1.20090291321635E+03, &
    -1.08090919788395E+02, 1.72772750258446E+00, 2.02042913309661E+04, &
    -9.69805983886375E+04, 1.92547001232532E+05, &
    -2.03400177280416E+05, 1.22200464983017E+05, &
    -4.11926549688976E+04, 7.10951430248936E+03, &
    -4.93915304773088E+02, 6.07404200127348E+00, &
    -2.42919187900551E+05, 1.31176361466298E+06, &
    -2.99801591853811E+06, 3.76327129765640E+06/
  DATA c(49), c(50), c(51), c(52), c(53), c(54), c(55), c(56), &
    c(57), c(58), c(59), c(60), c(61), c(62), c(63), c(64), &
    c(65)/ - 2.81356322658653E+06, 1.26836527332162E+06, &
    -3.31645172484564E+05, 4.52187689813627E+04, &
    -2.49983048181121E+03, 2.43805296995561E+01, 3.28446985307204E+06, &
    -1.97068191184322E+07, 5.09526024926646E+07, &
    -7.41051482115327E+07, 6.63445122747290E+07, &
    -3.75671766607634E+07, 1.32887671664218E+07, &
    -2.78561812808645E+06, 3.08186404612662E+05, &
    -1.38860897537170E+04, 1.10017140269247E+02/
  !***FIRST EXECUTABLE STATEMENT  ASYIK
  tol = R1MACH(3)
  tol = MAX(tol,1.0E-15)
  fn = Fnu
  z = (3.0E0-Flgik)/2.0E0
  kk = INT(z)
  DO jn = 1, In
    IF ( jn/=1 ) THEN
      fn = fn - Flgik
      z = X/fn
      Ra = SQRT(1.0E0+z*z)
      gln = LOG((1.0E0+Ra)/z)
      etx = Kode - 1
      t = Ra*(1.0E0-etx) + etx/(z+Ra)
      Arg = fn*(t-gln)*Flgik
    ENDIF
    coef = EXP(Arg)
    t = 1.0E0/Ra
    t2 = t*t
    t = t/fn
    t = SIGN(t,Flgik)
    s2 = 1.0E0
    ap = 1.0E0
    l = 0
    DO k = 2, 11
      l = l + 1
      s1 = c(l)
      DO j = 2, k
        l = l + 1
        s1 = s1*t2 + c(l)
      ENDDO
      ap = ap*t
      ak = ap*s1
      s2 = s2 + ak
      IF ( MAX(ABS(ak),ABS(ap))<tol ) EXIT
    ENDDO
    t = ABS(t)
    Y(jn) = s2*coef*SQRT(t)*con(kk)
  ENDDO
END SUBROUTINE ASYIK