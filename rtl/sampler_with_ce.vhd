library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity sampler_with_ce is
    generic (
        N : integer := 8
    );
    port (
        clk, ce, rst_i : in std_logic;
        din            : in std_logic_vector(N - 1 downto 0);
        dout           : out std_logic_vector(N - 1 downto 0);
        dout_valid     : out std_logic);
end sampler_with_ce;

architecture arch of sampler_with_ce is
    signal dout_reg : std_logic_vector(N - 1 downto 0);
    signal dout_valid_reg : std_logic;
begin
    process (clk, rst_i)
    begin
        if (rst_i = '1') then
            dout_valid_reg <= '0';
        elsif (rising_edge(clk)) then
            dout_valid_reg <= '0';
            if (ce = '1') then
                dout_reg <= din;
                dout_valid_reg <= '1';
            end if;
        end if;
    end process;
    dout <= dout_reg;
    dout_valid <= dout_valid_reg;
end arch;
