! **References:**
!     R. P. Brent, A Fortran multiple-precision arithmetic package,
!       ACM Transactions on Mathematical Software 4, 1 (March 1978), pp. 57-70.
!     R. P. Brent, MP, a Fortran multiple-precision arithmetic package,
!       Algorithm 524, ACM Transactions on Mathematical Software 4, 1 (March 1978), pp. 71-81.
MODULE MPCOM
  USE ISO_FORTRAN_ENV, ONLY : ERROR_UNIT
  USE service, ONLY : digits_int, digits_dp, huge_int
  IMPLICIT NONE
  INTEGER, PARAMETER :: &
    !     For full extended precision accuracy, MPB should be as large as
    !     possible, subject to the restrictions in Brent's paper.
    !
    !     Statements below are for an integer wordlength of  48, 36, 32,
    !     24, 18, and 16.  Pick one, or generate a new one.
    !       48     MPB = 4194304
    !       36     MPB =   65536
    !       32     MPB =   16384
    !       24     MPB =    1024
    !       18     MPB =     128
    !       16     MPB =      64
    mpbexp = digits_int/2 - 2, &
    b_com = 2**mpbexp, &
    !  UNIT FOR ERROR MESSAGES
    lun_com = ERROR_UNIT, &
    !  NUMBER OF MP DIGITS
    t_com = MIN( 26, (2*digits_dp+mpbexp-1)/mpbexp ), &
    !  DIMENSION OF R
    mxr_com = MIN( 30, t_com + 4 ), &
    !  EXPONENT RANGE
    m_com = MIN(32767,huge_int/4-1)
  INTEGER :: r_com(mxr_com)
END MODULE MPCOM