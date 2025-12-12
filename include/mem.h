// =========================================================================
//
//  File Name:         mem.h
//  Design Unit Name:
//  Revision:          OSVVM MODELS STANDARD VERSION
//
//  Maintainer:        Simon Southwell email:  simon.southwell@gmail.com
//  Contributor(s):
//    Simon Southwell      simon.southwell@gmail.com
//
//  Description:
//    PCIe VC model internal memory model header
//
//  Revision History:
//    Date      Version    Description
//    09/2025   ????.??    Initial Version
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

#ifndef _MEM_H_
#define _MEM_H_

// -------------------------------------------------------------------------
// INCLUDES
// -------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

#if !defined(OSVVM) && !defined(PCIEDPI)
#include "VUser.h"
#endif

#ifdef PCIEDPI
#include "pcie_dpi.h"
#endif

// -------------------------------------------------------------------------
// DEFINES
// -------------------------------------------------------------------------

#define TABLESIZE      (4096UL)
#define TABLEMASK      (TABLESIZE-1)

#define MEM_BAD_STATUS  1
#define MEM_GOOD_STATUS 0

// -------------------------------------------------------------------------
// TYPEDEFS
// -------------------------------------------------------------------------

typedef struct {
    char** p;
    uint64_t addr;
    bool     valid;
} PrimaryTbl_t, *pPrimaryTbl_t;

typedef uint16_t  PktData_t;
typedef uint16_t* pPktData_t;

// -------------------------------------------------------------------------
// PROTOTYPES
// -------------------------------------------------------------------------

extern void     InitialiseMem             (int node);
                                          
extern void     WriteRamByteBlock         (const uint64_t addr, const PktData_t* const data, const int fbe, const int lbe, const int length, const uint32_t node);
extern int      ReadRamByteBlock          (const uint64_t addr, PktData_t* const data, const int length, const uint32_t node);
                                          
extern void     WriteRamByte              (const uint64_t addr, const uint32_t data, const uint32_t node);
extern void     WriteRamWord              (const uint64_t addr, const uint32_t data, const int little_endian, const uint32_t node);
extern void     WriteRamHWord             (const uint64_t addr, const uint32_t data, const int little_endian, const uint32_t node);
extern void     WriteRamDWord             (const uint64_t addr, const uint64_t data, const int little_endian, const uint32_t node);
extern uint32_t ReadRamByte               (const uint64_t addr, const uint32_t node);
extern uint32_t ReadRamHWord              (const uint64_t addr, const int little_endian, const uint32_t node);
extern uint32_t ReadRamWord               (const uint64_t addr, const int little_endian, const uint32_t node);
extern uint64_t ReadRamDWord              (const uint64_t addr, const int little_endian, const uint32_t node);
                                          
extern void     WriteConfigSpace          (const uint32_t addr, const uint32_t data, const uint32_t node);
extern uint32_t ReadConfigSpace           (const uint32_t addr, const uint32_t node);
extern void     WriteConfigSpaceBuf       (const uint32_t addr, const PktData_t* const data, const int fbe, const int lbe, const int length, const bool use_mask, const uint32_t node);
extern void     ReadConfigSpaceBuf        (const uint32_t addr, PktData_t* const data, const int length, const uint32_t node);
extern void     WriteConfigSpaceMask      (const uint32_t addr, const uint32_t data, const uint32_t node);
extern uint32_t ReadConfigSpaceMask       (const uint32_t addr, const uint32_t node);
extern void     WriteConfigSpaceMaskBuf   (const uint32_t addr, const PktData_t* const data, const int length, const uint32_t node);
extern void     ReadConfigSpaceMaskBuf    (const uint32_t addr, PktData_t* const data, const int length, const uint32_t node);

extern bool     ReadConfigSpaceMaskBufChk (const uint32_t addr, PktData_t* const data, const int length, const bool check, const uint32_t node);
extern bool     ReadConfigSpaceBufChk     (const uint32_t addr, PktData_t* const data, const int length, const bool check, const uint32_t node);

#endif
