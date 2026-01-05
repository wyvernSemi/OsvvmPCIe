--
--  File Name:         PcieModel.vhd
--  Design Unit Name:  PcieModel
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Simon Southwell      email:  simon.southwell@gmail.com
--  Contributor(s):
--     Simon Southwell      simon.southwell@gmail.com
--
--
--  Description:
--      Pcie GEN1/2 model
--
--  Revision History:
--    Date      Version    Description
--    07/2025   2026.01    Initial version
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2025 by [OSVVM Authors](../../AUTHORS.md).
--
--  Licensed under the Apache License, Version 2.0 (the "License") ;
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
library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;
  use ieee.math_real.all ;

library std;
use std.env.all;

library osvvm ;
  context osvvm.OsvvmContext ;
  use osvvm.ScoreboardPkg_slv.all ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

library osvvm_cosim ;
  context osvvm_cosim.CoSimContext ;

  use work.PcieInterfacePkg.all ;

entity PcieModel is
generic (
  MODEL_ID_NAME     : string  := "" ;    -- Model name
  NODE_NUM          : integer := 8 ;     -- CoSim node number. Must be unique from all other CoSim elements
  ENDPOINT          : boolean := false ; -- true to enable endpoint features
  REQ_ID            : integer := 0 ;     -- Set Requester ID (completer ID when issuing completions)
  EN_TLP_REQ_DIGEST : boolean := false ; -- true to enable ECRC on TLP requests (completions will add in response to req with ECRC---can be disabled)
  PIPE              : boolean := false ; -- true if output to be PIPE compatible (no scrambling or 8b10b encoding; lane width is 9 bits instead of 10)
  ENABLE_INIT_PHY   : boolean := true  ; -- true if PHY layer link training is to be enabled
  ENABLE_AUTO       : boolean := false   -- true if PCIe automatic features are to be enabled
) ;
port (
  -- Globals
  Clk         : in   std_logic ;
  nReset      : in   std_logic ;

  -- Testbench Transaction Interface
  TransRec    : inout AddressBusRecType ;

  -- PCIe port Functional Interface
  PcieLinkOut : out  LinkType ;
  PcieLinkIn  : in   LinkType
) ;


  -- Derive ModelInstance label from path_name
  constant MODEL_INSTANCE_NAME : string :=
    -- use MODEL_ID_NAME Generic if set, otherwise use instance label (preferred if set as entityname_1)
    IfElse(MODEL_ID_NAME /= "", MODEL_ID_NAME, PathTail(to_lower(PcieModel'PATH_NAME))) ;

end entity PcieModel ;

architecture behavioral of PcieModel is

  constant LINKWIDTH     : integer                                          := PcieLinkOut'length ;
  constant LANEWIDTH     : integer                                          := PcieLinkOut(0)'length ;
  constant ELECIDLE      : std_logic_vector(LANEWIDTH-1 downto 0)           := (others => 'Z') ;

  signal   ModelID       : AlertLogIDType ;

  signal   ClkCount      : integer                                          := 0 ;
  signal   Initialised   : boolean                                          := false ;

  signal   ReverseIn     : std_logic                                        := '0' ;
  signal   ReverseOut    : std_logic                                        := '0' ;
  signal   InvertIn      : std_logic                                        := '0' ;
  signal   InvertOut     : std_logic                                        := '0' ;
  signal   InvertInVec   : std_logic_vector (LANEWIDTH-1 downto 0) ;
  signal   InvertOutVec  : std_logic_vector (LANEWIDTH-1 downto 0) ;
  signal   ElecIdleOut   : std_logic_vector (LINKWIDTH-1 downto 0)          := (others => '1') ;
  signal   ElecIdleIn    : std_logic_vector (LINKWIDTH-1 downto 0)          := (others => '0') ;
  signal   RxDetect      : std_logic_vector (LINKWIDTH-1 downto 0)          := (others => '0') ;

  signal   LinkInVec     : LinkType(0 to LINKWIDTH-1)(LANEWIDTH-1 downto 0) := (others => (others => '0')) ;
  signal   LinkOutVec    : LinkType(0 to LINKWIDTH-1)(LANEWIDTH-1 downto 0) := (others => (others => '0')) ;

begin

  ClockCounter : process(Clk)
  begin
    if Clk'event and Clk = '1' then
      ClkCount <= ClkCount + 1;
    end if;
  end process ClockCounter ;

  InvertInVec    <= (others => InvertIn) ;
  InvertOutVec   <= (others => InvertOut) ;

  ------------------------------------------------------------
  --  Initialise
  ------------------------------------------------------------
  Initialise : process
  variable ID   : AlertLogIDType ;
  variable Node : integer := NODE_NUM ;
  begin
    -- Alerts
    ID                      := NewID(MODEL_INSTANCE_NAME) ;
    ModelID                 <= ID ;

    wait for 0 ns;
    TransRec.WriteBurstFifo <= NewID("WriteBurstFifo", ModelID, Search => PRIVATE_NAME) ;
    TransRec.ReadBurstFifo  <= NewID("ReadBurstFifo",  ModelID, Search => PRIVATE_NAME) ;
    TransRec.Params         <= NewID("Params", NUM_PCIE_PARAMS, ModelID, Search => PRIVATE_NAME) ;

    -- Co-simulation
    CoSimInit(Node) ;
    Initialised  <= true;
    wait ;
  end process Initialise ;

  ------------------------------------------------------------
  --  Transaction Dispatcher
  ------------------------------------------------------------
  TransactionDispatcher : process

    variable VPData            : integer := 0 ;
    variable VPDataHi          : integer := 0 ;
    variable UnusedVPDataWidth : integer := 0 ;
    variable VPAddr            : integer := 0 ;
    variable UnusedVPAddrHi    : integer := 0 ;
    variable UnusedVPAddrWidth : integer := 0 ;
    variable VPOp              : integer := 0 ;
    variable UnusedVPBurstSize : integer := 0 ;
    variable UnusedVPTicks     : integer := 0 ;
    variable VPDone            : integer := 0 ;
    variable VPError           : integer := 0 ;
    variable UnusedVPParam     : integer := 0 ;
    variable UnusedVPStatus    : integer := 0 ;
    variable UnusedVPCount     : integer := 0 ;
    variable UnusedCount       : integer := 0 ;
    variable UnusedIntReq      : integer := 0 ;

    variable Delta             : boolean               := false;
    variable WE                : boolean               := false;
    variable LinkOffset        : integer               := 0;
    variable DataLoBits        : std_logic_vector (3 downto 0) := (others => '0') ;

    variable RdData            : std_logic_vector (63 downto 0) := (others => '0') ;
    variable WrData            : std_logic_vector (63 downto 0) := (others => '0') ;

  begin

    wait until Initialised = true;

    DispatchLoop : loop

      -- Get the read data from the last loop iteration
      VPData   := to_integer(signed(RdData(31 downto  0))) ;
      VPDataHi := to_integer(signed(RdData(63 downto 32))) ;

      -- Fetch the next transaction from the model
      VTrans (NODE_NUM,     UnusedIntReq,      UnusedVPStatus,  UnusedVPCount, UnusedCount,
              VPData,       VPDataHi,          UnusedVPDataWidth,
              VPAddr,       UnusedVPAddrHi,    UnusedVPAddrWidth,
              VPOp,         UnusedVPBurstSize, UnusedVPTicks,
              VPDone,       VPError,           UnusedVPParam) ;

      Delta := AddressBusOperationType'val(VPOp) = READ_OP  or    -- treat all reads as asynchronous (delta-cycle) accesses
               AddressBusOperationType'val(VPOp) = ASYNC_WRITE ;

      WE    := AddressBusOperationType'val(VPOp) = WRITE_OP or
               AddressBusOperationType'val(VPOp) = ASYNC_WRITE ;

      case VPAddr is

        -- -----------------------------------------------------
        -- Process parameters
        -- -----------------------------------------------------

        when NODENUMADDR      => RdData := std_logic_vector(to_unsigned(NODE_NUM, RdData'length)) ;
        when LANESADDR        => RdData := std_logic_vector(to_unsigned(LINKWIDTH, RdData'length)) ;
        when EP_ADDR          => RdData := 64x"00000001" when ENDPOINT else 64x"00000000";
        when REQID_ADDR       => RdData := std_logic_vector(to_unsigned(REQ_ID, RdData'length)) ;
        when PIPE_ADDR        => RdData := 64x"00000001" when PIPE else 64x"00000000";
        when EN_ECRC_ADDR     => RdData := 64x"00000001" when EN_TLP_REQ_DIGEST else 64x"00000000";
        when INITPHY_ADDR     => RdData := 64x"00000001" when ENABLE_INIT_PHY else 64x"00000000";
        when ENABLE_AUTO_ADDR => RdData := 64x"00000001" when ENABLE_AUTO     else 64x"00000000";

        -- -----------------------------------------------------
        -- Process global state
        -- -----------------------------------------------------

        when RESET_STATE  => RdData := (0 => not nReset, others => '0') ;
        when CLK_COUNT    => RdData := SafeResize(std_logic_vector(to_unsigned(ClkCount, 64)), RdData'length) ;

        -- -----------------------------------------------------
        -- Process PCIe port signalling
        -- -----------------------------------------------------

        when LINKADDR0  | LINKADDR1  | LINKADDR2  | LINKADDR3  |
             LINKADDR4  | LINKADDR5  | LINKADDR6  | LINKADDR7  |
             LINKADDR8  | LINKADDR9  | LINKADDR10 | LINKADDR11 |
             LINKADDR12 | LINKADDR13 | LINKADDR14 | LINKADDR15 =>

            LinkOffset := (VPAddr - LINKADDR0) mod 16;

            if WE then
              LinkOutVec(LinkOffset) <= SafeResize(std_logic_vector(to_signed(VPData, 32)), LinkOutVec(LinkOffset)'length) xor InvertOutVec ;
            end if;

            if not is_X(LinkInVec(LinkOffset)) then
              RdData := SafeResize(LinkInVec(LinkOffset) xor InvertInVec, RdData'length) ;
            end if ;

        when LINK_STATE  =>

          if WE then
            -- Just check bottom bit and set all to that value
            if (VPData mod 2) = 0 then
              ElecIdleOut <= (others => '0') ;
            else
              ElecIdleOut <= (others => '1') ;
            end if;
          end if;

           RdData                                 := (others=> '0') ;
           RdData(ElecIdleIn'length-1  downto  0) := ElecIdleIn;  -- lower half of word
           RdData(RxDetect'length+15   downto 16) := RxDetect;    -- upper half of word

        when PVH_INVERT =>

          DataLoBits     := SafeResize(std_logic_vector(to_unsigned(VPData mod 16, 4)), DataLoBits'length) ;

          if WE then
            ReverseOut   <= '1' when DataLoBits(3) = '1' else '0' ;
            ReverseIn    <= '1' when DataLoBits(2) = '1' else '0' ;
            InvertOut    <= '1' when DataLoBits(1) = '1' else '0' ;
            InvertIn     <= '1' when DataLoBits(0) = '1' else '0' ;
          end if;

          RdData := (3 => ReverseOut, 2 => ReverseIn, 1 => InvertOut, 0 => InvertIn, others => '0') ;

        -- -----------------------------------------------------
        -- Process simulation control
        -- -----------------------------------------------------

        when PVH_STOP   => if WE then stop; end if;
        when PVH_FINISH => if WE then finish; end if;
        when PVH_FATAL  =>
          if WE then
            Alert(ModelID, "The Model had an internal error condition", ERROR) ;
          end if;

        -- -----------------------------------------------------
        -- Access transaction interface values
        -- -----------------------------------------------------

        when GETNEXTTRANS =>

          RdData := SafeResize(std_logic_vector(to_unsigned(AddressBusOperationType'pos(TransRec.Operation), 32)), RdData'length) ;

        when GETINTTOMODEL =>

          RdData := SafeResize(std_logic_vector(to_signed(TransRec.IntToModel, 32)), RdData'length) ;

        when GETBOOLTOMODEL =>

          if TransRec.BoolToModel then
            RdData := 64x"00000001" ;
          else
            RdData := 64x"00000000" ;
          end if ;

        when GETADDRESS =>

          RdData := SafeResize(TransRec.Address, RdData'length) ;

        when GETADDRESSWIDTH =>

          RdData := SafeResize(std_logic_vector(to_signed(TransRec.AddrWidth, 32)), RdData'length) ;

        when GETDATATOMODEL =>

          RdData := SafeResize(TransRec.DataToModel, RdData'length) ;

        when GETDATAWIDTH =>

          RdData := SafeResize(std_logic_vector(to_signed(TransRec.DataWidth, 32)), RdData'length) ;

        when GETPARAMS =>

          RdData := SafeResize(std_logic_vector(to_signed(Get(TransRec.Params, VPData), 32)), RdData'length) ;

        when GETOPTIONS =>

          RdData := SafeResize(std_logic_vector(to_signed(TransRec.Options, 32)), RdData'length) ;

        when SETDATAFROMMODEL =>

          WrData(31 downto  0)   := SafeResize(std_logic_vector(to_signed(VPData,   32)), 32) ;
          WrData(63 downto 32)   := SafeResize(std_logic_vector(to_signed(VPDataHi, 32)), 32) ;

          TransRec.DataFromModel <= SafeResize(WrData, TransRec.DataFromModel'length) ;

        when SETBOOLFROMMODEL =>

          if VPData /= 0 then
              TransRec.BoolFromModel <= true ;
          else
              TransRec.BoolFromModel <= false ;
          end if;

        when SETINTFROMMODEL =>

          TransRec.IntFromModel <= VPData ;

        when SETPARAMS =>

            -- When updating the address, construct as a 64-bit value
            if VPDataHi = PARAM_REQ_ADDR then
                WrData := std_logic_vector(to_unsigned(0, WrData'length)) ;
                WrData(31 downto 0) := SafeResize(std_logic_vector(to_signed(VPData, 32)), 32) ;
                Set(TransRec.Params, PARAM_REQ_ADDR, WrData) ;

            -- If upper address bits being set, add to WrData upper bits and re-write the address parameter
            elsif VPDataHi = PARAM_REQ_ADDRHI then

                WrData(63 downto 32) :=  SafeResize(std_logic_vector(to_signed(VPData, 32)), 32) ;
                Set(TransRec.Params, PARAM_REQ_ADDR, WrData) ;

            else

                Set(TransRec.Params, VPDataHi, VPData) ;

            end if ;

        when POPWDATA =>

          RdData(7 downto 0) := Pop(TransRec.WriteBurstFifo) ;

        when PUSHWDATA =>

          WrData(7 downto 0) := SafeResize(std_logic_vector(to_signed(VPData, 32)), 8) ;

          Push(TransRec.WriteBurstFifo, WrData(7 downto 0)) ;

        when PUSHRDATA =>

          WrData(7 downto 0) := SafeResize(std_logic_vector(to_signed(VPData, 32)), 8) ;

          Push(TransRec.ReadBurstFifo, WrData(7 downto 0)) ;

        when POPRDATA =>

          RdData(7 downto 0) := Pop(TransRec.ReadBurstFifo) ;

        when ACKTRANS =>

          if WE then
            WaitForTransaction(
               Clk      => Clk,
               Rdy      => TransRec.Rdy,
               Ack      => TransRec.Ack
            ) ;
          end if ;

        -- -----------------------------------------------------
        -- Process unhandled  accesses
        -- -----------------------------------------------------
        when others =>
          Alert(ModelID, "VTrans co-sim procedure issued invalid address = " & to_string(VPaddr), FAILURE) ;

      end case;

      -- If not a delta access, wait for next clock edge, else loop round immediately
      if not Delta then
        wait until rising_edge(Clk) ;
      end if ;

    end loop ;

  end process TransactionDispatcher ;

  ------------------------------------------------------------
  -- Input and output signal conditioning
  ------------------------------------------------------------

  SignalConditioning : process (all)
  begin

    for idx in 0 to LINKWIDTH-1 loop

      ElecIdleIn(idx)   <= '1' when has_all_z(PcieLinkIn(idx))  else '0';
      RxDetect(idx)     <= '1' when is_X(PcieLinkOut(idx)) else '0';
      LinkInVec(idx)    <= PcieLinkIn(LINKWIDTH - 1 - idx) when ReverseIn = '1' else PcieLinkIn(idx) after 1 ps ;
      PcieLinkOut(idx)  <= ELECIDLE when ElecIdleOut(0)  = '1' else LinkOutVec(LINKWIDTH - 1 - idx) when ReverseOut else LinkOutVec(idx) ;

    end loop ;

  end process SignalConditioning ;

end architecture behavioral ;
