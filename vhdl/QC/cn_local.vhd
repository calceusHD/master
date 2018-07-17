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

architecture default of cn_local is
    signal signless_rv : llr_array_t;
begin
    gen_i : for i in signless_rv'range(1) generate
    begin
        gen_j : for j in signless_rv'range(2) generate
            signless_rv(i, j) <= min_in(i) when min_id_in(i) /= offset + j else min2_in(i);
        end generate;
    end generate;


    attach_inst : entity work.attach_signs
    port map (
        signless_in => signless_rv,
        signs_in => signs,
        signed_out => data_out
    );
end architecture;



