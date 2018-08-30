library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity vn_global_accu is
    port (
        clk : in std_logic;
        
        data_in : in llr_array_t;

        col_end : in std_logic;
        preload_in : in column_sum_array_t;
        
        sum_out : out column_sum_array_t
    );
end entity;

architecture base of vn_global_accu is
    signal sum_acc, sum_res : column_sum_array_t;
begin
    
    process (clk)
    begin
        if rising_edge(clk) then
            if col_end = '1' then
                sum_acc <= preload_in;
            else
                sum_acc <= sum_res;
            end if;
        end if;
    end process;

    sum_out <= sum_res;


    node : entity work.vn_global
    port map (
        data_in => data_in,
        sum_in => sum_acc,
        sum_out => sum_res
    );
end architecture;
