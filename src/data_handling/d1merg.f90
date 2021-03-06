!** D1MERG
PURE SUBROUTINE D1MERG(Tcos,I1,M1,I2,M2,I3)
  !> Merge two strings of ascending double precision numbers.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      DOUBLE PRECISION (S1MERG-S, D1MERG-D, CMERGE-C, I1MERG-I)
  !***
  ! **Author:**  Boland, W. Robert, (LANL)
  !           Clemens, Reginald, (PLK)
  !***
  ! **Description:**
  !
  !   This subroutine merges two ascending strings of numbers in the
  !   array TCOS.  The first string is of length M1 and starts at
  !   TCOS(I1+1).  The second string is of length M2 and starts at
  !   TCOS(I2+1).  The merged string goes into TCOS(I3+1).
  !
  !   This routine is currently unused, but was added to complete
  !   the set of routines S1MERG and C1MERG (both of which are used).
  !
  !***
  ! **Routines called:**  DCOPY

  !* REVISION HISTORY  (YYMMDD)
  !   910819  DATE WRITTEN
  INTEGER, INTENT(IN) :: I1, I2, I3, M1, M2
  REAL(DP), INTENT(INOUT) :: Tcos( MAX(I1+M1,I2+M2,I3+M1+M2) )
  !
  INTEGER :: j1, j2, j3
  !
  !* FIRST EXECUTABLE STATEMENT  D1MERG
  IF( M1==0 .AND. M2==0 ) RETURN
  !
  IF( M1==0 .AND. M2/=0 ) THEN
    Tcos(I3+1:I3+M2) = Tcos(I2+1:I2+M2)
    RETURN
  END IF
  !
  IF( M1/=0 .AND. M2==0 ) THEN
    Tcos(I3+1:I3+M1) = Tcos(I1+1:I1+M1)
    RETURN
  END IF
  !
  j1 = 1
  j2 = 1
  j3 = 1
  DO
    !
    IF( Tcos(I1+j1)<=Tcos(I2+j2) ) THEN
      Tcos(I3+j3) = Tcos(I1+j1)
      j1 = j1 + 1
      IF( j1>M1 ) THEN
        Tcos(I3+j3+1:I3+j3-j2+M2+1) = Tcos(I2+j2:I2+M2)
        RETURN
      END IF
    ELSE
      Tcos(I3+j3) = Tcos(I2+j2)
      j2 = j2 + 1
      IF( j2>M2 ) THEN
        Tcos(I3+j3+1:I3+j3-j1+M1+1) = Tcos(I1+j1:I1+M1)
        RETURN
      END IF
    END IF
    j3 = j3 + 1
  END DO

END SUBROUTINE D1MERG