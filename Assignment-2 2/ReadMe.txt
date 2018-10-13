Assignment-2 CSE535 Asynchronous Systems

Following is a brief description of files in this folder:
1)main.da :- This is the file responsible for carrying out all the correctness and performance testing. Run the following command to execute this project. python.exe -m da main.da p r n d a.

2. lamport.da :- This file is the solution for Part-1 of this Assignment. It is the implementation of Lamport Algorithm as exactly mentioned in the paper with the assumption that 'any' means one


3. orig.da and spec.da: These files used for testing the correctness.

4. All files ending with 'perf' have all the unnecesary print and messages removed so that performance can be measured correctly

5. Monitor: This File is responsible for carrying out all the correctness and performance. For correctness testing each process is sending messages to Monitor just before and after executing critical section. So monitor has a counter which increments and decrements as messages in FIFO channel are received. If counter reaches 2 or more safety violation is reported.
For Performance testing I have used a Resource code snippet from benchmark/controllers.da file which helps me in calculating various important time values.
Monitor does not report safety and Deadlock in case of performance testing
