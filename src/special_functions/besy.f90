!** BESY
PURE SUBROUTINE BESY(X,Fnu,N,Y)
  !> Implement forward recursion on the three term recursion
  !  relation for a sequence of non-negative order Bessel
  !  functions Y_{FNU+I-1}(X), I=1,...,N for REAL(SP), positive
  !  X and non-negative orders FNU.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  C10A3
  !***
  ! **Type:**      SINGLE PRECISION (BESY-S, DBESY-D)
  !***
  ! **Keywords:**  SPECIAL FUNCTIONS, Y BESSEL FUNCTION
  !***
  ! **Author:**  Amos, D. E., (SNLA)
  !***
  ! **Description:**
  !
  !     Abstract
  !         BESY implements forward recursion on the three term
  !         recursion relation for a sequence of non-negative order Bessel
  !         functions Y_{FNU+I-1}(X), I=1,N for real X > 0.0E0 and
  !         non-negative orders FNU.  If FNU < NULIM, orders FNU and
  !         FNU+1 are obtained from BESYNU which computes by a power
  !         series for X <= 2, the K Bessel function of an imaginary
  !         argument for 2 < X <= 20 and the asymptotic expansion for
  !         X > 20.
  !
  !         If FNU >= NULIM, the uniform asymptotic expansion is coded
  !         in ASYJY for orders FNU and FNU+1 to start the recursion.
  !         NULIM is 70 or 100 depending on whether N=1 or N >= 2.  An
  !         overflow test is made on the leading term of the asymptotic
  !         expansion before any extensive computation is done.
  !
  !     Description of Arguments
  !
  !         Input
  !           X      - X > 0.0E0
  !           FNU    - order of the initial Y function, FNU >= 0.0E0
  !           N      - number of members in the sequence, N >= 1
  !
  !         Output
  !           Y      - a vector whose first N components contain values
  !                    for the sequence Y(I)=Y_{FNU+I-1}(X), I=1,N.
  !
  !     Error Conditions
  !         Improper input arguments - a fatal error
  !         Overflow - a fatal error
  !
  !***
  ! **References:**  F. W. J. Olver, Tables of Bessel Functions of Moderate
  !                 or Large Orders, NPL Mathematical Tables 6, Her
  !                 Majesty's Stationery Office, London, 1962.
  !               N. M. Temme, On the numerical evaluation of the modified
  !                 Bessel function of the third kind, Journal of
  !                 Computational Physics 19, (1975), pp. 324-337.
  !               N. M. Temme, On the numerical evaluation of the ordinary
  !                 Bessel function of the second kind, Journal of
  !                 Computational Physics 21, (1976), pp. 343-350.
  !***
  ! **Routines called:**  ASYJY, BESY0, BESY1, BESYNU, I1MACH, R1MACH,
  !                    XERMSG, YAIRY

  !* REVISION HISTORY  (YYMMDD)
  !   800501  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900326  Removed duplicate information from DESCRIPTION section.  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE service, ONLY : min_exp_sp, log10_radix_sp, tiny_sp
  !
  INTEGER, INTENT(IN) :: N
  REAL(SP), INTENT(IN) :: Fnu, X
  REAL(SP), INTENT(OUT) :: Y(N)
  !
  INTEGER :: i, iflw, j, nb, nd, nn, nud
  REAL(SP) :: azn, cn, dnu, elim, flgjy, fn, rann, s, s1, s2, tm, &
    trx, w(2), wk(7), w2n, xlim, xxn
  INTEGER, PARAMETER :: nulim(2) = [ 70, 100 ]
  !* FIRST EXECUTABLE STATEMENT  BESY
  nn = -min_exp_sp
  elim = 2.303_SP*(nn*log10_radix_sp-3._SP)
  xlim = tiny_sp*1.E+3_SP
  IF( Fnu<0._SP ) THEN
    ERROR STOP 'BESY : ORDER, FNU < 0'
  ELSEIF( X<=0._SP ) THEN
    ERROR STOP 'BESY : X <= 0'
  ELSEIF( X<xlim ) THEN
    ERROR STOP 'BESY : OVERFLOW, FNU OR N TOO LARGE OR X TOO SMALL'
  ELSEIF( N<1 ) THEN
    ERROR STOP 'BESY : N < 1'
  ELSE
    !     ND IS A DUMMY VARIABLE FOR N
    nd = N
    nud = INT(Fnu)
    dnu = Fnu - nud
    nn = MIN(2,nd)
    fn = Fnu + N - 1
    IF( fn<2._SP ) THEN
      !     OVERFLOW TEST
      IF( fn<=1._SP ) GOTO 200
      IF( -fn*(LOG(X)-0.693E0_SP)<=elim ) GOTO 200
      ERROR STOP 'BESY : OVERFLOW, FNU OR N TOO LARGE OR X TOO SMALL'
    ELSE
      !     OVERFLOW TEST  (LEADING EXPONENTIAL OF ASYMPTOTIC EXPANSION)
      !     FOR THE LAST ORDER, FNU+N-1>=NULIM
      xxn = X/fn
      w2n = 1._SP - xxn*xxn
      IF( w2n>0._SP ) THEN
        rann = SQRT(w2n)
        azn = LOG((1._SP+rann)/xxn) - rann
        cn = fn*azn
        IF( cn>elim ) THEN
          ERROR STOP 'BESY : OVERFLOW, FNU OR N TOO LARGE OR X TOO SMALL'
        END IF
      END IF
      IF( nud<nulim(nn) ) THEN
        !
        IF( dnu/=0._SP ) THEN
          nb = 2
          IF( nud==0 .AND. nd==1 ) nb = 1
          CALL BESYNU(X,dnu,nb,w)
          s1 = w(1)
          IF( nb==1 ) GOTO 20
          s2 = w(2)
        ELSE
          s1 = BESSEL_Y0(X)
          IF( nud==0 .AND. nd==1 ) GOTO 20
          s2 = BESSEL_Y1(X)
        END IF
        trx = 2._SP/X
        tm = (dnu+dnu+2._SP)/X
        !     FORWARD RECUR FROM DNU TO FNU+1 TO GET Y(1) AND Y(2)
        IF( nd==1 ) nud = nud - 1
        IF( nud>0 ) THEN
          DO i = 1, nud
            s = s2
            s2 = tm*s2 - s1
            s1 = s
            tm = tm + trx
          END DO
          IF( nd==1 ) s1 = s2
        ELSEIF( nd<=1 ) THEN
          s1 = s2
        END IF
      ELSE
        !
        !     ASYMPTOTIC EXPANSION FOR ORDERS FNU AND FNU+1>=NULIM
        !
        flgjy = -1._SP
        CALL ASYJY(YAIRY,X,Fnu,flgjy,nn,Y,wk,iflw)
        IF( iflw/=0 ) THEN
          ERROR STOP 'BESY : OVERFLOW, FNU OR N TOO LARGE OR X TOO SMALL'
        ELSE
          IF( nn==1 ) RETURN
          trx = 2._SP/X
          tm = (Fnu+Fnu+2._SP)/X
          GOTO 100
        END IF
      END IF
      20  Y(1) = s1
      IF( nd==1 ) RETURN
      Y(2) = s2
    END IF
  END IF
  100 CONTINUE
  IF( nd==2 ) RETURN
  !     FORWARD RECUR FROM FNU+2 TO FNU+N-1
  DO i = 3, nd
    Y(i) = tm*Y(i-1) - Y(i-2)
    tm = tm + trx
  END DO
  RETURN
  200 CONTINUE
  IF( dnu==0._SP ) THEN
    j = nud
    IF( j/=1 ) THEN
      j = j + 1
      Y(j) = BESSEL_Y0(X)
      IF( nd==1 ) RETURN
      j = j + 1
    END IF
    Y(j) = BESSEL_Y1(X)
    IF( nd==1 ) RETURN
    trx = 2._SP/X
    tm = trx
    GOTO 100
  ELSE
    CALL BESYNU(X,Fnu,nd,Y)
    RETURN
  END IF

  RETURN
END SUBROUTINE BESY