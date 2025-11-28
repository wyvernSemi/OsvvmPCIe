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

entity TbPcieAutoEP is
end entity TbPcieAutoEP ;

architecture TestHarness of TbPcieAutoEP is

  constant tperiod_Clk : time :=   4 ns ; -- 250MHz for GEN1
  constant tpd         : time := 100 ps ;

  constant PCIE_ADDR_WIDTH   : integer := 64 ;
  constant PCIE_DATA_WIDTH   : integer := 64 ;

  -- Common configurations
  constant EN_TLP_REQ_DIGEST : boolean := false ;
  constant PIPE              : boolean := true ;
  constant PCIE_LINK_WIDTH   : integer := 2 ; -- valid values: 1, 2, 4, 8 and 16
  constant PCIE_LANE_WIDTH   : integer := selconst(PIPE, 9, 10) ; -- 9 when PIPE else 10
  
  -- Downstream (EP) device configuration
  constant DS_NODE_NUM       : integer := 63 ;
  constant DS_ENDPOINT       : boolean := true ;
  constant DS_ENABLE_AUTO    : boolean := true ;

  -- Upstream (RC) device configuration
  constant US_NODE_NUM       : integer := 62 ;
  constant US_ENDPOINT       : boolean := false ;
  constant US_ENABLE_AUTO    : boolean := false ;


  signal Clk                 : std_logic := '1';
  signal nReset              : std_logic := '0';

  signal UpstreamRec, DownstreamRec  : AddressBusRecType(
          Address      (PCIE_ADDR_WIDTH-1 downto 0),
          DataToModel  (PCIE_DATA_WIDTH-1 downto 0),
          DataFromModel(PCIE_DATA_WIDTH-1 downto 0)
        ) ;

--  -- PCIe Functional Interface
  signal   PcieDnLink, PcieUpLink : PcieRecType(
    LinkOut (0 to MAX_PCIE_LINK_WIDTH-1)(PCIE_LANE_WIDTH-1 downto 0),
    LinkIn  (0 to MAX_PCIE_LINK_WIDTH-1)(PCIE_LANE_WIDTH-1 downto 0)

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
    ENDPOINT          => US_ENDPOINT,
    ENABLE_AUTO       => US_ENABLE_AUTO
  )
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- Testbench Transaction Interface
    TransRec    => UpstreamRec,

    -- PCIe Functional Interface
    PcieLinkOut => PcieUpLink.LinkOut(0 to PCIE_LINK_WIDTH-1),
    PcieLinkIn  => PcieUpLink.LinkIn (0 to PCIE_LINK_WIDTH-1)

  ) ;

----------------------------------------------------------------
-- Generate the correct passthru for the specified link width --
----------------------------------------------------------------

g_lanewidth : if PCIE_LINK_WIDTH = 1 generate
  ------------------------------------------------------------
  passthru_1 : PciePassThru1
  ------------------------------------------------------------
  port map (
    UpLinkIn0         => PcieDnLink.LinkOut(0),
    UpLinkOut0        => PcieDnLink.LinkIn(0),

    DownLinkIn0       => PcieUpLink.LinkOut(0),
    DownLinkOut0      => PcieUpLink.LinkIn(0)
  ) ;

elsif PCIE_LINK_WIDTH = 2 generate

  ------------------------------------------------------------
  passthru_1 : PciePassThru2
  ------------------------------------------------------------
  port map (
    UpLinkIn0         => PcieDnLink.LinkOut(0),
    UpLinkOut0        => PcieDnLink.LinkIn(0),
    UpLinkIn1         => PcieDnLink.LinkOut(1),
    UpLinkOut1        => PcieDnLink.LinkIn(1),

    DownLinkIn0       => PcieUpLink.LinkOut(0),
    DownLinkOut0      => PcieUpLink.LinkIn(0),
    DownLinkIn1       => PcieUpLink.LinkOut(1),
    DownLinkOut1      => PcieUpLink.LinkIn(1)
  ) ;

