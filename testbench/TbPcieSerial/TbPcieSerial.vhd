--
--  File Name:         TbPcieSerial.vhd
--  Design Unit Name:  TbPcie
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Simon Southwell      email:  simon.southwell@gmail.com
--  Contributor(s):
--     Simon Southwell      simon.southwell@gmail.com
--
--
--  Description:
--      Simple PCIe GEN1/2  Model test bench

--  Revision History:
--    Date      Version    Description
--    08/2025   2026.01    Initial revision
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

library osvvm ;
  context osvvm.OsvvmContext ;

library osvvm_pcie ;
  context osvvm_pcie.PcieContext ;

entity TbPcieSerial is
end entity TbPcieSerial ;

architecture TestHarness of TbPcieSerial is

  constant tperiod_Clk : time :=   4 ns ; -- 250MHz for GEN1
  constant tpd         : time := 100 ps ;

  constant PCIE_ADDR_WIDTH   : integer := 64 ;
  constant PCIE_DATA_WIDTH   : integer := 64 ;

  -- Common configurations
  constant EN_TLP_REQ_DIGEST : boolean := false ;
  constant PIPE              : boolean := false ;
  constant PCIE_LINK_WIDTH   : integer := 1 ; -- valid values: 1, 2, 4, 8 and 16
  constant PCIE_LANE_WIDTH   : integer := IfElse(PIPE, 9, 10) ; -- 9 when PIPE else 10
  
  -- Downstream (EP) device configuration
  constant DS_NODE_NUM       : integer := 63 ;
  constant DS_ENDPOINT       : boolean := true ;
  constant DS_ENABLE_AUTO    : boolean := true ;

  -- Upstream (RC) device configuration
  constant US_NODE_NUM       : integer := 62 ;
  constant US_ENDPOINT       : boolean := false ;
  constant US_ENABLE_AUTO    : boolean := false ;


  signal Clk                 : std_logic := '1';
  signal SerClk              : std_logic := '0';
  signal nReset              : std_logic := '0';

  signal UpstreamRec, DownstreamRec  : AddressBusRecType(
          Address      (PCIE_ADDR_WIDTH-1 downto 0),
          DataToModel  (PCIE_DATA_WIDTH-1 downto 0),
          DataFromModel(PCIE_DATA_WIDTH-1 downto 0)
        ) ;

 -- PCIe Functional Interface
  signal   PcieDnLink, PcieUpLink : std_logic_vector (PCIE_LINK_WIDTH-1 downto 0) ;

  component TestCtrl is
    port (
      -- Global Signal Interface
      Clk                 : In    std_logic ;
      nReset              : In    std_logic ;

      -- Transaction Interfaces
      UpstreamRec          : inout AddressBusRecType ;
      DownstreamRec        : inout AddressBusRecType
    ) ;
  end component TestCtrl ;

begin

  ------------------------------------------------------------
  -- create clocks
  ------------------------------------------------------------
  Osvvm.ClockResetPkg.CreateClock (
    Clk        => Clk,
    Period     => Tperiod_Clk
  )  ;
  
  Osvvm.ClockResetPkg.CreateClock (
    Clk        => SerClk,
    Period     => Tperiod_Clk/10
  )  ;

  ------------------------------------------------------------
  -- create nReset
  ------------------------------------------------------------
  Osvvm.ClockResetPkg.CreateReset (
    Reset       => nReset,
    ResetActive => '0',
    Clk         => Clk,
    Period      => 7 * tperiod_Clk,
    tpd         => tpd
  ) ;

  ------------------------------------------------------------
  Upstream_1 : PcieModelSerial
  ------------------------------------------------------------
  generic map (
    NODE_NUM          => US_NODE_NUM,
    REQ_ID            => US_NODE_NUM,
    EN_TLP_REQ_DIGEST => EN_TLP_REQ_DIGEST,
    ENDPOINT          => US_ENDPOINT,
    ENABLE_AUTO       => US_ENABLE_AUTO
  )
  port map (
    -- Globals
    Clk         => Clk,
    SerClk      => SerClk,
    nReset      => nReset,

    -- Test bench Transaction Interface
    TransRec    => UpstreamRec,

    -- PCIe Functional Interface
    SerLinkOut  => PcieDnLink,
    SerLinkIn   => PcieUpLink

  ) ;

  ------------------------------------------------------------
  Downstream_1 : PcieModelSerial
  ------------------------------------------------------------
  generic map (
    NODE_NUM          => DS_NODE_NUM,
    REQ_ID            => DS_NODE_NUM,
    EN_TLP_REQ_DIGEST => EN_TLP_REQ_DIGEST,
    ENDPOINT          => DS_ENDPOINT,
    ENABLE_AUTO       => DS_ENABLE_AUTO
  )
  port map (
    -- Globals
    Clk         => Clk,
    SerClk      => SerClk,
    nReset      => nReset,

    -- Test bench Transaction Interface
    TransRec    => DownstreamRec,

    -- PCIe Functional Interface
    SerLinkOut  => PcieUpLink,
    SerLinkIn   => PcieDnLink
  ) ;

  ------------------------------------------------------------
  TestCtrl_1 : TestCtrl
  ------------------------------------------------------------
  port map (
    -- Globals
    Clk            => Clk,
    nReset         => nReset,

    -- Testbench Transaction Interfaces
    UpstreamRec    => UpstreamRec,
    DownstreamRec  => DownstreamRec
  ) ;

end architecture TestHarness ;