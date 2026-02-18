----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
--
-- Design Name:
-- Module Name:
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: AXI control module for data control and acquisition
--
-- Dependencies: None.
--
-- Revision: 2020-11-20
-- Additional Comments:
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fifo_record_pkg.all;

entity data_control is
  generic (
    -- Core ID and version
    USER_CORE_ID_VER : std_logic_vector(31 downto 0) := X"00020003";
    N                : integer                       := 1;           --number of ADC channels
    FIFO_EMPTY_VAL   : std_logic_vector(31 downto 0) := X"0000_0DEF" --output value when attempting to read from empty FIFO
  );
  port (
    -- Global Clock Signal
    S_AXI_ACLK      : in std_logic;
    -- Global Reset Signal. This Signal is Active LOW
    S_AXI_ARESETN   : in std_logic;
    -- Write address (issued by master, acceped by Slave)
    S_AXI_AWADDR    : in std_logic_vector(10 - 1 downto 0);
    -- Write channel Protection type. This signal indicates the
    -- privilege and security level of the transaction, and whether
    -- the transaction is a data access or an instruction access.
    S_AXI_AWPROT    : in std_logic_vector(2 downto 0);
    -- Write address valid. This signal indicates that the master signaling
    -- valid write address and control information.
    S_AXI_AWVALID   : in std_logic;
    -- Write address ready. This signal indicates that the slave is ready
    -- to accept an address and associated control signals.
    S_AXI_AWREADY   : out std_logic;
    -- Write data (issued by master, acceped by Slave)
    S_AXI_WDATA     : in std_logic_vector(32 - 1 downto 0);
    -- Write strobes. This signal indicates which byte lanes hold
    -- valid data. There is one write strobe bit for each eight
    -- bits of the write data bus.
    S_AXI_WSTRB     : in std_logic_vector((32/8) - 1 downto 0);
    -- Write valid. This signal indicates that valid write
    -- data and strobes are available.
    S_AXI_WVALID    : in std_logic;
    -- Write ready. This signal indicates that the slave
    -- can accept the write data.
    S_AXI_WREADY    : out std_logic;
    -- Write response. This signal indicates the status
    -- of the write transaction.
    S_AXI_BRESP     : out std_logic_vector(1 downto 0);
    -- Write response valid. This signal indicates that the channel
    -- is signaling a valid write response.
    S_AXI_BVALID    : out std_logic;
    -- Response ready. This signal indicates that the master
    -- can accept a write response.
    S_AXI_BREADY    : in std_logic;
    -- Read address (issued by master, acceped by Slave)
    S_AXI_ARADDR    : in std_logic_vector(10 - 1 downto 0);
    -- Protection type. This signal indicates the privilege
    -- and security level of the transaction, and whether the
    -- transaction is a data access or an instruction access.
    S_AXI_ARPROT    : in std_logic_vector(2 downto 0);
    -- Read address valid. This signal indicates that the channel
    -- is signaling valid read address and control information.
    S_AXI_ARVALID   : in std_logic;
    -- Read address ready. This signal indicates that the slave is
    -- ready to accept an address and associated control signals.
    S_AXI_ARREADY   : out std_logic;
    -- Read data (issued by slave)
    S_AXI_RDATA     : out std_logic_vector(32 - 1 downto 0);
    -- Read response. This signal indicates the status of the
    -- read transfer.
    S_AXI_RRESP     : out std_logic_vector(1 downto 0);
    -- Read valid. This signal indicates that the channel is
    -- signaling the required read data.
    S_AXI_RVALID    : out std_logic;
    -- Read ready. This signal indicates that the master can
    -- accept the read data and response information.
    S_AXI_RREADY    : in std_logic;

    -- Reset signals
    async_rst_o     : out std_logic;
    fifo_rst_o      : out std_logic;

    -- Control signals
    debug_enable_o  : out std_logic;
    debug_control_o : out std_logic_vector((4 * N - 1) downto 0);
    debug_w2w1_o    : out std_logic_vector((28 * N - 1) downto 0);

    -- FIFO signals
    fifo_rd_en_o    : out std_logic_vector((N - 1) downto 0);
    fifo_out_i      : in fifo_out_vector_t((N - 1) downto 0);

    -- External trigger
    ext_trigger_i   : in std_logic
  );
