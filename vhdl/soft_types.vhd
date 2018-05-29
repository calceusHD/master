library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package soft_types is
	constant LLR_BITS : natural := 5;
	subtype llr_type is signed;
	type llr_type_array is array(natural range <>) of signed(LLR_BITS-1 downto 0);
end package;


