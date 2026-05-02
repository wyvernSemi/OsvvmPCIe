TestSuite CoSim_Pcie
library    osvvm_TbPcie

ChangeWorkingDirectory ../tests
MkVproc    vc

TestName CoSim_Pcie
simulate Tb_PCIe [CoSim]
