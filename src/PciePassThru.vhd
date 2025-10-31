--
--  File Name:         PciePassThru.vhd
--  Design Unit Name:  PciePassThru
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Simon Sothwell email:  simon.southwell@gmail.com
--  Contributor(s):
--     Simon Southwell simon.southwell@gmail.com
--
--
--  Description:
--     DUT pass thru for PCIe VC testing
--     Used to demonstrate DUT connections
--
--
--  Revision History:
--    Date      Version    Description
--    10/2025   ???.??     Initial
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

library osvvm ;
    context osvvm.OsvvmContext ;

  use work.PcieComponentPkg.all ;
  use work.PcieInterfacePkg.all ;

entity PciePassThru is
  port (
    DownLinkIn0    : in  std_logic_vector ;
    DownLinkIn1    : in  std_logic_vector ;
    DownLinkIn2    : in  std_logic_vector ;
    DownLinkIn3    : in  std_logic_vector ;
    DownLinkIn4    : in  std_logic_vector ;
    DownLinkIn5    : in  std_logic_vector ;
    DownLinkIn6    : in  std_logic_vector ;
    DownLinkIn7    : in  std_logic_vector ;
    DownLinkIn8    : in  std_logic_vector ;
    DownLinkIn9    : in  std_logic_vector ;
    DownLinkIn10   : in  std_logic_vector ;
    DownLinkIn11   : in  std_logic_vector ;
    DownLinkIn12   : in  std_logic_vector ;
    DownLinkIn13   : in  std_logic_vector ;
    DownLinkIn14   : in  std_logic_vector ;
    DownLinkIn15   : in  std_logic_vector ;

    DownLinkOut0   : out std_logic_vector ;
    DownLinkOut1   : out std_logic_vector ;
    DownLinkOut2   : out std_logic_vector ;
    DownLinkOut3   : out std_logic_vector ;
    DownLinkOut4   : out std_logic_vector ;
    DownLinkOut5   : out std_logic_vector ;
    DownLinkOut6   : out std_logic_vector ;
    DownLinkOut7   : out std_logic_vector ;
    DownLinkOut8   : out std_logic_vector ;
    DownLinkOut9   : out std_logic_vector ;
    DownLinkOut10  : out std_logic_vector ;
    DownLinkOut11  : out std_logic_vector ;
    DownLinkOut12  : out std_logic_vector ;
    DownLinkOut13  : out std_logic_vector ;
    DownLinkOut14  : out std_logic_vector ;
    DownLinkOut15  : out std_logic_vector ;

    UpLinkIn0      : in  std_logic_vector ;
    UpLinkIn1      : in  std_logic_vector ;
    UpLinkIn2      : in  std_logic_vector ;
    UpLinkIn3      : in  std_logic_vector ;
    UpLinkIn4      : in  std_logic_vector ;
    UpLinkIn5      : in  std_logic_vector ;
    UpLinkIn6      : in  std_logic_vector ;
    UpLinkIn7      : in  std_logic_vector ;
    UpLinkIn8      : in  std_logic_vector ;
    UpLinkIn9      : in  std_logic_vector ;
    UpLinkIn10     : in  std_logic_vector ;
    UpLinkIn11     : in  std_logic_vector ;
    UpLinkIn12     : in  std_logic_vector ;
    UpLinkIn13     : in  std_logic_vector ;
    UpLinkIn14     : in  std_logic_vector ;
    UpLinkIn15     : in  std_logic_vector ;

    UpLinkOut0     : out std_logic_vector ;
    UpLinkOut1     : out std_logic_vector ;
    UpLinkOut2     : out std_logic_vector ;
    UpLinkOut3     : out std_logic_vector ;
    UpLinkOut4     : out std_logic_vector ;
    UpLinkOut5     : out std_logic_vector ;
    UpLinkOut6     : out std_logic_vector ;
    UpLinkOut7     : out std_logic_vector ;
    UpLinkOut8     : out std_logic_vector ;
    UpLinkOut9     : out std_logic_vector ;
    UpLinkOut10    : out std_logic_vector ;
    UpLinkOut11    : out std_logic_vector ;
    UpLinkOut12    : out std_logic_vector ;
    UpLinkOut13    : out std_logic_vector ;
    UpLinkOut14    : out std_logic_vector ;
    UpLinkOut15    : out std_logic_vector

  ) ;
end entity PciePassThru ;

