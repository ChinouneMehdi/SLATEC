!** GAUS8
PURE SUBROUTINE GAUS8(FUN,A,B,Err,Ans,Ierr)
  !> Integrate a real function of one variable over a finite interval using an
  !  adaptive 8-point Legendre-Gauss algorithm.
  !  Intended primarily for high accuracy integration or integration of smooth functions.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  H2A1A1
  !***
  ! **Type:**      SINGLE PRECISION (GAUS8-S, DGAUS8-D)
  !***
  ! **Keywords:**  ADAPTIVE QUADRATURE, AUTOMATIC INTEGRATOR,
  !             GAUSS QUADRATURE, NUMERICAL INTEGRATION
  !***
  ! **Author:**  Jones, R. E., (SNLA)
  !***
  ! **Description:**
  !
  !     Abstract
  !        GAUS8 integrates real functions of one variable over finite
  !        intervals using an adaptive 8-point Legendre-Gauss algorithm.
  !        GAUS8 is intended primarily for high accuracy integration
  !        or integration of smooth functions.
  !
  !     Description of Arguments
  !
  !        Input--
  !        FUN - name of external function to be integrated.  This name
  !              must be in an EXTERNAL statement in the calling program.
  !              FUN must be a REAL function of one REAL argument.  The
  !              value of the argument to FUN is the variable of
  !              integration which ranges from A to B.
  !        A   - lower limit of integration
  !        B   - upper limit of integration (may be less than A)
  !        ERR - is a requested pseudorelative error tolerance.  Normally
  !              pick a value of ABS(ERR) so that STOL < ABS(ERR) <=
  !              1.0E-3 where STOL is the single precision unit roundoff
  !              eps_sp.  ANS will normally have no more error than
  !              ABS(ERR) times the integral of the absolute value of
  !              FUN(X).  Usually, smaller values for ERR yield more
  !              accuracy and require more function evaluations.
  !
  !              A negative value for ERR causes an estimate of the
  !              absolute error in ANS to be returned in ERR.  Note that
  !              ERR must be a variable (not a constant) in this case.
  !              Note also that the user must reset the value of ERR
  !              before making any more calls that use the variable ERR.
  !
  !        Output--
  !        ERR - will be an estimate of the absolute error in ANS if the
  !              input value of ERR was negative.  (ERR is unchanged if
  !              the input value of ERR was non-negative.)  The estimated
  !              error is solely for information to the user and should
  !              not be used as a correction to the computed integral.
  !        ANS - computed value of integral
  !        IERR- a status code
  !            --Normal codes
  !               1 ANS most likely meets requested error tolerance, or A=B.
  !              -1 A and B are too nearly equal to allow normal integration.
  !                 ANS is set to zero.
  !            --Abnormal code
  !               2 ANS probably does not meet requested error tolerance.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  I1MACH, R1MACH, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   810223  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900326  Removed duplicate information from DESCRIPTIONsection.  (WRB)
  USE service, ONLY : log10_radix_sp, eps_sp, digits_sp
  !
  INTERFACE
    REAL(SP) PURE FUNCTION FUN(X)
      IMPORT SP
      REAL(SP), INTENT(IN) :: X
    END FUNCTION FUN
  END INTERFACE
  INTEGER, INTENT(OUT) :: Ierr
  REAL(SP), INTENT(IN) :: A, B
  REAL(SP), INTENT(INOUT) :: Err
  REAL(SP), INTENT(OUT) :: Ans
  !
  INTEGER :: k, l, lmn, lmx, lr(30), mxl, nbits, nib, nlmx
  REAL(SP) :: ae, anib, area, c, ce, ee, ef, eps, est, gl, glr, tol, vr
  REAL(SP) :: aa(30), gr(30), hh(30), vl(30)
  REAL(SP), PARAMETER :: x1 = 1.83434642495649805E-01_SP, x2 = 5.25532409916328986E-01_SP, &
    x3 =7.96666477413626740E-01_SP, x4 = 9.60289856497536232E-01_SP
  REAL(SP), PARAMETER ::  w1 =3.62683783378361983E-01_SP, w2 = 3.13706645877887287E-01_SP, &
    w3 = 2.22381034453374471E-01_SP, w4 = 1.01228536290376259E-01_SP
  REAL(SP), PARAMETER :: sq2 = 1.41421356_SP
  INTEGER, PARAMETER :: nlmn = 1, kmx = 5000, kml = 6
  !* FIRST EXECUTABLE STATEMENT  GAUS8
  !
  !     Initialize
  !
  k = digits_sp
  anib = log10_radix_sp*k/0.30102000_SP
  nbits = INT( anib )
  nlmx = MIN(30,(nbits*5)/8)
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
            nib = INT( anib )
            lmx = MIN(nlmx,nbits-nib-7)
            IF( lmx<1 ) THEN
              Ierr = -1
              ! 'GAUS8 : A and B are too nearly equal to allow normal integration.&
                ! & ANS is set to zero and IERR to -1.'
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
    !     Compute refined estimates, estimate the error, etc.
    !
    gl = G8(aa(l)+hh(l),hh(l))
    gr(l) = G8(aa(l)+3._SP*hh(l),hh(l))
    k = k + 16
    area = area + (ABS(gl)+ABS(gr(l))-ABS(est))
    !     IF(L < LMN) GO TO 11
    glr = gl + gr(l)
    ee = ABS(est-glr)*ef
    ae = MAX(eps*area,tol*ABS(glr))
    IF( ee<=ae ) EXIT
    !
    !     Consider the left half of this level
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
    !     Proceed to right half at this level
    !
    vl(l) = glr
  ELSE
    !
    !     Return one level
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
    !     Exit
    !
    Ans = vr
    IF( (mxl/=0) .AND. (ABS(ce)>2._SP*tol*area) ) THEN
      Ierr = 2
      ERROR STOP 'GAUS8 : ANS is probably insufficiently accurate.'
    END IF
    IF( Err<0._SP ) Err = ce
    RETURN
  END IF
  200  est = gr(l-1)
  lr(l) = 1
  aa(l) = aa(l) + 4._SP*hh(l)
  GOTO 100
  !
  RETURN
CONTAINS
  REAL(SP) ELEMENTAL FUNCTION G8(x,h)
    REAL(SP), INTENT(IN) :: x, h
    G8 = h*((w1*(FUN(x-x1*h)+FUN(x+x1*h))+w2*(FUN(x-x2*h)+FUN(x+x2*h)))&
      +(w3*(FUN(x-x3*h)+FUN(x+x3*h))+w4*(FUN(x-x4*h)+FUN(x+x4*h))))
  END FUNCTION G8
END SUBROUTINE GAUS8