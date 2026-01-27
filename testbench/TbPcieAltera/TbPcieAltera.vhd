--
--  File Name:         TbPcieAutoEp.vhd
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

library osvvm_Axi4 ;
  context osvvm_Axi4.Axi4LiteContext ;

library osvvm_pcie ;
  context osvvm_pcie.PcieContext ;

use work.Pcie1EpAvPkg.all ;

entity TbPcieAltera is
end entity TbPcieAltera ;

architecture TestHarness of TbPcieAltera is

  constant tperiod_RClk        : time :=   8 ns ; -- 125MHz
  constant tperiod_PClk        : time :=   4 ns ; -- 250Hz  for GEN1
  constant tpd                 : time := 100 ps ;
                               
  constant RSET_CLK_COUNT      : integer := 50 ;
                               
  constant PCIE_ADDR_WIDTH     : integer := 32 ;
  constant PCIE_DATA_WIDTH     : integer := 32 ;
                               
  -- Common configurations     
  constant EN_TLP_REQ_DIGEST   : boolean := false ;
  constant PIPE                : boolean := true ;
  constant DISABLE_SCRAMBLING  : boolean := false ; 
  constant PCIE_LINK_WIDTH     : integer := 1 ; -- valid values: 1, 2, 4, 8 and 16
  constant PCIE_LANE_WIDTH     : integer := IfElse(PIPE, 9, 10) ; -- 9 when PIPE else 10
                               
  -- Upstream (RC) device configuration
  constant US_NODE_NUM         : integer := 62 ;
  constant US_ENDPOINT         : boolean := false ;
  constant US_ENABLE_AUTO      : boolean := false ;
                               
  signal Clk                   : std_logic := '1';
  signal RefClk                : std_logic := '1';
  signal CoreClk               : std_logic := '1';
  signal nReset                : std_logic := '0';
                               
  signal Count                 : integer := 0 ;

  signal PcieTransRec, AxiTransRec  : AddressBusRecType(
          Address      (PCIE_ADDR_WIDTH-1 downto 0),
          DataToModel  (PCIE_DATA_WIDTH-1 downto 0),
          DataFromModel(PCIE_DATA_WIDTH-1 downto 0)
        ) ;

--  -- PCIe Functional Interface
  signal   PcieDnLink, PcieUpLink : PcieRecType(
    LinkOut (0 to MAXLINKWIDTH-1)(PCIE_LANE_WIDTH-1 downto 0),
    LinkIn  (0 to MAXLINKWIDTH-1)(PCIE_LANE_WIDTH-1 downto 0)

  ) ;

  signal AxiBus              : Axi4LiteRecType(
    WriteAddress( Addr (PCIE_ADDR_WIDTH-1 downto 0) ),
    WriteData   ( Data (PCIE_DATA_WIDTH-1 downto 0),   Strb(PCIE_DATA_WIDTH/8-1 downto 0) ),
    ReadAddress ( Addr (PCIE_ADDR_WIDTH-1 downto 0) ),
    ReadData    ( Data (PCIE_DATA_WIDTH-1 downto 0) )
  ) ;

  signal Pipe0               : PipeRecType  ;

  component TestCtrl is
    port (
      -- Global Signal Interface
      Clk                 : In    std_logic ;
      nReset              : In    std_logic ;

      -- Transaction Interfaces
      UpstreamRec         : inout AddressBusRecType ;
      DownstreamRec       : inout AddressBusRecType
    ) ;
  end component TestCtrl ;

