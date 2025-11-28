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
      MODEL_ID_NAME     : string  := "" ;    -- Model name
      NODE_NUM          : integer := 8 ;     -- CoSim node number. Must be unique from all other CoSim elements
      ENDPOINT          : boolean := false ; -- true to enable endpoint features
      REQ_ID            : integer := 0 ;     -- Set Requester ID (completer ID when issuing completions)
      EN_TLP_REQ_DIGEST : boolean := false ; -- true to enable ECRC on TLP requests (completions will add in response to req with ECRC---can be disabled)
      PIPE              : boolean := false ; -- true if output to be PIPE compatible (no scrambling or 8b10b encoding; lane width is 9 bits instead of 10)
      ENABLE_INIT_PHY   : boolean := true  ; -- true if PHY layer link training is to be enabled
      ENABLE_AUTO       : boolean := false   -- true if PCIe automatic features are to be enabled
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

  ------------------------------------------------------------
  component PciePassThru is
  ------------------------------------------------------------
    port (
      DownLinkIn0    : in  std_logic_vector ;
      DownLinkIn1    : in  std_logic_vector ;
      DownLinkIn2    : in  std_logic_vector ;
      DownLinkIn3    : in  std_logic_vector ;
      DownLinkIn4    : in  std_logic_vector ;
      DownLinkIn5    : in  std_logic_vector ;
      DownLinkIn6    : in  std_logic_vector ;
      DownLinkIn7    : in  std_logic_vector ;
      DownLinkIn8    : in  std_logic_vector ;
      DownLinkIn9    : in  std_logic_vector ;
      DownLinkIn10   : in  std_logic_vector ;
      DownLinkIn11   : in  std_logic_vector ;
      DownLinkIn12   : in  std_logic_vector ;
      DownLinkIn13   : in  std_logic_vector ;
      DownLinkIn14   : in  std_logic_vector ;
      DownLinkIn15   : in  std_logic_vector ;

      DownLinkOut0   : out std_logic_vector ;
      DownLinkOut1   : out std_logic_vector ;
      DownLinkOut2   : out std_logic_vector ;
      DownLinkOut3   : out std_logic_vector ;
      DownLinkOut4   : out std_logic_vector ;
      DownLinkOut5   : out std_logic_vector ;
      DownLinkOut6   : out std_logic_vector ;
      DownLinkOut7   : out std_logic_vector ;
      DownLinkOut8   : out std_logic_vector ;
      DownLinkOut9   : out std_logic_vector ;
      DownLinkOut10  : out std_logic_vector ;
      DownLinkOut11  : out std_logic_vector ;
      DownLinkOut12  : out std_logic_vector ;
      DownLinkOut13  : out std_logic_vector ;
      DownLinkOut14  : out std_logic_vector ;
      DownLinkOut15  : out std_logic_vector ;

      UpLinkIn0      : in  std_logic_vector ;
      UpLinkIn1      : in  std_logic_vector ;
      UpLinkIn2      : in  std_logic_vector ;
      UpLinkIn3      : in  std_logic_vector ;
      UpLinkIn4      : in  std_logic_vector ;
      UpLinkIn5      : in  std_logic_vector ;
      UpLinkIn6      : in  std_logic_vector ;
      UpLinkIn7      : in  std_logic_vector ;
      UpLinkIn8      : in  std_logic_vector ;
      UpLinkIn9      : in  std_logic_vector ;
      UpLinkIn10     : in  std_logic_vector ;
      UpLinkIn11     : in  std_logic_vector ;
      UpLinkIn12     : in  std_logic_vector ;
      UpLinkIn13     : in  std_logic_vector ;
      UpLinkIn14     : in  std_logic_vector ;
      UpLinkIn15     : in  std_logic_vector ;

      UpLinkOut0     : out std_logic_vector ;
      UpLinkOut1     : out std_logic_vector ;
      UpLinkOut2     : out std_logic_vector ;
      UpLinkOut3     : out std_logic_vector ;
      UpLinkOut4     : out std_logic_vector ;
      UpLinkOut5     : out std_logic_vector ;
      UpLinkOut6     : out std_logic_vector ;
      UpLinkOut7     : out std_logic_vector ;
      UpLinkOut8     : out std_logic_vector ;
      UpLinkOut9     : out std_logic_vector ;
      UpLinkOut10    : out std_logic_vector ;
      UpLinkOut11    : out std_logic_vector ;
      UpLinkOut12    : out std_logic_vector ;
      UpLinkOut13    : out std_logic_vector ;
      UpLinkOut14    : out std_logic_vector ;
      UpLinkOut15    : out std_logic_vector
    ) ;
  end component PciePassThru;

  ------------------------------------------------------------
  component PciePassThru8 is
  ------------------------------------------------------------
    port (
      DownLinkIn0    : in  std_logic_vector ;
      DownLinkIn1    : in  std_logic_vector ;
      DownLinkIn2    : in  std_logic_vector ;
      DownLinkIn3    : in  std_logic_vector ;
      DownLinkIn4    : in  std_logic_vector ;
      DownLinkIn5    : in  std_logic_vector ;
      DownLinkIn6    : in  std_logic_vector ;
      DownLinkIn7    : in  std_logic_vector ;

      DownLinkOut0   : out std_logic_vector ;
      DownLinkOut1   : out std_logic_vector ;
      DownLinkOut2   : out std_logic_vector ;
      DownLinkOut3   : out std_logic_vector ;
      DownLinkOut4   : out std_logic_vector ;
      DownLinkOut5   : out std_logic_vector ;
      DownLinkOut6   : out std_logic_vector ;
      DownLinkOut7   : out std_logic_vector ;

      UpLinkIn0      : in  std_logic_vector ;
      UpLinkIn1      : in  std_logic_vector ;
      UpLinkIn2      : in  std_logic_vector ;
      UpLinkIn3      : in  std_logic_vector ;
      UpLinkIn4      : in  std_logic_vector ;
      UpLinkIn5      : in  std_logic_vector ;
      UpLinkIn6      : in  std_logic_vector ;
      UpLinkIn7      : in  std_logic_vector ;

      UpLinkOut0     : out std_logic_vector ;
      UpLinkOut1     : out std_logic_vector ;
      UpLinkOut2     : out std_logic_vector ;
      UpLinkOut3     : out std_logic_vector ;
      UpLinkOut4     : out std_logic_vector ;
      UpLinkOut5     : out std_logic_vector ;
      UpLinkOut6     : out std_logic_vector ;
      UpLinkOut7     : out std_logic_vector
    ) ;
  end component PciePassThru8;

  ------------------------------------------------------------
  component PciePassThru4 is
  ------------------------------------------------------------
    port (
      DownLinkIn0    : in  std_logic_vector ;
      DownLinkIn1    : in  std_logic_vector ;
      DownLinkIn2    : in  std_logic_vector ;
      DownLinkIn3    : in  std_logic_vector ;

      DownLinkOut0   : out std_logic_vector ;
      DownLinkOut1   : out std_logic_vector ;
      DownLinkOut2   : out std_logic_vector ;
      DownLinkOut3   : out std_logic_vector ;

      UpLinkIn0      : in  std_logic_vector ;
      UpLinkIn1      : in  std_logic_vector ;
      UpLinkIn2      : in  std_logic_vector ;
      UpLinkIn3      : in  std_logic_vector ;

      UpLinkOut0     : out std_logic_vector ;
      UpLinkOut1     : out std_logic_vector ;
      UpLinkOut2     : out std_logic_vector ;
      UpLinkOut3     : out std_logic_vector
    );

  end component PciePassThru4;

  ------------------------------------------------------------
  component PciePassThru2 is
  ------------------------------------------------------------
    port (
      DownLinkIn0    : in  std_logic_vector ;
      DownLinkIn1    : in  std_logic_vector ;

      DownLinkOut0   : out std_logic_vector ;
      DownLinkOut1   : out std_logic_vector ;

      UpLinkIn0      : in  std_logic_vector ;
      UpLinkIn1      : in  std_logic_vector ;

      UpLinkOut0     : out std_logic_vector ;
      UpLinkOut1     : out std_logic_vector
    );

  end component PciePassThru2 ;

  ------------------------------------------------------------
  component PciePassThru1 is
  ------------------------------------------------------------
    port (
      DownLinkIn0    : in  std_logic_vector ;

      DownLinkOut0   : out std_logic_vector ;

      UpLinkIn0      : in  std_logic_vector ;

      UpLinkOut0     : out std_logic_vector
    );

  end component PciePassThru1 ;

end package PcieComponentPkg ;

