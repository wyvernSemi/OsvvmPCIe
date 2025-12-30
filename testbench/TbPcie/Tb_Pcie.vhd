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
--    10/2025   2026.01    Initial revision
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

  type rd_req_t is record
    addr          : std_logic_vector(31 downto 0);
    rid           : integer ;
    word_len      : integer ;
    tag           : integer ;
    word_offset   : integer ;
    padding       : integer ;
  end record rd_req_t ;

  type rd_req_array_t is array (natural range <>) of rd_req_t ;

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

    PcieCfgSpaceWrite(UpstreamRec, X"0014", X"0000", X"ffffffff", PktErrorStatus, CmplStatus) ;

    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Config Space Write Error Status #2: ") ;
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config Space Write Completion status #2: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    PcieCfgSpaceRead(UpstreamRec, X"00000010", Data(31 downto 0), PktErrorStatus, CmplStatus) ;

    AffirmIfEqual(Data(31 downto 0), X"fffff008", "Config Space Read Completion #3: ") ;
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Config Space Read Error Status #3: ") ;
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config Space Read Completion Status #3: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    PcieCfgSpaceRead(UpstreamRec, X"00000014", Data(31 downto 0), PktErrorStatus, CmplStatus) ;
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Config Space Read Error Status #4: ") ;
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config Space Read Completion Status #4: ") ;
    AffirmIfEqual(Data(31 downto 0), X"fffffc08", "Read data #4: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- Set BAR0 to be at 0x00010000, with bus =2, device = 0, func = 0
    PcieCfgSpaceWrite(UpstreamRec, X"0010", X"02_0_0", X"0001_0000", PktErrorStatus, CmplStatus) ;
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Config Space Read Error Status #5: ") ;
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config Space Write Completion Status #5: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- ***** I/O writes and reads *****

    PcieIoWrite(UpstreamRec, X"12345678", X"87654321", PktErrorStatus, CmplStatus) ;
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "I/O Write Error Status #1: ") ;
    AffirmIfEqual(CmplStatus, CPL_UNSUPPORTED, "I/O Write Completion Status #1: ") ;

    PcieIoRead(UpstreamRec,  X"12345678", Data(31 downto 0), PktErrorStatus, CmplStatus) ;
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "I/O Read Error Status #1: ") ;
    AffirmIfEqual(CmplStatus, CPL_UNSUPPORTED, "I/O Read Completion Status #1: ") ;

    -- ***** messages *****

    --  Error message (no payload)
    PcieMessageWrite(UpstreamRec, MSG_ERR_NON_FATAL) ;

    -- Set power limit messages (has payload)
    PcieMessageWrite(UpstreamRec, MSG_SET_PWR_LIMIT, X"20251015") ;

    -- ***** burst writes and reads *****

    -- Write 126 bytes to 0x00010201
    for i in 0 to 125 loop
      Push(UpstreamRec.WriteBurstFifo, to_slv(i, 8)) ;
    end loop ;
    PcieMemWrite(UpstreamRec, X"0001_0201", 126) ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- Read back bytes from 0x00010201
    PcieMemRead(UpstreamRec, X"0001_0201", 126, PktErrorStatus, CmplStatus) ;
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Burst Read Error Status #1: ") ;
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Burst Read Completion Status #1: ") ;

    for i in 0 to 125 loop
      Pop(UpstreamRec.ReadBurstFifo, Data(7 downto 0)) ;
      AffirmIfEqual(Data(7 downto 0), to_slv(i, 8), "Read burst data #1: ") ;
    end loop ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- ***** read address *****
    PcieMemReadAddress(UpstreamRec, X"00000080", 4, 16#a0#) ;
    PcieMemReadAddress(UpstreamRec, X"00000106", 2, 16#a1#) ;

    WaitForClock(UpstreamRec, 50);

    -- Expect completions in any order
    for cmplidx in 0 to 1 loop

      PcieMemReadData(UpstreamRec, Data(31 downto 0), PktErrorStatus, CmplStatus, CmplTag);

      AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Read Error Status #3: ") ;
      AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Read Completion Status #3: ") ;

      if CmplTag = 16#a0# then
        AffirmIfEqual(Data(31 downto 0), X"900dc0de", "Read data #3: ") ;
      elsif CmplTag = 16#a1# then
        AffirmIfEqual(Data(15 downto 0), X"cafe", "Read data #3: ") ;
      else
        Alert("Read data #3 unexpected TAG " & integer'image(CmplTag) & " Read data #3", ERROR) ;
      end if ;
    end loop ;

    -- ***** Locked read *****

    PcieMemReadLock(UpstreamRec,  X"00000080", Data, PktErrorStatus, CmplStatus) ;

    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Read Error Status #5: ") ;
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Read Completion Status #5: ") ;
    AffirmIfEqual(Data, X"900dc0de", "Read data #6: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    PcieMemReadLock(UpstreamRec,  X"00000106", Data(15 downto 0), PktErrorStatus, CmplStatus) ;

    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Read Error Status #6: ") ;
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Read Completion Status #6: ") ;
    AffirmIfEqual(Data(15 downto 0), X"cafe", "Read data #6: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

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

    variable ReadReqs          : rd_req_array_t (0 to 1) ;

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
    variable MsgCode           : integer ;
    variable RouteType         : integer ;
    variable Padding           : integer ;
    variable Offset            : integer ;
    variable ByteCount         : integer ;
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

    -- ******************************************
    -- ******** memory writes and reads *********
    -- ******************************************

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
        AffirmIfEqual(Tag,                0, "Rx Write Req Tag #1: ");
        AffirmIfEqual(PayloadByteLength,  4, "Rx Write Req Payload bytes #1: ");

        MemWrite(MemId, Address(Address'length-1 downto 2) & "00", Data) ;

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

        MemData               := MemRead(MemId, Address(Address'length-1 downto 2) & "00") ;
        MemData(31 downto 16) := Data(15 downto 0) ;
        MemWrite(MemId, Address(Address'length-1 downto 2) & "00", MemData) ;

    end if ;

    -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus);

        -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Read Req Error Status #3: ") ;
    AffirmIfEqual(TransType,      TL_MRD32, "Rx Read Req Type #3: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_MRD32 then

        PcieExtractMemRead(DownstreamRec, Address, Length, FBE, LBE, RID, Tag, Locked) ;

        AffirmIfEqual(Address,           X"00000080", "Rx Read Req Address #3: ") ;
        AffirmIfEqual(Length,                      1, "Rx Read Req Length #3: ") ;

        MemData := MemRead(MemId, Address(Address'length-1 downto 2) & "00") ;

        -- Send completion
        PcieCompletion(DownstreamRec, X"80", MemData, std_logic_vector(to_unsigned(RID, 16)), x"003f", Tag) ;

    end if ;

    -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus);

        -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Read Req Error Status #4: ") ;
    AffirmIfEqual(TransType,      TL_MRD32, "Rx Read Req Type #4: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_MRD32 then

        PcieExtractMemRead(DownstreamRec, Address, Length, FBE, LBE, RID, Tag, Locked) ;

        AffirmIfEqual(Address,           X"00000106", "Rx Read Req Address #4: ") ;
        AffirmIfEqual(Length,                      1, "Rx Read Req Length #4: ") ;

        -- Read word aligned memory
        MemData := MemRead(MemId, Address(Address'length-1 downto 2) & "00") ;

        -- Send completion
        PcieCompletion(DownstreamRec, X"06", MemData(31 downto 16), std_logic_vector(to_unsigned(RID, 16)), x"003f", Tag) ;
    end if ;

    -- ******************************************
    -- ***** configuration writes and reads *****
    -- ******************************************

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

    -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus) ;

    -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Cfg Spc Req Error Status #6: ") ;
    AffirmIfEqual(TransType,      TL_CFGWR0, "Rx Cfg Spc Req Type #6: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_CFGWR0 then

      PcieExtractCfgWrite(DownstreamRec, BusNum, Dev, Func, Reg, Data, FBE, RID, Tag) ;

      AffirmIfEqual(BusNum,          0, "Rx Cfg Spc Req Bus Number #6: ") ;
      AffirmIfEqual(Dev,             0, "Rx Cfg Spc Req Device Number #6: ") ;
      AffirmIfEqual(Func,            0, "Rx Cfg Spc Req Function Number #6: ") ;
      AffirmIfEqual(Reg ,       16#14#, "Rx Cfg Spc Req Register Index #6: ") ;
      AffirmIfEqual(Data , x"ffffffff", "Rx Cfg Spc Req Data #6: ") ;

      CID := std_logic_vector(to_unsigned(BusNum, 8)) &
             std_logic_vector(to_unsigned(Dev,    5)) &
             std_logic_vector(to_unsigned(Func,   3)) ;

      PcieCompletion(DownstreamRec, X"00", std_logic_vector(to_unsigned(RID, 16)), CID, Tag) ;

    end if ;

    -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus) ;

    -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Cfg Spc Req Error Status #7: ") ;
    AffirmIfEqual(TransType,      TL_CFGRD0, "Rx Cfg Spc Req Type #7: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_CFGRD0 then

      PcieExtractCfgRead(DownstreamRec, BusNum, Dev, Func, Reg, FBE, RID, Tag) ;

      AffirmIfEqual(BusNum,          0, "Rx Cfg Spc Req Bus Number #7: ") ;
      AffirmIfEqual(Dev,             0, "Rx Cfg Spc Req Device Number #7: ") ;
      AffirmIfEqual(Func,            0, "Rx Cfg Spc Req Function Number #7: ") ;
      AffirmIfEqual(Reg ,       16#10#, "Rx Cfg Spc Req Register Index #7: ") ;

      CID := std_logic_vector(to_unsigned(BusNum, 8)) &
             std_logic_vector(to_unsigned(Dev,    5)) &
             std_logic_vector(to_unsigned(Func,   3)) ;

    PcieCompletion(DownstreamRec, X"00", X"fffff008", std_logic_vector(to_unsigned(RID, 16)), CID, Tag) ;

    end if ;

    -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus) ;

    -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Cfg Spc Req Error Status #8: ") ;
    AffirmIfEqual(TransType,      TL_CFGRD0, "Rx Cfg Spc Req Type #8: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_CFGRD0 then

      PcieExtractCfgRead(DownstreamRec, BusNum, Dev, Func, Reg, FBE, RID, Tag) ;

      AffirmIfEqual(BusNum,          0, "Rx Cfg Spc Req Bus Number #8: ") ;
      AffirmIfEqual(Dev,             0, "Rx Cfg Spc Req Device Number #8: ") ;
      AffirmIfEqual(Func,            0, "Rx Cfg Spc Req Function Number #8: ") ;
      AffirmIfEqual(Reg ,       16#14#, "Rx Cfg Spc Req Register Index #8: ") ;

      CID := std_logic_vector(to_unsigned(BusNum, 8)) &
             std_logic_vector(to_unsigned(Dev,    5)) &
             std_logic_vector(to_unsigned(Func,   3)) ;

    PcieCompletion(DownstreamRec, X"00", X"fffffc08", std_logic_vector(to_unsigned(RID, 16)), CID, Tag) ;

    end if ;

    -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus) ;

    -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Cfg Spc Req Error Status #9: ") ;
    AffirmIfEqual(TransType,      TL_CFGWR0, "Rx Cfg Spc Req Type #9: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_CFGWR0 then

      PcieExtractCfgWrite(DownstreamRec, BusNum, Dev, Func, Reg, Data, FBE, RID, Tag) ;

      AffirmIfEqual(BusNum,          2, "Rx Cfg Spc Req Bus Number #9: ") ;
      AffirmIfEqual(Dev,             0, "Rx Cfg Spc Req Device Number #9: ") ;
      AffirmIfEqual(Func,            0, "Rx Cfg Spc Req Function Number #9: ") ;
      AffirmIfEqual(Reg ,       16#10#, "Rx Cfg Spc Req Register Index #9: ") ;
      AffirmIfEqual(Data , x"00010000", "Rx Cfg Spc Req Data #6: ") ;

      CID := std_logic_vector(to_unsigned(BusNum, 8)) &
             std_logic_vector(to_unsigned(Dev,    5)) &
             std_logic_vector(to_unsigned(Func,   3)) ;

      PcieCompletion(DownstreamRec, X"00", std_logic_vector(to_unsigned(RID, 16)), CID, Tag) ;

    end if ;

    -- ******************************************
    -- ********** I/O reads and writes **********
    -- ******************************************

     -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus) ;

    -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx I/O Write Req Error Status #10: ") ;
    AffirmIfEqual(TransType,      TL_IOWR, "Rx I/O Write Req Type #10: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_IOWR then

        PcieExtractIoWrite(DownstreamRec, Address, Data, FBE, RID, Tag) ;

        AffirmIfEqual(Address,  X"12345678", "Rx I/O Write Req Address #10: ") ;
        AffirmIfEqual(Data,     X"87654321", "Rx I/O Write Req Data #10: ") ;
        AffirmIfEqual(FBE,            16#F#, "Rx I/O Write Req FBE #10: ");
        AffirmIfEqual(RID,               62, "Rx I/O Write Req RID #10: ");
        AffirmIfEqual(Tag,           16#85#, "Rx I/O Write Req Tag #10: ");

        PcieCompletion(DownstreamRec, X"00", std_logic_vector(to_unsigned(RID, 16)), CID, Tag, CPL_UNSUPPORTED) ;

     end if ;

     -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus) ;

    -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx I/O Read Req Error Status #11: ") ;
    AffirmIfEqual(TransType,      TL_IORD, "Rx I/O Read Req Type #11: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_IORD then

        PcieExtractIoRead(DownstreamRec, Address, FBE, RID, Tag) ;

        AffirmIfEqual(Address,  X"12345678", "Rx I/O Read Req Address #11: ") ;
        AffirmIfEqual(FBE,            16#F#, "Rx I/O Read Req FBE #11: ");
        AffirmIfEqual(RID,               62, "Rx I/O Read Req RID #11: ");
        AffirmIfEqual(Tag,           16#86#, "Rx I/O Read Req Tag #11: ");

        PcieCompletion(DownstreamRec, X"00", std_logic_vector(to_unsigned(RID, 16)), CID, Tag, CPL_UNSUPPORTED) ;

     end if ;

    -- ******************************************
    -- **************** Messages ****************
    -- ******************************************

     -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus) ;

    -- Clear lower 3 bits of routing type
    TransType := (TransType / 8) * 8 ;

    -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Msg Req Error Status #12: ") ;
    AffirmIfEqual(TransType,      TL_MSG, "Rx Msg Req Type #12: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_MSG then

        PcieExtractMsg(DownstreamRec, MsgCode, Length, RouteType, RID, Tag, PayloadByteLength) ;

        AffirmIfEqual(MsgCode, to_integer(unsigned(MSG_ERR_NON_FATAL)), "Rx Msg Req MsgCode #12: ") ;
        AffirmIfEqual(Length,                                        0, "Rx Msg Req Length #12: ") ;
        AffirmIfEqual(PayloadByteLength,                             0, "Rx Msg Req Payload Bytes #12: ") ;
        AffirmIfEqual(RouteType,                                     0, "Rx Msg Req Route Type #12: ") ; -- route to root complex

    end if ;


     -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus) ;

    -- Clear lower 3 bits of routing type
    TransType := (TransType / 8) * 8 ;

    -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Msg Req Error Status #13: ") ;
    AffirmIfEqual(TransType,      TL_MSGD, "Rx Msg Req Type #13: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_MSGD then

        PcieExtractMsg(DownstreamRec, MsgCode, Length, RouteType, RID, Tag, PayloadByteLength) ;

        AffirmIfEqual(MsgCode, to_integer(unsigned(MSG_SET_PWR_LIMIT)), "Rx Msg Req MsgCode #13: ") ;
        AffirmIfEqual(Length,                                        1, "Rx Msg Req Length #13: ") ;
        AffirmIfEqual(PayloadByteLength,                             4, "Rx Msg Req Payload Bytes #13: ") ;
        AffirmIfEqual(RouteType,                                     4, "Rx Msg Req Route Type #13: ") ; -- ???

        Pop(DownstreamRec.ReadBurstFifo, Data( 7 downto  0)) ;
        Pop(DownstreamRec.ReadBurstFifo, Data(15 downto  8)) ;
        Pop(DownstreamRec.ReadBurstFifo, Data(23 downto 16)) ;
        Pop(DownstreamRec.ReadBurstFifo, Data(31 downto 24)) ;

        AffirmIfEqual(Data, x"20251015") ;

    end if ;

    -- ******************************************
    -- ********* burst writes and reads *********
    -- ******************************************

    -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus);

    -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Write Req Error Status #14: ") ;
    AffirmIfEqual(TransType,      TL_MWR32, "Rx Write Req Type #14: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_MWR32 then

        PcieExtractMemWrite(DownstreamRec, Address, Length, FBE, LBE, RID, Tag, PayloadByteLength) ;

        AffirmIfEqual(Address,   X"00010201", "Rx Write Req Address #14: ") ;
        AffirmIfEqual(Length,             32, "Rx Write Req Length #14: ");
        AffirmIfEqual(FBE,             16#E#, "Rx Write Req FBE #14: ");
        AffirmIfEqual(LBE,             16#7#, "Rx Write Req LBE #14: ");
        AffirmIfEqual(RID,                62, "Rx Write Req RID #14: ");
        AffirmIfEqual(Tag,            16#89#, "Rx Write Req Tag #14: ");
        AffirmIfEqual(PayloadByteLength, 126, "Rx Write Req Payload bytes #14: ");

        Offset    := to_integer(unsigned(Address(1 downto 0)));
        Address   := Address(Address'length-1 downto 2) & "00";

        for idx in Offset to PayloadByteLength+Offset-1 loop

          case (idx mod 4) is
          when 0 => Pop(DownstreamRec.ReadBurstFifo, Data( 7 downto  0)) ;
          when 1 => Pop(DownstreamRec.ReadBurstFifo, Data(15 downto  8)) ;
          when 2 => Pop(DownstreamRec.ReadBurstFifo, Data(23 downto 16)) ;
          when 3 => Pop(DownstreamRec.ReadBurstFifo, Data(31 downto 24)) ;
          when others => null ;
          end case ;

          if (idx mod 4) = 3 or idx = PayloadByteLength+Offset-1 then
              MemWrite(MemId, Address, Data);
              Address := std_logic_vector(unsigned(Address) + 4) ;
          end if ;
        end loop ;

     end if ;

    -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus);

    -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Write Req Error Status #15: ") ;
    AffirmIfEqual(TransType,      TL_MRD32, "Rx Write Req Type #15: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_MRD32 then

        PcieExtractMemRead(DownstreamRec, Address, Length, FBE, LBE, RID, Tag, Locked) ;

        AffirmIfEqual(Address,           X"00010201", "Rx Read Req Address #15: ") ;
        AffirmIfEqual(Length,                     32, "Rx Read Req Length #15: ") ;
        AffirmIfEqual(FBE,                     16#e#, "Rx Read Req FBE #15: ") ;
        AffirmIfEqual(LBE,                     16#7#, "Rx Read Req LBE #15: ") ;
        AffirmIfEqual(RID,                        62, "Rx Read Req LBE #15: ") ;
        AffirmIfEqual(Tag,                    16#8a#, "Rx Read Req Tag #15: ") ;
        AffirmIfEqual(Locked,                  false, "Rx Read Req Tag #15: ") ;

        Offset  := to_integer(unsigned(Address(1 downto 0)));
        Padding := 3 when LBE = 16#1# else
                   2 when LBE = 16#3# else
                   1 when LBE = 16#7# else
                   0 ;
        ByteCount := Length*4 - Padding - Offset ;

        Address   := Address(Address'length-1 downto 2) & "00";
        Data      := MemRead(MemId, Address);
        if Offset /= 0 then
          Address := std_logic_vector(unsigned(Address) + 4);
        end if;

        for idx in Offset to Length*4-Padding-1 loop
          case (idx mod 4) is
            when 0 => Data := MemRead(MemId, Address);
                      Push(DownstreamRec.WriteBurstFifo, Data( 7 downto  0)) ;
                      Address := std_logic_vector(unsigned(Address) + 4) ;
            when 1 => Push(DownstreamRec.WriteBurstFifo, Data(15 downto  8)) ;
            when 2 => Push(DownstreamRec.WriteBurstFifo, Data(23 downto 16)) ;
            when 3 => Push(DownstreamRec.WriteBurstFifo, Data(31 downto 24)) ;
            when others => null ;
          end case ;
        end loop ;

        PcieCompletion(DownstreamRec, Address(1 downto 0), ByteCount, std_logic_vector(to_unsigned(RID, 16)), CID, Tag) ;

    end if ;

    -- ******************************************
    -- ************** async reads ***************
    -- ******************************************

    -- Stack up read requests
    for ridx in 0 to 1 loop
      -- Wait for the reception of a transaction
      PcieGetTrans(DownstreamRec, TransType, PktErrorStatus);

      -- Check it's a good packet and of the expected type
      AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Write Req Error Status (loop " & integer'image(ridx) & ") #16: ") ;
      AffirmIfEqual(TransType,      TL_MRD32, "Rx Write Req Type (loop " & integer'image(ridx) & ") #16: ") ;

      -- If received packet good and the type expected, extract the rest of the data and check
      if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_MRD32 then

          PcieExtractMemRead(DownstreamRec, Address, Length, FBE, LBE, RID, Tag, Locked) ;

          if ridx = 0 then
            AffirmIfEqual(Address,           X"00000080", "Rx Read Req Address (loop " & integer'image(ridx) & ") #16: ") ;
          else
            AffirmIfEqual(Address,           X"00000106", "Rx Read Req Address (loop " & integer'image(ridx) & ") #16: ") ;
          end if ;
          AffirmIfEqual(Length,                        1, "Rx Read Req Length (loop " & integer'image(ridx) & ") #16: ") ;

          -- Store the request
          ReadReqs(ridx).addr        := Address ;
          ReadReqs(ridx).rid         := RID ;
          ReadReqs(ridx).word_len    := Length ;
          ReadReqs(ridx).tag         := Tag ;
          ReadReqs(ridx).word_offset := 3 when FBE = 16#8# else 2 when FBE = 16#c# else 1 when FBE = 16#e# else 0 ;
          ReadReqs(ridx).padding     := 3 when LBE = 16#1# else 2 when LBE = 16#3# else 1 when LBE = 16#7# else 0 ;

      end if ;

    end loop ;

    WaitForClock(DownstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- Send completions out-of-order
    for ridx in 1 downto 0 loop

      MemData := MemRead(MemId, ReadReqs(ridx).addr(31 downto 2) & "00") ;

      -- Send completion
      if ridx = 0 then
        PcieCompletion(DownstreamRec,
                       ReadReqs(ridx).addr(1 downto 0),
                       MemData,
                       std_logic_vector(to_unsigned(ReadReqs(ridx).rid, 16)),
                       x"003f",
                       ReadReqs(ridx).tag) ;
      else
        PcieCompletion(DownstreamRec,
                       ReadReqs(ridx).addr(1 downto 0),
                       MemData(31 downto 16),
                       std_logic_vector(to_unsigned(ReadReqs(ridx).rid, 16)),
                       x"003f",
                       ReadReqs(ridx).tag) ;
      end if ;

      WaitForClock(DownstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    end loop ;
    
    -- ******************************************
    -- ************* locked reads ***************
    -- ******************************************
    
    -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus);

        -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Read locked Req Error Status #17: ") ;
    AffirmIfEqual(TransType,      TL_MRDLCK32, "Rx Read locked Req Type #17: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_MRDLCK32 then

        PcieExtractMemRead(DownstreamRec, Address, Length, FBE, LBE, RID, Tag, Locked) ;

        AffirmIfEqual(Address,           X"00000080", "Rx Read locked Req Address #17: ") ;
        AffirmIfEqual(Length,                      1, "Rx Read locked Req Length #17: ") ;

        MemData := MemRead(MemId, Address(Address'length-1 downto 2) & "00") ;

        -- Send completion
        PcieCompletionLock(DownstreamRec, X"80", MemData, std_logic_vector(to_unsigned(RID, 16)), x"003f", Tag) ;

    end if ;

    -- Wait for the reception of a transaction
    PcieGetTrans(DownstreamRec, TransType, PktErrorStatus);

        -- Check it's a good packet and of the expected type
    AffirmIfEqual(PktErrorStatus, PKT_STATUS_GOOD, "Rx Read locked Req Error Status #18: ") ;
    AffirmIfEqual(TransType,      TL_MRDLCK32, "Rx Read locked Req Type #18: ") ;

    -- If received packet good and the type expected, extract the rest of the data and check
    if PktErrorStatus = PKT_STATUS_GOOD and TransType = TL_MRDLCK32 then

        PcieExtractMemRead(DownstreamRec, Address, Length, FBE, LBE, RID, Tag, Locked) ;

        AffirmIfEqual(Address,           X"00000106", "Rx Read locked Req Address #18: ") ;
        AffirmIfEqual(Length,                      1, "Rx Read locked Length #18: ") ;

        -- Read word aligned memory
        MemData := MemRead(MemId, Address(Address'length-1 downto 2) & "00") ;

        -- Send completion
        PcieCompletionLock(DownstreamRec, X"06", MemData(31 downto 16), std_logic_vector(to_unsigned(RID, 16)), x"003f", Tag) ;
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