#!/usr/bin/env python3

import numpy
import sys

H = numpy.array([
        [1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
        [0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0],
        [0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0]])


def matrix_to_conntection(H):
    c_to_v = []
    for i in range(0, H.shape[0]):
        c_to_v.append([])
        for j in range(0, H.shape[1]):
            if H[i, j] == 1:
                c_to_v[i].append(j)
    v_to_c = []
    for i in range(0, H.shape[1]):
        v_to_c.append([])
        for j in range(0, H.shape[0]):
            if H[j, i] == 1:
                v_to_c[i].append(j)

    print("c_to_v", c_to_v)
    print("v_to_c", v_to_c)
    return c_to_v, v_to_c

def generate_cn(name, n_io):
    return "check_node_" + str(name) + """ : entity work.cn_hard
    generic map (N_IO => """ + str(n_io) + """,
        LLR_BITS => LLR_BITS)
    port map (data_in => cn_in_""" + str(name) + """,
        data_out => cn_out_""" + str(name) + """,
        has_error => errors(""" + str(name) + """));
    \n"""

def generate_cns(c_to_v):
    out = ""
    for i in range(0, len(c_to_v)):
        out += generate_cn(i, len(c_to_v[i]))
    return out

def generate_vn(name, n_io):
    return "variable_node_" + str(name) + """ : entity work.vn_hard
    generic map (N_IO => """ + str(n_io) + """,
        LLR_BITS => LLR_BITS)
    port map (clk => clk,
        load => load,
        result => decoded_out(""" + str(name) + """),
        load_data => message_in(""" + str(name) + """),
        data_in => vn_in_""" + str(name) + """,
        data_out => vn_out_""" + str(name) + """);
    \n"""

def generate_vns(v_to_c):
    out = ""
    for i in range(0, len(v_to_c)):
        out += generate_vn(i, len(v_to_c[i]))
    return out

def generate_signals(v_to_c, c_to_v):
    out = ""
    for i in range(0, len(v_to_c)):
        out += "signal cn_in_" + str(i) + ", cn_out_" + str(i) + " : llr_type_array(0 to " + str(len(v_to_c[i]) - 1) + ")(LLR_BITS-1 downto 0);\n"
    for i in range(0, len(c_to_v)):
        out += "signal vn_in_" + str(i) + ", vn_out_" + str(i) + " : llr_type_array(0 to " + str(len(c_to_v[i]) - 1) + ")(LLR_BITS-1 downto 0);\n"
    return out + "\n"

def generate_connections(v_to_c, c_to_v):
    out = ""
    use_counts = [0]*len(c_to_v)
    for i in range(0, len(v_to_c)):
        out += "cn_in_" + str(i) + " <= ("
        tmp = []
        for j in range(0, len(v_to_c[i])):
            tmp.append("vn_out_" + str(v_to_c[i][j]) + "(" + str(use_counts[v_to_c[i][j]]) + ")")
            use_counts[v_to_c[i][j]] += 1
        out += ", ".join(tmp) + ");\n"
    out += "\n"
    use_counts = [0]*len(v_to_c)
    for i in range(0, len(c_to_v)):
        out += "vn_in_" + str(i) + " <= ("
        tmp = []
        for j in range(0, len(c_to_v[i])):
            tmp.append("cn_out_" + str(c_to_v[i][j]) + "(" + str(use_counts[c_to_v[i][j]]) + ")")
            use_counts[c_to_v[i][j]] += 1
        out += ", ".join(tmp) + ");\n"
    out += "\n"
    return out



out_file = open("vhdl/decoder_soft.vhd", "w")
#out_file = sys.stdout
c_to_v, v_to_c = matrix_to_conntection(H)

header = """library IEEE;
use IEEE.std_logic_1164.all;
use work.soft_types.all;

entity decoder_soft is
	port (clk : in std_logic;
		load : in std_logic;
		done : out std_logic;
		err : out std_logic;
		message_in : in llr_type_array(0 to """ + str(len(v_to_c) - 1) + """)(LLR_BITS-1 downto 0);
		decoded_out : out std_logic_vector(0 to """ + str(len(v_to_c) - 1) + """)(LLR_BITS-1 downto 0)
	);
end entity;

architecture soft of decoder_soft is
signal errors : std_logic_vector(""" + str(len(c_to_v) - 1) + """ downto 0);
"""

out_file.write(header)

out_file.write(generate_signals(c_to_v, v_to_c))

intermediate = """begin
err <= or errors;
"""

out_file.write(intermediate)

out_file.write(generate_cns(c_to_v))
out_file.write(generate_vns(v_to_c))

out_file.write(generate_connections(c_to_v, v_to_c))

out_file.write("end architecture;\n")

out_file.close()
