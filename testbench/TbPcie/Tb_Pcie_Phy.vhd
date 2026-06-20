--
--  File Name:         Tb_Pcie_phy.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Simon Southwell  email:  simon.southwell@gmail.com
--  Contributor(s):
--     Simon Southwell simon.southwell@gmail.com
--
--
--  Description:
--      Test PHY TS/OS traffic generation and receiving events
--
--  Revision History:
--    Date      Version    Description
--    06/2026   ????.??    Initial revision
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

architecture CoSim_Phy of TestCtrl is

  type rd_req_t is record
    addr          : std_logic_vector(31 downto 0);
    rid           : integer ;
    word_len      : integer ;
    tag           : integer ;
    word_offset   : integer ;
    padding       : integer ;
  end record rd_req_t ;

  type rd_req_array_t is array (natural range <>) of rd_req_t ;

  signal   TestDone        : integer_barrier := 1 ;
  signal   TestSync        : integer_barrier := 1 ;
  signal   Initialised     : boolean         := FALSE ;

  -- Shared variable to sync between test processes
  --shared variable SyncTest : PcieTestSyncType ;

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin

    SetTestName("Tb_Pcie_Phy");

    -- Initialization of test
    SetLogEnable(PASSED, TRUE) ;  -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    --PcieSync(SyncTest) ; -- Initialise shared variable to a sync'd state

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
  --   Generate transactions
  ------------------------------------------------------------
  UpstreamProc : process
    variable OpRV           : RandomPType ;
    variable WaitForClockRV : RandomPType ;
    variable TsParams       : PcieTsRecType ;
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

    SetModelOptions(UpstreamRec, CONFIG_DISABLE_SKIPS, 0);

    -- Send ten TS1 training sequences
    TsParams.Id             := TS1_ID ;
    TsParams.Linknum        := TS_PAD ;
    TsParams.LaneNum        := TS_PAD ;
    TsParams.Nfts           := 255 ;
    TsParams.Datarate       := PCIE_GEN1 ;
    TsParams.Control        := 16#0# ;
    
    PciePhyTs(UpstreamRec, TsParams, 10);

    WaitForBarrier(TestSync);

    -- Send nine TS2 training sequences
    TsParams.Id             := TS2_ID ;
    TsParams.Linknum        := 0 ;
    TsParams.LaneNum        := 0 ;
    TsParams.Nfts           := 255 ;
    TsParams.Datarate       := PCIE_GEN1 ;
    TsParams.Control        := 16#0# ;

    PciePhyTs(UpstreamRec, TsParams, 9);

    WaitForBarrier(TestSync);

    PciePhyOs(UpstreamRec, OS_FTS, 5) ;

    WaitForBarrier(TestSync);

    PciePhyOs(UpstreamRec, OS_SKP, 4) ;

    WaitForBarrier(TestSync);

    PciePhyOs(UpstreamRec, OS_IDL, 3) ;

    WaitForBarrier(TestSync);

    PciePhyOs(UpstreamRec, OS_EIE, 2) ;

    WaitForBarrier(TestSync);

    -- =================================================================
    -- ==========================  E  N  D  ============================
    -- =================================================================

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(UpstreamRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;

  end process UpstreamProc ;

   ------------------------------------------------------------
  -- DownstreamProc
  --   Receiving transactions
  ------------------------------------------------------------
  DownstreamProc : process
    variable OpRV              : RandomPType ;
    variable WaitForClockRV    : RandomPType ;
    variable NumLanes          : integer ;
    variable EventCountsVec    : PcieEventCountsType ;
    variable TsValues          : PcieTsRecType ;
  begin

    -- Initialize Randomization Objects
    OpRV.InitSeed(OpRv'instance_name) ;
    WaitForClockRV.InitSeed(WaitForClockRV'instance_name) ;

    -- Find exit of reset
    wait until nReset = '1' ;
    WaitForClock(DownstreamRec, 2) ;

    -- =================================================================
    -- =====================  T  E  S  T  S  ===========================
    -- =================================================================

    -- Wait until TS1 sent
    --PcieWaitSync(DownstreamRec, SyncTest) ;
    WaitForBarrier(TestSync);

    -- Check event counts for each active lane
    PciePhyGetOsTsEventCounts(DownstreamRec, TS1_ID, NumLanes, EventCountsVec) ;
    AffirmIfEqual(NumLanes, 2, "Number of lanes");
    for i in 0 to NumLanes-1 loop
      AffirmIfEqual(EventCountsVec(i), 10, "TS1 event count for lane " & integer'image(i)) ;
    end loop ;

    -- Reset TS1 event counts  and check cleared
    PciePhyResetOsTsEventCounts(DownstreamRec, TS1_ID) ;
    PciePhyGetOsTsEventCounts(DownstreamRec, TS1_ID, NumLanes, EventCountsVec) ;
    for i in 0 to NumLanes-1 loop
      AffirmIfEqual(EventCountsVec(i), 0, "TS1 post-reset event count for lane " & integer'image(i)) ;
    end loop ;

    -- Fetch last TS for lane
    for i in 0 to NumLanes-1 loop
      PciePhyGetTs(DownstreamRec, i, TsValues) ;
      AffirmIfEqual(TsValues.Id, TS1_ID, "TS ID for lane " & integer'image(i)) ;
      AffirmIfEqual(TsValues.Linknum, TS_PAD, "TS Link Number for lane " & integer'image(i)) ;
      AffirmIfEqual(TsValues.Lanenum, TS_PAD, "TS Lane Number for lane " & integer'image(i)) ;
      AffirmIfEqual(TsValues.Nfts, 255, "TS NFTS  for lane " & integer'image(i)) ;
      AffirmIfEqual(TsValues.Datarate, 16#02#, "TS GEN for lane " & integer'image(i)) ;
      AffirmIfEqual(TsValues.Control, 16#00#, "TS CTL for lane " & integer'image(i)) ;
    end loop ;

    -- Wait until TS2 sent
    --PcieWaitSync(DownstreamRec, SyncTest) ;
    WaitForBarrier(TestSync);

    -- Check event counts for each active lane
    PciePhyGetOsTsEventCounts(DownstreamRec, TS2_ID, NumLanes, EventCountsVec) ;
    AffirmIfEqual(NumLanes, 2, "Number of lanes");
    for i in 0 to NumLanes-1 loop
      AffirmIfEqual(EventCountsVec(i), 9, "TS2 event count for lane " & integer'image(i)) ;
    end loop ;

    -- Reset TS2 event counts and check cleared
    PciePhyResetOsTsEventCounts(DownstreamRec, TS2_ID) ;
    PciePhyGetOsTsEventCounts(DownstreamRec, TS2_ID, NumLanes, EventCountsVec) ;
    for i in 0 to NumLanes-1 loop
      AffirmIfEqual(EventCountsVec(i), 0, "TS2 post-reset event count for lane " & integer'image(i)) ;
    end loop ;

    -- Fetch last TS for lane
    for i in 0 to NumLanes-1 loop
      PciePhyGetTs(DownstreamRec, i, TsValues) ;
      AffirmIfEqual(TsValues.Id, TS2_ID, "TS ID for lane " & integer'image(i)) ;
      AffirmIfEqual(TsValues.Linknum, 0, "TS Link Number for lane " & integer'image(i)) ;
      AffirmIfEqual(TsValues.Lanenum, i, "TS Lane Number for lane " & integer'image(i)) ;
      AffirmIfEqual(TsValues.Nfts, 255, "TS NFTS  for lane " & integer'image(i)) ;
      AffirmIfEqual(TsValues.Datarate, 16#02#, "TS GEN for lane " & integer'image(i)) ;
      AffirmIfEqual(TsValues.Control, 16#00#, "TS CTL for lane " & integer'image(i)) ;
    end loop ;

    -- Wait for OS sent
    --PcieWaitSync(DownstreamRec, SyncTest) ;
    WaitForBarrier(TestSync);

    -- Check event counts for each active lane
    PciePhyGetOsTsEventCounts(DownstreamRec, OS_FTS, NumLanes, EventCountsVec) ;
    for i in 0 to NumLanes-1 loop
      AffirmIfEqual(EventCountsVec(i), 5, "FTS event count for lane " & integer'image(i)) ;
    end loop ;

    -- Reset NFTS event counts and check cleared
    PciePhyResetOsTsEventCounts(DownstreamRec, OS_FTS) ;
    PciePhyGetOsTsEventCounts(DownstreamRec, OS_FTS, NumLanes, EventCountsVec) ;
    for i in 0 to NumLanes-1 loop
      AffirmIfEqual(EventCountsVec(i), 0, "FTS post-reset event count for lane " & integer'image(i)) ;
    end loop ;

    -- Wait for OS sent
    --PcieWaitSync(DownstreamRec, SyncTest) ;
    WaitForBarrier(TestSync);

    -- Check event counts for each active lane
    PciePhyGetOsTsEventCounts(DownstreamRec, OS_SKP, NumLanes, EventCountsVec) ;
    for i in 0 to NumLanes-1 loop
      AffirmIfEqual(EventCountsVec(i), 4, "SKP event count for lane " & integer'image(i)) ;
    end loop ;

    -- Reset SKP event counts  and check cleared
    PciePhyResetOsTsEventCounts(DownstreamRec, OS_SKP) ;
    PciePhyGetOsTsEventCounts(DownstreamRec, OS_SKP, NumLanes, EventCountsVec) ;
    for i in 0 to NumLanes-1 loop
      AffirmIfEqual(EventCountsVec(i), 0, "SKP post-reset event count for lane " & integer'image(i)) ;
    end loop ;

    -- Wait for OS sent
    --PcieWaitSync(DownstreamRec, SyncTest) ;
    WaitForBarrier(TestSync);

    -- Check event counts for each active lane
    PciePhyGetOsTsEventCounts(DownstreamRec, OS_IDL, NumLanes, EventCountsVec) ;
    for i in 0 to NumLanes-1 loop
      AffirmIfEqual(EventCountsVec(i), 3, "IDL event count for lane " & integer'image(i)) ;
    end loop ;

    -- Reset IDL event counts and check cleared
    PciePhyResetOsTsEventCounts(DownstreamRec, OS_IDL) ;
    PciePhyGetOsTsEventCounts(DownstreamRec, OS_IDL, NumLanes, EventCountsVec) ;
    for i in 0 to NumLanes-1 loop
      AffirmIfEqual(EventCountsVec(i), 0, "IDL post-reset event count for lane " & integer'image(i)) ;
    end loop ;

    -- Wait for OS sent
    --PcieWaitSync(DownstreamRec, SyncTest) ;
    WaitForBarrier(TestSync);

    -- Check event counts for each active lane
    PciePhyGetOsTsEventCounts(DownstreamRec, OS_EIE, NumLanes, EventCountsVec) ;
    for i in 0 to NumLanes-1 loop
      AffirmIfEqual(EventCountsVec(i), 2, "EIE event count for lane " & integer'image(i)) ;
    end loop ;

    -- Reset EIE event counts and check cleared
    PciePhyResetOsTsEventCounts(DownstreamRec, OS_EIE) ;
    PciePhyGetOsTsEventCounts(DownstreamRec, OS_EIE, NumLanes, EventCountsVec) ;
    for i in 0 to NumLanes-1 loop
      AffirmIfEqual(EventCountsVec(i), 0, "EIE post-reset event count for lane " & integer'image(i)) ;
    end loop ;

    -- =================================================================
    -- ==========================  E  N  D  ============================
    -- =================================================================

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(DownstreamRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;

  end process DownstreamProc ;

end CoSim_Phy ;

Configuration Tb_PCIe_Phy of TbPcie is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(CoSim_Phy) ;
    end for ;
  end for ;
end Tb_PCIe_Phy ;