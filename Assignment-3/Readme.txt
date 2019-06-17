
Mehul Vinod Jain
UID : 112072812


SPEC-1 Filename :LamportMutex_1

specification size: 186 lines

ease of understanding: Very Simple.

how closely are different aspects of the algorithms followed:
1. Sending Request: In this Algorithm, Each Process is sending only one request and waiting to send another request only if the current request has been Fulfilled(Process entered critical section for this request). Message sending is done by appending request message in its network for all process(array of sequences) 
2. Receiving Request: When a process receives a request, it updates its request array for the process from which the request is received with new clock value and sends an acknowledgment message by adding a message in its sequence of networks.
3. Sending Release message: The process sets its request clock value to 0 indicating it no longer has any request. It sends a new Release message to everyone through its network array. It also sets its Sequence of Acknowledgement to Null indicating a new request will have to again receive a series of acknowledgment before it can be processed.
4. Receive Release Message: Since there is only one request in the request for a particular process, removing any request just means removing this single request. And this is done in this algorithm by a process by updating its request array for the process with value 0 from which release is received.
5. Entering Critical Section: It appropriately checks that it h beats every other process by clock Time and also ensures that the acknowledgment sequence contains all process. Only if this condition is satisfied, a process can go into CS. This ensures safety.


Properties Satisfied:
1. Safety: This Algorithm is safe as only 1 process can enter the critical section. This is because all the mutex condition specified by Lamport is implemented in this code. 
Spec == Init /\ [][Next]_vars . By including this in our spec we ensure that from every valid state we are going into a valid next state or the variables vars remain unchanged.
This is also validated by running this property in TLA+. 
Mutex == \A p,q \in crit : p = q
This is the invariant we are checking, which needs to be satisfied at every state in an ALgorithm. It checks in every state that only process is inside the critical section.
2. Liveness: 
Live == \A p \in Proc :<> (p \in crit)
By specifying this statement we are checking that the algorithm satisfies the liveness property. If we just specify our spec as: Spec == Init /\ [][Next]_vars .The Liveness property will fail as this property wants the spec to ensure that eventually, each process will be in the critical section. We can make this property becomes true by changing the spec to 
spec == Init /\ [][Next]_vars /\ WF_vars(Next)
Adding weak fairness ensures that the system is live. Every process that is always enabled from some point on, should eventually be executed.


Ease of Setting up: It was pretty straightforward as the code was given and this example was done in class by Saksham.


Checking Safety:-
Procs 		Nats 		StatesFound  		Time	DistinctStates		Diameter
2		5		1326			4282ms	685			33
2		6		2001			4470ms	1043			39
2		7		2812			4208ms	1475			46
2		8		3759			4661ms	1981			52
2		9		4842			4433ms	2561			58
3		2		2203			3684ms	511			15
3		3		41533			4469ms	10209			30
3		4		276114			6174ms	70472			41

Checking Liveliness:-
In all the below results we get Liveness failure as our spec is not able ensure that each process enters CS. But on changing the spec tospec == Init /\ [][Next]_vars /\ WF_vars(Next) we get Liveness property satisfied.
Procs 		Nats 		StatesFound  		Time	DistinctStates		Diameter
2		5		1326			1024ms	685			33
2		6		2001			1165ms	1043			39
2		7		2812			1557ms	1475			46
2		8		3759			1372ms	1981			52
2		9		4842			1541ms	2561			58
3		2		2203			2249ms	511			15
3		3		41533			2329ms	10209			30
3		4		276114			4057ms	70472			41



SPEC-2 Filename : TimeClock




specification size: 123 lines

ease of understanding: Very Simple.



how closely are different aspects of the algorithms followed:
In this Algorithm, we are using << to ensure total ordering of requests made by processes.

1. Sending Request: A process can only make a request when its state is idle which is then changed to waiting. The clock value of the current process is set to a new value greater than its current value. Each process then sends acquire message to every other process and also add this message in its requestSet.

