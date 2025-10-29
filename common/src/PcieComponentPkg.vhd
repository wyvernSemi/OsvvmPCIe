--
--  File Name:         PcieComponentPkg.vhd
--  Design Unit Name:  PcieComponentPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Simon Southwell email:  simon.southwell@gmail.com
--  Contributor(s):
--     Simon Southwell simon.southwell@gmail.com
--
--
--  Description:
--      Package for PCIe Components
--
--
--  Revision History:
--    Date      Version    Description
--    10/2025   ????.??       Initial revision
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2025 by [OSVVM Authors](../../../AUTHORS.md).
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      https://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--

library ieee ;
  use ieee.std_logic_1164.all ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

library osvvm_pcie ;
    use osvvm_pcie.PcieInterfacePkg.all ;

package PcieComponentPkg is

  ------------------------------------------------------------
  component PcieModel is
  ------------------------------------------------------------
    generic (
      MODEL_ID_NAME     : string := "" ;
      NODE_NUM          : integer := 8 ;     -- CoSim node number. Must be unique from all other CoSim elements
      ENDPOINT          : boolean := false ; -- true to enable endpoint features
      REQ_ID            : integer := 0 ;     -- Requester ID (completer ID when issuing completions)
      EN_TLP_REQ_DIGEST : boolean := false ; -- Enable ECRC on TLP requests (completions will add in response to req with ECRC---can be disabled)
      PIPE              : boolean := false ; -- true if output PIPE compatible (no scrambling or 8b10b encoding; lane width is 9 bits instead of 10)
      ENABLE_INIT_PHY   : boolean := true    -- true if PHY layer link training is enabled
    ) ;
    port (
      -- Globals
      Clk         : in   std_logic ;
      nReset      : in   std_logic ;

      -- Testbench Transaction Interface
      TransRec    : inout AddressBusRecType ;

      -- PCIe port Functional Interface
      PcieLinkOut : out  LinkType ;
      PcieLinkIn  : in   LinkType
    ) ;
  end component PcieModel ;

  ------------------------------------------------------------
  component PcieMonitor is
  ------------------------------------------------------------
    port (
      -- Globals
      Clk         : in   std_logic ;
      nReset      : in   std_logic ;

      -- AXI Manager Functional Interface
      PcieLink    : in   PcieRecType
    ) ;
  end component PcieMonitor ;


end package PcieComponentPkg ;

