
"p", "a", "l" are the number of proposers, acceptors, and learners, respectively,
"n" is the number of repetitions for each run,
"r" is the message loss rate, between 0 for 0% loss and 1 for 100% loss,
"d" is the message delay, up to the number of seconds specified,
"w" is the wait time, in seconds, before trying a new round,
"tp" and "tl" are the timeout, in seconds, by proposers and learners, respectively, when timeout is used.
"pr" and "To" are boolean variables to indicate prreemtion and Time out
"dr" indicates the directory name in which you want to save plots and report
"Liv" indicates max time you want to wait each time for consensus to be reached. By default it is 50 seconds. After which Liveness violated will be reported if consensus is not reached.(This is just to make sure the one running does not have to stop the execution in between. I know that the execution will eventually terminate.)
"Bf" Boolean variable indicating BackOff time

Generic Command :- python.exe -m da main.da p a l n r d w tp tl pr to dr Liv


SattisticsCalculator.py is a file that contains class that will help my program to plot figures and Report statistics.
Following are the plots that will be plotted for each schenario
-Avg CPU time for n Repetations svs (varying parameter)
-Avg Elapsed time for n Repetations svs (varying parameter)
-Standard Deviation for Elapsed Time for n Repetations svs (varying parameter)
-AStandard Deviation for CPU Time for n Repetations svs (varying parameter)

Also, a report will be generated providing statistics about each scenario.
Each row in this report will have following fields 
Timeout(boolean)  Preemtion(boolean)  TimeOutLearner(in seconds)  TimeOutProposer(in seconds)  WaitTime(in seconds)  MessageDelay(in seconds)  MessageLoss(Rate in seconds)  Safety(boolean)  Liveness(indicates number of successfull runs)  AvgElpTime(in seconds)   SDElpTime (std dev in seconds)  ElpTimeRange(Difference between Max and Min Elapsed Time in seconds for a set of n runs)  AvgCpuTime(in seconds)  SDCpuTime(Std dev in seconds)  CpuTimeRange (Difference between Max and Min CPU Time in seconds for a set of n runs)


Note:
- varying paramter can be r,d or w. And all other parameter will be same. 
- Suppose varying parameter is r, then we will report statistics for scenarios where r = r/5,2r/5,3r/5,4r/5,r. Similarly for d and w.

main.da This file contains all the defenitions of Proposer, acceptor, Learner and mmonitor.

By default, preemtion is False and Time out is false.

Execute following commands to get the All possible results and will store results in 4 different files:

--Timeout => False & Preemtion => False
	python -m da main.da 5 3 3 10 0.2 0.1 0.5 2 20 False False TO_False_PR_False 50 
--Timeout => False & Preemtion => True 
	python -m da main.da 5 3 3 10 0.2 0.1 0.5 2 20 True False TO_False_PR_True 50
--Timeout => True & Preemtion => False
	python -m da main.da 5 3 3 10 0.2 0.1 0.5 2 20 False True TO_True_PR_False 50
--Timeout => True & Preemtion => True
	python -m da main.da 5 3 3 10 0.2 0.1 0.5 2 20  True True TO_True_PR_True 20

When timeout is false, tp and tl are taken to be arbitary large value such as 100


CorrectnessTesting:
I have implemented a monitor class which will learn about the values learnt by Learners. It will report if the values learnt is different for any two learners.

Performance testing:
For each scenario values are reported to the the statistics class which will compute the results and put it inside appropriate directory. This class is generic enough to do analysis on any such algorithms, given that we provide appropriate parameters. Plots and Reports will be automatically generated.

Credits: The base algorithm is taken from here : https://github.com/DistAlgo/distalgo/blob/master/da/examples/lapaxos/orig.da
Apart from this I own every peice of this code.

Observations:
-The elapsed time and CPU time increased with increase in Message Loss Rate and Message Delay.
-Preemption enabeled the elapsed time and CPU time to go down, as Proposer does not have to wait for long.
-Increase in WaitTime before starting a new round enabeled the lapsed time and CPU time to go down.(Actually I think the results are a bit ambiguous for it. The time goes does down initially if we increase wait time and it again goes up.)
(See graphs and results plotted for more analysis for the above run commands)
-I think it makes much more sense to analyze the above parameters when we have both Timeout and Preemption as True. (*Check out the interesting results in its file*) 

Possible Case of Extra Credit:
Implemented Back off time in case of preemtion. For simplicity I have taken (1+(n%10))*waitTime. This will create some randomness in waiting.
Example:
--Timeout => True & Preemtion => True
python.exe -m da main.da 5 3 3 10 0.2 0.1 0.3 0.2 0.2 True True TO_True_PR_True_BackOff 50 True
Implemented a generic class StatisticsCalculator, for testing.

Note: 
sudo ulimit -n 12288 
use this command in Linux shell to increase the number of open files allowed. This will just be for the current shell so your settings won't change. This is only if you want to re run

Assertion failed: (NSViewIsCurrentlyBuildingLayerTreeForDisplay() != currentlyBuildingLayerTree), function NSViewSetCurrentlyBuildingLayerTreeForDisplay, file /BuildRoot/Library/Caches/com.apple.xbs/Sources/AppKit/AppKit-1671/AppKit.subproj/NSView.m, line 14127.
Illegal instruction: 4
----May get this error while exiting. Probably because of plotting. This is not an issue. Its a problem many mac users were facing when I checked online. Just do Cntrl-C and exit. Reports and Plots will be published. Get in touch with me if you plan to cut marks on this. Again I will say All process have terminated , this is an error which will be thrown after main gets terminated. So the purpose of this assignment is already acheived before this.