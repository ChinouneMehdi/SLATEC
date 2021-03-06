!** DPOCH
REAL(DP) ELEMENTAL FUNCTION DPOCH(A,X)
  !> Evaluate a generalization of Pochhammer's symbol.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C1, C7A
  !***
  ! **Type:**      DOUBLE PRECISION (POCH-S, DPOCH-D)
  !***
  ! **Keywords:**  FNLIB, POCHHAMMER, SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! Evaluate a double precision generalization of Pochhammer's symbol
  ! (A)-sub-X = GAMMA(A+X)/GAMMA(A) for double precision A and X.
  ! For X a non-negative integer, POCH(A,X) is just Pochhammer's symbol.
  ! This is a preliminary version that does not handle wrong arguments
  ! properly and may not properly handle the case when the result is
  ! computed to less than half of double precision.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  D9LGMC, DFAC, DGAMR, DLGAMS, DLNREL, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   770701  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890911  Removed unnecessary intrinsics.  (WRB)
  !   890911  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900727  Added EXTERNAL statement.  (WRB)
  REAL(DP), INTENT(IN) :: A, X
  INTEGER :: i, ia, n
  REAL(DP) :: absa, absax, alnga, alngax, ax, b, sgnga, sgngax
  REAL(DP), PARAMETER :: pi = 3.141592653589793238462643383279503_DP
  !* FIRST EXECUTABLE STATEMENT  DPOCH
  ax = A + X
  IF( ax<=0._DP ) THEN
    IF( AINT(ax)==ax ) THEN
      !
      IF( A>0._DP .OR. AINT(A)/=A ) &
        ERROR STOP 'DPOCH : A+X IS NON-POSITIVE INTEGER BUT A IS NOT'
      !
      ! WE KNOW HERE THAT BOTH A+X AND A ARE NON-POSITIVE INTEGERS.
      !
      DPOCH = 1._DP
      IF( X==0._DP ) RETURN
      !
      n = INT( X )
      IF( MIN(A+X,A)<(-20._DP) ) THEN
        !
        DPOCH = (-1._DP)**n*EXP((A-0.5_DP)*DLNREL(X/(A-1._DP))+X*LOG(-A+1._DP-X)&
          -X+D9LGMC(-A+1._DP)-D9LGMC(-A-X+1._DP))
        RETURN
      ELSE
        !
        ia = INT( A )
        DPOCH = (-1._DP)**n*DFAC(-ia)/DFAC(-ia-n)
        RETURN
      END IF
    END IF
  END IF
  !
  ! A+X IS NOT ZERO OR A NEGATIVE INTEGER.
  !
  DPOCH = 0._DP
  IF( A<=0._DP .AND. AINT(A)==A ) RETURN
  !
  n = INT( ABS(X) )
  IF( REAL( n, DP )/=X .OR. n>20 ) THEN
    !
    absax = ABS(A+X)
    absa = ABS(A)
    IF( MAX(absax,absa)<=20._DP ) THEN
      DPOCH = GAMMA(A+X)*DGAMR(A)
      RETURN
      !
    ELSEIF( ABS(X)>0.5_DP*absa ) THEN
      !
      CALL DLGAMS(A+X,alngax,sgngax)
      CALL DLGAMS(A,alnga,sgnga)
      DPOCH = sgngax*sgnga*EXP(alngax-alnga)
      RETURN
    END IF
  ELSE
    !
    ! X IS A SMALL NON-POSITIVE INTEGER, PRESUMMABLY A COMMON CASE.
    !
    DPOCH = 1._DP
    IF( n==0 ) RETURN
    DO i = 1, n
      DPOCH = DPOCH*(A+i-1)
    END DO
    RETURN
  END IF
  !
  ! ABS(X) IS SMALL AND BOTH ABS(A+X) AND ABS(A) ARE LARGE.  THUS,
  ! A+X AND A MUST HAVE THE SAME SIGN.  FOR NEGATIVE A, WE USE
  ! GAMMA(A+X)/GAMMA(A) = GAMMA(-A+1)/GAMMA(-A-X+1) *
  ! SIN(PI*A)/SIN(PI*(A+X))
  !
  b = A
  IF( b<0._DP ) b = -A - X + 1._DP
  DPOCH = EXP((b-0.5_DP)*DLNREL(X/b)+X*LOG(b+X)-X+D9LGMC(b+X)-D9LGMC(b))
  IF( A<0._DP .AND. DPOCH/=0._DP )&
    DPOCH = DPOCH/(COS(pi*X)+DCOT(pi*A)*SIN(pi*X))
  RETURN

END FUNCTION DPOCH