#################################################################
# Agora Digital Solutions Inc.
# ###############################################################
# Copyright 2020 Agora Digital Solutions IncS.

# All rights reserved in Agora Digital Solutions Inc. authored and generated code (including the selection and arrangement of the source code base regardless of the authorship of individual files), but not including any copyright interest(s) owned by a third party related to source code or object code authored or generated by non- Agora Digital Solutions Inc. personnel.
# Any use, disclosure and/or reproduction of source code is prohibited unless in compliance with the AGORA SOFTWARE DEVELOPMENT KIT LICENSE AGREEMENT.
#################################################################
from WorkerThread import WorkerThread
from HBM_PythonAppManagerBindings import *
import time
import logging
import random
#import numpy as np

class CalculationWorker(WorkerThread):

	privateRun = False
	privateBusClient = None
	privateDataOutEndpoint = ""

	privateA = IO_POINT2_T()
	privateB = IO_POINT2_T()
	privateC = IO_POINT2_T()

	def __init__(self):
		WorkerThread.__init__(self)
		self.setName("CalculationWorker")
		self.privateRun = False

	def Configure(self, serializer):
		logging.debug("New config received")

	def Initialize(self, name, busClient, dataOutEndpoint):
		logging.debug("Initialize thread CalculationWorker")
		self.privateBusClient = busClient
		self.privateDataOutEndpoint = dataOutEndpoint
		
	def HandleData(self, serializer):
		logging.debug("handleData thread CalculationWorker")
		ret_tuple = serializer.GetIOsMap()

		if 0 == ret_tuple[0]:
			io_data_map = ret_tuple[1]
			# Iterate through the IO Data Map and consume the data
			for device in io_data_map:
				device_data = io_data_map[device].device_data
				for io_name in device_data:
					logging.debug(io_name + ' => ' + str(device_data[io_name].value))



	def run(self):
		logging.debug("running thread CalculationWorker")
		self.privateRun = True

		data_serializer = JSerializer()

		while(self.privateRun == True):
			if (self.stopped() == True):
				logging.debug("Stopping thread CalculationWorker")
				self.privateRun = False
			else:
				time.sleep(5)

				header = MSG_HEADER_T()
				# Set the message header
				header.msg_type = "IODataReport"
				header.group_id ="EDGE"
				header.landing_point = "Edge"
				header.config_version = 1
				header.message_id = 896 # make message_id unique for each message e.g. use a random number 

				data_serializer.SetMsgHeader(header)

				# Initialize your IO Points
				self.privateA.value = random.uniform(10.1, 24.9)
				self.privateA.quality_code = 0
				self.privateA.timestamp = int(time.time())

				self.privateB.value = random.uniform(30.1, 34.9)
				self.privateB.quality_code = 0
				self.privateB.timestamp = int(time.time())

				self.privateC.value = random.uniform(40.1, 44.9)
				self.privateC.quality_code = 0
				self.privateC.timestamp = int(time.time())

				data_serializer.CacheIOValue("256", "io-a", self.privateA)
				data_serializer.CacheIOValue("256", "io-b", self.privateB)
				data_serializer.CacheIOValue("256", "io-c", self.privateC)

				data_serializer.SerializeCachedIOs()

				# You can loopback this data to your data handler for local testing 
				#self.HandleData(data_serializer)

				ret_tuple = data_serializer.GetAll(3)

				ret_val = ret_tuple[0]
				io_data_json = ret_tuple[1]

				if 0 == ret_val:
					# Send out your IO data message
					logging.debug("IOData Message: " + io_data_json)
					self.privateBusClient.SendMessage("DataOut", io_data_json)
