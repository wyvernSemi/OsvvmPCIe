#  File Name:         build.pro
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Simon Southwell      email:  simon.southwell@gmail.com
#  Contributor(s):
#     Simon Southwell      simon.southwell@gmail.com
#
#
#  Description:
#        Script to build Altera Cyclone V PCIe Hard IP model and wrappers
#        for Aldec tools
#
#  Revision History:
#    Date      Version    Description
#    01/2026   2026.01    Initial revision
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2026 by [OSVVM Authors](../../AUTHORS.md). 
#  
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#  
#      https://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

#
# Compile the Altera model and its OSVVM Verilog wrapper
# if the IP model directory is present
#

library pcie_cv_hip_avmm_0

if {[DirectoryExists altpcie_cv_hip_avmm_hwtcl]} { 

  ChangeWorkingDirectory ./altpcie_cv_hip_avmm_hwtcl
  
  # Point to the generated IP's top level directory
  set QSYS_SIMDIR $CurrentWorkingDirectory
  
  # Source the build script
  if {($::osvvm::ToolName eq "ActiveHDL") || ($::osvvm::ToolName eq "VSimSA") || ($::osvvm::ToolName eq "RivieraPRO")} {
    source $QSYS_SIMDIR/aldec/rivierapro_setup.tcl
  } else {
    source $QSYS_SIMDIR/mentor/msim_setup.tcl
  }
  
  # Compile the Altera libraries
  dev_com
  
  # Compile the Altera auto-generated source code
  com
  
  # Compile the wrapper
  
  eval vlog $QSYS_SIMDIR/../Pcie1EpAvmm.v -work pcie_cv_hip_avmm_0
}

#
# Compile the VHDl wrapper for AXI Lite
#

library osvvm_TbPcie

ChangeWorkingDirectory ../

analyze Pcie1EpAvPkg.vhd
analyze Pcie1EpAxi4Lite.vhd