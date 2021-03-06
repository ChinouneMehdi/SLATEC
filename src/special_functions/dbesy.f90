!** DBESY
PURE SUBROUTINE DBESY(X,Fnu,N,Y)
  !> Implement forward recursion on the three term recursion
  !  relation for a sequence of non-negative order Bessel
  !  functions Y_{FNU+I-1}(X), I=1,...,N for REAL(SP), positive
  !  X and non-negative orders FNU.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  C10A3
  !***
  ! **Type:**      DOUBLE PRECISION (BESY-S, DBESY-D)
  !***
  ! **Keywords:**  SPECIAL FUNCTIONS, Y BESSEL FUNCTION
  !***
  ! **Author:**  Amos, D. E., (SNLA)
  !***
  ! **Description:**
  !
  !     Abstract  **** a double precision routine ****
  !         DBESY implements forward recursion on the three term
  !         recursion relation for a sequence of non-negative order Bessel
  !         functions Y_{FNU+I-1}(X), I=1,N for real X > 0.0D0 and
  !         non-negative orders FNU.  If FNU < NULIM, orders FNU and
  !         FNU+1 are obtained from DBSYNU which computes by a power
  !         series for X <= 2, the K Bessel function of an imaginary
  !         argument for 2 < X <= 20 and the asymptotic expansion for
  !         X > 20.
  !
  !         If FNU >= NULIM, the uniform asymptotic expansion is coded
  !         in DASYJY for orders FNU and FNU+1 to start the recursion.
  !         NULIM is 70 or 100 depending on whether N=1 or N >= 2.  An
  !         overflow test is made on the leading term of the asymptotic
  !         expansion before any extensive computation is done.
  !
  !         The maximum number of significant digits obtainable
  !         is the smaller of 14 and the number of digits carried in
  !         double precision arithmetic.
  !
  !     Description of Arguments
  !
  !         Input
  !           X      - X > 0.0D0
  !           FNU    - order of the initial Y function, FNU >= 0.0D0
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
  ! **Routines called:**  D1MACH, DASYJY, DBESY0, DBESY1, DBSYNU, DYAIRY,
  !                    I1MACH, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   800501  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890911  Removed unnecessary intrinsics.  (WRB)
  !   890911  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE service, ONLY : log10_radix_dp, tiny_dp, min_exp_dp
  !
  INTEGER, INTENT(IN) :: N
  REAL(DP), INTENT(IN) :: Fnu, X
  REAL(DP), INTENT(OUT) :: Y(N)
  !
  INTEGER :: i, iflw, j, nb, nd, nn, nud
  REAL(DP) :: azn, cn, dnu, elim, flgjy, fn, rann, s, s1, s2, tm, trx, w(2), &
    wk(7), w2n, xlim, xxn
  INTEGER, PARAMETER :: nulim(2) = [ 70, 100 ]
  !* FIRST EXECUTABLE STATEMENT  DBESY
  nn = -min_exp_dp
  elim = 2.303_DP*(nn*log10_radix_dp-3._DP)
  xlim = tiny_dp*1.E+3_DP
  IF( Fnu<0._DP ) THEN
    ERROR STOP 'DBESY : ORDER, FNU, < 0'
  ELSEIF( X<=0._DP ) THEN
    ERROR STOP 'DBESY : X <= 0'
  ELSEIF( X<xlim ) THEN
    ERROR STOP 'DBESY : OVERFLOW, FNU OR N TOO LARGE OR X TOO SMALL'
  ELSEIF( N<1 ) THEN
    ERROR STOP 'DBESY : N < 1'
  ELSE
    !
    !     ND IS A DUMMY VARIABLE FOR N
    !
    nd = N
    nud = INT(Fnu)
    dnu = Fnu - nud
    nn = MIN(2,nd)
    fn = Fnu + N - 1
    IF( fn<2._DP ) THEN
      !
      !     OVERFLOW TEST
      IF( fn<=1._DP ) GOTO 200
      IF( -fn*(LOG(X)-0.693_DP)<=elim ) GOTO 200
      ERROR STOP 'DBESY : OVERFLOW, FNU OR N TOO LARGE OR X TOO SMALL'
    ELSE
      !
      !     OVERFLOW TEST  (LEADING EXPONENTIAL OF ASYMPTOTIC EXPANSION)
      !     FOR THE LAST ORDER, FNU+N-1>=NULIM
      !
      xxn = X/fn
      w2n = 1._DP - xxn*xxn
      IF( w2n>0._DP ) THEN
        rann = SQRT(w2n)
        azn = LOG((1._DP+rann)/xxn) - rann
        cn = fn*azn
        IF( cn>elim ) THEN
          ERROR STOP 'DBESY : OVERFLOW, FNU OR N TOO LARGE OR X TOO SMALL'
        END IF
      END IF
      IF( nud<nulim(nn) ) THEN
        !
        IF( dnu/=0._DP ) THEN
          nb = 2
          IF( nud==0 .AND. nd==1 ) nb = 1
          CALL DBSYNU(X,dnu,nb,w)
          s1 = w(1)
          IF( nb==1 ) GOTO 20
          s2 = w(2)
        ELSE
          s1 = BESSEL_Y0(X)
          IF( nud==0 .AND. nd==1 ) GOTO 20
          s2 = BESSEL_Y1(X)
        END IF
        trx = 2._DP/X
        tm = (dnu+dnu+2._DP)/X
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
        flgjy = -1._DP
        CALL DASYJY(DYAIRY,X,Fnu,flgjy,nn,Y,wk,iflw)
        IF( iflw/=0 ) THEN
          ERROR STOP 'DBESY : OVERFLOW, FNU OR N TOO LARGE OR X TOO SMALL'
        ELSE
          IF( nn==1 ) RETURN
          trx = 2._DP/X
          tm = (Fnu+Fnu+2._DP)/X
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
  IF( dnu==0._DP ) THEN
    j = nud
    IF( j/=1 ) THEN
      j = j + 1
      Y(j) = BESSEL_Y0(X)
      IF( nd==1 ) RETURN
      j = j + 1
    END IF
    Y(j) = BESSEL_Y1(X)
    IF( nd==1 ) RETURN
    trx = 2._DP/X
    tm = trx
    GOTO 100
  ELSE
    CALL DBSYNU(X,Fnu,nd,Y)
    RETURN
  END IF

  RETURN
END SUBROUTINE DBESY