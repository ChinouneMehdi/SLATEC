!** DBSPVN
PURE SUBROUTINE DBSPVN(T,Jhigh,K,Indexx,X,Ileft,Vnikx,Work,Iwork)
  !> Calculate the value of all (possibly) nonzero basis functions at X.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  E3, K6
  !***
  ! **Type:**      DOUBLE PRECISION (BSPVN-S, DBSPVN-D)
  !***
  ! **Keywords:**  EVALUATION OF B-SPLINE
  !***
  ! **Author:**  Amos, D. E., (SNLA)
  !***
  ! **Description:**
  !
  !     Written by Carl de Boor and modified by D. E. Amos
  !
  !     Abstract    **** a double precision routine ****
  !         DBSPVN is the BSPLVN routine of the reference.
  !
  !         DBSPVN calculates the value of all (possibly) nonzero basis
  !         functions at X of order MAX(JHIGH,(J+1)*(INDEX-1)), where T(K)
  !         <= X <= T(N+1) and J=IWORK is set inside the routine on
  !         the first call when INDEX=1.  ILEFT is such that T(ILEFT) <=
  !         X < T(ILEFT+1).  A call to DINTRV(T,N+1,X,ILO,ILEFT,MFLAG)
  !         produces the proper ILEFT.  DBSPVN calculates using the basic
  !         algorithm needed in DBSPVD.  If only basis functions are
  !         desired, setting JHIGH=K and INDEX=1 can be faster than
  !         calling DBSPVD, but extra coding is required for derivatives
  !         (INDEX=2) and DBSPVD is set up for this purpose.
  !
  !         Left limiting values are set up as described in DBSPVD.
  !
  !     Description of Arguments
  !
  !         Input      T,X are double precision
  !          T       - knot vector of length N+K, where
  !                    N = number of B-spline basis functions
  !                    N = sum of knot multiplicities-K
  !          JHIGH   - order of B-spline, 1 <= JHIGH <= K
  !          K       - highest possible order
  !          INDEX   - INDEX = 1 gives basis functions of order JHIGH
  !                          = 2 denotes previous entry with work, IWORK
  !                              values saved for subsequent calls to
  !                              DBSPVN.
  !          X       - argument of basis functions,
  !                    T(K) <= X <= T(N+1)
  !          ILEFT   - largest integer such that
  !                    T(ILEFT) <= X <  T(ILEFT+1)
  !
  !         Output     VNIKX, WORK are double precision
  !          VNIKX   - vector of length K for spline values.
  !          WORK    - a work vector of length 2*K
  !          IWORK   - a work parameter.  Both WORK and IWORK contain
  !                    information necessary to continue for INDEX = 2.
  !                    When INDEX = 1 exclusively, these are scratch
  !                    variables and can be used for other purposes.
  !
  !     Error Conditions
  !         Improper input is a fatal error.
  !
  !***
  ! **References:**  Carl de Boor, Package for calculating with B-splines,
  !                 SIAM Journal on Numerical Analysis 14, 3 (June 1977),
  !                 pp. 441-472.
  !***
  ! **Routines called:**  XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   800901  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER, INTENT(IN) :: Ileft, Indexx, Jhigh, K
  INTEGER, INTENT(OUT) :: Iwork
  REAL(DP), INTENT(IN) :: T(Ileft+Jhigh), X
  REAL(DP), INTENT(OUT) :: Vnikx(K), Work(2*K)
  INTEGER :: imjp1, ipj, jp1, jp1ml, l
  REAL(DP) :: vm, vmprev
  !     DIMENSION T(ILEFT+JHIGH)
  !     CONTENT OF J, DELTAM, DELTAP IS EXPECTED UNCHANGED BETWEEN CALLS.
  !     WORK(I) = DELTAP(I), WORK(K+I) = DELTAM(I), I = 1,K
  !* FIRST EXECUTABLE STATEMENT  DBSPVN
  IF( K<1 ) THEN
    ERROR STOP 'DBSPVN : K DOES NOT SATISFY K>=1'
  ELSEIF( Jhigh>K .OR. Jhigh<1 ) THEN
    ERROR STOP 'DBSPVN : JHIGH DOES NOT SATISFY 1<=JHIGH<=K'
  ELSEIF( Indexx<1 .OR. Indexx>2 ) THEN
    ERROR STOP 'DBSPVN : INDEX IS NOT 1 OR 2'
  ELSEIF( X<T(Ileft) .OR. X>T(Ileft+1) ) THEN
    ERROR STOP 'DBSPVN : X DOES NOT SATISFY T(ILEFT)<=X<=T(ILEFT+1)'
  ELSE
    IF( Indexx/=2 ) THEN
      Iwork = 1
      Vnikx(1) = 1._DP
      IF( Iwork>=Jhigh ) RETURN
    END IF
    DO
      !
      ipj = Ileft + Iwork
      Work(Iwork) = T(ipj) - X
      imjp1 = Ileft - Iwork + 1
      Work(K+Iwork) = X - T(imjp1)
      vmprev = 0._DP
      jp1 = Iwork + 1
      DO l = 1, Iwork
        jp1ml = jp1 - l
        vm = Vnikx(l)/(Work(l)+Work(K+jp1ml))
        Vnikx(l) = vm*Work(l) + vmprev
        vmprev = vm*Work(K+jp1ml)
      END DO
      Vnikx(jp1) = vmprev
      Iwork = jp1
      IF( Iwork>=Jhigh ) EXIT
    END DO
  END IF
  !
  RETURN
END SUBROUTINE DBSPVN