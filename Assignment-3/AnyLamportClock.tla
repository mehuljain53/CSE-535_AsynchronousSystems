-------------------------- MODULE AnyLamportClock --------------------------



(***************************************************************************)
(* TLA+ specification of Lamport's distributed mutual-exclusion algorithm  as mentioned in Assignment 2 *)
(***************************************************************************)
EXTENDS Naturals, Sequences, TLC

(***************************************************************************)
(* The parameter N represents the number of processes.                     *)
(* The parameter maxClock is used only for model checking in order to      *)
(* keep the state space finite.                                            *)
(***************************************************************************)
CONSTANT N, maxClock

ASSUME NType == N \in Nat
ASSUME maxClockType == maxClock \in Nat

Proc == 1 .. N
Clock == Nat \ {0}
(***************************************************************************)
(* For model checking, add ClockConstraint as a state constraint to ensure *)
(* a finite state space and override the definition of Clock by            *)
(* 1 .. maxClock+1 so that TLC can evaluate the definition of Message.     *)
(***************************************************************************)

VARIABLES
  clock,    \* local clock of each process
  req,      \* requests received from processes stored as sequence (clock transmitted with request)
  ack,      \* acknowledgements received from processes
  network,  \* messages sent but not yet received
  crit      \* set of processes in critical section

(***************************************************************************)
(* Messages used in the algorithm.                                         *)
(***************************************************************************)
ReqMessage(c) == [type |-> "req", clock |-> c]
AckMessage(c) == [type |-> "ack", clock |-> c]
RelMessage == [type |-> "rel", clock |-> 0]

Message == { RelMessage } \union {ReqMessage(c) : c \in Clock} \union {AckMessage(c) : c \in Clock }

(***************************************************************************)
(* The type correctness predicate.                                         *)
(***************************************************************************)  
TypeOK ==
     (* clock[p] is the local clock of process p *)
  /\ clock \in [Proc -> Clock]
     (* req[p][q] stores sequence of clock associated with request from q received by p, empty if none *)
  /\ req \in [Proc -> [Proc -> Seq(Nat)]]
     (* ack[p] stores the processes that have ack'ed p's request *)
  /\ ack \in [Proc -> [Proc -> Nat]]
     (* network[p][q]: queue of messages from p to q -- pairwise FIFO communication *)
  /\ network \in [Proc -> [Proc -> Seq(Message)]]
     (* set of processes in critical section: should be empty or singleton *)
  /\ crit \in SUBSET Proc


(***************************************************************************)
(* The initial state predicate.                                            *)
(***************************************************************************) 
Init ==
  /\ clock = [p \in Proc |-> 1]
  /\ req = [p \in Proc |-> [q \in Proc |-> <<>>]]
  /\ ack = [p \in Proc |-> [q \in Proc |-> 0]]
  /\ network = [p \in Proc |-> [q \in Proc |-> <<>> ]]
  /\ crit = {}

(***************************************************************************)
(* beats(p,q) is true if process p believes that its request has higher    *)
(* priority than q's request. This is true if either p has not received a  *)
(* request from q or p's request has a smaller clock value than any received from q.*)
(* If there is a tie, the numerical process ID decides.                    *)
(***************************************************************************)
beats(p,q) ==
  \/ req[p][q] = << >>
  \/ /\  req[p][p] # << >>
     /\  req[p][q] # << >>
         /\  LET pTop == Head(req[p][p])
                 qTop == Head(req[p][q])
             IN
                \/ pTop < qTop
                \/ pTop = qTop /\ p < q

  
(***************************************************************************)
(* Broadcast a message: send it to all processes except the sender.        *)
(***************************************************************************)
Broadcast(s, m) ==
  [r \in Proc |-> IF s=r THEN network[s][r] ELSE Append(network[s][r], m)]

(***************************************************************************)
(* Process p requests access to critical section. Increment Clock time also*)
(***************************************************************************)
Request(p) ==
  /\ req'= [req EXCEPT ![p][p] = Append(@, clock[p] + 1)]
  /\ network' = [network EXCEPT ![p] = Broadcast(p, ReqMessage(clock[p] + 1))]
  /\ clock' = [clock EXCEPT ![p] = @ + 1]
  /\ UNCHANGED <<ack,crit>>

(***************************************************************************)
(* Process p receives a request from q It adds this new request to its request Queue and
increment the clock time.Also it acknowledges it with a timestamp.         *)
(***************************************************************************)
ReceiveRequest(p,q) ==
  /\ network[q][p] # << >>
      /\ LET m == Head(network[q][p])
         IN  /\ m.type = "req"
             /\ LET c == m.clock
                    nextClock == IF c < clock[p] THEN clock[p] + 1 ELSE c + 1
                IN  /\ req' = [req EXCEPT ![p][q] = Append(@,c)]
                    /\ clock' = [clock EXCEPT ![p] = IF c > clock[p] THEN c + 1 ELSE @ + 1]
                    /\ network' = [network EXCEPT ![q][p] = Tail(@),
                                                   ![p][q] = Append(@, AckMessage(nextClock))]
                    /\ UNCHANGED <<ack,crit>>
                    

(***************************************************************************)
(* Process p receives an acknowledgement from q.                           *)
(***************************************************************************)      
ReceiveAck(p,q) ==
  /\ network[q][p] # << >>
            /\ LET m == Head(network[q][p])
                IN  /\ m.type = "ack"
                            /\ ack' = [ack EXCEPT ![p][q] = m.clock]
                            /\ network' = [network EXCEPT ![q][p] = Tail(@)]
                            /\ UNCHANGED <<clock, req, crit>>
                            
                         
             
            

(**************************************************************************)
(* Process p enters the critical section.Process enter CS if it has a request in the request queue
and it beats all other processes. Also the timestamp of all the Ack should be greater than the request time stamp            *)
(**************************************************************************)
Enter(p) == 
  /\ req[p][p] # << >>
              /\ LET pTop == Head(req[p][p])
                 IN  /\ \A q \in Proc \ {p} : pTop < ack[p][q]
                     /\ \A q \in Proc \ {p} : beats(p,q)
                     /\ crit' = crit \union {p}
                     /\ UNCHANGED <<clock, req, ack, network>>
                     
  
(***************************************************************************)
(* Process p exits the critical section and notifies other processes.It deletes any one of its
 request from its request queue    *)
(***************************************************************************)
Exit(p) ==
  /\ LET l == RandomElement (1..(Len(req[p][p]))) IN
      /\ p \in crit
      /\ crit' = crit \ {p}
      /\ network' = [network EXCEPT ![p] = Broadcast(p, RelMessage)]
      (*/\req' = [req EXCEPT ![p][p] = Tail(@)]*) (*Uncomment this line of code to check for Liveness*)
      /\  req' = [req EXCEPT ![p][p] = [ i \in 1..(Len(@)-1) |-> IF i < l THEN @[i] ELSE @[i+1]]] (* Comment this line of code to check for Liveness*)
      /\ UNCHANGED <<clock,ack>>

 
(***************************************************************************)
(* Process p receives a release notification from q and deletes any request from its request queue                      *)
(***************************************************************************)
ReceiveRelease(p,q) ==
  /\ LET l == RandomElement (1..(Len(req[p][q]))) IN
      /\ network[q][p] # << >>
      /\ LET m == Head(network[q][p])
         IN  /\ m.type = "rel"
             (*/\ req' = [req EXCEPT ![p][q] = Tail(@)]*)
             /\ req' = [req EXCEPT ![p][q] = [i \in 1..(Len(@)-1) |-> IF i < l THEN @[i] ELSE @[i+1]]]
             /\ network' = [network EXCEPT ![q][p] = Tail(@)]
             /\ UNCHANGED <<clock, ack, crit>>
             /\ Print( l,TRUE)





(***************************************************************************)
(* Next-state relation.                                                    *)
(***************************************************************************)
Next ==
  \/ \E p \in Proc : Request(p) \/ Enter(p) \/ Exit(p) 
  \/ \E p \in Proc : \E q \in Proc \ {p} : ReceiveRequest(p,q) \/ ReceiveAck(p,q) \/ ReceiveRelease(p,q)



vars == <<req, network, clock, ack, crit>>

Spec == Init /\ [][Next]_vars /\ WF_vars(Next)

-----------------------------------------------------------------------------
(***************************************************************************)
(* A state constraint that is useful for validating the specification      *)
(* using finite-state model checking.Constraints imposed on clock,network and request                                  *)
(***************************************************************************)
StateConstraint == /\ \A p \in Proc : clock[p] <= maxClock
                   /\ \A p,q \in Proc : Len(network[p][q]) <= 1
                   /\ \A p,q \in Proc : Len(req[p][q]) <= 2



(***************************************************************************)
(* The main safety property of mutual exclusion.                           *)
(***************************************************************************)
Mutex == \A p,q \in crit : p = q

Live == \A p \in Proc :<> (p \in crit)


=============================================================================
\* Modification History
\* Last modified Sun Oct 07 20:57:29 EDT 2018 by mehuljain
\* Created Sun Oct 07 15:39:52 EDT 2018 by mehuljain
