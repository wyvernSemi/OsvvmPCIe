library    osvvm_TbPcie

ChangeWorkingDirectory ../tests
MkVproc    vc

if {($::osvvm::ToolName eq "GHDL") || ($::osvvm::ToolName eq "NVC")} {
  SetSaveWaves
}

if {($::osvvm::ToolName eq "GHDL")} {
 SetExtendedRunOptions --ieee-asserts=disable
}


TestName   CoSim_PcieAutoEp
simulate Tb_PCIeAutoEp [CoSim]

#TestName CoSim_Pcie
#simulate Tb_PCIe
