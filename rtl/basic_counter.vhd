library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity basic_counter is
    generic (
        COUNTER_WIDTH      : integer := 16;
        DIVIDE_CLK_FREQ_BY : integer := 7);
    port (
        clk_i         : in std_logic;
        rst_ni        : in std_logic;
        m_axis_tdata  : out std_logic_vector(COUNTER_WIDTH - 1 downto 0);
        m_axis_tvalid : out std_logic
    );
end basic_counter;
architecture rtl of basic_counter is
    -- signals
    signal q_r : std_logic_vector(10 downto 0);
    signal m_axis_tdata_reg : std_logic_vector(COUNTER_WIDTH - 1 downto 0);
    signal m_axis_tvalid_reg : std_logic;
begin
    process (clk_i)
    begin
        if rising_edge(clk_i) then
            if (rst_ni = '0') then
                q_r <= (others => '0');
                m_axis_tdata_reg <= (others => '0');
                m_axis_tvalid_reg <= '0';
            else
                q_r <= q_r + 1;
                m_axis_tvalid_reg <= '0';
                if (q_r = std_logic_vector(to_unsigned(DIVIDE_CLK_FREQ_BY, 10) - 1)) then
                    m_axis_tdata_reg <= m_axis_tdata_reg + 1;
                    m_axis_tvalid_reg <= '1';
                    q_r <= (others => '0');
                end if;
            end if;
        end if;
    end process;
    m_axis_tdata <= m_axis_tdata_reg;
    m_axis_tvalid <= m_axis_tvalid_reg;
end rtl;
