!*==PCHKT.f90  processed by SPAG 6.72Dc at 11:00 on  6 Feb 2019
!DECK PCHKT
SUBROUTINE PCHKT(N,X,Knotyp,T)
  IMPLICIT NONE
  !*--PCHKT5
  !***BEGIN PROLOGUE  PCHKT
  !***SUBSIDIARY
  !***PURPOSE  Compute B-spline knot sequence for PCHBS.
  !***LIBRARY   SLATEC (PCHIP)
  !***CATEGORY  E3
  !***TYPE      SINGLE PRECISION (PCHKT-S, DPCHKT-D)
  !***AUTHOR  Fritsch, F. N., (LLNL)
  !***DESCRIPTION
  !
  !     Set a knot sequence for the B-spline representation of a PCH
  !     function with breakpoints X.  All knots will be at least double.
  !     Endknots are set as:
  !        (1) quadruple knots at endpoints if KNOTYP=0;
  !        (2) extrapolate the length of end interval if KNOTYP=1;
  !        (3) periodic if KNOTYP=2.
  !
  !  Input arguments:  N, X, KNOTYP.
  !  Output arguments:  T.
  !
  !  Restrictions/assumptions:
  !     1. N.GE.2 .  (not checked)
  !     2. X(i).LT.X(i+1), i=1,...,N .  (not checked)
  !     3. 0.LE.KNOTYP.LE.2 .  (Acts like KNOTYP=0 for any other value.)
  !
  !***SEE ALSO  PCHBS
  !***ROUTINES CALLED  (NONE)
  !***REVISION HISTORY  (YYMMDD)
  !   870701  DATE WRITTEN
  !   900405  Converted Fortran to upper case.
  !   900410  Converted prologue to SLATEC 4.0 format.
  !   900410  Minor cosmetic changes.
  !   930514  Changed NKNOTS from an output to an input variable.  (FNF)
  !   930604  Removed unused variable NKNOTS from argument list.  (FNF)
  !***END PROLOGUE  PCHKT
  !
  !*Internal Notes:
  !
  !  Since this is subsidiary to PCHBS, which validates its input before
  !  calling, it is unnecessary for such validation to be done here.
  !
  !**End
  !
  !  Declare arguments.
  !
  INTEGER N, Knotyp
  REAL X(*), T(*)
  !
  !  Declare local variables.
  !
  INTEGER j, k, ndim
  REAL hbeg, hend
  !***FIRST EXECUTABLE STATEMENT  PCHKT
  !
  !  Initialize.
  !
  ndim = 2*N
  !
  !  Set interior knots.
  !
  j = 1
  DO k = 1, N
    j = j + 2
    T(j) = X(k)
    T(j+1) = T(j)
  ENDDO
  !     Assertion:  At this point T(3),...,T(NDIM+2) have been set and
  !                 J=NDIM+1.
  !
  !  Set end knots according to KNOTYP.
  !
  hbeg = X(2) - X(1)
  hend = X(N) - X(N-1)
  IF ( Knotyp==1 ) THEN
    !          Extrapolate.
    T(2) = X(1) - hbeg
    T(ndim+3) = X(N) + hend
  ELSEIF ( Knotyp==2 ) THEN
    !          Periodic.
    T(2) = X(1) - hend
    T(ndim+3) = X(N) + hbeg
  ELSE
    !          Quadruple end knots.
    T(2) = X(1)
    T(ndim+3) = X(N)
  ENDIF
  T(1) = T(2)
  T(ndim+4) = T(ndim+3)
  !
  !  Terminate.
  !
  !------------- LAST LINE OF PCHKT FOLLOWS ------------------------------
END SUBROUTINE PCHKT