elsif PCIE_LINK_WIDTH = 4 generate

  ------------------------------------------------------------
  passthru_1 : PciePassThru4
  ------------------------------------------------------------
  port map (
    UpLinkIn0         => PcieDnLink.LinkOut(0),
    UpLinkOut0        => PcieDnLink.LinkIn(0),
    UpLinkIn1         => PcieDnLink.LinkOut(1),
    UpLinkOut1        => PcieDnLink.LinkIn(1),
    UpLinkIn2         => PcieDnLink.LinkOut(2),
    UpLinkOut2        => PcieDnLink.LinkIn(2),
    UpLinkIn3         => PcieDnLink.LinkOut(3),
    UpLinkOut3        => PcieDnLink.LinkIn(3),

    DownLinkIn0       => PcieUpLink.LinkOut(0),
    DownLinkOut0      => PcieUpLink.LinkIn(0),
    DownLinkIn1       => PcieUpLink.LinkOut(1),
    DownLinkOut1      => PcieUpLink.LinkIn(1),
    DownLinkIn2       => PcieUpLink.LinkOut(2),
    DownLinkOut2      => PcieUpLink.LinkIn(2),
    DownLinkIn3       => PcieUpLink.LinkOut(3),
    DownLinkOut3      => PcieUpLink.LinkIn(3)
  ) ;

elsif PCIE_LINK_WIDTH = 8 generate

  ------------------------------------------------------------
  passthru_1 : PciePassThru8
  ------------------------------------------------------------
  port map (
    UpLinkIn0         => PcieDnLink.LinkOut(0),
    UpLinkOut0        => PcieDnLink.LinkIn(0),
    UpLinkIn1         => PcieDnLink.LinkOut(1),
    UpLinkOut1        => PcieDnLink.LinkIn(1),
    UpLinkIn2         => PcieDnLink.LinkOut(2),
    UpLinkOut2        => PcieDnLink.LinkIn(2),
    UpLinkIn3         => PcieDnLink.LinkOut(3),
    UpLinkOut3        => PcieDnLink.LinkIn(3),
    UpLinkIn4         => PcieDnLink.LinkOut(4),
    UpLinkOut4        => PcieDnLink.LinkIn(4),
    UpLinkIn5         => PcieDnLink.LinkOut(5),
    UpLinkOut5        => PcieDnLink.LinkIn(5),
    UpLinkIn6         => PcieDnLink.LinkOut(6),
    UpLinkOut6        => PcieDnLink.LinkIn(6),
    UpLinkIn7         => PcieDnLink.LinkOut(7),
    UpLinkOut7        => PcieDnLink.LinkIn(7),

    DownLinkIn0       => PcieUpLink.LinkOut(0),
    DownLinkOut0      => PcieUpLink.LinkIn(0),
    DownLinkIn1       => PcieUpLink.LinkOut(1),
    DownLinkOut1      => PcieUpLink.LinkIn(1),
    DownLinkIn2       => PcieUpLink.LinkOut(2),
    DownLinkOut2      => PcieUpLink.LinkIn(2),
    DownLinkIn3       => PcieUpLink.LinkOut(3),
    DownLinkOut3      => PcieUpLink.LinkIn(3),
    DownLinkIn4       => PcieUpLink.LinkOut(4),
    DownLinkOut4      => PcieUpLink.LinkIn(4),
    DownLinkIn5       => PcieUpLink.LinkOut(5),
    DownLinkOut5      => PcieUpLink.LinkIn(5),
    DownLinkIn6       => PcieUpLink.LinkOut(6),
    DownLinkOut6      => PcieUpLink.LinkIn(6),
    DownLinkIn7       => PcieUpLink.LinkOut(7),
    DownLinkOut7      => PcieUpLink.LinkIn(7)
  ) ;

