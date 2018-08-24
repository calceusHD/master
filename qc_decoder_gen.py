#!/usr/bin/env python3
import numpy
import math
import numpy.random

def generate_record_const(name, val):
    return name + " => " + "\"" + str(val) + "\""

def generate_addr_pair(name, val, d):
    rv = ""
    rv += generate_record_const(name + "_" + d, "1" if val >= 0 else "0") + ","
    rv += generate_record_const(name + "_addr", val if val >= 0 else 0)
    return rv

def generate_inst(row_end, col_end, llr_mem_addr, result_addr, store_cn_addr, load_cn_addr, store_vn_addr, load_vn_addr, min_offset, roll):
    rv = "("
    rv += generate_record_const("row_end", "1" if row_end else "0") + ","
    rv += generate_record_const("col_end", "1" if col_end else "0") + ","
    rv += generate_addr_pair("llr_mem", llr_mem_addr, "rd") + ","
    rv += generate_addr_pair("result", result_addr, "wr") + ","
    rv += generate_addr_pair("store_cn", store_cn_addr, "wr") + ","
    rv += generate_addr_pair("load_cn", load_cn_addr, "rd") + ","
    rv += generate_addr_pair("store_vn", store_vn_addr, "wr") + ","
    rv += generate_addr_pair("load_vn", load_vn_addr, "rd") + ","
    rv += generate_record_const("min_offset", min_offset) + ","
    rv += generate_record_const("roll", roll)
    rv += ")"
    return rv

llr_bits = 8

block_vector = numpy.zeros(27, dtype='intc')
block_vector[0] = 1
block_vector[5] = 1

block_size = 27

block_weight = numpy.sum(block_vector)

