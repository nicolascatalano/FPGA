library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity copy_vec_N_times is
    generic (
        DATA_WIDTH : integer := 2;
        N : integer := 8
    );
    port (
        sys_clk_i            : in std_logic;
        sys_rst_ni            : in std_logic;
        s_axis_tdata_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        s_axis_tvalid_in : in std_logic;
        m_axis_tdata_out : out std_logic_vector(DATA_WIDTH*N - 1 downto 0);
        m_axis_tvalid_out : out std_logic_vector(N-1 downto 0)
    );
end copy_vec_N_times;

architecture Behavioral of copy_vec_N_times is
begin
process(sys_clk_i, sys_rst_ni)
begin
    if sys_rst_ni = '0' then
        m_axis_tdata_out <= (others => '0');
        m_axis_tvalid_out <= (others => '0');
    elsif rising_edge(sys_clk_i) then
        for i in 0 to N - 1 loop
            m_axis_tdata_out(DATA_WIDTH*(i + 1) - 1 downto DATA_WIDTH*i) <= s_axis_tdata_in;
            m_axis_tvalid_out(i) <= s_axis_tvalid_in;
        end loop;
    end if;
end process;
end Behavioral;