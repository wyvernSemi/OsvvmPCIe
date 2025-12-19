--
--  File Name:         PcieModelSerialiser.vhd
--  Design Unit Name:  PcieModelSerialiser
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Simon Southwell      email:  simon.southwell@gmail.com
--  Contributor(s):
--     Simon Southwell      simon.southwell@gmail.com
--
--
--  Description:
--      Pcie GEN1/2 model
--
--  Revision History:
--    Date      Version    Description
--    07/2025   ????.??    Initial version
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

  use work.PcieInterfacePkg.all ;

entity PcieModelSerialiser is
  generic (
    NUMOFLANES                         : integer := MAXLINKWIDTH
  );
  port (
    SerClk                             : in  std_logic;

    ParIn                              : in  LinkType(0 to NUMOFLANES-1)(ENCODEDWIDTH-1 downto 0) ;
    SerOut                             : out std_logic_vector (NUMOFLANES-1 downto 0);
    
    SerIn                              : in  std_logic_vector (NUMOFLANES-1 downto 0);
    ParOut                             : out LinkType(0 to NUMOFLANES-1)(ENCODEDWIDTH-1 downto 0)
  );
end entity PcieModelSerialiser ;

architecture behavioural of PcieModelSerialiser is

signal SerialShift                     : LinkType(0 to NUMOFLANES-1)(ENCODEDWIDTH-1 downto 0) := (others => (others => '0'));
signal DeserialShift                   : LinkType(0 to NUMOFLANES-1)(ENCODEDWIDTH-1 downto 0) := (others => (others => '0'));
signal DeserialReg                     : LinkType(0 to NUMOFLANES-1)(ENCODEDWIDTH-1 downto 0) := (others => (others => '0'));

signal Synced                          : std_logic := '0';

signal SerialCount                     : integer   := 0;
signal DeserialCount                   : integer   := 0;

begin


  g_GENDATA:  for i in 0 to NUMOFLANES-1 generate
    ParOut(i)           <= (others => 'Z') when Synced = '0' else  DeserialReg(i);
    SerOut(i)           <= SerialShift(i)(0);
  end generate g_GENDATA;

  process (SerClk)
  begin
    if SerClk'event and SerClk = '1' then

      if SerialCount = 0 then
        SerialCount <= ENCODEDWIDTH-1;
        for idx in 0 to NUMOFLANES-1 loop
          if not has_an_x(ParIn(idx)) then
            SerialShift(idx) <= ParIn(idx);
          end if;
        end loop;
      else
        SerialCount <=  SerialCount - 1;
        for idx in 0 to NUMOFLANES-1 loop
          SerialShift(idx) <= '0' &  SerialShift(idx)(ENCODEDWIDTH-1 downto 1);
        end loop;
      end if;

      for idx in 0 to NUMOFLANES-1 loop
        if SerIn(idx) = '1' or SerIn(idx) = '0' then
          DeserialShift(idx) <= SerIn(idx) & DeserialShift(idx)(ENCODEDWIDTH-1 downto 1);
        end if;
      end loop;

      -- Maintain sync
      if Synced = '1' then
        if SerIn(0) = 'Z' or SerIn(0) = 'X' then
          Synced <= '0';
        end if;
      else
        if DeserialShift(0) = NCOMMA or DeserialShift(0) = PCOMMA then
          Synced <= '1';
        end if;
      end if;

      if Synced = '1' then
        DeserialCount <=  (DeserialCount + 1) mod ENCODEDWIDTH;
      end if;

      if DeserialCount = (ENCODEDWIDTH-1) or (Synced = '0' and (DeserialShift(0) = NCOMMA or DeserialShift(0) = PCOMMA)) then
        for idx in 0 to NUMOFLANES-1 loop
          DeserialReg(idx) <= DeserialShift(idx);
        end loop;
      end if;
    end if;

  end process;

end behavioural;