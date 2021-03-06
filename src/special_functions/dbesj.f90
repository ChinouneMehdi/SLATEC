!** DBESJ
PURE SUBROUTINE DBESJ(X,Alpha,N,Y,Nz)
  !> Compute an N member sequence of J Bessel functions
  !  J_{ALPHA+K-1}(X), K=1,...,N for non-negative ALPHA and X.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  C10A3
  !***
  ! **Type:**      DOUBLE PRECISION (BESJ-S, DBESJ-D)
  !***
  ! **Keywords:**  J BESSEL FUNCTION, SPECIAL FUNCTIONS
  !***
  ! **Author:**  Amos, D. E., (SNLA)
  !           Daniel, S. L., (SNLA)
  !           Weston, M. K., (SNLA)
  !***
  ! **Description:**
  !
  !     Abstract  **** a double precision routine ****
  !         DBESJ computes an N member sequence of J Bessel functions
  !         J_{ALPHA+K-1}(X), K=1,...,N for non-negative ALPHA and X.
  !         A combination of the power series, the asymptotic expansion
  !         for X to infinity and the uniform asymptotic expansion for
  !         NU to infinity are applied over subdivisions of the (NU,X)
  !         plane.  For values of (NU,X) not covered by one of these
  !         formulae, the order is incremented or decremented by integer
  !         values into a region where one of the formulae apply. Backward
  !         recursion is applied to reduce orders by integer values except
  !         where the entire sequence lies in the oscillatory region.  In
  !         this case forward recursion is stable and values from the
  !         asymptotic expansion for X to infinity start the recursion
  !         when it is efficient to do so. Leading terms of the series and
  !         uniform expansion are tested for underflow.  If a sequence is
  !         requested and the last member would underflow, the result is
  !         set to zero and the next lower order tried, etc., until a
  !         member comes on scale or all members are set to zero.
  !         Overflow cannot occur.
  !
  !         The maximum number of significant digits obtainable
  !         is the smaller of 14 and the number of digits carried in
  !         double precision arithmetic.
  !
  !     Description of Arguments
  !
  !         Input      X,ALPHA are double precision
  !           X      - X >= 0.0D0
  !           ALPHA  - order of first member of the sequence,
  !                    ALPHA >= 0.0D0
  !           N      - number of members in the sequence, N >= 1
  !
  !         Output     Y is double precision
  !           Y      - a vector whose first N components contain
  !                    values for J_{ALPHA+K-1}(X), K=1,...,N
  !           NZ     - number of components of Y set to zero due to
  !                    underflow,
  !                    NZ=0  , normal return, computation completed
  !                    NZ /= 0, last NZ components of Y set to zero,
  !                             Y(K)=0.0D0, K=N-NZ+1,...,N.
  !
  !     Error Conditions
  !         Improper input arguments - a fatal error
  !         Underflow  - a non-fatal error (NZ /= 0)
  !
  !***
  ! **References:**  D. E. Amos, S. L. Daniel and M. K. Weston, CDC 6600
  !                 subroutines IBESS and JBESS for Bessel functions
  !                 I(NU,X) and J(NU,X), X >= 0, NU >= 0, ACM
  !                 Transactions on Mathematical Software 3, (1977),
  !                 pp. 76-92.
  !               F. W. J. Olver, Tables of Bessel Functions of Moderate
  !                 or Large Orders, NPL Mathematical Tables 6, Her
  !                 Majesty's Stationery Office, London, 1962.
  !***
  ! **Routines called:**  D1MACH, DASYJY, DJAIRY, I1MACH, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   750101  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890911  Removed unnecessary intrinsics.  (WRB)
  !   890911  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900326  Removed duplicate information from DESCRIPTION section.  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE service, ONLY : eps_2_dp, log10_radix_dp, tiny_dp, digits_dp, min_exp_dp
  !
  INTEGER, INTENT(IN) ::  N
  INTEGER, INTENT(OUT) ::  Nz
  REAL(DP), INTENT(IN) :: Alpha, X
  REAL(DP), INTENT(OUT) :: Y(N)
  !
  INTEGER :: i, ialp, idalp, iflw, in, is, i1, i2, k, kk, km, kt,nn, ns
  REAL(DP) :: ak, akm, ans, ap, arg, coef, dalpha, dfn, dtm, earg, elim1, &
    etx, fidal, flgjy, fn, fnf, fni, fnp1, fnu, gln, rden, relb, &
    rtx, rzden, s, sa, sb, sxo2, s1, s2, t, ta, tau, tb, temp(3), &
    tfn, tm, tol, tolln, trx, tx, t1, t2, wk(7), xo2, xo2l, slim, rtol
  REAL(DP), PARAMETER :: rtwo = 1.34839972492648E+00_DP, pdf = 7.85398163397448E-01_DP, &
    rttp = 7.97884560802865E-01_DP, pidt = 1.57079632679490_DP
  REAL(DP), PARAMETER :: pp(4) = [ 8.72909153935547E+00_DP, 2.65693932265030E-01_DP, &
    1.24578576865586E-01_DP, 7.70133747430388E-04_DP ]
  INTEGER, PARAMETER :: inlim = 150
  REAL(DP), PARAMETER :: fnulim(2) = [ 100._DP, 60._DP ]
  !* FIRST EXECUTABLE STATEMENT  DBESJ
  Nz = 0
  kt = 1
  ns = 0
  !     digits_dp REPLACES digits_sp IN A DOUBLE PRECISION CODE
  !     min_exp_dp REPLACES min_exp_sp IN A DOUBLE PRECISION CODE
  ta = eps_2_dp
  tol = MAX(ta,1.E-15_DP)
  i1 = digits_dp + 1
  i2 = min_exp_dp
  tb = log10_radix_dp
  elim1 = -2.303_DP*(i2*tb+3._DP)
  rtol = 1._DP/tol
  slim = tiny_dp*rtol*1.E+3_DP
  !     TOLLN = -LN(TOL)
  tolln = 2.303_DP*tb*i1
  tolln = MIN(tolln,34.5388_DP)
  IF( N<1 ) THEN
    ERROR STOP 'DBESJ : N < 1'
  ELSEIF( N==1 ) THEN
    kt = 2
  END IF
  nn = N
  IF( X<0 ) THEN
    ERROR STOP 'DBESJ : X < 0'
  ELSEIF( Alpha<0._DP ) THEN
    ERROR STOP 'DBESJ : ORDER, ALPHA, < 0'
  ELSEIF( X==0 ) THEN
    IF( Alpha==0 ) THEN
      Y(1) = 1._DP
      IF( N==1 ) RETURN
      i1 = 2
    ELSE
      i1 = 1
    END IF
    DO i = i1, N
      Y(i) = 0._DP
    END DO
    RETURN
  ELSE
    !
    ialp = INT(Alpha)
    fni = ialp + N - 1
    fnf = Alpha - ialp
    dfn = fni + fnf
    fnu = dfn
    xo2 = X*0.5_DP
    sxo2 = xo2*xo2
    !
    !     DECISION TREE FOR REGION WHERE SERIES, ASYMPTOTIC EXPANSION FOR X
    !     TO INFINITY AND ASYMPTOTIC EXPANSION FOR NU TO INFINITY ARE
    !     APPLIED.
    !
    IF( sxo2<=(fnu+1._DP) ) THEN
      fn = fnu
      fnp1 = fn + 1._DP
      xo2l = LOG(xo2)
      is = kt
      IF( X<=0.50_DP ) GOTO 200
      ns = 0
    ELSE
      ta = MAX(20._DP,fnu)
      IF( X>ta ) THEN
        rtx = SQRT(X)
        tau = rtwo*rtx
        ta = tau + fnulim(kt)
        IF( fnu<=ta ) THEN
          !
          !     ASYMPTOTIC EXPANSION FOR X TO INFINITY WITH FORWARD RECURSION IN
          !     OSCILLATORY REGION X>MAX(20, NU), PROVIDED THE LAST MEMBER
          !     OF THE SEQUENCE IS ALSO IN THE REGION.
          !
          in = INT(Alpha-tau+2._DP)
          IF( in<=0 ) THEN
            idalp = ialp
            in = 0
          ELSE
            idalp = ialp - in - 1
            kt = 1
          END IF
          is = kt
          fidal = idalp
          dalpha = fidal + fnf
          arg = X - pidt*dalpha - pdf
          sa = SIN(arg)
          sb = COS(arg)
          coef = rttp/rtx
          etx = 8._DP*X
          GOTO 800
        ELSE
          fn = fnu
          is = kt
          GOTO 100
        END IF
      ELSEIF( X>12._DP ) THEN
        ans = MAX(36._DP-fnu,0._DP)
        ns = INT(ans)
        fni = fni + ns
        dfn = fni + fnf
        fn = dfn
        is = kt
        IF( N-1+ns>0 ) is = 3
        GOTO 100
      ELSE
        xo2l = LOG(xo2)
        ns = INT(sxo2-fnu) + 1
      END IF
    END IF
    fni = fni + ns
    dfn = fni + fnf
    fn = dfn
    fnp1 = fn + 1._DP
    is = kt
    IF( N-1+ns>0 ) is = 3
    GOTO 200
  END IF
  100 CONTINUE
  DO
    !
    !     UNIFORM ASYMPTOTIC EXPANSION FOR NU TO INFINITY
    !
    i1 = ABS(3-is)
    i1 = MAX(i1,1)
    flgjy = 1._DP
    CALL DASYJY(DJAIRY,X,fn,flgjy,i1,temp(is),wk,iflw)
    IF( iflw/=0 ) THEN
      !
      !     SET UNDERFLOW VALUE AND UPDATE PARAMETERS
      !     UNDERFLOW CAN ONLY OCCUR FOR NS=0 SINCE THE ORDER MUST BE LARGER
      !     THAN 36. THEREFORE, NS NEE NOT BE TESTED.
      !
      Y(nn) = 0._DP
      nn = nn - 1
      fni = fni - 1._DP
      dfn = fni + fnf
      fn = dfn
      IF( nn<1 ) GOTO 500
      IF( nn==1 ) THEN
        kt = 2
        is = 2
      END IF
    ELSE
      SELECT CASE (is)
        CASE (1)
          EXIT
        CASE (2)
          GOTO 600
        CASE (3)
          !     COMPUTATION OF LAST ORDER FOR ASYMPTOTIC EXPANSION NORMALIZATION
          gln = wk(3) + wk(2)
          IF( wk(6)>30._DP ) THEN
            ta = 0.5_DP*tolln/wk(4)
            ta = ((0.0493827160_DP*ta-0.1111111111_DP)*ta+0.6666666667_DP)*ta*wk(6)
            IF( wk(1)<0.10_DP ) THEN
              tb = (1.259921049_DP+(0.1679894730_DP+0.0887944358_DP*wk(1))*wk(1))/wk(7)
            ELSE
              tb = gln/wk(5)
            END IF
          ELSE
            rden = (pp(4)*wk(6)+pp(3))*wk(6) + 1._DP
            rzden = pp(1) + pp(2)*wk(6)
            ta = rzden/rden
            IF( wk(1)<0.10_DP ) THEN
              tb = (1.259921049_DP+(0.1679894730_DP+0.0887944358_DP*wk(1))*wk(1))/wk(7)
            ELSE
              tb = gln/wk(5)
            END IF
          END IF
          in = INT(ta/tb+1.5_DP)
          IF( in<=inlim ) GOTO 900
        CASE DEFAULT
      END SELECT
      temp(1) = temp(3)
      kt = 1
      EXIT
    END IF
  END DO
  is = 2
  fni = fni - 1._DP
  dfn = fni + fnf
  fn = dfn
  IF( i1/=2 ) GOTO 100
  GOTO 600
  !
  !     SERIES FOR (X/2)**2<=NU+1
  !
  200  gln = LOG_GAMMA(fnp1)
  arg = fn*xo2l - gln
  IF( arg<(-elim1) ) GOTO 400
  earg = EXP(arg)
  300  s = 1._DP
  IF( X>=tol ) THEN
    ak = 3._DP
    t2 = 1._DP
    t = 1._DP
    s1 = fn
    DO k = 1, 17
      s2 = t2 + s1
      t = -t*sxo2/s2
      s = s + t
      IF( ABS(t)<tol ) EXIT
      t2 = t2 + ak
      ak = ak + 2._DP
      s1 = s1 + fn
    END DO
  END IF
  temp(is) = s*earg
  SELECT CASE (is)
    CASE (2)
      GOTO 600
    CASE (3)
      !
      !     BACKWARD RECURSION WITH NORMALIZATION BY
      !     ASYMPTOTIC EXPANSION FOR NU TO INFINITY OR POWER SERIES.
      !
      !     COMPUTATION OF LAST ORDER FOR SERIES NORMALIZATION
      akm = MAX(3._DP-fn,0._DP)
      km = INT(akm)
      tfn = fn + km
      ta = (gln+tfn-0.9189385332_DP-0.0833333333_DP/tfn)/(tfn+0.5_DP)
      ta = xo2l - ta
      tb = -(1._DP-1.5_DP/tfn)/tfn
      akm = tolln/(-ta+SQRT(ta*ta-tolln*tb)) + 1.5_DP
      in = km + INT(akm)
      GOTO 900
    CASE DEFAULT
      earg = earg*fn/xo2
      fni = fni - 1._DP
      dfn = fni + fnf
      fn = dfn
      is = 2
      GOTO 300
  END SELECT
  400  Y(nn) = 0._DP
  nn = nn - 1
  fnp1 = fn
  fni = fni - 1._DP
  dfn = fni + fnf
  fn = dfn
  IF( nn<1 ) GOTO 500
  IF( nn==1 ) THEN
    kt = 2
    is = 2
  END IF
  IF( sxo2>fnp1 ) GOTO 100
  arg = arg - xo2l + LOG(fnp1)
  IF( arg>=(-elim1) ) GOTO 200
  GOTO 400
  500  Nz = N - nn
  RETURN
  !
  !     BACKWARD RECURSION SECTION
  !
  600 CONTINUE
  IF( ns==0 ) THEN
    Nz = N - nn
    IF( kt==2 ) GOTO 700
    !     BACKWARD RECUR FROM INDEX ALPHA+NN-1 TO ALPHA
    Y(nn) = temp(1)
    Y(nn-1) = temp(2)
    IF( nn==2 ) RETURN
  END IF
  trx = 2._DP/X
  dtm = fni
  tm = (dtm+fnf)*trx
  ak = 1._DP
  ta = temp(1)
  tb = temp(2)
  IF( ABS(ta)<=slim ) THEN
    ta = ta*rtol
    tb = tb*rtol
    ak = tol
  END IF
  kk = 2
  in = ns - 1
  IF( in==0 ) GOTO 1100
  IF( ns/=0 ) GOTO 1000
  k = nn - 2
  DO i = 3, nn
    s = tb
    tb = tm*tb - ta
    ta = s
    Y(k) = tb*ak
    dtm = dtm - 1._DP
    tm = (dtm+fnf)*trx
    k = k - 1
  END DO
  RETURN
  700  Y(1) = temp(2)
  RETURN
  800  dtm = fidal + fidal
  dtm = dtm*dtm
  tm = 0._DP
  IF( fidal/=0._DP .OR. ABS(fnf)>=tol ) tm = 4._DP*fnf*(fidal+fidal+fnf)
  trx = dtm - 1._DP
  t2 = (trx+tm)/etx
  s2 = t2
  relb = tol*ABS(t2)
  t1 = etx
  s1 = 1._DP
  fn = 1._DP
  ak = 8._DP
  DO k = 1, 13
    t1 = t1 + etx
    fn = fn + ak
    trx = dtm - fn
    ap = trx + tm
    t2 = -t2*ap/t1
    s1 = s1 + t2
    t1 = t1 + etx
    ak = ak + 8._DP
    fn = fn + ak
    trx = dtm - fn
    ap = trx + tm
    t2 = t2*ap/t1
    s2 = s2 + t2
    IF( ABS(t2)<=relb ) EXIT
    ak = ak + 8._DP
  END DO
  temp(is) = coef*(s1*sb-s2*sa)
  IF( is==2 ) THEN
    !
    !     FORWARD RECURSION SECTION
    !
    IF( kt==2 ) GOTO 700
    s1 = temp(1)
    s2 = temp(2)
    tx = 2._DP/X
    tm = dalpha*tx
    IF( in/=0 ) THEN
      !
      !     FORWARD RECUR TO INDEX ALPHA
      !
      DO i = 1, in
        s = s2
        s2 = tm*s2 - s1
        tm = tm + tx
        s1 = s
      END DO
      IF( nn==1 ) THEN
        Y(1) = s2
        RETURN
      ELSE
        s = s2
        s2 = tm*s2 - s1
        tm = tm + tx
        s1 = s
      END IF
    END IF
    !
    !     FORWARD RECUR FROM INDEX ALPHA TO ALPHA+N-1
    !
    Y(1) = s1
    Y(2) = s2
    IF( nn==2 ) RETURN
    DO i = 3, nn
      Y(i) = tm*Y(i-1) - Y(i-2)
      tm = tm + tx
    END DO
    RETURN
  ELSE
    fidal = fidal + 1._DP
    dalpha = fidal + fnf
    is = 2
    tb = sa
    sa = -sb
    sb = tb
    GOTO 800
  END IF
  900  dtm = fni + in
  trx = 2._DP/X
  tm = (dtm+fnf)*trx
  ta = 0._DP
  tb = tol
  kk = 1
  ak = 1._DP
  1000 CONTINUE
  DO
    !
    !     BACKWARD RECUR UNINDEXED
    !
    DO i = 1, in
      s = tb
      tb = tm*tb - ta
      ta = s
      dtm = dtm - 1._DP
      tm = (dtm+fnf)*trx
    END DO
    !     NORMALIZATION
    IF( kk/=1 ) EXIT
    s = temp(3)
    sa = ta/tb
    ta = s
    tb = s
    IF( ABS(s)<=slim ) THEN
      ta = ta*rtol
      tb = tb*rtol
      ak = tol
    END IF
    ta = ta*sa
    kk = 2
    in = ns
    IF( ns==0 ) EXIT
  END DO
  1100 Y(nn) = tb*ak
  Nz = N - nn
  IF( nn==1 ) RETURN
  k = nn - 1
  s = tb
  tb = tm*tb - ta
  ta = s
  Y(k) = tb*ak
  IF( nn==2 ) RETURN
  dtm = dtm - 1._DP
  tm = (dtm+fnf)*trx
  k = nn - 2
  !
  !     BACKWARD RECUR INDEXED
  !
  DO i = 3, nn
    s = tb
    tb = tm*tb - ta
    ta = s
    Y(k) = tb*ak
    dtm = dtm - 1._DP
    tm = (dtm+fnf)*trx
    k = k - 1
  END DO

  RETURN
END SUBROUTINE DBESJ