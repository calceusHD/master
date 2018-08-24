
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

package common is
constant LLR_BITS :natural := 8;
type llr_row_t is array(0 to 2-1) of signed(8-1 downto 0);
type llr_array_t is array(0 to 27-1, 0  to 2-1) of signed(8-1 downto 0);
type llr_column_t is array(0 to 27-1) of signed(8-1 downto 0);
subtype column_sum_t is signed(12-1 downto 0);
type column_sum_array_t is array(0 to 27-1) of column_sum_t;
subtype min_signs_t is std_logic_vector(0 to 27-1);
subtype min_t is unsigned(8-1 downto 0);
type min_array_t is array(0 to 27-1) of unsigned(8-1 downto 0);
type signs_t is array(0 to 27-1) of std_logic_vector(0 to 2-1);
subtype min_id_t is unsigned(4-1 downto 0);
type min_id_array_t is array(0 to 27-1) of min_id_t;
type roll_count_t is array(0 to 2-1) of natural;
subtype row_addr_t is unsigned(5-1 downto 0);
subtype col_addr_t is unsigned(4-1 downto 0);
subtype roll_t is unsigned(5-1 downto 0);
constant ROLL_COUNT : roll_count_t := (0,5);
constant HQC_COLUMNS : natural := 24;
constant VN_MEM_BITS : natural := 5;
constant CN_MEM_BITS : natural := 4;
type inst_t is 
    record
        row_end : std_logic;
        col_end : std_logic;
        llr_mem_rd : std_logic;
        llr_mem_addr : row_addr_t;
        result_addr : row_addr_t;
        result_wr : std_logic;
        store_cn_wr : std_logic;
        store_cn_addr : col_addr_t;
        load_cn_rd : std_logic;
        load_cn_addr : col_addr_t;
        store_vn_wr : std_logic;
        store_vn_addr : row_addr_t;
        load_vn_rd : std_logic;
        load_vn_addr : row_addr_t;
        min_offset : min_id_t;
        roll : roll_t;
    end record;
type inst_array_t is array(integer range <>) of inst_t;
constant INSTRUCTIONS : inst_t(0 to 1-1) := ;
end package;