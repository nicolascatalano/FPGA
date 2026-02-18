----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
--
-- Design Name:
-- Module Name:
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: AXI control module for IDELAY
--
-- Dependencies: None.
--
-- Revision: 2020-11-19
-- Additional Comments:
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity delay_control is
  generic (
    N : integer := 16 --number of ADC signals present
  );
  port (
    -- Global Clock Signal
    S_AXI_ACLK            : in std_logic;
    -- Global Reset Signal. This Signal is Active LOW
    S_AXI_ARESETN         : in std_logic;
    -- Write address (issued by master, acceped by Slave)
    S_AXI_AWADDR          : in std_logic_vector(10 - 1 downto 0);
    -- Write channel Protection type. This signal indicates the
    -- privilege and security level of the transaction, and whether
    -- the transaction is a data access or an instruction access.
    S_AXI_AWPROT          : in std_logic_vector(2 downto 0);
    -- Write address valid. This signal indicates that the master signaling
    -- valid write address and control information.
    S_AXI_AWVALID         : in std_logic;
    -- Write address ready. This signal indicates that the slave is ready
    -- to accept an address and associated control signals.
    S_AXI_AWREADY         : out std_logic;
    -- Write data (issued by master, acceped by Slave)
    S_AXI_WDATA           : in std_logic_vector(32 - 1 downto 0);
    -- Write strobes. This signal indicates which byte lanes hold
    -- valid data. There is one write strobe bit for each eight
    -- bits of the write data bus.
    S_AXI_WSTRB           : in std_logic_vector((32/8) - 1 downto 0);
    -- Write valid. This signal indicates that valid write
    -- data and strobes are available.
    S_AXI_WVALID          : in std_logic;
    -- Write ready. This signal indicates that the slave
    -- can accept the write data.
    S_AXI_WREADY          : out std_logic;
    -- Write response. This signal indicates the status
    -- of the write transaction.
    S_AXI_BRESP           : out std_logic_vector(1 downto 0);
    -- Write response valid. This signal indicates that the channel
    -- is signaling a valid write response.
    S_AXI_BVALID          : out std_logic;
    -- Response ready. This signal indicates that the master
    -- can accept a write response.
    S_AXI_BREADY          : in std_logic;
    -- Read address (issued by master, acceped by Slave)
    S_AXI_ARADDR          : in std_logic_vector(10 - 1 downto 0);
    -- Protection type. This signal indicates the privilege
    -- and security level of the transaction, and whether the
    -- transaction is a data access or an instruction access.
    S_AXI_ARPROT          : in std_logic_vector(2 downto 0);
    -- Read address valid. This signal indicates that the channel
    -- is signaling valid read address and control information.
    S_AXI_ARVALID         : in std_logic;
    -- Read address ready. This signal indicates that the slave is
    -- ready to accept an address and associated control signals.
    S_AXI_ARREADY         : out std_logic;
    -- Read data (issued by slave)
    S_AXI_RDATA           : out std_logic_vector(32 - 1 downto 0);
    -- Read response. This signal indicates the status of the
    -- read transfer.
    S_AXI_RRESP           : out std_logic_vector(1 downto 0);
    -- Read valid. This signal indicates that the channel is
    -- signaling the required read data.
    S_AXI_RVALID          : out std_logic;
    -- Read ready. This signal indicates that the master can
    -- accept the read data and response information.
    S_AXI_RREADY          : in std_logic;

    -- User I/O
    delay_locked1_i       : in std_logic;
    delay_data_ld_o       : out std_logic_vector((N - 1) downto 0);
    delay_data_input_o    : out std_logic_vector((5 * N - 1) downto 0);
    delay_data_output_i   : in std_logic_vector((5 * N - 1) downto 0);
    delay_frame1_ld_o     : out std_logic;
    delay_frame1_input_o  : out std_logic_vector((5 - 1) downto 0);
    delay_frame1_output_i : in std_logic_vector((5 - 1) downto 0);
    delay_frame2_ld_o     : out std_logic;
    delay_frame2_input_o  : out std_logic_vector((5 - 1) downto 0);
    delay_frame2_output_i : in std_logic_vector((5 - 1) downto 0)
  );
end delay_control;

