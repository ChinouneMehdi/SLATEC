!*==RADBG.f90  processed by SPAG 6.72Dc at 10:55 on  6 Feb 2019
!DECK RADBG
      SUBROUTINE RADBG(Ido,Ip,L1,Idl1,Cc,C1,C2,Ch,Ch2,Wa)
      IMPLICIT NONE
!*--RADBG5
!*** Start of declarations inserted by SPAG
      REAL ai1 , ai2 , ar1 , ar1h , ar2 , ar2h , arg , C1 , C2 , Cc , Ch , Ch2 , 
     &     dc2 , dcp , ds2 , dsp , tpi , Wa
      INTEGER i , ic , idij , Idl1 , Ido , idp2 , ik , Ip , ipp2 , ipph , is , 
     &        j , j2 , jc , k , l , L1 , lc , nbd
!*** End of declarations inserted by SPAG
!***BEGIN PROLOGUE  RADBG
!***SUBSIDIARY
!***PURPOSE  Calculate the fast Fourier transform of subvectors of
!            arbitrary length.
!***LIBRARY   SLATEC (FFTPACK)
!***TYPE      SINGLE PRECISION (RADBG-S)
!***AUTHOR  Swarztrauber, P. N., (NCAR)
!***ROUTINES CALLED  (NONE)
!***REVISION HISTORY  (YYMMDD)
!   790601  DATE WRITTEN
!   830401  Modified to use SLATEC library source file format.
!   860115  Modified by Ron Boisvert to adhere to Fortran 77 by
!           (a) changing dummy array size declarations (1) to (*),
!           (b) changing references to intrinsic function FLOAT
!               to REAL, and
!           (c) changing definition of variable TPI by using
!               FORTRAN intrinsic function ATAN instead of a DATA
!               statement.
!   881128  Modified by Dick Valent to meet prologue standards.
!   890531  Changed all specific intrinsics to generic.  (WRB)
!   890831  Modified array declarations.  (WRB)
!   891214  Prologue converted to Version 4.0 format.  (BAB)
!   900402  Added TYPE section.  (WRB)
!***END PROLOGUE  RADBG
      DIMENSION Ch(Ido,L1,*) , Cc(Ido,Ip,*) , C1(Ido,L1,*) , C2(Idl1,*) , 
     &          Ch2(Idl1,*) , Wa(*)
!***FIRST EXECUTABLE STATEMENT  RADBG
      tpi = 8.*ATAN(1.)
      arg = tpi/Ip
      dcp = COS(arg)
      dsp = SIN(arg)
      idp2 = Ido + 2
      nbd = (Ido-1)/2
      ipp2 = Ip + 2
      ipph = (Ip+1)/2
      IF ( Ido<L1 ) THEN
        DO i = 1 , Ido
          DO k = 1 , L1
            Ch(i,k,1) = Cc(i,1,k)
          ENDDO
        ENDDO
      ELSE
        DO k = 1 , L1
          DO i = 1 , Ido
            Ch(i,k,1) = Cc(i,1,k)
          ENDDO
        ENDDO
      ENDIF
      DO j = 2 , ipph
        jc = ipp2 - j
        j2 = j + j
        DO k = 1 , L1
          Ch(1,k,j) = Cc(Ido,j2-2,k) + Cc(Ido,j2-2,k)
          Ch(1,k,jc) = Cc(1,j2-1,k) + Cc(1,j2-1,k)
        ENDDO
      ENDDO
      IF ( Ido/=1 ) THEN
        IF ( nbd<L1 ) THEN
          DO j = 2 , ipph
            jc = ipp2 - j
!DIR$ IVDEP
            DO i = 3 , Ido , 2
              ic = idp2 - i
              DO k = 1 , L1
                Ch(i-1,k,j) = Cc(i-1,2*j-1,k) + Cc(ic-1,2*j-2,k)
                Ch(i-1,k,jc) = Cc(i-1,2*j-1,k) - Cc(ic-1,2*j-2,k)
                Ch(i,k,j) = Cc(i,2*j-1,k) - Cc(ic,2*j-2,k)
                Ch(i,k,jc) = Cc(i,2*j-1,k) + Cc(ic,2*j-2,k)
              ENDDO
            ENDDO
          ENDDO
        ELSE
          DO j = 2 , ipph
            jc = ipp2 - j
            DO k = 1 , L1
