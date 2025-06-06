selectInst PcornerUL
selectInst PVDD1
selectInst clkPad
spaceIoInst -fixSide left -space 480
deselectAll
selectInst PcornerLR
selectInst PGND2
selectInst iorxPad
spaceIoInst -fixSide right -space 480
deselectAll
selectInst PcornerLL
selectInst PGND1
selectInst resetPad
spaceIoInst -fixSide bottom -space 480
deselectAll
selectInst PcornerUR
selectInst PVDD2
selectInst indicationPad
spaceIoInst -fixSide top -space 480

#done align

addIoFiller -cell PADSPACE_74x1u -prefix IO_FILLER -side n
addIoFiller -cell PADSPACE_74x1u -prefix IO_FILLER -side s
addIoFiller -cell PADSPACE_74x1u -prefix IO_FILLER -side w
addIoFiller -cell PADSPACE_74x1u -prefix IO_FILLER -side e
setDrawView ameba
setDrawView fplan
setDrawView place

#done IO_filler

