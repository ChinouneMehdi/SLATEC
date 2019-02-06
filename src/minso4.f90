!*==MINSO4.f90  processed by SPAG 6.72Dc at 11:01 on  6 Feb 2019
!DECK MINSO4
      SUBROUTINE MINSO4(Usol,Idmn,Zn,Zm,Pertb)
      IMPLICIT NONE
!*--MINSO45
!*** Start of declarations inserted by SPAG
      REAL AIT , BIT , CIT , DIT , DLX , DLX4 , DLY , DLY4 , ete , Pertb , 
     &     pertrb , TDLx3 , TDLy3 , Usol , ute , Zm , Zn
      INTEGER i , Idmn , ifnl , ii , IS , istr , j , jfnl , jj , JS , jstr , K , 
     &        KSWx , KSWy , L , MIT , MS , NIT , NS
!*** End of declarations inserted by SPAG
!***BEGIN PROLOGUE  MINSO4
!***SUBSIDIARY
!***PURPOSE  Subsidiary to SEPX4
!***LIBRARY   SLATEC
!***TYPE      SINGLE PRECISION (MINSO4-S)
!***AUTHOR  (UNKNOWN)
!***DESCRIPTION
!
!     This subroutine orthogonalizes the array USOL with respect to
!     the constant array in a weighted least squares norm.
!
!     Entry at MINSO4 occurs when the final solution is
!     to be minimized with respect to the weighted
!     least squares norm.
!
!***SEE ALSO  SEPX4
!***ROUTINES CALLED  (NONE)
!***COMMON BLOCKS    SPL4
!***REVISION HISTORY  (YYMMDD)
!   801001  DATE WRITTEN
!   891214  Prologue converted to Version 4.0 format.  (BAB)
!   900402  Added TYPE section.  (WRB)
!***END PROLOGUE  MINSO4
!
      COMMON /SPL4  / KSWx , KSWy , K , L , AIT , BIT , CIT , DIT , MIT , NIT , 
     &                IS , MS , JS , NS , DLX , DLY , TDLx3 , TDLy3 , DLX4 , 
     &                DLY4
      DIMENSION Usol(Idmn,*) , Zn(*) , Zm(*)
!***FIRST EXECUTABLE STATEMENT  MINSO4
      istr = 1
      ifnl = K
      jstr = 1
      jfnl = L
!
!     COMPUTE WEIGHTED INNER PRODUCTS
!
      ute = 0.0
      ete = 0.0
      DO i = IS , MS
        ii = i - IS + 1
        DO j = JS , NS
          jj = j - JS + 1
          ete = ete + Zm(ii)*Zn(jj)
          ute = ute + Usol(i,j)*Zm(ii)*Zn(jj)
        ENDDO
      ENDDO
!
!     SET PERTURBATION PARAMETER
!
      pertrb = ute/ete
!
!     SUBTRACT OFF CONSTANT PERTRB
!
      DO i = istr , ifnl
        DO j = jstr , jfnl
          Usol(i,j) = Usol(i,j) - pertrb
        ENDDO
      ENDDO
      END SUBROUTINE MINSO4
