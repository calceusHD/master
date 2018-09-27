library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity min_offset is
	port (
		offset : in min_t;
		min_in : in min_array_t;
		
		min_out : out min_array_t
	);
end entity;

architecture base of min_offset is
begin

	sub_gen : for i in min_in'range generate
		sub : entity work.unsigned_sub_sat
		port map (
			a => min_in(i),
			b => offset,
			res => min_out(i)
		);
	end generate;
end architecture;
	
