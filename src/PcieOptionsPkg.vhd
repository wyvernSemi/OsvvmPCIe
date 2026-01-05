--
--  File Name:         PcieOptionsPkg.vhd
--  Design Unit Name:  PcieOptionsPkg
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
--    09/2025   2026.01    Initial revision
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2025 by [OSVVM Authors](../../../AUTHORS.md).
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

library osvvm ;
    context osvvm.OsvvmContext ;

library OSVVM_Common ;
    context OSVVM_Common.OsvvmCommonContext ;

package PcieOptionsPkg is

  -- Must match the definitions in pcie.h (prefixed with CONFIG_)
  type PcieUnresolvedOptionsType is (

    FC_HDR_RATE,
    FC_DATA_RATE,

    -- Enables even, disables odd
    ENABLE_FC,
    DISABLE_FC,

    ENABLE_ACK,
    DISABLE_ACK,

    ENABLE_MEM,
    DISABLE_MEM,

    ENABLE_SKIPS,
    DISABLE_SKIPS,

    ENABLE_UR_CPL,
    DISABLE_UR_CPL,

    POST_HDR_CR,
    POST_DATA_CR,

    NONPOST_HDR_CR,
    NONPOST_DATA_CR,

    CPL_HDR_CR,
    CPL_DATA_CR,

    CPL_DELAY_RATE,
    CPL_DELAY_SPREAD,

    -- Used if LTSSM present
    LTSSM_LINKNUM,
    LTSSM_N_FTS,
    LTSSM_TS_CTL,
    LTSSM_DETECT_QUIET_TO,
    LTSSM_ENABLE_TESTS,
    LTSSM_FORCE_TESTS,
    LTSSM_POLL_ACTIVE_TX_COUNT,

    --- Enables even, disables odd
    DISABLE_SCRAMBLING,
    ENABLE_SCRAMBLING,

    DISABLE_8B10B,
    ENABLE_8B10B,

    DISABLE_ECRC_CMPL,
    ENABLE_ECRC_CMPL

  ) ;

  type PcieUnresolvedOptionsVectorType is array (natural range <>) of PcieUnresolvedOptionsType ;
  function resolved_max(A : PcieUnresolvedOptionsVectorType) return PcieUnresolvedOptionsType ;

  subtype PcieOptionsType is resolved_max PcieUnresolvedOptionsType ;

  ------------------------------------------------------------
  procedure SetPcieOptions (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    PcieOptionsType ;
    constant OptVal         : In    integer
  ) ;

  ------------------------------------------------------------
  procedure GetPcieOptions (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    PcieOptionsType ;
    variable OptVal         : Out   integer
  ) ;

 end package PcieOptionsPkg ;

-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////

 package body PcieOptionsPkg is

  function resolved_max(A : PcieUnresolvedOptionsVectorType) return PcieUnresolvedOptionsType is
  begin
    return maximum(A) ;
  end function resolved_max ;

   ------------------------------------------------------------
  procedure SetPcieOptions (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    PcieOptionsType ;
    constant OptVal         : In    integer
  ) is
  begin
    SetModelOptions(TransactionRec, PcieOptionsType'POS(Option), OptVal) ;
  end procedure SetPcieOptions ;

   ------------------------------------------------------------
  procedure GetPcieOptions (
  ------------------------------------------------------------
    signal   TransactionRec : InOut AddressBusRecType ;
    constant Option         : In    PcieOptionsType ;
    variable OptVal         : Out   integer
  ) is
  begin
    GetModelOptions(TransactionRec, PcieOptionsType'POS(Option), OptVal) ;
  end procedure GetPcieOptions ;

 end package body PcieOptionsPkg ;