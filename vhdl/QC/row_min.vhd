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
	process (min_in, min2_in, min_id_in, row_in, offset)
		variable id_rv : min_id_t;
		variable min_rv : min_t;
		variable min2_rv : min_t;
		variable row_tmp : min_t;
	begin
		min_rv := min_in;
        min2_rv := min2_in;
        id_rv := min_id_in;
		for i in row_in'range loop
			row_tmp := to_unsigned(to_integer(abs(row_in(i))), row_tmp'length);
			--report "Row_tmp" & to_hstring(row_tmp);
			--report "Min_rv" & to_hstring(min_rv);
			if row_tmp > min_rv and row_tmp < min2_rv then
				min2_rv := row_tmp;
			end if;
			if row_tmp <= min_rv then
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

