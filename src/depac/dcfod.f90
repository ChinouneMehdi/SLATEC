!DECK DCFOD
SUBROUTINE DCFOD(Meth,Elco,Tesco)
  IMPLICIT NONE
  !***BEGIN PROLOGUE  DCFOD
  !***SUBSIDIARY
  !***PURPOSE  Subsidiary to DDEBDF
  !***LIBRARY   SLATEC
  !***TYPE      DOUBLE PRECISION (CFOD-S, DCFOD-D)
  !***AUTHOR  (UNKNOWN)
  !***DESCRIPTION
  !
  !   DCFOD defines coefficients needed in the integrator package DDEBDF
  !
  !***SEE ALSO  DDEBDF
  !***ROUTINES CALLED  (NONE)
  !***REVISION HISTORY  (YYMMDD)
  !   820301  DATE WRITTEN
  !   890911  Removed unnecessary intrinsics.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  !***END PROLOGUE  DCFOD
  !
  !
  INTEGER i, ib, Meth, nq, nqm1, nqp1
  REAL(8) :: agamq, Elco, fnq, fnqm1, pc, pint, ragq, rq1fac, &
    rqfac, Tesco, tsign, xpin
  DIMENSION Elco(13,12), Tesco(3,12)
  !     ------------------------------------------------------------------
  !      DCFOD  IS CALLED BY THE INTEGRATOR ROUTINE TO SET COEFFICIENTS
  !      NEEDED THERE.  THE COEFFICIENTS FOR THE CURRENT METHOD, AS
  !      GIVEN BY THE VALUE OF METH, ARE SET FOR ALL ORDERS AND SAVED.
  !      THE MAXIMUM ORDER ASSUMED HERE IS 12 IF METH = 1 AND 5 IF METH =
  !      2.  (A SMALLER VALUE OF THE MAXIMUM ORDER IS ALSO ALLOWED.)
  !      DCFOD  IS CALLED ONCE AT THE BEGINNING OF THE PROBLEM,
  !      AND IS NOT CALLED AGAIN UNLESS AND UNTIL METH IS CHANGED.
  !
  !      THE ELCO ARRAY CONTAINS THE BASIC METHOD COEFFICIENTS.
  !      THE COEFFICIENTS EL(I), 1 .LE. I .LE. NQ+1, FOR THE METHOD OF
  !      ORDER NQ ARE STORED IN ELCO(I,NQ).  THEY ARE GIVEN BY A
  !      GENERATING POLYNOMIAL, I.E.,
  !          L(X) = EL(1) + EL(2)*X + ... + EL(NQ+1)*X**NQ.
  !      FOR THE IMPLICIT ADAMS METHODS, L(X) IS GIVEN BY
  !          DL/DX = (X+1)*(X+2)*...*(X+NQ-1)/FACTORIAL(NQ-1),    L(-1) =
  !      0.  FOR THE BDF METHODS, L(X) IS GIVEN BY
  !          L(X) = (X+1)*(X+2)* ... *(X+NQ)/K,
  !      WHERE         K = FACTORIAL(NQ)*(1 + 1/2 + ... + 1/NQ).
  !
  !      THE TESCO ARRAY CONTAINS TEST CONSTANTS USED FOR THE
  !      LOCAL ERROR TEST AND THE SELECTION OF STEP SIZE AND/OR ORDER.
  !      AT ORDER NQ, TESCO(K,NQ) IS USED FOR THE SELECTION OF STEP
  !      SIZE AT ORDER NQ - 1 IF K = 1, AT ORDER NQ IF K = 2, AND AT ORDER
  !      NQ + 1 IF K = 3.
  !     ------------------------------------------------------------------
  DIMENSION pc(12)
  !
  !***FIRST EXECUTABLE STATEMENT  DCFOD
  IF ( Meth==2 ) THEN
    !
    pc(1) = 1.0D0
    rq1fac = 1.0D0
    DO nq = 1, 5
      !           ------------------------------------------------------------
      !            THE PC ARRAY WILL CONTAIN THE COEFFICIENTS OF THE
      !                POLYNOMIAL P(X) = (X+1)*(X+2)*...*(X+NQ).
      !            INITIALLY, P(X) = 1.
      !           ------------------------------------------------------------
      fnq = nq
      nqp1 = nq + 1
      !           FORM COEFFICIENTS OF P(X)*(X+NQ).
      !           ------------------------------------
      pc(nqp1) = 0.0D0
      DO ib = 1, nq
        i = nq + 2 - ib
        pc(i) = pc(i-1) + fnq*pc(i)
      ENDDO
      pc(1) = fnq*pc(1)
      !           STORE COEFFICIENTS IN ELCO AND TESCO.
      !           --------------------------------
      DO i = 1, nqp1
        Elco(i,nq) = pc(i)/pc(2)
      ENDDO
      Elco(2,nq) = 1.0D0
      Tesco(1,nq) = rq1fac
      Tesco(2,nq) = nqp1/Elco(1,nq)
      Tesco(3,nq) = (nq+2)/Elco(1,nq)
      rq1fac = rq1fac/fnq
    ENDDO
  ELSE
    !
    Elco(1,1) = 1.0D0
    Elco(2,1) = 1.0D0
    Tesco(1,1) = 0.0D0
    Tesco(2,1) = 2.0D0
    Tesco(1,2) = 1.0D0
    Tesco(3,12) = 0.0D0
    pc(1) = 1.0D0
    rqfac = 1.0D0
    DO nq = 2, 12
      !           ------------------------------------------------------------
      !            THE PC ARRAY WILL CONTAIN THE COEFFICIENTS OF THE
      !                POLYNOMIAL P(X) = (X+1)*(X+2)*...*(X+NQ-1).
      !            INITIALLY, P(X) = 1.
      !           ------------------------------------------------------------
      rq1fac = rqfac
      rqfac = rqfac/nq
      nqm1 = nq - 1
      fnqm1 = nqm1
      nqp1 = nq + 1
      !           FORM COEFFICIENTS OF P(X)*(X+NQ-1).
      !           ----------------------------------
      pc(nq) = 0.0D0
      DO ib = 1, nqm1
        i = nqp1 - ib
        pc(i) = pc(i-1) + fnqm1*pc(i)
      ENDDO
      pc(1) = fnqm1*pc(1)
      !           COMPUTE INTEGRAL, -1 TO 0, OF P(X) AND X*P(X).
      !           -----------------------
      pint = pc(1)
      xpin = pc(1)/2.0D0
      tsign = 1.0D0
      DO i = 2, nq
        tsign = -tsign
        pint = pint + tsign*pc(i)/i
        xpin = xpin + tsign*pc(i)/(i+1)
      ENDDO
      !           STORE COEFFICIENTS IN ELCO AND TESCO.
      !           --------------------------------
      Elco(1,nq) = pint*rq1fac
      Elco(2,nq) = 1.0D0
      DO i = 2, nq
        Elco(i+1,nq) = rq1fac*pc(i)/i
      ENDDO
      agamq = rqfac*xpin
      ragq = 1.0D0/agamq
      Tesco(2,nq) = ragq
      IF ( nq<12 ) Tesco(1,nqp1) = ragq*rqfac/nqp1
      Tesco(3,nqm1) = ragq
    ENDDO
  ENDIF
  !     ----------------------- END OF SUBROUTINE DCFOD
  !     -----------------------
END SUBROUTINE DCFOD