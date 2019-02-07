!*==DDJAC2.f90  processed by SPAG 6.72Dc at 10:52 on  6 Feb 2019
!DECK DDJAC2
SUBROUTINE DDJAC2(T,Y,Yprime,Pd,Cj,Rpar,Ipar)
  IMPLICIT NONE
  !*--DDJAC25
  !***BEGIN PROLOGUE  DDJAC2
  !***SUBSIDIARY
  !***PURPOSE  Second Jacobian evaluator for DDASQC.
  !***LIBRARY   SLATEC (DASSL)
  !***TYPE      DOUBLE PRECISION (SDJAC2-S, DDJAC2-D)
  !***AUTHOR  PETZOLD, LINDA R., (LLNL)
  !***SEE ALSO  DDASQC
  !***ROUTINES CALLED  (NONE)
  !***REVISION HISTORY  (YYMMDD)
  !   891013  DATE WRITTEN
  !   901001  Converted prologue to 4.0 format and made all argument
  !           declarations explicit.  (FNF)
  !   901001  Eliminated 7-character variable names MBANDPn by explicitly
  !           including MBAND+n in expressions.  (FNF)
  !   901030  Made all local declarations explicit.  (FNF)
  !***END PROLOGUE  DDJAC2
  INTEGER Ipar(*)
  REAL(8) :: T, Y(*), Yprime(*), Pd(11,25), Cj, Rpar(*)
  INTEGER j, mband, ml, mu, neq, ng
  REAL(8) :: alph1, alph2
  DATA alph1/1.0D0/, alph2/1.0D0/, ng/5/
  DATA ml/5/, mu/0/, neq/25/
  !***FIRST EXECUTABLE STATEMENT  DDJAC2
  mband = ml + mu + 1
  DO j = 1, neq
    Pd(mband,j) = -2.0D0 - Cj
    Pd(mband+1,j) = alph1
    Pd(mband+2,j) = 0.0D0
    Pd(mband+3,j) = 0.0D0
    Pd(mband+4,j) = 0.0D0
    Pd(mband+5,j) = alph2
  ENDDO
  DO j = 1, neq, ng
    Pd(mband+1,j) = 0.0D0
  ENDDO
END SUBROUTINE DDJAC2
