library    osvvm_TbPcie

ChangeWorkingDirectory ../tests
MkVproc    vc

TestName CoSim_Pcie
simulate Tb_PCIe [CoSim]

TestName CoSim_PcieAutoEp
simulate Tb_PCIeAutoEp [CoSim]

TestName CoSim_PcieSerial
simulate Tb_PCIeSerial [CoSim]

