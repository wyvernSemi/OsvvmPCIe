--
--  File Name:         PcieInterfacePkg.vhd
--  Design Unit Name:  PcieInterfacePkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Simon Southwell      email:  simon.southwell@gmail.com
--  Contributor(s):
--     Simon Southwell simon.southwell@gmail.com
--
--
--  Description:
--      Defines types, constants, and subprograms to support the PCie interface to DUT
--      These are currently only intended for testbench models.
--
--  Revision History:
--    Date      Version    Description
--    09/2025   ????.??       Initial revision
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

library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;


library osvvm ;
  context osvvm.OsvvmContext ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

package PcieInterfacePkg is

  -- **** If the below values change, a      lso update ../../code/pcieVcInterface.h ****
  constant LINKADDR0                         : integer :=  0 ;
  constant LINKADDR1                         : integer :=  1 ;
  constant LINKADDR2                         : integer :=  2 ;
  constant LINKADDR3                         : integer :=  3 ;
  constant LINKADDR4                         : integer :=  4 ;
  constant LINKADDR5                         : integer :=  5 ;
  constant LINKADDR6                         : integer :=  6 ;
  constant LINKADDR7                         : integer :=  7 ;
  constant LINKADDR8                         : integer :=  8 ;
  constant LINKADDR9                         : integer :=  9 ;
  constant LINKADDR10                        : integer := 10 ;
  constant LINKADDR11                        : integer := 11 ;
  constant LINKADDR12                        : integer := 12 ;
  constant LINKADDR13                        : integer := 13 ;
  constant LINKADDR14                        : integer := 14 ;
  constant LINKADDR15                        : integer := 15 ;

  constant NODENUMADDR                       : integer := 200 ;
  constant LANESADDR                         : integer := 201 ;
  constant PVH_INVERT                        : integer := 202 ;
  constant EP_ADDR                           : integer := 203 ;
  constant CLK_COUNT                         : integer := 204 ;
  constant LINK_STATE                        : integer := 205 ;
  constant RESET_STATE                       : integer := 206 ;

  constant REQID_ADDR                        : integer := 300 ;
  constant PIPE_ADDR                         : integer := 301 ;
  constant EN_ECRC_ADDR                      : integer := 302 ;
  constant INITPHY_ADDR                      : integer := 303 ;

  constant GETNEXTTRANS                      : integer := 400 ;
  constant GETINTTOMODEL                     : integer := 401 ;
  constant GETBOOLTOMODEL                    : integer := 402 ;
  constant GETTIMETOMODEL                    : integer := 403 ;
  constant GETADDRESS                        : integer := 404 ;
  constant GETADDRESSWIDTH                   : integer := 405 ;
  constant GETDATATOMODEL                    : integer := 406 ;
  constant GETDATAWIDTH                      : integer := 407 ;
  constant GETPARAMS                         : integer := 408 ;
  constant GETOPTIONS                        : integer := 409 ;
  constant ACKTRANS                          : integer := 410 ;
  constant SETDATAFROMMODEL                  : integer := 411 ;
  constant SETBOOLFROMMODEL                  : integer := 412 ;
  constant SETINTFROMMODEL                   : integer := 413 ;
  constant POPDATA                           : integer := 414 ;
  constant PUSHDATA                          : integer := 415 ;

  constant PVH_STOP                          : integer := -3 ;
  constant PVH_FINISH                        : integer := -2 ;
  constant PVH_FATAL                         : integer := -1 ;

  -- SetModelOptions for pcievhost model
  constant CONFIG_FC_HDR_RATE                : integer :=  0 ;
  constant CONFIG_FC_DATA_RATE               : integer :=  1 ;

  constant CONFIG_ENABLE_FC                  : integer :=  2 ;
  constant CONFIG_DISABLE_FC                 : integer :=  3 ;

  constant CONFIG_ENABLE_ACK                 : integer :=  4 ;
  constant CONFIG_DISABLE_ACK                : integer :=  5 ;

  constant CONFIG_ENABLE_MEM                 : integer :=  6 ;
  constant CONFIG_DISABLE_MEM                : integer :=  7 ;

  constant CONFIG_ENABLE_SKIPS               : integer :=  8 ;
  constant CONFIG_DISABLE_SKIPS              : integer :=  9 ;

  constant CONFIG_ENABLE_UR_CPL              : integer := 10 ;
  constant CONFIG_DISABLE_UR_CPL             : integer := 11 ;

  constant CONFIG_POST_HDR_CR                : integer := 12 ;
  constant CONFIG_POST_DATA_CR               : integer := 13 ;

  constant CONFIG_NONPOST_HDR_CR             : integer := 14 ;
  constant CONFIG_NONPOST_DATA_CR            : integer := 15 ;

  constant CONFIG_CPL_HDR_CR                 : integer := 16 ;
  constant CONFIG_CPL_DATA_CR                : integer := 17 ;

  constant CONFIG_CPL_DELAY_RATE             : integer := 18 ;
  constant CONFIG_CPL_DELAY_SPREAD           : integer := 19 ;

  constant CONFIG_LTSSM_LINKNUM              : integer := 20 ;
  constant CONFIG_LTSSM_N_FTS                : integer := 21 ;
  constant CONFIG_LTSSM_TS_CTL               : integer := 22 ;
  constant CONFIG_LTSSM_DETECT_QUIET_TO      : integer := 23 ;
  constant CONFIG_LTSSM_ENABLE_TESTS         : integer := 24 ;
  constant CONFIG_LTSSM_FORCE_TESTS          : integer := 25 ;
  constant CONFIG_LTSSM_POLL_ACTIVE_TX_COUNT : integer := 26 ;
  constant CONFIG_LTSSM_DISABLE_DISP_STATE   : integer := 27 ;

  constant CONFIG_DISABLE_SCRAMBLING         : integer := 28 ;
  constant CONFIG_ENABLE_SCRAMBLING          : integer := 29 ;

  constant CONFIG_DISABLE_8B10B              : integer := 30 ;
  constant CONFIG_ENABLE_8B10B               : integer := 31 ;

  constant CONFIG_DISABLE_ECRC_CMPL          : integer := 32 ;
  constant CONFIG_ENABLE_ECRC_CMPL           : integer := 33 ;

  constant CONFIG_DISABLE_CRC_CHK            : integer := 34 ;
  constant CONFIG_ENABLE_CRC_CHK             : integer := 35 ;

  constant CONFIG_DISABLE_DISPLINK_COLOUR    : integer := 36 ;
  constant CONFIG_ENABLE_DISPLINK_COLOUR     : integer := 37 ;

  constant CONFIG_DISP_BCK_NODE_NUM          : integer := 38 ;

  -- SetModelOptions for PCIe VC
  constant NULLOPTVALUE                      : integer := -1 ;
  constant VCOPTIONSTART                     : integer :=  1000 ;
  constant ENDMODELRUN                       : integer :=  VCOPTIONSTART ;
  constant SETTRANSMODE                      : integer :=  1001 ;
  constant INITDLL                           : integer :=  1002 ;
  constant INITPHY                           : integer :=  1003 ;
  constant SETRDLCK                          : integer :=  1004 ;
  constant SETCMPLRID                        : integer :=  1005 ;
  constant SETCMPLCID                        : integer :=  1006 ;
  constant SETCMPLRLEN                       : integer :=  1007 ;
  constant SETCMPLTAG                        : integer :=  1008 ;
  constant SETREQTAG                         : integer :=  1009 ;
  constant GETLASTCMPLSTATUS                 : integer :=  1010 ;
  constant GETLASTRXREQTAG                   : integer :=  1011 ;

  constant FREERUNSIM                        : integer :=  0 ;
  constant STOPSIM                           : integer :=  1 ;
  constant FINISHSIM                         : integer :=  2 ;

  constant MEM_TRANS                         : integer :=  0 ;
  constant IO_TRANS                          : integer :=  1 ;
  constant CFG_SPC_TRANS                     : integer :=  2 ;
  constant MSG_TRANS                         : integer :=  3 ;
  constant CPL_TRANS                         : integer :=  4 ;
  constant PART_CPL_TRANS                    : integer :=  5 ;

  constant TLP_TAG_AUTO                      : integer :=  16#100#;

  -- PCIe Message codes

  constant MSG_UNLOCK                  : std_logic_vector(31 downto 0) := X"00000000" ;

  constant MSG_ASSERT_INTA             : std_logic_vector(31 downto 0) := X"00000020" ;
  constant MSG_ASSERT_INTB             : std_logic_vector(31 downto 0) := X"00000021" ;
  constant MSG_ASSERT_INTC             : std_logic_vector(31 downto 0) := X"00000022" ;
  constant MSG_ASSERT_INTD             : std_logic_vector(31 downto 0) := X"00000023" ;
  constant MSG_DEASSERT_INTA           : std_logic_vector(31 downto 0) := X"00000024" ;
  constant MSG_DEASSERT_INTB           : std_logic_vector(31 downto 0) := X"00000025" ;
  constant MSG_DEASSERT_INTC           : std_logic_vector(31 downto 0) := X"00000026" ;
  constant MSG_DEASSERT_INTD           : std_logic_vector(31 downto 0) := X"00000027" ;

  constant MSG_PM_ACTIVE_STATE_NAK     : std_logic_vector(31 downto 0) := X"00000014" ;
  constant MSG_PME                     : std_logic_vector(31 downto 0) := X"00000018" ;
  constant MSG_PME_TURN_OFF            : std_logic_vector(31 downto 0) := X"00000019" ;
  constant MSG_PME_TO_ACK              : std_logic_vector(31 downto 0) := X"0000001B" ;

  constant MSG_ERR_CORR                : std_logic_vector(31 downto 0) := X"00000030" ;
  constant MSG_ERR_NON_FATAL           : std_logic_vector(31 downto 0) := X"00000031" ;
  constant MSG_ERR_FATAL               : std_logic_vector(31 downto 0) := X"00000033" ;

  constant MSG_SET_PWR_LIMIT           : std_logic_vector(31 downto 0) := X"00000050" ;
  constant MSG_VENDOR_0                : std_logic_vector(31 downto 0) := X"0000007e" ;
  constant MSG_VENDOR_1                : std_logic_vector(31 downto 0) := X"0000007f" ;

  constant MSG_DATA_NULL               : std_logic_vector(31 downto 0) := X"00000000" ;


  constant CPL_SUCCESS                 : integer                       := 0 ;
  constant CPL_UNSUPPORTED             : integer                       := 1 ;
  constant CPL_CRS                     : integer                       := 2 ;
  constant CPL_ABORT                   : integer                       := 4 ;

  -- **** If the above values change, also update ../../code/pcieVcInterface.h ****

  constant MAXLINKWIDTH        : integer := 16 ;

  subtype TagType is integer range 0 to 256;

  type LinkType is array (natural range <>) of std_logic_vector ;

  type PcieRecType is record
    LinkOut       : LinkType ;
    LinkIn        : LinkType ;
  end record PcieRecType;

  function has_an_x (vec : std_logic_vector) return boolean ;

  ------------------------------------------------------------
  procedure PcieMemWrite (
  -- do PCIe Memory Write Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iData          : In    std_logic_vector ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) ;

  ------------------------------------------------------------
  procedure PcieMemWrite (
  -- do PCIe Burst Write Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iByteCount     : In    integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) ;

  ------------------------------------------------------------
  procedure PcieMemRead (
  -- do PCIe Memory Read Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             oData          : Out   std_logic_vector ;
             oStatus        : Out   integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) ;

  ------------------------------------------------------------
  procedure PcieMemRead (
  -- do PCIe Read Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iByteCount     : In    integer ;
             oStatus        : Out   integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) ;

  ------------------------------------------------------------
  procedure PcieMemReadLock (
  -- do PCIe Memory Read Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             oData          : Out   std_logic_vector ;
             oStatus        : Out   integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) ;

  ------------------------------------------------------------
  procedure PcieMemReadLock (
  -- do PCIe Read Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iByteCount     : In    integer ;
             oStatus        : Out   integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) ;

  ------------------------------------------------------------
  procedure PcieMemReadAddress (
  -- do PCIe Read Address Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iByteCount     : In    integer ;
             iLock          : In    boolean := false ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) ;

  ------------------------------------------------------------
  procedure PcieMemReadAddress (
  -- do PCIe Read Address Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iByteCount     : In    integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) ;

  ------------------------------------------------------------
  procedure PcieMemReadLockAddress (
  -- do PCIe Read Address Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iByteCount     : In    integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) ;

  ------------------------------------------------------------
  procedure PcieMemReadData (
  -- do PCIe Read Address Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             oData          : Out   std_logic_vector ;
             oStatus        : Out   integer ;
             oTag           : Out   TagType
  ) ;

  ------------------------------------------------------------
  procedure PcieCfgSpaceWrite (
  -- do PCIe Configuration Space Write Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iData          : In    std_logic_vector ;
             oStatus        : Out   integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) ;

  ------------------------------------------------------------
  procedure PcieCfgSpaceRead (
  -- do PCIe Configuration Space Read Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             oData          : Out   std_logic_vector ;
             oStatus        : Out   integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) ;

  ------------------------------------------------------------
  procedure PcieIoWrite (
  -- do PCIe I/O Space Write Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iData          : In    std_logic_vector ;
             oStatus        : Out   integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) ;

  ------------------------------------------------------------
  procedure PcieIoRead (
  -- do PCIe I/O Space Read Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             oData          : Out   std_logic_vector ;
             oStatus        : Out   integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) ;

  ------------------------------------------------------------
  procedure PcieMessageWrite (
  -- do PCIe message (no data) Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iMsgType       : In    std_logic_vector ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) ;

  ------------------------------------------------------------
  procedure PcieMessageWrite (
  -- do PCIe message (with data) Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iMsgType       : In    std_logic_vector ;
             iMsgData       : In    std_logic_vector ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) ;

  ------------------------------------------------------------
  procedure PcieCompletion (
  -- do PCIe completion (with data) Cycle
  ------------------------------------------------------------
  signal   TransactionRec : InOut AddressBusRecType ;
           iLowAddr       : In    std_logic_vector ;
           iData          : In    std_logic_vector ;
           iRid           : In    std_logic_vector ;
           iCid           : In    std_logic_vector ;
           iTag           : In    TagType
  ) ;

  ------------------------------------------------------------
  procedure PcieCompletion (
  -- do PCIe completion (with data) Cycle
  ------------------------------------------------------------
  signal   TransactionRec : InOut AddressBusRecType ;
           iLowAddr       : In    std_logic_vector ;
           iByteCount     : In    integer ;
           iRid           : In    std_logic_vector ;
           iCid           : In    std_logic_vector ;
           iTag           : In    TagType
  ) ;

  ------------------------------------------------------------
  procedure PcieCompletionLock (
  -- do PCIe locked completion (with data) Cycle
  ------------------------------------------------------------
  signal   TransactionRec : InOut AddressBusRecType ;
           iLowAddr       : In    std_logic_vector ;
           iData          : In    std_logic_vector ;
           iRid           : In    std_logic_vector ;
           iCid           : In    std_logic_vector ;
           iTag           : In    TagType
  ) ;

  ------------------------------------------------------------
  procedure PcieCompletionLock (
  -- do PCIe locked completion (with data) Cycle
  ------------------------------------------------------------
  signal   TransactionRec : InOut AddressBusRecType ;
           iLowAddr       : In    std_logic_vector ;
           iByteCount     : In    integer ;
           iRid           : In    std_logic_vector ;
           iCid           : In    std_logic_vector ;
           iTag           : In    TagType
  ) ;

  ------------------------------------------------------------
  procedure PciePartCompletion (
  -- do PCIe part completion (with data) Cycle
  ------------------------------------------------------------
  signal   TransactionRec : InOut AddressBusRecType ;
           iLowAddr       : In    std_logic_vector ;
           iData          : In    std_logic_vector ;
           iRid           : In    std_logic_vector ;
           iCid           : In    std_logic_vector ;
           iRemainingLen  : In    std_logic_vector ;
           iTag           : In    TagType
  ) ;

  ------------------------------------------------------------
  procedure PciePartCompletion (
  -- do PCIe completion (with burst data) Cycle
  ------------------------------------------------------------
  signal   TransactionRec : InOut AddressBusRecType ;
           iLowAddr       : In    std_logic_vector ;
           iByteCount     : In    integer ;
           iRid           : In    std_logic_vector ;
           iCid           : In    std_logic_vector ;
           iRemainingLen  : In    std_logic_vector ;
           iTag           : In    TagType
  ) ;

  ------------------------------------------------------------
  procedure PciePartCompletionLock (
  -- do PCIe locked part completion (with data) Cycle
  ------------------------------------------------------------
  signal   TransactionRec : InOut AddressBusRecType ;
           iLowAddr       : In    std_logic_vector ;
           iData          : In    std_logic_vector ;
           iRid           : In    std_logic_vector ;
           iCid           : In    std_logic_vector ;
           iRemainingLen  : In    std_logic_vector ;
           iTag           : In    TagType
  ) ;

  ------------------------------------------------------------
  procedure PciePartCompletionLock (
  -- do PCIe locked completion (with burst data) Cycle
  ------------------------------------------------------------
  signal   TransactionRec : InOut AddressBusRecType ;
           iLowAddr       : In    std_logic_vector ;
           iByteCount     : In    integer ;
           iRid           : In    std_logic_vector ;
           iCid           : In    std_logic_vector ;
           iRemainingLen  : In    std_logic_vector ;
           iTag           : In    TagType
  ) ;

