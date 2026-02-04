#  File Name:         build.pro
#  Revision:          OSVVM MODELS STANDARD VERSION
#
#  Maintainer:        Simon Southwell      email:  simon.southwell@gmail.com
#  Contributor(s):
#     Simon Southwell      simon.southwell@gmail.com
#
#
#  Description:
#        Script to generate and build Altera Cyclone V PCIe Hard IP model
#
#  Revision History:
#    Date      Version    Description
#    01/2026   2026.01    Initial revision
#
#
#  This file is part of OSVVM.
#  
#  Copyright (c) 2026 by [OSVVM Authors](../../../../../AUTHORS.md). 
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

exec -ignorestderr qsys-generate --simulation=VERILOG --output-directory=$CurrentWorkingDirectory/../pcie1_ep_avmm $CurrentWorkingDirectory/pcie1_ep_avmm.qsys

ChangeWorkingDirectory ../pcie1_ep_avmm/simulation

# Point to the generated IP's top level directory
set QSYS_SIMDIR $CurrentWorkingDirectory

# Source the build script
if {($::osvvm::ToolName eq "ActiveHDL") || ($::osvvm::ToolName eq "VSimSA") || ($::osvvm::ToolName eq "RivieraPRO")} {

  set USER_DEFINED_VERILOG_COMPILE_OPTIONS [AlteraLibArgsVlog]
  set USER_DEFINED_VHDL_COMPILE_OPTIONS [AlteraLibArgsVhdl]
  source $QSYS_SIMDIR/aldec/rivierapro_setup.tcl
} else {
  source $QSYS_SIMDIR/mentor/msim_setup.tcl
}

# Compile the Altera libraries
dev_com

# Compile the Altera auto-generated source code
com


exec rm -rf $QSYS_SIMDIR/../libraries
exec mv libraries  $QSYS_SIMDIR/..