Hqc = numpy.array([
    [ 0, -1, -1, -1,  0,  0, -1, -1,  0, -1, -1,  0,  1,  0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
    [22,  0, -1, -1, 17, -1,  0,  0, 12, -1, -1, -1, -1,  0,  0, -1, -1, -1, -1, -1, -1, -1, -1, -1],
    [ 6, -1,  0, -1, 10, -1, -1, -1, 24, -1,  0, -1, -1, -1,  0,  0, -1, -1, -1, -1, -1, -1, -1, -1],
    [ 2, -1, -1,  0, 20, -1, -1, -1, 25,  0, -1, -1, -1, -1, -1,  0,  0, -1, -1, -1, -1, -1, -1, -1],
    [23, -1, -1, -1,  3, -1, -1, -1,  0, -1,  9, 11, -1, -1, -1, -1,  0,  0, -1, -1, -1, -1, -1, -1],
    [24, -1, 23,  1, 17, -1,  3, -1, 10, -1, -1, -1, -1, -1, -1, -1, -1,  0,  0, -1, -1, -1, -1, -1],
    [25, -1, -1, -1,  8, -1, -1, -1,  7, 18, -1, -1,  0, -1, -1, -1, -1, -1,  0,  0, -1, -1, -1, -1],
    [13, 24, -1, -1,  0, -1,  8, -1,  6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  0,  0, -1, -1, -1],
    [ 7, 20, -1, 16, 22, 10, -1, -1, 23, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  0,  0, -1, -1],
    [11, -1, -1, -1, 19, -1, -1, -1, 13, -1,  3, 17, -1, -1, -1, -1, -1, -1, -1, -1, -1,  0,  0, -1],
    [25, -1,  8, -1, 23, 18, -1, 14,  9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  0,  0],
    [ 3, -1, -1, -1, 16, -1, -1,  2, 25,  5, -1, -1,  1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  0]])

max_row_weight = block_weight * numpy.max(numpy.sum(Hqc >= 0, axis=1))
row_sum_extra = math.ceil(math.log2(max_row_weight))

roll_bits = math.ceil(math.log2(block_size))

row_bits = math.ceil(math.log2(Hqc.shape[1]))
col_bits = math.ceil(math.log2(Hqc.shape[0]))


#instruction width
#row_end col_end llr_mem_rd llr_mem_addr result_addr result_wr store_cn_wr store_cn_addr load_cn_rd load_cn_addr store_vn_wr store_vn_addr load_vn_rd load_vn_addr
#1       1       1          row_bits     row_bits    1         1           col_bits      1          col_bits     1           row_bits      1          row_bits

total_inst_bits = 8 + 4 * row_bits + 2 * col_bits


#generate types
rv = """
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

package common is\n"""
#data transfer array
rv += "constant LLR_BITS :natural := " + str(llr_bits) + ";\n"
rv += "type llr_row_t is array(0 to " + str(block_weight) + "-1) of signed(" + str(llr_bits) + "-1 downto 0);\n"
rv += "type llr_array_t is array(0 to " + str(block_size) + "-1, 0  to " + str(block_weight) + "-1) of signed(" + str(llr_bits) + "-1 downto 0);\n"
rv += "type llr_column_t is array(0 to " + str(block_size) + "-1) of signed(" + str(llr_bits) + "-1 downto 0);\n"


#column sum array
rv += "subtype column_sum_t is signed(" + str(llr_bits + row_sum_extra) + "-1 downto 0);\n"
rv += "type column_sum_array_t is array(0 to " + str(block_size) + "-1) of column_sum_t;\n"
rv += "subtype min_signs_t is std_logic_vector(0 to " + str(block_size) + "-1);\n"


#signless minimum storage
rv += "subtype min_t is unsigned(" + str(llr_bits) + "-1 downto 0);\n"
rv += "type min_array_t is array(0 to " + str(block_size) + "-1) of unsigned(" + str(llr_bits) + "-1 downto 0);\n"

#sign storage?
rv += "type signs_t is array(0 to " + str(block_size) + "-1) of std_logic_vector(0 to " + str(block_weight) + "-1);\n"

#min id ? do i even need to store this, we can just test if our value equals the minimum. But that may mess up some of the computations
rv += "subtype min_id_t is unsigned(" + str(row_sum_extra) + "-1 downto 0);\n"
rv += "type min_id_array_t is array(0 to " + str(block_size) + "-1) of min_id_t;\n"

#helper stuff
rv += "type roll_count_t is array(0 to " + str(block_weight) + "-1) of natural;\n"
rv += "subtype row_addr_t is unsigned(" + str(row_bits) + "-1 downto 0);\n"
rv += "subtype col_addr_t is unsigned(" + str(col_bits) + "-1 downto 0);\n"
rv += "subtype roll_t is unsigned(" + str(roll_bits) + "-1 downto 0);\n"

nonz = numpy.nonzero(block_vector)
rv += "constant ROLL_COUNT : roll_count_t := (" + ','.join(map(str, nonz[0])) + ");\n"
rv += "constant HQC_COLUMNS : natural := " + str(Hqc.shape[1]) + ";\n"

rv += "constant VN_MEM_BITS : natural := " + str(row_bits) + ";\n"
rv += "constant CN_MEM_BITS : natural := " + str(col_bits) + ";\n"
rv += """type inst_t is 
    record
        row_end : std_logic;
        col_end : std_logic;
        llr_mem_rd : std_logic;
        llr_mem_addr : row_addr_t;
        result_addr : row_addr_t;
        result_wr : std_logic;
        store_cn_wr : std_logic;
        store_cn_addr : col_addr_t;
        load_cn_rd : std_logic;
        load_cn_addr : col_addr_t;
        store_vn_wr : std_logic;
        store_vn_addr : row_addr_t;
        load_vn_rd : std_logic;
        load_vn_addr : row_addr_t;
        min_offset : min_id_t;
        roll : roll_t;
    end record;
"""
rv += "type inst_array_t is array(integer range <>) of inst_t;\n"
inst_count = 1
rv += "constant INSTRUCTIONS : inst_t(0 to " + str(inst_count) + "-1) := ;\n"
print(generate_inst(True, False, 1, 2, -1, 3, 4, 5, 6, 7))
rv += "end package;"


f = open("./vhdl/QC/generated_common.vhd", "w")

f.write(rv)

f.close()
