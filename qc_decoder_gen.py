#!/usr/bin/env python3
import numpy
import math
import numpy.random

def generate_record_const(name, val, sep):
    return name + " => " + sep + str(val) + sep

def to_bin(val, length):
    return bin(val)[2:].zfill(length)

def generate_addr_pair(name, val, d, length):
    rv = ""
    rv += generate_record_const(name + "_" + d, "1" if val >= 0 else "0", "'") + ","
    rv += generate_record_const(name + "_addr", to_bin(val if val >= 0 else 0, length), "\"")
    return rv


llr_bits = 8

block_vector = numpy.zeros(27, dtype='intc')
block_vector[0] = 1
#block_vector[5] = 1

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

max_col_weight = block_weight * numpy.max(numpy.sum(Hqc >= 0, axis=0))
max_row_weight = block_weight * numpy.max(numpy.sum(Hqc >= 0, axis=1))
col_sum_extra = math.ceil(math.log2(max_col_weight))
row_sum_extra = math.ceil(math.log2(max_row_weight))

print("col_weight:", max_col_weight)
print("col_extra :", col_sum_extra)

roll_bits = math.ceil(math.log2(block_size))

row_bits = math.ceil(math.log2(Hqc.shape[1]))
col_bits = math.ceil(math.log2(Hqc.shape[0]))
sign_store_bits = math.ceil(math.log2(numpy.sum(Hqc >= 0)))

def generate_inst(row_end, col_end, llr_mem_addr, result_addr, store_cn_addr, load_cn_addr, store_vn_addr, load_vn_addr, store_signs_addr, load_signs_addr, min_offset, roll):
    rv = "("
    rv += generate_record_const("row_end", "1" if row_end else "0", "'") + ", "
    rv += generate_record_const("col_end", "1" if col_end else "0", "'") + ", "
    rv += generate_addr_pair("llr_mem", llr_mem_addr, "rd", row_bits) + ", "
    rv += generate_addr_pair("result", result_addr, "wr", row_bits) + ", "
    rv += generate_addr_pair("store_cn", store_cn_addr, "wr", col_bits) + ", "
    rv += generate_addr_pair("load_cn", load_cn_addr, "rd", col_bits) + ", "
    rv += generate_addr_pair("store_vn", store_vn_addr, "wr", row_bits) + ", "
    rv += generate_addr_pair("load_vn", load_vn_addr, "rd", row_bits) + ", "
    rv += generate_addr_pair("store_signs", store_signs_addr, "wr", sign_store_bits) + ", "
    rv += generate_addr_pair("load_signs", load_signs_addr, "rd", sign_store_bits) + ", "
    rv += generate_record_const("min_offset", to_bin(min_offset, row_sum_extra), "\"") + ", "
    rv += generate_record_const("roll", to_bin(roll, roll_bits), "\"")
    rv += ")"
    return rv

def generate_inst_list(Hqc):
    insts = []
    row_offsets = (numpy.cumsum(Hqc >= 0, axis=1) - 1)
    #so I wanna tightly pack all the signs i have to store so i need some type of offset for each valid position in my Hqc matrix
    sign_offset = numpy.reshape((numpy.cumsum((Hqc >= 0)[:]) - 1), Hqc.shape)
    col_end = (Hqc >= 0).cumsum(0).argmax(0)
    row_end = (Hqc >= 0).cumsum(1).argmax(1)
    
    insts.append((False, False, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0))
    print(col_end)
    print(row_end)
    for i in range(0, Hqc.shape[0]):
        new_row = True
        for j in range(0, Hqc.shape[1]):
            if Hqc[i, j] >= 0:
                if j == row_end[i]:
                    store_cn_addr = i
                    print("dong")
                else:
                    store_cn_addr = -1

                insts.append((new_row, False, -1, -1, store_cn_addr, i, -1, j, sign_offset[i, j], sign_offset[i, j], row_offsets[i, j] * block_weight, Hqc[i, j]))
                new_row = False

    for i in range(0, Hqc.shape[1]):
        new_col = True
        for j in range(0, Hqc.shape[0]):
            if Hqc[j, i] >= 0:
                if j == col_end[i]:
                    store_vn_addr = i
                    print("store at", i)
                else:
                    store_vn_addr = -1

                insts.append((False, new_col, i if new_col else - 1, store_vn_addr, -1, j, store_vn_addr, -1, -1, sign_offset[j, i], 0, Hqc[j, i]))
                new_col = False
    rv = []
    insts.append((False, False, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0))
    insts.append((False, False, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0))
    insts.append((False, False, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0))
    print(len(insts))
    for i in range(0, len(insts)-2):
        row_end =           insts[i][0]
        col_end =           insts[i][1]
        llr_mem_addr =      insts[i + 2][2]
        result_addr =       insts[i][3]
        store_cn_addr =     insts[i - 1][4]
        load_cn_addr =      insts[i + 1][5]
        store_vn_addr =     insts[i - 1][6]
        load_vn_addr =      insts[i + 1][7]
        store_signs_addr =  insts[i - 1][8]
        load_signs_addr =   insts[i + 1][9]
        min_offset =        insts[i - 1][10]
        roll =              insts[i - 1][11]
        rv.append("pack(" + generate_inst(row_end, col_end, llr_mem_addr, result_addr, store_cn_addr, load_cn_addr, store_vn_addr, load_vn_addr, store_signs_addr, load_signs_addr, min_offset, roll) + ")")
    rv = ",\n".join(rv)
    return rv, len(insts)-2


#print(generate_inst_list(Hqc))

#instruction width
#row_end col_end llr_mem_rd ll_mem_addr result_addr result_wr store_cn_wr store_cn_addr load_cn_rd load_cn_addr store_vn_wr store_vn_addr load_vn_rd load_vn_addr
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
rv += "subtype column_sum_t is signed(" + str(llr_bits + col_sum_extra) + "-1 downto 0);\n"
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
rv += "subtype signs_addr_t is unsigned(" + str(sign_store_bits) + "-1 downto 0);\n"
rv += "subtype roll_t is unsigned(" + str(roll_bits) + "-1 downto 0);\n"

nonz = numpy.nonzero(block_vector)
rv += "constant ROLL_COUNT : roll_count_t := (" + ','.join(map(str, nonz[0])) + ", others => 0);\n"
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
        store_signs_wr : std_logic;
        store_signs_addr : signs_addr_t;
        load_signs_rd : std_logic;
        load_signs_addr : signs_addr_t;
        min_offset : min_id_t;
        roll : roll_t;
    end record;
"""
rv += "type inst_array_t is array(integer range <>) of inst_t;\n"
inst_str, inst_count = generate_inst_list(Hqc)
rv += "constant INSTRUCTIONS : inst_array_t(0 to " + str(inst_count) + "-1) := (" + inst_str + ");\n"
#print(generate_inst(True, False, 1, 2, -1, 3, 4, 5, 6, 7, 8, 9))
rv += "end package;"


f = open("./vhdl/QC/generated_common.vhd", "w")

f.write(rv)

f.close()
