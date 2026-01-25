--
--  File Name:         Pcie1EpAxi4Lite.vhd
--  Design Unit Name:  Pcie1EpAxi4Lite
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Simon Southwell email:  simon.southwell@gmail.com
--  Contributor(s):
--     Simon Southwell simon.southwell@gmail.com
--
--
--  Description:
--      VHDL wrapper for Altera Avalon based PCIe Component converted to
--      AXI4-Lite Master bus
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

library osvvm_axi4 ;
  context osvvm_axi4.Axi4LiteContext ;

use work.Pcie1EpAvPkg.all ;

entity Pcie1EpAxi4Lite is
port (
  RefClk                       : in    std_logic ;
  PipeClk                      : in    std_logic ;
  nReset                       : in    std_logic ;

  -- AXI4-Lite memory mapped master
  AxiBus                       : inout Axi4LiteRecType ;

  -- PIPE lane 0
  Pipe0                        : inout PipeRecType

) ;
end entity Pcie1EpAxi4Lite ;

architecture rtl of Pcie1EpAxi4Lite is

signal BAR0, BAR1              : AvMemMappedMasterRecType (
  Address (AxiBus.ReadAddress.Addr'length-1 downto 0),
  ReadData(AxiBus.ReadData.Data'length-1 downto 0),
  WriteData(AxiBus.WriteData.Data'length-1 downto 0),
  ByteEnable(AxiBus.WriteData.Data'length/8-1 downto 0)
) ;

signal DataPending             : std_logic := '0' ;
signal WaitReqRead             : std_logic ;
signal WaitReqWrite            : std_logic ;
signal AvWrite                 : std_logic ;
signal AvRead                  : std_logic ;

signal LtssmState              : std_logic_vector  (4 downto 0) ;
signal EidleInferSel           : std_logic_vector  (2 downto 0);


begin

  ------------------------------------------------------------
  -- Combinatorial logic
  ------------------------------------------------------------

  -- Combined Avalon access strobes
  AvWrite                      <= BAR0.Write or BAR1.Write ;
  AvRead                       <= BAR0.Read  or BAR1.Read ;

  -- Mux between the Avalon BAR0 and BAR1 master bus read addresses
  -- onto the AXI read address bus. BAR0 has priority.
  AxiBus.ReadAddress.Valid     <= AvRead and not DataPending;
  AxiBus.ReadAddress.Addr      <= BAR0.Address when BAR0.Read = '1' else BAR1.Address;
  Axibus.ReadAddress.Prot      <= (others => '0') ;

  -- Return AXI read data to appropriate Avalon interface
  BAR0.ReadData                <= AxiBus.ReadData.Data ;
  BAR0.ReadDataValid           <= AxiBus.ReadData.Valid and BAR0.Read ;
  BAR1.ReadData                <= AxiBus.ReadData.Data ;
  BAR0.ReadDataValid           <= AxiBus.ReadData.Valid and BAR1.Read ;
  AxiBus.ReadData.Ready        <= '1' ;

  -- Mux the Avalon BAR0 and BAR1 master busses  writes addresses onto
  -- the AXI write address bus. BAR0 has priority.
  AxiBus.WriteAddress.Valid    <= AvWrite and not DataPending;
  AxiBus.WriteAddress.Addr     <= BAR0.Address when BAR0.Write = '1' else BAR1.Address;
  Axibus.WriteAddress.Prot     <= (others => '0') ;

  -- Mux the Avalon BAR0 and BAR1 master write data onto the AXI write
  -- data bus. BAR0 has priority.
  AxiBus.WriteData.Valid       <= AvWrite ;
  AxiBus.WriteData.Data        <= BAR0.WriteData  when BAR0.Write = '1' else BAR1.WriteData ;
  AxiBus.WriteData.Strb        <= BAR0.ByteEnable when BAR0.Write = '1' else BAR1.ByteEnable ;

  -- Always accept the write response
  AxiBus.WriteResponse.Ready   <= '1' ;

  -- Wait on Avalon reads until the AXI read data was transferred
  WaitReqRead                  <= AvRead  and not (AxiBus.ReadData.Valid  and AxiBus.ReadData.Ready) ;

  -- Wait on Avalon writes until the AXI write data was transferred
  WaitReqWrite                 <= AvWrite and not (AxiBus.WriteData.Valid and AxiBus.WriteData.Ready) ;

  -- Drive the Avalon bus wait requests
  BAR0.WaitRequest             <= (BAR0.Read and WaitReqRead) or (BAR0.Write and WaitReqWrite);
  BAR1.WaitRequest             <= (BAR1.Read and WaitReqRead) or (BAR1.Write and WaitReqWrite);

  ------------------------------------------------------------
  -- Synchronous process to generate a data pending mask
  --
  PendingProc : process (RefClk)
  ------------------------------------------------------------
  begin
    if RefClk'event and RefClk = '1' then
      -- Set when address transferred and cleared when data transferred.
      -- Used to mask Avalon strobes driving AXI address valid after AXI
      -- address accepted
      DataPending      <= ((AxiBus.ReadAddress.Valid  and AxiBus.ReadAddress.Ready)  and not (AxiBus.ReadData.Valid  and AxiBus.ReadData.Ready)) or
                          ((AxiBus.WriteAddress.Valid and AxiBus.WriteAddress.Ready) and not (AxiBus.WriteData.Valid and AxiBus.WriteData.Ready));
    end if ;
  end process PendingProc ;

-- ------------------------------------------------------------
-- -- Instantiation of Avalon PCIe GEN1 x1 EP IP
-- --
-- pcie_i : Pcie1EpAvmm
-- ------------------------------------------------------------
-- port  map (
--   RefClk               => RefClk,
--   PipeClk              => PipeClk,
--   nReset               => nReset,
--
--   -- BAR0 Avalon memory mapped master
--   BAR0                 => BAR0,
--
--   -- BAR1 Avalon memory mapped master
--   BAR1                 => BAR1,
--
--   -- PIPE lane 0
--   Pipe0                => Pipe0
-- ) ;

  ------------------------------------------------------------
  -- Instantiation of Avalon PCIe GEN1 x1 EP IP
  --
  pcie_i : Pcie1EpAvmm
  ------------------------------------------------------------
  port  map (
    RefClk               => RefClk,
    PipeClk              => PipeClk,
    nReset               => nReset,

    -- BAR0 Avalon memory mapped master
    Bar0Address          => BAR0.Address,
    Bar0Read             => BAR0.Read,
    Bar0WaitRequest      => BAR0.WaitRequest,
    Bar0Write            => BAR0.Write,
    Bar0ReadDataValid    => BAR0.ReadDataValid,
    Bar0ReadData         => BAR0.ReadData,
    Bar0WriteData        => BAR0.WriteData,
    Bar0ByteEnable       => BAR0.ByteEnable,

    -- BAR1 Avalon memory mapped master
    Bar1Address          => BAR1.Address,
    Bar1Read             => BAR1.Read,
    Bar1WaitRequest      => BAR1.WaitRequest,
    Bar1Write            => BAR1.Write,
    Bar1ReadDataValid    => BAR1.ReadDataValid,
    Bar1ReadData         => BAR1.ReadData,
    Bar1WriteData        => BAR1.WriteData,
    Bar1ByteEnable       => BAR1.ByteEnable,

    -- PIPE lane 0
    TxData               => Pipe0.TxData,
    TxDataK              => Pipe0.TxDataK,

    TxDetectRx           => Pipe0.TxDetectRx,
    TxElecIdle           => Pipe0.TxElecIdle,
    TxCompliance         => Pipe0.TxCompliance,
    RxPolarity           => Pipe0.RxPolarity,
    PowerDown            => Pipe0.PowerDown,
    Rate                 => Pipe0.Rate,
    TxDemph              => Pipe0.TxDemph,
    TxMargin             => Pipe0.TxMargin,
    TxSwing              => Pipe0.TxSwing,

    RxData               => Pipe0.RxData,
    RxDataK              => Pipe0.RxDataK,
    RxValid              => Pipe0.RxValid,
    RxElecIdle           => Pipe0.RxElecIdle,
    RxStatus             => Pipe0.RxStatus,
    PhyStatus            => Pipe0.PhyStatus,

    LtssmState           => LtssmState,
    EidleInferSel        => EidleInferSel

  ) ;


end architecture rtl ;