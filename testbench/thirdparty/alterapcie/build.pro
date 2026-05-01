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
#  Copyright (c) 2026 by [OSVVM Authors](../../../../AUTHORS.md).
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

library osvvm_TbPcie

# Map the pre-compiled Altera PCIe model library
if {($::osvvm::ToolName eq "RivieraPRO")} {
  #build ./qsys
  vmap work                   $CurrentWorkingDirectory/pcie1_ep_avmm/rvlibraries/work
  vmap altera_lnsim_ver       $CurrentWorkingDirectory/pcie1_ep_avmm/rvlibraries/altera_lnsim_ver
  vmap altera_mf_ver          $CurrentWorkingDirectory/pcie1_ep_avmm/rvlibraries/altera_mf_ver
  vmap altera_ver             $CurrentWorkingDirectory/pcie1_ep_avmm/rvlibraries/altera_ver
  vmap cyclonev_hssi_ver      $CurrentWorkingDirectory/pcie1_ep_avmm/rvlibraries/cyclonev_hssi_ver
  vmap cyclonev_pcie_hip_ver  $CurrentWorkingDirectory/pcie1_ep_avmm/rvlibraries/cyclonev_pcie_hip_ver
  vmap cyclonev_ver           $CurrentWorkingDirectory/pcie1_ep_avmm/rvlibraries/cyclonev_ver
  vmap lpm_ver                $CurrentWorkingDirectory/pcie1_ep_avmm/rvlibraries/lpm_ver
  vmap sgate_ver              $CurrentWorkingDirectory/pcie1_ep_avmm/rvlibraries/sgate_ver
  vmap pcie_cv_hip_avmm_0     $CurrentWorkingDirectory/pcie1_ep_avmm/rvlibraries/pcie_cv_hip_avmm_0/
} else {
  vmap pcie_cv_hip_avmm_0     $CurrentWorkingDirectory/pcie1_ep_avmm/libraries/pcie_cv_hip_avmm_0/
}

# Compile the Verilog wrapper

eval vlog -sv -l pcie_cv_hip_avmm_0 $CurrentWorkingDirectory/pcie1epavmm.sv -work osvvm_TbPcie

#
# Compile the VHDl wrapper for AXI Lite
#


analyze Pcie1EpAvPkg.vhd
analyze Pcie1EpAxi4Lite.vhd