library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity level_sync is
    generic (FF_COUNT : integer := 2);
    port (
        dest_clk_i : in std_logic;
        dest_rst_i : in std_logic;
        level_i    : in std_logic;
        level_o    : out std_logic
    );
end level_sync;

architecture arch of level_sync is
    signal dest_level_reg : std_logic_vector(FF_COUNT - 1 downto 0);

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of dest_level_reg : signal is "TRUE";

begin

    sync : process (dest_clk_i, dest_rst_i)
    begin
        if (dest_rst_i = '1') then
            level_o <= '0';
        elsif rising_edge(dest_clk_i) then
            dest_level_reg <= dest_level_reg(FF_COUNT - 2 downto 0) & level_i;
            level_o <= dest_level_reg(FF_COUNT - 1);
        end if;
    end process;
end arch;
