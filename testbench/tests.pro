TestSuite CoSim_Pcie
library    osvvm_TbPcie

ChangeWorkingDirectory ../tests
MkVproc    vc

ChangeWorkingDirectory ../testbench/TbPcie
RunTest Tb_Pcie_Phy.vhd [CoSim]
RunTest Tb_Pcie_Dll.vhd [CoSim]

TestName   CoSim_Pcie
simulate   Tb_PCIe [CoSim]

TestName   CoSim_PcieAutoEp
simulate   Tb_PCIeAutoEp [CoSim]

TestName   CoSim_PcieSerial
simulate   Tb_PCIeSerial [CoSim]

if {($::osvvm::ToolName eq "Questa") || ($::osvvm::ToolName eq "FPGA")} {

  SetExtendedSimulateOptions +nowarnPCDPC
  SetExtendedOptimizeOptions [AlteraLibArgs]

  TestName CoSim_PcieAltera
  simulate Tb_PCIeAltera [CoSim]

} elseif {($::osvvm::ToolName eq "RivieraPRO")} {

  SetExtendedSimulateOptions [AlteraLibArgsAldec]

  TestName CoSim_PcieAltera
  simulate Tb_PCIeAltera [CoSim]
}

