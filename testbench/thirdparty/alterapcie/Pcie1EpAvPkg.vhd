--
--  File Name:         Pcie1EpAvPkg.vhd
--  Design Unit Name:  Pcie1EpAvPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Simon Southwell email:  simon.southwell@gmail.com
--  Contributor(s):
--     Simon Southwell simon.southwell@gmail.com
--
--
--  Description:
--      Package for Altera PCIe Components
--
--
--  Revision History:
--    Date      Version    Description
--    01/2026   2026.01       Initial revision
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library osvvm ;
  context osvvm.OsvvmContext ;

library OSVVM_Common ;
  context OSVVM_Common.OsvvmCommonContext ;

library osvvm_axi4 ;
  context osvvm_axi4.Axi4LiteContext ;


package Pcie1EpAvPkg is

    type AvMemMappedMasterRecType is record

        Address            : std_logic_vector ;
        Read               : std_logic ;
        WaitRequest        : std_logic ;
        Write              : std_logic ;
        ReadDataValid      : std_logic ;
        ReadData           : std_logic_vector ;
        WriteData          : std_logic_vector ;
        ByteEnable         : std_logic_vector ;

    end record AvMemMappedMasterRecType ;

    type PipeRecType is record

        -- Transmit signals
        TxData             : std_logic_vector(7 downto 0) ;
        TxDataK            : std_logic ;

        TxDetectRx         : std_logic ;
        TxElecIdle         : std_logic ;
        TxCompliance       : std_logic;
        RxPolarity         : std_logic ;
        PowerDown          : std_logic_vector(1 downto 0) ;
        Rate               : std_logic_vector(1 downto 0) ;
        TxDemph            : std_logic ;
        TxMargin           : std_logic_vector(2 downto 0) ;
        TxSwing            : std_logic;

        -- Receive signals
        RxData             : std_logic_vector(7 downto 0) ;
        RxDataK            : std_logic ;
        RxValid            : std_logic ;
        RxElecIdle         : std_logic ;
        RxStatus           : std_logic_vector(2 downto 0) ;
        PhyStatus          : std_logic ;

    end record PipeRecType ;

    component Pcie1EpAxi4Lite is
    port (
      RefClk               : in    std_logic ;
      PipeClk              : in    std_logic ;
      nReset               : in    std_logic ;

      -- AXI4-Lite memory mapped master
      AxiBus               : inout Axi4LiteRecType ;

      -- PIPE lane 0
      Pipe0                : inout PipeRecType

    ) ;
    end component Pcie1EpAxi4Lite ;

    component Pcie1EpAvmm is
    port (
      RefClk               : in    std_logic ;
      PipeClk              : in    std_logic ;
      nReset               : in    std_logic ;

      Bar0Address          : out   std_logic_vector (31 downto 0) ;
      Bar0Read             : out   std_logic ;
      Bar0WaitRequest      : out   std_logic ;
      Bar0Write            : out   std_logic ;
      Bar0ReadDataValid    : in    std_logic ;
      Bar0ReadData         : in    std_logic_vector (31 downto 0) ;
      Bar0WriteData        : out   std_logic_vector (31 downto 0) ;
      Bar0ByteEnable       : out   std_logic_vector  (3 downto 0) ;

      Bar1Address          : out   std_logic_vector (31 downto 0) ;
      Bar1Read             : out   std_logic ;
      Bar1WaitRequest      : out   std_logic ;
      Bar1Write            : out   std_logic ;
      Bar1ReadDataValid    : in    std_logic ;
      Bar1ReadData         : in    std_logic_vector (31 downto 0) ;
      Bar1WriteData        : out   std_logic_vector (31 downto 0) ;
      Bar1ByteEnable       : out   std_logic_vector  (3 downto 0) ;

      TxData               : out   std_logic_vector  (7 downto 0) ;
      TxDataK              : out   std_logic ;

      TxDetectRx           : out   std_logic ;
      TxElecIdle           : out   std_logic ;
      TxCompliance         : out   std_logic ;
      RxPolarity           : out   std_logic ;
      PowerDown            : out   std_logic_vector  (1 downto 0) ;
      Rate                 : out   std_logic_vector  (1 downto 0) ;
      TxDemph              : out   std_logic ;
      TxMargin             : out   std_logic_vector  (2 downto 0) ;
      TxSwing              : out   std_logic ;

      RxData               : in    std_logic_vector  (7 downto 0) ;
      RxDataK              : in    std_logic ;
      RxValid              : in    std_logic ;
      RxElecIdle           : in    std_logic ;
      RxStatus             : in    std_logic_vector  (2 downto 0) ;
      PhyStatus            : in    std_logic ;

      LtssmState           : out   std_logic_vector  (4 downto 0) ;
      EidleInferSel        : out   std_logic_vector  (2 downto 0)

    ) ;
    end component Pcie1EpAvmm ;

    component Pcie1EpAvmmVhdl is
    port (
      RefClk               : in    std_logic ;
      PipeClk              : in    std_logic ;
      nReset               : in    std_logic ;

      -- BAR0 Avalon memory mapped master
      BAR0                 : inout AvMemMappedMasterRecType ;

      -- BAR1 Avalon memory mapped master
      BAR1                 : inout AvMemMappedMasterRecType ;

      -- PIPE lane 0
      Pipe0                : inout PipeRecType

    ) ;
    end component Pcie1EpAvmmVhdl ;

    component altpcie_cv_hip_avmm_hwtcl_x is
        generic (
            lane_mask_hwtcl                          : string  := "x4";
            gen123_lane_rate_mode_hwtcl              : string  := "Gen1 (2.5 Gbps)";
            port_type_hwtcl                          : string  := "Native endpoint";
            pcie_spec_version_hwtcl                  : string  := "2.1";
            pll_refclk_freq_hwtcl                    : string  := "100 MHz";
            set_pld_clk_x1_625MHz_hwtcl              : integer := 0;
            in_cvp_mode_hwtcl                        : integer := 0;
            bar0_size_mask_hwtcl                     : integer := 28;
            bar0_io_space_hwtcl                      : string  := "Disabled";
            bar0_64bit_mem_space_hwtcl               : string  := "Enabled";
            bar0_prefetchable_hwtcl                  : string  := "Enabled";
            bar1_size_mask_hwtcl                     : integer := 0;
            bar1_io_space_hwtcl                      : string  := "Disabled";
            bar1_prefetchable_hwtcl                  : string  := "Disabled";
            bar2_size_mask_hwtcl                     : integer := 0;
            bar2_io_space_hwtcl                      : string  := "Disabled";
            bar2_64bit_mem_space_hwtcl               : string  := "Disabled";
            bar2_prefetchable_hwtcl                  : string  := "Disabled";
            bar3_size_mask_hwtcl                     : integer := 0;
            bar3_io_space_hwtcl                      : string  := "Disabled";
            bar3_prefetchable_hwtcl                  : string  := "Disabled";
            bar4_size_mask_hwtcl                     : integer := 0;
            bar4_io_space_hwtcl                      : string  := "Disabled";
            bar4_64bit_mem_space_hwtcl               : string  := "Disabled";
            bar4_prefetchable_hwtcl                  : string  := "Disabled";
            bar5_size_mask_hwtcl                     : integer := 0;
            bar5_io_space_hwtcl                      : string  := "Disabled";
            bar5_prefetchable_hwtcl                  : string  := "Disabled";
            CB_P2A_AVALON_ADDR_B0                    : integer := 0;
            CB_P2A_AVALON_ADDR_B1                    : integer := 0;
            CB_P2A_AVALON_ADDR_B2                    : integer := 0;
            CB_P2A_AVALON_ADDR_B3                    : integer := 0;
            CB_P2A_AVALON_ADDR_B4                    : integer := 0;
            CB_P2A_AVALON_ADDR_B5                    : integer := 0;
            vendor_id_hwtcl                          : integer := 0;
            device_id_hwtcl                          : integer := 1;
            revision_id_hwtcl                        : integer := 1;
            class_code_hwtcl                         : integer := 0;
            subsystem_vendor_id_hwtcl                : integer := 0;
            subsystem_device_id_hwtcl                : integer := 0;
            max_payload_size_hwtcl                   : integer := 128;
            extend_tag_field_hwtcl                   : string  := "32";
            completion_timeout_hwtcl                 : string  := "ABCD";
            enable_completion_timeout_disable_hwtcl  : integer := 1;
            use_aer_hwtcl                            : integer := 0;
            ecrc_check_capable_hwtcl                 : integer := 0;
            ecrc_gen_capable_hwtcl                   : integer := 0;
            use_crc_forwarding_hwtcl                 : integer := 0;
            port_link_number_hwtcl                   : integer := 1;
            dll_active_report_support_hwtcl          : integer := 0;
            surprise_down_error_support_hwtcl        : integer := 0;
            slotclkcfg_hwtcl                         : integer := 1;
            msi_multi_message_capable_hwtcl          : string  := "4";
            msi_64bit_addressing_capable_hwtcl       : string  := "true";
            msi_masking_capable_hwtcl                : string  := "false";
            msi_support_hwtcl                        : string  := "true";
            enable_function_msix_support_hwtcl       : integer := 0;
            msix_table_size_hwtcl                    : integer := 0;
            msix_table_offset_hwtcl                  : string  := "0";
            msix_table_bir_hwtcl                     : integer := 0;
            msix_pba_offset_hwtcl                    : string  := "0";
            msix_pba_bir_hwtcl                       : integer := 0;
            enable_slot_register_hwtcl               : integer := 0;
            slot_power_scale_hwtcl                   : integer := 0;
            slot_power_limit_hwtcl                   : integer := 0;
            slot_number_hwtcl                        : integer := 0;
            rx_ei_l0s_hwtcl                          : integer := 0;
            endpoint_l0_latency_hwtcl                : integer := 0;
            endpoint_l1_latency_hwtcl                : integer := 0;
            vsec_id_hwtcl                            : integer := 4466;
            vsec_rev_hwtcl                           : integer := 0;
            user_id_hwtcl                            : integer := 0;
            avmm_width_hwtcl                         : integer := 64;
            AVALON_ADDR_WIDTH                        : integer := 32;
            avmm_burst_width_hwtcl                   : integer := 7;
            CB_PCIE_MODE                             : integer := 0;
            CB_PCIE_RX_LITE                          : integer := 0;
            CB_RXM_DATA_WIDTH                        : integer := 64;
            CG_AVALON_S_ADDR_WIDTH                   : integer := 20;
            CG_IMPL_CRA_AV_SLAVE_PORT                : integer := 1;
            CG_ENABLE_ADVANCED_INTERRUPT             : integer := 0;
            CG_ENABLE_A2P_INTERRUPT                  : integer := 0;
            CB_A2P_ADDR_MAP_IS_FIXED                 : integer := 0;
            CB_A2P_ADDR_MAP_NUM_ENTRIES              : integer := 2;
            BYPASSS_A2P_TRANSLATION                  : integer := 0;
            a2p_pass_thru_bits                       : integer := 20;
            ast_width_hwtcl                          : string  := "Avalon-ST 64-bit";
            use_ast_parity                           : integer := 0;
            reconfig_to_xcvr_width                   : integer := 10;
            hip_hard_reset_hwtcl                     : integer := 0;
            reconfig_from_xcvr_width                 : integer := 10;
            bypass_cdc_hwtcl                         : string  := "false";
            single_rx_detect_hwtcl                   : integer := 0;
            wrong_device_id_hwtcl                    : string  := "disable";
            data_pack_rx_hwtcl                       : string  := "disable";
            ltssm_1ms_timeout_hwtcl                  : string  := "disable";
            ltssm_freqlocked_check_hwtcl             : string  := "disable";
            deskew_comma_hwtcl                       : string  := "skp_eieos_deskw";
            maximum_current_hwtcl                    : integer := 0;
            disable_snoop_packet_hwtcl               : string  := "false";
            enable_l0s_aspm_hwtcl                    : string  := "true";
            extended_tag_reset_hwtcl                 : string  := "false";
            interrupt_pin_hwtcl                      : string  := "inta";
            bridge_port_vga_enable_hwtcl             : string  := "false";
            bridge_port_ssid_support_hwtcl           : string  := "false";
            ssvid_hwtcl                              : integer := 0;
            ssid_hwtcl                               : integer := 0;
            aspm_config_management_hwtcl             : string  := "false";
            atomic_op_routing_hwtcl                  : string  := "false";
            atomic_op_completer_32bit_hwtcl          : string  := "false";
            atomic_op_completer_64bit_hwtcl          : string  := "false";
            cas_completer_128bit_hwtcl               : string  := "false";
            ltr_mechanism_hwtcl                      : string  := "false";
            tph_completer_hwtcl                      : string  := "false";
            extended_format_field_hwtcl              : string  := "true";
            atomic_malformed_hwtcl                   : string  := "true";
            flr_capability_hwtcl                     : integer := 0;
            enable_adapter_half_rate_mode_hwtcl      : string  := "false";
            skp_os_gen3_count_hwtcl                  : integer := 0;
            millisecond_cycle_count_hwtcl            : integer := 124250;
            credit_buffer_allocation_aux_hwtcl       : string  := "balanced";
            vc0_rx_flow_ctrl_posted_header_hwtcl     : integer := 50;
            vc0_rx_flow_ctrl_posted_data_hwtcl       : integer := 360;
            vc0_rx_flow_ctrl_nonposted_header_hwtcl  : integer := 54;
            vc0_rx_flow_ctrl_nonposted_data_hwtcl    : integer := 0;
            vc0_rx_flow_ctrl_compl_header_hwtcl      : integer := 112;
            vc0_rx_flow_ctrl_compl_data_hwtcl        : integer := 448;
            cpl_spc_header_hwtcl                     : integer := 112;
            cpl_spc_data_hwtcl                       : integer := 448;
            coreclkout_hip_phaseshift_hwtcl          : string  := "0 ps";
            pldclk_hip_phase_shift_hwtcl             : string  := "0 ps";
            port_width_be_hwtcl                      : integer := 8;
            port_width_data_hwtcl                    : integer := 64;
            hip_reconfig_hwtcl                       : integer := 0;
            gen3_rxfreqlock_counter_hwtcl            : integer := 0;
            gen3_skip_ph2_ph3_hwtcl                  : integer := 0;
            g3_bypass_equlz_hwtcl                    : integer := 0;
            expansion_base_address_register_hwtcl    : integer := 0;
            prefetchable_mem_window_addr_width_hwtcl : integer := 0;
            bypass_clk_switch_hwtcl                  : string  := "disable";
            cvp_rate_sel_hwtcl                       : string  := "full_rate";
            cvp_data_compressed_hwtcl                : string  := "false";
            cvp_data_encrypted_hwtcl                 : string  := "false";
            cvp_mode_reset_hwtcl                     : string  := "false";
            cvp_clk_reset_hwtcl                      : string  := "false";
            core_clk_sel_hwtcl                       : string  := "pld_clk";
            enable_rx_buffer_checking_hwtcl          : string  := "false";
            disable_link_x2_support_hwtcl            : string  := "false";
            device_number_hwtcl                      : integer := 0;
            pipex1_debug_sel_hwtcl                   : string  := "disable";
            pclk_out_sel_hwtcl                       : string  := "pclk";
            no_soft_reset_hwtcl                      : string  := "false";
            d1_support_hwtcl                         : string  := "false";
            d2_support_hwtcl                         : string  := "false";
            d0_pme_hwtcl                             : string  := "false";
            d1_pme_hwtcl                             : string  := "false";
            d2_pme_hwtcl                             : string  := "false";
            d3_hot_pme_hwtcl                         : string  := "false";
            d3_cold_pme_hwtcl                        : string  := "false";
            low_priority_vc_hwtcl                    : string  := "single_vc";
            enable_l1_aspm_hwtcl                     : string  := "false";
            l1_exit_latency_sameclock_hwtcl          : integer := 0;
            l1_exit_latency_diffclock_hwtcl          : integer := 0;
            hot_plug_support_hwtcl                   : integer := 0;
            no_command_completed_hwtcl               : string  := "false";
            eie_before_nfts_count_hwtcl              : integer := 4;
            gen2_diffclock_nfts_count_hwtcl          : integer := 255;
            gen2_sameclock_nfts_count_hwtcl          : integer := 255;
            deemphasis_enable_hwtcl                  : string  := "false";
            l0_exit_latency_sameclock_hwtcl          : integer := 6;
            l0_exit_latency_diffclock_hwtcl          : integer := 6;
            vc0_clk_enable_hwtcl                     : string  := "true";
            register_pipe_signals_hwtcl              : string  := "true";
            tx_cdc_almost_empty_hwtcl                : integer := 5;
            rx_l0s_count_idl_hwtcl                   : integer := 0;
            cdc_dummy_insert_limit_hwtcl             : integer := 11;
            ei_delay_powerdown_count_hwtcl           : integer := 10;
            skp_os_schedule_count_hwtcl              : integer := 0;
            fc_init_timer_hwtcl                      : integer := 1024;
            l01_entry_latency_hwtcl                  : integer := 31;
            flow_control_update_count_hwtcl          : integer := 30;
            flow_control_timeout_count_hwtcl         : integer := 200;
            retry_buffer_last_active_address_hwtcl   : integer := 255;
            reserved_debug_hwtcl                     : integer := 0;
            use_tl_cfg_sync_hwtcl                    : integer := 1;
            diffclock_nfts_count_hwtcl               : integer := 255;
            sameclock_nfts_count_hwtcl               : integer := 255;
            l2_async_logic_hwtcl                     : string  := "disable";
            rx_cdc_almost_full_hwtcl                 : integer := 12;
            tx_cdc_almost_full_hwtcl                 : integer := 11;
            indicator_hwtcl                          : integer := 0;
            rpre_emph_a_val_hwtcl                    : integer := 11;
            rpre_emph_b_val_hwtcl                    : integer := 0;
            rpre_emph_c_val_hwtcl                    : integer := 22;
            rpre_emph_d_val_hwtcl                    : integer := 12;
            rpre_emph_e_val_hwtcl                    : integer := 21;
            rvod_sel_a_val_hwtcl                     : integer := 50;
            rvod_sel_b_val_hwtcl                     : integer := 34;
            rvod_sel_c_val_hwtcl                     : integer := 50;
            rvod_sel_d_val_hwtcl                     : integer := 50;
            rvod_sel_e_val_hwtcl                     : integer := 9
        );
        port (
            coreclkout           : out std_logic;                                         -- clk
            refclk               : in  std_logic                      := 'X';             -- clk

            npor                 : in  std_logic                      := 'X';             -- npor
            pin_perst            : in  std_logic                      := 'X';             -- pin_perst
            reset_status         : out std_logic;                                         -- reset_n

            test_in              : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- test_in
            simu_mode_pipe       : in  std_logic                      := 'X';             -- simu_mode_pipe

            RxmAddress_0_o       : out std_logic_vector(31 downto 0);                     -- address
            RxmRead_0_o          : out std_logic;                                         -- read
            RxmWaitRequest_0_i   : in  std_logic                      := 'X';             -- waitrequest
            RxmWrite_0_o         : out std_logic;                                         -- write
            RxmReadDataValid_0_i : in  std_logic                      := 'X';             -- readdatavalid
            RxmReadData_0_i      : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- readdata
            RxmWriteData_0_o     : out std_logic_vector(31 downto 0);                     -- writedata
            RxmByteEnable_0_o    : out std_logic_vector(3 downto 0);                      -- byteenable

            RxmAddress_1_o       : out std_logic_vector(31 downto 0);                     -- address
            RxmRead_1_o          : out std_logic;                                         -- read
            RxmWaitRequest_1_i   : in  std_logic                      := 'X';             -- waitrequest
            RxmWrite_1_o         : out std_logic;                                         -- write
            RxmReadDataValid_1_i : in  std_logic                      := 'X';             -- readdatavalid
            RxmReadData_1_i      : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- readdata
            RxmWriteData_1_o     : out std_logic_vector(31 downto 0);                     -- writedata
            RxmByteEnable_1_o    : out std_logic_vector(3 downto 0);                      -- byteenable

            reconfig_to_xcvr     : in  std_logic_vector(139 downto 0) := (others => 'X'); -- reconfig_to_xcvr
            busy_xcvr_reconfig   : in  std_logic                      := 'X';             -- reconfig_busy
            reconfig_from_xcvr   : out std_logic_vector(91 downto 0);                     -- reconfig_from_xcvr
            fixedclk_locked      : out std_logic;                                         -- fixedclk_locked

            rx_in0               : in  std_logic                      := 'X';             -- rx_in0
            tx_out0              : out std_logic;                                         -- tx_out0

            sim_pipe_pclk_in     : in  std_logic                      := 'X';             -- sim_pipe_pclk_in
            sim_pipe_rate        : out std_logic_vector(1 downto 0);                      -- sim_pipe_rate
            sim_ltssmstate       : out std_logic_vector(4 downto 0);                      -- sim_ltssmstate
            eidleinfersel0       : out std_logic_vector(2 downto 0);                      -- eidleinfersel0
            powerdown0           : out std_logic_vector(1 downto 0);                      -- powerdown0
            rxpolarity0          : out std_logic;                                         -- rxpolarity0
            txcompl0             : out std_logic;                                         -- txcompl0
            txdata0              : out std_logic_vector(7 downto 0);                      -- txdata0
            txdatak0             : out std_logic;                                         -- txdatak0
            txdetectrx0          : out std_logic;                                         -- txdetectrx0
            txelecidle0          : out std_logic;                                         -- txelecidle0
            txswing0             : out std_logic;                                         -- txswing0
            txmargin0            : out std_logic_vector(2 downto 0);                      -- txmargin0
            txdeemph0            : out std_logic;                                         -- txdeemph0
            phystatus0           : in  std_logic                      := 'X';             -- phystatus0
            rxdata0              : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- rxdata0
            rxdatak0             : in  std_logic                      := 'X';             -- rxdatak0
            rxelecidle0          : in  std_logic                      := 'X';             -- rxelecidle0
            rxstatus0            : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- rxstatus0
            rxvalid0             : in  std_logic                      := 'X';             -- rxvalid0

            rx_in1               : in  std_logic                      := 'X';             -- rx_in1
            rx_in2               : in  std_logic                      := 'X';             -- rx_in2
            rx_in3               : in  std_logic                      := 'X';             -- rx_in3
            rx_in4               : in  std_logic                      := 'X';             -- rx_in4
            rx_in5               : in  std_logic                      := 'X';             -- rx_in5
            rx_in6               : in  std_logic                      := 'X';             -- rx_in6
            rx_in7               : in  std_logic                      := 'X';             -- rx_in7
            tx_out1              : out std_logic;                                         -- tx_out1
            tx_out2              : out std_logic;                                         -- tx_out2
            tx_out3              : out std_logic;                                         -- tx_out3
            tx_out4              : out std_logic;                                         -- tx_out4
            tx_out5              : out std_logic;                                         -- tx_out5
            tx_out6              : out std_logic;                                         -- tx_out6
            tx_out7              : out std_logic;                                         -- tx_out7
            eidleinfersel1       : out std_logic_vector(2 downto 0);                      -- eidleinfersel1
            eidleinfersel2       : out std_logic_vector(2 downto 0);                      -- eidleinfersel2
            eidleinfersel3       : out std_logic_vector(2 downto 0);                      -- eidleinfersel3
            eidleinfersel4       : out std_logic_vector(2 downto 0);                      -- eidleinfersel4
            eidleinfersel5       : out std_logic_vector(2 downto 0);                      -- eidleinfersel5
            eidleinfersel6       : out std_logic_vector(2 downto 0);                      -- eidleinfersel6
            eidleinfersel7       : out std_logic_vector(2 downto 0);                      -- eidleinfersel7
            powerdown1           : out std_logic_vector(1 downto 0);                      -- powerdown1
            powerdown2           : out std_logic_vector(1 downto 0);                      -- powerdown2
            powerdown3           : out std_logic_vector(1 downto 0);                      -- powerdown3
            powerdown4           : out std_logic_vector(1 downto 0);                      -- powerdown4
            powerdown5           : out std_logic_vector(1 downto 0);                      -- powerdown5
            powerdown6           : out std_logic_vector(1 downto 0);                      -- powerdown6
            powerdown7           : out std_logic_vector(1 downto 0);                      -- powerdown7
            rxpolarity1          : out std_logic;                                         -- rxpolarity1
            rxpolarity2          : out std_logic;                                         -- rxpolarity2
            rxpolarity3          : out std_logic;                                         -- rxpolarity3
            rxpolarity4          : out std_logic;                                         -- rxpolarity4
            rxpolarity5          : out std_logic;                                         -- rxpolarity5
            rxpolarity6          : out std_logic;                                         -- rxpolarity6
            rxpolarity7          : out std_logic;                                         -- rxpolarity7
            txcompl1             : out std_logic;                                         -- txcompl1
            txcompl2             : out std_logic;                                         -- txcompl2
            txcompl3             : out std_logic;                                         -- txcompl3
            txcompl4             : out std_logic;                                         -- txcompl4
            txcompl5             : out std_logic;                                         -- txcompl5
            txcompl6             : out std_logic;                                         -- txcompl6
            txcompl7             : out std_logic;                                         -- txcompl7
            txdata1              : out std_logic_vector(7 downto 0);                      -- txdata1
            txdata2              : out std_logic_vector(7 downto 0);                      -- txdata2
            txdata3              : out std_logic_vector(7 downto 0);                      -- txdata3
            txdata4              : out std_logic_vector(7 downto 0);                      -- txdata4
            txdata5              : out std_logic_vector(7 downto 0);                      -- txdata5
            txdata6              : out std_logic_vector(7 downto 0);                      -- txdata6
            txdata7              : out std_logic_vector(7 downto 0);                      -- txdata7
            txdatak1             : out std_logic;                                         -- txdatak1
            txdatak2             : out std_logic;                                         -- txdatak2
            txdatak3             : out std_logic;                                         -- txdatak3
            txdatak4             : out std_logic;                                         -- txdatak4
            txdatak5             : out std_logic;                                         -- txdatak5
            txdatak6             : out std_logic;                                         -- txdatak6
            txdatak7             : out std_logic;                                         -- txdatak7
            txdetectrx1          : out std_logic;                                         -- txdetectrx1
            txdetectrx2          : out std_logic;                                         -- txdetectrx2
            txdetectrx3          : out std_logic;                                         -- txdetectrx3
            txdetectrx4          : out std_logic;                                         -- txdetectrx4
            txdetectrx5          : out std_logic;                                         -- txdetectrx5
            txdetectrx6          : out std_logic;                                         -- txdetectrx6
            txdetectrx7          : out std_logic;                                         -- txdetectrx7
            txelecidle1          : out std_logic;                                         -- txelecidle1
            txelecidle2          : out std_logic;                                         -- txelecidle2
            txelecidle3          : out std_logic;                                         -- txelecidle3
            txelecidle4          : out std_logic;                                         -- txelecidle4
            txelecidle5          : out std_logic;                                         -- txelecidle5
            txelecidle6          : out std_logic;                                         -- txelecidle6
            txelecidle7          : out std_logic;                                         -- txelecidle7
            txswing1             : out std_logic;                                         -- txswing1
            txswing2             : out std_logic;                                         -- txswing2
            txswing3             : out std_logic;                                         -- txswing3
            txswing4             : out std_logic;                                         -- txswing4
            txswing5             : out std_logic;                                         -- txswing5
            txswing6             : out std_logic;                                         -- txswing6
            txswing7             : out std_logic;                                         -- txswing7
            txmargin1            : out std_logic_vector(2 downto 0);                      -- txmargin1
            txmargin2            : out std_logic_vector(2 downto 0);                      -- txmargin2
            txmargin3            : out std_logic_vector(2 downto 0);                      -- txmargin3
            txmargin4            : out std_logic_vector(2 downto 0);                      -- txmargin4
            txmargin5            : out std_logic_vector(2 downto 0);                      -- txmargin5
            txmargin6            : out std_logic_vector(2 downto 0);                      -- txmargin6
            txmargin7            : out std_logic_vector(2 downto 0);                      -- txmargin7
            txdeemph1            : out std_logic;                                         -- txdeemph1
            txdeemph2            : out std_logic;                                         -- txdeemph2
            txdeemph3            : out std_logic;                                         -- txdeemph3
            txdeemph4            : out std_logic;                                         -- txdeemph4
            txdeemph5            : out std_logic;                                         -- txdeemph5
            txdeemph6            : out std_logic;                                         -- txdeemph6
            txdeemph7            : out std_logic;                                         -- txdeemph7
            phystatus1           : in  std_logic                      := 'X';             -- phystatus1
            phystatus2           : in  std_logic                      := 'X';             -- phystatus2
            phystatus3           : in  std_logic                      := 'X';             -- phystatus3
            phystatus4           : in  std_logic                      := 'X';             -- phystatus4
            phystatus5           : in  std_logic                      := 'X';             -- phystatus5
            phystatus6           : in  std_logic                      := 'X';             -- phystatus6
            phystatus7           : in  std_logic                      := 'X';             -- phystatus7
            rxdata1              : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- rxdata1
            rxdata2              : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- rxdata2
            rxdata3              : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- rxdata3
            rxdata4              : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- rxdata4
            rxdata5              : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- rxdata5
            rxdata6              : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- rxdata6
            rxdata7              : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- rxdata7
            rxdatak1             : in  std_logic                      := 'X';             -- rxdatak1
            rxdatak2             : in  std_logic                      := 'X';             -- rxdatak2
            rxdatak3             : in  std_logic                      := 'X';             -- rxdatak3
            rxdatak4             : in  std_logic                      := 'X';             -- rxdatak4
            rxdatak5             : in  std_logic                      := 'X';             -- rxdatak5
            rxdatak6             : in  std_logic                      := 'X';             -- rxdatak6
            rxdatak7             : in  std_logic                      := 'X';             -- rxdatak7
            rxelecidle1          : in  std_logic                      := 'X';             -- rxelecidle1
            rxelecidle2          : in  std_logic                      := 'X';             -- rxelecidle2
            rxelecidle3          : in  std_logic                      := 'X';             -- rxelecidle3
            rxelecidle4          : in  std_logic                      := 'X';             -- rxelecidle4
            rxelecidle5          : in  std_logic                      := 'X';             -- rxelecidle5
            rxelecidle6          : in  std_logic                      := 'X';             -- rxelecidle6
            rxelecidle7          : in  std_logic                      := 'X';             -- rxelecidle7
            rxstatus1            : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- rxstatus1
            rxstatus2            : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- rxstatus2
            rxstatus3            : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- rxstatus3
            rxstatus4            : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- rxstatus4
            rxstatus5            : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- rxstatus5
            rxstatus6            : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- rxstatus6
            rxstatus7            : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- rxstatus7
            rxvalid1             : in  std_logic                      := 'X';             -- rxvalid1
            rxvalid2             : in  std_logic                      := 'X';             -- rxvalid2
            rxvalid3             : in  std_logic                      := 'X';             -- rxvalid3
            rxvalid4             : in  std_logic                      := 'X';             -- rxvalid4
            rxvalid5             : in  std_logic                      := 'X';             -- rxvalid5
            rxvalid6             : in  std_logic                      := 'X';             -- rxvalid6
            rxvalid7             : in  std_logic                      := 'X';             -- rxvalid7
            rxdataskip0          : in  std_logic                      := 'X';             -- rxdataskip0
            rxdataskip1          : in  std_logic                      := 'X';             -- rxdataskip1
            rxdataskip2          : in  std_logic                      := 'X';             -- rxdataskip2
            rxdataskip3          : in  std_logic                      := 'X';             -- rxdataskip3
            rxdataskip4          : in  std_logic                      := 'X';             -- rxdataskip4
            rxdataskip5          : in  std_logic                      := 'X';             -- rxdataskip5
            rxdataskip6          : in  std_logic                      := 'X';             -- rxdataskip6
            rxdataskip7          : in  std_logic                      := 'X';             -- rxdataskip7
            rxblkst0             : in  std_logic                      := 'X';             -- rxblkst0
            rxblkst1             : in  std_logic                      := 'X';             -- rxblkst1
            rxblkst2             : in  std_logic                      := 'X';             -- rxblkst2
            rxblkst3             : in  std_logic                      := 'X';             -- rxblkst3
            rxblkst4             : in  std_logic                      := 'X';             -- rxblkst4
            rxblkst5             : in  std_logic                      := 'X';             -- rxblkst5
            rxblkst6             : in  std_logic                      := 'X';             -- rxblkst6
            rxblkst7             : in  std_logic                      := 'X';             -- rxblkst7
            rxsynchd0            : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- rxsynchd0
            rxsynchd1            : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- rxsynchd1
            rxsynchd2            : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- rxsynchd2
            rxsynchd3            : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- rxsynchd3
            rxsynchd4            : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- rxsynchd4
            rxsynchd5            : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- rxsynchd5
            rxsynchd6            : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- rxsynchd6
            rxsynchd7            : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- rxsynchd7
            rxfreqlocked0        : in  std_logic                      := 'X';             -- rxfreqlocked0
            rxfreqlocked1        : in  std_logic                      := 'X';             -- rxfreqlocked1
            rxfreqlocked2        : in  std_logic                      := 'X';             -- rxfreqlocked2
            rxfreqlocked3        : in  std_logic                      := 'X';             -- rxfreqlocked3
            rxfreqlocked4        : in  std_logic                      := 'X';             -- rxfreqlocked4
            rxfreqlocked5        : in  std_logic                      := 'X';             -- rxfreqlocked5
            rxfreqlocked6        : in  std_logic                      := 'X';             -- rxfreqlocked6
            rxfreqlocked7        : in  std_logic                      := 'X';             -- rxfreqlocked7
            currentcoeff0        : out std_logic_vector(17 downto 0);                     -- currentcoeff0
            currentcoeff1        : out std_logic_vector(17 downto 0);                     -- currentcoeff1
            currentcoeff2        : out std_logic_vector(17 downto 0);                     -- currentcoeff2
            currentcoeff3        : out std_logic_vector(17 downto 0);                     -- currentcoeff3
            currentcoeff4        : out std_logic_vector(17 downto 0);                     -- currentcoeff4
            currentcoeff5        : out std_logic_vector(17 downto 0);                     -- currentcoeff5
            currentcoeff6        : out std_logic_vector(17 downto 0);                     -- currentcoeff6
            currentcoeff7        : out std_logic_vector(17 downto 0);                     -- currentcoeff7
            currentrxpreset0     : out std_logic_vector(2 downto 0);                      -- currentrxpreset0
            currentrxpreset1     : out std_logic_vector(2 downto 0);                      -- currentrxpreset1
            currentrxpreset2     : out std_logic_vector(2 downto 0);                      -- currentrxpreset2
            currentrxpreset3     : out std_logic_vector(2 downto 0);                      -- currentrxpreset3
            currentrxpreset4     : out std_logic_vector(2 downto 0);                      -- currentrxpreset4
            currentrxpreset5     : out std_logic_vector(2 downto 0);                      -- currentrxpreset5
            currentrxpreset6     : out std_logic_vector(2 downto 0);                      -- currentrxpreset6
            currentrxpreset7     : out std_logic_vector(2 downto 0);                      -- currentrxpreset7
            txsynchd0            : out std_logic_vector(1 downto 0);                      -- txsynchd0
            txsynchd1            : out std_logic_vector(1 downto 0);                      -- txsynchd1
            txsynchd2            : out std_logic_vector(1 downto 0);                      -- txsynchd2
            txsynchd3            : out std_logic_vector(1 downto 0);                      -- txsynchd3
            txsynchd4            : out std_logic_vector(1 downto 0);                      -- txsynchd4
            txsynchd5            : out std_logic_vector(1 downto 0);                      -- txsynchd5
            txsynchd6            : out std_logic_vector(1 downto 0);                      -- txsynchd6
            txsynchd7            : out std_logic_vector(1 downto 0);                      -- txsynchd7
            txblkst0             : out std_logic;                                         -- txblkst0
            txblkst1             : out std_logic;                                         -- txblkst1
            txblkst2             : out std_logic;                                         -- txblkst2
            txblkst3             : out std_logic;                                         -- txblkst3
            txblkst4             : out std_logic;                                         -- txblkst4
            txblkst5             : out std_logic;                                         -- txblkst5
            txblkst6             : out std_logic;                                         -- txblkst6
            txblkst7             : out std_logic                                          -- txblkst7
        );
    end component altpcie_cv_hip_avmm_hwtcl_x;


    component altpcie_cv_hip_avmm_hwtcl
        generic(
            pll_refclk_freq_hwtcl: string  := "100 MHz";
            enable_slot_register_hwtcl: integer := 0;
            port_type_hwtcl : string  := "Native endpoint";
            bypass_cdc_hwtcl: string  := "false";
            enable_rx_buffer_checking_hwtcl: string  := "false";
            single_rx_detect_hwtcl: integer := 0;
            use_crc_forwarding_hwtcl: integer := 0;
            ast_width_hwtcl : string  := "rx_tx_64";
            gen123_lane_rate_mode_hwtcl: string  := "gen1";
            lane_mask_hwtcl : string  := "x4";
            disable_link_x2_support_hwtcl: string  := "false";
            hip_hard_reset_hwtcl: string  := "disable";
            wrong_device_id_hwtcl: string  := "disable";
            data_pack_rx_hwtcl: string  := "disable";
            use_ast_parity  : integer := 0;
            ltssm_1ms_timeout_hwtcl: string  := "disable";
            ltssm_freqlocked_check_hwtcl: string  := "disable";
            deskew_comma_hwtcl: string  := "skp_eieos_deskw";
            port_link_number_hwtcl: integer := 1;
            device_number_hwtcl: integer := 0;
            bypass_clk_switch_hwtcl: string  := "disabled";
            pipex1_debug_sel_hwtcl: string  := "disable";
            pclk_out_sel_hwtcl: string  := "pclk";
            vendor_id_hwtcl : integer := 4466;
            device_id_hwtcl : integer := 57345;
            revision_id_hwtcl: integer := 1;
            class_code_hwtcl: integer := 16711680;
            subsystem_vendor_id_hwtcl: integer := 4466;
            subsystem_device_id_hwtcl: integer := 57345;
            no_soft_reset_hwtcl: string  := "false";
            maximum_current_hwtcl: integer := 0;
            d1_support_hwtcl: string  := "false";
            d2_support_hwtcl: string  := "false";
            d0_pme_hwtcl    : string  := "false";
            d1_pme_hwtcl    : string  := "false";
            d2_pme_hwtcl    : string  := "false";
            d3_hot_pme_hwtcl: string  := "false";
            d3_cold_pme_hwtcl: string  := "false";
            use_aer_hwtcl   : integer := 0;
            low_priority_vc_hwtcl: string  := "single_vc";
            disable_snoop_packet_hwtcl: string  := "false";
            max_payload_size_hwtcl: integer := 256;
            surprise_down_error_support_hwtcl: integer := 0;
            dll_active_report_support_hwtcl: integer := 0;
            extend_tag_field_hwtcl: string  := "false";
            endpoint_l0_latency_hwtcl: integer := 0;
            endpoint_l1_latency_hwtcl: integer := 0;
            indicator_hwtcl : integer := 0;
            slot_power_scale_hwtcl: integer := 0;
            enable_l1_aspm_hwtcl: string  := "false";
            l1_exit_latency_sameclock_hwtcl: integer := 0;
            l1_exit_latency_diffclock_hwtcl: integer := 0;
            hot_plug_support_hwtcl: integer := 0;
            slot_power_limit_hwtcl: integer := 0;
            slot_number_hwtcl: integer := 0;
            diffclock_nfts_count_hwtcl: integer := 128;
            sameclock_nfts_count_hwtcl: integer := 128;
            completion_timeout_hwtcl: string  := "abcd";
            enable_completion_timeout_disable_hwtcl: integer := 1;
            extended_tag_reset_hwtcl: string  := "false";
            ecrc_check_capable_hwtcl: integer := 0;
            ecrc_gen_capable_hwtcl: integer := 0;
            msi_multi_message_capable_hwtcl: string  := "count_4";
            msi_64bit_addressing_capable_hwtcl: string  := "true";
            msi_masking_capable_hwtcl: string  := "false";
            msi_support_hwtcl: string  := "true";
            interrupt_pin_hwtcl: string  := "inta";
            enable_function_msix_support_hwtcl: integer := 0;
            msix_table_size_hwtcl: integer := 0;
            msix_table_bir_hwtcl: integer := 0;
            msix_table_offset_hwtcl: integer := 0;
            msix_pba_bir_hwtcl: integer := 0;
            msix_pba_offset_hwtcl: integer := 0;
            bridge_port_vga_enable_hwtcl: string  := "false";
            bridge_port_ssid_support_hwtcl: string  := "false";
            ssvid_hwtcl     : integer := 0;
            ssid_hwtcl      : integer := 0;
            eie_before_nfts_count_hwtcl: integer := 4;
            gen2_diffclock_nfts_count_hwtcl: integer := 255;
            gen2_sameclock_nfts_count_hwtcl: integer := 255;
            deemphasis_enable_hwtcl: string  := "false";
            pcie_spec_version_hwtcl: string  := "v2";
            l0_exit_latency_sameclock_hwtcl: integer := 6;
            l0_exit_latency_diffclock_hwtcl: integer := 6;
            rx_ei_l0s_hwtcl : integer := 1;
            l2_async_logic_hwtcl: string  := "disable";
            aspm_config_management_hwtcl: string  := "true";
            atomic_op_routing_hwtcl: string  := "false";
            atomic_op_completer_32bit_hwtcl: string  := "false";
            atomic_op_completer_64bit_hwtcl: string  := "false";
            cas_completer_128bit_hwtcl: string  := "false";
            ltr_mechanism_hwtcl: string  := "false";
            tph_completer_hwtcl: string  := "false";
            extended_format_field_hwtcl: string  := "true";
            atomic_malformed_hwtcl: string  := "false";
            flr_capability_hwtcl: string  := "true";
            enable_adapter_half_rate_mode_hwtcl: string  := "false";
            vc0_clk_enable_hwtcl: string  := "true";
            bar0_io_space_hwtcl: string  := "Disabled";
            bar0_64bit_mem_space_hwtcl: string  := "Enabled";
            bar0_prefetchable_hwtcl: string  := "Enabled";
            bar0_size_mask_hwtcl: string  := "256 MBytes - 28 bits";
            bar1_io_space_hwtcl: string  := "Disabled";
            bar1_64bit_mem_space_hwtcl: string  := "Disabled";
            bar1_prefetchable_hwtcl: string  := "Disabled";
            bar1_size_mask_hwtcl: string  := "N/A";
            bar2_io_space_hwtcl: string  := "Disabled";
            bar2_64bit_mem_space_hwtcl: string  := "Disabled";
            bar2_prefetchable_hwtcl: string  := "Disabled";
            bar2_size_mask_hwtcl: string  := "N/A";
            bar3_io_space_hwtcl: string  := "Disabled";
            bar3_64bit_mem_space_hwtcl: string  := "Disabled";
            bar3_prefetchable_hwtcl: string  := "Disabled";
            bar3_size_mask_hwtcl: string  := "N/A";
            bar4_io_space_hwtcl: string  := "Disabled";
            bar4_64bit_mem_space_hwtcl: string  := "Disabled";
            bar4_prefetchable_hwtcl: string  := "Disabled";
            bar4_size_mask_hwtcl: string  := "N/A";
            bar5_io_space_hwtcl: string  := "Disabled";
            bar5_64bit_mem_space_hwtcl: string  := "Disabled";
            bar5_prefetchable_hwtcl: string  := "Disabled";
            bar5_size_mask_hwtcl: string  := "N/A";
            expansion_base_address_register_hwtcl: integer := 0;
            io_window_addr_width_hwtcl: integer := 0;
            prefetchable_mem_window_addr_width_hwtcl: integer := 0;
            skp_os_gen3_count_hwtcl: integer := 0;
            tx_cdc_almost_empty_hwtcl: integer := 5;
            rx_cdc_almost_full_hwtcl: integer := 12;
            tx_cdc_almost_full_hwtcl: integer := 12;
            rx_l0s_count_idl_hwtcl: integer := 0;
            cdc_dummy_insert_limit_hwtcl: integer := 11;
            ei_delay_powerdown_count_hwtcl: integer := 10;
            millisecond_cycle_count_hwtcl: integer := 248500;
            skp_os_schedule_count_hwtcl: integer := 0;
            fc_init_timer_hwtcl: integer := 1024;
            l01_entry_latency_hwtcl: integer := 31;
            flow_control_update_count_hwtcl: integer := 30;
            flow_control_timeout_count_hwtcl: integer := 200;
            credit_buffer_allocation_aux_hwtcl: string  := "balanced";
            vc0_rx_flow_ctrl_posted_header_hwtcl: integer := 50;
            vc0_rx_flow_ctrl_posted_data_hwtcl: integer := 360;
            vc0_rx_flow_ctrl_nonposted_header_hwtcl: integer := 54;
            vc0_rx_flow_ctrl_nonposted_data_hwtcl: integer := 0;
            vc0_rx_flow_ctrl_compl_header_hwtcl: integer := 112;
            vc0_rx_flow_ctrl_compl_data_hwtcl: integer := 448;
            rx_ptr0_posted_dpram_min_hwtcl: integer := 0;
            rx_ptr0_posted_dpram_max_hwtcl: integer := 0;
            rx_ptr0_nonposted_dpram_min_hwtcl: integer := 0;
            rx_ptr0_nonposted_dpram_max_hwtcl: integer := 0;
            retry_buffer_last_active_address_hwtcl: integer := 2047;
            retry_buffer_memory_settings_hwtcl: integer := 0;
            vc0_rx_buffer_memory_settings_hwtcl: integer := 0;
            in_cvp_mode_hwtcl: integer := 0;
            slotclkcfg_hwtcl: integer := 1;
            reconfig_to_xcvr_width: integer := 350;
            set_pld_clk_x1_625MHz_hwtcl: integer := 0;
            reconfig_from_xcvr_width: integer := 230;
            enable_l0s_aspm_hwtcl: string  := "true";
            cpl_spc_header_hwtcl: integer := 195;
            cpl_spc_data_hwtcl: integer := 781;
            coreclkout_hip_phaseshift_hwtcl: string  := "0 ps";
            pldclk_hip_phase_shift_hwtcl: string  := "0 ps";
            port_width_be_hwtcl: integer := 8;
            port_width_data_hwtcl: integer := 64;
            reserved_debug_hwtcl: integer := 0;
            hip_reconfig_hwtcl: integer := 0;
            user_id_hwtcl   : integer := 0;
            vsec_id_hwtcl   : integer := 0;
            vsec_rev_hwtcl  : integer := 0;
            gen3_rxfreqlock_counter_hwtcl: integer := 0;
            gen3_skip_ph2_ph3_hwtcl: string  := "true";
            g3_bypass_equlz_hwtcl: string  := "true";
            cvp_rate_sel_hwtcl: string  := "full_rate";
            cvp_data_compressed_hwtcl: string  := "false";
            cvp_data_encrypted_hwtcl: string  := "false";
            cvp_mode_reset_hwtcl: string  := "false";
            cvp_clk_reset_hwtcl: string  := "false";
            cseb_cpl_status_during_cvp_hwtcl: string  := "config_retry_status";
            core_clk_sel_hwtcl: string  := "pld_clk";
            rpre_emph_a_val_hwtcl: integer := 0;
            rpre_emph_b_val_hwtcl: integer := 0;
            rpre_emph_c_val_hwtcl: integer := 0;
            rpre_emph_d_val_hwtcl: integer := 0;
            rpre_emph_e_val_hwtcl: integer := 0;
            rvod_sel_a_val_hwtcl: integer := 0;
            rvod_sel_b_val_hwtcl: integer := 0;
            rvod_sel_c_val_hwtcl: integer := 0;
            rvod_sel_d_val_hwtcl: integer := 0;
            rvod_sel_e_val_hwtcl: integer := 0;
            register_pipe_signals_hwtcl: string  := "true";
            no_command_completed_hwtcl: string  := "true";
            use_tl_cfg_sync_hwtcl: integer := 0;
            CG_ENABLE_A2P_INTERRUPT: integer := 0;
            CG_RXM_IRQ_NUM  : integer := 16;
            CB_PCIE_MODE    : integer := 0;
            CB_PCIE_RX_LITE : integer := 0;
            CB_RXM_DATA_WIDTH: integer := 64;
            CB_A2P_ADDR_MAP_IS_FIXED: integer := 0;
            CB_A2P_ADDR_MAP_NUM_ENTRIES: integer := 1;
            CG_AVALON_S_ADDR_WIDTH: integer := 24;
            CG_IMPL_CRA_AV_SLAVE_PORT: integer := 1;
            a2p_pass_thru_bits: integer := 24;
            CB_P2A_AVALON_ADDR_B0: integer := 0;
            CB_P2A_AVALON_ADDR_B1: integer := 0;
            CB_P2A_AVALON_ADDR_B2: integer := 0;
            CB_P2A_AVALON_ADDR_B3: integer := 0;
            CB_P2A_AVALON_ADDR_B4: integer := 0;
            CB_P2A_AVALON_ADDR_B5: integer := 0;
            CB_P2A_AVALON_ADDR_B6: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_0_LOW: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_0_HIGH: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_1_LOW: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_1_HIGH: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_2_LOW: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_2_HIGH: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_3_LOW: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_3_HIGH: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_4_LOW: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_4_HIGH: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_5_LOW: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_5_HIGH: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_6_LOW: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_6_HIGH: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_7_LOW: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_7_HIGH: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_8_LOW: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_8_HIGH: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_9_LOW: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_9_HIGH: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_10_LOW: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_10_HIGH: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_11_LOW: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_11_HIGH: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_12_LOW: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_12_HIGH: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_13_LOW: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_13_HIGH: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_14_LOW: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_14_HIGH: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_15_LOW: integer := 0;
            CB_A2P_ADDR_MAP_FIXED_TABLE_15_HIGH: integer := 0;
            bar_prefetchable: integer := 1;
            avmm_width_hwtcl: integer := 64;
            avmm_burst_width_hwtcl: integer := 7;
            AVALON_ADDR_WIDTH: integer := 32;
            BYPASSS_A2P_TRANSLATION: integer := 0;
            CG_ENABLE_ADVANCED_INTERRUPT: integer := 0
        );
        port(
            pin_perst       : in    std_logic;
            npor            : in    std_logic;
            reset_status    : out   std_logic;
            refclk          : in    std_logic;
            hpg_ctrler      : in    std_logic_vector(4 downto 0);
            simu_mode_pipe  : in    std_logic;
            test_in         : in    std_logic_vector(31 downto 0);
            testout         : out   std_logic_vector(127 downto 0);
            sim_pipe_rate   : out   std_logic_vector(1 downto 0);
            sim_pipe_pclk_in: in    std_logic;
            sim_pipe_pclk_out: out   std_logic;
            sim_pipe_clk250_out: out   std_logic;
            sim_pipe_clk500_out: out   std_logic;
            sim_ltssmstate  : out   std_logic_vector(4 downto 0);
            phystatus0      : in    std_logic;
            phystatus1      : in    std_logic;
            phystatus2      : in    std_logic;
            phystatus3      : in    std_logic;
            phystatus4      : in    std_logic;
            phystatus5      : in    std_logic;
            phystatus6      : in    std_logic;
            phystatus7      : in    std_logic;
            rxdata0         : in    std_logic_vector(7 downto 0);
            rxdata1         : in    std_logic_vector(7 downto 0);
            rxdata2         : in    std_logic_vector(7 downto 0);
            rxdata3         : in    std_logic_vector(7 downto 0);
            rxdata4         : in    std_logic_vector(7 downto 0);
            rxdata5         : in    std_logic_vector(7 downto 0);
            rxdata6         : in    std_logic_vector(7 downto 0);
            rxdata7         : in    std_logic_vector(7 downto 0);
            rxdatak0        : in    std_logic;
            rxdatak1        : in    std_logic;
            rxdatak2        : in    std_logic;
            rxdatak3        : in    std_logic;
            rxdatak4        : in    std_logic;
            rxdatak5        : in    std_logic;
            rxdatak6        : in    std_logic;
            rxdatak7        : in    std_logic;
            rxelecidle0     : in    std_logic;
            rxelecidle1     : in    std_logic;
            rxelecidle2     : in    std_logic;
            rxelecidle3     : in    std_logic;
            rxelecidle4     : in    std_logic;
            rxelecidle5     : in    std_logic;
            rxelecidle6     : in    std_logic;
            rxelecidle7     : in    std_logic;
            rxfreqlocked0   : in    std_logic;
            rxfreqlocked1   : in    std_logic;
            rxfreqlocked2   : in    std_logic;
            rxfreqlocked3   : in    std_logic;
            rxfreqlocked4   : in    std_logic;
            rxfreqlocked5   : in    std_logic;
            rxfreqlocked6   : in    std_logic;
            rxfreqlocked7   : in    std_logic;
            rxstatus0       : in    std_logic_vector(2 downto 0);
            rxstatus1       : in    std_logic_vector(2 downto 0);
            rxstatus2       : in    std_logic_vector(2 downto 0);
            rxstatus3       : in    std_logic_vector(2 downto 0);
            rxstatus4       : in    std_logic_vector(2 downto 0);
            rxstatus5       : in    std_logic_vector(2 downto 0);
            rxstatus6       : in    std_logic_vector(2 downto 0);
            rxstatus7       : in    std_logic_vector(2 downto 0);
            rxdataskip0     : in    std_logic;
            rxdataskip1     : in    std_logic;
            rxdataskip2     : in    std_logic;
            rxdataskip3     : in    std_logic;
            rxdataskip4     : in    std_logic;
            rxdataskip5     : in    std_logic;
            rxdataskip6     : in    std_logic;
            rxdataskip7     : in    std_logic;
            rxblkst0        : in    std_logic;
            rxblkst1        : in    std_logic;
            rxblkst2        : in    std_logic;
            rxblkst3        : in    std_logic;
            rxblkst4        : in    std_logic;
            rxblkst5        : in    std_logic;
            rxblkst6        : in    std_logic;
            rxblkst7        : in    std_logic;
            rxsynchd0       : in    std_logic_vector(1 downto 0);
            rxsynchd1       : in    std_logic_vector(1 downto 0);
            rxsynchd2       : in    std_logic_vector(1 downto 0);
            rxsynchd3       : in    std_logic_vector(1 downto 0);
            rxsynchd4       : in    std_logic_vector(1 downto 0);
            rxsynchd5       : in    std_logic_vector(1 downto 0);
            rxsynchd6       : in    std_logic_vector(1 downto 0);
            rxsynchd7       : in    std_logic_vector(1 downto 0);
            rxvalid0        : in    std_logic;
            rxvalid1        : in    std_logic;
            rxvalid2        : in    std_logic;
            rxvalid3        : in    std_logic;
            rxvalid4        : in    std_logic;
            rxvalid5        : in    std_logic;
            rxvalid6        : in    std_logic;
            rxvalid7        : in    std_logic;
            eidleinfersel0  : out   std_logic_vector(2 downto 0);
            eidleinfersel1  : out   std_logic_vector(2 downto 0);
            eidleinfersel2  : out   std_logic_vector(2 downto 0);
            eidleinfersel3  : out   std_logic_vector(2 downto 0);
            eidleinfersel4  : out   std_logic_vector(2 downto 0);
            eidleinfersel5  : out   std_logic_vector(2 downto 0);
            eidleinfersel6  : out   std_logic_vector(2 downto 0);
            eidleinfersel7  : out   std_logic_vector(2 downto 0);
            powerdown0      : out   std_logic_vector(1 downto 0);
            powerdown1      : out   std_logic_vector(1 downto 0);
            powerdown2      : out   std_logic_vector(1 downto 0);
            powerdown3      : out   std_logic_vector(1 downto 0);
            powerdown4      : out   std_logic_vector(1 downto 0);
            powerdown5      : out   std_logic_vector(1 downto 0);
            powerdown6      : out   std_logic_vector(1 downto 0);
            powerdown7      : out   std_logic_vector(1 downto 0);
            rxpolarity0     : out   std_logic;
            rxpolarity1     : out   std_logic;
            rxpolarity2     : out   std_logic;
            rxpolarity3     : out   std_logic;
            rxpolarity4     : out   std_logic;
            rxpolarity5     : out   std_logic;
            rxpolarity6     : out   std_logic;
            rxpolarity7     : out   std_logic;
            txcompl0        : out   std_logic;
            txcompl1        : out   std_logic;
            txcompl2        : out   std_logic;
            txcompl3        : out   std_logic;
            txcompl4        : out   std_logic;
            txcompl5        : out   std_logic;
            txcompl6        : out   std_logic;
            txcompl7        : out   std_logic;
            txdata0         : out   std_logic_vector(7 downto 0);
            txdata1         : out   std_logic_vector(7 downto 0);
            txdata2         : out   std_logic_vector(7 downto 0);
            txdata3         : out   std_logic_vector(7 downto 0);
            txdata4         : out   std_logic_vector(7 downto 0);
            txdata5         : out   std_logic_vector(7 downto 0);
            txdata6         : out   std_logic_vector(7 downto 0);
            txdata7         : out   std_logic_vector(7 downto 0);
            txdatak0        : out   std_logic;
            txdatak1        : out   std_logic;
            txdatak2        : out   std_logic;
            txdatak3        : out   std_logic;
            txdatak4        : out   std_logic;
            txdatak5        : out   std_logic;
            txdatak6        : out   std_logic;
            txdatak7        : out   std_logic;
            txdatavalid0    : out   std_logic;
            txdatavalid1    : out   std_logic;
            txdatavalid2    : out   std_logic;
            txdatavalid3    : out   std_logic;
            txdatavalid4    : out   std_logic;
            txdatavalid5    : out   std_logic;
            txdatavalid6    : out   std_logic;
            txdatavalid7    : out   std_logic;
            txdetectrx0     : out   std_logic;
            txdetectrx1     : out   std_logic;
            txdetectrx2     : out   std_logic;
            txdetectrx3     : out   std_logic;
            txdetectrx4     : out   std_logic;
            txdetectrx5     : out   std_logic;
            txdetectrx6     : out   std_logic;
            txdetectrx7     : out   std_logic;
            txelecidle0     : out   std_logic;
            txelecidle1     : out   std_logic;
            txelecidle2     : out   std_logic;
            txelecidle3     : out   std_logic;
            txelecidle4     : out   std_logic;
            txelecidle5     : out   std_logic;
            txelecidle6     : out   std_logic;
            txelecidle7     : out   std_logic;
            txmargin0       : out   std_logic_vector(2 downto 0);
            txmargin1       : out   std_logic_vector(2 downto 0);
            txmargin2       : out   std_logic_vector(2 downto 0);
            txmargin3       : out   std_logic_vector(2 downto 0);
            txmargin4       : out   std_logic_vector(2 downto 0);
            txmargin5       : out   std_logic_vector(2 downto 0);
            txmargin6       : out   std_logic_vector(2 downto 0);
            txmargin7       : out   std_logic_vector(2 downto 0);
            txdeemph0       : out   std_logic;
            txdeemph1       : out   std_logic;
            txdeemph2       : out   std_logic;
            txdeemph3       : out   std_logic;
            txdeemph4       : out   std_logic;
            txdeemph5       : out   std_logic;
            txdeemph6       : out   std_logic;
            txdeemph7       : out   std_logic;
            txswing0        : out   std_logic;
            txswing1        : out   std_logic;
            txswing2        : out   std_logic;
            txswing3        : out   std_logic;
            txswing4        : out   std_logic;
            txswing5        : out   std_logic;
            txswing6        : out   std_logic;
            txswing7        : out   std_logic;
            txblkst0        : out   std_logic;
            txblkst1        : out   std_logic;
            txblkst2        : out   std_logic;
            txblkst3        : out   std_logic;
            txblkst4        : out   std_logic;
            txblkst5        : out   std_logic;
            txblkst6        : out   std_logic;
            txblkst7        : out   std_logic;
            txsynchd0       : out   std_logic_vector(1 downto 0);
            txsynchd1       : out   std_logic_vector(1 downto 0);
            txsynchd2       : out   std_logic_vector(1 downto 0);
            txsynchd3       : out   std_logic_vector(1 downto 0);
            txsynchd4       : out   std_logic_vector(1 downto 0);
            txsynchd5       : out   std_logic_vector(1 downto 0);
            txsynchd6       : out   std_logic_vector(1 downto 0);
            txsynchd7       : out   std_logic_vector(1 downto 0);
            currentcoeff0   : out   std_logic_vector(17 downto 0);
            currentcoeff1   : out   std_logic_vector(17 downto 0);
            currentcoeff2   : out   std_logic_vector(17 downto 0);
            currentcoeff3   : out   std_logic_vector(17 downto 0);
            currentcoeff4   : out   std_logic_vector(17 downto 0);
            currentcoeff5   : out   std_logic_vector(17 downto 0);
            currentcoeff6   : out   std_logic_vector(17 downto 0);
            currentcoeff7   : out   std_logic_vector(17 downto 0);
            currentrxpreset0: out   std_logic_vector(2 downto 0);
            currentrxpreset1: out   std_logic_vector(2 downto 0);
            currentrxpreset2: out   std_logic_vector(2 downto 0);
            currentrxpreset3: out   std_logic_vector(2 downto 0);
            currentrxpreset4: out   std_logic_vector(2 downto 0);
            currentrxpreset5: out   std_logic_vector(2 downto 0);
            currentrxpreset6: out   std_logic_vector(2 downto 0);
            currentrxpreset7: out   std_logic_vector(2 downto 0);
            coreclkout      : out   std_logic;
            reconfig_to_xcvr: in    std_logic_vector;
            busy_xcvr_reconfig: in    std_logic;
            reconfig_from_xcvr: out   std_logic_vector;
            fixedclk_locked : out   std_logic;
            rx_in0          : in    std_logic;
            rx_in1          : in    std_logic;
            rx_in2          : in    std_logic;
            rx_in3          : in    std_logic;
            rx_in4          : in    std_logic;
            rx_in5          : in    std_logic;
            rx_in6          : in    std_logic;
            rx_in7          : in    std_logic;
            tx_out0         : out   std_logic;
            tx_out1         : out   std_logic;
            tx_out2         : out   std_logic;
            tx_out3         : out   std_logic;
            tx_out4         : out   std_logic;
            tx_out5         : out   std_logic;
            tx_out6         : out   std_logic;
            tx_out7         : out   std_logic;
            TxsChipSelect_i : in    std_logic;
            TxsRead_i       : in    std_logic;
            TxsWrite_i      : in    std_logic;
            TxsWriteData_i  : in    std_logic_vector;
            TxsBurstCount_i : in    std_logic_vector;
            TxsAddress_i    : in    std_logic_vector;
            TxsByteEnable_i : in    std_logic_vector;
            TxsReadDataValid_o: out   std_logic;
            TxsReadData_o   : out   std_logic_vector;
            TxsWaitRequest_o: out   std_logic;
            RxmIrq_i        : in    std_logic_vector(15 downto 0);
            RxmWrite_0_o    : out   std_logic;
            RxmAddress_0_o  : out   std_logic_vector;
            RxmWriteData_0_o: out   std_logic_vector;
            RxmByteEnable_0_o: out   std_logic_vector;
            RxmBurstCount_0_o: out   std_logic_vector;
            RxmWaitRequest_0_i: in    std_logic;
            RxmRead_0_o     : out   std_logic;
            RxmReadData_0_i : in    std_logic_vector;
            RxmReadDataValid_0_i: in    std_logic;
            RxmWrite_1_o    : out   std_logic;
            RxmAddress_1_o  : out   std_logic_vector;
            RxmWriteData_1_o: out   std_logic_vector;
            RxmByteEnable_1_o: out   std_logic_vector;
            RxmBurstCount_1_o: out   std_logic_vector;
            RxmWaitRequest_1_i: in    std_logic;
            RxmRead_1_o     : out   std_logic;
            RxmReadData_1_i : in    std_logic_vector;
            RxmReadDataValid_1_i: in    std_logic;
            RxmWrite_2_o    : out   std_logic;
            RxmAddress_2_o  : out   std_logic_vector;
            RxmWriteData_2_o: out   std_logic_vector;
            RxmByteEnable_2_o: out   std_logic_vector;
            RxmBurstCount_2_o: out   std_logic_vector;
            RxmWaitRequest_2_i: in    std_logic;
            RxmRead_2_o     : out   std_logic;
            RxmReadData_2_i : in    std_logic_vector;
            RxmReadDataValid_2_i: in    std_logic;
            RxmWrite_3_o    : out   std_logic;
            RxmAddress_3_o  : out   std_logic_vector;
            RxmWriteData_3_o: out   std_logic_vector;
            RxmByteEnable_3_o: out   std_logic_vector;
            RxmBurstCount_3_o: out   std_logic_vector;
            RxmWaitRequest_3_i: in    std_logic;
            RxmRead_3_o     : out   std_logic;
            RxmReadData_3_i : in    std_logic_vector;
            RxmReadDataValid_3_i: in    std_logic;
            RxmWrite_4_o    : out   std_logic;
            RxmAddress_4_o  : out   std_logic_vector;
            RxmWriteData_4_o: out   std_logic_vector;
            RxmByteEnable_4_o: out   std_logic_vector;
            RxmBurstCount_4_o: out   std_logic_vector(6 downto 0);
            RxmWaitRequest_4_i: in    std_logic;
            RxmRead_4_o     : out   std_logic;
            RxmReadData_4_i : in    std_logic_vector;
            RxmReadDataValid_4_i: in    std_logic;
            RxmWrite_5_o    : out   std_logic;
            RxmAddress_5_o  : out   std_logic_vector;
            RxmWriteData_5_o: out   std_logic_vector;
            RxmByteEnable_5_o: out   std_logic_vector;
            RxmBurstCount_5_o: out   std_logic_vector;
            RxmWaitRequest_5_i: in    std_logic;
            RxmRead_5_o     : out   std_logic;
            RxmReadData_5_i : in    std_logic_vector;
            RxmReadDataValid_5_i: in    std_logic;
            RxmWrite_6_o    : out   std_logic;
            RxmAddress_6_o  : out   std_logic_vector;
            RxmWriteData_6_o: out   std_logic_vector;
            RxmByteEnable_6_o: out   std_logic_vector;
            RxmBurstCount_6_o: out   std_logic_vector;
            RxmWaitRequest_6_i: in    std_logic;
            RxmRead_6_o     : out   std_logic;
            RxmReadData_6_i : in    std_logic_vector;
            RxmReadDataValid_6_i: in    std_logic;
            CraChipSelect_i : in    std_logic;
            CraRead         : in    std_logic;
            CraWrite        : in    std_logic;
            CraWriteData_i  : in    std_logic_vector(31 downto 0);
            CraAddress_i    : in    std_logic_vector(13 downto 0);
            CraByteEnable_i : in    std_logic_vector(3 downto 0);
            CraReadData_o   : out   std_logic_vector(31 downto 0);
            CraWaitRequest_o: out   std_logic;
            CraIrq_o        : out   std_logic;
            MsiIntfc_o      : out   std_logic_vector(81 downto 0);
            MsiControl_o    : out   std_logic_vector(15 downto 0);
            MsixIntfc_o     : out   std_logic_vector(15 downto 0);
            IntxReq_i       : in    std_logic;
            IntxAck_o       : out   std_logic;
            rx_st_valid     : out   std_logic;
            rx_st_sop       : out   std_logic;
            rx_st_eop       : out   std_logic;
            rx_st_err       : out   std_logic;
            rx_st_data      : out   std_logic_vector;
            rx_st_bar       : out   std_logic_vector(7 downto 0);
            tx_st_ready     : out   std_logic;
            pld_clk_inuse   : out   std_logic;
            dlup_exit       : out   std_logic;
            hotrst_exit     : out   std_logic;
            l2_exit         : out   std_logic;
            currentspeed    : out   std_logic_vector(1 downto 0);
            ltssmstate      : out   std_logic_vector(4 downto 0);
            derr_cor_ext_rcv: out   std_logic;
            derr_cor_ext_rpl: out   std_logic;
            derr_rpl        : out   std_logic;
            int_status      : out   std_logic_vector(3 downto 0);
            serr_out        : out   std_logic;
            tl_cfg_add      : out   std_logic_vector(3 downto 0);
            tl_cfg_ctl      : out   std_logic_vector(31 downto 0);
            tl_cfg_sts      : out   std_logic_vector(52 downto 0);
            pme_to_sr       : out   std_logic;
            lane_act        : out   std_logic_vector(3 downto 0);
            ev128ns         : out   std_logic;
            ev1us           : out   std_logic;
            ko_cpl_spc_header: out   std_logic_vector(7 downto 0);
            ko_cpl_spc_data : out   std_logic_vector(11 downto 0)
        );
    end component;




end package Pcie1EpAvPkg;
