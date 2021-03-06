!** POISP2
PURE SUBROUTINE POISP2(M,N,A,Bb,C,Q,Idimq,B,B2,B3,W,W2,W3,D,Tcos,P)
  !> Subsidiary to GENBUN
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (POISP2-S, CMPOSP-C)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     Subroutine to solve Poisson equation with periodic boundary conditions.
  !
  !***
  ! **See also:**  GENBUN
  !***
  ! **Routines called:**  POISD2, POISN2

  !* REVISION HISTORY  (YYMMDD)
  !   801001  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900402  Added TYPE section.  (WRB)

  INTEGER, INTENT(IN) :: Idimq, M, N
  REAL(SP), INTENT(IN) :: A(M), Bb(M), C(M)
  REAL(SP), INTENT(INOUT) :: Q(Idimq,N)
  REAL(SP), INTENT(OUT) :: B(M), B2(M), B3(M), W(M), W2(M), W3(M), D(M), &
    P(:), Tcos(4*N)
  !
  INTEGER :: i, ipstor, j, lh, mr, nr, nrm1, nrmj, nrpj
  REAL(SP) :: s, t

  !* FIRST EXECUTABLE STATEMENT  POISP2
  mr = M
  nr = (N+1)/2
  nrm1 = nr - 1
  IF( 2*nr/=N ) THEN
    !
    !     ODD  NUMBER OF UNKNOWNS
    !
    DO j = 1, nrm1
      nrpj = N + 1 - j
      DO i = 1, mr
        s = Q(i,j) - Q(i,nrpj)
        t = Q(i,j) + Q(i,nrpj)
        Q(i,j) = s
        Q(i,nrpj) = t
      END DO
    END DO
    DO i = 1, mr
      Q(i,nr) = 2._SP*Q(i,nr)
    END DO
    lh = nrm1/2
    DO j = 1, lh
      nrmj = nr - j
      DO i = 1, mr
        s = Q(i,j)
        Q(i,j) = Q(i,nrmj)
        Q(i,nrmj) = s
      END DO
    END DO
    CALL POISD2(mr,nrm1,2,A,Bb,C,Q,Idimq,B,W,D,Tcos,P)
    ipstor = INT( W(1) )
    CALL POISN2(mr,nr,2,1,A,Bb,C,Q(1,nr),Idimq,B,B2,B3,W,W2,W3,D,Tcos,P)
    ipstor = MAX(ipstor,INT(W(1)))
    DO j = 1, nrm1
      nrpj = nr + j
      DO i = 1, mr
        s = 0.5_SP*(Q(i,nrpj)+Q(i,j))
        t = 0.5_SP*(Q(i,nrpj)-Q(i,j))
        Q(i,nrpj) = t
        Q(i,j) = s
      END DO
    END DO
    DO i = 1, mr
      Q(i,nr) = 0.5_SP*Q(i,nr)
    END DO
    DO j = 1, lh
      nrmj = nr - j
      DO i = 1, mr
        s = Q(i,j)
        Q(i,j) = Q(i,nrmj)
        Q(i,nrmj) = s
      END DO
    END DO
  ELSE
    !
    !     EVEN NUMBER OF UNKNOWNS
    !
    DO j = 1, nrm1
      nrmj = nr - j
      nrpj = nr + j
      DO i = 1, mr
        s = Q(i,nrmj) - Q(i,nrpj)
        t = Q(i,nrmj) + Q(i,nrpj)
        Q(i,nrmj) = s
        Q(i,nrpj) = t
      END DO
    END DO
    DO i = 1, mr
      Q(i,nr) = 2._SP*Q(i,nr)
      Q(i,N) = 2._SP*Q(i,N)
    END DO
    CALL POISD2(mr,nrm1,1,A,Bb,C,Q,Idimq,B,W,D,Tcos,P)
    ipstor = INT( W(1) )
    CALL POISN2(mr,nr+1,1,1,A,Bb,C,Q(1,nr),Idimq,B,B2,B3,W,W2,W3,D,Tcos,P)
    ipstor = MAX(ipstor,INT(W(1)))
    DO j = 1, nrm1
      nrmj = nr - j
      nrpj = nr + j
      DO i = 1, mr
        s = 0.5_SP*(Q(i,nrpj)+Q(i,nrmj))
        t = 0.5_SP*(Q(i,nrpj)-Q(i,nrmj))
        Q(i,nrmj) = s
        Q(i,nrpj) = t
      END DO
    END DO
    DO i = 1, mr
      Q(i,nr) = 0.5_SP*Q(i,nr)
      Q(i,N) = 0.5_SP*Q(i,N)
    END DO
  END IF
  !
  !     RETURN STORAGE REQUIREMENTS FOR P VECTORS.
  !
  W(1) = ipstor
  !
END SUBROUTINE POISP2