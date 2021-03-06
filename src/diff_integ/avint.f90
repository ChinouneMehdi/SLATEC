!** AVINT
PURE SUBROUTINE AVINT(X,Y,N,Xlo,Xup,Ans,Ierr)
  !> Integrate a function tabulated at arbitrarily spaced abscissas using
  !  overlapping parabolas.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  H2A1B2
  !***
  ! **Type:**      SINGLE PRECISION (AVINT-S, DAVINT-D)
  !***
  ! **Keywords:**  INTEGRATION, QUADRATURE, TABULATED DATA
  !***
  ! **Author:**  Jones, R. E., (SNLA)
  !***
  ! **Description:**
  !
  !     Abstract
  !         AVINT integrates a function tabulated at arbitrarily spaced
  !         abscissas.  The limits of integration need not coincide
  !         with the tabulated abscissas.
  !
  !         A method of overlapping parabolas fitted to the data is used
  !         provided that there are at least 3 abscissas between the
  !         limits of integration.  AVINT also handles two special cases.
  !         If the limits of integration are equal, AVINT returns a result
  !         of zero regardless of the number of tabulated values.
  !         If there are only two function values, AVINT uses the
  !         trapezoid rule.
  !
  !     Description of Parameters
  !         The user must dimension all arrays appearing in the call list
  !              X(N), Y(N).
  !
  !         Input--
  !         X    - real array of abscissas, which must be in increasing
  !                order.
  !         Y    - real array of functional values. i.e., Y(I)=FUNC(X(I)).
  !         N    - the integer number of function values supplied.
  !                N >= 2 unless XLO = XUP.
  !         XLO  - real lower limit of integration.
  !         XUP  - real upper limit of integration.
  !                Must have XLO <= XUP.
  !
  !         Output--
  !         ANS  - computed approximate value of integral
  !         IERR - a status code
  !              --normal code
  !                =1 means the requested integration was performed.
  !              --abnormal codes
  !                =2 means XUP was less than XLO.
  !                =3 means the number of X(I) between XLO and XUP
  !                   (inclusive) was less than 3 and neither of the two
  !                   special cases described in the Abstract occurred.
  !                   No integration was performed.
  !                =4 means the restriction X(I+1) > X(I) was violated.
  !                =5 means the number N of function values was < 2.
  !                ANS is set to zero if IERR=2,3,4,or 5.
  !
  !     AVINT is documented completely in SC-M-69-335
  !     Original program from "Numerical Integration" by Davis & Rabinowitz.
  !     Adaptation and modifications for Sandia Mathematical Program
  !     Library by Rondall E. Jones.
  !
  !***
  ! **References:**  R. E. Jones, Approximate integrator of functions
  !                 tabulated at arbitrarily spaced abscissas,
  !                 Report SC-M-69-335, Sandia Laboratories, 1969.
  !***
  ! **Routines called:**  XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   690901  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900326  Removed duplicate information from DESCRIPTIONsection.  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER, INTENT(IN) :: N
  INTEGER, INTENT(OUT) :: Ierr
  REAL(SP), INTENT(IN) :: Xlo, Xup, X(N), Y(N)
  REAL(SP), INTENT(OUT) :: Ans
  !
  INTEGER :: i, inlft, inrt, istart, istop
  REAL(SP) :: fl, fr, slope
  REAL(DP) :: r3, rp5, summ, syl, syl2, syl3, syu, syu2, syu3, &
    x1, x2, x3, x12, x13, x23, term1, term2, term3, a, b, c, ca, cb, cc
  !* FIRST EXECUTABLE STATEMENT  AVINT
  Ierr = 1
  Ans = 0._SP
  IF( Xlo<Xup ) THEN
    IF( N<2 ) THEN
      Ierr = 5
      ERROR STOP 'AVINT : LESS THAN TWO FUNCTION VALUES WERE SUPPLIED.'
      RETURN
    ELSE
      DO i = 2, N
        IF( X(i)<=X(i-1) ) GOTO 200
        IF( X(i)>Xup ) EXIT
      END DO
      IF( N>=3 ) THEN
        IF( X(N-2)<Xlo ) GOTO 100
        IF( X(3)>Xup ) GOTO 100
        i = 1
        DO WHILE( X(i)<Xlo )
          i = i + 1
        END DO
        inlft = i
        i = N
        DO WHILE( X(i)>Xup )
          i = i - 1
        END DO
        inrt = i
        IF( (inrt-inlft)<2 ) GOTO 100
        istart = inlft
        IF( inlft==1 ) istart = 2
        istop = inrt
        IF( inrt==N ) istop = N - 1
        !
        r3 = 3._DP
        rp5 = 0.5_DP
        summ = 0._SP
        syl = Xlo
        syl2 = syl*syl
        syl3 = syl2*syl
        !
        DO i = istart, istop
          x1 = X(i-1)
          x2 = X(i)
          x3 = X(i+1)
          x12 = x1 - x2
          x13 = x1 - x3
          x23 = x2 - x3
          term1 = REAL( Y(i-1), DP )/(x12*x13)
          term2 = -REAL( Y(i), DP )/(x12*x23)
          term3 = REAL( Y(i+1), DP )/(x13*x23)
          a = term1 + term2 + term3
          b = -(x2+x3)*term1 - (x1+x3)*term2 - (x1+x2)*term3
          c = x2*x3*term1 + x1*x3*term2 + x1*x2*term3
          IF( i<=istart ) THEN
            ca = a
            cb = b
            cc = c
          ELSE
            ca = 0.5_DP*(a+ca)
            cb = 0.5_DP*(b+cb)
            cc = 0.5_DP*(c+cc)
          END IF
          syu = x2
          syu2 = syu*syu
          syu3 = syu2*syu
          summ = summ + ca*(syu3-syl3)/r3 + cb*rp5*(syu2-syl2) + cc*(syu-syl)
          ca = a
          cb = b
          cc = c
          syl = syu
          syl2 = syu2
          syl3 = syu3
        END DO
        syu = Xup
        Ans = REAL( summ + ca*(syu**3-syl3)/r3 + cb*rp5*(syu**2-syl2) + cc*(syu-syl) , SP )
      ELSE
        !
        !     SPECIAL N=2 CASE
        slope = (Y(2)-Y(1))/(X(2)-X(1))
        fl = Y(1) + slope*(Xlo-X(1))
        fr = Y(2) + slope*(Xup-X(2))
        Ans = 0.5_SP*(fl+fr)*(Xup-Xlo)
        RETURN
      END IF
    END IF
  ELSEIF( Xlo/=Xup ) THEN
    Ierr = 2
    ERROR STOP 'AVINT : THE UPPER LIMIT OF INTEGRATION WAS NOT GREATER THAN &
      &THE LOWER LIMIT.'
    RETURN
  END IF
  RETURN
  100  Ierr = 3
  ERROR STOP 'AVINT : THERE WERE LESS THAN THREE FUNCTION VALUES BETWEEN THE &
    &LIMITS OF INTEGRATION.'
  RETURN
  200  Ierr = 4
  ERROR STOP 'AVINT : THE ABSCISSAS WERE NOT STRICTLY INCREASING. &
    &MUST HAVE X(I-1) < X(I) FOR ALL I.'
  !
  RETURN
END SUBROUTINE AVINT