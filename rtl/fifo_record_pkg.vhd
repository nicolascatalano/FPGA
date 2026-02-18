----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
--
-- Design Name:
-- Module Name:
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: Package containing FIFO data record declaration
--
-- Dependencies: None.
--
-- Revision: 2020-10-25
-- Additional Comments:
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package fifo_record_pkg is

  -- Outputs from the FIFO.
  type fifo_out_t is record
    full : std_logic; -- FIFO Full Flag
    empty : std_logic; -- FIFO Empty Flag
    overflow : std_logic;
    prog_full : std_logic;
    wr_rst_bsy : std_logic;
    rd_rst_bsy : std_logic;
    --rd_data_cnt : std_logic_vector (12 - 1 downto 0);
    rd_data_cnt : std_logic_vector (10 downto 0);
    data_out : std_logic_vector (32 - 1 downto 0);
  end record fifo_out_t;

  constant fifo_zeros : fifo_out_t :=
  (
  full => '0',
  empty => '0',
  overflow => '0',
  prog_full => '0',
  wr_rst_bsy => '0',
  rd_rst_bsy => '0',
  rd_data_cnt => (others => '0'),
  data_out => (others => '0')
  );

  type fifo_out_vector_t is array (integer range <>) of fifo_out_t;

end package fifo_record_pkg;
