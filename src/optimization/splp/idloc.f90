!** IDLOC
INTEGER FUNCTION IDLOC(Loc,Sx,Ix)
  IMPLICIT NONE
  !>
  !***
  !  Subsidiary to DSPLP
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      DOUBLE PRECISION (IPLOC-S, IDLOC-D)
  !***
  ! **Keywords:**  RELATIVE ADDRESS DETERMINATION FUNCTION, SLATEC
  !***
  ! **Author:**  Boland, W. Robert, (LANL)
  !           Nicol, Tom, (University of British Columbia)
  !***
  ! **Description:**
  !
  !   Given a "virtual" location,  IDLOC returns the relative working
  !   address of the vector component stored in SX, IX.  Any necessary
  !   page swaps are performed automatically for the user in this
  !   function subprogram.
  !
  !   LOC       is the "virtual" address of the data to be retrieved.
  !   SX ,IX    represent the matrix where the data is stored.
  !
  !***
  ! **See also:**  DSPLP
  !***
  ! **Routines called:**  DPRWPG, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   890606  DATE WRITTEN
  !   890606  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   910731  Added code to set IDLOC to 0 if LOC is non-positive.  (WRB)

  INTEGER ipage, itemp, k, key, lmx, lmxm1, Loc, lpg, np
  REAL(8) :: Sx(*)
  INTEGER Ix(*)
  !* FIRST EXECUTABLE STATEMENT  IDLOC
  IF ( Loc<=0 ) THEN
    CALL XERMSG('SLATEC','IDLOC',&
      'A value of LOC, the first argument, .LE. 0 was encountered',55,1)
    IDLOC = 0
    RETURN
  END IF
  !
  !     Two cases exist:  (1.LE.LOC.LE.K) .OR. (LOC.GT.K).
  !
  k = Ix(3) + 4
  lmx = Ix(1)
  lmxm1 = lmx - 1
  IF ( Loc<=k ) THEN
    IDLOC = Loc
    RETURN
  END IF
  !
  !     Compute length of the page, starting address of the page, page
  !     number and relative working address.
  !
  lpg = lmx - k
  itemp = Loc - k - 1
  ipage = itemp/lpg + 1
  IDLOC = MOD(itemp,lpg) + k + 1
  np = ABS(Ix(lmxm1))
  !
  !     Determine if a page fault has occurred.  If so, write page NP
  !     and read page IPAGE.  Write the page only if it has been
  !     modified.
  !
  IF ( ipage/=np ) THEN
    IF ( Sx(lmx)==1.0 ) THEN
      Sx(lmx) = 0.0
      key = 2
      CALL DPRWPG(key,np,lpg,Sx,Ix)
    END IF
    key = 1
    CALL DPRWPG(key,ipage,lpg,Sx,Ix)
  END IF
END FUNCTION IDLOC