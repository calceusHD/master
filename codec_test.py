#!/usr/bin/env python3
import numpy
import scipy.io as sio
#import matplotlib.pyplot as plt
from scipy.linalg import lu, circulant
import sys
import encode
import decode
import math


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
"""
Hqc = numpy.array([
    [57, -1, -1, -1, 50, -1, 11, -1, 50, -1, 79, -1, 1, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
    [3, -1, 28, -1, 0, -1, -1, -1, 55, 7, -1, -1, -1, 0, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1],
    [30, -1, -1, -1, 24, 37, -1, -1, 56, 14, -1, -1, -1, -1, 0, 0, -1, -1, -1, -1, -1, -1, -1, -1],
    [62, 53, -1, -1, 53, -1, -1, 3, 35, -1, -1, -1, -1, -1, -1, 0, 0, -1, -1, -1, -1, -1, -1, -1],
    [40, -1, -1, 20, 66, -1, -1, 22, 28, -1, -1, -1, -1, -1, -1, -1, 0, 0, -1, -1, -1, -1, -1, -1],
    [0, -1, -1, -1, 8, -1, 42, -1, 50, -1, -1, 8, -1, -1, -1, -1, -1, 0, 0, -1, -1, -1, -1, -1],
    [69, 79, 79, -1, -1, -1, 56, -1, 52, -1, -1, -1, 0, -1, -1, -1, -1, -1, 0, 0, -1, -1, -1, -1],
    [65, -1, -1, -1, 38, 57, -1, -1, 72, -1, 27, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, -1, -1, -1],
    [64, -1, -1, -1, 14, 52, -1, -1, 30, -1, -1, 32, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, -1, -1],
    [-1, 45, -1, 70, 0, -1, -1, -1, 77, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, -1],
    [2, 56, -1, 57, 35, -1, -1, -1, -1, -1, 12, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0],
    [24, -1, 61, -1, 60, -1, -1, 27, 51, -1, -1, 16, 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0]])
"""

#Hqc = numpy.load("test_mat.npy")
#print(numpy.sum(Hqc >= 0, axis=1))
#print("aaaaaaaaaaaaaaaaaaa")

H = numpy.array([
        [1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
        [0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0],
        [0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0]])
#H = sio.loadmat("20003000V2.mat")
#H = H["Hqc2"]

expansion = 27 #81

block_vector = numpy.zeros(expansion, dtype=Hqc.dtype)
block_vector[0] = 1

#print(circulant(block_vector))
# fixed precomputation
H = encode.qc_to_pcm(Hqc, block_vector)
numpy.set_printoptions(threshold=numpy.inf)
#print(H)
message_length = H.shape[1] - H.shape[0]
#G = encode.calculate_G(H)
ast = encode.encode_precompute(H, expansion)
#ast = numpy.load("res.npy").item()
#print(ast)
#block_vector[3] = 1

offset = float(sys.argv[2])
supp = float(sys.argv[2])
ebn0 = math.pow(10, float(sys.argv[1]) / 10)
#print(ebn0)

SIGMA = math.sqrt(.25 / ebn0)
err_count = 0
bit_err_count = 0
bit_err_count2 = 0
frame_count = 1

#print(H)
f = open("test.txt", "w")

def to_twoscomplement(value, bits):
    if value < 0:
        value = ( 1<<bits ) + value
    formatstring = '{:0%ib}' % bits
    return formatstring.format(value)

for fc in range(0, frame_count):
    #if i % 10 == 0:
        #print(i)
    #encoding
    U = numpy.random.randint(2, size=(1,message_length))
    #M = numpy.transpose(encode.encode_message(U, G))
    M = encode.encode_ast(ast, U)
    #print(M.shape)
    #channel
    e = numpy.random.standard_normal(M.shape) * SIGMA
    X = M #+ e


    #decoding
    
    LLR = (1 - 2 * X) / (2 * SIGMA)
    
    test = numpy.reshape(LLR, (-1, block_vector.shape[0])) * 5
    test = test.astype(int)

    testM = numpy.reshape(M, (-1, block_vector.shape[0]))
    
    for i in range(0, test.shape[0]):
        for j in range(0, test.shape[1]):
            f.write(to_twoscomplement(test[i,j],7))
            print(testM[i, j], end='')
        print('')
        #f.write("\n")
    """   
    LLR = numpy.reshape(test, (-1, 1))
    """
    #print(LLR.shape)
    #Xe2 = decode.decode_soft(LLR, H)[:,0]
    Xe = decode.decode_qc(LLR, Hqc, block_vector, offset, supp)
    su = numpy.sum(Xe != M[:,0])
    bit_err_count += su
    #bit_err_count2 += numpy.sum(Xe2 != M[:,0])

    if (su != 0):
        #print("wrong")
        err_count += 1
    #else:
        #print("right")
    #if fc % 1 == 0:
        #print("frame error rate:", float(err_count) / (fc + 1), " BER:", bit_err_count / (fc + 1) / M.shape[0])
    #if err_count == 15:
        #break
fc += 1
print(sys.argv[1], sys.argv[2], sys.argv[3], err_count / fc, bit_err_count / fc / M.shape[0])

f.close()

#print("U:", U)
#print("G:", G)
#print("M:", encode_message(U, G))
