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
  PipeTx0                      : out PipeTxRecType ;
  PipeRx0                      : in  PipeRxRecType

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
signal EidleInferSel           : std_logic_vector  (2 downto 0) ;

signal LowWordAddress          : boolean ;
signal WordAddrAdj             : std_logic_vector  (31 downto 0) ;
signal ReadDataMask            : std_logic_vector  (31 downto 0)  := (others => '1') ;

begin

  ------------------------------------------------------------
  -- Combinatorial logic
  ------------------------------------------------------------
  
  BAR0.ByteEnable              <= (others => 'L') ;
  BAR0.WriteData               <= (others => 'L') ;
  
  -- Flag if addressing the lower 32-bit word
  LowWordAddress               <= BAR0.ByteEnable(3 downto 0) /= "0000";      
  WordAddrAdj                  <= 32x"00000000" when BAR0.ByteEnable(0) else 
                                  32x"00000001" when BAR0.ByteEnable(1) else
                                  32x"00000002" when BAR0.ByteEnable(2) else
                                  32x"00000003" when BAR0.ByteEnable(3) else
                                  32x"00000004" when BAR0.ByteEnable(4) else
                                  32x"00000005" when BAR0.ByteEnable(5) else
                                  32x"00000006" when BAR0.ByteEnable(6) else
                                  32x"00000007" ;

  AxiBus.ReadAddress.Valid     <= BAR0.Read ;
  AxiBus.ReadAddress.Addr      <= BAR0.Address or WordAddrAdj ;
  Axibus.ReadAddress.Prot      <= (others => '0') ;

  -- Return AXI read data to appropriate Avalon interface
  BAR0.ReadData                <= (AxiBus.ReadData.Data and ReadDataMask) & (AxiBus.ReadData.Data and ReadDataMask) ;
  BAR0.ReadDataValid           <= AxiBus.ReadData.Valid ;

  -- Avalon bus can always accept data for a read it has issued
  AxiBus.ReadData.Ready        <= '1' ;

  AxiBus.WriteAddress.Valid    <= BAR0.Write and not DataPending ;
  AxiBus.WriteAddress.Addr     <= BAR0.Address or WordAddrAdj ;
  Axibus.WriteAddress.Prot     <= (others => '0') ;

  AxiBus.WriteData.Valid       <= BAR0.Write ;
  AxiBus.WriteData.Data        <= BAR0.WriteData(31 downto 0) when LowWordAddress else  BAR0.WriteData(63 downto 32) ;
  AxiBus.WriteData.Strb        <= BAR0.ByteEnable(3 downto 0) when LowWordAddress else  BAR0.ByteEnable(7 downto 4) ;

  -- Always accept the write response
  AxiBus.WriteResponse.Ready   <= '1' ;

  -- Wait on Avalon reads until the AXI read address was transferred
  WaitReqRead                  <= BAR0.Read  and not AxiBus.ReadAddress.Ready;

  -- Wait on Avalon writes until the AXI write address and data was transferred
  WaitReqWrite                 <= BAR0.Write and ((AxiBus.WriteAddress.Valid and not AxiBus.WriteAddress.Ready) or (AxiBus.WriteData.Valid and not AxiBus.WriteData.Ready)) ;

  -- Drive the Avalon bus wait requests
  BAR0.WaitRequest             <= (BAR0.Read and WaitReqRead) or (BAR0.Write and WaitReqWrite) ;

  ------------------------------------------------------------
  -- Synchronous process to generate a data pending mask
  --
  PendingProc : process (CoreClk)
  ------------------------------------------------------------
  begin
    if CoreClk'event and CoreClk = '1' then
      DataPending      <= ((AxiBus.WriteAddress.Valid and AxiBus.WriteAddress.Ready) and not (AxiBus.WriteData.Valid and AxiBus.WriteData.Ready)) ;
      
      -- Data returned from AXI4-Lite VC is X for non addressed bytes, so create
      -- a mask based on AXI read address low bits
      if AxiBus.ReadAddress.Valid and AxiBus.ReadAddress.Ready then
        ReadDataMask   <= 32x"ffffffff" when AxiBus.ReadAddress.Addr(1 downto 0) = 2x"0" else
                          32x"ffffff00" when AxiBus.ReadAddress.Addr(1 downto 0) = 2x"1" else
                          32x"ffff0000" when AxiBus.ReadAddress.Addr(1 downto 0) = 2x"2" else
                          32x"ff000000" ;
      end if ;        
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
    TxData               => PipeTx0.TxData,
    TxDataK              => PipeTx0.TxDataK,

    TxDetectRx           => PipeTx0.TxDetectRx,
    TxElecIdle           => PipeTx0.TxElecIdle,
    TxCompliance         => PipeTx0.TxCompliance,
    RxPolarity           => PipeTx0.RxPolarity,
    PowerDown            => PipeTx0.PowerDown,
    Rate                 => PipeTx0.Rate,
    TxDemph              => PipeTx0.TxDemph,
    TxMargin             => PipeTx0.TxMargin,
    TxSwing              => PipeTx0.TxSwing,

    RxData               => PipeRx0.RxData,
    RxDataK              => PipeRx0.RxDataK,
    RxValid              => PipeRx0.RxValid,
    RxElecIdle           => PipeRx0.RxElecIdle,
    RxStatus             => PipeRx0.RxStatus,
    PhyStatus            => PipeRx0.PhyStatus,

    LtssmState           => LtssmState,
    EidleInferSel        => EidleInferSel,
    coreclkout           => CoreClk

  ) ;


end architecture rtl ;