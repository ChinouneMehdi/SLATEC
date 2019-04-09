!** XSETUN
SUBROUTINE XSETUN(Iunit)
  IMPLICIT NONE
  !>
  !***
  !  Set output file to which error messages are to be sent.
  !***
  ! **Library:**   SLATEC (XERROR)
  !***
  ! **Category:**  R3B
  !***
  ! **Type:**      ALL (XSETUN-A)
  !***
  ! **Keywords:**  ERROR, XERROR
  !***
  ! **Author:**  Jones, R. E., (SNLA)
  !***
  ! **Description:**
  !
  !     Abstract
  !        XSETUN sets the output file to which error messages are to
  !        be sent.  Only one file will be used.  See XSETUA for
  !        how to declare more than one file.
  !
  !     Description of Parameter
  !      --Input--
  !        IUNIT - an input parameter giving the logical unit number
  !                to which error messages are to be sent.
  !
  !***
  ! **References:**  R. E. Jones and D. K. Kahaner, XERROR, the SLATEC
  !                 Error-handling Package, SAND82-0800, Sandia
  !                 Laboratories, 1982.
  !***
  ! **Routines called:**  J4SAVE

  !* REVISION HISTORY  (YYMMDD)
  !   790801  DATE WRITTEN
  !   861211  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  
  INTEGER Iunit
  INTEGER J4SAVE
  INTEGER junk
  !* FIRST EXECUTABLE STATEMENT  XSETUN
  junk = J4SAVE(3,Iunit,.TRUE.)
  junk = J4SAVE(5,1,.TRUE.)
END SUBROUTINE XSETUN