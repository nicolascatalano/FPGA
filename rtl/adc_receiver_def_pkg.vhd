library ieee;
use ieee.std_logic_1164.all;

package adc_receiver_def_pkg is
  type adc_data_t is array (integer range <>) of std_logic_vector(14 - 1 downto 0);

end package adc_receiver_def_pkg;
