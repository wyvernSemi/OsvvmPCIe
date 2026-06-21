# CoSimPCIe

| Revision  |  Release Summary | 
------------|----------- 
| ????.??   | PCIe VC extended to drive DLLP and PHY traffic from MIT |
| 2026.05   | Added test bench using 3rd party PCIe EP
| 2026.01   | Initial release

## ????.?? June 2026
- The PCIe VC now supports MIT commands to drive and receive DLL packets and PHY OS/TS traffic
- New PCIe procedures for DLL/PHY traffic
- Added new tests to verify and demonstrate the DLL and PHY features
- Updated PCIe C model libraries to v1.9.4

## 2026.05 May 2026
- Added a test bench using the Altera [_Cyclone V Hard IP for PCI Express_](https://docs.altera.com/r/docs/683494/17.1/cyclone-v-avalon-memory-mapped-avalon-mm-interface-for-pci-express-solutions-user-guide/datasheet) configured as a x1 PCIe PIPE interfaced Endpoint.

## 2026.01 January 2026
- New repository with PCIe verification component based on a PCIe C model and using the OSVVM co-simulation capabilities.  See [README.md](./README.md)

 
## Copyright and License
Copyright (C) 2026 by [OSVVM Authors](../AUTHORS.md)   

This file is part of OSVVM.

    Licensed under Apache License, Version 2.0 (the "License")
    You may not use this file except in compliance with the License.
    You may obtain a copy of the License at

  [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
