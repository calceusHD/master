library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity cn_local is
    port (
        min_in, min2_in : in min_array_t;
        min_id_in : in min_id_array_t;
        sign_in : in min_signs_t;
        signs : in signs_t;

        data_out : out llr_array_t;
        offset : in min_id_t
    );
end entity;

architecture base of cn_local is
    signal signless_rv : llr_array_t;
begin
    gen_i : for i in signless_rv'range(1) generate
    begin
        gen_j : for j in signless_rv'range(2) generate
            signless_rv(i, j) <= to_signed(to_integer(min_in(i)), signless_rv(0, 0)'length) 
                when min_id_in(i) /= offset + j 
                else to_signed(to_integer(min2_in(i)), signless_rv(0, 0)'length);
        end generate;
    end generate;


    attach_inst : entity work.attach_signs
    port map (
        signless_in => signless_rv,
        signs_in => signs,
        signed_out => data_out
    );
end architecture;



