!** PCOEF
PURE SUBROUTINE PCOEF(L,C,Tc,A)
  !> Convert the POLFIT coefficients to Taylor series form.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  K1A1A2
  !***
  ! **Type:**      SINGLE PRECISION (PCOEF-S, DPCOEF-D)
  !***
  ! **Keywords:**  CURVE FITTING, DATA FITTING, LEAST SQUARES, POLYNOMIAL FIT
  !***
  ! **Author:**  Shampine, L. F., (SNLA)
  !           Davenport, S. M., (SNLA)
  !***
  ! **Description:**
  !
  !     Written BY L. F. Shampine and S. M. Davenport.
  !
  !     Abstract
  !
  !     POLFIT  computes the least squares polynomial fit of degree  L  as
  !     a sum of orthogonal polynomials.  PCOEF  changes this fit to its
  !     Taylor expansion about any point  C, i.e. writes the polynomial
  !     as a sum of powers of (X-C).  Taking  C=0.  gives the polynomial
  !     in powers of X, but a suitable non-zero  C  often leads to
  !     polynomials which are better scaled and more accurately evaluated.
  !
  !     The parameters for  PCOEF  are
  !
  !     INPUT --
  !         L -      Indicates the degree of polynomial to be changed to
  !                  its Taylor expansion.  To obtain the Taylor
  !                  coefficients in reverse order, input  L  as the
  !                  negative of the degree desired.  The absolute value
  !                  of L  must be less than or equal to NDEG, the highest
  !                  degree polynomial fitted by  POLFIT .
  !         C -      The point about which the Taylor expansion is to be
  !                  made.
  !         A -      Work and output array containing values from last
  !                  call to  POLFIT .
  !
  !     OUTPUT --
  !         TC -     Vector containing the first LL+1 Taylor coefficients
  !                  where LL=ABS(L).  If  L>0, the coefficients are
  !                  in the usual Taylor series order, i.e.
  !                    P(X) = TC(1) + TC(2)*(X-C) + ... + TC(N+1)*(X-C)**N
  !                  If L < 0, the coefficients are in reverse order,
  !                  i.e.
  !                    P(X) = TC(1)*(X-C)**N + ... + TC(N)*(X-C) + TC(N+1)
  !
  !***
  ! **References:**  L. F. Shampine, S. M. Davenport and R. E. Huddleston,
  !                 Curve fitting by polynomials in one variable, Report
  !                 SLA-74-0270, Sandia Laboratories, June 1974.
  !***
  ! **Routines called:**  PVALUE

  !* REVISION HISTORY  (YYMMDD)
  !   740601  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER, INTENT(IN) :: L
  REAL(SP), INTENT(IN) :: C
  REAL(SP), INTENT(INOUT) :: A(:)
  REAL(SP), INTENT(OUT) :: Tc(ABS(L)+1)
  !
  REAL(SP) :: fac, save
  INTEGER :: i, ll, llp1, llp2, new, nr
  !* FIRST EXECUTABLE STATEMENT  PCOEF
  ll = ABS(L)
  llp1 = ll + 1
  CALL PVALUE(ll,ll,C,Tc(1),Tc(2),A)
  IF( ll>=2 ) THEN
    fac = 1.0
    DO i = 3, llp1
      fac = fac*(i-1)
      Tc(i) = Tc(i)/fac
    END DO
  END IF
  IF( L<0 ) THEN
    nr = llp1/2
    llp2 = ll + 2
    DO i = 1, nr
      save = Tc(i)
      new = llp2 - i
      Tc(i) = Tc(new)
      Tc(new) = save
    END DO
  END IF
  !
END SUBROUTINE PCOEF