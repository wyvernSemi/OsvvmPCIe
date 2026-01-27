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
  
  CoreClk                      : out   std_logic ;

  -- AXI4-Lite memory mapped master
  AxiBus                       : inout Axi4LiteRecType ;

  -- PIPE lane 0
  Pipe0                        : inout PipeRecType

) ;
end entity Pcie1EpAxi4Lite ;

architecture rtl of Pcie1EpAxi4Lite is

signal BAR0                    : AvMemMappedMasterRecType (
  Address   (31 downto 0),
  ReadData  (63 downto 0),
  WriteData (63 downto 0),
  ByteEnable( 7 downto 0),
  BurstCount( 6 downto 0)
) ;

signal DataPending             : std_logic := '0' ;
signal WaitReqRead             : std_logic ;
signal WaitReqWrite            : std_logic ;

signal LtssmState              : std_logic_vector  (4 downto 0) ;
signal EidleInferSel           : std_logic_vector  (2 downto 0);

signal LowWordAddress          : std_logic ;

begin

  ------------------------------------------------------------
  -- Combinatorial logic
  ------------------------------------------------------------
  
  BAR0.ByteEnable              <= (others => 'H') ;
  BAR0.WriteData               <= (others => 'L') ;
  
  -- Flag if addressing the lower 32-bit word
  LowWordAddress               <= not BAR0.Address(2);             

  AxiBus.ReadAddress.Valid     <= BAR0.Read and not DataPending;
  AxiBus.ReadAddress.Addr      <= BAR0.Address ;
  Axibus.ReadAddress.Prot      <= (others => '0') ;

  -- Return AXI read data to appropriate Avalon interface
  BAR0.ReadData                <= AxiBus.ReadData.Data & AxiBus.ReadData.Data ;
  BAR0.ReadDataValid           <= AxiBus.ReadData.Valid and BAR0.Read ;

  AxiBus.ReadData.Ready        <= '1' ;

  AxiBus.WriteAddress.Valid    <= BAR0.Write and not DataPending;
  AxiBus.WriteAddress.Addr     <= BAR0.Address ;
  Axibus.WriteAddress.Prot     <= (others => '0') ;


  AxiBus.WriteData.Valid       <= BAR0.Write ;
  AxiBus.WriteData.Data        <= BAR0.WriteData(31 downto 0) when LowWordAddress = '1' else  BAR0.WriteData(63 downto 32);
  AxiBus.WriteData.Strb        <= BAR0.ByteEnable(3 downto 0) when LowWordAddress = '1' else  BAR0.ByteEnable(7 downto 4);

  -- Always accept the write response
  AxiBus.WriteResponse.Ready   <= '1' ;

  -- Wait on Avalon reads until the AXI read data was transferred
  WaitReqRead                  <= BAR0.Read  and not (AxiBus.ReadData.Valid  and AxiBus.ReadData.Ready) ;

  -- Wait on Avalon writes until the AXI write data was transferred
  WaitReqWrite                 <= BAR0.Write and not (AxiBus.WriteData.Valid and AxiBus.WriteData.Ready) ;

  -- Drive the Avalon bus wait requests
  BAR0.WaitRequest             <= (BAR0.Read and WaitReqRead) or (BAR0.Write and WaitReqWrite) ;

  ------------------------------------------------------------
  -- Synchronous process to generate a data pending mask
  --
  PendingProc : process (CoreClk)
  ------------------------------------------------------------
  begin
    if CoreClk'event and CoreClk = '1' then
      -- Set when address transferred and cleared when data transferred.
      -- Used to mask Avalon strobes driving AXI address valid after AXI
      -- address accepted
      DataPending      <= ((DataPending or (AxiBus.ReadAddress.Valid  and AxiBus.ReadAddress.Ready))  and not (AxiBus.ReadData.Valid  and AxiBus.ReadData.Ready)) or
                          ((AxiBus.WriteAddress.Valid and AxiBus.WriteAddress.Ready) and not (AxiBus.WriteData.Valid and AxiBus.WriteData.Ready));
    end if ;
  end process PendingProc ;

  ------------------------------------------------------------
  -- Instantiation of Avalon PCIe GEN1 x1 EP IP
  --
  pcie_i : pcie1epavmm
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
    Bar0BurstCount       => BAR0.BurstCount,

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
    EidleInferSel        => EidleInferSel,
    coreclkout           => CoreClk

  ) ;


end architecture rtl ;