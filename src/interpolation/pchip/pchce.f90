!** PCHCE
PURE SUBROUTINE PCHCE(Ic,Vc,N,X,H,Slope,D,Incfd,Ierr)
  !> Set boundary conditions for PCHIC
  !***
  ! **Library:**   SLATEC (PCHIP)
  !***
  ! **Type:**      SINGLE PRECISION (PCHCE-S, DPCHCE-D)
  !***
  ! **Author:**  Fritsch, F. N., (LLNL)
  !***
  ! **Description:**
  !
  !          PCHCE:  PCHIC End Derivative Setter.
  !
  !    Called by PCHIC to set end derivatives as requested by the user.
  !    It must be called after interior derivative values have been set.
  !                      -----
  !
  !    To facilitate two-dimensional applications, includes an increment
  !    between successive values of the D-array.
  !
  ! ----------------------------------------------------------------------
  !
  !  Calling sequence:
  !
  !        PARAMETER  (INCFD = ...)
  !        INTEGER  IC(2), N, IERR
  !        REAL  VC(2), X(N), H(N), SLOPE(N), D(INCFD,N)
  !
  !        CALL  PCHCE (IC, VC, N, X, H, SLOPE, D, INCFD, IERR)
  !
  !   Parameters:
  !
  !     IC -- (input) integer array of length 2 specifying desired
  !           boundary conditions:
  !           IC(1) = IBEG, desired condition at beginning of data.
  !           IC(2) = IEND, desired condition at end of data.
  !           ( see prologue to PCHIC for details. )
  !
  !     VC -- (input) real array of length 2 specifying desired boundary
  !           values.  VC(1) need be set only if IC(1) = 2 or 3 .
  !                    VC(2) need be set only if IC(2) = 2 or 3 .
  !
  !     N -- (input) number of data points.  (assumes N>=2)
  !
  !     X -- (input) real array of independent variable values.  (the
  !           elements of X are assumed to be strictly increasing.)
  !
  !     H -- (input) real array of interval lengths.
  !     SLOPE -- (input) real array of data slopes.
  !           If the data are (X(I),Y(I)), I=1(1)N, then these inputs are:
  !                  H(I) =  X(I+1)-X(I),
  !              SLOPE(I) = (Y(I+1)-Y(I))/H(I),  I=1(1)N-1.
  !
  !     D -- (input) real array of derivative values at the data points.
  !           The value corresponding to X(I) must be stored in
  !                D(1+(I-1)*INCFD),  I=1(1)N.
  !          (output) the value of D at X(1) and/or X(N) is changed, if
  !           necessary, to produce the requested boundary conditions.
  !           no other entries in D are changed.
  !
  !     INCFD -- (input) increment between successive values in D.
  !           This argument is provided primarily for 2-D applications.
  !
  !     IERR -- (output) error flag.
  !           Normal return:
  !              IERR = 0  (no errors).
  !           Warning errors:
  !              IERR = 1  if IBEG<0 and D(1) had to be adjusted for
  !                        monotonicity.
  !              IERR = 2  if IEND<0 and D(1+(N-1)*INCFD) had to be
  !                        adjusted for monotonicity.
  !              IERR = 3  if both of the above are true.
  !
  !    -------
  !    WARNING:  This routine does no validity-checking of arguments.
  !    -------
  !
  !  Fortran intrinsics used:  ABS.
  !
  !***
  ! **See also:**  PCHIC
  !***
  ! **Routines called:**  PCHDF, PCHST, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   820218  DATE WRITTEN
  !   820805  Converted to SLATEC library version.
  !   870707  Minor corrections made to prologue..
  !   890411  Added SAVE statements (Vers. 3.2).
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900328  Added TYPE section.  (WRB)
  !   910408  Updated AUTHOR section in prologue.  (WRB)
  !   930503  Improved purpose.  (FNF)

  !
  !  Programming notes:
  !     1. The function  PCHST(ARG1,ARG2)  is assumed to return zero if
  !        either argument is zero, +1 if they are of the same sign, and
  !        -1 if they are of opposite sign.
  !     2. One could reduce the number of arguments and amount of local
  !        storage, at the expense of reduced code clarity, by passing in
  !        the array WK (rather than splitting it into H and SLOPE) and
  !        increasing its length enough to incorporate STEMP and XTEMP.
  !     3. The two monotonicity checks only use the sufficient conditions.
  !        Thus, it is possible (but unlikely) for a boundary condition to
  !        be changed, even though the original interpolant was monotonic.
  !        (At least the result is a continuous function of the data.)
  !**End
  !
  !  DECLARE ARGUMENTS.
  !
  INTEGER, INTENT(IN) :: Ic(2), N, Incfd
  INTEGER, INTENT(OUT) :: Ierr
  REAL(SP), INTENT(IN) :: Vc(2), X(N), H(N), Slope(N)
  REAL(SP), INTENT(INOUT) :: D(Incfd,N)
  !
  !  DECLARE LOCAL VARIABLES.
  !
  INTEGER :: ibeg, iend, indexx, j, k
  REAL(SP) :: stemp(3), xtemp(4)
  !
  !* FIRST EXECUTABLE STATEMENT  PCHCE
  ibeg = Ic(1)
  iend = Ic(2)
  Ierr = 0
  !
  !  SET TO DEFAULT BOUNDARY CONDITIONS IF N IS TOO SMALL.
  !
  IF( ABS(ibeg)>N ) ibeg = 0
  IF( ABS(iend)>N ) iend = 0
  !
  !  TREAT BEGINNING BOUNDARY CONDITION.
  !
  IF( ibeg/=0 ) THEN
    k = ABS(ibeg)
    IF( k==1 ) THEN
      !        BOUNDARY VALUE PROVIDED.
      D(1,1) = Vc(1)
    ELSEIF( k==2 ) THEN
      !        BOUNDARY SECOND DERIVATIVE PROVIDED.
      D(1,1) = 0.5_SP*((3._SP*Slope(1)-D(1,2))-0.5_SP*Vc(1)*H(1))
    ELSEIF( k<5 ) THEN
      !        USE K-POINT DERIVATIVE FORMULA.
      !        PICK UP FIRST K POINTS, IN REVERSE ORDER.
      DO j = 1, k
        indexx = k - j + 1
        !           INDEX RUNS FROM K DOWN TO 1.
        xtemp(j) = X(indexx)
        IF( j<k ) stemp(j) = Slope(indexx-1)
      END DO
      !                 -----------------------------
      D(1,1) = PCHDF(k,xtemp,stemp)
    ELSE
      !        USE 'NOT A KNOT' CONDITION.
      D(1,1) = (3._SP*(H(1)*Slope(2)+H(2)*Slope(1))-2._SP*(H(1)+H(2))*D(1,2)&
        -H(1)*D(1,3))/H(2)
    END IF
    !
    IF( ibeg<=0 ) THEN
      !
      !  CHECK D(1,1) FOR COMPATIBILITY WITH MONOTONICITY.
      !
      IF( Slope(1)==0._SP ) THEN
        IF( D(1,1)/=0._SP ) THEN
          D(1,1) = 0._SP
          Ierr = Ierr + 1
        END IF
      ELSEIF( PCHST(D(1,1),Slope(1))<0._SP ) THEN
        D(1,1) = 0._SP
        Ierr = Ierr + 1
      ELSEIF( ABS(D(1,1))>3._SP*ABS(Slope(1)) ) THEN
        D(1,1) = 3._SP*Slope(1)
        Ierr = Ierr + 1
      END IF
    END IF
  END IF
  !
  !  TREAT END BOUNDARY CONDITION.
  !
  IF( iend/=0 ) THEN
    k = ABS(iend)
    IF( k==1 ) THEN
      !        BOUNDARY VALUE PROVIDED.
      D(1,N) = Vc(2)
    ELSEIF( k==2 ) THEN
      !        BOUNDARY SECOND DERIVATIVE PROVIDED.
      D(1,N) = 0.5_SP*((3._SP*Slope(N-1)-D(1,N-1))+0.5_SP*Vc(2)*H(N-1))
    ELSEIF( k<5 ) THEN
      !        USE K-POINT DERIVATIVE FORMULA.
      !        PICK UP LAST K POINTS.
      DO j = 1, k
        indexx = N - k + j
        !           INDEX RUNS FROM N+1-K UP TO N.
        xtemp(j) = X(indexx)
        IF( j<k ) stemp(j) = Slope(indexx)
      END DO
      !                 -----------------------------
      D(1,N) = PCHDF(k,xtemp,stemp)
    ELSE
      !        USE 'NOT A KNOT' CONDITION.
      D(1,N) = (3._SP*(H(N-1)*Slope(N-2)+H(N-2)*Slope(N-1))&
        -2._SP*(H(N-1)+H(N-2))*D(1,N-1)-H(N-1)*D(1,N-2))/H(N-2)
    END IF
    !
    IF( iend<=0 ) THEN
      !
      !  CHECK D(1,N) FOR COMPATIBILITY WITH MONOTONICITY.
      !
      IF( Slope(N-1)==0._SP ) THEN
        IF( D(1,N)/=0._SP ) THEN
          D(1,N) = 0._SP
          Ierr = Ierr + 2
        END IF
      ELSEIF( PCHST(D(1,N),Slope(N-1))<0._SP ) THEN
        D(1,N) = 0._SP
        Ierr = Ierr + 2
      ELSEIF( ABS(D(1,N))>3._SP*ABS(Slope(N-1)) ) THEN
        D(1,N) = 3._SP*Slope(N-1)
        Ierr = Ierr + 2
      END IF
    END IF
  END IF
  !
  !  NORMAL RETURN.
  !
  RETURN
  !
  !------------- LAST LINE OF PCHCE FOLLOWS ------------------------------
END SUBROUTINE PCHCE