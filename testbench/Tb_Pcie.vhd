--
--  File Name:         Tb_Pcie.vhd
--  Design Unit Name:  Architecture of TestCtrl
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
--  Revision History:
--    Date      Version    Description
--    10/2025   ????.??    Initial revision
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

architecture CoSim of TestCtrl is

  constant Node           : integer         := 0 ;

  signal   TestDone       : integer_barrier := 1 ;
  signal   TestActive     : boolean         := TRUE ;
  signal   OperationCount : integer         := 0 ;
  signal   Initialised    : boolean         := FALSE;

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin

    SetTestName("CoSim_pcie");

    -- Initialization of test
    SetLogEnable(PASSED, TRUE) ;  -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen ;
    SetTranscriptMirror(TRUE) ;

    -- Wait for Design Reset
    wait until nReset = '1' ;
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 1 ms) ;

    TranscriptClose ;
    -- Printing differs in different simulators due to differences in process order execution
    -- AffirmIfTranscriptsMatch(PATH_TO_VALIDATED_RESULTS) ;

    EndOfTestReports(TimeOut => (now >= 1 ms)) ;
    std.env.stop ;
    wait ;
  end process ControlProc ;

   ------------------------------------------------------------
  -- UpstreamProc
  --   Generate transactions for P
  ------------------------------------------------------------
  UpstreamProc : process
    variable OpRV           : RandomPType ;
    variable WaitForClockRV : RandomPType ;
    variable Data           : std_logic_vector(31 downto 0) ;
    variable CmplStatus     : integer ;
    variable CmplTag        : integer ;
    variable RemainLen      : integer ;
  begin
    -- Initialize Randomization Objects
    OpRV.InitSeed(OpRv'instance_name) ;
    WaitForClockRV.InitSeed(WaitForClockRV'instance_name) ;

    -- Find exit of reset
    wait until nReset = '1' ;
    WaitForClock(UpstreamRec, 2) ;

    -- =================================================================
    -- =====================  T  E  S  T  S  ===========================
    -- =================================================================

    -- Run PHY initialisation
    SetModelOptions(UpstreamRec, INITPHY, NULLOPTVALUE) ;

    -- Run DLL initialisation
    SetModelOptions(UpstreamRec, INITDLL, NULLOPTVALUE) ;

    -- ***** memory writes and reads *****

    -- Do some memory reads and writes
    PcieMemWrite(UpstreamRec, X"00000080", X"900dc0de") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    PcieMemWrite(UpstreamRec, X"00000106", X"cafe");
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    PcieMemRead(UpstreamRec, X"00000080", Data(31 downto 0), CmplStatus) ;

    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Read Status #1: ") ;
    AffirmIfEqual(Data(31 downto 0), X"900dc0de", "Read data #1: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    PcieMemRead(UpstreamRec,  X"00000106", Data(15 downto 0), CmplStatus) ;

    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Read Status #2: ") ;
    AffirmIfEqual(Data(15 downto 0), X"cafe", "Read data #2: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- ***** configuration writes and reads *****

    PcieCfgSpaceWrite(UpstreamRec, X"00000010", X"ffffffff", CmplStatus, 128) ; -- Set the tag

    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config space write status #1: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    PcieCfgSpaceWrite(UpstreamRec, X"00000014", X"ffffffff", CmplStatus) ;

    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config space write status #2: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    PcieCfgSpaceRead(UpstreamRec, X"00000010", Data(31 downto 0), CmplStatus) ;
    AffirmIfEqual(Data(31 downto 0), X"fffff008", "Read data #3: ") ;
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config space read status #3: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    PcieCfgSpaceRead(UpstreamRec, X"00000014", Data(31 downto 0), CmplStatus) ;
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config space read status #3: ") ;
    AffirmIfEqual(Data(31 downto 0), X"fffffc08", "Read data #4: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- Set BAR0 to be at 0x00010000, with bus =2, device = 0, func = 0
    PcieCfgSpaceWrite(UpstreamRec, X"02_0_0_0010", X"0001_0000", CmplStatus) ;
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config space write status #3: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- ***** I/O writes and reads *****

    -- Set to transmit I/O accesses
    SetModelOptions(UpstreamRec, SETTRANSMODE, IO_TRANS) ;

    PcieIoWrite(UpstreamRec, X"12345678", X"87654321", CmplStatus) ;
    AffirmIfEqual(CmplStatus, CPL_UNSUPPORTED, "I/O Write Status #1: ") ;
    PcieIoRead(UpstreamRec,  X"12345678", Data(31 downto 0), CmplStatus) ;
    AffirmIfEqual(CmplStatus, CPL_UNSUPPORTED, "I/O Read Status #1: ") ;

    -- ***** messages *****

    --  Error message (no payload)
    PcieMessageWrite(UpstreamRec, MSG_ERR_NON_FATAL) ;

    -- Set power limit messages (has payload)
    PcieMessageWrite(UpstreamRec, MSG_SET_PWR_LIMIT, X"20251015") ;

    -- ***** completions *****

    -- Set to transmit completions
    PcieCompletion(UpstreamRec, X"63", X"0badf00d", X"003e", X"0123", 1) ;

    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- ***** burst writes and reads *****

    -- Write 126 bytes to 0x00010201
    for i in 0 to 125 loop
      Push(UpstreamRec.WriteBurstFifo, to_slv(i, 8)) ;
    end loop ;
    PcieMemWrite(UpstreamRec, X"0001_0201", 126) ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- Read back bytes from 0x00010201
    PcieMemRead(UpstreamRec, X"0001_0201", 126, CmplStatus) ;
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Burst read status #1: ") ;

    for i in 0 to 125 loop
      Pop(UpstreamRec.ReadBurstFifo, Data(7 downto 0)) ;
      AffirmIfEqual(Data(7 downto 0), to_slv(i, 8), "Read burst data #1: ") ;
    end loop ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- ***** burst completion *****

    -- Set to transmit completions

    -- complete 47 bytes with low addr = 0x32
    for i in 0 to 46 loop
      Push(UpstreamRec.WriteBurstFifo, to_slv(i + 16, 8)) ;
    end loop ;
    PcieCompletion(UpstreamRec, X"32", 47, X"003e", X"0123", 2) ;


    -- ***** read address *****
    PcieMemWrite(UpstreamRec, X"00010080", X"900dc0de") ;
    PcieMemWrite(UpstreamRec, X"00010106", X"cafe");

    PcieMemReadAddress(UpstreamRec, X"00010080", 4, 16#a0#) ;
    PcieMemReadAddress(UpstreamRec, X"00010106", 2, 16#a1#) ;

    WaitForClock(UpstreamRec, 50);

    PcieMemReadData(UpstreamRec, Data(31 downto 0), CmplStatus, CmplTag);
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Read Status #3: ") ;
    AffirmIfEqual(CmplTag, 16#a0#, "Read tag #3: ") ;
    AffirmIfEqual(Data(31 downto 0), X"900dc0de", "Read data #3: ") ;

    PcieMemReadData(UpstreamRec, Data(15 downto 0), CmplStatus, CmplTag);
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Read Status #4: ") ;
    AffirmIfEqual(CmplTag, 16#a1#, "Read tag #4: ") ;
    AffirmIfEqual(Data(15 downto 0), X"cafe", "Read data #4: ") ;
    
    -- ***** part completions *****
    -- Transfer 47 bytes in two competions
    RemainLen := 47 ;
    
    -- complete 22 bytes (of 47) with low addr = 0x32
    for i in 0 to 21 loop
      Push(UpstreamRec.WriteBurstFifo, to_slv(i + 32, 8)) ;
    end loop ;
    PciePartCompletion(UpstreamRec, X"32", 22, X"003e", X"0123", std_logic_vector(to_unsigned(RemainLen, 12)), 3) ;
    RemainLen := RemainLen - 22 ;
    
    -- complete remaining 25 bytes with low addr = 0x48
    for i in 0 to 24 loop
      Push(UpstreamRec.WriteBurstFifo, to_slv(i + 54, 8)) ;
    end loop ;
    PciePartCompletion(UpstreamRec, X"48", 25, X"003e", X"0123", std_logic_vector(to_unsigned(RemainLen, 12)), 4) ;

    -- =================================================================
    -- ==========================  E  N  D  ============================
    -- =================================================================

    TestActive <= FALSE ;

    -- Allow Downstream device to catch up before signaling OperationCount (needed when WRITE_OP is last)
    WaitForClock(UpstreamRec, 2) ;
    Increment(OperationCount) ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(UpstreamRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;

  end process UpstreamProc ;
end CoSim ;

Configuration Tb_PCIe of TbPcie is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(CoSim) ;
    end for ;
  end for ;
end Tb_PCIe ;