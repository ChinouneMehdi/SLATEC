!DECK DY4
SUBROUTINE DY4(U,Idmn,I,J,Uyyy,Uyyyy)
  IMPLICIT NONE
  REAL AIT, BIT, CIT, DIT, DLX, DLX4, DLY, DLY4, TDLx3, TDLy3, U, &
    Uyyy, Uyyyy
  INTEGER I, Idmn, IS, J, JS, K, KSWx, KSWy, L, MIT, MS, NIT, NS
  !***BEGIN PROLOGUE  DY4
  !***SUBSIDIARY
  !***PURPOSE  Subsidiary to SEPX4
  !***LIBRARY   SLATEC
  !***TYPE      SINGLE PRECISION (DY4-S)
  !***AUTHOR  (UNKNOWN)
  !***DESCRIPTION
  !
  !     This program computes second order finite difference
  !     approximations to the third and fourth Y
  !     partial derivatives of U at the (I,J) mesh point.
  !
  !***SEE ALSO  SEPX4
  !***ROUTINES CALLED  (NONE)
  !***COMMON BLOCKS    SPL4
  !***REVISION HISTORY  (YYMMDD)
  !   801001  DATE WRITTEN
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900402  Added TYPE section.  (WRB)
  !***END PROLOGUE  DY4
  !
  COMMON /SPL4  / KSWx, KSWy, K, L, AIT, BIT, CIT, DIT, MIT, NIT, &
    IS, MS, JS, NS, DLX, DLY, TDLx3, TDLy3, DLX4, &
    DLY4
  DIMENSION U(Idmn,*)
  !***FIRST EXECUTABLE STATEMENT  DY4
  IF ( J>2.AND.J<(L-1) ) THEN
    !
    !     COMPUTE PARTIAL DERIVATIVE APPROXIMATIONS ON THE INTERIOR
    !
    Uyyy = (-U(I,J-2)+2.0*U(I,J-1)-2.0*U(I,J+1)+U(I,J+2))/TDLy3
    Uyyyy = (U(I,J-2)-4.0*U(I,J-1)+6.0*U(I,J)-4.0*U(I,J+1)+U(I,J+2))/DLY4
    RETURN
  ELSE
    IF ( J/=1 ) THEN
      IF ( J==2 ) THEN
        !
        !     COMPUTE PARTIAL DERIVATIVE APPROXIMATIONS AT Y=C+DLY
        !
        IF ( KSWy==1 ) THEN
          !
          !     PERIODIC AT Y=C+DLY
          !
          Uyyy = (-U(I,L-1)+2.0*U(I,1)-2.0*U(I,3)+U(I,4))/TDLy3
          Uyyyy = (U(I,L-1)-4.0*U(I,1)+6.0*U(I,2)-4.0*U(I,3)+U(I,4))/DLY4
          RETURN
        ELSE
          Uyyy = (-3.0*U(I,1)+10.0*U(I,2)-12.0*U(I,3)+6.0*U(I,4)-U(I,5))&
            /TDLy3
          Uyyyy = (2.0*U(I,1)-9.0*U(I,2)+16.0*U(I,3)-14.0*U(I,4)+6.0*U(I,5)&
            -U(I,6))/DLY4
          RETURN
        ENDIF
      ELSEIF ( J==L-1 ) THEN
        !
        !     COMPUTE PARTIAL DERIVATIVE APPROXIMATIONS AT Y=D-DLY
        !
        IF ( KSWy==1 ) THEN
          !
          !     PERIODIC AT Y=D-DLY
          !
          Uyyy = (-U(I,L-3)+2.0*U(I,L-2)-2.0*U(I,1)+U(I,2))/TDLy3
          Uyyyy = (U(I,L-3)-4.0*U(I,L-2)+6.0*U(I,L-1)-4.0*U(I,1)+U(I,2))&
            /DLY4
          RETURN
        ELSE
          Uyyy = (U(I,L-4)-6.0*U(I,L-3)+12.0*U(I,L-2)-10.0*U(I,L-1)&
            +3.0*U(I,L))/TDLy3
          Uyyyy = (-U(I,L-5)+6.0*U(I,L-4)-14.0*U(I,L-3)+16.0*U(I,L-2)&
            -9.0*U(I,L-1)+2.0*U(I,L))/DLY4
          RETURN
        ENDIF
      ELSEIF ( J==L ) THEN
        !
        !     COMPUTE PARTIAL DERIVATIVE APPROXIMATIONS AT Y=D
        !
        Uyyy = -(3.0*U(I,L-4)-14.0*U(I,L-3)+24.0*U(I,L-2)-18.0*U(I,L-1)&
          +5.0*U(I,L))/TDLy3
        Uyyyy = (-2.0*U(I,L-5)+11.0*U(I,L-4)-24.0*U(I,L-3)+26.0*U(I,L-2)&
          -14.0*U(I,L-1)+3.0*U(I,L))/DLY4
        GOTO 99999
      ENDIF
    ENDIF
    !
    !     COMPUTE PARTIAL DERIVATIVE APPROXIMATIONS AT Y=C
    !
    IF ( KSWy/=1 ) THEN
      Uyyy = (-5.0*U(I,1)+18.0*U(I,2)-24.0*U(I,3)+14.0*U(I,4)-3.0*U(I,5))&
        /TDLy3
      Uyyyy = (3.0*U(I,1)-14.0*U(I,2)+26.0*U(I,3)-24.0*U(I,4)+11.0*U(I,5)&
        -2.0*U(I,6))/DLY4
      RETURN
    ENDIF
  ENDIF
  !
  !     PERIODIC AT X=A
  !
  Uyyy = (-U(I,L-2)+2.0*U(I,L-1)-2.0*U(I,2)+U(I,3))/TDLy3
  Uyyyy = (U(I,L-2)-4.0*U(I,L-1)+6.0*U(I,1)-4.0*U(I,2)+U(I,3))/DLY4
  RETURN
  99999 CONTINUE
  END SUBROUTINE DY4