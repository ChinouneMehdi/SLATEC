!** QNC79
PURE SUBROUTINE QNC79(FUN,A,B,Err,Ans,Ierr,K)
  !> Integrate a function using a 7-point adaptive Newton-Cotes quadrature rule.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  H2A1A1
  !***
  ! **Type:**      SINGLE PRECISION (QNC79-S, DQNC79-D)
  !***
  ! **Keywords:**  ADAPTIVE QUADRATURE, INTEGRATION, NEWTON-COTES
  !***
  ! **Author:**  Kahaner, D. K., (NBS)
  !           Jones, R. E., (SNLA)
  !***
  ! **Description:**
  !
  !     Abstract
  !       QNC79 is a general purpose program for evaluation of
  !       one dimensional integrals of user defined functions.
  !       QNC79 will pick its own points for evaluation of the
  !       integrand and these will vary from problem to problem.
  !       Thus, QNC79 is not designed to integrate over data sets.
  !       Moderately smooth integrands will be integrated efficiently
  !       and reliably.  For problems with strong singularities,
  !       oscillations etc., the user may wish to use more sophis-
  !       ticated routines such as those in QUADPACK.  One measure
  !       of the reliability of QNC79 is the output parameter K,
  !       giving the number of integrand evaluations that were needed.
  !
  !     Description of Arguments
  !
  !     --Input--
  !       FUN  - name of external function to be integrated.  This name
  !              must be in an EXTERNAL statement in your calling
  !              program.  You must write a Fortran function to evaluate
  !              FUN.  This should be of the form
  !                    REAL FUNCTION FUN (X)
  !              C
  !              C     X can vary from A to B
  !              C     FUN(X) should be finite for all X on interval.
  !              C
  !                    FUN = ...
  !                    RETURN
  !                    END
  !       A    - lower limit of integration
  !       B    - upper limit of integration (may be less than A)
  !       ERR  - is a requested error tolerance.  Normally, pick a value
  !              0 < ERR < 1.0E-3.
  !
  !     --Output--
  !       ANS  - computed value of the integral.  Hopefully, ANS is
  !              accurate to within ERR * integral of ABS(FUN(X)).
  !       IERR - a status code
  !            - Normal codes
  !               1  ANS most likely meets requested error tolerance.
  !              -1  A equals B, or A and B are too nearly equal to
  !                  allow normal integration.  ANS is set to zero.
  !            - Abnormal code
  !               2  ANS probably does not meet requested error tolerance.
  !       K    - the number of function evaluations actually used to do
  !              the integration.  A value of K > 1000 indicates a
  !              difficult problem; other programs may be more efficient.
  !              QNC79 will gracefully give up if K exceeds 2000.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  I1MACH, R1MACH, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   790601  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   920218  Code and prologue polished.  (WRB)
  USE service, ONLY : log10_radix_sp, eps_sp, digits_sp
  !     .. Function Arguments ..
  INTERFACE
    REAL(SP) PURE FUNCTION FUN(X)
      IMPORT SP
      REAL(SP), INTENT(IN) :: X
    END FUNCTION FUN
  END INTERFACE
  !     .. Scalar Arguments ..
  INTEGER, INTENT(OUT) :: Ierr, K
  REAL(SP), INTENT(IN) :: A, B, Err
  REAL(SP), INTENT(OUT) :: Ans
  !     .. Local Scalars ..
  REAL(SP) :: ae, area, bank, blocal, c, ce, ee, ef, eps, q13, q7, q7l, test, tol, vr
  INTEGER :: i, l, lmn, lmx, nib
  !     .. Local Arrays ..
  REAL(SP) :: aa(40), f(13), f1(40), f2(40), f3(40), f4(40), f5(40), f6(40), &
    f7(40), hh(40), q7r(40), vl(40)
  INTEGER :: lr(40)
  !     .. Intrinsic Functions ..
  INTRINSIC ABS, LOG, MAX, MIN, SIGN, SQRT
  !     .. Data statements ..
  INTEGER, PARAMETER :: nbits = INT( log10_radix_sp*digits_sp/0.30102000_SP ), &
    nlmx = MIN(40,(nbits*4)/5)
  REAL(SP), PARAMETER :: sq2 = SQRT(2._SP), w1 = 41._SP/140._SP, w2 = 216._SP/140._SP, &
    w3 = 27._SP/140._SP, w4 = 272._SP/140._SP
  INTEGER, PARAMETER :: kml = 7, kmx = 2000, nlmn = 2
  !* FIRST EXECUTABLE STATEMENT  QNC79
  Ans = 0._SP
  Ierr = 1
  ce = 0._SP
  IF( A==B ) GOTO 400
  lmx = nlmx
  lmn = nlmn
  IF( B/=0._SP ) THEN
    IF( SIGN(1._SP,B)*A>0._SP ) THEN
      c = ABS(1._SP-A/B)
      IF( c<=0.1_SP ) THEN
        IF( c<=0._SP ) GOTO 400
        nib = INT( 0.5_SP - LOG(c)/LOG(2._SP) )
        lmx = MIN(nlmx,nbits-nib-4)
        IF( lmx<2 ) GOTO 400
        lmn = MIN(lmn,lmx)
      END IF
    END IF
  END IF
  tol = MAX(ABS(Err),2._SP**(5-nbits))
  IF( Err==0._SP ) tol = SQRT(eps_sp)
  eps = tol
  hh(1) = (B-A)/12._SP
  aa(1) = A
  lr(1) = 1
  DO i = 1, 11, 2
    f(i) = FUN(A+(i-1)*hh(1))
  END DO
  blocal = B
  f(13) = FUN(blocal)
  K = 7
  l = 1
  area = 0._SP
  q7 = 0._SP
  ef = 256._SP/255._SP
  bank = 0._SP
  !
  !     Compute refined estimates, estimate the error, etc.
  !
  100 CONTINUE
  DO i = 2, 12, 2
    f(i) = FUN(aa(l)+(i-1)*hh(l))
  END DO
  K = K + 6
  !
  !     Compute left and right half estimates
  !
  q7l = hh(l)*((w1*(f(1)+f(7))+w2*(f(2)+f(6)))+(w3*(f(3)+f(5))+w4*f(4)))
  q7r(l) = hh(l)&
    *((w1*(f(7)+f(13))+w2*(f(8)+f(12)))+(w3*(f(9)+f(11))+w4*f(10)))
  !
  !     Update estimate of integral of absolute value
  !
  area = area + (ABS(q7l)+ABS(q7r(l))-ABS(q7))
  !
  !     Do not bother to test convergence before minimum refinement level
  !
  IF( l>=lmn ) THEN
    !
    !     Estimate the error in new value for whole interval, Q13
    !
    q13 = q7l + q7r(l)
    ee = ABS(q7-q13)*ef
    !
    !     Compute nominal allowed error
    !
    ae = eps*area
    !
    !     Borrow from bank account, but not too much
    !
    test = MIN(ae+0.8_SP*bank,10._SP*ae)
    !
    !     Don't ask for excessive accuracy
    !
    test = MAX(test,tol*ABS(q13),0.00003_SP*tol*area)
    !
    !     Now, did this interval pass or not?
    !
    IF( ee<=test ) THEN
      !
      !     On good intervals accumulate the theoretical estimate
      !
      ce = ce + (q7-q13)/255._SP
    ELSE
      !
      !     Consider the left half of next deeper level
      !
      IF( K>kmx ) lmx = MIN(kml,lmx)
      IF( l<lmx ) GOTO 200
      !
      !     Have hit maximum refinement level -- penalize the cumulative error
      !
      ce = ce + (q7-q13)
    END IF
    !
    !     Update the bank account.  Don't go into debt.
    !
    bank = bank + (ae-ee)
    IF( bank<0._SP ) bank = 0._SP
    !
    !     Did we just finish a left half or a right half?
    !
    IF( lr(l)<=0 ) THEN
      !
      !     Proceed to right half at this level
      !
      vl(l) = q13
      GOTO 300
    ELSE
      !
      !     Left and right halves are done, so go back up a level
      !
      vr = q13
      DO WHILE( l>1 )
        IF( l<=17 ) ef = ef*sq2
        eps = eps*2._SP
        l = l - 1
        IF( lr(l)<=0 ) THEN
          vl(l) = vl(l+1) + vr
          GOTO 300
        ELSE
          vr = vl(l+1) + vr
        END IF
      END DO
      !
      !     Exit
      !
      Ans = vr
      IF( ABS(ce)>2._SP*tol*area ) THEN
        Ierr = 2
        ERROR STOP 'QNC79 : ANS is probably insufficiently accurate.'
      END IF
      RETURN
    END IF
  END IF
  200  l = l + 1
  eps = eps*0.5_SP
  IF( l<=17 ) ef = ef/sq2
  hh(l) = hh(l-1)*0.5_SP
  lr(l) = -1
  aa(l) = aa(l-1)
  q7 = q7l
  f1(l) = f(7)
  f2(l) = f(8)
  f3(l) = f(9)
  f4(l) = f(10)
  f5(l) = f(11)
  f6(l) = f(12)
  f7(l) = f(13)
  f(13) = f(7)
  f(11) = f(6)
  f(9) = f(5)
  f(7) = f(4)
  f(5) = f(3)
  f(3) = f(2)
  GOTO 100
  300  q7 = q7r(l-1)
  lr(l) = 1
  aa(l) = aa(l) + 12._SP*hh(l)
  f(1) = f1(l)
  f(3) = f2(l)
  f(5) = f3(l)
  f(7) = f4(l)
  f(9) = f5(l)
  f(11) = f6(l)
  f(13) = f7(l)
  GOTO 100
  400  Ierr = -1
  ! 'QNC79 : A and B are too nearly equal to allow normal integration.&
    ! & ANS is set to zero and IERR to -1.'
  !
  RETURN
END SUBROUTINE QNC79