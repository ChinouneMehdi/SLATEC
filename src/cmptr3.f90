!*==CMPTR3.f90  processed by SPAG 6.72Dc at 11:01 on  6 Feb 2019
!DECK CMPTR3
SUBROUTINE CMPTR3(M,A,B,C,K,Y1,Y2,Y3,Tcos,D,W1,W2,W3)
  IMPLICIT NONE
  !*--CMPTR35
  !*** Start of declarations inserted by SPAG
  INTEGER i, ip, K, k1, k2, k2k3k4, k3, k4, kint1, kint2, kint3, &
    l1, l2, l3, lint1, lint2, lint3, M, mm1, n
  !*** End of declarations inserted by SPAG
  !***BEGIN PROLOGUE  CMPTR3
  !***SUBSIDIARY
  !***PURPOSE  Subsidiary to CMGNBN
  !***LIBRARY   SLATEC
  !***TYPE      COMPLEX (TRI3-S, CMPTR3-C)
  !***AUTHOR  (UNKNOWN)
  !***DESCRIPTION
  !
  !     Subroutine to solve tridiagonal systems.
  !
  !***SEE ALSO  CMGNBN
  !***ROUTINES CALLED  (NONE)
  !***REVISION HISTORY  (YYMMDD)
  !   801001  DATE WRITTEN
  !   890206  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900402  Added TYPE section.  (WRB)
  !***END PROLOGUE  CMPTR3
  COMPLEX A, B, C, Y1, Y2, Y3, Tcos, D, W1, W2, W3, x, xx, z
  DIMENSION A(*), B(*), C(*), K(4), Tcos(*), Y1(*), Y2(*), Y3(*), &
    D(*), W1(*), W2(*), W3(*)
  INTEGER k1p1, k2p1, k3p1, k4p1
  !
  !***FIRST EXECUTABLE STATEMENT  CMPTR3
  mm1 = M - 1
  k1 = K(1)
  k2 = K(2)
  k3 = K(3)
  k4 = K(4)
  k1p1 = k1 + 1
  k2p1 = k2 + 1
  k3p1 = k3 + 1
  k4p1 = k4 + 1
  k2k3k4 = k2 + k3 + k4
  IF ( k2k3k4/=0 ) THEN
    l1 = k1p1/k2p1
    l2 = k1p1/k3p1
    l3 = k1p1/k4p1
    lint1 = 1
    lint2 = 1
    lint3 = 1
    kint1 = k1
    kint2 = kint1 + k2
    kint3 = kint2 + k3
  ENDIF
  DO n = 1, k1
    x = Tcos(n)
    IF ( k2k3k4/=0 ) THEN
      IF ( n==l1 ) THEN
        DO i = 1, M
          W1(i) = Y1(i)
        ENDDO
      ENDIF
      IF ( n==l2 ) THEN
        DO i = 1, M
          W2(i) = Y2(i)
        ENDDO
      ENDIF
      IF ( n==l3 ) THEN
        DO i = 1, M
          W3(i) = Y3(i)
        ENDDO
      ENDIF
    ENDIF
    z = 1./(B(1)-x)
    D(1) = C(1)*z
    Y1(1) = Y1(1)*z
    Y2(1) = Y2(1)*z
    Y3(1) = Y3(1)*z
    DO i = 2, M
      z = 1./(B(i)-x-A(i)*D(i-1))
      D(i) = C(i)*z
      Y1(i) = (Y1(i)-A(i)*Y1(i-1))*z
      Y2(i) = (Y2(i)-A(i)*Y2(i-1))*z
      Y3(i) = (Y3(i)-A(i)*Y3(i-1))*z
    ENDDO
    DO ip = 1, mm1
      i = M - ip
      Y1(i) = Y1(i) - D(i)*Y1(i+1)
      Y2(i) = Y2(i) - D(i)*Y2(i+1)
      Y3(i) = Y3(i) - D(i)*Y3(i+1)
    ENDDO
    IF ( k2k3k4/=0 ) THEN
      IF ( n==l1 ) THEN
        i = lint1 + kint1
        xx = x - Tcos(i)
        DO i = 1, M
          Y1(i) = xx*Y1(i) + W1(i)
        ENDDO
        lint1 = lint1 + 1
        l1 = (lint1*k1p1)/k2p1
      ENDIF
      IF ( n==l2 ) THEN
        i = lint2 + kint2
        xx = x - Tcos(i)
        DO i = 1, M
          Y2(i) = xx*Y2(i) + W2(i)
        ENDDO
        lint2 = lint2 + 1
        l2 = (lint2*k1p1)/k3p1
      ENDIF
      IF ( n==l3 ) THEN
        i = lint3 + kint3
        xx = x - Tcos(i)
        DO i = 1, M
          Y3(i) = xx*Y3(i) + W3(i)
        ENDDO
        lint3 = lint3 + 1
        l3 = (lint3*k1p1)/k4p1
      ENDIF
    ENDIF
  ENDDO
END SUBROUTINE CMPTR3
