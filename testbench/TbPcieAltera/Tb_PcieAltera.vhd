--
--  File Name:         Tb_PcieAltera.vhd
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
--    01/2026   2026.01    Initial revision
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2026 by [OSVVM Authors](../../AUTHORS.md).
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

architecture CoSimAltera of TestCtrl is

  constant Node           : integer         := 0 ;

  signal   TestDone       : integer_barrier := 1 ;
  signal   Initialised    : boolean         := FALSE;

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin

    SetTestName("CoSim_PcieAltera");

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
    WaitForBarrier(TestDone, 100 us) ;

    TranscriptClose ;
    -- Printing differs in different simulators due to differences in process order execution
    -- AffirmIfTranscriptsMatch(PATH_TO_VALIDATED_RESULTS) ;

    EndOfTestReports(TimeOut => (now >= 1 ms)) ;
    std.env.stop ;
    wait ;
  end process ControlProc ;

   ------------------------------------------------------------
  -- PcieUpProc
  --   Generate transactions
  ------------------------------------------------------------
  PcieUpProc : process
    variable OpRV           : RandomPType ;
    variable WaitForClockRV : RandomPType ;
    variable Data           : std_logic_vector(31 downto 0) ;
    variable RemainLen      : integer ;
    variable PcieStatus     : PcieStatusRecType ;
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
    PcieInitLink(UpstreamRec) ;

    -- Run DLL initialisation
    PcieInitDll(UpstreamRec) ;
    
    WaitForClock(UpstreamRec, 150) ;

    -- ***** configuration enumeration *****

    --                 TransRec    Offset    CID      Data         Status      Tag
    PcieCfgSpaceWrite(UpstreamRec, X"0010",  X"02_0_0", X"ffffffff", PcieStatus, 128) ; -- Set the tag

    AffirmIfEqual(PcieStatus.Packet, PKT_STATUS_GOOD, "Config Space Write Error Status #1: ") ;
    AffirmIfEqual(PcieStatus.Completion, CPL_SUCCESS, "Config Space Write Completion Status #1: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    PcieCfgSpaceRead(UpstreamRec, X"0010", X"02_0_0", Data(31 downto 0), PcieStatus) ;

    AffirmIfEqual(PcieStatus.Packet, PKT_STATUS_GOOD, "Config Space Read Error Status #2: ") ;
    AffirmIfEqual(PcieStatus.Completion, CPL_SUCCESS, "Config Space Read Completion Status #2: ") ;
    AffirmIfEqual(Data(31 downto 0), X"fffff000", "Config Space Read Completion #2: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- Set BAR0 to be at 0x00010000, with bus =2, device = 0, func = 0
    PcieCfgSpaceWrite(UpstreamRec, X"0010", X"02_0_0", X"0001_0000", PcieStatus) ;
    AffirmIfEqual(PcieStatus.Packet, PKT_STATUS_GOOD, "Config Space Read Error Status #3: ") ;
    AffirmIfEqual(PcieStatus.Completion, CPL_SUCCESS, "Config Space Write Completion Status #3: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;
    
    PcieCfgSpaceWrite(UpstreamRec, X"0004",  X"02_0_0", X"06", PcieStatus) ;

    -- AffirmIfEqual(PcieStatus.Packet, PKT_STATUS_GOOD, "Config Space Write Error Status #4: ") ;
    -- AffirmIfEqual(PcieStatus.Completion, CPL_SUCCESS, "Config Space Write Completion Status #4: ") ;
    -- WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- ***** memory writes and reads *****

    -- Do some memory reads and writes
    PcieMemWrite(UpstreamRec, X"00010080", X"900dc0de") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- PcieMemWrite(UpstreamRec, X"00010106", X"cafe");
    -- WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    PcieMemRead(UpstreamRec, X"00010080", Data(31 downto 0), PcieStatus) ;

    AffirmIfEqual(PcieStatus.Packet, PKT_STATUS_GOOD, "Read Error Status #1: ") ;
    AffirmIfEqual(PcieStatus.Completion, CPL_SUCCESS, "Read Completion Status #1: ") ;
    AffirmIfEqual(Data(31 downto 0), X"900dc0de", "Read data #1: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- PcieMemRead(UpstreamRec,  X"00010106", Data(15 downto 0), PcieStatus) ;
    -- 
    -- AffirmIfEqual(PcieStatus.Packet, PKT_STATUS_GOOD, "Read Error Status #2: ") ;
    -- AffirmIfEqual(PcieStatus.Completion, CPL_SUCCESS, "Read Completion Status #2: ") ;
    -- AffirmIfEqual(Data(15 downto 0), X"cafe", "Read data #2: ") ;
    -- WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- =================================================================
    -- ==========================  E  N  D  ============================
    -- =================================================================

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(UpstreamRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;

  end process PcieUpProc ;


   ------------------------------------------------------------
  -- AxiSubProc
  --   Receiving transactions
  ------------------------------------------------------------
  AxiSubProc : process
  
    variable Addr : std_logic_vector(31 downto 0) ;
    variable Data : std_logic_vector(31 downto 0) ; 

  begin

    -- Find exit of reset
    wait until nReset = '1' ;
    WaitForClock(DownstreamRec, 2) ;

    -- =================================================================
    -- =====================  T  E  S  T  S  ===========================
    -- =================================================================

    GetWrite(DownstreamRec, Addr, Data) ;
    AffirmIfEqual(Addr, X"00000080", "AXI4-Lite Subordinate Write Addr: ") ;
    AffirmIfEqual(Data, X"900dc0de", "Subordinate Write Data: ") ;
    
    -- GetWrite(DownstreamRec, Addr, Data(15 downto 0)) ;
    -- AffirmIfEqual(Addr, X"00000106", "AXI4-Lite Subordinate Write Addr: ") ;
    -- AffirmIfEqual(Data(15 downto 0), X"cafe", "Subordinate Write Data: ") ;
    
    SendRead(DownstreamRec, Addr, X"900dc0de") ; 
    AffirmIfEqual(Addr, X"00000080", "AXI4-Lite Subordinate Read Addr: ") ;
    
    -- SendRead(DownstreamRec, Addr, X"cafe") ; 
    -- AffirmIfEqual(Addr, X"00010106", "AXI4-Lite Subordinate Read Addr: ") ;

    -- =================================================================
    -- =======================  E  N  D  ===============================
    -- ================================================================= 

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(DownstreamRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;

  end process AxiSubProc ;

end CoSimAltera ;

Configuration Tb_PCIeAltera of TbPcieAltera is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(CoSimAltera) ;
    end for ;
  end for ;
end Tb_PCIeAltera ;
