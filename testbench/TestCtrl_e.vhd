library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;

library OSVVM ;
  context OSVVM.OsvvmContext ;
  use osvvm.ScoreboardPkg_slv.all ;

library osvvm_pcie ;
  context osvvm_pcie.PcieContext ;

--use work.OsvvmTestCommonPkg ;

entity TestCtrl is
  port (
    -- Global Signal Interface
    Clk            : In    std_logic ;
    nReset         : In    std_logic ;

    -- Transaction Interfaces
    UpstreamRec    : inout AddressBusRecType ;
    DownstreamRec  : inout AddressBusRecType

  ) ;

  constant PCIE_ADDR_WIDTH : integer := DownstreamRec.Address'length ;
  constant PCIE_DATA_WIDTH : integer := DownstreamRec.DataToModel'length ;

end entity TestCtrl ;
