require twincat-ads

## IOC / PLC configuration
epicsEnvSet("ASYN_PORT",  "ADS_1")
epicsEnvSet("PLC_IP",     "127.0.0.1")
epicsEnvSet("PLC_AMS_ID", "127.0.0.1.1.1")
epicsEnvSet("PLC_AMS_PORT", "851")
# Must match the static route configured on the PLC side
epicsEnvSet("LOCAL_AMS_ID", "127.0.0.1.1.1")

## ADS connection
# portName, ipaddr, amsaddr, amsport, paramTableSize, priority, noAutoConnect,
# defaultSampleTimeMS, maxDelayTimeMS, adsTimeoutMS, defaultTimeSource (0=PLC, 1=EPICS)
adsAsynPortDriverConfigure("$(ASYN_PORT)", "$(PLC_IP)", "$(PLC_AMS_ID)", "$(PLC_AMS_PORT)", 1000, 0, 0, 50, 100, 1000, 0)

## Records
dbLoadTemplate("$(E3_CMD_TOP)/EPP2328-0002.substitutions", "P=TEST_SYSTEM_1:, FB=FB_EPP2328-0002,ASYN_PORT=$(ASYN_PORT),AMS_PORT=$(PLC_AMS_PORT)")

iocInit()
