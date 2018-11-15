library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;
use work.fixed_generic_pkg_mod.all;

entity vn_global is
    port (
        data_in : in llr_array_t;
        sum_in : in column_sum_array_t;
        sum_out : out column_sum_array_t
    );
end entity;

architecture base of vn_global is

begin
	gen_i : for i in data_in'range(1) generate
    begin
		process (data_in, sum_in)
			variable tmp : sfixed(sum_in(0)'range) := (others => '0');
		begin
			tmp := (others => '0');
			gen_j : for j in data_in'range(2) loop
            	tmp := resize(tmp + to_sfixed(data_in(i, j)), tmp);
			end loop;
			tmp := resize(tmp + to_sfixed(sum_in(i)), tmp);
			if tmp = - 2**(sum_out(i)'length-1) then
                tmp := to_sfixed(- 2**(sum_out(i)'length-1)+1, tmp);
            end if;
        	sum_out(i) <= to_signed(tmp, sum_out(i)'length);
		end process;
    end generate;
end architecture;


