library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity vector_valid_sync is
  generic (
    DATA_WIDTH : integer := 32
  );
  port (
    src_clk_i   : in std_logic;
    src_rst_i   : in std_logic;

    src_data_i  : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    src_valid_i : in std_logic;

    dst_clk_i   : in std_logic;

    dst_data_o  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    dst_valid_o : out std_logic
  );
end entity vector_valid_sync;

architecture arch of vector_valid_sync is
  signal sync_data_reg0 : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal sync_data_reg1 : std_logic_vector(DATA_WIDTH - 1 downto 0);
  attribute ASYNC_REG : string;
  attribute ASYNC_REG of sync_data_reg0 : signal is "TRUE";
  attribute ASYNC_REG of sync_data_reg1 : signal is "TRUE";
  signal sync_valid : std_logic;
begin

  valid_sync_inst : entity work.pulse_sync
    generic map(
      FF_COUNT => 3 -- take spare to allow data to be stable at output
    )
    port map(
      src_clk_i  => src_clk_i,
      src_rst_i  => src_rst_i,
      dest_clk_i => dst_clk_i,
      dest_rst_i => src_rst_i,
      pulse_i    => src_valid_i,
      pulse_o    => sync_valid
    );
  aproc_vec_valid_sync : process (dst_clk_i, src_rst_i)
  begin
    if src_rst_i = '1' then
      dst_valid_o <= '0';
    elsif rising_edge(dst_clk_i) then
      dst_valid_o <= '0';
      sync_data_reg0 <= src_data_i;
      sync_data_reg1 <= sync_data_reg0;
      if (sync_valid = '1') then
        dst_data_o <= sync_data_reg1;
        dst_valid_o <= '1';
      end if;
    end if;
  end process aproc_vec_valid_sync;

end architecture arch;
