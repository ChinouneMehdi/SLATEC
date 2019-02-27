!DECK CFOD
SUBROUTINE CFOD(Meth,Elco,Tesco)
  IMPLICIT NONE
  !***BEGIN PROLOGUE  CFOD
  !***SUBSIDIARY
  !***PURPOSE  Subsidiary to DEBDF
  !***LIBRARY   SLATEC
  !***TYPE      SINGLE PRECISION (CFOD-S, DCFOD-D)
  !***AUTHOR  (UNKNOWN)
  !***DESCRIPTION
  !
  !   CFOD defines coefficients needed in the integrator package DEBDF
  !
  !***SEE ALSO  DEBDF
  !***ROUTINES CALLED  (NONE)
  !***REVISION HISTORY  (YYMMDD)
  !   800901  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  !***END PROLOGUE  CFOD
  !
  !
  !LLL. OPTIMIZE
  INTEGER Meth, i, ib, nq, nqm1, nqp1
  REAL Elco, Tesco, agamq, fnq, fnqm1, pc, pint, ragq, rqfac, &
    rq1fac, tsign, xpin
  DIMENSION Elco(13,12), Tesco(3,12)
  !-----------------------------------------------------------------------
  ! CFOD  IS CALLED BY THE INTEGRATOR ROUTINE TO SET COEFFICIENTS
  ! NEEDED THERE.  THE COEFFICIENTS FOR THE CURRENT METHOD, AS
  ! GIVEN BY THE VALUE OF METH, ARE SET FOR ALL ORDERS AND SAVED.
  ! THE MAXIMUM ORDER ASSUMED HERE IS 12 IF METH = 1 AND 5 IF METH = 2.
  ! (A SMALLER VALUE OF THE MAXIMUM ORDER IS ALSO ALLOWED.)
  ! CFOD  IS CALLED ONCE AT THE BEGINNING OF THE PROBLEM,
  ! AND IS NOT CALLED AGAIN UNLESS AND UNTIL METH IS CHANGED.
  !
  ! THE ELCO ARRAY CONTAINS THE BASIC METHOD COEFFICIENTS.
  ! THE COEFFICIENTS EL(I), 1 .LE. I .LE. NQ+1, FOR THE METHOD OF
  ! ORDER NQ ARE STORED IN ELCO(I,NQ).  THEY ARE GIVEN BY A GENERATING
  ! POLYNOMIAL, I.E.,
  !     L(X) = EL(1) + EL(2)*X + ... + EL(NQ+1)*X**NQ.
  ! FOR THE IMPLICIT ADAMS METHODS, L(X) IS GIVEN BY
  !     DL/DX = (X+1)*(X+2)*...*(X+NQ-1)/FACTORIAL(NQ-1),    L(-1) = 0.
  ! FOR THE BDF METHODS, L(X) IS GIVEN BY
  !     L(X) = (X+1)*(X+2)* ... *(X+NQ)/K,
  ! WHERE         K = FACTORIAL(NQ)*(1 + 1/2 + ... + 1/NQ).
  !
  ! THE TESCO ARRAY CONTAINS TEST CONSTANTS USED FOR THE
  ! LOCAL ERROR TEST AND THE SELECTION OF STEP SIZE AND/OR ORDER.
  ! AT ORDER NQ, TESCO(K,NQ) IS USED FOR THE SELECTION OF STEP
  ! SIZE AT ORDER NQ - 1 IF K = 1, AT ORDER NQ IF K = 2, AND AT ORDER
  ! NQ + 1 IF K = 3.
  !-----------------------------------------------------------------------
  DIMENSION pc(12)
  !
  !***FIRST EXECUTABLE STATEMENT  CFOD
  IF ( Meth==2 ) THEN
    !
    pc(1) = 1.0E0
    rq1fac = 1.0E0
    DO nq = 1, 5
      !-----------------------------------------------------------------------
      ! THE PC ARRAY WILL CONTAIN THE COEFFICIENTS OF THE POLYNOMIAL
      !     P(X) = (X+1)*(X+2)*...*(X+NQ).
      ! INITIALLY, P(X) = 1.
      !-----------------------------------------------------------------------
      fnq = nq
      nqp1 = nq + 1
      ! FORM COEFFICIENTS OF P(X)*(X+NQ). ------------------------------------
      pc(nqp1) = 0.0E0
      DO ib = 1, nq
        i = nq + 2 - ib
        pc(i) = pc(i-1) + fnq*pc(i)
      ENDDO
      pc(1) = fnq*pc(1)
      ! STORE COEFFICIENTS IN ELCO AND TESCO. --------------------------------
      DO i = 1, nqp1
        Elco(i,nq) = pc(i)/pc(2)
      ENDDO
      Elco(2,nq) = 1.0E0
      Tesco(1,nq) = rq1fac
      Tesco(2,nq) = nqp1/Elco(1,nq)
      Tesco(3,nq) = (nq+2)/Elco(1,nq)
      rq1fac = rq1fac/fnq
    ENDDO
    GOTO 99999
  ENDIF
  !
  Elco(1,1) = 1.0E0
  Elco(2,1) = 1.0E0
  Tesco(1,1) = 0.0E0
  Tesco(2,1) = 2.0E0
  Tesco(1,2) = 1.0E0
  Tesco(3,12) = 0.0E0
  pc(1) = 1.0E0
  rqfac = 1.0E0
  DO nq = 2, 12
    !-----------------------------------------------------------------------
    ! THE PC ARRAY WILL CONTAIN THE COEFFICIENTS OF THE POLYNOMIAL
    !     P(X) = (X+1)*(X+2)*...*(X+NQ-1).
    ! INITIALLY, P(X) = 1.
    !-----------------------------------------------------------------------
    rq1fac = rqfac
    rqfac = rqfac/nq
    nqm1 = nq - 1
    fnqm1 = nqm1
    nqp1 = nq + 1
    ! FORM COEFFICIENTS OF P(X)*(X+NQ-1). ----------------------------------
    pc(nq) = 0.0E0
    DO ib = 1, nqm1
      i = nqp1 - ib
      pc(i) = pc(i-1) + fnqm1*pc(i)
    ENDDO
    pc(1) = fnqm1*pc(1)
    ! COMPUTE INTEGRAL, -1 TO 0, OF P(X) AND X*P(X). -----------------------
    pint = pc(1)
    xpin = pc(1)/2.0E0
    tsign = 1.0E0
    DO i = 2, nq
      tsign = -tsign
      pint = pint + tsign*pc(i)/i
      xpin = xpin + tsign*pc(i)/(i+1)
    ENDDO
    ! STORE COEFFICIENTS IN ELCO AND TESCO. --------------------------------
    Elco(1,nq) = pint*rq1fac
    Elco(2,nq) = 1.0E0
    DO i = 2, nq
      Elco(i+1,nq) = rq1fac*pc(i)/i
    ENDDO
    agamq = rqfac*xpin
    ragq = 1.0E0/agamq
    Tesco(2,nq) = ragq
    IF ( nq<12 ) Tesco(1,nqp1) = ragq*rqfac/nqp1
    Tesco(3,nqm1) = ragq
  ENDDO
  RETURN
  !----------------------- END OF SUBROUTINE CFOD  -----------------------
  99999 CONTINUE
  END SUBROUTINE CFOD