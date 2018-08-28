library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity row_min is
	port (
		min_in, min2_in : in min_t;
		min_id_in : in min_id_t;
		row_in : in llr_row_t;
		min_out, min2_out : out min_t;
		min_id_out : out min_id_t;
		offset : in min_id_t
	);
end entity;

architecture base of row_min is
begin
	process (min_in, min2_in, min_id_in, row_in)
		variable id_rv : min_id_t := min_id_in;
		variable min_rv : min_t := min_in;
		variable min2_rv : min_t := min2_in;
		variable row_tmp : min_t;
	begin
		for i in row_in'range loop
			row_tmp := to_unsigned(to_integer(abs(row_in(i))), row_tmp'length);
			if row_tmp < min_rv then
				min2_rv := min_rv;
				min_rv := row_tmp;
				id_rv := i + offset;
			end if;
		end loop;
		min_out <= min_rv;
		min2_out <= min2_rv;
		min_id_out <= id_rv;
	end process;

end architecture;

