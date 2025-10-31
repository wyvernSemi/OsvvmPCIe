--
--  File Name:         TbPcie.vhd
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
--    08/2025   2025.??    Initial revision
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

entity TbPcie is
end entity TbPcie ;

architecture TestHarness of TbPcie is

  constant tperiod_Clk : time :=   4 ns ; -- 250MHz for GEN1
  constant tpd         : time := 100 ps ;

  constant PCIE_ADDR_WIDTH   : integer := 64 ;
  constant PCIE_DATA_WIDTH   : integer := 64 ;

  constant PCIE_LANE_WIDTH   : integer := 10 ;
  constant PCIE_LINK_WIDTH   : integer := 1 ;

  constant EN_TLP_REQ_DIGEST : boolean := false ;
  constant PIPE              : boolean := true ;
  constant DS_NODE_NUM       : integer := 63 ;
  constant US_NODE_NUM       : integer := 62 ;

  signal Clk                 : std_logic := '1';
  signal nReset              : std_logic := '0';

  signal UpstreamRec, DownstreamRec  : AddressBusRecType(
          Address      (PCIE_ADDR_WIDTH-1 downto 0),
          DataToModel  (PCIE_DATA_WIDTH-1 downto 0),
          DataFromModel(PCIE_DATA_WIDTH-1 downto 0)
        ) ;

--  -- PCIe Functional Interface
  signal   PcieDnLink, PcieUpLink : PcieRecType(
    LinkOut (0 to PCIE_LINK_WIDTH-1)(PCIE_LANE_WIDTH-1 downto 0),
    LinkIn  (0 to PCIE_LINK_WIDTH-1)(PCIE_LANE_WIDTH-1 downto 0)

  ) ;

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
  -- create Clock
  ------------------------------------------------------------
  Osvvm.ClockResetPkg.CreateClock (
    Clk        => Clk,
    Period     => Tperiod_Clk
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
  Upstream_1 : PcieModel
  ------------------------------------------------------------
  generic map (
    NODE_NUM          => US_NODE_NUM,
    REQ_ID            => US_NODE_NUM,
    EN_TLP_REQ_DIGEST => EN_TLP_REQ_DIGEST,
    PIPE              => PIPE,
    ENDPOINT          => false
  )
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- Testbench Transaction Interface
    TransRec    => UpstreamRec,

    -- PCIe Functional Interface
    PcieLinkOut => PcieUpLink.LinkOut,
    PcieLinkIn  => PcieUpLink.LinkIn

  ) ;

  ------------------------------------------------------------
  passthru_1 : PciePassThru1
  ------------------------------------------------------------
  port map (
    UpLinkIn0         => PcieDnLink.LinkOut(0),
    UpLinkOut0        => PcieDnLink.LinkIn(0),

    DownLinkIn0       => PcieUpLink.LinkOut(0),
    DownLinkOut0      => PcieUpLink.LinkIn(0)
  ) ;

  ------------------------------------------------------------
  Downstream_1 : PcieModel
  ------------------------------------------------------------
  generic map (
    NODE_NUM          => DS_NODE_NUM,
    REQ_ID            => DS_NODE_NUM,
    EN_TLP_REQ_DIGEST => EN_TLP_REQ_DIGEST,
    PIPE              => PIPE,
    ENDPOINT          => true
  )
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- Testbench Transaction Interface
    TransRec    => DownstreamRec,

    -- PCIe Functional Interface
    PcieLinkOut => PcieDnLink.LinkOut,
    PcieLinkIn  => PcieDnLink.LinkIn
  ) ;

  ------------------------------------------------------------
  Monitor_1 : PcieMonitor
  ------------------------------------------------------------
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- Pcie Functional Interface
    PcieLink    => PcieUpLink
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