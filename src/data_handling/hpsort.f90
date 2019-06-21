!** HPSORT
SUBROUTINE HPSORT(Hx,N,Strbeg,Strend,Iperm,Kflag,Work,Ier)
  !> Return the permutation vector generated by sorting a
  !            substring within a character array and, optionally,
  !            rearrange the elements of the array.  The array may be
  !            sorted in forward or reverse lexicographical order.  A
  !            slightly modified quicksort algorithm is used.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  N6A1C, N6A2C
  !***
  ! **Type:**      CHARACTER (SPSORT-S, DPSORT-D, IPSORT-I, HPSORT-H)
  !***
  ! **Keywords:**  PASSIVE SORTING, SINGLETON QUICKSORT, SORT, STRING SORTING
  !***
  ! **Author:**  Jones, R. E., (SNLA)
  !           Rhoads, G. S., (NBS)
  !           Sullivan, F. E., (NBS)
  !           Wisniewski, J. A., (SNLA)
  !***
  ! **Description:**
  !
  !   HPSORT returns the permutation vector IPERM generated by sorting
  !   the substrings beginning with the character STRBEG and ending with
  !   the character STREND within the strings in array HX and, optionally,
  !   rearranges the strings in HX.   HX may be sorted in increasing or
  !   decreasing lexicographical order.  A slightly modified quicksort
  !   algorithm is used.
  !
  !   IPERM is such that HX(IPERM(I)) is the Ith value in the
  !   rearrangement of HX.  IPERM may be applied to another array by
  !   calling IPPERM, SPPERM, DPPERM or HPPERM.
  !
  !   An active sort of numerical data is expected to execute somewhat
  !   more quickly than a passive sort because there is no need to use
  !   indirect references. But for the character data in HPSORT, integers
  !   in the IPERM vector are manipulated rather than the strings in HX.
  !   Moving integers may be enough faster than moving character strings
  !   to more than offset the penalty of indirect referencing.
  !
  !   Description of Parameters
  !      HX - input/output -- array of type character to be sorted.
  !           For example, to sort a 80 element array of names,
  !           each of length 6, declare HX as character HX(100)*6.
  !           If ABS(KFLAG) = 2, then the values in HX will be
  !           rearranged on output; otherwise, they are unchanged.
  !      N  - input -- number of values in array HX to be sorted.
  !      STRBEG - input -- the index of the initial character in
  !               the string HX that is to be sorted.
  !      STREND - input -- the index of the final character in
  !               the string HX that is to be sorted.
  !      IPERM - output -- permutation array such that IPERM(I) is the
  !              index of the string in the original order of the
  !              HX array that is in the Ith location in the sorted
  !              order.
  !      KFLAG - input -- control parameter:
  !            =  2  means return the permutation vector resulting from
  !                  sorting HX in lexicographical order and sort HX also.
  !            =  1  means return the permutation vector resulting from
  !                  sorting HX in lexicographical order and do not sort
  !                  HX.
  !            = -1  means return the permutation vector resulting from
  !                  sorting HX in reverse lexicographical order and do
  !                  not sort HX.
  !            = -2  means return the permutation vector resulting from
  !                  sorting HX in reverse lexicographical order and sort
  !                  HX also.
  !      WORK - character variable which must have a length specification
  !             at least as great as that of HX.
  !      IER - output -- error indicator:
  !          =  0  if no error,
  !          =  1  if N is zero or negative,
  !          =  2  if KFLAG is not 2, 1, -1, or -2,
  !          =  3  if work array is not long enough,
  !          =  4  if string beginning is beyond its end,
  !          =  5  if string beginning is out-of-range,
  !          =  6  if string end is out-of-range.
  !
  !     E X A M P L E  O F  U S E
  !
  !      CHARACTER(2) :: HX, W
  !      INTEGER STRBEG, STREND
  !      DIMENSION HX(10), IPERM(10)
  !      DATA (HX(I),I=1,10)/ '05','I ',' I','  ','Rs','9R','R9','89',
  !     1     ',*','N"'/
  !      DATA STRBEG, STREND / 1, 2 /
  !      CALL HPSORT (HX,10,STRBEG,STREND,IPERM,1,W)
  !      PRINT 100, (HX(IPERM(I)),I=1,10)
  ! 100 FORMAT (2X, A2)
  !      STOP
  !      END
  !
  !***
  ! **References:**  R. C. Singleton, Algorithm 347, An efficient algorithm
  !                 for sorting with minimal storage, Communications of
  !                 the ACM, 12, 3 (1969), pp. 185-187.
  !***
  ! **Routines called:**  XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   761101  DATE WRITTEN
  !   761118  Modified by John A. Wisniewski to use the Singleton
  !           quicksort algorithm.
  !   811001  Modified by Francis Sullivan for string data.
  !   850326  Documentation slightly modified by D. Kahaner.
  !   870423  Modified by Gregory S. Rhoads for passive sorting with the
  !           option for the rearrangement of the original data.
  !   890620  Algorithm for rearranging the data vector corrected by R.
  !           Boisvert.
  !   890622  Prologue upgraded to Version 4.0 style by D. Lozier.
  !   920507  Modified by M. McClain to revise prologue text.
  !   920818  Declarations section rebuilt and code restructured to use
  !           IF-THEN-ELSE-ENDIF.  (SMR, WRB)
  USE service, ONLY : XERMSG
  !     .. Scalar Arguments ..
  INTEGER :: Ier, Kflag, N, Strbeg, Strend
  CHARACTER(*) Work
  !     .. Array Arguments ..
  INTEGER :: Iperm(N)
  CHARACTER(*) Hx(N)
  !     .. Local Scalars ..
  REAL(SP) :: r
  INTEGER :: i, ij, indx, indx0, ir, istrt, j, k, kk, l, lm, lmt, m, nn, nn2
  !     .. Local Arrays ..
  INTEGER :: il(21), iu(21)  !     .. Intrinsic Functions ..
  INTRINSIC ABS, INT, LEN
  !* FIRST EXECUTABLE STATEMENT  HPSORT
  Ier = 0
  nn = N
  IF( nn<1 ) THEN
    Ier = 1
    CALL XERMSG('HPSORT',&
      'The number of values to be sorted, N, is not positive.',Ier,1)
    RETURN
  END IF
  kk = ABS(Kflag)
  IF( kk/=1 .AND. kk/=2 ) THEN
    Ier = 2
    CALL XERMSG('HPSORT',&
      'The sort control parameter, KFLAG, is not 2, 1, -1, or -2.',Ier,1)
    RETURN
  END IF
  !
  IF( LEN(Work)<LEN(Hx(1)) ) THEN
    Ier = 3
    CALL XERMSG(' HPSORT',&
      'The length of the work variable, WORK, is too short.',Ier,1)
    RETURN
  END IF
  IF( Strbeg>Strend ) THEN
    Ier = 4
    CALL XERMSG('HPSORT',&
      'The string beginning, STRBEG, is beyond its end, STREND.',Ier,1)
    RETURN
  END IF
  IF( Strbeg<1 .OR. Strbeg>LEN(Hx(1)) ) THEN
    Ier = 5
    CALL XERMSG('HPSORT',&
      'The string beginning, STRBEG, is out-of-range.',Ier,1)
    RETURN
  END IF
  IF( Strend<1 .OR. Strend>LEN(Hx(1)) ) THEN
    Ier = 6
    CALL XERMSG('HPSORT','The string end, STREND, is out-of-range.',Ier,1)
    RETURN
  END IF
  !
  !     Initialize permutation vector
  !
  DO i = 1, nn
    Iperm(i) = i
  END DO
  !
  !     Return if only one value is to be sorted
  !
  IF( nn==1 ) RETURN
  !
  !     Sort HX only
  !
  m = 1
  i = 1
  j = nn
  r = .375_SP
  !
  100 CONTINUE
  IF( i==j ) GOTO 300
  IF( r<=0.5898437_SP ) THEN
    r = r + 3.90625E-2_SP
  ELSE
    r = r - 0.21875_SP
  END IF
  !
  200  k = i
  !
  !     Select a central element of the array and save it in location L
  !
  ij = i + INT((j-i)*r)
  lm = Iperm(ij)
  !
  !     If first element of array is greater than LM, interchange with LM
  !
  IF( Hx(Iperm(i))(Strbeg:Strend)>Hx(lm)(Strbeg:Strend) ) THEN
    Iperm(ij) = Iperm(i)
    Iperm(i) = lm
    lm = Iperm(ij)
  END IF
  l = j
  !
  !     If last element of array is less than LM, interchange with LM
  !
  IF( Hx(Iperm(j))(Strbeg:Strend)<Hx(lm)(Strbeg:Strend) ) THEN
    Iperm(ij) = Iperm(j)
    Iperm(j) = lm
    lm = Iperm(ij)
    !
    !        If first element of array is greater than LM, interchange
    !        with LM
    !
    IF( Hx(Iperm(i))(Strbeg:Strend)>Hx(lm)(Strbeg:Strend) ) THEN
      Iperm(ij) = Iperm(i)
      Iperm(i) = lm
      lm = Iperm(ij)
    END IF
  END IF
  DO
    !
    !     Find an element in the second half of the array which is smaller
    !     than LM
    !
    l = l - 1
    IF( Hx(Iperm(l))(Strbeg:Strend)<=Hx(lm)(Strbeg:Strend) ) THEN
      DO
        !
        !     Find an element in the first half of the array which is greater
        !     than LM
        !
        k = k + 1
        IF( Hx(Iperm(k))(Strbeg:Strend)>=Hx(lm)(Strbeg:Strend) ) THEN
          !
          !     Interchange these elements
          !
          IF( k<=l ) THEN
            lmt = Iperm(l)
            Iperm(l) = Iperm(k)
            Iperm(k) = lmt
            EXIT
          ELSE
            !
            !     Save upper and lower subscripts of the array yet to be sorted
            !
            IF( l-i>j-k ) THEN
              il(m) = i
              iu(m) = l
              i = k
              m = m + 1
            ELSE
              il(m) = k
              iu(m) = j
              j = l
              m = m + 1
            END IF
            GOTO 400
          END IF
        END IF
      END DO
    END IF
  END DO
  !
  !     Begin again on another portion of the unsorted array
  !
  300  m = m - 1
  IF( m==0 ) THEN
    !
    !     Clean up
    !
    IF( Kflag<=-1 ) THEN
      !
      !        Alter array to get reverse order, if necessary
      !
      nn2 = nn/2
      DO i = 1, nn2
        ir = nn - i + 1
        lm = Iperm(i)
        Iperm(i) = Iperm(ir)
        Iperm(ir) = lm
      END DO
    END IF
    !
    !     Rearrange the values of HX if desired
    !
    IF( kk==2 ) THEN
      !
      !        Use the IPERM vector as a flag.
      !        If IPERM(I) < 0, then the I-th value is in correct location
      !
      DO istrt = 1, nn
        IF( Iperm(istrt)>=0 ) THEN
          indx = istrt
          indx0 = indx
          Work = Hx(istrt)
          DO
            IF( Iperm(indx)>0 ) THEN
              Hx(indx) = Hx(Iperm(indx))
              indx0 = indx
              Iperm(indx) = -Iperm(indx)
              indx = ABS(Iperm(indx))
              CYCLE
            END IF
            Hx(indx0) = Work
            EXIT
          END DO
        END IF
      END DO
      !
      !        Revert the signs of the IPERM values
      !
      DO i = 1, nn
        Iperm(i) = -Iperm(i)
      END DO
      !
    END IF
    RETURN
  ELSE
    i = il(m)
    j = iu(m)
  END IF
  !
  400 CONTINUE
  IF( j-i>=1 ) GOTO 200
  IF( i==1 ) GOTO 100
  i = i - 1
  DO
    !
    i = i + 1
    IF( i==j ) GOTO 300
    lm = Iperm(i+1)
    IF( Hx(Iperm(i))(Strbeg:Strend)>Hx(lm)(Strbeg:Strend) ) THEN
      k = i
      DO
        !
        Iperm(k+1) = Iperm(k)
        k = k - 1
        !
        IF( Hx(lm)(Strbeg:Strend)>=Hx(Iperm(k))(Strbeg:Strend) ) THEN
          Iperm(k+1) = lm
          EXIT
        END IF
      END DO
    END IF
  END DO
  !
  RETURN
END SUBROUTINE HPSORT
