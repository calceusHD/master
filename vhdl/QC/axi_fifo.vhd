library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity axi_fifo is
  generic (
    g_WIDTH : natural := 33;
    g_DEPTH : integer := 32
    );
  port (
    clk : in std_logic;
    res : in std_logic;
    
    s_tvalid : in std_logic;
    s_tlast : in std_logic;
    s_tdata : in std_logic_vector(31 downto 0);
    s_tready : out std_logic;
    m_tvalid : out std_logic;
    m_tlast : out std_logic;
    m_tdata : out std_logic_vector(31 downto 0);
    m_tready : in std_logic
    );
end axi_fifo;
 
architecture rtl of axi_fifo is
 
  type t_FIFO_DATA is array (0 to g_DEPTH-1) of std_logic_vector(g_WIDTH-1 downto 0);
  signal r_FIFO_DATA : t_FIFO_DATA := (others => (others => '0'));
 
  signal r_WR_INDEX   : integer range 0 to g_DEPTH-1 := 0;
  signal r_RD_INDEX   : integer range 0 to g_DEPTH-1 := 0;
 
  -- # Words in FIFO, has extra range to allow for assert conditions
  signal r_FIFO_COUNT : integer range -1 to g_DEPTH+1 := 0;
 
  signal w_FULL  : std_logic;
  signal w_EMPTY : std_logic;
  
  signal i_clk, i_rst_sync, i_wr_en, o_full, i_rd_en, o_empty : std_logic;
  signal i_wr_data, o_rd_data : std_logic_vector(32 downto 0);
   
begin
  i_clk <= clk;
  i_rst_sync <= res;
  s_tready <= not o_full;
  i_wr_en <= s_tvalid and not o_full;
  m_tvalid <= not o_empty;
  i_rd_en <= m_tready and not o_empty;
  i_wr_data <= s_tlast & s_tdata;
  m_tlast <= o_rd_data(32);
  m_tdata <= o_rd_data(31 downto 0);
  
 
  p_CONTROL : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_rst_sync = '1' then
        r_FIFO_COUNT <= 0;
        r_WR_INDEX   <= 0;
        r_RD_INDEX   <= 0;
      else
 
        -- Keeps track of the total number of words in the FIFO
        if (i_wr_en = '1' and i_rd_en = '0') then
          r_FIFO_COUNT <= r_FIFO_COUNT + 1;
        elsif (i_wr_en = '0' and i_rd_en = '1') then
          r_FIFO_COUNT <= r_FIFO_COUNT - 1;
        end if;
 
        -- Keeps track of the write index (and controls roll-over)
        if (i_wr_en = '1' and w_FULL = '0') then
          if r_WR_INDEX = g_DEPTH-1 then
            r_WR_INDEX <= 0;
          else
            r_WR_INDEX <= r_WR_INDEX + 1;
          end if;
        end if;
 
        -- Keeps track of the read index (and controls roll-over)        
        if (i_rd_en = '1' and w_EMPTY = '0') then
          if r_RD_INDEX = g_DEPTH-1 then
            r_RD_INDEX <= 0;
          else
            r_RD_INDEX <= r_RD_INDEX + 1;
          end if;
        end if;
 
        -- Registers the input data when there is a write
        if i_wr_en = '1' then
          r_FIFO_DATA(r_WR_INDEX) <= i_wr_data;
        end if;
         
      end if;                           -- sync reset
    end if;                             -- rising_edge(i_clk)
  end process p_CONTROL;
   
  o_rd_data <= r_FIFO_DATA(r_RD_INDEX);
 
  w_FULL  <= '1' when r_FIFO_COUNT = g_DEPTH else '0';
  w_EMPTY <= '1' when r_FIFO_COUNT = 0       else '0';
 
  o_full  <= w_FULL;
  o_empty <= w_EMPTY;
   
  -- ASSERTION LOGIC - Not synthesized
  -- synthesis translate_off
 
  p_ASSERT : process (i_clk) is
  begin
    if rising_edge(i_clk) then
      if i_wr_en = '1' and w_FULL = '1' then
        report "ASSERT FAILURE - MODULE_REGISTER_FIFO: FIFO IS FULL AND BEING WRITTEN " severity failure;
      end if;
 
      if i_rd_en = '1' and w_EMPTY = '1' then
        report "ASSERT FAILURE - MODULE_REGISTER_FIFO: FIFO IS EMPTY AND BEING READ " severity failure;
      end if;
    end if;
  end process p_ASSERT;
 
  -- synthesis translate_on
end rtl;
