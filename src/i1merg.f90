!*==I1MERG.f90  processed by SPAG 6.72Dc at 11:01 on  6 Feb 2019
!DECK I1MERG
      SUBROUTINE I1MERG(Icos,I1,M1,I2,M2,I3)
      IMPLICIT NONE
!*--I1MERG5
!***BEGIN PROLOGUE  I1MERG
!***SUBSIDIARY
!***PURPOSE  Merge two strings of ascending integers.
!***LIBRARY   SLATEC
!***TYPE      INTEGER (S1MERG-S, D1MERG-D, C1MERG-C, I1MERG-I)
!***AUTHOR  Boland, W. Robert, (LANL)
!           Clemens, Reginald, (PLK)
!***DESCRIPTION
!
!   This subroutine merges two ascending strings of integers in the
!   array ICOS.  The first string is of length M1 and starts at
!   ICOS(I1+1).  The second string is of length M2 and starts at
!   ICOS(I2+1).  The merged string goes into ICOS(I3+1).
!
!***ROUTINES CALLED  ICOPY
!***REVISION HISTORY  (YYMMDD)
!   920202  DATE WRITTEN
!***END PROLOGUE  I1MERG
      INTEGER I1 , I2 , I3 , M1 , M2
      REAL Icos(*)
!
      INTEGER j1 , j2 , j3
!
!***FIRST EXECUTABLE STATEMENT  I1MERG
      IF ( M1==0.AND.M2==0 ) RETURN
!
      IF ( M1==0.AND.M2/=0 ) THEN
        CALL ICOPY(M2,Icos(I2+1),1,Icos(I3+1),1)
        RETURN
      ENDIF
!
      IF ( M1/=0.AND.M2==0 ) THEN
        CALL ICOPY(M1,Icos(I1+1),1,Icos(I3+1),1)
        RETURN
      ENDIF
!
      j1 = 1
      j2 = 1
      j3 = 1
      DO
!
        IF ( Icos(I1+j1)<=Icos(I2+j2) ) THEN
          Icos(I3+j3) = Icos(I1+j1)
          j1 = j1 + 1
          IF ( j1>M1 ) THEN
            CALL ICOPY(M2-j2+1,Icos(I2+j2),1,Icos(I3+j3+1),1)
            RETURN
          ENDIF
        ELSE
          Icos(I3+j3) = Icos(I2+j2)
          j2 = j2 + 1
          IF ( j2>M2 ) THEN
            CALL ICOPY(M1-j1+1,Icos(I1+j1),1,Icos(I3+j3+1),1)
            RETURN
          ENDIF
        ENDIF
        j3 = j3 + 1
      ENDDO
      END SUBROUTINE I1MERG
