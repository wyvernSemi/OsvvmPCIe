// =========================================================================
//
//  File Name:         ltssm.h
//  Design Unit Name:
//  Revision:          OSVVM MODELS STANDARD VERSION
//
//  Maintainer:        Simon Southwell email:  simon.southwell@gmail.com
//  Contributor(s):
//    Simon Southwell      simon.southwell@gmail.com
//
//  Description:
//    Header for PCIe LTSSM partial implementation for use wqith PCIe C model
//
//  Revision History:
//    Date      Version    Description
//    09/2025   2026.01    Initial Version
//
//  This file is part of OSVVM.
//
//  Copyright (c) 2025 by [OSVVM Authors](../../AUTHORS.md)
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
// =========================================================================

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#include "pcie.h"

#ifdef __cplusplus
}
#endif

#ifdef OSVVM
#include "OsvvmVUserVPrint.h"
#endif

#ifdef __cplusplus
#define EXTERN extern "C"
#else
#define EXTERN extern
#endif

#ifndef _LTSSM_H_
#define _LTSSM_H_

#define LINK_INIT_NO_CHANGE  (-1)

typedef struct
{
    int ltssm_linknum;
    int ltssm_n_fts;
    int ltssm_ts_ctl;
    int ltssm_detect_quiet_to;
    int ltssm_enable_tests;
    int ltssm_force_tests;
    int ltssm_poll_active_tx_count;
    int ltssm_disable_disp_state;

} ConfigLinkInit_t;

#define INIT_CFG_LINK_STRUCT(_cfg) {                  \
  (_cfg).ltssm_linknum              = LINK_INIT_NO_CHANGE; \
  (_cfg).ltssm_n_fts                = LINK_INIT_NO_CHANGE; \
  (_cfg).ltssm_ts_ctl               = LINK_INIT_NO_CHANGE; \
  (_cfg).ltssm_detect_quiet_to      = LINK_INIT_NO_CHANGE; \
  (_cfg).ltssm_enable_tests         = LINK_INIT_NO_CHANGE; \
  (_cfg).ltssm_force_tests          = LINK_INIT_NO_CHANGE; \
  (_cfg).ltssm_poll_active_tx_count = LINK_INIT_NO_CHANGE; \
  (_cfg).ltssm_disable_disp_state    = LINK_INIT_NO_CHANGE; \
}

// Link initialisation
EXTERN void InitLink             (const int linkwidth,         const int node);
EXTERN void ConfigLinkInit       (const ConfigLinkInit_t cfg,  const int node);
EXTERN void ConfigurePcieLtssm   (const config_t         type, const int value, const int node);

#endif
