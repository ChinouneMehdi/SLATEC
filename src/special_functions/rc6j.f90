!** RC6J
PURE SUBROUTINE RC6J(L2,L3,L4,L5,L6,L1min,L1max,Sixcof,Ndim,Ier)
  !> Evaluate the 6j symbol h(L1) = {L1 L2 L3}
  !                                 {L4 L5 L6}
  !  for all allowed values of L1, the other parameters being held fixed.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  C19
  !***
  ! **Type:**      SINGLE PRECISION (RC6J-S, DRC6J-D)
  !***
  ! **Keywords:**  6J COEFFICIENTS, 6J SYMBOLS, CLEBSCH-GORDAN COEFFICIENTS,
  !             RACAH COEFFICIENTS, VECTOR ADDITION COEFFICIENTS,
  !             WIGNER COEFFICIENTS
  !***
  ! **Author:**  Gordon, R. G., Harvard University
  !           Schulten, K., Max Planck Institute
  !***
  ! **Description:**
  !
  !- Usage:
  !
  !        REAL L2, L3, L4, L5, L6, L1MIN, L1MAX, SIXCOF(NDIM)
  !        INTEGER NDIM, IER
  !
  !        CALL RC6J(L2, L3, L4, L5, L6, L1MIN, L1MAX, SIXCOF, NDIM, IER)
  !
  !- Arguments:
  !
  !     L2 :IN      Parameter in 6j symbol.
  !
  !     L3 :IN      Parameter in 6j symbol.
  !
  !     L4 :IN      Parameter in 6j symbol.
  !
  !     L5 :IN      Parameter in 6j symbol.
  !
  !     L6 :IN      Parameter in 6j symbol.
  !
  !     L1MIN :OUT  Smallest allowable L1 in 6j symbol.
  !
  !     L1MAX :OUT  Largest allowable L1 in 6j symbol.
  !
  !     SIXCOF :OUT Set of 6j coefficients generated by evaluating the
  !                 6j symbol for all allowed values of L1.  SIXCOF(I)
  !                 will contain h(L1MIN+I-1), I=1,2,...,L1MAX-L1MIN+1.
  !
  !     NDIM :IN    Declared length of SIXCOF in calling program.
  !
  !     IER :OUT    Error flag.
  !                 IER=0 No errors.
  !                 IER=1 L2+L3+L5+L6 or L4+L2+L6 not an integer.
  !                 IER=2 L4, L2, L6 triangular condition not satisfied.
  !                 IER=3 L4, L5, L3 triangular condition not satisfied.
  !                 IER=4 L1MAX-L1MIN not an integer.
  !                 IER=5 L1MAX less than L1MIN.
  !                 IER=6 NDIM less than L1MAX-L1MIN+1.
  !
  !- Description:
  !
  !     The definition and properties of 6j symbols can be found, for
  !  example, in Appendix C of Volume II of A. Messiah. Although the
  !  parameters of the vector addition coefficients satisfy certain
  !  conventional restrictions, the restriction that they be non-negative
  !  integers or non-negative integers plus 1/2 is not imposed on input
  !  to this subroutine. The restrictions imposed are
  !       1. L2+L3+L5+L6 and L2+L4+L6 must be integers;
  !       2. ABS(L2-L4)<=L6<=L2+L4 must be satisfied;
  !       3. ABS(L4-L5)<=L3<=L4+L5 must be satisfied;
  !       4. L1MAX-L1MIN must be a non-negative integer, where
  !          L1MAX=MIN(L2+L3,L5+L6) and L1MIN=MAX(ABS(L2-L3),ABS(L5-L6)).
  !  If all the conventional restrictions are satisfied, then these
  !  restrictions are met. Conversely, if input to this subroutine meets
  !  all of these restrictions and the conventional restriction stated
  !  above, then all the conventional restrictions are satisfied.
  !
  !     The user should be cautious in using input parameters that do
  !  not satisfy the conventional restrictions. For example, the
  !  the subroutine produces values of
  !       h(L1) = { L1 2/3  1 }
  !               {2/3 2/3 2/3}
  !  for L1=1/3 and 4/3 but none of the symmetry properties of the 6j
  !  symbol, set forth on pages 1063 and 1064 of Messiah, is satisfied.
  !
  !     The subroutine generates h(L1MIN), h(L1MIN+1), ..., h(L1MAX)
  !  where L1MIN and L1MAX are defined above. The sequence h(L1) is
  !  generated by a three-term recurrence algorithm with scaling to
  !  control overflow. Both backward and forward recurrence are used to
  !  maintain numerical stability. The two recurrence sequences are
  !  matched at an interior point and are normalized from the unitary
  !  property of 6j coefficients and Wigner's phase convention.
  !
  !    The algorithm is suited to applications in which large quantum
  !  numbers arise, such as in molecular dynamics.
  !
  !***
  ! **References:**  1. Messiah, Albert., Quantum Mechanics, Volume II,
  !                  North-Holland Publishing Company, 1963.
  !               2. Schulten, Klaus and Gordon, Roy G., Exact recursive
  !                  evaluation of 3j and 6j coefficients for quantum-
  !                  mechanical coupling of angular momenta, J Math
  !                  Phys, v 16, no. 10, October 1975, pp. 1961-1970.
  !               3. Schulten, Klaus and Gordon, Roy G., Semiclassical
  !                  approximations to 3j and 6j coefficients for
  !                  quantum-mechanical coupling of angular momenta,
  !                  J Math Phys, v 16, no. 10, October 1975,
  !                  pp. 1971-1988.
  !               4. Schulten, Klaus and Gordon, Roy G., Recursive
  !                  evaluation of 3j and 6j coefficients, Computer
  !                  Phys Comm, v 11, 1976, pp. 269-278.
  !***
  ! **Routines called:**  R1MACH, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   750101  DATE WRITTEN
  !   880515  SLATEC prologue added by G. C. Nielson, NBS; parameters
  !           HUGE and TINY revised to depend on R1MACH.
  !   891229  Prologue description rewritten; other prologue sections
  !           revised; LMATCH (location of match point for recurrences)
  !           removed from argument list; argument IER changed to serve
  !           only as an error flag (previously, in cases without error,
  !           it returned the number of scalings); number of error codes
  !           increased to provide more precise error information;
  !           program comments revised; SLATEC error handler calls
  !           introduced to enable printing of error messages to meet
  !           SLATEC standards. These changes were done by D. W. Lozier,
  !           M. A. McClain and J. M. Smith of the National Institute
  !           of Standards and Technology, formerly NBS.
  !   910415  Mixed type expressions eliminated; variable C1 initialized;
  !           description of SIXCOF expanded. These changes were done by
  !           D. W. Lozier.
  USE service, ONLY : huge_sp
  !
  INTEGER, INTENT(IN) :: Ndim
  INTEGER, INTENT(OUT) :: Ier
  REAL(SP), INTENT(IN) :: L2, L3, L4, L5, L6
  REAL(SP), INTENT(OUT) :: L1min, L1max, Sixcof(Ndim)
  !
  INTEGER :: i, indexx, lstep, n, nfin, nfinp1, nfinp2, nfinp3, nlim, nstep2
  REAL(SP) :: a1, a1s, a2, a2s, c1, c1old, c2, cnorm, denom, dv, hugee, l1, &
    newfac, oldfac, ratio, sign1, sign2, srhuge, srtiny, sum1, sum2, sumbac, &
    sumfor, sumuni, thresh, tinyy, x, x1, x2, x3, y, y1, y2, y3
  REAL(SP), PARAMETER :: eps = 0.01_SP
  !
  !* FIRST EXECUTABLE STATEMENT  RC6J
  Ier = 0
  !  HUGE is the square root of one twentieth of the largest floating
  !  point number, approximately.
  hugee = SQRT(huge_sp/20._SP)
  srhuge = SQRT(hugee)
  tinyy = 1._SP/hugee
  srtiny = 1._SP/srhuge
  !
  !     LMATCH = ZERO
  !
  !  Check error conditions 1, 2, and 3.
  IF( (MOD(L2+L3+L5+L6+eps,1._SP)>=eps+eps) .OR. &
      (MOD(L4+L2+L6+eps,1._SP)>=eps+eps) ) THEN
    Ier = 1
    ERROR STOP 'RC6J : L2+L3+L5+L6 or L4+L2+L6 not integer.'
  ELSEIF( (L4+L2-L6<0._SP) .OR. (L4-L2+L6<0._SP) .OR. (-L4+L2+L6<0._SP) ) THEN
    Ier = 2
    ERROR STOP 'RC6J : L4, L2, L6 triangular condition not satisfied.'
  ELSEIF( (L4-L5+L3<0._SP) .OR. (L4+L5-L3<0._SP) .OR. (-L4+L5+L3<0._SP) ) THEN
    Ier = 3
    ERROR STOP 'RC6J : L4, L5, L3 triangular condition not satisfied.'
  END IF
  !
  !  Limits for L1
  !
  L1min = MAX(ABS(L2-L3),ABS(L5-L6))
  L1max = MIN(L2+L3,L5+L6)
  !
  !  Check error condition 4.
  IF( MOD(L1max-L1min+eps,1._SP)>=eps+eps ) THEN
    Ier = 4
    ERROR STOP 'RC6J : L1MAX-L1MIN not integer.'
  END IF
  IF( L1min<L1max-eps ) THEN
    !
    !
    !  This is reached in case that L1 can take more than one value.
    !
    !     LSCALE = 0
    nfin = INT(L1max-L1min+1._SP+eps)
    IF( Ndim<nfin ) THEN
      !
      !  Check error condition 6.
      Ier = 6
      ERROR STOP 'RC6J : Dimension of result array for 6j coefficients too small.'
    ELSE
      !
      !
      !  Start of forward recursion
      !
      l1 = L1min
      newfac = 0._SP
      c1 = 0._SP
      Sixcof(1) = srtiny
      sum1 = (l1+l1+1._SP)*tinyy
      !
      lstep = 1
    END IF
  ELSEIF( L1min<L1max+eps ) THEN
    !
    !
    !  This is reached in case that L1 can take only one value
    !
    !     LSCALE = 0
    Sixcof(1) = (-1._SP)**INT(L2+L3+L5+L6+eps)&
      /SQRT((L1min+L1min+1._SP)*(L4+L4+1._SP))
    RETURN
  ELSE
    !
    !  Check error condition 5.
    Ier = 5
    ERROR STOP 'RC6J : L1MIN greater than L1MAX.'
    RETURN
  END IF
  100  lstep = lstep + 1
  l1 = l1 + 1._SP
  !
  oldfac = newfac
  a1 = (l1+L2+L3+1._SP)*(l1-L2+L3)*(l1+L2-L3)*(-l1+L2+L3+1._SP)
  a2 = (l1+L5+L6+1._SP)*(l1-L5+L6)*(l1+L5-L6)*(-l1+L5+L6+1._SP)
  newfac = SQRT(a1*a2)
  !
  IF( l1<1._SP+eps ) THEN
    !
    !  If L1 = 1, (L1 - 1) has to be factored out of DV, hence
    !
    c1 = -2._SP*(L2*(L2+1._SP)+L5*(L5+1._SP)-L4*(L4+1._SP))/newfac
  ELSE
    !
    dv = 2._SP*(L2*(L2+1._SP)*L5*(L5+1._SP)+L3*(L3+1._SP)*L6*(L6+1._SP)-l1*(l1-1._SP)&
      *L4*(L4+1._SP)) - (L2*(L2+1._SP)+L3*(L3+1._SP)-l1*(l1-1._SP))&
      *(L5*(L5+1._SP)+L6*(L6+1._SP)-l1*(l1-1._SP))
    !
    denom = (l1-1._SP)*newfac
    !
    !
    IF( lstep>2 ) c1old = ABS(c1)
    c1 = -(l1+l1-1._SP)*dv/denom
  END IF
  !
  IF( lstep>2 ) THEN
    !
    !
    c2 = -l1*oldfac/denom
    !
    !  Recursion to the next 6j coefficient X
    !
    x = c1*Sixcof(lstep-1) + c2*Sixcof(lstep-2)
    Sixcof(lstep) = x
    !
    sumfor = sum1
    sum1 = sum1 + (l1+l1+1._SP)*x*x
    IF( lstep/=nfin ) THEN
      !
      !  See if last unnormalized 6j coefficient exceeds SRHUGE
      !
      IF( ABS(x)>=srhuge ) THEN
        !
        !  This is reached if last 6j coefficient larger than SRHUGE,
        !  so that the recursion series SIXCOF(1), ... ,SIXCOF(LSTEP)
        !  has to be rescaled to prevent overflow
        !
        !     LSCALE = LSCALE + 1
        DO i = 1, lstep
          IF( ABS(Sixcof(i))<srtiny ) Sixcof(i) = 0._SP
          Sixcof(i) = Sixcof(i)/srhuge
        END DO
        sum1 = sum1/hugee
        sumfor = sumfor/hugee
        x = x/srhuge
      END IF
      !
      !
      !  As long as the coefficient ABS(C1) is decreasing, the recursion
      !  proceeds towards increasing 6j values and, hence, is numerically
      !  stable.  Once an increase of ABS(C1) is detected, the recursion
      !  direction is reversed.
      !
      IF( c1old>ABS(c1) ) GOTO 100
    END IF
    !
    !
    !  Keep three 6j coefficients around LMATCH for comparison later
    !  with backward recursion.
    !
    !     LMATCH = L1 - 1
    x1 = x
    x2 = Sixcof(lstep-1)
    x3 = Sixcof(lstep-2)
    !
    !
    !
    !  Starting backward recursion from L1MAX taking NSTEP2 steps, so
    !  that forward and backward recursion overlap at the three points
    !  L1 = LMATCH+1, LMATCH, LMATCH-1.
    !
    nfinp1 = nfin + 1
    nfinp2 = nfin + 2
    nfinp3 = nfin + 3
    nstep2 = nfin - lstep + 3
    l1 = L1max
    !
    Sixcof(nfin) = srtiny
    sum2 = (l1+l1+1._SP)*tinyy
    !
    !
    l1 = l1 + 2._SP
    lstep = 1
    DO
      lstep = lstep + 1
      l1 = l1 - 1._SP
      !
      oldfac = newfac
      a1s = (l1+L2+L3)*(l1-L2+L3-1._SP)*(l1+L2-L3-1._SP)*(-l1+L2+L3+2._SP)
      a2s = (l1+L5+L6)*(l1-L5+L6-1._SP)*(l1+L5-L6-1._SP)*(-l1+L5+L6+2._SP)
      newfac = SQRT(a1s*a2s)
      !
      dv = 2._SP*(L2*(L2+1._SP)*L5*(L5+1._SP)+L3*(L3+1._SP)*L6*(L6+1._SP)-l1*(l1-1._SP)&
        *L4*(L4+1._SP)) - (L2*(L2+1._SP)+L3*(L3+1._SP)-l1*(l1-1._SP))&
        *(L5*(L5+1._SP)+L6*(L6+1._SP)-l1*(l1-1._SP))
      !
      denom = l1*newfac
      c1 = -(l1+l1-1._SP)*dv/denom
      IF( lstep>2 ) THEN
        !
        !
        c2 = -(l1-1._SP)*oldfac/denom
        !
        !  Recursion to the next 6j coefficient Y
        !
        y = c1*Sixcof(nfinp2-lstep) + c2*Sixcof(nfinp3-lstep)
        IF( lstep==nstep2 ) EXIT
        Sixcof(nfinp1-lstep) = y
        sumbac = sum2
        sum2 = sum2 + (l1+l1-3._SP)*y*y
        !
        !  See if last unnormalized 6j coefficient exceeds SRHUGE
        !
        IF( ABS(y)>=srhuge ) THEN
          !
          !  This is reached if last 6j coefficient larger than SRHUGE,
          !  so that the recursion series SIXCOF(NFIN), ... ,SIXCOF(NFIN-LSTEP+1)
          !  has to be rescaled to prevent overflow
          !
          !     LSCALE = LSCALE + 1
          DO i = 1, lstep
            indexx = nfin - i + 1
            IF( ABS(Sixcof(indexx))<srtiny ) Sixcof(indexx) = 0._SP
            Sixcof(indexx) = Sixcof(indexx)/srhuge
          END DO
          sumbac = sumbac/hugee
          !
          sum2 = sum2/hugee
        END IF
      ELSE
        !
        !  If L1 = L1MAX + 1 the third term in the recursion equation vanishes
        !
        y = srtiny*c1
        Sixcof(nfin-1) = y
        IF( lstep==nstep2 ) EXIT
        sumbac = sum2
        sum2 = sum2 + (l1+l1-3._SP)*c1*c1*tinyy
      END IF
    END DO
    !
    !
    !  The forward recursion 6j coefficients X1, X2, X3 are to be matched
    !  with the corresponding backward recursion values Y1, Y2, Y3.
    !
    y3 = y
    y2 = Sixcof(nfinp2-lstep)
    y1 = Sixcof(nfinp3-lstep)
    !
    !
    !  Determine now RATIO such that YI = RATIO * XI  (I=1,2,3) holds
    !  with minimal error.
    !
    ratio = (x1*y1+x2*y2+x3*y3)/(x1*x1+x2*x2+x3*x3)
    nlim = nfin - nstep2 + 1
    !
    IF( ABS(ratio)<1._SP ) THEN
      !
      nlim = nlim + 1
      ratio = 1._SP/ratio
      DO n = nlim, nfin
        Sixcof(n) = ratio*Sixcof(n)
      END DO
      sumuni = sumfor + ratio*ratio*sumbac
    ELSE
      !
      DO n = 1, nlim
        Sixcof(n) = ratio*Sixcof(n)
      END DO
      sumuni = ratio*ratio*sumfor + sumbac
    END IF
  ELSE
    !
    !  If L1 = L1MIN + 1, the third term in recursion equation vanishes
    !
    x = srtiny*c1
    Sixcof(2) = x
    sum1 = sum1 + tinyy*(l1+l1+1._SP)*c1*c1
    !
    IF( lstep/=nfin ) GOTO 100
    !
    sumuni = sum1
  END IF
  !
  !
  !  Normalize 6j coefficients
  !
  cnorm = 1._SP/SQRT((L4+L4+1._SP)*sumuni)
  !
  !  Sign convention for last 6j coefficient determines overall phase
  !
  sign1 = SIGN(1._SP,Sixcof(nfin))
  sign2 = (-1._SP)**INT(L2+L3+L5+L6+eps)
  IF( sign1*sign2<=0 ) cnorm = -cnorm
  !
  IF( ABS(cnorm)<1._SP ) THEN
    !
    thresh = tinyy/ABS(cnorm)
    DO n = 1, nfin
      IF( ABS(Sixcof(n))<thresh ) Sixcof(n) = 0._SP
      Sixcof(n) = cnorm*Sixcof(n)
    END DO
    RETURN
  END IF
  !
  DO n = 1, nfin
    Sixcof(n) = cnorm*Sixcof(n)
  END DO

  RETURN
END SUBROUTINE RC6J