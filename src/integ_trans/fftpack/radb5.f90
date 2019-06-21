!** RADB5
SUBROUTINE RADB5(Ido,L1,Cc,Ch,Wa1,Wa2,Wa3,Wa4)
  !> Calculate the fast Fourier transform of subvectors of
  !            length five.
  !***
  ! **Library:**   SLATEC (FFTPACK)
  !***
  ! **Type:**      SINGLE PRECISION (RADB5-S)
  !***
  ! **Author:**  Swarztrauber, P. N., (NCAR)
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   790601  DATE WRITTEN
  !   830401  Modified to use SLATEC library source file format.
  !   860115  Modified by Ron Boisvert to adhere to Fortran 77 by
  !           (a) changing dummy array size declarations (1) to (*),
  !           (b) changing definition of variables PI, TI11, TI12,
  !               TR11, TR12 by using FORTRAN intrinsic functions ATAN
  !               and SIN instead of DATA statements.
  !   881128  Modified by Dick Valent to meet prologue standards.
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900402  Added TYPE section.  (WRB)

  INTEGER :: Ido, L1
  REAL(SP) :: Cc(Ido,5,L1), Ch(Ido,L1,5), Wa1(Ido), Wa2(Ido), Wa3(Ido), Wa4(Ido)
  INTEGER :: i, ic, idp2, k
  REAL(SP) :: ci2, ci3, ci4, ci5, cr2, cr3, cr4, cr5, di2, di3, di4, di5, dr2, dr3, &
    dr4, dr5, pi, ti11, ti12, ti2, ti3, ti4, ti5, tr11, tr12, tr2, tr3, tr4, tr5
  !* FIRST EXECUTABLE STATEMENT  RADB5
  pi = 4._SP*ATAN(1._SP)
  tr11 = SIN(0.1_SP*pi)
  ti11 = SIN(0.4_SP*pi)
  tr12 = -SIN(0.3_SP*pi)
  ti12 = SIN(0.2_SP*pi)
  DO k = 1, L1
    ti5 = Cc(1,3,k) + Cc(1,3,k)
    ti4 = Cc(1,5,k) + Cc(1,5,k)
    tr2 = Cc(Ido,2,k) + Cc(Ido,2,k)
    tr3 = Cc(Ido,4,k) + Cc(Ido,4,k)
    Ch(1,k,1) = Cc(1,1,k) + tr2 + tr3
    cr2 = Cc(1,1,k) + tr11*tr2 + tr12*tr3
    cr3 = Cc(1,1,k) + tr12*tr2 + tr11*tr3
    ci5 = ti11*ti5 + ti12*ti4
    ci4 = ti12*ti5 - ti11*ti4
    Ch(1,k,2) = cr2 - ci5
    Ch(1,k,3) = cr3 - ci4
    Ch(1,k,4) = cr3 + ci4
    Ch(1,k,5) = cr2 + ci5
  END DO
  IF( Ido==1 ) RETURN
  idp2 = Ido + 2
  IF( (Ido-1)/2<L1 ) THEN
    DO i = 3, Ido, 2
      ic = idp2 - i
      DO k = 1, L1
        ti5 = Cc(i,3,k) + Cc(ic,2,k)
        ti2 = Cc(i,3,k) - Cc(ic,2,k)
        ti4 = Cc(i,5,k) + Cc(ic,4,k)
        ti3 = Cc(i,5,k) - Cc(ic,4,k)
        tr5 = Cc(i-1,3,k) - Cc(ic-1,2,k)
        tr2 = Cc(i-1,3,k) + Cc(ic-1,2,k)
        tr4 = Cc(i-1,5,k) - Cc(ic-1,4,k)
        tr3 = Cc(i-1,5,k) + Cc(ic-1,4,k)
        Ch(i-1,k,1) = Cc(i-1,1,k) + tr2 + tr3
        Ch(i,k,1) = Cc(i,1,k) + ti2 + ti3
        cr2 = Cc(i-1,1,k) + tr11*tr2 + tr12*tr3
        ci2 = Cc(i,1,k) + tr11*ti2 + tr12*ti3
        cr3 = Cc(i-1,1,k) + tr12*tr2 + tr11*tr3
        ci3 = Cc(i,1,k) + tr12*ti2 + tr11*ti3
        cr5 = ti11*tr5 + ti12*tr4
        ci5 = ti11*ti5 + ti12*ti4
        cr4 = ti12*tr5 - ti11*tr4
        ci4 = ti12*ti5 - ti11*ti4
        dr3 = cr3 - ci4
        dr4 = cr3 + ci4
        di3 = ci3 + cr4
        di4 = ci3 - cr4
        dr5 = cr2 + ci5
        dr2 = cr2 - ci5
        di5 = ci2 - cr5
        di2 = ci2 + cr5
        Ch(i-1,k,2) = Wa1(i-2)*dr2 - Wa1(i-1)*di2
        Ch(i,k,2) = Wa1(i-2)*di2 + Wa1(i-1)*dr2
        Ch(i-1,k,3) = Wa2(i-2)*dr3 - Wa2(i-1)*di3
        Ch(i,k,3) = Wa2(i-2)*di3 + Wa2(i-1)*dr3
        Ch(i-1,k,4) = Wa3(i-2)*dr4 - Wa3(i-1)*di4
        Ch(i,k,4) = Wa3(i-2)*di4 + Wa3(i-1)*dr4
        Ch(i-1,k,5) = Wa4(i-2)*dr5 - Wa4(i-1)*di5
        Ch(i,k,5) = Wa4(i-2)*di5 + Wa4(i-1)*dr5
      END DO
    END DO
    RETURN
  END IF
  DO k = 1, L1
    DO i = 3, Ido, 2
      ic = idp2 - i
      ti5 = Cc(i,3,k) + Cc(ic,2,k)
      ti2 = Cc(i,3,k) - Cc(ic,2,k)
      ti4 = Cc(i,5,k) + Cc(ic,4,k)
      ti3 = Cc(i,5,k) - Cc(ic,4,k)
      tr5 = Cc(i-1,3,k) - Cc(ic-1,2,k)
      tr2 = Cc(i-1,3,k) + Cc(ic-1,2,k)
      tr4 = Cc(i-1,5,k) - Cc(ic-1,4,k)
      tr3 = Cc(i-1,5,k) + Cc(ic-1,4,k)
      Ch(i-1,k,1) = Cc(i-1,1,k) + tr2 + tr3
      Ch(i,k,1) = Cc(i,1,k) + ti2 + ti3
      cr2 = Cc(i-1,1,k) + tr11*tr2 + tr12*tr3
      ci2 = Cc(i,1,k) + tr11*ti2 + tr12*ti3
      cr3 = Cc(i-1,1,k) + tr12*tr2 + tr11*tr3
      ci3 = Cc(i,1,k) + tr12*ti2 + tr11*ti3
      cr5 = ti11*tr5 + ti12*tr4
      ci5 = ti11*ti5 + ti12*ti4
      cr4 = ti12*tr5 - ti11*tr4
      ci4 = ti12*ti5 - ti11*ti4
      dr3 = cr3 - ci4
      dr4 = cr3 + ci4
      di3 = ci3 + cr4
      di4 = ci3 - cr4
      dr5 = cr2 + ci5
      dr2 = cr2 - ci5
      di5 = ci2 - cr5
      di2 = ci2 + cr5
      Ch(i-1,k,2) = Wa1(i-2)*dr2 - Wa1(i-1)*di2
      Ch(i,k,2) = Wa1(i-2)*di2 + Wa1(i-1)*dr2
      Ch(i-1,k,3) = Wa2(i-2)*dr3 - Wa2(i-1)*di3
      Ch(i,k,3) = Wa2(i-2)*di3 + Wa2(i-1)*dr3
      Ch(i-1,k,4) = Wa3(i-2)*dr4 - Wa3(i-1)*di4
      Ch(i,k,4) = Wa3(i-2)*di4 + Wa3(i-1)*dr4
      Ch(i-1,k,5) = Wa4(i-2)*dr5 - Wa4(i-1)*di5
      Ch(i,k,5) = Wa4(i-2)*di5 + Wa4(i-1)*dr5
    END DO
  END DO
  RETURN
END SUBROUTINE RADB5
