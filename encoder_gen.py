#!/usr/bin/env python3

import encode 
import numpy

H = numpy.array([
        [1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
        [0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0],
        [0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0]])


G = encode.calculate_G(H)

in_width = G.shape[0]
out_width = G.shape[1]

header = """library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity encoder is 
    port (clock : in std_logic;
        bits_in : in std_logic_vector(" + in_width + "-1 downto 0);
        bits_out : out std_logic_vector(" + out_width + "-1 downto 0)
    );
end entity;

architecture simple of encoder is
begin
"""

footer = "end architecture;"

out_file = open("encoder.vhd", "w")

out_file.write(header)

for i in range(0, G.shape[1]):
    tmp = []
    for j in range(0, G.shape[0]):
        if G[j][i] == 1:
            tmp.append("bits_in(" + str(j) + ")")
    if len(tmp) == 0:
        line = "\"0\""
    else:
        line = " XOR ".join(tmp)
    line = "    bits_out(" + str(i) + ") <= " + line + ";\n"
    print(line)
    out_file.write(line)

out_file.write(footer)