!DIR$ IVDEP
              DO i = 3 , Ido , 2
                ic = idp2 - i
                Ch(i-1,k,j) = Cc(i-1,2*j-1,k) + Cc(ic-1,2*j-2,k)
                Ch(i-1,k,jc) = Cc(i-1,2*j-1,k) - Cc(ic-1,2*j-2,k)
                Ch(i,k,j) = Cc(i,2*j-1,k) - Cc(ic,2*j-2,k)
                Ch(i,k,jc) = Cc(i,2*j-1,k) + Cc(ic,2*j-2,k)
              ENDDO
            ENDDO
          ENDDO
        ENDIF
      ENDIF
      ar1 = 1.
      ai1 = 0.
      DO l = 2 , ipph
        lc = ipp2 - l
        ar1h = dcp*ar1 - dsp*ai1
        ai1 = dcp*ai1 + dsp*ar1
        ar1 = ar1h
        DO ik = 1 , Idl1
          C2(ik,l) = Ch2(ik,1) + ar1*Ch2(ik,2)
          C2(ik,lc) = ai1*Ch2(ik,Ip)
        ENDDO
        dc2 = ar1
        ds2 = ai1
        ar2 = ar1
        ai2 = ai1
        DO j = 3 , ipph
          jc = ipp2 - j
          ar2h = dc2*ar2 - ds2*ai2
          ai2 = dc2*ai2 + ds2*ar2
          ar2 = ar2h
          DO ik = 1 , Idl1
            C2(ik,l) = C2(ik,l) + ar2*Ch2(ik,j)
            C2(ik,lc) = C2(ik,lc) + ai2*Ch2(ik,jc)
          ENDDO
        ENDDO
      ENDDO
      DO j = 2 , ipph
        DO ik = 1 , Idl1
          Ch2(ik,1) = Ch2(ik,1) + Ch2(ik,j)
        ENDDO
      ENDDO
      DO j = 2 , ipph
        jc = ipp2 - j
        DO k = 1 , L1
          Ch(1,k,j) = C1(1,k,j) - C1(1,k,jc)
          Ch(1,k,jc) = C1(1,k,j) + C1(1,k,jc)
        ENDDO
      ENDDO
      IF ( Ido/=1 ) THEN
        IF ( nbd<L1 ) THEN
          DO j = 2 , ipph
            jc = ipp2 - j
            DO i = 3 , Ido , 2
              DO k = 1 , L1
                Ch(i-1,k,j) = C1(i-1,k,j) - C1(i,k,jc)
                Ch(i-1,k,jc) = C1(i-1,k,j) + C1(i,k,jc)
                Ch(i,k,j) = C1(i,k,j) + C1(i-1,k,jc)
                Ch(i,k,jc) = C1(i,k,j) - C1(i-1,k,jc)
              ENDDO
            ENDDO
          ENDDO
        ELSE
          DO j = 2 , ipph
            jc = ipp2 - j
            DO k = 1 , L1
!DIR$ IVDEP
              DO i = 3 , Ido , 2
                Ch(i-1,k,j) = C1(i-1,k,j) - C1(i,k,jc)
                Ch(i-1,k,jc) = C1(i-1,k,j) + C1(i,k,jc)
                Ch(i,k,j) = C1(i,k,j) + C1(i-1,k,jc)
                Ch(i,k,jc) = C1(i,k,j) - C1(i-1,k,jc)
              ENDDO
            ENDDO
          ENDDO
        ENDIF
      ENDIF
      IF ( Ido==1 ) RETURN
      DO ik = 1 , Idl1
        C2(ik,1) = Ch2(ik,1)
      ENDDO
      DO j = 2 , Ip
        DO k = 1 , L1
          C1(1,k,j) = Ch(1,k,j)
        ENDDO
      ENDDO
      IF ( nbd>L1 ) THEN
        is = -Ido
        DO j = 2 , Ip
          is = is + Ido
          DO k = 1 , L1
            idij = is
!DIR$ IVDEP
            DO i = 3 , Ido , 2
              idij = idij + 2
              C1(i-1,k,j) = Wa(idij-1)*Ch(i-1,k,j) - Wa(idij)*Ch(i,k,j)
              C1(i,k,j) = Wa(idij-1)*Ch(i,k,j) + Wa(idij)*Ch(i-1,k,j)
            ENDDO
          ENDDO
        ENDDO
      ELSE
        is = -Ido
        DO j = 2 , Ip
          is = is + Ido
          idij = is
          DO i = 3 , Ido , 2
            idij = idij + 2
            DO k = 1 , L1
              C1(i-1,k,j) = Wa(idij-1)*Ch(i-1,k,j) - Wa(idij)*Ch(i,k,j)
              C1(i,k,j) = Wa(idij-1)*Ch(i,k,j) + Wa(idij)*Ch(i-1,k,j)
            ENDDO
          ENDDO
        ENDDO
      ENDIF
      END SUBROUTINE RADBG
