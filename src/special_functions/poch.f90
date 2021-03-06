!** POCH
REAL(SP) ELEMENTAL FUNCTION POCH(A,X)
  !> Evaluate a generalization of Pochhammer's symbol.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C1, C7A
  !***
  ! **Type:**      SINGLE PRECISION (POCH-S, DPOCH-D)
  !***
  ! **Keywords:**  FNLIB, POCHHAMMER, SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! Evaluate a generalization of Pochhammer's symbol
  ! (A)-sub-X = GAMMA(A+X)/GAMMA(A).  For X a non-negative integer,
  ! POCH(A,X) is just Pochhammer's symbol.  A and X are single precision.
  ! This is a preliminary version.  Error handling when POCH(A,X) is
  ! less than half precision is probably incorrect.  Grossly incorrect
  ! arguments are not handled properly.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  ALGAMS, ALNREL, FAC, GAMR, R9LGMC, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   770701  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900727  Added EXTERNAL statement.  (WRB)
  REAL(SP), INTENT(IN) :: A, X
  REAL(SP) :: absa, absax, alnga, alngax, ax, b, sgnga, sgngax
  INTEGER :: i, n
  REAL(SP), PARAMETER :: pi = 3.141592653589793238_SP
  !* FIRST EXECUTABLE STATEMENT  POCH
  ax = A + X
  IF( ax<=0._SP ) THEN
    IF( AINT(ax)==ax ) THEN
      !
      IF( A>0._SP .OR. AINT(A)/=A ) THEN
        ERROR STOP 'POCH : A+X IS NON-POSITIVE INTEGER BUT A IS NOT'
      END IF
      !
      ! WE KNOW HERE THAT BOTH A+X AND A ARE NON-POSITIVE INTEGERS.
      !
      POCH = 1._SP
      IF( X==0._SP ) RETURN
      !
      n = INT( X )
      IF( MIN(A+X,A)<(-20._SP) ) THEN
        !
        POCH = (-1._SP)**n*EXP((A-0.5_SP)*ALNREL(X/(A-1._SP))+X*LOG(-A+1._SP-X)&
          -X+R9LGMC(-A+1._SP)-R9LGMC(-A-X+1._SP))
        RETURN
      ELSE
        !
        POCH = (-1._SP)**n*FAC(-INT(A))/FAC(-INT(A)-n)
        RETURN
      END IF
    END IF
  END IF
  !
  ! HERE WE KNOW A+X IS NOT ZERO OR A NEGATIVE INTEGER.
  !
  POCH = 0._SP
  IF( A<=0._SP .AND. AINT(A)==A ) RETURN
  !
  n = INT( ABS(X) )
  IF( REAL(n)/=X .OR. n>20 ) THEN
    !
    absax = ABS(A+X)
    absa = ABS(A)
    IF( MAX(absax,absa)<=20._SP ) THEN
      POCH = GAMMA(A+X)*GAMR(A)
      RETURN
      !
    ELSEIF( ABS(X)>0.5_SP*absa ) THEN
      !
      CALL ALGAMS(A+X,alngax,sgngax)
      CALL ALGAMS(A,alnga,sgnga)
      POCH = sgngax*sgnga*EXP(alngax-alnga)
      RETURN
    END IF
  ELSE
    !
    ! X IS A SMALL NON-POSITIVE INTEGER, PRESUMMABLY A COMMON CASE.
    !
    POCH = 1._SP
    IF( n==0 ) RETURN
    DO i = 1, n
      POCH = POCH*(A+i-1)
    END DO
    RETURN
  END IF
  !
  ! HERE ABS(X) IS SMALL AND BOTH ABS(A+X) AND ABS(A) ARE LARGE.  THUS,
  ! A+X AND A MUST HAVE THE SAME SIGN.  FOR NEGATIVE A, WE USE
  ! GAMMA(A+X)/GAMMA(A) = GAMMA(-A+1)/GAMMA(-A-X+1) *
  ! SIN(PI*A)/SIN(PI*(A+X))
  !
  b = A
  IF( b<0._SP ) b = -A - X + 1._SP
  POCH = EXP((b-0.5_SP)*ALNREL(X/b)+X*LOG(b+X)-X+R9LGMC(b+X)-R9LGMC(b))
  IF( A<0._SP .AND. POCH/=0._SP ) POCH = POCH/(COS(pi*X)+COT(pi*A)*SIN(pi*X))
  RETURN

END FUNCTION POCH