!** DWNLT2
LOGICAL PURE FUNCTION DWNLT2(Me,Mend,Ir,Factor,Tau,Scalee,Wic)
  !> Subsidiary to WNLIT
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      DOUBLE PRECISION (WNLT2-S, DWNLT2-D)
  !***
  ! **Author:**  Hanson, R. J., (SNLA)
  !           Haskell, K. H., (SNLA)
  !***
  ! **Description:**
  !
  !     To test independence of incoming column.
  !
  !     Test the column IC to determine if it is linearly independent
  !     of the columns already in the basis.  In the initial tri. step,
  !     we usually want the heavy weight ALAMDA to be included in the
  !     test for independence.  In this case, the value of FACTOR will
  !     have been set to 1.E0 before this procedure is invoked.
  !     In the potentially rank deficient problem, the value of FACTOR
  !     will have been set to ALSQ=ALAMDA**2 to remove the effect of the
  !     heavy weight from the test for independence.
  !
  !     Write new column as partitioned vector
  !           (A1)  number of components in solution so far = NIV
  !           (A2)  M-NIV components
  !     And compute  SN = inverse weighted length of A1
  !                  RN = inverse weighted length of A2
  !     Call the column independent when RN > TAU*SN
  !
  !***
  ! **See also:**  DWNLIT
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   790701  DATE WRITTEN
  !   890620  Code extracted from WNLIT and made a subroutine.  (RWC)
  !   900604  DP version created from SP version.  (RWC)

  INTEGER, INTENT(IN) :: Ir, Me, Mend
  REAL(DP), INTENT(IN) :: Factor, Tau, Scalee(Mend), Wic(:)
  !
  INTEGER :: j
  REAL(DP) :: rn, sn, t
  !
  !* FIRST EXECUTABLE STATEMENT  DWNLT2
  sn = 0._SP
  rn = 0._SP
  DO j = 1, Mend
    t = Scalee(j)
    IF( j<=Me ) t = t/Factor
    t = t*Wic(j)**2
    !
    IF( j<Ir ) THEN
      sn = sn + t
    ELSE
      rn = rn + t
    END IF
  END DO
  DWNLT2 = rn>sn*Tau**2
  !
END FUNCTION DWNLT2