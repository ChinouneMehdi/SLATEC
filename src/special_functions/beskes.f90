!** BESKES
PURE SUBROUTINE BESKES(Xnu,X,Nin,Bke)
  !> Compute a sequence of exponentially scaled modified Bessel functions of
  !  the third kind of fractional order.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C10B3
  !***
  ! **Type:**      SINGLE PRECISION (BESKES-S, DBSKES-D)
  !***
  ! **Keywords:**  EXPONENTIALLY SCALED, FNLIB, FRACTIONAL ORDER,
  !             MODIFIED BESSEL FUNCTION, SEQUENCE OF BESSEL FUNCTIONS,
  !             SPECIAL FUNCTIONS, THIRD KIND
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! BESKES computes a sequence of exponentially scaled
  ! (i.e., multipled by EXP(X)) modified Bessel
  ! functions of the third kind of order XNU + I at X, where X > 0,
  ! XNU lies in (-1,1), and I = 0, 1, ..., NIN - 1, if NIN is positive
  ! and I = 0, -1, ..., NIN + 1, if NIN is negative.  On return, the
  ! vector BKE(.) contains the results at X for order starting at XNU.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  R1MACH, R9KNUS, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   770601  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890911  Removed unnecessary intrinsics.  (WRB)
  !   890911  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900326  Removed duplicate information from DESCRIPTION section.  (WRB)
  USE service, ONLY : huge_sp
  !
  INTEGER, INTENT(IN) :: Nin
  REAL(SP), INTENT(IN) :: X, Xnu
  REAL(SP), INTENT(OUT) :: Bke(Nin)
  !
  INTEGER :: i, iswtch, n
  REAL(SP) :: bknu1, direct, v, vend, vincr
  REAL(SP), PARAMETER :: alnbig = LOG(huge_sp)
  !* FIRST EXECUTABLE STATEMENT  BESKES
  !
  v = ABS(Xnu)
  n = ABS(Nin)
  !
  IF( v>=1. ) THEN
    ERROR STOP 'BESKES : ABS(XNU) MUST BE < 1'
  ELSEIF( X<=0. ) THEN
    ERROR STOP 'BESKES : X <= 0'
  ELSEIF( n==0 ) THEN
    ERROR STOP 'BESKES : N THE NUMBER IN THE SEQUENCE IS 0'
  END IF
  !
  CALL R9KNUS(v,X,Bke(1),bknu1,iswtch)
  IF( n==1 ) RETURN
  !
  vincr = SIGN(1._SP,REAL(Nin,SP))
  direct = vincr
  IF( Xnu/=0. ) direct = vincr*SIGN(1._SP,Xnu)
  IF( iswtch==1 .AND. direct>0. ) THEN
    ERROR STOP 'BESKES : X SO SMALL BESSEL K-SUB-XNU+1 OVERFLOWS'
  END IF
  Bke(2) = bknu1
  !
  IF( direct<0. ) CALL R9KNUS(ABS(Xnu+vincr),X,Bke(2),bknu1,iswtch)
  IF( n==2 ) RETURN
  !
  vend = ABS(Xnu+Nin) - 1._SP
  IF( (vend-0.5_SP)*LOG(vend)+0.27-vend*(LOG(X)-.694)>alnbig ) THEN
    ERROR STOP 'BESKES : X SO SMALL OR ABS(NU) SO BIG THAT BESSEL K-SUB-NU OVERFLOWS'
  END IF
  !
  v = Xnu
  DO i = 3, n
    v = v + vincr
    Bke(i) = 2._SP*v*Bke(i-1)/X + Bke(i-2)
  END DO
  !
END SUBROUTINE BESKES