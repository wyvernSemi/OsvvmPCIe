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
    variable counts         : integer := 0;
    variable Data           : std_logic_vector(31 downto 0);
    variable Count          : integer ;
    variable CmplStatus     : integer ;
  begin
    -- Initialize Randomization Objects
    OpRV.InitSeed(OpRv'instance_name) ;
    WaitForClockRV.InitSeed(WaitForClockRV'instance_name) ;

    -- Find exit of reset
    wait until nReset = '1' ;
    WaitForClock(UpstreamRec, 2) ;

    -- Run PHY initialisation
    SetModelOptions(UpstreamRec, INITPHY, NULLOPTVALUE);

    -- Run DLL initialisation
    SetModelOptions(UpstreamRec, INITDLL, NULLOPTVALUE);

    -- ***** memory writes and reads *****

    -- Set to transmit memory accesses
    SetModelOptions(UpstreamRec, SETTRANSMODE, MEM_TRANS);

    -- Do some memory reads and writes
    Write(UpstreamRec, X"0000080", X"900dc0de");
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    Write(UpstreamRec, X"00000106", X"cafe");
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    Read(UpstreamRec, X"00000080", Data(31 downto 0));
    GetModelOptions(UpstreamRec, GETLASTCMPLSTATUS, CmplStatus);
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Read Status #1: ") ;
    AffirmIfEqual(Data(31 downto 0), X"900dc0de", "Read data #1: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    Read(UpstreamRec,  X"00000106", Data(15 downto 0)) ;
    GetModelOptions(UpstreamRec, GETLASTCMPLSTATUS, CmplStatus);
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Read Status #2: ") ;
    AffirmIfEqual(Data(15 downto 0), X"cafe", "Read data #2: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- ***** configuration writes and reads *****

    -- Set to transmit configuration space accesses
    SetModelOptions(UpstreamRec, SETTRANSMODE, CFG_SPC_TRANS);

    Write(UpstreamRec, X"00000010", X"ffffffff");
    GetModelOptions(UpstreamRec, GETLASTCMPLSTATUS, CmplStatus);
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config space write status #1: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    Write(UpstreamRec, X"00000014", X"ffffffff");
    GetModelOptions(UpstreamRec, GETLASTCMPLSTATUS, CmplStatus);
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config space write status #2: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    Read(UpstreamRec, X"00000010", Data(31 downto 0));
    AffirmIfEqual(Data(31 downto 0), X"fffff008", "Read data #3: ") ;
    GetModelOptions(UpstreamRec, GETLASTCMPLSTATUS, CmplStatus);
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config space read status #3: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    Read(UpstreamRec, X"00000014", Data(31 downto 0));
    GetModelOptions(UpstreamRec, GETLASTCMPLSTATUS, CmplStatus);
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Config space read status #3: ") ;
    AffirmIfEqual(Data(31 downto 0), X"fffffc08", "Read data #4: ") ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- Set BAR0 to be at 0x00010000, with bus =2, device = 0, func = 0
    Write(UpstreamRec, X"02_0_0_0010", X"0001_0000");
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- ***** I/O writes and reads *****

    -- Set to transmit I/O accesses
    SetModelOptions(UpstreamRec, SETTRANSMODE, IO_TRANS);

    Write(UpstreamRec, X"12345678", X"87654321");
    Read(UpstreamRec,  X"12345678", Data(31 downto 0));
    GetModelOptions(UpstreamRec, GETLASTCMPLSTATUS, CmplStatus);
    AffirmIfEqual(CmplStatus, CPL_UNSUPPORTED, "I/O Read Status #1: ") ;

    -- ***** messages *****

    -- Set to transmit messages
    SetModelOptions(UpstreamRec, SETTRANSMODE, MSG_TRANS);

    --  Error message (no payload)
    WriteAddressAsync(UpstreamRec, MSG_ERR_NON_FATAL);

    -- Set power limit messages (has payload)
    Write(UpstreamRec, MSG_SET_PWR_LIMIT, X"20251015");

    -- ***** completions *****

    -- Set to transmit completions
    SetModelOptions(UpstreamRec, SETTRANSMODE, CPL_TRANS);
    SetModelOptions(UpstreamRec, SETCMPLRID,   x"003e");
    SetModelOptions(UpstreamRec, SETCMPLCID,   x"0123");
    SetModelOptions(UpstreamRec, SETCMPLTAG,   x"01");

    Write(UpstreamRec, X"03", X"0badf00d");
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- ***** burst writes ad reads *****

    -- Set to transmit memory accesses
    SetModelOptions(UpstreamRec, SETTRANSMODE, MEM_TRANS);

    -- Write 126 bytes to 0x00000201
    for i in 0 to 125 loop
      Push(UpstreamRec.WriteBurstFifo, to_slv(i, 8)) ;
    end loop ;
    WriteBurst(UpstreamRec, X"0001_0201", 126) ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- Read back bytes from 0x00000201
    ReadBurst(UpstreamRec, X"0001_0201", 126) ;
    GetModelOptions(UpstreamRec, GETLASTCMPLSTATUS, CmplStatus);
    AffirmIfEqual(CmplStatus, CPL_SUCCESS, "Burst read status #1: ") ;

    for i in 0 to 125 loop
      Pop(UpstreamRec.ReadBurstFifo, Data(7 downto 0)) ;
      AffirmIfEqual(Data(7 downto 0), to_slv(i, 8), "Read burst data #1: ") ;
    end loop ;
    WaitForClock(UpstreamRec, WaitForClockRV.RandInt(1, 5)) ;

    -- ***** burst completion *****

    -- Set to transmit completions
    SetModelOptions(UpstreamRec, SETTRANSMODE, CPL_TRANS);
    SetModelOptions(UpstreamRec, SETCMPLTAG,   x"03");

    -- complete 47 bytes with low addr = 0x02
    for i in 0 to 46 loop
      Push(UpstreamRec.WriteBurstFifo, to_slv(i + 16, 8)) ;
    end loop ;
    WriteBurst(UpstreamRec, X"0001_0202", 47) ;

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