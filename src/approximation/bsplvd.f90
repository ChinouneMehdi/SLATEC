!** BSPLVD
SUBROUTINE BSPLVD(T,K,X,Ileft,Vnikx,Nderiv)
  !> Subsidiary to FC
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (BSPLVD-S, DFSPVD-D)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  ! Calculates value and deriv.s of all B-splines which do not vanish at X
  !
  !  Fill VNIKX(J,IDERIV), J=IDERIV, ... ,K  with nonzero values of
  !  B-splines of order K+1-IDERIV, IDERIV=NDERIV, ... ,1, by repeated
  !  calls to BSPLVN
  !
  !***
  ! **See also:**  FC
  !***
  ! **Routines called:**  BSPLVN

  !* REVISION HISTORY  (YYMMDD)
  !   780801  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)

  INTEGER, INTENT(IN) :: Ileft, K, Nderiv
  REAL(SP), INTENT(IN) :: T(:), X
  REAL(SP), INTENT(INOUT) :: Vnikx(K,K)
  INTEGER :: i, ideriv, idervm, ipkmd, j, jlow, jm1, kmd, l, m
  REAL(SP) :: a(20,20), diff, fkmd, v
  !* FIRST EXECUTABLE STATEMENT  BSPLVD
  CALL BSPLVN(T,K+1-Nderiv,1,X,Ileft,Vnikx(Nderiv:K,Nderiv))
  IF( Nderiv>1 ) THEN
    ideriv = Nderiv
    DO i = 2, Nderiv
      idervm = ideriv - 1
      DO j = ideriv, K
        Vnikx(j-1,idervm) = Vnikx(j,ideriv)
      END DO
      ideriv = idervm
      CALL BSPLVN(T,0,2,X,Ileft,Vnikx(ideriv,ideriv))
    END DO
    !
    DO i = 1, K
      DO j = 1, K
        a(i,j) = 0.
      END DO
      a(i,i) = 1.
    END DO
    kmd = K
    DO m = 2, Nderiv
      kmd = kmd - 1
      fkmd = kmd
      i = Ileft
      j = K
      DO
        jm1 = j - 1
        ipkmd = i + kmd
        diff = T(ipkmd) - T(i)
        IF( jm1==0 ) THEN
          IF( diff/=0. ) a(1,1) = a(1,1)/diff*fkmd
          !
          DO i = 1, K
            v = 0.
            jlow = MAX(i,m)
            DO j = jlow, K
              v = a(i,j)*Vnikx(j,m) + v
            END DO
            Vnikx(i,m) = v
          END DO
          EXIT
        ELSE
          IF( diff/=0. ) THEN
            DO l = 1, j
              a(l,j) = (a(l,j)-a(l,j-1))/diff*fkmd
            END DO
          END IF
          j = jm1
          i = i - 1
        END IF
      END DO
    END DO
  END IF
  !
END SUBROUTINE BSPLVD