begin

  ------------------------------------------------------------
  -- create Clock
  ------------------------------------------------------------
  Osvvm.ClockResetPkg.CreateClock (
    Clk                => Clk,
    Period             => tperiod_PClk
  )  ;

  Osvvm.ClockResetPkg.CreateClock (
    Clk                => RefClk,
    Period             => tperiod_RClk
  )  ;

  ------------------------------------------------------------
  -- create nReset
  ------------------------------------------------------------
  Osvvm.ClockResetPkg.CreateReset (
    Reset              => nReset,
    ResetActive        => '0',
    Clk                => Clk,
    Period             => RSET_CLK_COUNT * tperiod_PClk,
    tpd                => tpd
  ) ;

  ------------------------------------------------------------
  Upstream_1 : PcieModel
  ------------------------------------------------------------
  generic map (
    NODE_NUM           => US_NODE_NUM,
    REQ_ID             => US_NODE_NUM,
    EN_TLP_REQ_DIGEST  => EN_TLP_REQ_DIGEST,
    PIPE               => PIPE,
    DISABLE_SCRAMBLING => DISABLE_SCRAMBLING,
    ENDPOINT           => US_ENDPOINT,
    ENABLE_AUTO        => US_ENABLE_AUTO
  )
  port map (
    -- Globals
    Clk                => Clk,
    nReset             => nReset,

    -- Testbench Transaction Interface
    TransRec           => PcieTransRec,

    -- PCIe Functional Interface
    PcieLinkOut        => PcieUpLink.LinkOut(0 to PCIE_LINK_WIDTH-1),
    PcieLinkIn         => PcieUpLink.LinkIn (0 to PCIE_LINK_WIDTH-1)

  ) ;

-- Connect the PIPE interfaces
PcieUpLink.LinkIn(0)  <= Pipe0.TxDataK & Pipe0.TxData ;
Pipe0.RxDataK         <= PcieUpLink.LinkOut(0)(PcieUpLink.LinkOut(0)'length-1) ;
Pipe0.RxData          <= PcieUpLink.LinkOut(0)(PcieUpLink.LinkOut(0)'length-2 downto 0) ;
Pipe0.RxValid         <= not Pipe0.RxElecIdle ;

  ------------------------------------------------------------
  Downstream_1 : Pcie1EpAxi4Lite
  ------------------------------------------------------------

  port map (
    -- Globals
    RefClk      => RefClk,
    PipeClk     => Clk,
    CoreClk     => CoreClk,
    nReset      => nReset,

    AxiBus      => AxiBus,

    Pipe0       => Pipe0
  ) ;

  ------------------------------------------------------------
  AxiSub_1 : Axi4LiteSubordinate
  ------------------------------------------------------------

  port map (
    -- Globals
    Clk         => CoreClk,
    nReset      => nReset,

    -- AXI Manager Functional Interface
    AxiBus      => AxiBus,

    -- Testbench Transaction Interface
    TransRec    => AxiTransRec
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
    UpstreamRec    => PcieTransRec,
    DownstreamRec  => AxiTransRec
  ) ;

  ------------------------------------------------------------
  pCountGeneration : process(Clk)
  ------------------------------------------------------------
  begin
     if Clk'event and Clk = '1' then
       Count <= Count + 1 ;
     end if ;
  end process pCountGeneration ;

  ------------------------------------------------------------
  pPcieResetSequence : process (Clk, nReset)
  ------------------------------------------------------------
  variable TxDetectTime : integer := 0 ;
  begin

    if nReset = '0' then

      Pipe0.RxElecIdle      <= '1' ;
      Pipe0.RxStatus        <= "100" ;
      Pipe0.PhyStatus       <= '1' ;

    elsif Clk'event and Clk = '1' then

      if Count = 54 or Count = 573 or Count = 574 then
        Pipe0.PhyStatus <= not Pipe0.PhyStatus ;
      end if ;

      if TxDetectTime = 0 and Pipe0.TxDetectRx = '1' then
        TxDetectTime := Count ;
      end if;

      if (Count - TxDetectTime) = 2 or (Count - TxDetectTime) =  6 then
        Pipe0.RxStatus   <= "000" ;
      elsif (Count - TxDetectTime) = 5 then
        Pipe0.RxStatus   <= "011" ;
      elsif (Count - TxDetectTime) = 8 then
        Pipe0.RxStatus   <= "100" ;
      elsif Count = 600 then
        Pipe0.RxStatus   <= "000" ;
        Pipe0.RxElecIdle <= '0' ;
      end if;
    end if ;

  end process pPcieResetSequence ;

end architecture TestHarness ;