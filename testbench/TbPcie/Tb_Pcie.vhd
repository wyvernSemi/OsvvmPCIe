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
  signal   Initialised    : boolean         := FALSE;

  signal   MemId          : MemoryIDType ;
  signal   CfgSpcId       : MemoryIDType ;

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin

    SetTestName("CoSim_Pcie");

    MemId    <= NewID("MainMem", 32, 32) ;
    CfgSpcId <= NewID("CfgSpc",  12, 32) ;

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
    variable Data           : std_logic_vector(31 downto 0) ;
    variable CmplStatus     : integer ;
    variable PktErrorStatus : integer ;
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
    PcieInitLink(UpstreamRec) ;

    -- Run DLL initialisation
    PcieInitDll(UpstreamRec) ;

    -- ***** memory writes and reads *****

    -- Do some memory reads and writes
    PcieMemWrite(UpstreamRec, X"00000080", X"900dc0de") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    PcieMemWrite(UpstreamRec, X"00000106", X"cafe");
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    PcieMemRead(UpstreamRec, X"00000080", Data(31 downto 0), PktErrorStatus, CmplStatus) ;

    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Read Error Status #1: ") ;
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Read Completion Status #1: ") ;
    AffirmIfEqual(Data(31 downto 0), X"900dc0de", "Read data #1: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    PcieMemRead(UpstreamRec,  X"00000106", Data(15 downto 0), PktErrorStatus, CmplStatus) ;

    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Read Error Status #2: ") ;
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Read Completion Status #2: ") ;
    AffirmIfEqual(Data(15 downto 0), X"cafe", "Read data #2: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- ***** configuration writes and reads *****
    --                 TransRec    Offset    CID      Data         Status      Tag
    PcieCfgSpaceWrite(UpstreamRec, X"0010",  X"0000", X"ffffffff", PktErrorStatus, CmplStatus, 128) ; -- Set the tag
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Config Space Write Error Status #1: ") ;
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config Space Write Completion Status #1: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

--     PcieCfgSpaceWrite(UpstreamRec, X"0014", X"0000", X"ffffffff", PktErrorStatus, CmplStatus) ;
--
--     AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Config Space Write Error Status #2: ") ;
--     AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config Space Write Completion status #2: ") ;
--     WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;
--
--     PcieCfgSpaceRead(UpstreamRec, X"00000010", Data(31 downto 0), PktErrorStatus, CmplStatus) ;
--
--     AffirmIfEqual(Data(31 downto 0), X"fffff008", "Config Space Read Completion #3: ") ;
--     AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Config Space Read Error Status #3: ") ;
--     AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config Space Read Completion Status #3: ") ;
--     WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;
--
--     PcieCfgSpaceRead(UpstreamRec, X"00000014", Data(31 downto 0), PktErrorStatus, CmplStatus) ;
--     AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Config Space Read Error Status #4: ") ;
--     AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config Space Read Completion Status #4: ") ;
--     AffirmIfEqual(Data(31 downto 0), X"fffffc08", "Read data #4: ") ;
--     WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;
--
--     -- Set BAR0 to be at 0x00010000, with bus =2, device = 0, func = 0
--     PcieCfgSpaceWrite(UpstreamRec, X"0010", X"02_0_0", X"0001_0000", PktErrorStatus, CmplStatus) ;
--     AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Config Space Read Error Status #5: ") ;
--     AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config Space Write Completion Status #5: ") ;
--     WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;
--
--     -- ***** I/O writes and reads *****
--
--     PcieIoWrite(UpstreamRec, X"12345678", X"87654321", PktErrorStatus, CmplStatus) ;
--     AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "I/O Write Error Status #1: ") ;
--     AffirmIfEqual(CmplStatus, CPL_UNSUPPORTED, "I/O Write Completion Status #1: ") ;
--
--     PcieIoRead(UpstreamRec,  X"12345678", Data(31 downto 0), PktErrorStatus, CmplStatus) ;
--     AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "I/O Read Error Status #1: ") ;
--     AffirmIfEqual(CmplStatus, CPL_UNSUPPORTED, "I/O Read Completion Status #1: ") ;
--
--     -- ***** messages *****
--
--     --  Error message (no payload)
--     PcieMessageWrite(UpstreamRec, MSG_ERR_NON_FATAL) ;
--
--     -- Set power limit messages (has payload)
--     PcieMessageWrite(UpstreamRec, MSG_SET_PWR_LIMIT, X"20251015") ;
--
--     -- ***** completions *****
--
--     -- Set to transmit completions
--     PcieCompletion(UpstreamRec, X"63", X"0badf00d", X"003e", X"0123", 1) ;
--
--     WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;
--
--     -- Set to transmit completions
--     PcieCompletionLock(UpstreamRec, X"51", X"25081964", X"003e", X"0123", 1) ;
--
--     WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;
--
--     -- ***** burst writes and reads *****
--
--     -- Write 126 bytes to 0x00010201
--     for i in 0 to 125 loop
--       Push(UpstreamRec.WriteBurstFifo, to_slv(i, 8)) ;
--     end loop ;
--     PcieMemWrite(UpstreamRec, X"0001_0201", 126) ;
--     WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;
--
--     -- Read back bytes from 0x00010201
--     PcieMemRead(UpstreamRec, X"0001_0201", 126, PktErrorStatus, CmplStatus) ;
--     AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Burst Read Error Status #1: ") ;
--     AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Burst Read Completion Status #1: ") ;
--
--     for i in 0 to 125 loop
--       Pop(UpstreamRec.ReadBurstFifo, Data(7 downto 0)) ;
--       AffirmIfEqual(Data(7 downto 0), to_slv(i, 8), "Read burst data #1: ") ;
--     end loop ;
--     WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;
--
--     -- ***** burst completion *****
--
--     -- Set to transmit completions
--
--     -- complete 47 bytes with low addr = 0x32
--     for i in 0 to 46 loop
--       Push(UpstreamRec.WriteBurstFifo, to_slv(i + 16, 8)) ;
--     end loop ;
--     PcieCompletion(UpstreamRec, X"32", 47, X"003e", X"0123", 2) ;
--
--
--     -- ***** read address *****
--     PcieMemWrite(UpstreamRec, X"00010080", X"900dc0de") ;
--     PcieMemWrite(UpstreamRec, X"00010106", X"cafe");
--
--     PcieMemReadAddress(UpstreamRec, X"00010080", 4, 16#a0#) ;
--     PcieMemReadAddress(UpstreamRec, X"00010106", 2, 16#a1#) ;
--
--     WaitForClock(UpstreamRec, 50);
--
--     PcieMemReadData(UpstreamRec, Data(31 downto 0), PktErrorStatus, CmplStatus, CmplTag);
--
--     AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Read Error Status #3: ") ;
--     AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Read Completion Status #3: ") ;
--     AffirmIfEqual(CmplTag, 16#a0#, "Read tag #3: ") ;
--     AffirmIfEqual(Data(31 downto 0), X"900dc0de", "Read data #3: ") ;
--
--     PcieMemReadData(UpstreamRec, Data(15 downto 0), PktErrorStatus, CmplStatus, CmplTag);
--
--     AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Read Error Status #4: ") ;
--     AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Read Completion Status #4: ") ;
--     AffirmIfEqual(CmplTag, 16#a1#, "Read tag #4: ") ;
--     AffirmIfEqual(Data(15 downto 0), X"cafe", "Read data #4: ") ;
--
--     -- ***** part completions *****
--     -- Transfer 47 bytes in two completions
--     RemainLen := 47 ;
--
--     -- complete 22 bytes (of 47) with low addr = 0x32
--     for i in 0 to 21 loop
--       Push(UpstreamRec.WriteBurstFifo, to_slv(i + 32, 8)) ;
--     end loop ;
--     PciePartCompletion(UpstreamRec, X"32", 22, X"003e", X"0123", std_logic_vector(to_unsigned(RemainLen, 12)), 3) ;
--     RemainLen := RemainLen - 22 ;
--
--     -- complete remaining 25 bytes with low addr = 0x48
--     for i in 0 to 24 loop
--       Push(UpstreamRec.WriteBurstFifo, to_slv(i + 54, 8)) ;
--     end loop ;
--     PciePartCompletion(UpstreamRec, X"48", 25, X"003e", X"0123", std_logic_vector(to_unsigned(RemainLen, 12)), 4) ;
--
--     -- ***** Locked read *****
--     PcieMemReadLock(UpstreamRec,  X"00010106", Data(15 downto 0), PktErrorStatus, CmplStatus) ;
--
--     AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Read Error Status #5: ") ;
--     AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Read Completion Status #5: ") ;
--     AffirmIfEqual(Data(15 downto 0), X"cafe", "Read data #5: ") ;
--     WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;
--
--     PcieMemReadLock(UpstreamRec,  X"00000006", Data(15 downto 0), PktErrorStatus, CmplStatus) ;
--
--     AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Read Error Status #6: ") ;
--     AffirmIfEqual(CmplStatus, CPL_UNSUPPORTED, "Read Completion Status #6: ") ;
--     WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

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

    variable Data              : std_logic_vector(31 downto 0) ;
    variable MemData           : std_logic_vector(31 downto 0) ;
    variable Address           : std_logic_vector(31 downto 0) ;
    variable CID               : std_logic_vector(15 downto 0) := x"0000";

    variable TransType         : integer ;
    variable PktErrorStatus    : integer ;
    variable Length            : integer ;
    variable FBE               : integer ;
    variable LBE               : integer ;
    variable RID               : integer ;
    variable Tag               : integer ;
    variable PayloadByteLength : integer ;
    variable Locked            : boolean ;
    variable BusNum            : integer ;
    variable Dev               : integer ;
    variable Func              : integer ;
    variable Reg               : integer ;

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

   -- Run PHY initialisation
    PcieInitLink(DownstreamRec) ;

    -- Run DLL initialisation
    PcieInitDll(DownstreamRec) ;

    -- ***** memory writes and reads *****

    -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus);

    -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Write Req Error Status #1: ") ;
    AffirmIfEqual(TransType,      TL_MWR32, "Rx Write Req Type #1: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_MWR32 then

        PcieExtractMemWrite(DownstreamRec, Address, Data, Length, FBE, LBE, RID, Tag, PayloadByteLength) ;

        AffirmIfEqual(Address,  X"00000080", "Rx Write Req Address #1: ") ;
        AffirmIfEqual(Data,     X"900dc0de", "Rx Write Req Data #1: ") ;
        AffirmIfEqual(Length,             1, "Rx Write Req Length #1: ");
        AffirmIfEqual(FBE,            16#F#, "Rx Write Req FBE #1: ");
        AffirmIfEqual(LBE,            16#0#, "Rx Write Req LBE #1: ");
        AffirmIfEqual(RID,               62, "Rx Write Req RID #1: ");
        AffirmIfEqual(Tag,                1, "Rx Write Req Tag #1: ");
        AffirmIfEqual(PayloadByteLength,  4, "Rx Write Req Payload bytes #1: ");

        MemWrite(MemId, Address(31 downto 2) & "00", Data) ;

     end if ;

    -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus);

    -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Write Req Error Status #2: ") ;
    AffirmIfEqual(TransType,      TL_MWR32, "Rx Write Req Type #2: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_MWR32 then

        PcieExtractMemWrite(DownstreamRec, Address, Data, Length, FBE, LBE, RID, Tag, PayloadByteLength) ;

        AffirmIfEqual(Address,           X"00000106", "Rx Write Req Address #2: ") ;
        AffirmIfEqual(Data(15 downto 0), X"cafe",     "Rx Write Req Data #2: ") ;

        MemData               := MemRead(MemId, Address(31 downto 2) & "00") ;
        MemData(31 downto 16) := Data(15 downto 0) ;
        MemWrite(MemId, Address(31 downto 2) & "00", MemData) ;

    end if ;

    -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus);

        -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Write Req Error Status #3: ") ;
    AffirmIfEqual(TransType,      TL_MRD32, "Rx Write Req Type #3: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_MRD32 then

        PcieExtractMemRead(DownstreamRec, Address, Length, FBE, LBE, RID, Tag, Locked) ;

        AffirmIfEqual(Address,           X"00000080", "Rx Read Req Address #3: ") ;
        AffirmIfEqual(Length,                      1, "Rx Read Req Length #3: ") ;

        MemData := MemRead(MemId, Address(31 downto 2) & "00") ;

        -- Send completion
        PcieCompletion(DownstreamRec, X"80", MemData, std_logic_vector(to_unsigned(RID, 16)), x"003f", Tag) ;

    end if ;

    -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus);

        -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Write Req Error Status #4: ") ;
    AffirmIfEqual(TransType,      TL_MRD32, "Rx Write Req Type #4: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_MRD32 then

        PcieExtractMemRead(DownstreamRec, Address, Length, FBE, LBE, RID, Tag, Locked) ;

        AffirmIfEqual(Address,           X"00000106", "Rx Read Req Address #4: ") ;
        AffirmIfEqual(Length,                      1, "Rx Read Req Length #4: ") ;

        -- Read word aligned memory
        MemData := MemRead(MemId, Address(31 downto 2) & "00") ;

        -- Send completion
        PcieCompletion(DownstreamRec, X"06", MemData(31 downto 16), std_logic_vector(to_unsigned(RID, 16)), x"003f", Tag) ;
    end if ;

    -- ***** configuration writes and reads *****

    -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus) ;

    -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Cfg Spc Req Error Status #5: ") ;
    AffirmIfEqual(TransType,      TL_CFGWR0, "Rx Cfg Spc Req Type #5: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_CFGWR0 then

      PcieExtractCfgWrite(DownstreamRec, BusNum, Dev, Func, Reg, Data, FBE, RID, Tag) ;

      AffirmIfEqual(BusNum,          0, "Rx Cfg Spc Req Bus Number #5: ") ;
      AffirmIfEqual(Dev,             0, "Rx Cfg Spc Req Device Number #5: ") ;
      AffirmIfEqual(Func,            0, "Rx Cfg Spc Req Function Number #5: ") ;
      AffirmIfEqual(Reg ,       16#10#, "Rx Cfg Spc Req Register Index #5: ") ;
      AffirmIfEqual(Data , x"ffffffff", "Rx Cfg Spc Req Data #5: ") ;

      CID := std_logic_vector(to_unsigned(BusNum, 8)) &
             std_logic_vector(to_unsigned(Dev,    5)) &
             std_logic_vector(to_unsigned(Func,   3)) ;

      PcieCompletion(DownstreamRec, X"00", std_logic_vector(to_unsigned(RID, 16)), CID, Tag) ;

    end if ;


    -- =================================================================
    -- ==========================  E  N  D  ============================
    -- ================================================================= ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(DownstreamRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;

  end process DownstreamProc ;

end CoSim ;

Configuration Tb_PCIe of TbPcie is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(CoSim) ;
    end for ;
  end for ;
end Tb_PCIe ;