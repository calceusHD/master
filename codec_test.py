#!/usr/bin/env python3
import numpy
import scipy.io as sio
#import matplotlib.pyplot as plt

import encode
import decode


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

print(numpy.sum(Hqc >= 0, axis=1))
print("aaaaaaaaaaaaaaaaaaa")

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


# fixed precomputation
H = encode.qc_to_pcm(Hqc, 27)


message_length = H.shape[1] - H.shape[0]
#G = encode.calculate_G(H)
ast = encode.encode_precompute(H, 27)

block_vector = numpy.zeros(27, dtype=Hqc.dtype)
block_vector[0] = 1
        
SIGMA = .35
err_count = 0
frame_count = 1

f = open("test.txt", "w")

def to_twoscomplement(value, bits):
    if value < 0:
        value = ( 1<<bits ) + value
    formatstring = '{:0%ib}' % bits
    return formatstring.format(value)

for i in range(0, frame_count):
    if i % 10 == 0:
        print(i)
    #encoding
    U = numpy.random.randint(2, size=(1,message_length))
    #M = numpy.transpose(encode.encode_message(U, G))
    M = encode.encode_ast(ast, U)
    
    #channel
    e = numpy.random.standard_normal(M.shape) * SIGMA
    X = M #+ e

    #decoding
    LLR = (1 - 2 * X) / (2 * SIGMA)
    test = numpy.reshape(LLR, (-1, 27)) * 10
    test = test.astype(int)
    for i in range(0, test.shape[0]):
        for j in range(0, test.shape[1]):
            f.write(to_twoscomplement(test[i,j],8))
        f.write("\n")
    
    #Xe = decode.decode_soft(LLR, H)
    Xe = decode.decode_qc(LLR, Hqc, block_vector)
    if (numpy.sum(Xe != M[:,0]) != 0):
        err_count += 1
    if i % 10 == 0:
        print("frame error rate:", err_count / (i+1.0))
print("frame error rate:", err_count / frame_count)

f.close()

#print("U:", U)
#print("G:", G)
#print("M:", encode_message(U, G))