end data_control;

architecture rtl of data_control is

  -- Register inputs
  signal fifo_out : fifo_out_vector_t((16 - 1) downto 0) := (others => fifo_zeros);
  signal fifo_rd_en : std_logic_vector((16 - 1) downto 0) := (others => '0');
  signal fifo_data_out_r, fifo_flags_r : std_logic_vector(16 * 32 - 1 downto 0) := (others => '0');
  signal fifo_progfull_r : std_logic_vector(32 - 1 downto 0) := (others => '0');
  -- Register outputs
  signal async_rst_r, fifo_rst_r : std_logic_vector(32 - 1 downto 0) := (others => '0');
  signal debug_control_r, debug_w2w1_r : std_logic_vector(16 * 32 - 1 downto 0) := (others => '0');
  signal debug_enable_r : std_logic_vector(32 - 1 downto 0);
  -- Aux user register
  signal usr_aux_r : std_logic_vector(32 - 1 downto 0) := (others => '0');

  -- External trigger registers
  signal ext_trigger_r, ext_trigger_en_r : std_logic_vector(32 - 1 downto 0) := (others => '0');
  -- Debug enable aux signal
  signal debug_enable_aux : std_logic := '0';

  --CRC signals
  signal crc_o : std_logic_vector(32 - 1 downto 0) := (others => '0');
  signal crc_data : std_logic_vector(32 - 1 downto 0) := (others => '0');
  signal crc_en : std_logic;
  signal crc_rst_n : std_logic;

  -- Width of S_AXI address bus
  constant C_S_AXI_ADDR_WIDTH : integer := 10;

  -- AXI4LITE signals
  signal axi_awaddr : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
  signal axi_awready : std_logic;
  signal axi_wready : std_logic;
  signal axi_bresp : std_logic_vector(1 downto 0);
  signal axi_bvalid : std_logic;
  signal axi_araddr : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
  signal axi_arready : std_logic;
  signal axi_rdata : std_logic_vector(32 - 1 downto 0);
  signal axi_rresp : std_logic_vector(1 downto 0);
  signal axi_rvalid : std_logic;

  -- local parameter for addressing 32 bit / 64 bit 32
  -- ADDR_LSB is used for addressing 32/64 bit registers/memories
  -- ADDR_LSB = 2 for 32 bits (n downto 2)
  -- ADDR_LSB = 3 for 64 bits (n downto 3)
  constant ADDR_LSB : integer := (32/32) + 1;
  constant OPT_MEM_ADDR_BITS : integer := 7; --memory address width -1 (max 7)
  ------------------------------------------------
  ---- Signals for user logic register space example
  --------------------------------------------------
  ---- Number of Slave Registers 4
  signal slv_reg_rden : std_logic;
  signal slv_reg_wren : std_logic;
  signal reg_data_out : std_logic_vector(32 - 1 downto 0);
  signal byte_index : integer;
  signal aw_en : std_logic;

  -- user logic

