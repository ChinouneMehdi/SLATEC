!** CMPCSG
PURE SUBROUTINE CMPCSG(N,Ijump,Fnum,Fden,A)
  !> Subsidiary to CMGNBN
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      COMPLEX (COSGEN-S, CMPCSG-C)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     This subroutine computes required cosine values in ascending
  !     order.  When IJUMP > 1 the routine computes values
  !
  !        2*COS(J*PI/L), J=1,2,...,L and J /= 0(MOD N/IJUMP+1)
  !
  !     where L = IJUMP*(N/IJUMP+1).
  !
  !
  !     when IJUMP = 1 it computes
  !
  !            2*COS((J-FNUM)*PI/(N+FDEN)),  J=1, 2, ... ,N
  !
  !     where
  !        FNUM = 0.5, FDEN = 0.0,  for regular reduction values.
  !        FNUM = 0.0, FDEN = 1.0, for B-R and C-R when ISTAG = 1
  !        FNUM = 0.0, FDEN = 0.5, for B-R and C-R when ISTAG = 2
  !        FNUM = 0.5, FDEN = 0.5, for B-R and C-R when ISTAG = 2
  !                                in CMPOSN only.
  !
  !***
  ! **See also:**  CMGNBN
  !***
  ! **Routines called:**  PIMACH

  !* REVISION HISTORY  (YYMMDD)
  !   801001  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900402  Added TYPE section.  (WRB)

  INTEGER, INTENT(IN) :: Ijump, N
  REAL(SP), INTENT(IN) :: Fden, Fnum
  COMPLEX(SP), INTENT(OUT) :: A(N)
  !
  INTEGER :: i, k, k1, k2, k3, k4, k5, np1
  REAL(SP) :: pibyn, x, y
  REAL(SP), PARAMETER :: pi = 3.14159265358979_SP
  !
  !* FIRST EXECUTABLE STATEMENT  CMPCSG
  IF( N/=0 ) THEN
    IF( Ijump==1 ) THEN
      np1 = N + 1
      y = pi/(N+Fden)
      DO i = 1, N
        x = np1 - i - Fnum
        A(i) = CMPLX(2._SP*COS(x*y),0._SP,SP)
      END DO
    ELSE
      k3 = N/Ijump + 1
      k4 = k3 - 1
      pibyn = pi/(N+Ijump)
      DO k = 1, Ijump
        k1 = (k-1)*k3
        k5 = (k-1)*k4
        DO i = 1, k4
          x = k1 + i
          k2 = k5 + i
          A(k2) = CMPLX(-2._SP*COS(x*pibyn),0._SP,SP)
        END DO
      END DO
    END IF
  END IF
  !
END SUBROUTINE CMPCSG