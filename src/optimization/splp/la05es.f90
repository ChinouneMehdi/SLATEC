!** LA05ES
SUBROUTINE LA05ES(A,Irn,Ip,N,Iw,Reals)
  !> Subsidiary to SPLP
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (LA05ES-S, LA05ED-D)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     THIS SUBPROGRAM IS A SLIGHT MODIFICATION OF A SUBPROGRAM
  !     FROM THE C. 1979 AERE HARWELL LIBRARY.  THE NAME OF THE
  !     CORRESPONDING HARWELL CODE CAN BE OBTAINED BY DELETING
  !     THE FINAL LETTER =S= IN THE NAMES USED HERE.
  !     REVISED SEP. 13, 1979.
  !
  !     ROYALTIES HAVE BEEN PAID TO AERE-UK FOR USE OF THEIR CODES
  !     IN THE PACKAGE GIVEN HERE.  ANY PRIMARY USAGE OF THE HARWELL
  !     SUBROUTINES REQUIRES A ROYALTY AGREEMENT AND PAYMENT BETWEEN
  !     THE USER AND AERE-UK.  ANY USAGE OF THE SANDIA WRITTEN CODES
  !     SPLP( ) (WHICH USES THE HARWELL SUBROUTINES) IS PERMITTED.
  !
  !***
  ! **See also:**  SPLP
  !***
  ! **Routines called:**  (NONE)
  !***
  ! COMMON BLOCKS    LA05DS

  !* REVISION HISTORY  (YYMMDD)
  !   811215  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900402  Added TYPE section.  (WRB)
  USE LA05DS, ONLY : lcol_com, lrow_com, ncp_com
  INTEGER :: N
  LOGICAL :: Reals
  INTEGER :: Irn(*), Iw(N), Ip(N)
  REAL(SP) :: A(:)
  INTEGER :: ipi, j, k, kl, kn, nz
  !* FIRST EXECUTABLE STATEMENT  LA05ES
  ncp_com = ncp_com + 1
  !     COMPRESS FILE OF POSITIVE INTEGERS. ENTRY J STARTS AT IRN(IP(J))
  !  AND CONTAINS IW(J) INTEGERS,J=1,N. OTHER COMPONENTS OF IRN ARE ZERO.
  !  LENGTH OF COMPRESSED FILE PLACED IN LROW IF REALS IS .TRUE. OR LCOL
  !  OTHERWISE.
  !  IF REALS IS .TRUE. ARRAY A CONTAINS A REAL FILE ASSOCIATED WITH IRN
  !  AND THIS IS COMPRESSED TOO.
  !  A,IRN,IP,IW,IA ARE INPUT/OUTPUT VARIABLES.
  !  N,REALS ARE INPUT/UNCHANGED VARIABLES.
  !
  DO j = 1, N
    ! STORE THE LAST ELEMENT OF ENTRY J IN IW(J) THEN OVERWRITE IT BY -J.
    nz = Iw(j)
    IF( nz>0 ) THEN
      k = Ip(j) + nz - 1
      Iw(j) = Irn(k)
      Irn(k) = -j
    END IF
  END DO
  ! KN IS THE POSITION OF NEXT ENTRY IN COMPRESSED FILE.
  kn = 0
  ipi = 0
  kl = lcol_com
  IF( Reals ) kl = lrow_com
  ! LOOP THROUGH THE OLD FILE SKIPPING ZERO (DUMMY) ELEMENTS AND
  !     MOVING GENUINE ELEMENTS FORWARD. THE ENTRY NUMBER BECOMES
  !     KNOWN ONLY WHEN ITS END IS DETECTED BY THE PRESENCE OF A NEGATIVE
  !     INTEGER.
  DO k = 1, kl
    IF( Irn(k)/=0 ) THEN
      kn = kn + 1
      IF( Reals ) A(kn) = A(k)
      IF( Irn(k)<0 ) THEN
        ! END OF ENTRY. RESTORE IRN(K), SET POINTER TO START OF ENTRY AND
        !     STORE CURRENT KN IN IPI READY FOR USE WHEN NEXT LAST ENTRY
        !     IS DETECTED.
        j = -Irn(k)
        Irn(k) = Iw(j)
        Ip(j) = ipi + 1
        Iw(j) = kn - ipi
        ipi = kn
      END IF
      Irn(kn) = Irn(k)
    END IF
  END DO
  IF( Reals ) lrow_com = kn
  IF( .NOT. Reals ) lcol_com = kn
END SUBROUTINE LA05ES
