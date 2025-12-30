--
--  File Name:         TestCtrl_e.vhd
--  Design Unit Name:  TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Simon Southwell  email:  simon.southwell@gmail.com
--  Contributor(s):
--     Simon Southwell simon.southwell@gmail.com
--
--
--  Description:
--      Test transaction source
--
--
--  Revision History:
--    Date      Version    Description
--    10/2025   2026.01    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2025 by [OSVVM Authors](../../AUTHORS.md).
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
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library OSVVM ;
  context OSVVM.OsvvmContext ;
  use osvvm.ScoreboardPkg_slv.all ;

library osvvm_pcie ;
  context osvvm_pcie.PcieContext ;

--use work.OsvvmTestCommonPkg ;

entity TestCtrl is
  port (
    -- Global Signal Interface
    Clk            : In    std_logic ;
    nReset         : In    std_logic ;

    -- Transaction Interfaces
    UpstreamRec    : inout AddressBusRecType ;
    DownstreamRec  : inout AddressBusRecType

  ) ;

  constant PCIE_ADDR_WIDTH : integer := DownstreamRec.Address'length ;
  constant PCIE_DATA_WIDTH : integer := DownstreamRec.DataToModel'length ;

end entity TestCtrl ;
