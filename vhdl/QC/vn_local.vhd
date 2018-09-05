library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

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
            signal temp : column_sum_t;
        begin
            temp <= col_sum(i) - data_in(i, j);
            sat : entity work.saturate
            port map (
                data_in => temp,
                data_out => data_out(i, j)
            );
        end generate;
    end generate;

end architecture;


