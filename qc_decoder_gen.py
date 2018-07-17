#!/usr/bin/env python3
import numpy
import math
import numpy.random

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

nonz = numpy.nonzero(block_vector)
rv += "constant ROLL_COUNT : roll_count_t := (" + ','.join(map(str, nonz[0])) + ");\n"
rv += "end package;"


f = open("./vhdl/QC/generated_common.vhd", "w")

f.write(rv)

f.close()
