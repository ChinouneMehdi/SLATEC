!*==IPPERM.f90  processed by SPAG 6.72Dc at 11:01 on  6 Feb 2019
!DECK IPPERM
SUBROUTINE IPPERM(Ix,N,Iperm,Ier)
  IMPLICIT NONE
  !*--IPPERM5
  !***BEGIN PROLOGUE  IPPERM
  !***PURPOSE  Rearrange a given array according to a prescribed
  !            permutation vector.
  !***LIBRARY   SLATEC
  !***CATEGORY  N8
  !***TYPE      INTEGER (SPPERM-S, DPPERM-D, IPPERM-I, HPPERM-H)
  !***KEYWORDS  APPLICATION OF PERMUTATION TO DATA VECTOR
  !***AUTHOR  McClain, M. A., (NIST)
  !           Rhoads, G. S., (NBS)
  !***DESCRIPTION
  !
  !         IPPERM rearranges the data vector IX according to the
  !         permutation IPERM: IX(I) <--- IX(IPERM(I)).  IPERM could come
  !         from one of the sorting routines IPSORT, SPSORT, DPSORT or
  !         HPSORT.
  !
  !     Description of Parameters
  !         IX - input/output -- integer array of values to be rearranged.
  !         N - input -- number of values in integer array IX.
  !         IPERM - input -- permutation vector.
  !         IER - output -- error indicator:
  !             =  0  if no error,
  !             =  1  if N is zero or negative,
  !             =  2  if IPERM is not a valid permutation.
  !
  !***REFERENCES  (NONE)
  !***ROUTINES CALLED  XERMSG
  !***REVISION HISTORY  (YYMMDD)
  !   900618  DATE WRITTEN
  !   920507  Modified by M. McClain to revise prologue text.
  !***END PROLOGUE  IPPERM
  INTEGER Ix(*), N, Iperm(*), i, Ier, indx, indx0, itemp, istrt
  !***FIRST EXECUTABLE STATEMENT  IPPERM
  Ier = 0
  IF ( N<1 ) THEN
    Ier = 1
    CALL XERMSG('SLATEC','IPPERM',&
      'The number of values to be rearranged, N, is not positive.'&
      ,Ier,1)
    RETURN
  ENDIF
  !
  !     CHECK WHETHER IPERM IS A VALID PERMUTATION
  !
  DO i = 1, N
    indx = ABS(Iperm(i))
    IF ( (indx>=1).AND.(indx<=N) ) THEN
      IF ( Iperm(indx)>0 ) THEN
        Iperm(indx) = -Iperm(indx)
        CYCLE
      ENDIF
    ENDIF
    Ier = 2
    CALL XERMSG('SLATEC','IPPERM',&
      'The permutation vector, IPERM, is not valid.',Ier,1)
    RETURN
  ENDDO
  !
  !     REARRANGE THE VALUES OF IX
  !
  !     USE THE IPERM VECTOR AS A FLAG.
  !     IF IPERM(I) > 0, THEN THE I-TH VALUE IS IN CORRECT LOCATION
  !
  DO istrt = 1, N
    IF ( Iperm(istrt)<=0 ) THEN
      indx = istrt
      indx0 = indx
      itemp = Ix(istrt)
      DO WHILE ( Iperm(indx)<0 )
        Ix(indx) = Ix(-Iperm(indx))
        indx0 = indx
        Iperm(indx) = -Iperm(indx)
        indx = Iperm(indx)
      ENDDO
      Ix(indx0) = itemp
    ENDIF
  ENDDO
  !
END SUBROUTINE IPPERM
