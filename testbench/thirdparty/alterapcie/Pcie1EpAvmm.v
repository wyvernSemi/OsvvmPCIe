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

    .port_type_hwtcl                                   ("Native endpoint"),    // DEFAULT "Native endpoint"
    .gen123_lane_rate_mode_hwtcl                       ("gen1"),               // DEFAULT "gen1"
    .pll_refclk_freq_hwtcl                             ("100 MHz"),            // DEFAULT "100 MHz"
    .lane_mask_hwtcl                                   ("x1"),                 // default "x4"

    .vendor_id_hwtcl                                   (5372),                 // default 4466
    .device_id_hwtcl                                   (1),                    // default 57345
    .revision_id_hwtcl                                 (1),                    // default 1
    .class_code_hwtcl                                  (163841),               // default 16711680
    .subsystem_vendor_id_hwtcl                         (0),                    // default 4466
    .subsystem_device_id_hwtcl                         (0),                    // default 57345

    .max_payload_size_hwtcl                            (128),                  // default 256

    .bar0_io_space_hwtcl                               ("Disabled"),           // DEFAULT "Disabled"
    .bar0_64bit_mem_space_hwtcl                        ("Disabled"),           // DEFAULT "Disabled"
    .bar0_prefetchable_hwtcl                           ("Disabled"),           // DEFAULT "Disabled"
    .bar0_size_mask_hwtcl                              (12),                   // default "256 MBytes - 28 bits"

    .vc0_rx_flow_ctrl_posted_header_hwtcl              (16),                   // default 50
    .vc0_rx_flow_ctrl_posted_data_hwtcl                (16),                   // default 360
    .vc0_rx_flow_ctrl_nonposted_header_hwtcl           (16),                   // default 54
    .vc0_rx_flow_ctrl_nonposted_data_hwtcl             (0),                    // DEFAULT 0
    .vc0_rx_flow_ctrl_compl_header_hwtcl               (0),                    // default 112
    .vc0_rx_flow_ctrl_compl_data_hwtcl                 (0),                    // default 448
    .cpl_spc_header_hwtcl                              (67),                   // default 195
    .cpl_spc_data_hwtcl                                (269),                  // default 781

    .single_rx_detect_hwtcl                            (1),                    // default 0

    .CB_A2P_ADDR_MAP_NUM_ENTRIES                       (2),                    // default 1
    .CG_IMPL_CRA_AV_SLAVE_PORT                         (0),                    // default 1
    .a2p_pass_thru_bits                                (20)                    // default 24

  ) altpcie_i  (

    // Reset signals
    .pin_perst                                         (nReset),               // input
    .npor                                              (nReset),               // input

    // Serdes related
    .refclk                                            (RefClk),               // input
    .coreclkout                                        (coreclkout),           // output

    // Input PIPE simulation for simulation only
    .simu_mode_pipe                                    (1'b1),                 // input
    .sim_pipe_rate                                     (Rate),                 // output [1 : 0]
    .sim_pipe_pclk_in                                  (PipeClk),              // input
    .sim_ltssmstate                                    (LtssmState),           // output [4 : 0]

    // Input Pipe interface
    .phystatus0                                        (PhyStatus),            // input
    .rxdata0                                           (RxData),               // input  [7 : 0]
    .rxdatak0                                          (RxDataK),              // input
    .rxelecidle0                                       (RxElecIdle),           // input
    .rxstatus0                                         (RxStatus),             // input  [2 : 0]
    .rxvalid0                                          (RxValid),              // input

    // Output Pipe interface
    .eidleinfersel0                                    (EidleInferSel),        // output [2 : 0]
    .powerdown0                                        (PowerDown),            // output [1 : 0]
    .rxpolarity0                                       (RxPolarity),           // output
    .txcompl0                                          (TxCompliance),         // output
    .txdata0                                           (TxData),               // output [7 : 0]
    .txdatak0                                          (TxDataK),              // output
    .txdetectrx0                                       (TxDetectRx),           // output
    .txelecidle0                                       (TxElecIdle),           // output
    .txmargin0                                         (TxMargin),             // output [2 : 0]
    .txdeemph0                                         (TxDemph),              // output
    .txswing0                                          (TxSwing),              // output

    // Avalon Rx Master BAR0 interface
    .RxmWrite_0_o                                      (Bar0Write),            // output
    .RxmAddress_0_o                                    (Bar0Address),          // output [AVALON_ADDR_WIDTH-1:0]
    .RxmWriteData_0_o                                  (Bar0WriteData),        // output [avmm_width_hwtcl-1:0]
    .RxmByteEnable_0_o                                 (Bar0ByteEnable),       // output [(avmm_width_hwtcl/8)-1:0]
    .RxmBurstCount_0_o                                 (Bar0BurstCount),       // output [avmm_burst_width_hwtcl-1:0]
    .RxmWaitRequest_0_i                                (Bar0WaitRequest),      // input
    .RxmRead_0_o                                       (Bar0Read),             // output
    .RxmReadData_0_i                                   (Bar0ReadData),         // input  [avmm_width_hwtcl-1:0]
    .RxmReadDataValid_0_i                              (Bar0ReadDataValid),    // input

     // Tie off unused Avalon bus inputs
    .RxmWaitRequest_1_i                                (1'b0),                 // input
    .RxmReadDataValid_1_i                              (1'b0),                 // input
    .RxmWaitRequest_2_i                                (1'b0),                 // input
    .RxmReadDataValid_2_i                              (1'b0),                 // input
    .RxmWaitRequest_3_i                                (1'b0),                 // input
    .RxmReadDataValid_3_i                              (1'b0),                 // input
    .RxmWaitRequest_4_i                                (1'b0),                 // input
    .RxmReadDataValid_4_i                              (1'b0),                 // input
    .RxmWaitRequest_5_i                                (1'b0),                 // input
    .RxmReadDataValid_5_i                              (1'b0),                 // input
    .RxmWaitRequest_6_i                                (1'b0),                 // input
    .RxmReadDataValid_6_i                              (1'b0)                  // input
  );

endmodule