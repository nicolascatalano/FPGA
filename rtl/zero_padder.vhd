library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity zero_padder is
  generic (
    INPUT_WIDTH  : natural := 16;
    OUTPUT_WIDTH : natural := 32;
    LSB_PADDING  : boolean := true);
  port (
    data_in   : in std_logic_vector(INPUT_WIDTH - 1 downto 0);
    data_out  : out std_logic_vector(OUTPUT_WIDTH - 1 downto 0)
  );
end zero_padder;

architecture rtl of zero_padder is
begin
  with LSB_PADDING select data_out(OUTPUT_WIDTH - 1 downto OUTPUT_WIDTH - INPUT_WIDTH) <=
  data_in when true,
 (others => '0') when false;
 
 with LSB_PADDING select data_out(OUTPUT_WIDTH - INPUT_WIDTH - 1 downto 0) <=
  data_in when false,
  (others => '0') when true;
end rtl;
