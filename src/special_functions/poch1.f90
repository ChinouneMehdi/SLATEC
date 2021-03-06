!** POCH1
REAL(SP) ELEMENTAL FUNCTION POCH1(A,X)
  !> Calculate a generalization of Pochhammer's symbol starting from first order.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C1, C7A
  !***
  ! **Type:**      SINGLE PRECISION (POCH1-S, DPOCH1-D)
  !***
  ! **Keywords:**  FIRST ORDER, FNLIB, POCHHAMMER, SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! Evaluate a generalization of Pochhammer's symbol for special
  ! situations that require especially accurate values when X is small in
  !        POCH1(A,X) = (POCH(A,X)-1)/X
  !                   = (GAMMA(A+X)/GAMMA(A) - 1.0)/X .
  ! This specification is particularly suited for stably computing
  ! expressions such as
  !        (GAMMA(A+X)/GAMMA(A) - GAMMA(B+X)/GAMMA(B))/X
  !             = POCH1(A,X) - POCH1(B,X)
  ! Note that POCH1(A,0.0) = PSI(A)
  !
  ! When ABS(X) is so small that substantial cancellation will occur if
  ! the straightforward formula is used, we  use an expansion due
  ! to Fields and discussed by Y. L. Luke, The Special Functions and Their
  ! Approximations, Vol. 1, Academic Press, 1969, page 34.
  !
  ! The ratio POCH(A,X) = GAMMA(A+X)/GAMMA(A) is written by Luke as
  !        (A+(X-1)/2)**X * polynomial in (A+(X-1)/2)**(-2) .
  ! In order to maintain significance in POCH1, we write for positive A
  !        (A+(X-1)/2)**X = EXP(X*LOG(A+(X-1)/2)) = EXP(Q)
  !                       = 1.0 + Q*EXPREL(Q) .
  ! Likewise the polynomial is written
  !        POLY = 1.0 + X*POLY1(A,X) .
  ! Thus,
  !        POCH1(A,X) = (POCH(A,X) - 1) / X
  !                   = EXPREL(Q)*(Q/X + Q*POLY1(A,X)) + POLY1(A,X)
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  COT, EXPREL, POCH, PSI, R1MACH, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   770801  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900727  Added EXTERNAL statement.  (WRB)
  USE service, ONLY : tiny_sp, eps_2_sp
  !
  REAL(SP), INTENT(IN) :: A, X
  !
  INTEGER :: i, ii, incr, j, k, ndx, nterms
  REAL(SP) :: absa, absx, alnvar, b, binv, bp, gbern(10), gbk, poly1, &
    q, rho, sinpx2, sinpxx, term, trig, var, var2
  REAL(SP), PARAMETER :: sqtbig = 1._SP/SQRT(24._SP*tiny_sp), alneps = LOG(eps_2_sp)
  REAL(SP), PARAMETER :: bern(9) = [ .83333333333333333E-01_SP,-.13888888888888889E-02_SP, &
    .33068783068783069E-04_SP, -.82671957671957672E-06_SP, .20876756987868099E-07_SP, &
    -.52841901386874932E-09_SP, .13382536530684679E-10_SP,-.33896802963225829E-12_SP, &
    .85860620562778446E-14_SP ]
  REAL(SP), PARAMETER :: pi = 3.14159265358979324_SP
  !* FIRST EXECUTABLE STATEMENT  POCH1
  !
  IF( X==0._SP ) THEN
    POCH1 = PSI(A)
    RETURN
  END IF
  !
  absx = ABS(X)
  absa = ABS(A)
  IF( absx>0.1_SP*absa ) THEN
    !
    POCH1 = (POCH(A,X)-1._SP)/X
  ELSEIF( absx*LOG(MAX(absa,2._SP))>0.1 ) THEN
    POCH1 = (POCH(A,X)-1._SP)/X
  ELSE
    !
    bp = A
    IF( A<(-0.5_SP) ) bp = 1._SP - A - X
    incr = 0
    IF( bp<10._SP ) incr = 11 - INT( bp )
    b = bp + incr
    !
    var = b + 0.5_SP*(X-1._SP)
    alnvar = LOG(var)
    q = X*alnvar
    !
    poly1 = 0._SP
    IF( var<sqtbig ) THEN
      var2 = (1._SP/var)**2
      !
      rho = 0.5_SP*(X+1._SP)
      gbern(1) = 1._SP
      gbern(2) = -rho/12._SP
      term = var2
      poly1 = gbern(2)*term
      !
      nterms = INT( -0.5_SP*alneps/alnvar ) + 1
      IF( nterms>9 ) ERROR STOP 'POCH1 : NTERMS IS TOO BIG, MAYBE eps_2_sp IS BAD'
      IF( nterms>=2 ) THEN
        !
        DO k = 2, nterms
          gbk = 0._SP
          DO j = 1, k
            ndx = k - j + 1
            gbk = gbk + bern(ndx)*gbern(j)
          END DO
          gbern(k+1) = -rho*gbk/k
          !
          term = term*(2*k-2._SP-X)*(2*k-1._SP-X)*var2
          poly1 = poly1 + gbern(k+1)*term
        END DO
      END IF
    END IF
    !
    poly1 = (X-1._SP)*poly1
    POCH1 = EXPREL(q)*(alnvar+q*poly1) + poly1
    !
    IF( incr/=0 ) THEN
      !
      ! WE HAVE POCH1(B,X).  BUT BP IS SMALL, SO WE USE BACKWARDS RECURSION
      ! TO OBTAIN POCH1(BP,X).
      !
      DO ii = 1, incr
        i = incr - ii
        binv = 1._SP/(bp+i)
        POCH1 = (POCH1-binv)/(1._SP+X*binv)
      END DO
    END IF
    !
    IF( bp==A ) RETURN
    !
    ! WE HAVE POCH1(BP,X), BUT A IS LT -0.5.  WE THEREFORE USE A REFLECTION
    ! FORMULA TO OBTAIN POCH1(A,X).
    !
    sinpxx = SIN(pi*X)/X
    sinpx2 = SIN(0.5_SP*pi*X)
    trig = sinpxx*COT(pi*b) - 2._SP*sinpx2*(sinpx2/X)
    !
    POCH1 = trig + (1._SP+X*trig)*POCH1
    RETURN
  END IF
  !
END FUNCTION POCH1