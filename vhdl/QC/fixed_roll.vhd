library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity fixed_roll is
	generic (
		ROLL_COUNTS : roll_count_t
	);
    port (
        data_in : in llr_array_t;
		data_out : out llr_array_t
    );
end entity;

architecture base of fixed_roll is
begin
	gen_i : for i in data_in'range(1) generate
	begin
		gen_j : for j in data_in'range(2) generate
		begin
			data_out(i, j) <= data_in((i - ROLL_COUNTS(j)) mod data_in'length, j);
		end generate;
	end generate;

end architecture;
