!** SPLPFL
PURE SUBROUTINE SPLPFL(Mrelas,Nvars,Ienter,Ileave,Ibasis,Ind,Theta,Dirnrm,&
    Rprnrm,Csc,Ww,Bl,Bu,Erp,Rprim,Primal,Finite,Zerolv)
  !> Subsidiary to SPLP
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (SPLPFL-S, DPLPFL-D)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     THE EDITING REQUIRED TO CONVERT THIS SUBROUTINE FROM SINGLE TO
  !     DOUBLE PRECISION INVOLVES THE FOLLOWING CHARACTER STRING CHANGES.
  !
  !     USE AN EDITING COMMAND (CHANGE) /STRING-1/(TO)STRING-2/.
  !     /REAL (12 BLANKS)/DOUBLE PRECISION/.
  !
  !     THIS SUBPROGRAM IS PART OF THE SPLP( ) PACKAGE.
  !     IT IMPLEMENTS THE PROCEDURE (CHOOSE VARIABLE TO LEAVE BASIS).
  !     REVISED 811130-1045
  !     REVISED YYMMDD-HHMM
  !
  !***
  ! **See also:**  SPLP
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   811215  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890605  Removed unreferenced labels.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)

  INTEGER, INTENT(IN) :: Ienter, Mrelas, Nvars
  INTEGER, INTENT(OUT) :: Ileave
  REAL(SP), INTENT(IN) :: Dirnrm, Rprnrm
  REAL(SP), INTENT(OUT) :: Theta
  LOGICAL, INTENT(OUT) :: Finite, Zerolv
  INTEGER, INTENT(IN) :: Ibasis(Nvars+Mrelas), Ind(Nvars+Mrelas)
  REAL(SP), INTENT(IN) :: Csc(Nvars), Ww(Mrelas), Bl(Nvars+Mrelas), Bu(Nvars+Mrelas), &
    Erp(Mrelas), Rprim(Mrelas), Primal(Nvars+Mrelas)
  INTEGER :: i, j, n20005, n20036
  REAL(SP) ::  bound, ratio
  !* FIRST EXECUTABLE STATEMENT  SPLPFL
  !
  !     SEE IF THE ENTERING VARIABLE IS RESTRICTING THE STEP LENGTH
  !     BECAUSE OF AN UPPER BOUND.
  Finite = .FALSE.
  j = Ibasis(Ienter)
  IF( Ind(j)==3 ) THEN
    Theta = Bu(j) - Bl(j)
    IF( j<=Nvars ) Theta = Theta/Csc(j)
    Finite = .TRUE.
    Ileave = Ienter
  END IF
  !
  !     NOW USE THE BASIC VARIABLES TO POSSIBLY RESTRICT THE STEP
  !     LENGTH EVEN FURTHER.
  i = 1
  n20005 = Mrelas
  DO WHILE( (n20005-i)>=0 )
    j = Ibasis(i)
    !
    !     IF THIS IS A FREE VARIABLE, DO NOT USE IT TO
    !     RESTRICT THE STEP LENGTH.
    IF( Ind(j)==4 ) THEN
      i = i + 1
      !
      !     IF DIRECTION COMPONENT IS ABOUT ZERO, IGNORE IT FOR COMPUTING
      !     THE STEP LENGTH.
    ELSEIF( ABS(Ww(i))<=Dirnrm*Erp(i) ) THEN
      i = i + 1
    ELSEIF( Ww(i)<=0._SP ) THEN
      !
      !     IF THE VARIABLE IS LESS THAN ITS LOWER BOUND, IT CAN
      !     INCREASE ONLY TO ITS LOWER BOUND.
      IF( Primal(i+Nvars)<0._SP ) THEN
        ratio = Rprim(i)/Ww(i)
        IF( ratio<0._SP ) ratio = 0._SP
        IF( .NOT. Finite ) THEN
          Ileave = i
          Theta = ratio
          Finite = .TRUE.
        ELSEIF( ratio<Theta ) THEN
          Ileave = i
          !
          !     IF THE BASIC VARIABLE IS FEASIBLE AND IS NOT AT ITS UPPER BOUND,
          !     THEN IT CAN INCREASE TO ITS UPPER BOUND.
          Theta = ratio
        END IF
      ELSEIF( Ind(j)==3 .AND. Primal(i+Nvars)==0._SP ) THEN
        bound = Bu(j) - Bl(j)
        IF( j<=Nvars ) bound = bound/Csc(j)
        ratio = (bound-Rprim(i))/(-Ww(i))
        IF( .NOT. Finite ) THEN
          Ileave = -i
          Theta = ratio
          Finite = .TRUE.
        ELSEIF( ratio<Theta ) THEN
          Ileave = -i
          Theta = ratio
        END IF
      END IF
      i = i + 1
      !
      !     IF RPRIM(I) IS ESSENTIALLY ZERO, SET RATIO TO ZERO AND EXIT LOOP.
    ELSEIF( ABS(Rprim(i))>Rprnrm*Erp(i) ) THEN
      !
      !     THE VALUE OF RPRIM(I) WILL DECREASE ONLY TO ITS LOWER BOUND OR
      !     ONLY TO ITS UPPER BOUND.  IF IT DECREASES TO ITS
      !     UPPER BOUND, THEN RPRIM(I) HAS ALREADY BEEN TRANSLATED
      !     TO ITS UPPER BOUND AND NOTHING NEEDS TO BE DONE TO IBB(J).
      IF( Rprim(i)>0._SP ) THEN
        ratio = Rprim(i)/Ww(i)
        IF( .NOT. Finite ) THEN
          Ileave = i
          Theta = ratio
          Finite = .TRUE.
        ELSEIF( ratio<Theta ) THEN
          Ileave = i
          !
          !     THE VALUE RPRIM(I)<ZERO WILL NOT RESTRICT THE STEP.
          !
          !     THE DIRECTION COMPONENT IS NEGATIVE, THEREFORE THE VARIABLE WILL
          !     INCREASE.
          Theta = ratio
        END IF
      END IF
      i = i + 1
    ELSE
      Theta = 0._SP
      Ileave = i
      Finite = .TRUE.
      EXIT
    END IF
  END DO
  !
  !     IF STEP LENGTH IS FINITE, SEE IF STEP LENGTH IS ABOUT ZERO.
  IF( Finite ) THEN
    Zerolv = .TRUE.
    i = 1
    n20036 = Mrelas
    DO WHILE( (n20036-i)>=0 )
      Zerolv = Zerolv .AND. ABS(Theta*Ww(i))<=Erp(i)*Rprnrm
      IF( .NOT. Zerolv ) EXIT
      i = i + 1
    END DO
  END IF

END SUBROUTINE SPLPFL