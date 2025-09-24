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
    -- Initialization of test
    SetLogEnable(PASSED, TRUE) ;  -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen ;  -- SetTestName done in SW
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
  -- ManagerProc
  --   Generate transactions for AxiManager
  ------------------------------------------------------------
  ManagerProc : process
    variable OpRV           : RandomPType ;
    variable WaitForClockRV : RandomPType ;
    variable counts         : integer := 0;

    -- CoSim variables
    variable RnW            : integer ;
    variable Done           : integer := 0 ;
    variable Error          : integer := 0 ;
    variable IntReq         : integer := 0 ;
    variable NodeNum        : integer := Node ;

    variable Count          : integer ;
  begin
    -- Initialize Randomization Objects
    OpRV.InitSeed(OpRv'instance_name) ;
    WaitForClockRV.InitSeed(WaitForClockRV'instance_name) ;

    -- Initialise VProc code
    -- CoSimInit(NodeNum);
    Initialised <= TRUE;

    -- SetBurstMode(ManagerRec, BURST_MODE) ;

    -- Find exit of reset
    wait until nReset = '1' ;
    WaitForClock(ManagerRec, 2) ;

    OperationLoop : loop

      -- 20 % of the time add a no-op cycle with a delay of 1 to 5 clocks
      if WaitForClockRV.DistInt((8, 2)) = 1 then
        WaitForClock(ManagerRec, WaitForClockRV.RandInt(1, 5)) ;
      end if ;

      -- Call CoSimTrans procedure to generate an access from the running VProc program
      -- CoSimTrans (ManagerRec, Done, Error, IntReq, NodeNum);

      AlertIf(Error /= 0, "CoSimTrans flagged an error") ;

      -- Finish when Done flagged
      exit when Done /= 0;

      counts := counts + 1;

    end loop OperationLoop ;

    TestActive <= FALSE ;

    -- Allow Subordinate to catch up before signaling OperationCount (needed when WRITE_OP is last)
    -- wait for 0 ns ;  -- this is enough
    WaitForClock(ManagerRec, 2) ;
    Increment(OperationCount) ;

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ManagerRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ManagerProc ;
end CoSim ;

-- Configuration Tb_PCIe of TbPcie is
--   for TestHarness
--     for TestCtrl_1 : TestCtrl
--       use entity work.TestCtrl(CoSim) ;
--     end for ;
--   end for ;
-- end Tb_PCIe ;