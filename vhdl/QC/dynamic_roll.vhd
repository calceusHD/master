library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity dynamic_roll is
	generic (
		DIRECTION : boolean --true means the same direction as fixed roll
	);
    port (
		roll_count : in unsigned;
        data_in : in llr_array_t;
		data_out : out llr_array_t
    );
end entity;

architecture base of dynamic_roll is
begin
	gen_i : for i in data_in'range(1) generate
	begin
		gen_j : for j in data_in'range(2) generate
		begin
			if DIRECTION then
				data_out(i, j) <= data_in((i - roll_count) mod data_in'length, j);
			else
				data_out(i, j) <= data_in((i + roll_count) mod data_in'length, j);
		end generate;
	end generate;

end architecture;
