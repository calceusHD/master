library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity encoder is 
    port (clock : in std_logic;
        bits_in : in std_logic_vector(8-1 downto 0);
        bits_out : out std_logic_vector(16-1 downto 0)
    );
end entity;

architecture simple of encoder is
begin
    bits_out(0) <= bits_in(0);
    bits_out(1) <= bits_in(1);
    bits_out(2) <= bits_in(2);
    bits_out(3) <= bits_in(3);
    bits_out(4) <= bits_in(4);
    bits_out(5) <= bits_in(5);
    bits_out(6) <= bits_in(6);
    bits_out(7) <= bits_in(7);
    bits_out(8) <= bits_in(0) XOR bits_in(1) XOR bits_in(2) XOR bits_in(3) XOR bits_in(4) XOR bits_in(5) XOR bits_in(6) XOR bits_in(7);
    bits_out(9) <= bits_in(1) XOR bits_in(3) XOR bits_in(4) XOR bits_in(5) XOR bits_in(6);
    bits_out(10) <= bits_in(0) XOR bits_in(2) XOR bits_in(3) XOR bits_in(4) XOR bits_in(6) XOR bits_in(7);
    bits_out(11) <= bits_in(1) XOR bits_in(3) XOR bits_in(4) XOR bits_in(5) XOR bits_in(6) XOR bits_in(7);
    bits_out(12) <= bits_in(2) XOR bits_in(4);
    bits_out(13) <= bits_in(2) XOR bits_in(3) XOR bits_in(4) XOR bits_in(6);
    bits_out(14) <= "0";
    bits_out(15) <= bits_in(3) XOR bits_in(4) XOR bits_in(5);
end architecture;