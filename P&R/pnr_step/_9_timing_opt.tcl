#setAnalysisMode -analysisType onChipVariation -cppr both
setAnalysisMode -analysisType onChipVariation
setOptMode -fixCap true -fixTran false -fixFanoutLoad false
optDesign -postRoute
setOptMode -fixCap false -fixTran true -fixFanoutLoad false
optDesign -postRoute
setOptMode -fixCap true -fixTran false -fixFanoutLoad false
optDesign -postRoute -hold
setOptMode -fixCap false -fixTran true -fixFanoutLoad false
optDesign -postRoute -hold
setOptMode -fixCap false -fixTran false -fixFanoutLoad true
optDesign -postRoute -hold
#optimization done
saveDesign backup/after_optimize
