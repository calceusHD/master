
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
constant ROLL_COUNT : roll_count_t := (0,5);
end package;