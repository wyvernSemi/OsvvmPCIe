--
--  File Name:         Pcie1EpAvPkg.vhd
--  Design Unit Name:  Pcie1EpAvPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Simon Southwell email:  simon.southwell@gmail.com
--  Contributor(s):
--     Simon Southwell simon.southwell@gmail.com
--
--
--  Description:
--      Package for Altera PCIe Components
--
--
--  Revision History:
--    Date      Version    Description
--    01/2026   2026.01       Initial revision
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library osvvm ;
  context osvvm.OsvvmContext ;

library OSVVM_Common ;
  context OSVVM_Common.OsvvmCommonContext ;

library osvvm_axi4 ;
  context osvvm_axi4.Axi4LiteContext ;


package Pcie1EpAvPkg is

    type AvMemMappedMasterRecType is record

        Address            : std_logic_vector ;
        Read               : std_logic ;
        WaitRequest        : std_logic ;
        Write              : std_logic ;
        ReadDataValid      : std_logic ;
        ReadData           : std_logic_vector ;
        WriteData          : std_logic_vector ;
        ByteEnable         : std_logic_vector ;
        BurstCount         : std_logic_vector ;

    end record AvMemMappedMasterRecType ;

    type PipeRecType is record

        -- Transmit signals
        TxData             : std_logic_vector(7 downto 0) ;
        TxDataK            : std_logic ;

        TxDetectRx         : std_logic ;
        TxElecIdle         : std_logic ;
        TxCompliance       : std_logic;
        RxPolarity         : std_logic ;
        PowerDown          : std_logic_vector(1 downto 0) ;
        Rate               : std_logic_vector(1 downto 0) ;
        TxDemph            : std_logic ;
        TxMargin           : std_logic_vector(2 downto 0) ;
        TxSwing            : std_logic;

        -- Receive signals
        RxData             : std_logic_vector(7 downto 0) ;
        RxDataK            : std_logic ;
        RxValid            : std_logic ;
        RxElecIdle         : std_logic ;
        RxStatus           : std_logic_vector(2 downto 0) ;
        PhyStatus          : std_logic ;

    end record PipeRecType ;

    component Pcie1EpAxi4Lite is
    port (
      RefClk               : in    std_logic ;
      PipeClk              : in    std_logic ;
      CoreClk              : out   std_logic ;
      nReset               : in    std_logic ;

      -- AXI4-Lite memory mapped master
      AxiBus               : inout Axi4LiteRecType ;

      -- PIPE lane 0
      Pipe0                : inout PipeRecType

    ) ;
    end component Pcie1EpAxi4Lite ;

    component pcie1epavmm is
    port (
      RefClk               : in    std_logic ;
      PipeClk              : in    std_logic ;
      nReset               : in    std_logic ;

      Bar0Address          : out   std_logic_vector (31 downto 0) ;
      Bar0Read             : out   std_logic ;
      Bar0WaitRequest      : in    std_logic ;
      Bar0Write            : out   std_logic ;
      Bar0ReadDataValid    : in    std_logic ;
      Bar0ReadData         : in    std_logic_vector (63 downto 0) ;
      Bar0WriteData        : out   std_logic_vector (63 downto 0) ;
      Bar0ByteEnable       : out   std_logic_vector  (7 downto 0) ;
      Bar0BurstCount       : out   std_logic_vector  (6 downto 0) ;

      TxData               : out   std_logic_vector  (7 downto 0) ;
      TxDataK              : out   std_logic ;

      TxDetectRx           : out   std_logic ;
      TxElecIdle           : out   std_logic ;
      TxCompliance         : out   std_logic ;
      RxPolarity           : out   std_logic ;
      PowerDown            : out   std_logic_vector  (1 downto 0) ;
      Rate                 : out   std_logic_vector  (1 downto 0) ;
      TxDemph              : out   std_logic ;
      TxMargin             : out   std_logic_vector  (2 downto 0) ;
      TxSwing              : out   std_logic ;

      RxData               : in    std_logic_vector  (7 downto 0) ;
      RxDataK              : in    std_logic ;
      RxValid              : in    std_logic ;
      RxElecIdle           : in    std_logic ;
      RxStatus             : in    std_logic_vector  (2 downto 0) ;
      PhyStatus            : in    std_logic ;

      LtssmState           : out   std_logic_vector  (4 downto 0) ;
      EidleInferSel        : out   std_logic_vector  (2 downto 0) ;
      coreclkout           : out   std_logic

    ) ;
    end component pcie1epavmm ;

end package Pcie1EpAvPkg;