end package PcieInterfacePkg ;

-- ***********************************************************
-- ************************ B O D Y **************************
-- ***********************************************************

package body PcieInterfacePkg is

  function has_an_x (vec : std_logic_vector) return boolean is
  begin

    for idx in vec'range loop
      case vec(idx) is
        when 'U' | 'X' | 'Z' | 'W' | '-' => return true ;
        when others                      => null ;
      end case;
    end loop;

    return false ;

  end function has_an_x ;

  ------------------------------------------------------------
  procedure PcieMemWrite (
  -- do PCIe Write Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iData          : In    std_logic_vector ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) is
  begin
    SetModelOptions(TransactionRec, SETTRANSMODE, MEM_TRANS) ;
    SetModelOptions(TransactionRec, SETREQTAG,    iTag) ;

    -- Do some memory reads and writes
    Write(TransactionRec, iAddr, iData) ;

  end procedure PcieMemWrite ;

  ------------------------------------------------------------
  procedure PcieMemWrite (
  -- do PCIe Burst Write Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iByteCount     : In    integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) is
  begin
    SetModelOptions(TransactionRec, SETTRANSMODE, MEM_TRANS) ;
    SetModelOptions(TransactionRec, SETREQTAG,    iTag) ;

    -- Do some memory reads and writes
    WriteBurst(TransactionRec, iAddr, iByteCount) ;

  end procedure PcieMemWrite ;

  ------------------------------------------------------------
  procedure PcieMemRead (
  -- do PCIe Read Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             oData          : Out   std_logic_vector ;
             oStatus        : Out   integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) is
  begin

    SetModelOptions(TransactionRec, SETTRANSMODE, MEM_TRANS) ;
    SetModelOptions(TransactionRec, SETREQTAG,    iTag) ;
    SetModelOptions(TransactionRec, SETRDLCK,     0) ;


    Read(TransactionRec, iAddr, oData) ;
    GetModelOptions(TransactionRec, GETLASTCMPLSTATUS, oStatus) ;

  end procedure PcieMemRead ;

  ------------------------------------------------------------
  procedure PcieMemRead (
  -- do PCIe Read Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iByteCount     : In    integer ;
             oStatus        : Out   integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) is
  begin
    SetModelOptions(TransactionRec, SETTRANSMODE, MEM_TRANS) ;
    SetModelOptions(TransactionRec, SETREQTAG,    iTag) ;
    SetModelOptions(TransactionRec, SETRDLCK,     0) ;


    ReadBurst(TransactionRec, iAddr, iByteCount) ;
    GetModelOptions(TransactionRec, GETLASTCMPLSTATUS, oStatus) ;

  end procedure PcieMemRead ;

  ------------------------------------------------------------
  procedure PcieMemReadLock (
  -- do PCIe Memory Read Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             oData          : Out   std_logic_vector ;
             oStatus        : Out   integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) is
  begin

    SetModelOptions(TransactionRec, SETTRANSMODE, MEM_TRANS) ;
    SetModelOptions(TransactionRec, SETREQTAG,    iTag) ;
    SetModelOptions(TransactionRec, SETRDLCK,     1) ;

    Read(TransactionRec, iAddr, oData) ;
    GetModelOptions(TransactionRec, GETLASTCMPLSTATUS, oStatus) ;

  end procedure PcieMemReadLock ;

  ------------------------------------------------------------
  procedure PcieMemReadLock (
  -- do PCIe Read Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iByteCount     : In    integer ;
             oStatus        : Out   integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) is
  begin
    SetModelOptions(TransactionRec, SETTRANSMODE, MEM_TRANS) ;
    SetModelOptions(TransactionRec, SETREQTAG,    iTag) ;
    SetModelOptions(TransactionRec, SETRDLCK,     1) ;


    ReadBurst(TransactionRec, iAddr, iByteCount) ;
    GetModelOptions(TransactionRec, GETLASTCMPLSTATUS, oStatus) ;

  end procedure PcieMemReadLock ;

  ------------------------------------------------------------
  procedure PcieMemReadAddress (
  -- do PCIe Read Address Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iByteCount     : In    integer ;
             iLock          : In    boolean := false ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) is
  begin

    SetModelOptions(TransactionRec, SETTRANSMODE, MEM_TRANS) ;
    SetModelOptions(TransactionRec, SETREQTAG,    iTag) ;
    SetModelOptions(TransactionRec, SETRDLCK,     iLock) ;

    -- Put values in record
    TransactionRec.Operation     <= READ_ADDRESS ;
    TransactionRec.Address       <= SafeResize(iAddr, TransactionRec.Address'length) ;
    TransactionRec.AddrWidth     <= iAddr'length ;
    TransactionRec.DataToModel   <= (TransactionRec.DataToModel'range => 'X') ;
    TransactionRec.DataWidth     <= iByteCount * 8;
    TransactionRec.StatusMsgOn   <= false ;

    -- Start Transaction
    RequestTransaction(Rdy => TransactionRec.Rdy, Ack => TransactionRec.Ack) ;

  end procedure PcieMemReadAddress ;

  ------------------------------------------------------------
  procedure PcieMemReadAddress (
  -- do PCIe Read Address Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iByteCount     : In    integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) is
  begin

    PcieMemReadAddress(TransactionRec, iAddr, iByteCount, false, iTag) ;

  end procedure PcieMemReadAddress ;

  ------------------------------------------------------------
  procedure PcieMemReadLockAddress (
  -- do PCIe Read Address Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iByteCount     : In    integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) is
  begin

    PcieMemReadAddress(TransactionRec, iAddr, iByteCount, true, iTag) ;

  end procedure PcieMemReadLockAddress ;

  ------------------------------------------------------------
  procedure PcieMemReadData (
  -- do PCIe Read Address Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             oData          : Out   std_logic_vector ;
             oStatus        : Out   integer ;
             oTag           : Out   TagType
  ) is
  begin

    SetModelOptions(TransactionRec, SETTRANSMODE, MEM_TRANS) ;

    ReadData(TransactionRec, oData) ;
    GetModelOptions(TransactionRec, GETLASTCMPLSTATUS, oStatus) ;
    GetModelOptions(TransactionRec, GETLASTRXREQTAG,   oTag) ;

  end procedure PcieMemReadData ;

  ------------------------------------------------------------
  procedure PcieCfgSpaceWrite (
  -- do PCIe Write Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iData          : In    std_logic_vector ;
             oStatus        : Out   integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) is
  begin

    SetModelOptions(TransactionRec, SETTRANSMODE, CFG_SPC_TRANS) ;
    SetModelOptions(TransactionRec, SETREQTAG, iTag) ;

    Write(TransactionRec, iAddr, iData) ;
    GetModelOptions(TransactionRec, GETLASTCMPLSTATUS, oStatus) ;

  end procedure PcieCfgSpaceWrite ;

  ------------------------------------------------------------
  procedure PcieCfgSpaceRead (
  -- do PCIe Configuration Space Read Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             oData          : Out   std_logic_vector ;
             oStatus        : Out   integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) is
  begin

    SetModelOptions(TransactionRec, SETTRANSMODE, CFG_SPC_TRANS) ;
    SetModelOptions(TransactionRec, SETREQTAG, iTag) ;

    Read(TransactionRec, iAddr, oData) ;
    GetModelOptions(TransactionRec, GETLASTCMPLSTATUS, oStatus) ;

  end procedure PcieCfgSpaceRead ;

  ------------------------------------------------------------
  procedure PcieIoWrite (
  -- do PCIe Write Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             iData          : In    std_logic_vector ;
             oStatus        : Out   integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) is
  begin

    SetModelOptions(TransactionRec, SETTRANSMODE, IO_TRANS) ;
    SetModelOptions(TransactionRec, SETREQTAG,    iTag) ;

    Write(TransactionRec, iAddr, iData) ;
    GetModelOptions(TransactionRec, GETLASTCMPLSTATUS, oStatus) ;

  end procedure PcieIoWrite ;

  ------------------------------------------------------------
  procedure PcieIoRead (
  -- do PCIe Configuration Space Read Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iAddr          : In    std_logic_vector ;
             oData          : Out   std_logic_vector ;
             oStatus        : Out   integer ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) is
  begin

    SetModelOptions(TransactionRec, SETTRANSMODE, IO_TRANS) ;
    SetModelOptions(TransactionRec, SETREQTAG,    iTag) ;

    Read(TransactionRec, iAddr, oData) ;
    GetModelOptions(TransactionRec, GETLASTCMPLSTATUS, oStatus) ;

  end procedure PcieIoRead ;

  ------------------------------------------------------------
  procedure PcieMessageWrite (
  -- do PCIe message (no data) Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iMsgType       : In    std_logic_vector ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) is
  begin
    SetModelOptions(TransactionRec, SETTRANSMODE, MSG_TRANS) ;
    SetModelOptions(TransactionRec, SETREQTAG,    iTag) ;

    -- Do some memory reads and writes
    WriteAddressAsync(TransactionRec, iMsgType) ;

  end procedure PcieMessageWrite ;

  ------------------------------------------------------------
  procedure PcieMessageWrite (
  -- do PCIe message (with data) Cycle
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
             iMsgType       : In    std_logic_vector ;
             iMsgData       : In    std_logic_vector ;
             iTag           : In    TagType := TLP_TAG_AUTO
  ) is
  begin
    SetModelOptions(TransactionRec, SETTRANSMODE, MSG_TRANS) ;
    SetModelOptions(TransactionRec, SETREQTAG,    iTag) ;

    -- Do some memory reads and writes
    Write(TransactionRec, iMsgType, iMsgData) ;

  end procedure PcieMessageWrite ;

  ------------------------------------------------------------
  procedure PcieCompletion (
  -- do PCIe completion (with data) Cycle
  ------------------------------------------------------------
  signal   TransactionRec : InOut AddressBusRecType ;
           iLowAddr       : In    std_logic_vector ;
           iData          : In    std_logic_vector ;
           iRid           : In    std_logic_vector ;
           iCid           : In    std_logic_vector ;
           iTag           : In    TagType
  ) is
  begin

    SetModelOptions(TransactionRec, SETTRANSMODE, CPL_TRANS) ;
    SetModelOptions(TransactionRec, SETCMPLRID,   iRid) ;
    SetModelOptions(TransactionRec, SETCMPLCID,   iCid) ;
    SetModelOptions(TransactionRec, SETCMPLTAG,   iTag) ;
    SetModelOptions(TransactionRec, SETRDLCK,     0) ;

    Write(TransactionRec, iLowAddr, iData) ;

  end procedure PcieCompletion ;

  ------------------------------------------------------------
  procedure PcieCompletion (
  -- do PCIe completion (with burst data) Cycle
  ------------------------------------------------------------
  signal   TransactionRec : InOut AddressBusRecType ;
           iLowAddr       : In    std_logic_vector ;
           iByteCount     : In    integer ;
           iRid           : In    std_logic_vector ;
           iCid           : In    std_logic_vector ;
           iTag           : In    TagType
  ) is
  begin

    SetModelOptions(TransactionRec, SETTRANSMODE, CPL_TRANS) ;
    SetModelOptions(TransactionRec, SETCMPLRID,   iRid) ;
    SetModelOptions(TransactionRec, SETCMPLCID,   iCid) ;
    SetModelOptions(TransactionRec, SETCMPLTAG,   iTag) ;
    SetModelOptions(TransactionRec, SETRDLCK,     0) ;

    WriteBurst(TransactionRec, iLowAddr, iByteCount) ;

  end procedure PcieCompletion ;

  ------------------------------------------------------------
  procedure PcieCompletionLock (
  -- do PCIe locked completion (with data) Cycle
  ------------------------------------------------------------
  signal   TransactionRec : InOut AddressBusRecType ;
           iLowAddr       : In    std_logic_vector ;
           iData          : In    std_logic_vector ;
           iRid           : In    std_logic_vector ;
           iCid           : In    std_logic_vector ;
           iTag           : In    TagType
  ) is
  begin

    SetModelOptions(TransactionRec, SETTRANSMODE, CPL_TRANS) ;
    SetModelOptions(TransactionRec, SETCMPLRID,   iRid) ;
    SetModelOptions(TransactionRec, SETCMPLCID,   iCid) ;
    SetModelOptions(TransactionRec, SETCMPLTAG,   iTag) ;
    SetModelOptions(TransactionRec, SETRDLCK,     1) ;

    Write(TransactionRec, iLowAddr, iData) ;

  end procedure PcieCompletionLock ;

  ------------------------------------------------------------
  procedure PcieCompletionLock (
  -- do PCIe locked completion (with burst data) Cycle
  ------------------------------------------------------------
  signal   TransactionRec : InOut AddressBusRecType ;
           iLowAddr       : In    std_logic_vector ;
           iByteCount     : In    integer ;
           iRid           : In    std_logic_vector ;
           iCid           : In    std_logic_vector ;
           iTag           : In    TagType
  ) is
  begin

    SetModelOptions(TransactionRec, SETTRANSMODE, CPL_TRANS) ;
    SetModelOptions(TransactionRec, SETCMPLRID,   iRid) ;
    SetModelOptions(TransactionRec, SETCMPLCID,   iCid) ;
    SetModelOptions(TransactionRec, SETCMPLTAG,   iTag) ;
    SetModelOptions(TransactionRec, SETRDLCK,     1) ;

    WriteBurst(TransactionRec, iLowAddr, iByteCount) ;

  end procedure PcieCompletionLock ;

  ------------------------------------------------------------
  procedure PciePartCompletion (
  -- do PCIe completion (with data) Cycle
  ------------------------------------------------------------
  signal   TransactionRec : InOut AddressBusRecType ;
           iLowAddr       : In    std_logic_vector ;
           iData          : In    std_logic_vector ;
           iRid           : In    std_logic_vector ;
           iCid           : In    std_logic_vector ;
           iRemainingLen  : In    std_logic_vector ;
           iTag           : In    TagType
  ) is
  begin

    SetModelOptions(TransactionRec, SETTRANSMODE, PART_CPL_TRANS) ;
    SetModelOptions(TransactionRec, SETCMPLRID,   iRid) ;
    SetModelOptions(TransactionRec, SETCMPLCID,   iCid) ;
    SetModelOptions(TransactionRec, SETCMPLRLEN,  iRemainingLen) ;
    SetModelOptions(TransactionRec, SETCMPLTAG,   iTag) ;
    SetModelOptions(TransactionRec, SETRDLCK,     0) ;

    Write(TransactionRec, iLowAddr, iData) ;

  end procedure PciePartCompletion ;

  ------------------------------------------------------------
  procedure PciePartCompletion (
  -- do PCIe completion (with burst data) Cycle
  ------------------------------------------------------------
  signal   TransactionRec : InOut AddressBusRecType ;
           iLowAddr       : In    std_logic_vector ;
           iByteCount     : In    integer ;
           iRid           : In    std_logic_vector ;
           iCid           : In    std_logic_vector ;
           iRemainingLen  : In    std_logic_vector ;
           iTag           : In    TagType
  ) is
  begin

    SetModelOptions(TransactionRec, SETTRANSMODE, PART_CPL_TRANS) ;
    SetModelOptions(TransactionRec, SETCMPLRID,   iRid) ;
    SetModelOptions(TransactionRec, SETCMPLCID,   iCid) ;
    SetModelOptions(TransactionRec, SETCMPLRLEN,  iRemainingLen) ;
    SetModelOptions(TransactionRec, SETCMPLTAG,   iTag) ;
    SetModelOptions(TransactionRec, SETRDLCK,     0) ;

    WriteBurst(TransactionRec, iLowAddr, iByteCount) ;

  end procedure PciePartCompletion ;

  ------------------------------------------------------------
  procedure PciePartCompletionLock (
  -- do PCIe locked completion (with data) Cycle
  ------------------------------------------------------------
  signal   TransactionRec : InOut AddressBusRecType ;
           iLowAddr       : In    std_logic_vector ;
           iData          : In    std_logic_vector ;
           iRid           : In    std_logic_vector ;
           iCid           : In    std_logic_vector ;
           iRemainingLen  : In    std_logic_vector ;
           iTag           : In    TagType
  ) is
  begin

    SetModelOptions(TransactionRec, SETTRANSMODE, PART_CPL_TRANS) ;
    SetModelOptions(TransactionRec, SETCMPLRID,   iRid) ;
    SetModelOptions(TransactionRec, SETCMPLCID,   iCid) ;
    SetModelOptions(TransactionRec, SETCMPLRLEN,  iRemainingLen) ;
    SetModelOptions(TransactionRec, SETCMPLTAG,   iTag) ;
    SetModelOptions(TransactionRec, SETRDLCK,     1) ;

    Write(TransactionRec, iLowAddr, iData) ;

  end procedure PciePartCompletionLock ;

  ------------------------------------------------------------
  procedure PciePartCompletionLock (
  -- do PCIe locked completion (with burst data) Cycle
  ------------------------------------------------------------
  signal   TransactionRec : InOut AddressBusRecType ;
           iLowAddr       : In    std_logic_vector ;
           iByteCount     : In    integer ;
           iRid           : In    std_logic_vector ;
           iCid           : In    std_logic_vector ;
           iRemainingLen  : In    std_logic_vector ;
           iTag           : In    TagType
  ) is
  begin

    SetModelOptions(TransactionRec, SETTRANSMODE, PART_CPL_TRANS) ;
    SetModelOptions(TransactionRec, SETCMPLRID,   iRid) ;
    SetModelOptions(TransactionRec, SETCMPLCID,   iCid) ;
    SetModelOptions(TransactionRec, SETCMPLRLEN,  iRemainingLen) ;
    SetModelOptions(TransactionRec, SETCMPLTAG,   iTag) ;
    SetModelOptions(TransactionRec, SETRDLCK,     1) ;

    WriteBurst(TransactionRec, iLowAddr, iByteCount) ;

  end procedure PciePartCompletionLock ;

end package body PcieInterfacePkg ;