architecture rtl of delay_control is

  -- Width of S_AXI address bus
  constant C_S_AXI_ADDR_WIDTH : integer := 10;

  -- Input registers
  signal delay_locked1_r : std_logic_vector(32 - 1 downto 0) := (others => '0');
  signal delay_frame1_output_r : std_logic_vector(32 - 1 downto 0) := (others => '0');
  signal delay_frame2_output_r : std_logic_vector(32 - 1 downto 0) := (others => '0');
  signal delay_data_output_r : std_logic_vector(16 * 32 - 1 downto 0) := (others => '0');

  -- Output registers
  signal delay_frame1_ld_r, delay_frame1_input_r : std_logic_vector(32 - 1 downto 0) := (others => '0');
  signal delay_frame2_ld_r, delay_frame2_input_r : std_logic_vector(32 - 1 downto 0) := (others => '0');
  signal delay_data_ld_r, delay_data_input_r : std_logic_vector(16 * 32 - 1 downto 0) := (others => '0');

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
        delay_frame1_ld_r <= (others => '0');
        delay_frame2_ld_r <= (others => '0');
        delay_frame1_input_r <= (others => '0');
        delay_frame2_input_r <= (others => '0');
        delay_data_ld_r <= (others => '0');
        delay_data_input_r <= (others => '0');
      else
        loc_addr_w := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
        if (slv_reg_wren = '1') then
          case loc_addr_w is
              --frame1 load
            when x"02" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_frame1_ld_r(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --frame2 load
            when x"03" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_frame2_ld_r(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --frame1 value
            when x"04" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_frame1_input_r(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --frame2 value
            when x"05" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_frame2_input_r(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;

              --delay load for data 1
            when x"20" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_ld_r(0 + byte_index * 8 + 7 downto 0 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay load for data 2
            when x"21" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_ld_r(32 + byte_index * 8 + 7 downto 32 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay load for data 3
            when x"22" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_ld_r(64 + byte_index * 8 + 7 downto 64 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay load for data 4
            when x"23" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_ld_r(96 + byte_index * 8 + 7 downto 96 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay load for data 5
            when x"24" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_ld_r(128 + byte_index * 8 + 7 downto 128 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay load for data 6
            when x"25" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_ld_r(160 + byte_index * 8 + 7 downto 160 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay load for data 7
            when x"26" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_ld_r(192 + byte_index * 8 + 7 downto 192 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay load for data 8
            when x"27" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_ld_r(224 + byte_index * 8 + 7 downto 224 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay load for data 9
            when x"28" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_ld_r(256 + byte_index * 8 + 7 downto 256 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay load for data 10
            when x"29" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_ld_r(288 + byte_index * 8 + 7 downto 288 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay load for data 11
            when x"2a" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_ld_r(320 + byte_index * 8 + 7 downto 320 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay load for data 12
            when x"2b" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_ld_r(352 + byte_index * 8 + 7 downto 352 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay load for data 13
            when x"2c" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_ld_r(384 + byte_index * 8 + 7 downto 384 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay load for data 14
            when x"2d" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_ld_r(416 + byte_index * 8 + 7 downto 416 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay load for data 15
            when x"2e" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_ld_r(448 + byte_index * 8 + 7 downto 448 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay load for data 16
            when x"2f" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_ld_r(480 + byte_index * 8 + 7 downto 480 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;

              --delay input for data 1
            when x"40" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_input_r(0 + byte_index * 8 + 7 downto 0 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay input for data 2
            when x"41" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_input_r(32 + byte_index * 8 + 7 downto 32 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay input for data 3
            when x"42" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_input_r(64 + byte_index * 8 + 7 downto 64 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay input for data 4
            when x"43" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_input_r(96 + byte_index * 8 + 7 downto 96 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay input for data 5
            when x"44" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_input_r(128 + byte_index * 8 + 7 downto 128 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay input for data 6
            when x"45" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_input_r(160 + byte_index * 8 + 7 downto 160 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay input for data 7
            when x"46" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_input_r(192 + byte_index * 8 + 7 downto 192 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay input for data 8
            when x"47" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_input_r(224 + byte_index * 8 + 7 downto 224 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay input for data 9
            when x"48" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_input_r(256 + byte_index * 8 + 7 downto 256 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay input for data 10
            when x"49" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_input_r(288 + byte_index * 8 + 7 downto 288 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay input for data 11
            when x"4a" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_input_r(320 + byte_index * 8 + 7 downto 320 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay input for data 12
            when x"4b" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_input_r(352 + byte_index * 8 + 7 downto 352 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay input for data 13
            when x"4c" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_input_r(384 + byte_index * 8 + 7 downto 384 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay input for data 14
            when x"4d" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_input_r(416 + byte_index * 8 + 7 downto 416 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay input for data 15
            when x"4e" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_input_r(448 + byte_index * 8 + 7 downto 448 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                end if;
              end loop;
              --delay input for data 16
            when x"4f" =>
              for byte_index in 0 to (32/8 - 1) loop
                if (S_AXI_WSTRB(byte_index) = '1') then
                  delay_data_input_r(480 + byte_index * 8 + 7 downto 480 + byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
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
      if (S_AXI_ARESETN = '0') then
        axi_rdata <= (others => '0');
      elsif (slv_reg_rden = '1') then
        -- When there is a valid read address (S_AXI_ARVALID) with
        -- acceptance of read address by the slave (axi_arready),
        -- output the read data matching the read address.
        case loc_addr_r is
            --locked state
          when x"00" =>
            axi_rdata <= delay_locked1_r;

            --delay frame1 load readback
          when x"02" =>
            axi_rdata <= delay_frame1_ld_r;
            --delay frame2 load readback
          when x"03" =>
            axi_rdata <= delay_frame2_ld_r;

            --delay frame1 input readback
          when x"04" =>
            axi_rdata <= delay_frame1_input_r;
            --delay frame2 input readback
          when x"05" =>
            axi_rdata <= delay_frame2_input_r;

            --delay frame1 output
          when x"06" =>
            axi_rdata <= delay_frame1_output_r;
            --delay frame2 output
          when x"07" =>
            axi_rdata <= delay_frame2_output_r;

            --delay load for data 1 readback
          when x"20" =>
            axi_rdata <= delay_data_ld_r(31 downto 0);
            --delay load for data 2 readback
          when x"21" =>
            axi_rdata <= delay_data_ld_r(63 downto 32);
            --delay load for data 3 readback
          when x"22" =>
            axi_rdata <= delay_data_ld_r(95 downto 64);
            --delay load for data 4 readback
          when x"23" =>
            axi_rdata <= delay_data_ld_r(127 downto 96);
            --delay load for data 5 readback
          when x"24" =>
            axi_rdata <= delay_data_ld_r(159 downto 128);
            --delay load for data 6 readback
          when x"25" =>
            axi_rdata <= delay_data_ld_r(191 downto 160);
            --delay load for data 7 readback
          when x"26" =>
            axi_rdata <= delay_data_ld_r(223 downto 192);
            --delay load for data 8 readback
          when x"27" =>
            axi_rdata <= delay_data_ld_r(255 downto 224);
            --delay load for data 9 readback
          when x"28" =>
            axi_rdata <= delay_data_ld_r(287 downto 256);
            --delay load for data 10 readback
          when x"29" =>
            axi_rdata <= delay_data_ld_r(319 downto 288);
            --delay load for data 11 readback
          when x"2a" =>
            axi_rdata <= delay_data_ld_r(351 downto 320);
            --delay load for data 12 readback
          when x"2b" =>
            axi_rdata <= delay_data_ld_r(383 downto 352);
            --delay load for data 13 readback
          when x"2c" =>
            axi_rdata <= delay_data_ld_r(415 downto 384);
            --delay load for data 14 readback
          when x"2d" =>
            axi_rdata <= delay_data_ld_r(447 downto 416);
            --delay load for data 15 readback
          when x"2e" =>
            axi_rdata <= delay_data_ld_r(479 downto 448);
            --delay load for data 16 readback
          when x"2f" =>
            axi_rdata <= delay_data_ld_r(511 downto 480);

            --delay input for data 1 readback
          when x"40" =>
            axi_rdata <= delay_data_input_r(31 downto 0);
            --delay input for data 2 readback
          when x"41" =>
            axi_rdata <= delay_data_input_r(63 downto 32);
            --delay input for data 3 readback
          when x"42" =>
            axi_rdata <= delay_data_input_r(95 downto 64);
            --delay input for data 4 readback
          when x"43" =>
            axi_rdata <= delay_data_input_r(127 downto 96);
            --delay input for data 5 readback
          when x"44" =>
            axi_rdata <= delay_data_input_r(159 downto 128);
            --delay input for data 6 readback
          when x"45" =>
            axi_rdata <= delay_data_input_r(191 downto 160);
            --delay input for data 7 readback
          when x"46" =>
            axi_rdata <= delay_data_input_r(223 downto 192);
            --delay input for data 8 readback
          when x"47" =>
            axi_rdata <= delay_data_input_r(255 downto 224);
            --delay input for data 9 readback
          when x"48" =>
            axi_rdata <= delay_data_input_r(287 downto 256);
            --delay input for data 10 readback
          when x"49" =>
            axi_rdata <= delay_data_input_r(319 downto 288);
            --delay input for data 11 readback
          when x"4a" =>
            axi_rdata <= delay_data_input_r(351 downto 320);
            --delay input for data 12 readback
          when x"4b" =>
            axi_rdata <= delay_data_input_r(383 downto 352);
            --delay input for data 13 readback
          when x"4c" =>
            axi_rdata <= delay_data_input_r(415 downto 384);
            --delay input for data 14 readback
          when x"4d" =>
            axi_rdata <= delay_data_input_r(447 downto 416);
            --delay input for data 15 readback
          when x"4e" =>
            axi_rdata <= delay_data_input_r(479 downto 448);
            --delay input for data 16 readback
          when x"4f" =>
            axi_rdata <= delay_data_input_r(511 downto 480);

            --delay output for data 1
          when x"60" =>
            axi_rdata <= delay_data_output_r(31 downto 0);
            --delay output for data 2
          when x"61" =>
            axi_rdata <= delay_data_output_r(63 downto 32);
            --delay output for data 3
          when x"62" =>
            axi_rdata <= delay_data_output_r(95 downto 64);
            --delay output for data 4
          when x"63" =>
            axi_rdata <= delay_data_output_r(127 downto 96);
            --delay output for data 5
          when x"64" =>
            axi_rdata <= delay_data_output_r(159 downto 128);
            --delay output for data 6
          when x"65" =>
            axi_rdata <= delay_data_output_r(191 downto 160);
            --delay output for data 7
          when x"66" =>
            axi_rdata <= delay_data_output_r(223 downto 192);
            --delay output for data 8
          when x"67" =>
            axi_rdata <= delay_data_output_r(255 downto 224);
            --delay output for data 9
          when x"68" =>
            axi_rdata <= delay_data_output_r(287 downto 256);
            --delay output for data 10
          when x"69" =>
            axi_rdata <= delay_data_output_r(319 downto 288);
            --delay output for data 11
          when x"6a" =>
            axi_rdata <= delay_data_output_r(351 downto 320);
            --delay output for data 12
          when x"6b" =>
            axi_rdata <= delay_data_output_r(383 downto 352);
            --delay output for data 13
          when x"6c" =>
            axi_rdata <= delay_data_output_r(415 downto 384);
            --delay output for data 14
          when x"6d" =>
            axi_rdata <= delay_data_output_r(447 downto 416);
            --delay output for data 15
          when x"6e" =>
            axi_rdata <= delay_data_output_r(479 downto 448);
            --delay output for data 16
          when x"6f" =>
            axi_rdata <= delay_data_output_r(511 downto 480);

          when others =>
            axi_rdata <= (others => '0');
        end case;
      end if;
    end if;
  end process;

  -- User logic

  -- Register inputs and outputs
  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      -- --Outputs
      delay_frame1_ld_o <= delay_frame1_ld_r(0);
      delay_frame1_input_o <= delay_frame1_input_r((5 - 1) downto 0);
      delay_frame2_ld_o <= delay_frame2_ld_r(0);
      delay_frame2_input_o <= delay_frame2_input_r((5 - 1) downto 0);
      --Inputs
      delay_locked1_r(0) <= delay_locked1_i;
      delay_frame1_output_r((5 - 1) downto 0) <= delay_frame1_output_i;
      delay_frame2_output_r((5 - 1) downto 0) <= delay_frame2_output_i;
    end if;
  end process;

  --generate input/output register mapping
  inout_reg_map : for i in 0 to (N - 1) generate
    process (S_AXI_ACLK)
    begin
      if rising_edge(S_AXI_ACLK) then
        --outputs
        delay_data_ld_o(i) <= delay_data_ld_r(32 * i);
        delay_data_input_o((5 * (i + 1) - 1) downto (5 * i)) <= delay_data_input_r((32 * i + 5 - 1) downto (32 * i));
        --inputs
        delay_data_output_r((32 * i + 5 - 1) downto (32 * i)) <= delay_data_output_i((5 * (i + 1) - 1) downto (5 * i));
      end if;
    end process;
  end generate inout_reg_map;

end rtl;
