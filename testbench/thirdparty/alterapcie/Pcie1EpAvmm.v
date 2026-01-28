//
//  File Name:         Pcie1EpAvvm.v
//  Design Unit Name:  Pcie1EpAvvm
//  Revision:          OSVVM MODELS STANDARD VERSION
//
//  Maintainer:        Simon Southwell email:  simon.southwell@gmail.com
//  Contributor(s):
//     Simon Southwell simon.southwell@gmail.com
//
//
//  Description:
//      Verilog wrapper for Altera PCIe Component with Avalon Master busses
//
//
//  Revision History:
//    Date      Version    Description
//    01/2026   2026.01       Initial revision
//
//
//  This file is part of OSVVM.
//
//  Copyright (c) 2026 by [OSVVM Authors](../../../AUTHORS.md).
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

module pcie1epavmm
(

  input                RefClk,
  input                PipeClk,
  input                nReset,

  // BAR0 Avalon memory mapped master
  output [31:0]        Bar0Address,
  output               Bar0Read,
  input                Bar0WaitRequest,
  output               Bar0Write,
  input                Bar0ReadDataValid,
  input  [63:0]        Bar0ReadData,
  output [63:0]        Bar0WriteData,
  output  [7:0]        Bar0ByteEnable,
  output  [6:0]        Bar0BurstCount,

  // PIPE lane 0
  output  [7:0]        TxData,
  output               TxDataK,

  output               TxDetectRx,
  output               TxElecIdle,
  output               TxCompliance,
  output               RxPolarity,
  output  [1:0]        PowerDown,
  output  [1:0]        Rate,
  output               TxDemph,
  output  [2:0]        TxMargin,
  output               TxSwing,

  input   [7:0]        RxData,
  input                RxDataK,
  input                RxValid,
  input                RxElecIdle,
  input   [2:0]        RxStatus,
  input                PhyStatus,

  // Useful debug signals
  output [4:0]         LtssmState,
  output [2:0]         EidleInferSel,
  output               coreclkout
  
);

