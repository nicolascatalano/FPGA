library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity dsp_complex_gain is
    generic (
        SHIFT_BY   : integer := 1;
        DATA_WIDTH : natural := 32);
    port (
        data_in  : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity dsp_complex_gain;

architecture rtl of dsp_complex_gain is
begin
    data_out(DATA_WIDTH - 1 downto DATA_WIDTH/2 + SHIFT_BY) <= data_in(DATA_WIDTH - 1 - SHIFT_BY downto DATA_WIDTH/2);
    data_out(DATA_WIDTH/2 + SHIFT_BY - 1 downto DATA_WIDTH/2) <= (others => '0');
    data_out(DATA_WIDTH/2 - 1 downto SHIFT_BY) <= data_in(DATA_WIDTH/2 - 1 - SHIFT_BY downto 0);
    data_out(SHIFT_BY - 1 downto 0) <= (others => '0');
end architecture rtl;
