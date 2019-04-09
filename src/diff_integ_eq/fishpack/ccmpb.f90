!** CCMPB
SUBROUTINE CCMPB(N,Ierror,An,Bn,Cn,B,Ah,Bh)
  USE CCBLK
  IMPLICIT NONE
  !>
  !***
  !  Subsidiary to CBLKTR
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      COMPLEX (COMPB-S, CCMPB-C)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     CCMPB computes the roots of the B polynomials using subroutine
  !     TEVLC which is a modification the EISPACK program TQLRAT.
  !     IERROR is set to 4 if either TEVLC fails or if A(J+1)*C(J) is
  !     less than zero for some J.  AH,BH are temporary work arrays.
  !
  !***
  ! **See also:**  CBLKTR
  !***
  ! **Routines called:**  CPADD, INXCB, R1MACH, TEVLC
  !***
  ! COMMON BLOCKS    CCBLK

  !* REVISION HISTORY  (YYMMDD)
  !   801001  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900402  Added TYPE section.  (WRB)

  REAL Ah(*), An(*), arg, B(*), Bh(*), Bn(*), bnorm, Cn(*), d1, d2, d3, R1MACH
  INTEGER i, i2, i4, ib, Ierror, if, ifd, ipl, ir, j, j1, j2, jf, js, kdo, l, l1, &
    l2, lh, ls, N, n2m2, nb, nmp
  COMPLEX :: Bc(500)
  !* FIRST EXECUTABLE STATEMENT  CCMPB
  EPS = R1MACH(4)
  bnorm = ABS(Bn(1))
  DO j = 2, NM
    bnorm = MAX(bnorm,ABS(Bn(j)))
    arg = An(j)*Cn(j-1)
    IF ( arg<0 ) GOTO 200
    B(j) = SIGN(SQRT(arg),An(j))
  END DO
  CNV = EPS*bnorm
  if = 2**K
  kdo = K - 1
  DO l = 1, kdo
    ir = l - 1
    i2 = 2**ir
    i4 = i2 + i2
    ipl = i4 - 1
    ifd = if - i4
    DO i = i4, ifd, i4
      CALL INXCB(i,l,ib,nb)
      IF ( nb<=0 ) EXIT
      js = i - ipl
      jf = js + nb - 1
      ls = 0
      DO j = js, jf
        ls = ls + 1
        Bh(ls) = Bn(j)
        Ah(ls) = B(j)
      END DO
      CALL TEVLC(nb,Bh,Ah,Ierror)
      IF ( Ierror/=0 ) GOTO 100
      lh = ib - 1
      DO j = 1, nb
        lh = lh + 1
        B(lh) = -Bh(j)
      END DO
    END DO
  END DO
  DO j = 1, NM
    B(j) = -Bn(j)
  END DO
  IF ( NPP==0 ) THEN
    nmp = NM + 1
    nb = NM + nmp
    DO j = 1, nb
      l1 = MOD(j-1,nmp) + 1
      l2 = MOD(j+NM-1,nmp) + 1
      arg = An(l1)*Cn(l2)
      IF ( arg<0 ) GOTO 200
      Bh(j) = SIGN(SQRT(arg),-An(l1))
      Ah(j) = -Bn(l1)
    END DO
    CALL TEVLC(nb,Ah,Bh,Ierror)
    IF ( Ierror/=0 ) GOTO 100
    CALL INXCB(if,K-1,j2,lh)
    CALL INXCB(if/2,K-1,j1,lh)
    j2 = j2 + 1
    lh = j2
    n2m2 = j2 + NM + NM - 2
    DO
      d1 = ABS(B(j1)-B(j2-1))
      d2 = ABS(B(j1)-B(j2))
      d3 = ABS(B(j1)-B(j2+1))
      IF ( (d2<d1).AND.(d2<d3) ) THEN
        j2 = j2 + 1
        j1 = j1 + 1
        IF ( j2>n2m2 ) EXIT
      ELSE
        B(lh) = B(j2)
        j2 = j2 + 1
        lh = lh + 1
        IF ( j2>n2m2 ) EXIT
      END IF
    END DO
    B(lh) = B(n2m2+1)
    CALL INXCB(if,K-1,j1,j2)
    j2 = j1 + nmp + nmp
    CALL CPADD(NM+1,Ierror,An,Cn,Bc(j1),B(j1),B(j2))
  END IF
  RETURN
  100  Ierror = 4
  RETURN
  200  Ierror = 5
END SUBROUTINE CCMPB