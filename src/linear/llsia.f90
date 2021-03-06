!** LLSIA
PURE SUBROUTINE LLSIA(A,Mda,M,N,B,Mdb,Nb,Re,Ae,Key,Mode,Np,Krank,Ksure,Rnorm,W,&
    Lw,Iwork,Liw,Info)
  !> Solve a linear least squares problems by performing a QR factorization of
  !  the matrix using Householder transformations.
  !  Emphasis is put on detecting possible rank deficiency.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  D9, D5
  !***
  ! **Type:**      SINGLE PRECISION (LLSIA-S, DLLSIA-D)
  !***
  ! **Keywords:**  LINEAR LEAST SQUARES, QR FACTORIZATION
  !***
  ! **Author:**  Manteuffel, T. A., (LANL)
  !***
  ! **Description:**
  !
  !     LLSIA computes the least squares solution(s) to the problem AX=B
  !     where A is an M by N matrix with M>=N and B is the M by NB
  !     matrix of right hand sides.  User input bounds on the uncertainty
  !     in the elements of A are used to detect numerical rank deficiency.
  !     The algorithm employs a row and column pivot strategy to
  !     minimize the growth of uncertainty and round-off errors.
  !
  !     LLSIA requires (MDA+6)*N + (MDB+1)*NB + M dimensioned space
  !
  !   ******************************************************************
  !   *                                                                *
  !   *         WARNING - All input arrays are changed on exit.        *
  !   *                                                                *
  !   ******************************************************************
  !     SUBROUTINE LLSIA(A,MDA,M,N,B,MDB,NB,RE,AE,KEY,MODE,NP,
  !    1   KRANK,KSURE,RNORM,W,LW,IWORK,LIW,INFO)
  !
  !     Input..
  !
  !     A(,)          Linear coefficient matrix of AX=B, with MDA the
  !      MDA,M,N      actual first dimension of A in the calling program.
  !                   M is the row dimension (no. of EQUATIONS of the
  !                   problem) and N the col dimension (no. of UNKNOWNS).
  !                   Must have MDA>=M and M>=N.
  !
  !     B(,)          Right hand side(s), with MDB the actual first
  !      MDB,NB       dimension of B in the calling program. NB is the
  !                   number of M by 1 right hand sides. Must have
  !                   MDB>=M. If NB = 0, B is never accessed.
  !
  !   ******************************************************************
  !   *                                                                *
  !   *         Note - Use of RE and AE are what make this             *
  !   *                code significantly different from               *
  !   *                other linear least squares solvers.             *
  !   *                However, the inexperienced user is              *
  !   *                advised to set RE=0.,AE=0.,KEY=0.               *
  !   *                                                                *
  !   ******************************************************************
  !     RE(),AE(),KEY
  !     RE()          RE() is a vector of length N such that RE(I) is
  !                   the maximum relative uncertainty in column I of
  !                   the matrix A. The values of RE() must be between
  !                   0 and 1. A minimum of 10*machine precision will
  !                   be enforced.
  !
  !     AE()          AE() is a vector of length N such that AE(I) is
  !                   the maximum absolute uncertainty in column I of
  !                   the matrix A. The values of AE() must be greater
  !                   than or equal to 0.
  !
  !     KEY           For ease of use, RE and AE may be input as either
  !                   vectors or scalars. If a scalar is input, the algo-
  !                   rithm will use that value for each column of A.
  !                   The parameter key indicates whether scalars or
  !                   vectors are being input.
  !                        KEY=0     RE scalar  AE scalar
  !                        KEY=1     RE vector  AE scalar
  !                        KEY=2     RE scalar  AE vector
  !                        KEY=3     RE vector  AE vector
  !
  !     MODE          The integer mode indicates how the routine
  !                   is to react if rank deficiency is detected.
  !                   If MODE = 0 return immediately, no solution
  !                             1 compute truncated solution
  !                             2 compute minimal length solution
  !                   The inexperienced user is advised to set MODE=0
  !
  !     NP            The first NP columns of A will not be interchanged
  !                   with other columns even though the pivot strategy
  !                   would suggest otherwise.
  !                   The inexperienced user is advised to set NP=0.
  !
  !     WORK()        A real work array dimensioned 5*N.  However, if
  !                   RE or AE have been specified as vectors, dimension
  !                   WORK 4*N. If both RE and AE have been specified
  !                   as vectors, dimension WORK 3*N.
  !
  !     LW            Actual dimension of WORK
  !
  !     IWORK()       Integer work array dimensioned at least N+M.
  !
  !     LIW           Actual dimension of IWORK.
  !
  !     INFO          Is a flag which provides for the efficient
  !                   solution of subsequent problems involving the
  !                   same A but different B.
  !                   If INFO = 0 original call
  !                      INFO = 1 subsequent calls
  !                   On subsequent calls, the user must supply A, KRANK,
  !                   LW, IWORK, LIW, and the first 2*N locations of WORK
  !                   as output by the original call to LLSIA. MODE must
  !                   be equal to the value of MODE in the original call.
  !                   If MODE<2, only the first N locations of WORK
  !                   are accessed. AE, RE, KEY, and NP are not accessed.
  !
  !     Output..
  !
  !     A(,)          Contains the upper triangular part of the reduced
  !                   matrix and the transformation information. It togeth
  !                   with the first N elements of WORK (see below)
  !                   completely specify the QR factorization of A.
  !
  !     B(,)          Contains the N by NB solution matrix for X.
  !
  !     KRANK,KSURE   The numerical rank of A,  based upon the relative
  !                   and absolute bounds on uncertainty, is bounded
  !                   above by KRANK and below by KSURE. The algorithm
  !                   returns a solution based on KRANK. KSURE provides
  !                   an indication of the precision of the rank.
  !
  !     RNORM()       Contains the Euclidean length of the NB residual
  !                   vectors  B(I)-AX(I), I=1,NB.
  !
  !     WORK()        The first N locations of WORK contain values
  !                   necessary to reproduce the Householder
  !                   transformation.
  !
  !     IWORK()       The first N locations contain the order in
  !                   which the columns of A were used. The next
  !                   M locations contain the order in which the
  !                   rows of A were used.
  !
  !     INFO          Flag to indicate status of computation on completion
  !                  -1   Parameter error(s)
  !                   0 - Rank deficient, no solution
  !                   1 - Rank deficient, truncated solution
  !                   2 - Rank deficient, minimal length solution
  !                   3 - Numerical rank 0, zero solution
  !                   4 - Rank < NP
  !                   5 - Full rank
  !
  !***
  ! **References:**  T. Manteuffel, An interval analysis approach to rank
  !                 determination in linear least squares problems,
  !                 Report SAND80-0655, Sandia Laboratories, June 1980.
  !***
  ! **Routines called:**  R1MACH, U11LS, U12LS, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   810801  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   891009  Removed unreferenced variable.  (WRB)
  !   891009  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900510  Fixed an error message.  (RWC)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE service, ONLY : eps_sp
  !
  INTEGER, INTENT(IN) :: Key, Liw, Lw, M, Mda, Mdb, Mode, N, Nb, Np
  INTEGER, INTENT(INOUT) :: Info
  INTEGER, INTENT(OUT) :: Krank, Ksure
  INTEGER, INTENT(INOUT) :: Iwork(N+M)
  REAL(SP), INTENT(INOUT) :: Ae(N), Re(N), A(Mda,N), B(Mdb,Nb), W(5*N)
  REAL(SP), INTENT(OUT) :: Rnorm(Nb)
  !
  INTEGER :: i, it, n1, n2, n3, n4, n5
  REAL(SP) :: eps
  !
  !* FIRST EXECUTABLE STATEMENT  LLSIA
  IF( Info<0 .OR. Info>1 ) THEN
    ERROR STOP 'LLSIA : INFO OUT OF RANGE'
    RETURN
  ELSE
    it = Info
    Info = -1
    IF( Nb==0 .AND. it==1 ) THEN
      !
      !     ERROR MESSAGES
      !
      ERROR STOP 'LLSIA : SOLUTION ONLY (INFO=1) BUT NO RIGHT HAND SIDE (NB=0)'
      RETURN
    ELSEIF( M<1 ) THEN
      ERROR STOP 'LLSIA : M<1'
      RETURN
    ELSEIF( N<1 ) THEN
      ERROR STOP 'LLSIA : N<1'
      RETURN
    ELSE
      IF( N>M ) THEN
        ERROR STOP 'LLSIA : N>M'
        RETURN
      ELSE
        IF( Mda<M ) THEN
          ERROR STOP 'LLSIA : MDA<M'
          RETURN
        ELSE
          IF( Liw<M+N ) THEN
            ERROR STOP 'LLSIA : LIW<M+N'
            RETURN
          ELSE
            IF( Mode<0 .OR. Mode>3 ) THEN
              ERROR STOP 'LLSIA : MODE OUT OF RANGE'
              RETURN
            ELSE
              IF( Nb/=0 ) THEN
                IF( Nb<0 ) THEN
                  ERROR STOP 'LLSIA : NB<0'
                  RETURN
                ELSEIF( Mdb<M ) THEN
                  ERROR STOP 'LLSIA : MDB<M'
                  RETURN
                ELSEIF( it/=0 ) THEN
                  GOTO 2
                END IF
              END IF
              IF( Key<0 .OR. Key>3 ) THEN
                ERROR STOP 'LLSIA : KEY OUT OF RANGE'
                RETURN
              ELSE
                IF( Key==0 .AND. Lw<5*N ) GOTO 5
                IF( Key==1 .AND. Lw<4*N ) GOTO 5
                IF( Key==2 .AND. Lw<4*N ) GOTO 5
                IF( Key==3 .AND. Lw<3*N ) GOTO 5
                IF( Np<0 .OR. Np>N ) THEN
                  ERROR STOP 'LLSIA : NP OUT OF RANGE'
                  RETURN
                ELSE
                  !
                  eps = 10._SP*eps_sp
                  n1 = 1
                  n2 = n1 + N
                  n3 = n2 + N
                  n4 = n3 + N
                  n5 = n4 + N
                  !
                  IF( Key==1 ) THEN
                    !
                    IF( Ae(1)<0._SP ) GOTO 100
                    DO i = 1, N
                      IF( Re(i)<0._SP ) GOTO 10
                      IF( Re(i)>1._SP ) GOTO 20
                      IF( Re(i)<eps ) Re(i) = eps
                      W(n4-1+i) = Ae(1)
                    END DO
                    CALL U11LS(A,Mda,M,N,Re,W(n4),Mode,Np,Krank,Ksure,W(n1),&
                      W(n2),W(n3),Iwork(n1),Iwork(n2))
                  ELSEIF( Key==2 ) THEN
                    !
                    IF( Re(1)<0._SP ) GOTO 10
                    IF( Re(1)>1._SP ) GOTO 20
                    IF( Re(1)<eps ) Re(1) = eps
                    DO i = 1, N
                      W(n4-1+i) = Re(1)
                      IF( Ae(i)<0._SP ) GOTO 100
                    END DO
                    CALL U11LS(A,Mda,M,N,W(n4),Ae,Mode,Np,Krank,Ksure,W(n1),&
                      W(n2),W(n3),Iwork(n1),Iwork(n2))
                  ELSEIF( Key==3 ) THEN
                    !
                    DO i = 1, N
                      IF( Re(i)<0._SP ) GOTO 10
                      IF( Re(i)>1._SP ) GOTO 20
                      IF( Re(i)<eps ) Re(i) = eps
                      IF( Ae(i)<0._SP ) GOTO 100
                    END DO
                    CALL U11LS(A,Mda,M,N,Re,Ae,Mode,Np,Krank,Ksure,W(n1),&
                      W(n2),W(n3),Iwork(n1),Iwork(n2))
                  ELSE
                    !
                    IF( Re(1)<0._SP ) GOTO 10
                    IF( Re(1)>1._SP ) GOTO 20
                    IF( Re(1)<eps ) Re(1) = eps
                    IF( Ae(1)<0._SP ) GOTO 100
                    DO i = 1, N
                      W(n4-1+i) = Re(1)
                      W(n5-1+i) = Ae(1)
                    END DO
                    CALL U11LS(A,Mda,M,N,W(n4),W(n5),Mode,Np,Krank,Ksure,&
                      W(n1),W(n2),W(n3),Iwork(n1),Iwork(n2))
                  END IF
                END IF
              END IF
            END IF
            !
            !     DETERMINE INFO
            !
            2 CONTINUE
            IF( Krank==N ) THEN
              Info = 5
            ELSEIF( Krank==0 ) THEN
              Info = 3
            ELSEIF( Krank>=Np ) THEN
              Info = Mode
              IF( Mode==0 ) RETURN
            ELSE
              Info = 4
              RETURN
            END IF
            IF( Nb==0 ) RETURN
            !
            !     SOLUTION PHASE
            !
            n1 = 1
            n2 = n1 + N
            n3 = n2 + N
            IF( Info==2 ) THEN
              !
              IF( Lw>=n3-1 ) THEN
                CALL U12LS(A,Mda,M,N,B,Mdb,Nb,Mode,Krank,Rnorm,W(n1),W(n2),&
                  Iwork(n1),Iwork(n2))
                RETURN
              END IF
            ELSEIF( Lw>=n2-1 ) THEN
              CALL U12LS(A,Mda,M,N,B,Mdb,Nb,Mode,Krank,Rnorm,W(n1),W(n1),&
                Iwork(n1),Iwork(n2))
              RETURN
            END IF
          END IF
          5  ERROR STOP 'LLSIA : INSUFFICIENT WORK SPACE'
          Info = -1
          RETURN
        END IF
        10  ERROR STOP 'LLSIA : RE(I) < 0'
        RETURN
      END IF
      20  ERROR STOP 'LLSIA : RE(I) > 1'
      RETURN
    END IF
  END IF
  100  ERROR STOP 'LLSIA : AE(I) < 0'

  RETURN
END SUBROUTINE LLSIA