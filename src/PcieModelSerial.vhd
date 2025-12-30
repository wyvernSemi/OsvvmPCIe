--
--  File Name:         PcieModelSerial.vhd
--  Design Unit Name:  PcieModelSerial
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Simon Southwell      email:  simon.southwell@gmail.com
--  Contributor(s):
--     Simon Southwell      simon.southwell@gmail.com
--
--
--  Description:
--      Pcie GEN1/2 model wrapper module to convert 8b10b for serial
--      (single ended)
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

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

library osvvm_pcie ;
  context osvvm_pcie.PcieContext ;

--  use work.PcieInterfacePkg.all ;

-- -------------------------------------------------------------
--  PcieVModelSerial full 16 lanes
-- -------------------------------------------------------------

entity PcieModelSerial is

  generic (
    MODEL_ID_NAME         : string  := "" ;
    NODE_NUM              : integer := 8 ;
    ENDPOINT              : boolean := false ;
    REQ_ID                : integer := 0 ;
    EN_TLP_REQ_DIGEST     : boolean := false ;
    ENABLE_INIT_PHY       : boolean := true  ;
    ENABLE_AUTO           : boolean := false
  );
  port (
    Clk                   : in  std_logic;
    SerClk                : in  std_logic;
    nReset                : in  std_logic;

    -- Testbench Transaction Interface
    TransRec              : inout AddressBusRecType ;

    SerLinkIn             : in  std_logic_vector;
    SerLinkOut            : out std_logic_vector
  );

end entity PcieModelSerial;

architecture behavioural of PcieModelSerial is

signal PcieLink : PcieRecType(
    LinkOut (0 to SerLinkOut'length-1)(ENCODEDWIDTH-1 downto 0),
    LinkIn  (0 to SerLinkIn'length -1)(ENCODEDWIDTH-1 downto 0)
  ) ;

begin

  ------------------------------------------------------------
  pciemodel_i : entity osvvm_pcie.PcieModel
  ------------------------------------------------------------
  generic map (
    MODEL_ID_NAME      => MODEL_ID_NAME,
    NODE_NUM           => NODE_NUM,
    ENDPOINT           => ENDPOINT,
    REQ_ID             => REQ_ID,
    EN_TLP_REQ_DIGEST  => EN_TLP_REQ_DIGEST,
    PIPE               => false,
    ENABLE_INIT_PHY    => ENABLE_INIT_PHY,
    ENABLE_AUTO        => ENABLE_AUTO
  )
  port map (
    -- Globals
    Clk                => Clk,
    nReset             => nReset,

    -- Test bench Transaction Interface
    TransRec           => TransRec,

    -- PCIe Functional Interface
    PcieLinkOut        => PcieLink.LinkOut,
    PcieLinkIn         => PcieLink.LinkIn
  ) ;

  ------------------------------------------------------------
  serdes_i : entity osvvm_pcie.PcieModelSerialiser
  ------------------------------------------------------------
  generic map (
    NUMOFLANES         => SerLinkOut'length
  )
  port map (
    SerClk             => SerClk,

    ParIn              => PcieLink.LinkOut,
    SerOut             => SerLinkOut,
    SerIn              => SerLinkIn,
    ParOut             => PcieLink.LinkIn
  );


end behavioural;