!** BSGQ8
PURE SUBROUTINE BSGQ8(FUN,Xt,Bc,N,Kk,Id,A,B,Err,Ans,Ierr)
  !> Subsidiary to BFQAD
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (BSGQ8-S, DBSGQ8-D)
  !***
  ! **Author:**  Jones, R. E., (SNLA)
  !***
  ! **Description:**
  !
  !     Abstract
  !        BSGQ8, a modification of GAUS8, integrates the
  !        product of FUN(X) by the ID-th derivative of a spline
  !        BVALU(XT,BC,N,KK,ID,X,INBV,WORK)  between limits A and B.
  !
  !     Description of Arguments
  !
  !        INPUT--
  !        FUN - Name of external function of one argument which
  !              multiplies BVALU.
  !        XT  - Knot array for BVALU
  !        BC  - B-coefficient array for BVALU
  !        N   - Number of B-coefficients for BVALU
  !        KK  - Order of the spline, KK>=1
  !        ID  - Order of the spline derivative, 0<=ID<=KK-1
  !        A   - Lower limit of integral
  !        B   - Upper limit of integral (may be less than A)
  !        INBV- Initialization parameter for BVALU
  !        ERR - Is a requested pseudorelative error tolerance.  Normally
  !              pick a value of ABS(ERR)<1E-3.  ANS will normally
  !              have no more error than ABS(ERR) times the integral of
  !              the absolute value of FUN(X)*BVALU(XT,BC,N,KK,X,ID,
  !              INBV,WORK).
  !
  !
  !        OUTPUT--
  !        ERR - Will be an estimate of the absolute error in ANS if the
  !              input value of ERR was negative.  (ERR is unchanged if
  !              the input value of ERR was nonnegative.)  The estimated
  !              error is solely for information to the user and should
  !              not be used as a correction to the computed integral.
  !        ANS - Computed value of integral
  !        IERR- A status code
  !            --Normal Codes
  !               1 ANS most likely meets requested error tolerance,
  !                 or A=B.
  !              -1 A and B are too nearly equal to allow normal
  !                 integration.  ANS is set to zero.
  !            --Abnormal Code
  !               2 ANS probably does not meet requested error tolerance.
  !        WORK- Work vector of length 3*K for BVALU
  !
  !***
  ! **See also:**  BFQAD
  !***
  ! **Routines called:**  BVALU, I1MACH, R1MACH, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   800901  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900326  Removed duplicate information from DESCRIPTION section.  (WRB)
  !   900328  Added TYPE section.  (WRB)
  !   910408  Updated the AUTHOR section.  (WRB)
  USE service, ONLY : log10_radix_sp, eps_sp, digits_sp
  !
  INTERFACE
    PURE REAL(SP) FUNCTION FUN(X)
      IMPORT SP
      REAL(SP), INTENT(IN) :: X
    END FUNCTION
  END INTERFACE
  INTEGER, INTENT(IN) :: Id, Kk, N
  INTEGER, INTENT(OUT) :: Ierr
  REAL(SP), INTENT(IN) :: A, B, Bc(N), Xt(N+Kk)
  REAL(SP), INTENT(INOUT) :: Err
  REAL(SP), INTENT(OUT) :: Ans
  !
  INTEGER :: k, l, lmn, lmx, lr(30), mxl, nbits, nib, nlmx
  REAL(SP) :: aa(30), ae, anib, area, c, ce, ee, ef, eps, est, gl, glr, gr(30), &
    hh(30), tol, vl(30), vr
  REAL(SP), PARAMETER :: x1 = 1.83434642495649805E-01_SP, x2 = 5.25532409916328986E-01_SP, &
    x3 =7.96666477413626740E-01_SP , x4 = 9.60289856497536232E-01_SP
  REAL(SP), PARAMETER ::  w1 =3.62683783378361983E-01_SP , w2 = 3.13706645877887287E-01_SP, &
    w3 = 2.22381034453374471E-01_SP, w4 = 1.01228536290376259E-01_SP
  REAL(SP), PARAMETER :: sq2 = 1.41421356_SP
  INTEGER, PARAMETER :: nlmn = 1, kmx = 5000, kml = 6
  !
  !     INITIALIZE
  !
  !* FIRST EXECUTABLE STATEMENT  BSGQ8
  k = digits_sp
  anib = log10_radix_sp*k/0.30102000_SP
  nbits = INT(anib)
  nlmx = (nbits*5)/8
  Ans = 0._SP
  Ierr = 1
  ce = 0._SP
  IF( A==B ) THEN
    IF( Err<0._SP ) Err = ce
    RETURN
  ELSE
    lmx = nlmx
    lmn = nlmn
    IF( B/=0._SP ) THEN
      IF( SIGN(1._SP,B)*A>0._SP ) THEN
        c = ABS(1._SP-A/B)
        IF( c<=0.1_SP ) THEN
          IF( c<=0._SP ) THEN
            IF( Err<0._SP ) Err = ce
            RETURN
          ELSE
            anib = 0.5_SP - LOG(c)/0.69314718_SP
            nib = INT(anib)
            lmx = MIN(nlmx,nbits-nib-7)
            IF( lmx<1 ) THEN
              Ierr = -1
              ! CALL XERMSG('BSGQ8','A AND B ARE TOO NEARLY EQUAL TO ALLOW NORMAL&
                ! &INTEGRATION.  ANS IS SET TO ZERO AND IERR TO -1.',1,-1)
              IF( Err<0._SP ) Err = ce
              RETURN
            ELSE
              lmn = MIN(lmn,lmx)
            END IF
          END IF
        END IF
      END IF
    END IF
    tol = MAX(ABS(Err),2._SP**(5-nbits))/2._SP
    IF( Err==0._SP ) tol = SQRT(eps_sp)
    eps = tol
    hh(1) = (B-A)/4._SP
    aa(1) = A
    lr(1) = 1
    l = 1
    est = G8(aa(l)+2._SP*hh(l),2._SP*hh(l))
    k = 8
    area = ABS(est)
    ef = 0.5_SP
    mxl = 0
  END IF
  100 CONTINUE
  DO
    !
    !     COMPUTE REFINED ESTIMATES, ESTIMATE THE ERROR, ETC.
    !
    gl = G8(aa(l)+hh(l),hh(l))
    gr(l) = G8(aa(l)+3._SP*hh(l),hh(l))
    k = k + 16
    area = area + (ABS(gl)+ABS(gr(l))-ABS(est))
    glr = gl + gr(l)
    ee = ABS(est-glr)*ef
    ae = MAX(eps*area,tol*ABS(glr))
    IF( ee<=ae ) EXIT
    !
    !     CONSIDER THE LEFT HALF OF THIS LEVEL
    !
    IF( k>kmx ) lmx = kml
    IF( l>=lmx ) THEN
      mxl = 1
      EXIT
    ELSE
      l = l + 1
      eps = eps*0.5_SP
      ef = ef/sq2
      hh(l) = hh(l-1)*0.5_SP
      lr(l) = -1
      aa(l) = aa(l-1)
      est = gl
    END IF
  END DO
  ce = ce + (est-glr)
  IF( lr(l)<=0 ) THEN
    !
    !     PROCEED TO RIGHT HALF AT THIS LEVEL
    !
    vl(l) = glr
  ELSE
    !
    !     RETURN ONE LEVEL
    !
    vr = glr
    DO WHILE( l>1 )
      l = l - 1
      eps = eps*2._SP
      ef = ef*sq2
      IF( lr(l)<=0 ) THEN
        vl(l) = vl(l+1) + vr
        GOTO 200
      ELSE
        vr = vl(l+1) + vr
      END IF
    END DO
    !
    !      EXIT
    !
    Ans = vr
    IF( (mxl/=0) .AND. (ABS(ce)>2._SP*tol*area) ) THEN
      Ierr = 2
      ! CALL XERMSG('BSGQ8','ANS IS PROBABLY INSUFFICIENTLY ACCURATE.',3,1)
    END IF
    IF( Err<0._SP ) Err = ce
    RETURN
  END IF
  200  est = gr(l-1)
  lr(l) = 1
  aa(l) = aa(l) + 4._SP*hh(l)
  GOTO 100
  RETURN
CONTAINS
  PURE REAL(SP) FUNCTION G8(x,h)
    REAL(SP), INTENT(IN) :: x, h
    G8 = h*((w1*(FUN(x-x1*h)*BVALU(Xt,Bc,N,Kk,Id,x-x1*h)+FUN(x+&
      x1*h)*BVALU(Xt,Bc,N,Kk,Id,x+x1*h))&
      +w2*(FUN(x-x2*h)*BVALU(Xt,Bc,N,Kk,Id,x-x2*h)&
      +FUN(x+x2*h)*BVALU(Xt,Bc,N,Kk,Id,x+x2*h)))&
      +(w3*(FUN(x-x3*h)*BVALU(Xt,Bc,N,Kk,Id,x-x3*h)&
      +FUN(x+x3*h)*BVALU(Xt,Bc,N,Kk,Id,x+x3*h))&
      +w4*(FUN(x-x4*h)*BVALU(Xt,Bc,N,Kk,Id,x-x4*h)&
      +FUN(x+x4*h)*BVALU(Xt,Bc,N,Kk,Id,x+x4*h))))
  END FUNCTION G8

END SUBROUTINE BSGQ8