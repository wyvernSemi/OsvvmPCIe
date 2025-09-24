
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
  
 end package PcieOptionsPkg ;