localparam reconfig_to_xcvr_width   = 350;
localparam reconfig_from_xcvr_width = 230;

  altpcie_cv_hip_avmm_hwtcl # (

    .pll_refclk_freq_hwtcl                             ("100 MHz"),
    .enable_slot_register_hwtcl                        (0),
    .port_type_hwtcl                                   ("Native endpoint"),
    .bypass_cdc_hwtcl                                  ("false"),
    .enable_rx_buffer_checking_hwtcl                   ("false"),
    .single_rx_detect_hwtcl                            (1),
    .use_crc_forwarding_hwtcl                          (0),
    .ast_width_hwtcl                                   ("Avalon-ST 64-bit"),
    .gen123_lane_rate_mode_hwtcl                       ("Gen1 (2.5 Gbps)"),
    .lane_mask_hwtcl                                   ("x1"),
    .disable_link_x2_support_hwtcl                     ("false"),
    .hip_hard_reset_hwtcl                              (1),
    .wrong_device_id_hwtcl                             ("disable"),
    .data_pack_rx_hwtcl                                ("disable"),
    .use_ast_parity                                    (0),
    .ltssm_1ms_timeout_hwtcl                           ("disable"),
    .ltssm_freqlocked_check_hwtcl                      ("disable"),
    .deskew_comma_hwtcl                                ("skp_eieos_deskw"),
    .port_link_number_hwtcl                            (1),
    .device_number_hwtcl                               (0),
    .bypass_clk_switch_hwtcl                           ("disable"),
    .pipex1_debug_sel_hwtcl                            ("disable"),
    .pclk_out_sel_hwtcl                                ("pclk"),
    .vendor_id_hwtcl                                   (5372),
    .device_id_hwtcl                                   (1),
    .revision_id_hwtcl                                 (1),
    .class_code_hwtcl                                  (163841),
    .subsystem_vendor_id_hwtcl                         (0),
    .subsystem_device_id_hwtcl                         (0),
    .no_soft_reset_hwtcl                               ("false"),
    .maximum_current_hwtcl                             (0),
    .d1_support_hwtcl                                  ("false"),
    .d2_support_hwtcl                                  ("false"),
    .d0_pme_hwtcl                                      ("false"),
    .d1_pme_hwtcl                                      ("false"),
    .d2_pme_hwtcl                                      ("false"),
    .d3_hot_pme_hwtcl                                  ("false"),
    .d3_cold_pme_hwtcl                                 ("false"),
    .use_aer_hwtcl                                     (0),
    .low_priority_vc_hwtcl                             ("single_vc"),
    .disable_snoop_packet_hwtcl                        ("false"),
    .max_payload_size_hwtcl                            (128),
    .surprise_down_error_support_hwtcl                 (0),
    .dll_active_report_support_hwtcl                   (0),
    .extend_tag_field_hwtcl                            ("32"),
    .endpoint_l0_latency_hwtcl                         (0),
    .endpoint_l1_latency_hwtcl                         (0),
    .indicator_hwtcl                                   (0),
    .slot_power_scale_hwtcl                            (0),
    .enable_l1_aspm_hwtcl                              ("false"),
    .l1_exit_latency_sameclock_hwtcl                   (0),
    .l1_exit_latency_diffclock_hwtcl                   (0),
    .hot_plug_support_hwtcl                            (0),
    .slot_power_limit_hwtcl                            (0),
    .slot_number_hwtcl                                 (0),
    .diffclock_nfts_count_hwtcl                        (255),
    .sameclock_nfts_count_hwtcl                        (255),
    .completion_timeout_hwtcl                          ("abcd"),
    .enable_completion_timeout_disable_hwtcl           (1),
    .extended_tag_reset_hwtcl                          ("false"),
    .ecrc_check_capable_hwtcl                          (0),
    .ecrc_gen_capable_hwtcl                            (0),
    .msi_multi_message_capable_hwtcl                   ("4"),
    .msi_64bit_addressing_capable_hwtcl                ("true"),
    .msi_masking_capable_hwtcl                         ("false"),
    .msi_support_hwtcl                                 ("true"),
    .interrupt_pin_hwtcl                               ("inta"),
    .enable_function_msix_support_hwtcl                (0),
    .msix_table_size_hwtcl                             (0),
    .msix_table_bir_hwtcl                              (0),
    .msix_table_offset_hwtcl                           ("0"),
    .msix_pba_bir_hwtcl                                (0),
    .msix_pba_offset_hwtcl                             ("0"),
    .bridge_port_vga_enable_hwtcl                      ("false"),
    .bridge_port_ssid_support_hwtcl                    ("false"),
    .ssvid_hwtcl                                       (0),
    .ssid_hwtcl                                        (0),
    .eie_before_nfts_count_hwtcl                       (4),
    .gen2_diffclock_nfts_count_hwtcl                   (255),
    .gen2_sameclock_nfts_count_hwtcl                   (255),
    .deemphasis_enable_hwtcl                           ("false"),
    .pcie_spec_version_hwtcl                           ("2.1"),
    .l0_exit_latency_sameclock_hwtcl                   (6),
    .l0_exit_latency_diffclock_hwtcl                   (6),
    .rx_ei_l0s_hwtcl                                   (0),
    .l2_async_logic_hwtcl                              ("disable"),
    .aspm_config_management_hwtcl                      ("false"),
    .atomic_op_routing_hwtcl                           ("false"),
    .atomic_op_completer_32bit_hwtcl                   ("false"),
    .atomic_op_completer_64bit_hwtcl                   ("false"),
    .cas_completer_128bit_hwtcl                        ("false"),
    .ltr_mechanism_hwtcl                               ("false"),
    .tph_completer_hwtcl                               ("false"),
    .extended_format_field_hwtcl                       ("true"),
    .atomic_malformed_hwtcl                            ("true"),
    .flr_capability_hwtcl                              (1),
    .enable_adapter_half_rate_mode_hwtcl               ("false"),
    .vc0_clk_enable_hwtcl                              ("true"),
    .bar0_io_space_hwtcl                               ("Disabled"),
    .bar0_64bit_mem_space_hwtcl                        ("Disabled"),
    .bar0_prefetchable_hwtcl                           ("Disabled"),
    .bar0_size_mask_hwtcl                              (12),
    .bar1_io_space_hwtcl                               ("Disabled"),
    .bar1_64bit_mem_space_hwtcl                        ("Disabled"),
    .bar1_prefetchable_hwtcl                           ("Disabled"),
    .bar1_size_mask_hwtcl                              (0),
    .bar2_io_space_hwtcl                               ("Disabled"),
    .bar2_64bit_mem_space_hwtcl                        ("Disabled"),
    .bar2_prefetchable_hwtcl                           ("Disabled"),
    .bar2_size_mask_hwtcl                              (0),
    .bar3_io_space_hwtcl                               ("Disabled"),
    .bar3_64bit_mem_space_hwtcl                        ("Disabled"),
    .bar3_prefetchable_hwtcl                           ("Disabled"),
    .bar3_size_mask_hwtcl                              (0),
    .bar4_io_space_hwtcl                               ("Disabled"),
    .bar4_64bit_mem_space_hwtcl                        ("Disabled"),
    .bar4_prefetchable_hwtcl                           ("Disabled"),
    .bar4_size_mask_hwtcl                              (0),
    .bar5_io_space_hwtcl                               ("Disabled"),
    .bar5_64bit_mem_space_hwtcl                        ("Disabled"),
    .bar5_prefetchable_hwtcl                           ("Disabled"),
    .bar5_size_mask_hwtcl                              (0),
    .expansion_base_address_register_hwtcl             (0),
    .io_window_addr_width_hwtcl                        (0),
    .prefetchable_mem_window_addr_width_hwtcl          (0),
    .skp_os_gen3_count_hwtcl                           (0),
    .tx_cdc_almost_empty_hwtcl                         (5),
    .rx_cdc_almost_full_hwtcl                          (12),
    .tx_cdc_almost_full_hwtcl                          (11),
    .rx_l0s_count_idl_hwtcl                            (0),
    .cdc_dummy_insert_limit_hwtcl                      (11),
    .ei_delay_powerdown_count_hwtcl                    (10),
    .millisecond_cycle_count_hwtcl                     (124250),
    .skp_os_schedule_count_hwtcl                       (0),
    .fc_init_timer_hwtcl                               (1024),
    .l01_entry_latency_hwtcl                           (31),
    .flow_control_update_count_hwtcl                   (30),
    .flow_control_timeout_count_hwtcl                  (200),
    .credit_buffer_allocation_aux_hwtcl                ("absolute"),
    .vc0_rx_flow_ctrl_posted_header_hwtcl              (16),
    .vc0_rx_flow_ctrl_posted_data_hwtcl                (16),
    .vc0_rx_flow_ctrl_nonposted_header_hwtcl           (16),
    .vc0_rx_flow_ctrl_nonposted_data_hwtcl             (0),
    .vc0_rx_flow_ctrl_compl_header_hwtcl               (0),
    .vc0_rx_flow_ctrl_compl_data_hwtcl                 (0),
    .rx_ptr0_posted_dpram_min_hwtcl                    (0),
    .rx_ptr0_posted_dpram_max_hwtcl                    (0),
    .rx_ptr0_nonposted_dpram_min_hwtcl                 (0),
    .rx_ptr0_nonposted_dpram_max_hwtcl                 (0),
    .retry_buffer_last_active_address_hwtcl            (255),
    .retry_buffer_memory_settings_hwtcl                (0),
    .vc0_rx_buffer_memory_settings_hwtcl               (0),
    .in_cvp_mode_hwtcl                                 (0),
    .slotclkcfg_hwtcl                                  (1),
    .reconfig_to_xcvr_width                            (reconfig_to_xcvr_width),
    .set_pld_clk_x1_625MHz_hwtcl                       (0),
    .reconfig_from_xcvr_width                          (reconfig_from_xcvr_width),
    .enable_l0s_aspm_hwtcl                             ("true"),
    .cpl_spc_header_hwtcl                              (67),
    .cpl_spc_data_hwtcl                                (269),
    .coreclkout_hip_phaseshift_hwtcl                   ("0 ps"),
    .pldclk_hip_phase_shift_hwtcl                      ("0 ps"),
    .port_width_be_hwtcl                               (8),
    .port_width_data_hwtcl                             (64),
    .reserved_debug_hwtcl                              (0),
    .hip_reconfig_hwtcl                                (0),
    .user_id_hwtcl                                     (0),
    .vsec_id_hwtcl                                     (40960),
    .vsec_rev_hwtcl                                    (0),
    .gen3_rxfreqlock_counter_hwtcl                     (0),
    .gen3_skip_ph2_ph3_hwtcl                           (0),
    .g3_bypass_equlz_hwtcl                             (0),
    .cvp_rate_sel_hwtcl                                ("full_rate"),
    .cvp_data_compressed_hwtcl                         ("false"),
    .cvp_data_encrypted_hwtcl                          ("false"),
    .cvp_mode_reset_hwtcl                              ("false"),
    .cvp_clk_reset_hwtcl                               ("false"),
    .cseb_cpl_status_during_cvp_hwtcl                  ("config_retry_status"),
    .core_clk_sel_hwtcl                                ("pld_clk"),

    .rpre_emph_a_val_hwtcl                             (11),
    .rpre_emph_b_val_hwtcl                             (0),
    .rpre_emph_c_val_hwtcl                             (22),
    .rpre_emph_d_val_hwtcl                             (12),
    .rpre_emph_e_val_hwtcl                             (21),
    .rvod_sel_a_val_hwtcl                              (50),
    .rvod_sel_b_val_hwtcl                              (34),
    .rvod_sel_c_val_hwtcl                              (50),
    .rvod_sel_d_val_hwtcl                              (50),
    .rvod_sel_e_val_hwtcl                              (9),
    .register_pipe_signals_hwtcl                       ("true"),
    .no_command_completed_hwtcl                        ("false"),
    .use_tl_cfg_sync_hwtcl                             (1),

    /// Bridge Parameters
    .CG_ENABLE_A2P_INTERRUPT                           (0),
    .CG_RXM_IRQ_NUM                                    (16),
    .CB_PCIE_MODE                                      (1), // ???
    .CB_PCIE_RX_LITE                                   (0),
    .CB_RXM_DATA_WIDTH                                 (64),
    .CB_A2P_ADDR_MAP_IS_FIXED                          (0),
    .CB_A2P_ADDR_MAP_NUM_ENTRIES                       (2),
    .CG_AVALON_S_ADDR_WIDTH                            (21),
    .CG_IMPL_CRA_AV_SLAVE_PORT                         (0), // ???
    .a2p_pass_thru_bits                                (20),
    //.CB_P2A_AVALON_ADDR_B0                             (32'h00000000),
    //.CB_P2A_AVALON_ADDR_B1                             (32'h00000000),
    //.CB_P2A_AVALON_ADDR_B2                             (32'h00000000),
    //.CB_P2A_AVALON_ADDR_B3                             (32'h00000000),
    //.CB_P2A_AVALON_ADDR_B4                             (32'h00000000),
    //.CB_P2A_AVALON_ADDR_B5                             (32'h00000000),
    //.CB_P2A_AVALON_ADDR_B6                             (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_0_LOW                 (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_0_HIGH                (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_1_LOW                 (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_1_HIGH                (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_2_LOW                 (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_2_HIGH                (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_3_LOW                 (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_3_HIGH                (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_4_LOW                 (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_4_HIGH                (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_5_LOW                 (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_5_HIGH                (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_6_LOW                 (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_6_HIGH                (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_7_LOW                 (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_7_HIGH                (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_8_LOW                 (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_8_HIGH                (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_9_LOW                 (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_9_HIGH                (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_10_LOW                (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_10_HIGH               (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_11_LOW                (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_11_HIGH               (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_12_LOW                (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_12_HIGH               (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_13_LOW                (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_13_HIGH               (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_14_LOW                (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_14_HIGH               (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_15_LOW                (32'h00000000),
    //.CB_A2P_ADDR_MAP_FIXED_TABLE_15_HIGH               (32'h00000000),
    //.bar_prefetchable                                  (0),
    .avmm_width_hwtcl                                  (64),
    .avmm_burst_width_hwtcl                            (7),
    .AVALON_ADDR_WIDTH                                 (32),
    .BYPASSS_A2P_TRANSLATION                           (0),
    .CG_ENABLE_ADVANCED_INTERRUPT                      (0)

  ) altpcie_i  (

    // Reset signals
    .pin_perst                                         (nReset),        // input
    .npor                                              (nReset),        // input
    .reset_status                                      (),              // output

    // Serdes related
    .refclk                                            (RefClk),         // input

    // HIP control signals
    .hpg_ctrler                                        (4'b0000),       // input  [4 : 0]

    // Driven by the testbench
    // Input PIPE simulation for simulation only
    .simu_mode_pipe                                    (1'b1),          // input
    .test_in                                           (32'h00000000),  // input [31 : 0]
    .testout                                           (),              // output [127 : 0]
    .sim_pipe_rate                                     (Rate),          // output [1 : 0]
    .sim_pipe_pclk_in                                  (PipeClk),       // input
    .sim_pipe_pclk_out                                 (),              // output
    .sim_pipe_clk250_out                               (),              // output
    .sim_pipe_clk500_out                               (),              // output
    .sim_ltssmstate                                    (LtssmState),    // output [4 : 0]
    .phystatus0                                        (PhyStatus),     // input
    .phystatus1                                        (1'b0),             // input
    .phystatus2                                        (1'b0),             // input
    .phystatus3                                        (1'b0),             // input
    .phystatus4                                        (1'b0),             // input
    .phystatus5                                        (1'b0),             // input
    .phystatus6                                        (1'b0),             // input
    .phystatus7                                        (1'b0),             // input
    .rxdata0                                           (RxData),           // input  [7 : 0]
    .rxdata1                                           (8'h00),            // input  [7 : 0]
    .rxdata2                                           (8'h00),            // input  [7 : 0]
    .rxdata3                                           (8'h00),            // input  [7 : 0]
    .rxdata4                                           (8'h00),            // input  [7 : 0]
    .rxdata5                                           (8'h00),            // input  [7 : 0]
    .rxdata6                                           (8'h00),            // input  [7 : 0]
    .rxdata7                                           (8'h00),            // input  [7 : 0]
    .rxdatak0                                          (RxDataK),          // input
    .rxdatak1                                          (1'b0),             // input
    .rxdatak2                                          (1'b0),             // input
    .rxdatak3                                          (1'b0),             // input
    .rxdatak4                                          (1'b0),             // input
    .rxdatak5                                          (1'b0),             // input
    .rxdatak6                                          (1'b0),             // input
    .rxdatak7                                          (1'b0),             // input
    .rxelecidle0                                       (RxElecIdle),       // input
    .rxelecidle1                                       (1'b0),             // input
    .rxelecidle2                                       (1'b0),             // input
    .rxelecidle3                                       (1'b0),             // input
    .rxelecidle4                                       (1'b0),             // input
    .rxelecidle5                                       (1'b0),             // input
    .rxelecidle6                                       (1'b0),             // input
    .rxelecidle7                                       (1'b0),             // input
    .rxfreqlocked0                                     (1'b1),             // input
    .rxfreqlocked1                                     (1'b1),             // input
    .rxfreqlocked2                                     (1'b1),             // input
    .rxfreqlocked3                                     (1'b1),             // input
    .rxfreqlocked4                                     (1'b1),             // input
    .rxfreqlocked5                                     (1'b1),             // input
    .rxfreqlocked6                                     (1'b1),             // input
    .rxfreqlocked7                                     (1'b1),             // input
    .rxstatus0                                         (RxStatus),         // input  [2 : 0]
    .rxstatus1                                         (3'b000),           // input  [2 : 0]
    .rxstatus2                                         (3'b000),           // input  [2 : 0]
    .rxstatus3                                         (3'b000),           // input  [2 : 0]
    .rxstatus4                                         (3'b000),           // input  [2 : 0]
    .rxstatus5                                         (3'b000),           // input  [2 : 0]
    .rxstatus6                                         (3'b000),           // input  [2 : 0]
    .rxstatus7                                         (3'b000),           // input  [2 : 0]
    .rxdataskip0                                       (1'b0),             // input
    .rxdataskip1                                       (1'b0),             // input
    .rxdataskip2                                       (1'b0),             // input
    .rxdataskip3                                       (1'b0),             // input
    .rxdataskip4                                       (1'b0),             // input
    .rxdataskip5                                       (1'b0),             // input
    .rxdataskip6                                       (1'b0),             // input
    .rxdataskip7                                       (1'b0),             // input
    .rxblkst0                                          (1'b0),             // input
    .rxblkst1                                          (1'b0),             // input
    .rxblkst2                                          (1'b0),             // input
    .rxblkst3                                          (1'b0),             // input
    .rxblkst4                                          (1'b0),             // input
    .rxblkst5                                          (1'b0),             // input
    .rxblkst6                                          (1'b0),             // input
    .rxblkst7                                          (1'b0),             // input
    .rxsynchd0                                         (2'b00),            // input  [1 : 0]
    .rxsynchd1                                         (2'b00),            // input  [1 : 0]
    .rxsynchd2                                         (2'b00),            // input  [1 : 0]
    .rxsynchd3                                         (2'b00),            // input  [1 : 0]
    .rxsynchd4                                         (2'b00),            // input  [1 : 0]
    .rxsynchd5                                         (2'b00),            // input  [1 : 0]
    .rxsynchd6                                         (2'b00),            // input  [1 : 0]
    .rxsynchd7                                         (2'b00),            // input  [1 : 0]
    .rxvalid0                                          (RxValid),          // input
    .rxvalid1                                          (1'b0),             // input
    .rxvalid2                                          (1'b0),             // input
    .rxvalid3                                          (1'b0),             // input
    .rxvalid4                                          (1'b0),             // input
    .rxvalid5                                          (1'b0),             // input
    .rxvalid6                                          (1'b0),             // input
    .rxvalid7                                          (1'b0),             // input

    // Output Pipe interface
    .eidleinfersel0                                     (EidleInferSel),   // output [2 : 0]
    .eidleinfersel1                                     (),                // output [2 : 0]
    .eidleinfersel2                                     (),                // output [2 : 0]
    .eidleinfersel3                                     (),                // output [2 : 0]
    .eidleinfersel4                                     (),                // output [2 : 0]
    .eidleinfersel5                                     (),                // output [2 : 0]
    .eidleinfersel6                                     (),                // output [2 : 0]
    .eidleinfersel7                                     (),                // output [2 : 0]
    .powerdown0                                         (PowerDown),       // output [1 : 0]
    .powerdown1                                         (),                // output [1 : 0]
    .powerdown2                                         (),                // output [1 : 0]
    .powerdown3                                         (),                // output [1 : 0]
    .powerdown4                                         (),                // output [1 : 0]
    .powerdown5                                         (),                // output [1 : 0]
    .powerdown6                                         (),                // output [1 : 0]
    .powerdown7                                         (),                // output [1 : 0]
    .rxpolarity0                                        (RxPolarity),      // output
    .rxpolarity1                                        (),                // output
    .rxpolarity2                                        (),                // output
    .rxpolarity3                                        (),                // output
    .rxpolarity4                                        (),                // output
    .rxpolarity5                                        (),                // output
    .rxpolarity6                                        (),                // output
    .rxpolarity7                                        (),                // output
    .txcompl0                                           (TxCompliance),    // output
    .txcompl1                                           (),                // output
    .txcompl2                                           (),                // output
    .txcompl3                                           (),                // output
    .txcompl4                                           (),                // output
    .txcompl5                                           (),                // output
    .txcompl6                                           (),                // output
    .txcompl7                                           (),                // output
    .txdata0                                            (TxData),          // output [7 : 0]
    .txdata1                                            (),                // output [7 : 0]
    .txdata2                                            (),                // output [7 : 0]
    .txdata3                                            (),                // output [7 : 0]
    .txdata4                                            (),                // output [7 : 0]
    .txdata5                                            (),                // output [7 : 0]
    .txdata6                                            (),                // output [7 : 0]
    .txdata7                                            (),                // output [7 : 0]
    .txdatak0                                           (TxDataK),         // output
    .txdatak1                                           (),                // output
    .txdatak2                                           (),                // output
    .txdatak3                                           (),                // output
    .txdatak4                                           (),                // output
    .txdatak5                                           (),                // output
    .txdatak6                                           (),                // output
    .txdatak7                                           (),                // output
    .txdatavalid0                                       (),                // output
    .txdatavalid1                                       (),                // output
    .txdatavalid2                                       (),                // output
    .txdatavalid3                                       (),                // output
    .txdatavalid4                                       (),                // output
    .txdatavalid5                                       (),                // output
    .txdatavalid6                                       (),                // output
    .txdatavalid7                                       (),                // output
    .txdetectrx0                                        (TxDetectRx),      // output
    .txdetectrx1                                        (),                // output
    .txdetectrx2                                        (),                // output
    .txdetectrx3                                        (),                // output
    .txdetectrx4                                        (),                // output
    .txdetectrx5                                        (),                // output
    .txdetectrx6                                        (),                // output
    .txdetectrx7                                        (),                // output
    .txelecidle0                                        (TxElecIdle),      // output
    .txelecidle1                                        (),                // output
    .txelecidle2                                        (),                // output
    .txelecidle3                                        (),                // output
    .txelecidle4                                        (),                // output
    .txelecidle5                                        (),                // output
    .txelecidle6                                        (),                // output
    .txelecidle7                                        (),                // output
    .txmargin0                                          (TxMargin),        // output [2 : 0]
    .txmargin1                                          (),                // output [2 : 0]
    .txmargin2                                          (),                // output [2 : 0]
    .txmargin3                                          (),                // output [2 : 0]
    .txmargin4                                          (),                // output [2 : 0]
    .txmargin5                                          (),                // output [2 : 0]
    .txmargin6                                          (),                // output [2 : 0]
    .txmargin7                                          (),                // output [2 : 0]
    .txdeemph0                                          (TxDemph),         // output
    .txdeemph1                                          (),                // output
    .txdeemph2                                          (),                // output
    .txdeemph3                                          (),                // output
    .txdeemph4                                          (),                // output
    .txdeemph5                                          (),                // output
    .txdeemph6                                          (),                // output
    .txdeemph7                                          (),                // output
    .txswing0                                           (TxSwing),         // output
    .txswing1                                           (),                // output
    .txswing2                                           (),                // output
    .txswing3                                           (),                // output
    .txswing4                                           (),                // output
    .txswing5                                           (),                // output
    .txswing6                                           (),                // output
    .txswing7                                           (),                // output
    .txblkst0                                           (),                // output
    .txblkst1                                           (),                // output
    .txblkst2                                           (),                // output
    .txblkst3                                           (),                // output
    .txblkst4                                           (),                // output
    .txblkst5                                           (),                // output
    .txblkst6                                           (),                // output
    .txblkst7                                           (),                // output
    .txsynchd0                                          (),                // output [1 : 0]
    .txsynchd1                                          (),                // output [1 : 0]
    .txsynchd2                                          (),                // output [1 : 0]
    .txsynchd3                                          (),                // output [1 : 0]
    .txsynchd4                                          (),                // output [1 : 0]
    .txsynchd5                                          (),                // output [1 : 0]
    .txsynchd6                                          (),                // output [1 : 0]
    .txsynchd7                                          (),                // output [1 : 0]
    .currentcoeff0                                      (),                // output [17 : 0]
    .currentcoeff1                                      (),                // output [17 : 0]
    .currentcoeff2                                      (),                // output [17 : 0]
    .currentcoeff3                                      (),                // output [17 : 0]
    .currentcoeff4                                      (),                // output [17 : 0]
    .currentcoeff5                                      (),                // output [17 : 0]
    .currentcoeff6                                      (),                // output [17 : 0]
    .currentcoeff7                                      (),                // output [17 : 0]
    .currentrxpreset0                                   (),                // output [2 : 0]
    .currentrxpreset1                                   (),                // output [2 : 0]
    .currentrxpreset2                                   (),                // output [2 : 0]
    .currentrxpreset3                                   (),                // output [2 : 0]
    .currentrxpreset4                                   (),                // output [2 : 0]
    .currentrxpreset5                                   (),                // output [2 : 0]
    .currentrxpreset6                                   (),                // output [2 : 0]
    .currentrxpreset7                                   (),                // output [2 : 0]
    .coreclkout                                         (coreclkout),      // output

    // Reconfig GXB
    .reconfig_to_xcvr                                   ({reconfig_to_xcvr_width{1'b0}}),               // input                [reconfig_to_xcvr_width-1:0]
    .busy_xcvr_reconfig                                 (1'b0),            // input
    .reconfig_from_xcvr                                 (),                // output               [reconfig_from_xcvr_width-1:0]
    .fixedclk_locked                                    (),

    // serial interface
    .rx_in0                                             (1'b0),            // input
    .rx_in1                                             (1'b0),            // input
    .rx_in2                                             (1'b0),            // input
    .rx_in3                                             (1'b0),            // input
    .rx_in4                                             (1'b0),            // input
    .rx_in5                                             (1'b0),            // input
    .rx_in6                                             (1'b0),            // input
    .rx_in7                                             (1'b0),            // input

    .tx_out0                                            (),                // output
    .tx_out1                                            (),                // output
    .tx_out2                                            (),                // output
    .tx_out3                                            (),                // output
    .tx_out4                                            (),                // output
    .tx_out5                                            (),                // output
    .tx_out6                                            (),                // output
    .tx_out7                                            (),                // output

    // Avalon Tx Slave interface
    .TxsChipSelect_i                                    (1'b0),            // input
    .TxsRead_i                                          (1'b0),            // input
    .TxsWrite_i                                         (1'b0),            // input
    .TxsWriteData_i                                     (32'h0),           // input  [avmm_width_hwtcl-1:0]
    .TxsBurstCount_i                                    (7'h0),            // input  [avmm_burst_width_hwtcl-1:0]
    .TxsAddress_i                                      (13'h0),            // input  [CG_AVALON_S_ADDR_WIDTH-1:0]
    .TxsByteEnable_i                                    (8'h0),            // input  [(avmm_width_hwtcl/8)-1:0]
    .TxsReadDataValid_o                                     (),            // output
    .TxsReadData_o                                          (),            // output  [avmm_width_hwtcl-1:0]
    .TxsWaitRequest_o                                       (),            // output

    // Avalon- RX Master
    .RxmIrq_i                                          (16'h0),            // input    [15:0]

    // Avalon Rx Master interface 0
    .RxmWrite_0_o                                      (Bar0Write),        // output
    .RxmAddress_0_o                                    (Bar0Address),      // output [AVALON_ADDR_WIDTH-1:0]
    .RxmWriteData_0_o                                  (Bar0WriteData),    // output [avmm_width_hwtcl-1:0]
    .RxmByteEnable_0_o                                 (Bar0ByteEnable),   // output [(avmm_width_hwtcl/8)-1:0]
    .RxmBurstCount_0_o                                 (Bar0BurstCount),   // output [avmm_burst_width_hwtcl-1:0]
    .RxmWaitRequest_0_i                                (Bar0WaitRequest),  // input
    .RxmRead_0_o                                       (Bar0Read),         // output
    .RxmReadData_0_i                                   (Bar0ReadData),     // input  [avmm_width_hwtcl-1:0]
    .RxmReadDataValid_0_i                              (Bar0ReadDataValid),// input

    // Avalon Rx Master interface 1
    .RxmWrite_1_o                                      (),                // output
    .RxmAddress_1_o                                    (),                // output [AVALON_ADDR_WIDTH-1:0]
    .RxmWriteData_1_o                                  (),                // output [avmm_width_hwtcl-1:0]
    .RxmByteEnable_1_o                                 (),                // output [(avmm_width_hwtcl/8)-1:0]
    .RxmBurstCount_1_o                                 (),                // output [avmm_burst_width_hwtcl-1:0]
    .RxmWaitRequest_1_i                                (1'b0),            // input
    .RxmRead_1_o                                       (),                // output
    .RxmReadData_1_i                                   (),                // input  [avmm_width_hwtcl-1:0]
    .RxmReadDataValid_1_i                              (1'b0),            // input

    // Avalon Rx Master interface 2
    .RxmWrite_2_o                                      (),                 // output
    .RxmAddress_2_o                                    (),                 // output [AVALON_ADDR_WIDTH-1:0]
    .RxmWriteData_2_o                                  (),                 // output [avmm_width_hwtcl-1:0]
    .RxmByteEnable_2_o                                 (),                 // output [(avmm_width_hwtcl/8)-1:0]
    .RxmBurstCount_2_o                                 (),                 // output [avmm_burst_width_hwtcl-1:0]
    .RxmWaitRequest_2_i                                (1'b0),             // input
    .RxmRead_2_o                                       (),                 // output
    .RxmReadData_2_i                                   (),                 // input  [avmm_width_hwtcl-1:0]
    .RxmReadDataValid_2_i                              (1'b0),             // input

    // Avalon Rx Master interface 3
    .RxmWrite_3_o                                      (),                 // output
    .RxmAddress_3_o                                    (),                 // output [AVALON_ADDR_WIDTH-1:0]
    .RxmWriteData_3_o                                  (),                 // output [avmm_width_hwtcl-1:0]
    .RxmByteEnable_3_o                                 (),                 // output [(avmm_width_hwtcl/8)-1:0]
    .RxmBurstCount_3_o                                 (),                 // output [avmm_burst_width_hwtcl-1:0]
    .RxmWaitRequest_3_i                                (1'b0),             // input
    .RxmRead_3_o                                       (),                 // output
    .RxmReadData_3_i                                   (),                 // input  [avmm_width_hwtcl-1:0]
    .RxmReadDataValid_3_i                              (1'b0),             // input

    // Avalon Rx Master interface 4
    .RxmWrite_4_o                                      (),                 // output
    .RxmAddress_4_o                                    (),                 // output [AVALON_ADDR_WIDTH-1:0]
    .RxmWriteData_4_o                                  (),                 // output [avmm_width_hwtcl-1:0]
    .RxmByteEnable_4_o                                 (),                 // output [(avmm_width_hwtcl/8)-1:0]
    .RxmBurstCount_4_o                                 (),                 // output [avmm_burst_width_hwtcl-1:0]
    .RxmWaitRequest_4_i                                (1'b0),             // input
    .RxmRead_4_o                                       (),                 // output
    .RxmReadData_4_i                                   (),                 // input  [avmm_width_hwtcl-1:0]
    .RxmReadDataValid_4_i                              (1'b0),             // input

    // Avalon Rx Master interface 5
    .RxmWrite_5_o                                      (),                 // output
    .RxmAddress_5_o                                    (),                 // output [AVALON_ADDR_WIDTH-1:0]
    .RxmWriteData_5_o                                  (),                 // output [avmm_width_hwtcl-1:0]
    .RxmByteEnable_5_o                                 (),                 // output [(avmm_width_hwtcl/8)-1:0]
    .RxmBurstCount_5_o                                 (),                 // output [avmm_burst_width_hwtcl-1:0]
    .RxmWaitRequest_5_i                                (1'b0),             // input
    .RxmRead_5_o                                       (),                 // output
    .RxmReadData_5_i                                   (),                 // input  [avmm_width_hwtcl-1:0]
    .RxmReadDataValid_5_i                              (1'b0),             // input

    // Avalon Rx Master interface 6
    .RxmWrite_6_o                                      (),                 // output
    .RxmAddress_6_o                                    (),                 // output [AVALON_ADDR_WIDTH-1:0]
    .RxmWriteData_6_o                                  (),                 // output [avmm_width_hwtcl-1:0]
    .RxmByteEnable_6_o                                 (),                 // output [(avmm_width_hwtcl/8)-1:0]
    .RxmBurstCount_6_o                                 (),                 // output [avmm_burst_width_hwtcl-1:0]
    .RxmWaitRequest_6_i                                (1'b0),             // input
    .RxmRead_6_o                                       (),                 // output
    .RxmReadData_6_i                                   (),                 // input  [avmm_width_hwtcl-1:0]
    .RxmReadDataValid_6_i                              (1'b0),             // input

    // Avalon Control Register Access (CRA) Slave (This is 32-bit interface)
    .CraChipSelect_i                                   (1'b0),             // input
    .CraRead                                           (1'b0),             // input
    .CraWrite                                          (1'b0),             // input
    .CraWriteData_i                                    (32'h0),            // input  [31:0]
    .CraAddress_i                                      (14'h0),            // input  [13:0]
    .CraByteEnable_i                                   (4'h0),             // input  [3:0]
    .CraReadData_o                                     (),                 // output [31:0]
    .CraWaitRequest_o                                  (),                 // output
    .CraIrq_o                                          (),                 // output

    /// MSI/MSI-X/INTx supported signals
    .MsiIntfc_o                                        (),                // output  [81:0]
    .MsiControl_o                                      (),                // output  [15:0]
    .MsixIntfc_o                                       (),                // output  [15:0]
    .IntxReq_i                                         (1'b0),            // input
    .IntxAck_o                                         (),                // output

    /// Hip Status Extention
    .rx_st_valid                                       (),                // output
    .rx_st_sop                                         (),                // output
    .rx_st_eop                                         (),                // output
    .rx_st_err                                         (),                // output
    .rx_st_data                                        (),                // output  [avmm_width_hwtcl-1:0]
    .rx_st_bar                                         (),                // output  [7:0]
    .tx_st_ready                                       (),                // output
    .pld_clk_inuse                                     (),                // output
    .dlup_exit                                         (),                // output
    .hotrst_exit                                       (),                // output
    .l2_exit                                           (),                // output
    .currentspeed                                      (),                // output  [1:0]
    .ltssmstate                                        (),                // output  [4:0]
    .derr_cor_ext_rcv                                  (),                // output
    .derr_cor_ext_rpl                                  (),                // output
    .derr_rpl                                          (),                // output
    .int_status                                        (),                // output  [3:0]
    .serr_out                                          (),                // output
    .tl_cfg_add                                        (),                // output  [3:0]
    .tl_cfg_ctl                                        (),                // output  [31:0]
    .tl_cfg_sts                                        (),                // output  [52:0]
    .pme_to_sr                                         (),                // output
    .lane_act                                          (),                // output  [3:0]
    .ev128ns                                           (),                // output
    .ev1us                                             (),                // output
    .ko_cpl_spc_header                                 (),                // output  [7 : 0]
    .ko_cpl_spc_data                                   ()                 // output  [11: 0]
  );

endmodule