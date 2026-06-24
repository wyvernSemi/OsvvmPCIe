--
--  File Name:         Tb_Pcie_Dll.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Simon Southwell  email:  simon.southwell@gmail.com
--  Contributor(s):
--     Simon Southwell simon.southwell@gmail.com
--
--
--  Description:
--      Test DLLP transaction handling
--
--  Revision History:
--    Date      Version    Description
--    06/2026   2026.07    Initial revision
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

architecture CoSim_Dll of TestCtrl is


  signal   TestDone        : integer_barrier := 1 ;
  signal   Initialised     : boolean         := FALSE ;

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin

    SetTestName("Tb_Pcie_Dll");

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
  --   Generate transactions
  ------------------------------------------------------------
  UpstreamProc : process
    variable OpRV           : RandomPType ;
    variable WaitForClockRV : RandomPType ;
    variable FcType            : integer ;
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

    -- Send an ACK DLLP with sequence number 22
    PcieDllSendAck(UpstreamRec, 22) ;

    -- Send an NAK DLLP with sequence number 23
    PcieDllSendNak(UpstreamRec, 23) ;

    -- Send idle cycles to ensure ACK/NAks a transmitted else following DLLPs may overtake
    WaitForClock(UpstreamRec, 2) ;

    -- Send all 9 different types of flow control DLLPs
    for fc in 0 to 8 loop

      if fc < 3 then
        FcType := DL_INITFC1_P  + 16#10# * (fc + 0) ;
      elsif fc < 6 then
        FcType := DL_UPDATEFC_P + 16#10# * (fc - 3) ;
      else
        FcType := DL_INITFC2_P  + 16#10# * (fc - 6) ;
      end if ;

      -- Send an InitFc1_x DLLP with  header credits and  data credits
      PcieDllSendFc(UpstreamRec, FcType, 2 + fc, 10 + fc) ;

    end loop ;
    
    -- Send all 5 power management DLLPs
    for pm in DL_PM_ENTER_L1 to DL_PM_REQ_L1 loop
      PcieDllSendPm (UpstreamRec, pm) ;
    end loop ;
    
    -- Send vendor DLLP
    PcieDllVendor(UpstreamRec) ;
    
    -- Send vendor DLLP with data
    PcieDllVendor(UpstreamRec, 1234) ; 

    -- =================================================================
    -- ==========================  E  N  D  ============================
    -- =================================================================

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(UpstreamRec, 100) ;
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
    variable DllpType          : integer ;
    variable DllpErrorStatus   : integer ;
    variable DllpSeqNum        : integer ;
    variable DllpAvailable     : boolean ;
    variable DllpVc            : integer ;
    variable DllpHdrFc         : integer ;
    variable DllpDataFc        : integer ;
    variable DllpVendData      : integer ;
    variable FcType            : integer ;
  begin

    -- Initialize Randomization Objects
    OpRV.InitSeed(OpRv'instance_name) ;
    WaitForClockRV.InitSeed(WaitForClockRV'instance_name) ;

    -- Find exit of reset
    wait until nReset = '1' ;

    SetModelOptions(DownstreamRec, CONFIG_DISABLE_ACK, CONFIG_DONT_CARE);
    SetModelOptions(DownstreamRec, CONFIG_DISABLE_FC,  CONFIG_DONT_CARE);

    WaitForClock(DownstreamRec, 2) ;

    -- =================================================================
    -- =====================  T  E  S  T  S  ===========================
    -- =================================================================

    PcieGetDllp(DownstreamRec, DllpType, DllpErrorStatus) ;
    AffirmIfEqual(DllpErrorStatus, PKT_STATUS_GOOD, "Check ACK error status") ;
    AffirmIfEqual(DllpType, DL_ACK, "Check ACK type") ;

    PcieExtractDllpSeqNum(DownstreamRec, DllpSeqNum) ;
    AffirmIfEqual(DllpSeqNum, 22) ;

    PcieGetDllp(DownstreamRec, DllpType, DllpErrorStatus) ;
    AffirmIfEqual(DllpErrorStatus, PKT_STATUS_GOOD, "Check NAK error status") ;
    AffirmIfEqual(DllpType, DL_NAK, "Check NAK type") ;

    PcieExtractDllpSeqNum(DownstreamRec, DllpSeqNum) ;
    AffirmIfEqual(DllpSeqNum, 23, "Check sequence number") ;

    for fc in 0 to 8 loop

      if fc < 3 then
        FcType := DL_INITFC1_P  + 16#10# * (fc + 0) ;
      elsif fc < 6 then
        FcType := DL_UPDATEFC_P + 16#10# * (fc - 3) ;
      else
        FcType := DL_INITFC2_P  + 16#10# * (fc - 6) ;
      end if ;

      PcieGetDllp(DownstreamRec, DllpType, DllpErrorStatus) ;
      AffirmIfEqual(DllpErrorStatus, PKT_STATUS_GOOD, "Check FC DLLP error status") ;
      AffirmIfEqual(DllpType, FcType, "Check FC DLLP type") ;

      PcieExtractDllpFc(DownstreamRec, DllpVc, DllpHdrFc, DllpDataFc) ;
      AffirmIfEqual(DllpVc,      0,      "Check DllpVc") ;
      AffirmIfEqual(DllpHdrFc,   2 + fc, "Check DllpHrdFc") ;
      AffirmIfEqual(DllpDataFc, 10 + fc, "Check DllpDataFc") ;

    end loop ;
    
    for pm in DL_PM_ENTER_L1 to DL_PM_REQ_L1 loop
      PcieGetDllp(DownstreamRec, DllpType, DllpErrorStatus) ;
      AffirmIfEqual(DllpErrorStatus, PKT_STATUS_GOOD, "Check PM DLLP error status") ;
      AffirmIfEqual(DllpType, pm, "Check PM DLLP type") ;
    end loop ;
    
    PcieGetDllp(DownstreamRec, DllpType, DllpErrorStatus) ;
    AffirmIfEqual(DllpErrorStatus, PKT_STATUS_GOOD, "Check Vendor error status") ;
    AffirmIfEqual(DllpType, DL_VENDOR, "Check Vendor type") ;
    
    PcieExtractDllpVendData(DownstreamRec, DllpVendData) ;
    AffirmIfEqual(DllpVendData, 0) ;
    
    PcieGetDllp(DownstreamRec, DllpType, DllpErrorStatus) ;
    AffirmIfEqual(DllpErrorStatus, PKT_STATUS_GOOD, "Check Vendor (data) error status") ;
    AffirmIfEqual(DllpType, DL_VENDOR, "Check Vendor (data) type") ;
    
    PcieExtractDllpVendData(DownstreamRec, DllpVendData) ;
    AffirmIfEqual(DllpVendData, 1234) ;

    -- Last Test
    PcieTryGetDllp(DownstreamRec, DllpType, DllpErrorStatus, DllpAvailable) ;
    AffirmIfEqual(DllpAvailable, false, "Check no more DLLPs") ;

    -- =================================================================
    -- ==========================  E  N  D  ============================
    -- =================================================================

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(DownstreamRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;

  end process DownstreamProc ;

end CoSim_Dll ;

Configuration Tb_PCIe_Dll of TbPcie is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(CoSim_Dll) ;
    end for ;
  end for ;
end Tb_PCIe_Dll ;