architecture FeedThru of PciePassThru is
begin

    UpLinkOut0      <= DownLinkIn0;
    UpLinkOut1      <= DownLinkIn1;
    UpLinkOut2      <= DownLinkIn2;
    UpLinkOut3      <= DownLinkIn3;
    UpLinkOut4      <= DownLinkIn4;
    UpLinkOut5      <= DownLinkIn5;
    UpLinkOut6      <= DownLinkIn6;
    UpLinkOut7      <= DownLinkIn7;
    UpLinkOut8      <= DownLinkIn8;
    UpLinkOut9      <= DownLinkIn9;
    UpLinkOut10     <= DownLinkIn10;
    UpLinkOut11     <= DownLinkIn11;
    UpLinkOut12     <= DownLinkIn12;
    UpLinkOut13     <= DownLinkIn13;
    UpLinkOut14     <= DownLinkIn14;
    UpLinkOut15     <= DownLinkIn15;

    DownLinkOut0    <= UpLinkIn0;
    DownLinkOut1    <= UpLinkIn1;
    DownLinkOut2    <= UpLinkIn2;
    DownLinkOut3    <= UpLinkIn3;
    DownLinkOut4    <= UpLinkIn4;
    DownLinkOut5    <= UpLinkIn5;
    DownLinkOut6    <= UpLinkIn6;
    DownLinkOut7    <= UpLinkIn7;
    DownLinkOut8    <= UpLinkIn8;
    DownLinkOut9    <= UpLinkIn9;
    DownLinkOut10   <= UpLinkIn10;
    DownLinkOut11   <= UpLinkIn11;
    DownLinkOut12   <= UpLinkIn12;
    DownLinkOut13   <= UpLinkIn13;
    DownLinkOut14   <= UpLinkIn14;
    DownLinkOut15   <= UpLinkIn15;

end architecture FeedThru ;

library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
    context osvvm.OsvvmContext ;

  use work.PcieInterfacePkg.all ;

entity PciePassThru1 IS
  port (
    DownLinkIn0    : in  std_logic_vector ;
    DownLinkOut0   : out std_logic_vector ;

    UpLinkIn0      : in  std_logic_vector ;
    UpLinkOut0     : out std_logic_vector
  ) ;
end entity PciePassThru1 ;

architecture FeedThru of PciePassThru1 is

