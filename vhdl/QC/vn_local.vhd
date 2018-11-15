library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

--use IEEE.fixed_pkg.all;
use work.fixed_generic_pkg_mod.all;
entity vn_local is
    port (
       col_sum : in column_sum_array_t;
       data_in : in llr_array_t;
       data_out : out llr_array_t
    );
end entity;

architecture base of vn_local is

begin
    gen_i : for i in data_in'range(1) generate
    begin
        gen_j : for j in data_in'range(2) generate
            
        begin
            process (col_sum(i), data_in(i, j))
                variable tmp : sfixed(data_in(0, 0)'range);
            begin
                tmp := resize(to_sfixed(col_sum(i)) - to_sfixed(data_in(i, j), data_out(i, j)'length), tmp);
                if tmp = - 2**(data_out(i, j)'length-1) then
                    tmp := to_sfixed(- 2**(data_out(i, j)'length-1)+1, tmp);
                end if;
                data_out(i, j) <= to_signed(tmp, data_out(i, j)'length);
            end process;
        end generate;
    end generate;

end architecture;


