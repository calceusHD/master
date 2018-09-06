library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity attach_signs is
	port (
		signless_in : in llr_array_t;
		signs_in : in signs_t;
        sign_in : in min_signs_t;
		signed_out : out llr_array_t
	);
end entity;

architecture base of attach_signs is
begin

	gen_i : for i in signless_in'range(1) generate
	begin
		gen_j : for j in signless_in'range(2) generate
		begin
			signed_out(i, j) <= - signless_in(i, j) when (signs_in(i)(j) xor sign_in(i)) = '1' else signless_in(i, j);
		end generate;
	end generate;
end architecture;
