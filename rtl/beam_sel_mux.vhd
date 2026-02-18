library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity beam_sel_mux is
  port (
    sys_clk_i    : in std_logic;
    async_rst_i  : in std_logic;
    control_i    : in std_logic_vector(2 downto 0);
    beams_data_i : in std_logic_vector(32 * 16 * 5 - 1 downto 0);
    beam_valid_i : in std_logic_vector(16 * 5 - 1 downto 0);
    beam_data_o  : out std_logic_vector(32 * 16 - 1 downto 0);
    beam_valid_o : out std_logic_vector(16 - 1 downto 0)
  );
end beam_sel_mux;

architecture rtl of beam_sel_mux is

  signal beam_data_reg : std_logic_vector(32 * 16 - 1 downto 0);
  signal beam_valid_reg : std_logic_vector(16 - 1 downto 0);
  signal control_reg : std_logic_vector(2 downto 0);

begin

  process (sys_clk_i, async_rst_i)
  begin
    if (async_rst_i = '1') then
      beam_data_reg <= (others => '0');
      beam_valid_reg <= (others => '0');
      control_reg <= (others => '0');
    elsif (rising_edge(sys_clk_i)) then
      control_reg <= control_i;
      case control_reg is
        when "000" =>
          for i in 0 to 15 loop
            beam_data_reg(32 * i + 31 downto 32 * i) <= beams_data_i(32 * (5 * i + 1) - 1 downto 32 * (5 * i));
            beam_valid_reg(i) <= beam_valid_i(5 * i);
          end loop;
        when "001" =>
          for i in 0 to 15 loop
            beam_data_reg(32 * i + 31 downto 32 * i) <= beams_data_i(32 * (5 * i + 2) - 1 downto 32 * (5 * i + 1));
            beam_valid_reg(i) <= beam_valid_i(5 * i + 1);
          end loop;
        when "010" =>
          for i in 0 to 15 loop
            beam_data_reg(32 * i + 31 downto 32 * i) <= beams_data_i(32 * (5 * i + 3) - 1 downto 32 * (5 * i + 2));
            beam_valid_reg(i) <= beam_valid_i(5 * i + 2);
          end loop;
        when "011" =>
          for i in 0 to 15 loop
            beam_data_reg(32 * i + 31 downto 32 * i) <= beams_data_i(32 * (5 * i + 4) - 1 downto 32 * (5 * i + 3));
            beam_valid_reg(i) <= beam_valid_i(5 * i + 3);
          end loop;
        when "100" =>
          for i in 0 to 15 loop
            beam_data_reg(32 * i + 31 downto 32 * i) <= beams_data_i(32 * (5 * i + 5) - 1 downto 32 * (5 * i + 4));
            beam_valid_reg(i) <= beam_valid_i(5 * i + 4);
          end loop;
        when others =>
          beam_data_reg <= (others => '0');
          beam_valid_reg <= (others => '0');
      end case;
    end if;
  end process;

  beam_data_o <= beam_data_reg;
  beam_valid_o <= beam_valid_reg;

end rtl;