2. Receive Request Message. 
    When a request (acquire) message is received: the Current clock is set to the max of old value and max of message timestamp. If p has not sent an acknowledgment message with a large enough timestamp that will enable Acquire(p) for requesting process then an acknowledgment message is sent. Update requestSet and LastTRcvd

3. Sending Release Message:
    Change the current state of the process to idle. Send a Release message to every other process and update is LastSent variable.

4. Receive a Release Message: On receiving a release message, the process updates its clock and also removes the corresponding process from the requesting Set.

5.     Acquire Mutex:
    A process acquires lock only if 
    -it has a request in process Request (pReq) and its state is waiting. 
    -it must have received Acknowledgement from every other process with a later timestamp than that request.
    -Also, this request must be smaller according to the total ordering rule
    -After this request is removed from reqSet of the current process

Next == \E p \in Proc : \/ Request(p) \/ Acquire(p) \/Release(p)
                        \/ \E q \in Proc \ {p} : RcvMsg(p, q)
                        \/ Tick(p)
Tick is used to update the clock value of a process P to a value greater than its current value.

Liveness == \A p \in Proc : /\ WF_vars(Acquire(p))
                            /\ \A q \in Proc \ {p} : WF_vars(RcvMsg(p, q))
Constraint == \A p \in Proc : clock[p] < NumofNats


EventuallyAcquires == \A p \in Proc: (state[p] = "waiting") ~> (state[p] = "owner")

AlwaysReleases == \A p \in Proc: WF_state(Release(p))


Spec == Init /\ [][Next]_vars /\ Liveness
By this spec we ensure that from every valid state we are going into a valid next state or the variables vars remain unchanged. Also, we add the Liveness property in which we add weak fairness on each process acquiring the mutex and also receiving a message from other processes.

Spec  == Init /\ [][Next]_vars /\ Liveness /\ AlwaysReleases
We then update the Spec to this to add Weak Fairness on Release of Mutex. This is done to ensure that if a process enters CS, it eventually leaves it.


Properties Satisfied:
1. Safety: This Algorithm is safe as only 1 process can enter the critical section. This is because all the mutex condition specified by Lamport is implemented in this code. 
Spec == Init /\ [][Next]_vars . By including this in our spec we ensure that from every valid state we are going into a valid next state or the variables vars remain unchanged.
This is also validated by running this property in TLA+. 
Mutex == \A p,q \in Proc : p # q => ( {state[p], state[q]} # {"owner"})
This is the invariant we are checking, which needs to be satisfied at every state in an ALgorithm. It checks in every state that only 1 process has the state value as owner.
2. Liveness: 
EventuallyAcquires == \A p \in Proc: (state[p] = "waiting") ~> (state[p] = "owner")
By specifying this statement we are checking that the algorithm satisfies the liveness property. This property validates that if a process intends to acquire mutex it must eventually get it. If we just specify our spec as: Spec == Init /\ [][Next]_vars /\ Liveness ,the property will fail as this property wants the spec to ensure that eventually each process will be in critical section. We can make this property becomes true by chaning the spec to 
Spec  == Init /\ [][Next]_vars /\ Liveness /\ AlwaysReleases



Ease of Setting up: Had to re write the code in TLA+. A bit boring to just copy.

Checking Safety
Procs 		Nats 		StatesFound  		Time	DistinctStates		Diameter
2		5		35863			5049ms	5733			20
2		6		119918			5836ms	18009			22
2		7		347580			6153ms	49365			23
2		8		903743			7217ms	122045			24
2		9		2157110			10635ms	278208			24
3		2		6582			3512ms	877			20
3		3		301626			5430ms	35706			34
3		4		5606881			25837ms	622560			41

Checking Liveness:-
Procs 		Nats 		StatesFound  		Time	DistinctStates		Diameter
2		5		35863			5326ms	5733			20
2		6		119918			8490ms	18009			22
2		7		347580			13372ms	49365			23
2		8		903743			27953ms	122045			24
2		9		2157110			61419ms	278208			24
3		2		6582			4848ms	877			20
3		3		301626			17923ms	35706			34
3		4		5606881			56564ms	622560			41 .. Stopped in between

Spec 3 Filename : Spec_3

