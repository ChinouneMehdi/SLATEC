!*==TEST40.f90  processed by SPAG 6.72Dc at 10:52 on  6 Feb 2019
!DECK TEST40
      PROGRAM TEST40
      IMPLICIT NONE
!*--TEST405
!*** Start of declarations inserted by SPAG
      INTEGER I1MACH
!*** End of declarations inserted by SPAG
!***BEGIN PROLOGUE  TEST40
!***PURPOSE  Driver for testing SLATEC subprograms
!***LIBRARY   SLATEC
!***CATEGORY  H2
!***TYPE      DOUBLE PRECISION (TEST39-S, TEST40-D)
!***KEYWORDS  QUICK CHECK DRIVER
!***AUTHOR  SLATEC Common Mathematical Library Committee
!***DESCRIPTION
!
! *Usage:
!     One input data record is required
!         READ (LIN, '(I1)') KPRINT
!
! *Arguments:
!     KPRINT = 0  Quick checks - No printing.
!                 Driver       - Short pass or fail message printed.
!              1  Quick checks - No message printed for passed tests,
!                                short message printed for failed tests.
!                 Driver       - Short pass or fail message printed.
!              2  Quick checks - Print short message for passed tests,
!                                fuller information for failed tests.
!                 Driver       - Pass or fail message printed.
!              3  Quick checks - Print complete quick check results.
!                 Driver       - Pass or fail message printed.
!
! *Description:
!     Driver for testing SLATEC subprograms
!        DQAG     DQAGI    DQAGP    DQAGS    DQAWC
!        DQAWF    DQAWO    DQAWS    DQNG
!
!***REFERENCES  Kirby W. Fong, Thomas H. Jefferson, Tokihiko Suyehiro
!                 and Lee Walton, Guide to the SLATEC Common Mathema-
!                 tical Library, April 10, 1990.
!***ROUTINES CALLED  CDQAG, CDQAGI, CDQAGP, CDQAGS, CDQAWC, CDQAWF,
!                    CDQAWO, CDQAWS, CDQNG, I1MACH, XERMAX, XSETF,
!                    XSETUN
!***REVISION HISTORY  (YYMMDD)
!   890618  DATE WRITTEN
!   890618  REVISION DATE from Version 3.2
!   891214  Prologue converted to Version 4.0 format.  (BAB)
!   900524  Cosmetic changes to code.  (WRB)
!***END PROLOGUE  TEST40
      INTEGER ipass , kprint , lin , lun , nfail
!***FIRST EXECUTABLE STATEMENT  TEST40
      lun = I1MACH(2)
      lin = I1MACH(1)
      nfail = 0
!
!     Read KPRINT parameter
!
      READ (lin,'(I1)') kprint
      CALL XERMAX(1000)
      CALL XSETUN(lun)
      IF ( kprint<=1 ) THEN
        CALL XSETF(0)
      ELSE
        CALL XSETF(1)
      ENDIF
!
!     Test double precision QUADPACK routines
!
!     Test DQAG.
!
      CALL CDQAG(lun,kprint,ipass)
      IF ( ipass==0 ) nfail = nfail + 1
!
!     Test DQAGS.
!
      CALL CDQAGS(lun,kprint,ipass)
      IF ( ipass==0 ) nfail = nfail + 1
!
!     Test DQAGP.
!
      CALL CDQAGP(lun,kprint,ipass)
      IF ( ipass==0 ) nfail = nfail + 1
!
!     Test DQAGI.
!
      CALL CDQAGI(lun,kprint,ipass)
      IF ( ipass==0 ) nfail = nfail + 1
!
!     Test DQAWO.
!
      CALL CDQAWO(lun,kprint,ipass)
      IF ( ipass==0 ) nfail = nfail + 1
!
!     Test DQAWF.
!
      CALL CDQAWF(lun,kprint,ipass)
      IF ( ipass==0 ) nfail = nfail + 1
!
!     Test DQAWS.
!
      CALL CDQAWS(lun,kprint,ipass)
      IF ( ipass==0 ) nfail = nfail + 1
!
!     Test DQAWC.
!
      CALL CDQAWC(lun,kprint,ipass)
      IF ( ipass==0 ) nfail = nfail + 1
!
!     Test DQNG.
!
      CALL CDQNG(lun,kprint,ipass)
      IF ( ipass==0 ) nfail = nfail + 1
!
!     Write PASS or FAIL message
!
      IF ( nfail==0 ) THEN
        WRITE (lun,99001)
99001   FORMAT (/' --------------TEST40 PASSED ALL TESTS----------------')
      ELSE
        WRITE (lun,99002) nfail
99002   FORMAT (/' ************* WARNING -- ',I5,
     &          ' TEST(S) FAILED IN PROGRAM TEST40 *************')
      ENDIF
      STOP
      END PROGRAM TEST40
