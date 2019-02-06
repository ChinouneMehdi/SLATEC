!*==DSTOR1.f90  processed by SPAG 6.72Dc at 11:01 on  6 Feb 2019
!DECK DSTOR1
      SUBROUTINE DSTOR1(U,Yh,V,Yp,Ntemp,Ndisk,Ntape)
      IMPLICIT NONE
!*--DSTOR15
!***BEGIN PROLOGUE  DSTOR1
!***SUBSIDIARY
!***PURPOSE  Subsidiary to DBVSUP
!***LIBRARY   SLATEC
!***TYPE      DOUBLE PRECISION (STOR1-S, DSTOR1-D)
!***AUTHOR  Watts, H. A., (SNLA)
!***DESCRIPTION
!
! **********************************************************************
!             0 -- storage at output points.
!     NTEMP =
!             1 -- temporary storage
! **********************************************************************
!
!***SEE ALSO  DBVSUP
!***ROUTINES CALLED  (NONE)
!***COMMON BLOCKS    DML8SZ
!***REVISION HISTORY  (YYMMDD)
!   750601  DATE WRITTEN
!   890831  Modified array declarations.  (WRB)
!   890921  Realigned order of variables in certain COMMON blocks.
!           (WRB)
!   891214  Prologue converted to Version 4.0 format.  (BAB)
!   900328  Added TYPE section.  (WRB)
!   910722  Updated AUTHOR section.  (ALS)
!***END PROLOGUE  DSTOR1
      INTEGER IGOfx , INHomo , IVP , j , NCOmp , nctnf , Ndisk , NFC , Ntape , 
     &        Ntemp
      DOUBLE PRECISION C , U(*) , V(*) , XSAv , Yh(*) , Yp(*)
!
!     ******************************************************************
!
      COMMON /DML8SZ/ C , XSAv , IGOfx , INHomo , IVP , NCOmp , NFC
!
!      *****************************************************************
!
!     BEGIN BLOCK PERMITTING ...EXITS TO 80
!***FIRST EXECUTABLE STATEMENT  DSTOR1
      nctnf = NCOmp*NFC
      DO j = 1 , nctnf
        U(j) = Yh(j)
      ENDDO
      IF ( INHomo==1 ) THEN
!
!           NONZERO PARTICULAR SOLUTION
!
        IF ( Ntemp==0 ) THEN
!
          DO j = 1 , NCOmp
            V(j) = C*Yp(j)
          ENDDO
!
!        IS OUTPUT INFORMATION TO BE WRITTEN TO DISK
!
          IF ( Ndisk==1 ) WRITE (Ntape) (V(j),j=1,NCOmp) , (U(j),j=1,nctnf)
        ELSE
!
          DO j = 1 , NCOmp
            V(j) = Yp(j)
!     .........EXIT
          ENDDO
        ENDIF
!
!           ZERO PARTICULAR SOLUTION
!
!     ......EXIT
      ELSEIF ( Ntemp/=1 ) THEN
        DO j = 1 , NCOmp
          V(j) = 0.0D0
        ENDDO
        IF ( Ndisk==1 ) WRITE (Ntape) (V(j),j=1,NCOmp) , (U(j),j=1,nctnf)
      ENDIF
!
      END SUBROUTINE DSTOR1
