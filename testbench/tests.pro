library    osvvm_TbPcie

ChangeWorkingDirectory ../tests

MkVproc    bringup
TestName   CoSim_pcie

if {($::osvvm::ToolName eq "GHDL") || ($::osvvm::ToolName eq "NVC")} {
  SetSaveWaves
}

if {($::osvvm::ToolName eq "GHDL")} {
 SetExtendedRunOptions --ieee-asserts=disable
}

simulate TbPcie [CoSim]
