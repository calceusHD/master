library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity vn_global is
    port (
        data_in : in llr_array_t;
        sum_in : in column_sum_array_t;
        sum_out : out column_sum_array_t
    );
end entity;

architecture default of vn_global is

begin
	gen_i : for i in data_in'range(1) generate
    begin
		process (data_in, sum_in)
			variable tmp : column_sum_t := (others => '0');
		begin
			gen_j : for j in data_in'range(2) loop
            	tmp := tmp + data_in(i, j);
			end loop;
        	sum_out(i) <= tmp + sum_in(i);
		end process;
    end generate;
end architecture;