begin
  -- I/O Connections assignments
  S_AXI_AWREADY <= axi_awready;
  S_AXI_WREADY <= axi_wready;
  S_AXI_BRESP <= axi_bresp;
  S_AXI_BVALID <= axi_bvalid;
  S_AXI_ARREADY <= axi_arready;
  S_AXI_RDATA <= axi_rdata;
  S_AXI_RRESP <= axi_rresp;
  S_AXI_RVALID <= axi_rvalid;

  -- Implement axi_awready generation
  -- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
  -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
  -- de-asserted when reset is low.

  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        axi_awready <= '0';
        aw_en <= '1';
      else
        if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
          -- slave is ready to accept write address when
          -- there is a valid write address and write data
          -- on the write address and data bus. This design
          -- expects no outstanding transactions.
          axi_awready <= '1';
          aw_en <= '0';
        elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
          aw_en <= '1';
          axi_awready <= '0';
        else
          axi_awready <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Implement axi_awaddr latching
  -- This process is used to latch the address when both
  -- S_AXI_AWVALID and S_AXI_WVALID are valid.

  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        axi_awaddr <= (others => '0');
      else
        if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
          -- Write Address latching
          axi_awaddr <= S_AXI_AWADDR;
        end if;
      end if;
    end if;
  end process;

  -- Implement axi_wready generation
  -- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
  -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is
  -- de-asserted when reset is low.

  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        axi_wready <= '0';
      else
        if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then
          -- slave is ready to accept write data when
          -- there is a valid write address and write data
          -- on the write address and data bus. This design
          -- expects no outstanding transactions.
          axi_wready <= '1';
        else
          axi_wready <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Implement memory mapped register select and write logic generation
  -- The write data is accepted and written to memory mapped registers when
  -- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
  -- select byte enables of slave registers while writing.
  -- These registers are cleared when reset (active low) is applied.
  -- Slave register write enable is asserted when valid address and data are available
  -- and the slave is ready to accept the write address and write data.
  -- Respective byte enables are asserted as per write strobes

  slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID;

  process (S_AXI_ACLK)
    variable loc_addr_w : std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        async_rst_r <= (others => '0');
        fifo_rst_r <= (others => '0');
        debug_enable_r <= (others => '0');
        debug_control_r <= (others => '0');
        debug_w2w1_r <= (others => '0');
        usr_aux_r <= (others => '0');
        ext_trigger_en_r <= (others => '0');
      else
        loc_addr_w := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
        if (slv_reg_wren = '1') then
          case loc_addr_w is
              --async reset
            when x"01" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  async_rst_r(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --FIFO reset
            when x"02" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  fifo_rst_r(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;

              --debug enable
            when x"04" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_enable_r(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;

              --external trigger enable
            when x"05" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  ext_trigger_en_r(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;

              --debug control 1
            when x"20" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_control_r(0 + byte_index * 8 + 7 downto 0 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug control 2
            when x"21" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_control_r(32 + byte_index * 8 + 7 downto 32 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug control 3
            when x"22" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_control_r(64 + byte_index * 8 + 7 downto 64 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug control 4
            when x"23" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_control_r(96 + byte_index * 8 + 7 downto 96 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug control 5
            when x"24" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_control_r(128 + byte_index * 8 + 7 downto 128 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug control 6
            when x"25" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_control_r(160 + byte_index * 8 + 7 downto 160 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug control 7
            when x"26" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_control_r(192 + byte_index * 8 + 7 downto 192 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug control 8
            when x"27" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_control_r(224 + byte_index * 8 + 7 downto 224 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug control 9
            when x"28" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_control_r(256 + byte_index * 8 + 7 downto 256 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug control 10
            when x"29" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_control_r(288 + byte_index * 8 + 7 downto 288 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug control 11
            when x"2a" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_control_r(320 + byte_index * 8 + 7 downto 320 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug control 12
            when x"2b" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_control_r(352 + byte_index * 8 + 7 downto 352 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug control 13
            when x"2c" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_control_r(384 + byte_index * 8 + 7 downto 384 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug control 14
            when x"2d" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_control_r(416 + byte_index * 8 + 7 downto 416 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug control 15
            when x"2e" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_control_r(448 + byte_index * 8 + 7 downto 448 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug control 16
            when x"2f" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_control_r(480 + byte_index * 8 + 7 downto 480 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;

              --debug w2w1 1
            when x"40" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_w2w1_r(0 + byte_index * 8 + 7 downto 0 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug w2w1 2
            when x"41" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_w2w1_r(32 + byte_index * 8 + 7 downto 32 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug w2w1 3
            when x"42" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_w2w1_r(64 + byte_index * 8 + 7 downto 64 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug w2w1 4
            when x"43" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_w2w1_r(96 + byte_index * 8 + 7 downto 96 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug w2w1 5
            when x"44" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_w2w1_r(128 + byte_index * 8 + 7 downto 128 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug w2w1 6
            when x"45" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_w2w1_r(160 + byte_index * 8 + 7 downto 160 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug w2w1 7
            when x"46" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_w2w1_r(192 + byte_index * 8 + 7 downto 192 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug w2w1 8
            when x"47" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_w2w1_r(224 + byte_index * 8 + 7 downto 224 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug w2w1 9
            when x"48" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_w2w1_r(256 + byte_index * 8 + 7 downto 256 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug w2w1 10
            when x"49" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_w2w1_r(288 + byte_index * 8 + 7 downto 288 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug w2w1 11
            when x"4a" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_w2w1_r(320 + byte_index * 8 + 7 downto 320 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug w2w1 12
            when x"4b" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_w2w1_r(352 + byte_index * 8 + 7 downto 352 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug w2w1 13
            when x"4c" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_w2w1_r(384 + byte_index * 8 + 7 downto 384 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug w2w1 14
            when x"4d" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_w2w1_r(416 + byte_index * 8 + 7 downto 416 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug w2w1 15
            when x"4e" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_w2w1_r(448 + byte_index * 8 + 7 downto 448 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --debug w2w1 16
            when x"4f" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  debug_w2w1_r(480 + byte_index * 8 + 7 downto 480 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;

              --usr aux
            when x"FF" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  usr_aux_r(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;

              --other cases include read-only registers and invalid addresses
            when others =>
              null; -- Maintain actual values
          end case;
        end if;
      end if;
    end if;
  end process;

  -- Implement write response logic generation
  -- The write response and response valid signals are asserted by the slave
  -- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.
  -- This marks the acceptance of address and indicates the status of
  -- write transaction.
  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        axi_bvalid <= '0';
        axi_bresp <= "00"; --need to work more on the responses
      else
        if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0') then
          axi_bvalid <= '1';
          axi_bresp <= "00";
        elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then --check if bready is asserted while bvalid is high)
          axi_bvalid <= '0'; -- (there is a possibility that bready is always asserted high)
        end if;
      end if;
    end if;
  end process;

  -- Implement axi_arready generation
  -- axi_arready is asserted for one S_AXI_ACLK clock cycle when
  -- S_AXI_ARVALID is asserted. axi_awready is
  -- de-asserted when reset (active low) is asserted.
  -- The read address is also latched when S_AXI_ARVALID is
  -- asserted. axi_araddr is reset to zero on reset assertion.
  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        axi_arready <= '0';
        axi_araddr <= (others => '1');
      else
        if (axi_arready = '0' and S_AXI_ARVALID = '1') then
          -- indicates that the slave has acceped the valid read address
          axi_arready <= '1';
          -- Read Address latching
          axi_araddr <= S_AXI_ARADDR;
        else
          axi_arready <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Implement axi_arvalid generation
  -- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both
  -- S_AXI_ARVALID and axi_arready are asserted. The slave registers
  -- data are available on the axi_rdata bus at this instance. The
  -- assertion of axi_rvalid marks the validity of read data on the
  -- bus and axi_rresp indicates the status of read transaction.axi_rvalid
  -- is deasserted on reset (active low). axi_rresp and axi_rdata are
  -- cleared to zero on reset (active low).
  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        axi_rvalid <= '0';
        axi_rresp <= "00";
      else
        if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
          -- Valid read data is available at the read data bus
          axi_rvalid <= '1';
          axi_rresp <= "00"; -- 'OKAY' response
        elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
          -- Read data is accepted by the master
          axi_rvalid <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Implement memory mapped register select and read logic generation
  -- Slave register read enable is asserted when valid address is available
  -- and the slave is ready to accept the read address.
  slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid);

  -- Output register or memory read data
  process (S_AXI_ACLK, axi_araddr)
    variable loc_addr_r : std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
  begin
    -- Address decoding for reading registers
    loc_addr_r := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
    if (rising_edge (S_AXI_ACLK)) then

      -- FIFO read_en default value
      fifo_rd_en <= (others => '0');

      crc_en <= '0';
      crc_rst_n <= '1';

      if (S_AXI_ARESETN = '0') then
        axi_rdata <= (others => '0');
      elsif (slv_reg_rden = '1') then
        -- When there is a valid read address (S_AXI_ARVALID) with
        -- acceptance of read address by the slave (axi_arready),
        -- output the read data matching the read address.
        case loc_addr_r is
            --core ID and version
          when x"00" =>
            axi_rdata <= USER_CORE_ID_VER;
            --async reset readback
          when x"01" =>
            axi_rdata <= async_rst_r;
            --FIFO reset readback
          when x"02" =>
            axi_rdata <= fifo_rst_r;

            --FIFO prog full flags register
          when x"03" =>
            axi_rdata <= fifo_progfull_r;

            --debug enable readback
          when x"04" =>
            axi_rdata <= debug_enable_r;

            --external trigger enable readback
          when x"05" =>
            axi_rdata <= ext_trigger_en_r;

            --external trigger input
          when x"06" =>
            axi_rdata <= ext_trigger_r;

            --debug control 1 readback
          when x"20" =>
            axi_rdata <= debug_control_r(31 downto 0);
            --debug control 2 readback
          when x"21" =>
            axi_rdata <= debug_control_r(63 downto 32);
            --debug control 3 readback
          when x"22" =>
            axi_rdata <= debug_control_r(95 downto 64);
            --debug control 4 readback
          when x"23" =>
            axi_rdata <= debug_control_r(127 downto 96);
            --debug control 5 readback
          when x"24" =>
            axi_rdata <= debug_control_r(159 downto 128);
            --debug control 6 readback
          when x"25" =>
            axi_rdata <= debug_control_r(191 downto 160);
            --debug control 7 readback
          when x"26" =>
            axi_rdata <= debug_control_r(223 downto 192);
            --debug control 8 readback
          when x"27" =>
            axi_rdata <= debug_control_r(255 downto 224);
            --debug control 9 readback
          when x"28" =>
            axi_rdata <= debug_control_r(287 downto 256);
            --debug control 10 readback
          when x"29" =>
            axi_rdata <= debug_control_r(319 downto 288);
            --debug control 11 readback
          when x"2a" =>
            axi_rdata <= debug_control_r(351 downto 320);
            --debug control 12 readback
          when x"2b" =>
            axi_rdata <= debug_control_r(383 downto 352);
            --debug control 13 readback
          when x"2c" =>
            axi_rdata <= debug_control_r(415 downto 384);
            --debug control 14 readback
          when x"2d" =>
            axi_rdata <= debug_control_r(447 downto 416);
            --debug control 15 readback
          when x"2e" =>
            axi_rdata <= debug_control_r(479 downto 448);
            --debug control 16 readback
          when x"2f" =>
            axi_rdata <= debug_control_r(511 downto 480);

            --debug w2w1 1 readback
          when x"40" =>
            axi_rdata <= debug_w2w1_r(31 downto 0);
            --debug w2w1 2 readback
          when x"41" =>
            axi_rdata <= debug_w2w1_r(63 downto 32);
            --debug w2w1 3 readback
          when x"42" =>
            axi_rdata <= debug_w2w1_r(95 downto 64);
            --debug w2w1 4 readback
          when x"43" =>
            axi_rdata <= debug_w2w1_r(127 downto 96);
            --debug w2w1 5 readback
          when x"44" =>
            axi_rdata <= debug_w2w1_r(159 downto 128);
            --debug w2w1 6 readback
          when x"45" =>
            axi_rdata <= debug_w2w1_r(191 downto 160);
            --debug w2w1 7 readback
          when x"46" =>
            axi_rdata <= debug_w2w1_r(223 downto 192);
            --debug w2w1 8 readback
          when x"47" =>
            axi_rdata <= debug_w2w1_r(255 downto 224);
            --debug w2w1 9 readback
          when x"48" =>
            axi_rdata <= debug_w2w1_r(287 downto 256);
            --debug w2w1 10 readback
          when x"49" =>
            axi_rdata <= debug_w2w1_r(319 downto 288);
            --debug w2w1 11 readback
          when x"4a" =>
            axi_rdata <= debug_w2w1_r(351 downto 320);
            --debug w2w1 12 readback
          when x"4b" =>
            axi_rdata <= debug_w2w1_r(383 downto 352);
            --debug w2w1 13 readback
          when x"4c" =>
            axi_rdata <= debug_w2w1_r(415 downto 384);
            --debug w2w1 14 readback
          when x"4d" =>
            axi_rdata <= debug_w2w1_r(447 downto 416);
            --debug w2w1 15 readback
          when x"4e" =>
            axi_rdata <= debug_w2w1_r(479 downto 448);
            --debug w2w1 16 readback
          when x"4f" =>
            axi_rdata <= debug_w2w1_r(511 downto 480);

            --fifo flags 1
          when x"60" =>
            axi_rdata <= fifo_flags_r(31 downto 0);
            --fifo flags 2
          when x"61" =>
            axi_rdata <= fifo_flags_r(63 downto 32);
            --fifo flags 3
          when x"62" =>
            axi_rdata <= fifo_flags_r(95 downto 64);
            --fifo flags 4
          when x"63" =>
            axi_rdata <= fifo_flags_r(127 downto 96);
            --fifo flags 5
          when x"64" =>
            axi_rdata <= fifo_flags_r(159 downto 128);
            --fifo flags 6
          when x"65" =>
            axi_rdata <= fifo_flags_r(191 downto 160);
            --fifo flags 7
          when x"66" =>
            axi_rdata <= fifo_flags_r(223 downto 192);
            --fifo flags 8
          when x"67" =>
            axi_rdata <= fifo_flags_r(255 downto 224);
            --fifo flags 9
          when x"68" =>
            axi_rdata <= fifo_flags_r(287 downto 256);
            --fifo flags 10
          when x"69" =>
            axi_rdata <= fifo_flags_r(319 downto 288);
            --fifo flags 11
          when x"6a" =>
            axi_rdata <= fifo_flags_r(351 downto 320);
            --fifo flags 12
          when x"6b" =>
            axi_rdata <= fifo_flags_r(383 downto 352);
            --fifo flags 13
          when x"6c" =>
            axi_rdata <= fifo_flags_r(415 downto 384);
            --fifo flags 14
          when x"6d" =>
            axi_rdata <= fifo_flags_r(447 downto 416);
            --fifo flags 15
          when x"6e" =>
            axi_rdata <= fifo_flags_r(479 downto 448);
            --fifo flags 16
          when x"6f" =>
            axi_rdata <= fifo_flags_r(511 downto 480);

            --if FIFO is not empty, read data and generate rd_en. Else, output FIFO_EMPTY_VAL

            --FIFO data1 input
          when x"80" =>
            if (fifo_out(0).empty = '0') then
              axi_rdata <= fifo_data_out_r(31 downto 0);
              fifo_rd_en(0) <= '1';
              crc_data <= fifo_data_out_r(31 downto 0);
              crc_en <= '1';
            else
              axi_rdata <= FIFO_EMPTY_VAL;
            end if;
            --FIFO data2 input
          when x"81" =>
            if (fifo_out(1).empty = '0') then
              axi_rdata <= fifo_data_out_r(63 downto 32);
              fifo_rd_en(1) <= '1';
              crc_data <= fifo_data_out_r(63 downto 32);
              crc_en <= '1';
            else
              axi_rdata <= FIFO_EMPTY_VAL;
            end if;
            --FIFO data3 input
          when x"82" =>
            if (fifo_out(2).empty = '0') then
              axi_rdata <= fifo_data_out_r(95 downto 64);
              fifo_rd_en(2) <= '1';
              crc_data <= fifo_data_out_r(95 downto 64);
              crc_en <= '1';
            else
              axi_rdata <= FIFO_EMPTY_VAL;
            end if;
            --FIFO data4 input
          when x"83" =>
            if (fifo_out(3).empty = '0') then
              axi_rdata <= fifo_data_out_r(127 downto 96);
              fifo_rd_en(3) <= '1';
              crc_data <= fifo_data_out_r(127 downto 96);
              crc_en <= '1';
            else
              axi_rdata <= FIFO_EMPTY_VAL;
            end if;
            --FIFO data5 input
          when x"84" =>
            if (fifo_out(4).empty = '0') then
              axi_rdata <= fifo_data_out_r(159 downto 128);
              fifo_rd_en(4) <= '1';
              crc_data <= fifo_data_out_r(159 downto 128);
              crc_en <= '1';
            else
              axi_rdata <= FIFO_EMPTY_VAL;
            end if;
            --FIFO data6 input
          when x"85" =>
            if (fifo_out(5).empty = '0') then
              axi_rdata <= fifo_data_out_r(191 downto 160);
              fifo_rd_en(5) <= '1';
              crc_data <= fifo_data_out_r(191 downto 160);
              crc_en <= '1';
            else
              axi_rdata <= FIFO_EMPTY_VAL;
            end if;
            --FIFO data7 input
          when x"86" =>
            if (fifo_out(6).empty = '0') then
              axi_rdata <= fifo_data_out_r(223 downto 192);
              fifo_rd_en(6) <= '1';
              crc_data <= fifo_data_out_r(223 downto 192);
              crc_en <= '1';
            else
              axi_rdata <= FIFO_EMPTY_VAL;
            end if;
            --FIFO data8 input
          when x"87" =>
            if (fifo_out(7).empty = '0') then
              axi_rdata <= fifo_data_out_r(255 downto 224);
              fifo_rd_en(7) <= '1';
              crc_data <= fifo_data_out_r(255 downto 224);
              crc_en <= '1';
            else
              axi_rdata <= FIFO_EMPTY_VAL;
            end if;
            --FIFO data9 input
          when x"88" =>
            if (fifo_out(8).empty = '0') then
              axi_rdata <= fifo_data_out_r(287 downto 256);
              fifo_rd_en(8) <= '1';
              crc_data <= fifo_data_out_r(287 downto 256);
              crc_en <= '1';
            else
              axi_rdata <= FIFO_EMPTY_VAL;
            end if;
            --FIFO data10 input
          when x"89" =>
            if (fifo_out(9).empty = '0') then
              axi_rdata <= fifo_data_out_r(319 downto 288);
              fifo_rd_en(9) <= '1';
              crc_data <= fifo_data_out_r(319 downto 288);
              crc_en <= '1';
            else
              axi_rdata <= FIFO_EMPTY_VAL;
            end if;
            --FIFO data11 input
          when x"8a" =>
            if (fifo_out(10).empty = '0') then
              axi_rdata <= fifo_data_out_r(351 downto 320);
              fifo_rd_en(10) <= '1';
              crc_data <= fifo_data_out_r(351 downto 320);
              crc_en <= '1';
            else
              axi_rdata <= FIFO_EMPTY_VAL;
            end if;
            --FIFO data12 input
          when x"8b" =>
            if (fifo_out(11).empty = '0') then
              axi_rdata <= fifo_data_out_r(383 downto 352);
              fifo_rd_en(11) <= '1';
              crc_data <= fifo_data_out_r(383 downto 352);
              crc_en <= '1';
            else
              axi_rdata <= FIFO_EMPTY_VAL;
            end if;
            --FIFO data13 input
          when x"8c" =>
            if (fifo_out(12).empty = '0') then
              axi_rdata <= fifo_data_out_r(415 downto 384);
              fifo_rd_en(12) <= '1';
              crc_data <= fifo_data_out_r(415 downto 384);
              crc_en <= '1';
            else
              axi_rdata <= FIFO_EMPTY_VAL;
            end if;
            --FIFO data14 input
          when x"8d" =>
            if (fifo_out(13).empty = '0') then
              axi_rdata <= fifo_data_out_r(447 downto 416);
              fifo_rd_en(13) <= '1';
              crc_data <= fifo_data_out_r(447 downto 416);
              crc_en <= '1';
            else
              axi_rdata <= FIFO_EMPTY_VAL;
            end if;
            --FIFO data15 input
          when x"8e" =>
            if (fifo_out(14).empty = '0') then
              axi_rdata <= fifo_data_out_r(479 downto 448);
              fifo_rd_en(14) <= '1';
              crc_data <= fifo_data_out_r(479 downto 448);
              crc_en <= '1';
            else
              axi_rdata <= FIFO_EMPTY_VAL;
            end if;
            --FIFO data16 input
          when x"8f" =>
            if (fifo_out(15).empty = '0') then
              axi_rdata <= fifo_data_out_r(511 downto 480);
              fifo_rd_en(15) <= '1';
              crc_data <= fifo_data_out_r(511 downto 480);
              crc_en <= '1';
            else
              axi_rdata <= FIFO_EMPTY_VAL;
            end if;

          when x"90" =>
            axi_rdata <= crc_o(31 downto 0);
            crc_rst_n <= '0';

            --usr aux
          when x"FF" =>
            axi_rdata <= usr_aux_r;

          when others =>
            axi_rdata <= (others => '0');
        end case;
      end if;
    end if;
  end process;

  -- User logic

  --Logic for external trigger selection
  debug_enable_aux <= (debug_enable_r(0) and ext_trigger_i) when ext_trigger_en_r(0) = '1' else
    debug_enable_r(0);

  -- Register inputs and outputs
  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      --Reset outputs
      fifo_rst_o <= fifo_rst_r(0);
      async_rst_o <= async_rst_r(0);
      --Debug enable output
      debug_enable_o <= debug_enable_aux;
      --External trigger input
      ext_trigger_r(0) <= ext_trigger_i;

    end if;
  end process;

  --generate input/output register mapping
  inout_reg_map : for i in 0 to (N - 1) generate

    fifo_out(i) <= fifo_out_i(i);
    fifo_rd_en_o(i) <= fifo_rd_en(i);

    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then
        --outputs
        debug_control_o((4 * (i + 1) - 1) downto (4 * i)) <= debug_control_r((32 * i + 4 - 1) downto (32 * i));
        debug_w2w1_o((28 * (i + 1) - 1) downto (28 * i)) <= debug_w2w1_r((32 * i + 28 - 1) downto (32 * i));

        --inputs
        fifo_data_out_r((32 * (i + 1) - 1) downto (32 * i)) <= fifo_out_i(i).data_out;

        --fifo_flags_r((32 * i + 12 - 1) downto (32 * i)) <= fifo_out_i(i).rd_data_cnt;
        fifo_flags_r((32 * i + 10) downto (32 * i)) <= fifo_out_i(i).rd_data_cnt;
        fifo_flags_r(12 + 32 * i) <= fifo_out_i(i).rd_rst_bsy;
        fifo_flags_r(13 + 32 * i) <= fifo_out_i(i).wr_rst_bsy;
        fifo_flags_r(14 + 32 * i) <= fifo_out_i(i).overflow;
        fifo_flags_r(15 + 32 * i) <= fifo_out_i(i).empty;
        fifo_flags_r(16 + 32 * i) <= fifo_out_i(i).full;
        fifo_flags_r(17 + 32 * i) <= fifo_out_i(i).prog_full;

        fifo_progfull_r(i) <= fifo_out_i(i).prog_full;
      end if;
    end process;

  end generate inout_reg_map;

  crc_32_inst : entity work.crc_32(imp_crc)
    port map(
      clk      => S_AXI_ACLK,
      rstn_in  => S_AXI_ARESETN,
      srstn_in => crc_rst_n,
      data_in  => crc_data,
      crc_en   => crc_en,
      crc_out  => crc_o
    );
end rtl;
