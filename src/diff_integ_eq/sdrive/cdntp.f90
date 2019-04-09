!** CDNTP
SUBROUTINE CDNTP(H,K,N,Nq,T,Tout,Yh,Y)
  IMPLICIT NONE
  !>
  !***
  !  Subroutine CDNTP interpolates the K-th derivative of Y at
  !            TOUT, using the data in the YH array.  If K has a value
  !            greater than NQ, the NQ-th derivative is calculated.
  !***
  ! **Library:**   SLATEC (SDRIVE)
  !***
  ! **Type:**      COMPLEX (SDNTP-S, DDNTP-D, CDNTP-C)
  !***
  ! **Author:**  Kahaner, D. K., (NIST)
  !             National Institute of Standards and Technology
  !             Gaithersburg, MD  20899
  !           Sutherland, C. D., (LANL)
  !             Mail Stop D466
  !             Los Alamos National Laboratory
  !             Los Alamos, NM  87545
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   790601  DATE WRITTEN
  !   900329  Initial submission to SLATEC.

  INTEGER i, j, jj, K, kk, kused, N, Nq
  COMPLEX Y(*), Yh(N,*)
  REAL factor, H, r, T, Tout
  !* FIRST EXECUTABLE STATEMENT  CDNTP
  IF ( K==0 ) THEN
    DO i = 1, N
      Y(i) = Yh(i,Nq+1)
    END DO
    r = ((Tout-T)/H)
    DO jj = 1, Nq
      j = Nq + 1 - jj
      DO i = 1, N
        Y(i) = Yh(i,j) + r*Y(i)
      END DO
    END DO
  ELSE
    kused = MIN(K,Nq)
    factor = 1.E0
    DO kk = 1, kused
      factor = factor*(Nq+1-kk)
    END DO
    DO i = 1, N
      Y(i) = factor*Yh(i,Nq+1)
    END DO
    r = ((Tout-T)/H)
    DO jj = kused + 1, Nq
      j = kused + 1 + Nq - jj
      factor = 1.E0
      DO kk = 1, kused
        factor = factor*(j-kk)
      END DO
      DO i = 1, N
        Y(i) = factor*Yh(i,j) + r*Y(i)
      END DO
    END DO
    DO i = 1, N
      Y(i) = Y(i)*H**(-kused)
    END DO
  END IF
END SUBROUTINE CDNTP