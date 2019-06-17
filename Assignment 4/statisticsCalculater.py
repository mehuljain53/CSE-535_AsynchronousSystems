from tabulate import tabulate
import os
import numpy as np
import matplotlib.pyplot as plt
from statistics import stdev

class StatisticsCalculator:

	
	def __init__(self,ToutLearner,ToutProposer,drty):
		self.TimeOutLearner = ToutLearner
		self.TimeOutProposer = ToutProposer
		self.Table = []
		self.fileDirectory = drty
		self.avgCpuTimes = []
		self.avgElapsedTimes = []
		self.stdCpuTimes = []
		self.stdElapsedTimes = []
		self.varyingParameterValues = []
		self.varyingParameter = None

	def createDirectory(self):
		if not os.path.exists(self.fileDirectory):
			os.makedirs(self.fileDirectory)
		

	def addTableHeader(self,varyingParameterName , param2Name , param3Name):
		tableHeader = ["Timeout","Preemtion","TimeOutLearner","TimeOutProposer",varyingParameterName,param2Name,param3Name,"Safety","Liveness","AvgElpTime","SDElpTime","ElpTimeRange","AvgCpuTime","SDCpuTime","CpuTimeRange"]
		self.Table.append(tableHeader)
		self.varyingParameter = varyingParameterName

	def plot(self,title,parameter1Name,parameter1Value,parameter2Name,parameter2Value):
		plt.figure()
		plt.title(title, size = 14)
		plt.xlabel(parameter1Name, size = 14)
		plt.ylabel(parameter2Name, size = 14)
		plt.plot(parameter1Value,parameter2Value,'-r',label='Label')
		plt.legend(loc='upper left')
		self.createDirectory()
		filename = './' + self.fileDirectory +'/' + title +'.png'
		plt.savefig(filename)
		plt.close()
		

	def addEntry(self,varyingParameter,cpuTimeList,elapsedTimeList,isTimeOut,isPreemtionEnabled,param2Value,param3Value,isSafe,isLive):
		tableRow = []
		tableRow.append(isTimeOut)
		tableRow.append(isPreemtionEnabled)
		tableRow.append(self.TimeOutLearner)
		tableRow.append(self.TimeOutProposer)
		tableRow.append(round(varyingParameter,5))
		tableRow.append(round(param2Value,5))
		tableRow.append(round(param3Value,5))
		tableRow.append(isSafe)
		tableRow.append(isLive)
		tableRow.append(round(sum(elapsedTimeList) / len(elapsedTimeList),5))
		tableRow.append(round(stdev(elapsedTimeList),5))
		tableRow.append(round(max(elapsedTimeList) - min(elapsedTimeList),5))
		tableRow.append(round(sum(cpuTimeList) / len(cpuTimeList),5))
		tableRow.append(round(stdev(cpuTimeList),5))
		tableRow.append(round(max(cpuTimeList) - min(cpuTimeList),5))
		self.Table.append(tableRow)

		self.avgElapsedTimes.append(sum(elapsedTimeList) / len(elapsedTimeList))
		self.avgCpuTimes.append(sum(cpuTimeList) / len(cpuTimeList))
		self.stdElapsedTimes.append(stdev(elapsedTimeList))
		self.stdCpuTimes.append(stdev(cpuTimeList))
		self.varyingParameterValues.append(varyingParameter)




	def report(self):
		print(tabulate(self.Table))
		self.plot("Average Cpu Time vs " + self.varyingParameter ,self.varyingParameter,self.varyingParameterValues,"Average Cpu Time" , self.avgCpuTimes  )
		self.plot("Average Elapsed Time vs " + self.varyingParameter ,self.varyingParameter,self.varyingParameterValues,"Average Elapsed Time" , self.avgElapsedTimes  )
		self.plot("Standard Deviation - Elapsed Time vs " + self.varyingParameter ,self.varyingParameter,self.varyingParameterValues,"Standard Deviation - Elapsed Time" , self.stdElapsedTimes  )
		self.plot("Standard Deviation - Cpu Time vs " + self.varyingParameter ,self.varyingParameter,self.varyingParameterValues,"Standard Deviation - CPU Time" , self.stdCpuTimes  )
		filename = './' + self.fileDirectory +'/' + self.varyingParameter +'Analysis.txt'
		f = open(filename,'w')
		f.write(tabulate(self.Table))
		f.flush()
		f.close()
















