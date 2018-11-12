library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;
use work.fixed_generic_pkg_mod.all;


entity min_mangle is
	port (
		val_1 : in min_t;
		val_2 : in min_t;

		hard_cn_res : in min_signs_t;
		
		min_in : in min_array_t;
		min2_in : in min_array_t;

		min_out : out min_array_t;
		min2_out : out min_array_t
	);
end entity;

architecture offset of min_mangle is
begin

asdf : for i in min_in'range generate
    min_out(i) <= to_unsigned(to_ufixed(min_in(i), min_in(0)'length-1, 0) * to_ufixed(std_logic_vector(val_1), 0, -min_in(0)'length+1), min_in(0)'length);
    min2_out(i) <= to_unsigned(to_ufixed(min2_in(i), min_in(0)'length-1, 0) * to_ufixed(std_logic_vector(val_1), 0, -min_in(0)'length+1), min_in(0)'length);
end generate;
--	min_offset_inst1 : entity work.min_offset
--	port map (
--		offset => val_1,
--		min_in => min_in,
--		min_out => min_out
--	);


--	min_offset_inst2 : entity work.min_offset
--	port map (
--		offset => val_1,
--		min_in => min2_in,
--		min_out => min2_out
--	);
end architecture;
