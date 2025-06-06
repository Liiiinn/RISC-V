selectObject Module CPUInst
uiSetTool move
setObjFPlanBox Module CPUInst 75.168 78.543 671.359 674.029
uiSetTool select
uiSetTool move
setObjFPlanBox Module CPUInst 73.400 80.800 670.468 499.380
uiSetTool select

selectObject Module CPUInst
uiSetTool move
setObjFPlanBox Module CPUInst 98.525 95.346 693.925 513.946

getIoFlowFlag
setIoFlowFlag 0
floorPlan -site CORE -s 1500 1500 20 20 20 20
uiSetTool select
getIoFlowFlag
fit