signal dummyin     : std_logic_vector (DownLinkIn0'length-1  downto 0) := (others => 'Z') ;
signal dummyout    : std_logic_vector (DownLinkOut0'length-1 downto 0) ;

begin

    pass_1 : entity work.PciePassThru
    port map (
      DownLinkIn0   => DownLinkIn0,

      DownLinkIn1   => dummyin, DownLinkIn2   => dummyin, DownLinkIn3   => dummyin, DownLinkIn4   => dummyin,
      DownLinkIn5   => dummyin, DownLinkIn6   => dummyin, DownLinkIn7   => dummyin, DownLinkIn8   => dummyin,
      DownLinkIn9   => dummyin, DownLinkIn10  => dummyin, DownLinkIn11  => dummyin, DownLinkIn12  => dummyin,
      DownLinkIn13  => dummyin, DownLinkIn14  => dummyin, DownLinkIn15  => dummyin,

      DownLinkOut0  => DownLinkOut0,

      DownLinkOut1  => dummyout, DownLinkOut2  => dummyout, DownLinkOut3  => dummyout, DownLinkOut4  => dummyout,
      DownLinkOut5  => dummyout, DownLinkOut6  => dummyout, DownLinkOut7  => dummyout, DownLinkOut8  => dummyout,
      DownLinkOut9  => dummyout, DownLinkOut10 => dummyout, DownLinkOut11 => dummyout, DownLinkOut12 => dummyout,
      DownLinkOut13 => dummyout, DownLinkOut14 => dummyout, DownLinkOut15 => dummyout,

      UpLinkIn0     => UpLinkIn0,

      UpLinkIn1     => dummyin, UpLinkIn2     => dummyin, UpLinkIn3     => dummyin, UpLinkIn4     => dummyin,
      UpLinkIn5     => dummyin, UpLinkIn6     => dummyin, UpLinkIn7     => dummyin, UpLinkIn8     => dummyin,
      UpLinkIn9     => dummyin, UpLinkIn10    => dummyin, UpLinkIn11    => dummyin, UpLinkIn12    => dummyin,
      UpLinkIn13    => dummyin, UpLinkIn14    => dummyin, UpLinkIn15    => dummyin,

      UpLinkOut0    => UpLinkOut0,

      UpLinkOut1    => dummyout, UpLinkOut2    => dummyout, UpLinkOut3    => dummyout, UpLinkOut4   => dummyout,
      UpLinkOut5    => dummyout, UpLinkOut6    => dummyout, UpLinkOut7    => dummyout, UpLinkOut8   => dummyout,
      UpLinkOut9    => dummyout, UpLinkOut10   => dummyout, UpLinkOut11   => dummyout, UpLinkOut12  => dummyout,
      UpLinkOut13   => dummyout, UpLinkOut14   => dummyout, UpLinkOut15   => dummyout

   ) ;

end architecture FeedThru ;

library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
    context osvvm.OsvvmContext ;

  use work.PcieComponentPkg.all ;
  use work.PcieInterfacePkg.all ;

entity PciePassThru2 IS
  port (
    DownLinkIn0    : in  std_logic_vector ;
    DownLinkIn1    : in  std_logic_vector ;

    DownLinkOut0   : out std_logic_vector ;
    DownLinkOut1   : out std_logic_vector ;

    UpLinkIn0      : in  std_logic_vector ;
    UpLinkIn1      : in  std_logic_vector ;

    UpLinkOut0     : out std_logic_vector ;
    UpLinkOut1     : out std_logic_vector
  ) ;
end entity PciePassThru2 ;

architecture FeedThru of PciePassThru2 is

signal dummyin     : std_logic_vector (DownLinkIn0'length-1  downto 0) := (others => 'Z') ;
signal dummyout    : std_logic_vector (DownLinkOut0'length-1 downto 0) ;

begin

    pass_1 : PciePassThru
    port map (
      DownLinkIn0   => DownLinkIn0,
      DownLinkIn1   => DownLinkIn1,

      DownLinkIn2   => dummyin, DownLinkIn3   => dummyin, DownLinkIn4   => dummyin,
      DownLinkIn5   => dummyin, DownLinkIn6   => dummyin, DownLinkIn7   => dummyin, DownLinkIn8   => dummyin,
      DownLinkIn9   => dummyin, DownLinkIn10  => dummyin, DownLinkIn11  => dummyin, DownLinkIn12  => dummyin,
      DownLinkIn13  => dummyin, DownLinkIn14  => dummyin, DownLinkIn15  => dummyin,

      DownLinkOut0  => DownLinkOut0,
      DownLinkOut1  => DownLinkOut1,

      DownLinkOut2  => dummyout, DownLinkOut3  => dummyout, DownLinkOut4  => dummyout,
      DownLinkOut5  => dummyout, DownLinkOut6  => dummyout, DownLinkOut7  => dummyout, DownLinkOut8  => dummyout,
      DownLinkOut9  => dummyout, DownLinkOut10 => dummyout, DownLinkOut11 => dummyout, DownLinkOut12 => dummyout,
      DownLinkOut13 => dummyout, DownLinkOut14 => dummyout, DownLinkOut15 => dummyout,

      UpLinkIn0     => UpLinkIn0,
      UpLinkIn1     => UpLinkIn1,

      UpLinkIn2     => dummyin, UpLinkIn3     => dummyin, UpLinkIn4     => dummyin,
      UpLinkIn5     => dummyin, UpLinkIn6     => dummyin, UpLinkIn7     => dummyin, UpLinkIn8     => dummyin,
      UpLinkIn9     => dummyin, UpLinkIn10    => dummyin, UpLinkIn11    => dummyin, UpLinkIn12    => dummyin,
      UpLinkIn13    => dummyin, UpLinkIn14    => dummyin, UpLinkIn15    => dummyin,

      UpLinkOut0    => UpLinkOut0,
      UpLinkOut1    => UpLinkOut1,

      UpLinkOut2    => dummyout, UpLinkOut3    => dummyout, UpLinkOut4    => dummyout,
      UpLinkOut5    => dummyout, UpLinkOut6    => dummyout, UpLinkOut7    => dummyout, UpLinkOut8   => dummyout,
      UpLinkOut9    => dummyout, UpLinkOut10   => dummyout, UpLinkOut11   => dummyout, UpLinkOut12  => dummyout,
      UpLinkOut13   => dummyout, UpLinkOut14   => dummyout, UpLinkOut15   => dummyout

   ) ;

end architecture FeedThru ;

library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
    context osvvm.OsvvmContext ;

  use work.PcieComponentPkg.all ;
  use work.PcieInterfacePkg.all ;

entity PciePassThru4 IS
  port (
    DownLinkIn0    : in  std_logic_vector ;
    DownLinkIn1    : in  std_logic_vector ;
    DownLinkIn2    : in  std_logic_vector ;
    DownLinkIn3    : in  std_logic_vector ;

    DownLinkOut0   : out std_logic_vector ;
    DownLinkOut1   : out std_logic_vector ;
    DownLinkOut2   : out std_logic_vector ;
    DownLinkOut3   : out std_logic_vector ;

    UpLinkIn0      : in  std_logic_vector ;
    UpLinkIn1      : in  std_logic_vector ;
    UpLinkIn2      : in  std_logic_vector ;
    UpLinkIn3      : in  std_logic_vector ;

    UpLinkOut0     : out std_logic_vector ;
    UpLinkOut1     : out std_logic_vector ;
    UpLinkOut2     : out std_logic_vector ;
    UpLinkOut3     : out std_logic_vector
  ) ;
end entity PciePassThru4 ;

architecture FeedThru of PciePassThru4 is

signal dummyin     : std_logic_vector (DownLinkIn0'length-1  downto 0) := (others => 'Z') ;
signal dummyout    : std_logic_vector (DownLinkOut0'length-1 downto 0) ;

begin

    pass_1 : PciePassThru
    port map (
      DownLinkIn0   => DownLinkIn0,
      DownLinkIn1   => DownLinkIn1,
      DownLinkIn2   => DownLinkIn2,
      DownLinkIn3   => DownLinkIn3,

      DownLinkIn4   => dummyin,
      DownLinkIn5   => dummyin, DownLinkIn6   => dummyin, DownLinkIn7   => dummyin, DownLinkIn8   => dummyin,
      DownLinkIn9   => dummyin, DownLinkIn10  => dummyin, DownLinkIn11  => dummyin, DownLinkIn12  => dummyin,
      DownLinkIn13  => dummyin, DownLinkIn14  => dummyin, DownLinkIn15  => dummyin,

      DownLinkOut0  => DownLinkOut0,
      DownLinkOut1  => DownLinkOut1,
      DownLinkOut2  => DownLinkOut2,
      DownLinkOut3  => DownLinkOut3,

      DownLinkOut4  => dummyout,
      DownLinkOut5  => dummyout, DownLinkOut6  => dummyout, DownLinkOut7  => dummyout, DownLinkOut8  => dummyout,
      DownLinkOut9  => dummyout, DownLinkOut10 => dummyout, DownLinkOut11 => dummyout, DownLinkOut12 => dummyout,
      DownLinkOut13 => dummyout, DownLinkOut14 => dummyout, DownLinkOut15 => dummyout,

      UpLinkIn0     => UpLinkIn0,
      UpLinkIn1     => UpLinkIn1,
      UpLinkIn2     => UpLinkIn2,
      UpLinkIn3     => UpLinkIn3,

      UpLinkIn4     => dummyin,
      UpLinkIn5     => dummyin, UpLinkIn6     => dummyin, UpLinkIn7     => dummyin, UpLinkIn8     => dummyin,
      UpLinkIn9     => dummyin, UpLinkIn10    => dummyin, UpLinkIn11    => dummyin, UpLinkIn12    => dummyin,
      UpLinkIn13    => dummyin, UpLinkIn14    => dummyin, UpLinkIn15    => dummyin,

      UpLinkOut0    => UpLinkOut0,
      UpLinkOut1    => UpLinkOut1,
      UpLinkOut2    => UpLinkOut2,
      UpLinkOut3    => UpLinkOut3,

      UpLinkOut4    => dummyout,
      UpLinkOut5    => dummyout, UpLinkOut6    => dummyout, UpLinkOut7    => dummyout, UpLinkOut8   => dummyout,
      UpLinkOut9    => dummyout, UpLinkOut10   => dummyout, UpLinkOut11   => dummyout, UpLinkOut12  => dummyout,
      UpLinkOut13   => dummyout, UpLinkOut14   => dummyout, UpLinkOut15   => dummyout

   ) ;

end architecture FeedThru ;

library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library osvvm ;
    context osvvm.OsvvmContext ;

  use work.PcieComponentPkg.all ;
  use work.PcieInterfacePkg.all ;

entity PciePassThru8 IS
  port (
    DownLinkIn0    : in  std_logic_vector ;
    DownLinkIn1    : in  std_logic_vector ;
    DownLinkIn2    : in  std_logic_vector ;
    DownLinkIn3    : in  std_logic_vector ;
    DownLinkIn4    : in  std_logic_vector ;
    DownLinkIn5    : in  std_logic_vector ;
    DownLinkIn6    : in  std_logic_vector ;
    DownLinkIn7    : in  std_logic_vector ;

    DownLinkOut0   : out std_logic_vector ;
    DownLinkOut1   : out std_logic_vector ;
    DownLinkOut2   : out std_logic_vector ;
    DownLinkOut3   : out std_logic_vector ;
    DownLinkOut4   : out std_logic_vector ;
    DownLinkOut5   : out std_logic_vector ;
    DownLinkOut6   : out std_logic_vector ;
    DownLinkOut7   : out std_logic_vector ;

    UpLinkIn0      : in  std_logic_vector ;
    UpLinkIn1      : in  std_logic_vector ;
    UpLinkIn2      : in  std_logic_vector ;
    UpLinkIn3      : in  std_logic_vector ;
    UpLinkIn4      : in  std_logic_vector ;
    UpLinkIn5      : in  std_logic_vector ;
    UpLinkIn6      : in  std_logic_vector ;
    UpLinkIn7      : in  std_logic_vector ;

    UpLinkOut0     : out std_logic_vector ;
    UpLinkOut1     : out std_logic_vector ;
    UpLinkOut2     : out std_logic_vector ;
    UpLinkOut3     : out std_logic_vector ;
    UpLinkOut4     : out std_logic_vector ;
    UpLinkOut5     : out std_logic_vector ;
    UpLinkOut6     : out std_logic_vector ;
    UpLinkOut7     : out std_logic_vector
  ) ;
end entity PciePassThru8 ;

architecture FeedThru of PciePassThru8 is

signal dummyin     : std_logic_vector (DownLinkIn0'length-1  downto 0) := (others => 'Z') ;
signal dummyout    : std_logic_vector (DownLinkOut0'length-1 downto 0) ;

begin

    pass_1 : PciePassThru
    port map (
      DownLinkIn0   => DownLinkIn0,
      DownLinkIn1   => DownLinkIn1,
      DownLinkIn2   => DownLinkIn2,
      DownLinkIn3   => DownLinkIn3,
      DownLinkIn4   => DownLinkIn4,
      DownLinkIn5   => DownLinkIn5,
      DownLinkIn6   => DownLinkIn6,
      DownLinkIn7   => DownLinkIn7,

      DownLinkIn8   => dummyin,
      DownLinkIn9   => dummyin, DownLinkIn10  => dummyin, DownLinkIn11  => dummyin, DownLinkIn12  => dummyin,
      DownLinkIn13  => dummyin, DownLinkIn14  => dummyin, DownLinkIn15  => dummyin,

      DownLinkOut0  => DownLinkOut0,
      DownLinkOut1  => DownLinkOut1,
      DownLinkOut2  => DownLinkOut2,
      DownLinkOut3  => DownLinkOut3,
      DownLinkOut4  => DownLinkOut4,
      DownLinkOut5  => DownLinkOut5,
      DownLinkOut6  => DownLinkOut6,
      DownLinkOut7  => DownLinkOut7,

      DownLinkOut8  => dummyout,
      DownLinkOut9  => dummyout, DownLinkOut10 => dummyout, DownLinkOut11 => dummyout, DownLinkOut12 => dummyout,
      DownLinkOut13 => dummyout, DownLinkOut14 => dummyout, DownLinkOut15 => dummyout,

      UpLinkIn0     => UpLinkIn0,
      UpLinkIn1     => UpLinkIn1,
      UpLinkIn2     => UpLinkIn2,
      UpLinkIn3     => UpLinkIn3,
      UpLinkIn4     => UpLinkIn4,
      UpLinkIn5     => UpLinkIn5,
      UpLinkIn6     => UpLinkIn6,
      UpLinkIn7     => UpLinkIn7,

      UpLinkIn8     => dummyin,
      UpLinkIn9     => dummyin, UpLinkIn10    => dummyin, UpLinkIn11    => dummyin, UpLinkIn12    => dummyin,
      UpLinkIn13    => dummyin, UpLinkIn14    => dummyin, UpLinkIn15    => dummyin,

      UpLinkOut0    => UpLinkOut0,
      UpLinkOut1    => UpLinkOut1,
      UpLinkOut2    => UpLinkOut2,
      UpLinkOut3    => UpLinkOut3,
      UpLinkOut4    => UpLinkOut4,
      UpLinkOut5    => UpLinkOut5,
      UpLinkOut6    => UpLinkOut6,
      UpLinkOut7    => UpLinkOut7,

      UpLinkOut8    => dummyout,
      UpLinkOut9    => dummyout, UpLinkOut10   => dummyout, UpLinkOut11   => dummyout, UpLinkOut12  => dummyout,
      UpLinkOut13   => dummyout, UpLinkOut14   => dummyout, UpLinkOut15   => dummyout

   ) ;

end architecture FeedThru ;