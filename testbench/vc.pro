library    osvvm_TbPcie

ChangeWorkingDirectory ../tests

MkVproc    vc
TestName   CoSim_pcie

if {($::osvvm::ToolName eq "GHDL") || ($::osvvm::ToolName eq "NVC")} {
  SetSaveWaves
}

if {($::osvvm::ToolName eq "GHDL")} {
 SetExtendedRunOptions --ieee-asserts=disable
}

simulate Tb_PCIe