specification size: 303 lines

ease of understanding: Very Simple.

how closely are different aspects of the algorithms followed:

In this Specification, all N nodes execute the Algorithm with each node represented by 2 process - site(Requesting CS) and Communicator (asynchronously receives messages). Sites are numbered from 1 to N, communicators from N+1 to 2N.  maxClock is a Constant used to bound the state space explored by the
model checker.

network:- 2-dimensional array to ensure FIFO communication
Every process maintains a queue to order the incoming pending requests.

We also define a function beats to check if request q1 has higher priority than q2 according to time stamp if both requests are records as they occur in reqQ



1. Sending a request: A sending process broadcasts message "msg" from site "from" to all sites by updating the network.

2. Receive a request: When a process receives a request message it appropriately places this request at a position according to the beats function defined. It also sends a time stamp through the network

3. Sending a Release Message: When a process finishes its execution it broadcasts a Free message to every other process. Along with this, it sets the Acknowledgement variable as NULL.

4. Receiving a release Message: When a process receives a release message it removes the request from its queue if that request exists.

5. The condition for Acquiring Mutex( Going into CS) :
    - Number of request in queue greater than 0
    - The given process is at the head of the queue
    - It has received Ack from all another process.

State constraint:
ClockConstraint == \A s \in Sites : clock[s] <= maxClock



Next == (\E self \in Sites: Site(self))
           \/ (\E self \in Comms: Comm(self))

Spec == Init /\ [][Next]_vars



Properties:
Safety: The given spec ensures that every step taken is safe and we are only moving from a safe state to another. This is proved by checking the invariant Mutex
1. Mutex ==
  \A s,t \in Sites : pc[s] = "crit" /\ pc[t] = "crit" => s = t
This invariant checks that at each point only one process is in CS.

2. Liveness: Following is the liveness property we are checking in our Code. That if a process has state=enter then eventually it will enter into CS
Liveness == \A s \in Sites : pc[s] = "enter" ~> pc[s] = "crit"
But this condition was failing when I was running with the above Spec.

On making following change in the Spec the liveness property is satisfied:

Fairness ==
  /\ \A s \in Sites : WF_vars(enter(s)) /\ WF_vars(crit(s)) /\ WF_vars(exit(s))
  /\ \A c \in Comms : WF_vars(comm(c))


FairSpec == Spec /\ Fairness

We are basically adding weak fairness on all the Actions of the Spec which eventually results in ensuring Liveness.



Ease of Setting up: Just had to copy the code from that email and convert the code from PlusCal to TLA+ and execute.

Checking Safety:-

Procs 		Nats 		StatesFound  		Time	DistinctStates		Diameter
2		5		23888			4745ms	7711			54
2		6		43121			4992ms	13863			22
2		7		67446			4915ms	21625			78
2		8		959888			5333ms	30727			90
2		9		128362			5591ms	41025			102
3		2		21646			3776ms	3990			25
3		3		578165			8303ms	99411			40
3		4		7763351			75023ms	1309654			41


Checking Liveness:-
Procs 		Nats 		StatesFound  		Time		DistinctStates		Diameter
2		5		23888			7360ms		7711			54
2		6		43121			8571ms		13863			66
2		7		67446			10405ms		21625			78
2		8		959888			11143ms		30727			90
2		9		128362			13970ms		41025			102
3		2		21646			7290ms		3990			25
3		3		578165			68009ms		99411			40
3		4		7763351			238091ms	1309654			41 .. Stopped in between


ExtraCredit. Filename : AnyLamportClock.tla

Implemented the Algorithm to remove any one request and comments are added in the code which explains it completely. Refer AnyLamportClock.tla
Most part of spec is taken from Saksham and is been edited to suit the given requirement
To check the model,
just specify the "Spec", add invariant as "Mutex" and specify the property as "StateConstraint". Click on Deadlock option. Run with "2" Process for Max Clock Value as "8"
This gives Mutex Violation as as 2 process {1,2} are in CS at the same time.
Also condition to check Deadlock is also added for that instructions are given in the code.










