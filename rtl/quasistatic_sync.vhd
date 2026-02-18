library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity quasistatic_sync is
  generic (
    DATA_WIDTH : integer := 32
  );
  port (
    src_data_i  : in std_logic_vector(DATA_WIDTH - 1 downto 0);

    sys_clk_i   : in std_logic;
    sync_data_o : out std_logic_vector(DATA_WIDTH - 1 downto 0)
  );
end entity quasistatic_sync;

architecture arch of quasistatic_sync is
  signal sync_data_reg0 : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal sync_data_reg1 : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal sync_data_reg2 : std_logic_vector(DATA_WIDTH - 1 downto 0);

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of sync_data_reg0 : signal is "TRUE";
  attribute ASYNC_REG of sync_data_reg1 : signal is "TRUE";
begin
  aproc_quasistatic_sync : process (sys_clk_i)
  begin
    if rising_edge(sys_clk_i) then
      sync_data_reg0 <= src_data_i;
      sync_data_reg1 <= sync_data_reg0;
      sync_data_reg2 <= sync_data_reg1;
      if (sync_data_reg1 = sync_data_reg2) then
        sync_data_o <= sync_data_reg2;
      end if;
    end if;
  end process aproc_quasistatic_sync;
end architecture arch;