else generate

  ------------------------------------------------------------
  passthru_1 : PciePassThru
  ------------------------------------------------------------
  port map (
    UpLinkIn0         => PcieDnLink.LinkOut(0),
    UpLinkOut0        => PcieDnLink.LinkIn(0),
    UpLinkIn1         => PcieDnLink.LinkOut(1),
    UpLinkOut1        => PcieDnLink.LinkIn(1),
    UpLinkIn2         => PcieDnLink.LinkOut(2),
    UpLinkOut2        => PcieDnLink.LinkIn(2),
    UpLinkIn3         => PcieDnLink.LinkOut(3),
    UpLinkOut3        => PcieDnLink.LinkIn(3),
    UpLinkIn4         => PcieDnLink.LinkOut(4),
    UpLinkOut4        => PcieDnLink.LinkIn(4),
    UpLinkIn5         => PcieDnLink.LinkOut(5),
    UpLinkOut5        => PcieDnLink.LinkIn(5),
    UpLinkIn6         => PcieDnLink.LinkOut(6),
    UpLinkOut6        => PcieDnLink.LinkIn(6),
    UpLinkIn7         => PcieDnLink.LinkOut(7),
    UpLinkOut7        => PcieDnLink.LinkIn(7),
    UpLinkIn8         => PcieDnLink.LinkOut(8),
    UpLinkOut8        => PcieDnLink.LinkIn(8),
    UpLinkIn9         => PcieDnLink.LinkOut(9),
    UpLinkOut9        => PcieDnLink.LinkIn(9),
    UpLinkIn10        => PcieDnLink.LinkOut(10),
    UpLinkOut10       => PcieDnLink.LinkIn(10),
    UpLinkIn11        => PcieDnLink.LinkOut(11),
    UpLinkOut11       => PcieDnLink.LinkIn(11),
    UpLinkIn12        => PcieDnLink.LinkOut(12),
    UpLinkOut12       => PcieDnLink.LinkIn(12),
    UpLinkIn13        => PcieDnLink.LinkOut(13),
    UpLinkOut13       => PcieDnLink.LinkIn(13),
    UpLinkIn14        => PcieDnLink.LinkOut(14),
    UpLinkOut14       => PcieDnLink.LinkIn(14),
    UpLinkIn15        => PcieDnLink.LinkOut(15),
    UpLinkOut15       => PcieDnLink.LinkIn(15),

    DownLinkIn0       => PcieUpLink.LinkOut(0),
    DownLinkOut0      => PcieUpLink.LinkIn(0),
    DownLinkIn1       => PcieUpLink.LinkOut(1),
    DownLinkOut1      => PcieUpLink.LinkIn(1),
    DownLinkIn2       => PcieUpLink.LinkOut(2),
    DownLinkOut2      => PcieUpLink.LinkIn(2),
    DownLinkIn3       => PcieUpLink.LinkOut(3),
    DownLinkOut3      => PcieUpLink.LinkIn(3),
    DownLinkIn4       => PcieUpLink.LinkOut(4),
    DownLinkOut4      => PcieUpLink.LinkIn(4),
    DownLinkIn5       => PcieUpLink.LinkOut(5),
    DownLinkOut5      => PcieUpLink.LinkIn(5),
    DownLinkIn6       => PcieUpLink.LinkOut(6),
    DownLinkOut6      => PcieUpLink.LinkIn(6),
    DownLinkIn7       => PcieUpLink.LinkOut(7),
    DownLinkOut7      => PcieUpLink.LinkIn(7),
    DownLinkIn8       => PcieUpLink.LinkOut(8),
    DownLinkOut8      => PcieUpLink.LinkIn(8),
    DownLinkIn9       => PcieUpLink.LinkOut(9),
    DownLinkOut9      => PcieUpLink.LinkIn(9),
    DownLinkIn10      => PcieUpLink.LinkOut(10),
    DownLinkOut10     => PcieUpLink.LinkIn(10),
    DownLinkIn11      => PcieUpLink.LinkOut(11),
    DownLinkOut11     => PcieUpLink.LinkIn(11),
    DownLinkIn12      => PcieUpLink.LinkOut(12),
    DownLinkOut12     => PcieUpLink.LinkIn(12),
    DownLinkIn13      => PcieUpLink.LinkOut(13),
    DownLinkOut13     => PcieUpLink.LinkIn(13),
    DownLinkIn14      => PcieUpLink.LinkOut(14),
    DownLinkOut14     => PcieUpLink.LinkIn(14),
    DownLinkIn15      => PcieUpLink.LinkOut(15),
    DownLinkOut15     => PcieUpLink.LinkIn(15)
  ) ;

end generate ;

  ------------------------------------------------------------
  Downstream_1 : PcieModel
  ------------------------------------------------------------
  generic map (
    NODE_NUM          => DS_NODE_NUM,
    REQ_ID            => DS_NODE_NUM,
    EN_TLP_REQ_DIGEST => EN_TLP_REQ_DIGEST,
    PIPE              => PIPE,
    ENDPOINT          => DS_ENDPOINT,
    ENABLE_AUTO       => DS_ENABLE_AUTO
  )
  port map (
    -- Globals
    Clk         => Clk,
    nReset      => nReset,

    -- Testbench Transaction Interface
    TransRec    => DownstreamRec,

    -- PCIe Functional Interface
    PcieLinkOut => PcieDnLink.LinkOut(0 to PCIE_LINK_WIDTH-1),
    PcieLinkIn  => PcieDnLink.LinkIn (0 to PCIE_LINK_WIDTH-1)
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