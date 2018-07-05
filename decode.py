#!/usr/bin/env python3
import numpy
import math
import numpy.random

def cn_global(current_min, current_min2, current_min_id, current_sign, block_vector, data_in, offset):
    #ahahahahahahrhgrhgrha y do i even allow non identity submatrices?!?!
    nonz = numpy.nonzero(block_vector)
    f = numpy.abs(data_in)
    #print(data_in.shape)
    #print(f.shape)
    #print(f)
    for i in range(0, f.shape[1]):
        f[:,i] = numpy.roll(f[:,i], -nonz[0][i])

    new_min = numpy.min(numpy.column_stack((current_min, f)), axis=1)
    tmp = numpy.argmin(numpy.column_stack((current_min, f)), axis=1)
    new_min_id = (tmp > 0) * (offset + tmp - 1) + (tmp == 0) * current_min_id
    new_min2 = numpy.partition(numpy.column_stack((current_min, current_min2, f)), 1, axis=1)[:, 1]

    new_sign = (current_sign + numpy.sum(data_in < 0, axis=1)) % 2
    signs_out = data_in < 0
    #print("new sign", new_sign)


    return new_min, new_min2, new_min_id, new_sign, signs_out

def cn_local(min_data, min2_data, min_id_data, min_signs, signs, sign_offset, weight, row, block_size, column):
    # returns the messages for the 1 in the current submatrix...
    #print(sign_offset)
    relevant_signs = (signs[row * block_size:(row + 1) * block_size, sign_offset:sign_offset+weight] + numpy.array([min_signs,]*weight).transpose()) % 2
    #print("signs shape", relevant_signs.shape)
    #print("signs", relevant_signs)
    #print("signs shape", signs.shape)
    tmp = numpy.array([numpy.arange(weight) + column * block_size,]*block_size)
    id_tmp = numpy.array([min_id_data,]*weight).transpose()
    #print(id_tmp == tmp)
    numbers = numpy.array([min_data,]*weight).transpose() * (tmp != id_tmp)  + numpy.array([min2_data,]*weight).transpose() * (tmp == id_tmp)
    relevant_signs = relevant_signs == 1
    #print(relevant_signs)
    rv = numbers * (relevant_signs * -1 + (~relevant_signs) * 1)
    #print("rv", rv)
    return rv

def vn_global(sum_in, data_in):
    #initialize the sum accumulator for each row with the input LLRs
    return sum_in + numpy.sum(data_in, axis=1)

def vn_local(column_sum, data_in):
    return numpy.array([column_sum,]*data_in.shape[1]).transpose() - data_in

def decode_qc(X, Hqc, block_vector):
    block_size = block_vector.shape[0]
    block_weight = numpy.sum(block_vector)
    vn_sums = numpy.zeros((block_size, Hqc.shape[1]), dtype=X.dtype)
    gl_min = numpy.zeros((block_size, Hqc.shape[0]), dtype=X.dtype)
    gl_min2 = numpy.zeros((block_size, Hqc.shape[0]), dtype=X.dtype)
    gl_min_id = numpy.zeros((block_size, Hqc.shape[0]), dtype=X.dtype)
    gl_sign = numpy.zeros((block_size, Hqc.shape[0]), dtype=block_vector.dtype)
    max_ones_per_row = numpy.max(numpy.sum(Hqc > -1, axis = 1)) * numpy.sum(block_vector)
    signs = numpy.zeros((Hqc.shape[0] * block_size, max_ones_per_row), dtype=block_vector.dtype)
    #print(signs.shape)
    # init
    X_block = numpy.reshape(X, (-1, block_size)).transpose()
    vn_sums = numpy.reshape(X, (-1, block_size)).transpose()
    #print(1 * (X[:,0] > 0))
    print(1 * (vn_sums < 0))
    row_offsets = numpy.cumsum(Hqc >= 0, axis=1) - 1
    
    for it in range(0, 1):
        
        #we start with the global check node calculation
        for i in range(0, Hqc.shape[0]):
            min_tmp = numpy.full(block_size, numpy.inf)
            min2_tmp = numpy.full(block_size, numpy.inf)
            min_id_tmp = numpy.zeros(block_size, dtype=block_vector.dtype)
            sign_tmp = numpy.zeros(block_size, dtype=block_vector.dtype)
            row_os = 0
            for j in range(0, Hqc.shape[1]):
                if Hqc[i, j] >= 0:
                    current_data = cn_local(gl_min[:,i], gl_min2[:,i], gl_min_id[:,i], gl_sign[:,i], signs, row_os * block_weight, block_weight, i, block_size, j)
                    print(current_data)
                    current_data = numpy.roll(current_data, Hqc[i, j], axis=0)
                    print(current_data)
                    current_data = vn_local(vn_sums[:,j], current_data)
                    current_data = numpy.roll(current_data, -Hqc[i, j], axis=0)
                    #print("data", current_data)
                    print(current_data)
                    min_tmp, min2_tmp, min_id_tmp, sign_tmp, sign_res = cn_global(min_tmp, min2_tmp, min_id_tmp, sign_tmp, block_vector, current_data, j * block_size)
                    #print("sign output", sign_res)
                    #print("block_weight", block_weight)
                    #print("row_os", row_os)
                    #print(signs.shape)
                    print(min_tmp)
                    signs[i * block_size:(i + 1) * block_size, row_os * block_weight:(row_os + 1) * block_weight] = sign_res
                    row_os += 1

            #when we collect all data from a row we write it to the global arrays
            gl_min[:,i] = min_tmp
            gl_min2[:,i] = min2_tmp
            gl_min_id[:,i] = min_id_tmp
            gl_sign[:,i] = sign_tmp
        #print("gl_sign", gl_sign)
        #print("signs", signs)

        #as the local check node calculation stores no state it will only be implicitly use
        #now follows the global variable node, this basically sums all columns
        for i in range(0, Hqc.shape[1]):
            sum_tmp = X_block[:,i] #numpy.zeros(block_size)
            for j in range(0, Hqc.shape[0]):
                if Hqc[j, i] >= 0:
                    row_os = row_offsets[j, i] # this has to be stored some better way, maybe as part of the instruction
                    current_data = cn_local(gl_min[:,j], gl_min2[:,j], gl_min_id[:,j], gl_sign[:,j], signs, row_os * block_weight, block_weight, j, block_size, i)

                    current_data = numpy.roll(current_data, Hqc[j, i], axis=0)
                    sum_tmp = vn_global(sum_tmp, current_data)
                    #print("row", j)
            vn_sums[:,i] = sum_tmp
        print("i")
        #print(gl_min_id)
        #print(gl_min)
        print(1 * (vn_sums < 0))
    return 1 * (numpy.reshape(vn_sums.transpose(), (-1)) < 0)

def decode_hard(X, H):
    for it in range(0, 10):
        v_to_c = []
        for i in range(0, H.shape[0]):
            tmp = []
            for j in range(0, H.shape[1]):
                if H[i, j] == 1:
                    tmp.append(X[j, 0])
            v_to_c.append(tmp)

        c_to_v = [[] for _ in range(H.shape[1])]

        for i in range(0, H.shape[0]):
            cin = v_to_c[i]
            su = 0
            tmp = []
            for a in cin:
                su += a
            for a in cin:
                tmp.append( ( su - a ) % 2)
            j = 0

            for k in range(0, H.shape[1]):
                if H[i,k] == 1:
                    c_to_v[k].append(tmp[j])
                    j += 1


        for i in range(0, H.shape[1]):
            tmp = X[i, 0] + sum(c_to_v[i])
            if tmp > ((1 + len(c_to_v[i])) // 2):
                X[i, 0] = 1
            else:
                X[i, 0] = 0
        
        err = sum(numpy.dot(H, X) % 2)
        print("error?",err[0])
        if err[0] == 0:
            print("corrected!")
            break;
    return X

def pcm_to_list(H):
    rowpos = []
    for i in range(0, H.shape[0]):
        tmp = []
        for j in range(0, H.shape[1]):
            if H[i, j] == 1:
                tmp.append(j)
        rowpos.append(tmp)
    colpos = []
    for i in range(0, H.shape[1]):
        tmp = []
        for j in range(0, H.shape[0]):
            if H[j, i] == 1:
                tmp.append(j)
        colpos.append(tmp)
    rv = {}
    rv["rowpos"] = rowpos
    rv["colpos"] = colpos
    return rv

def decode_soft_list(X, H):
    v_to_c = []
    for row in rowpos:
        tmp = []
        for j in row:
            tmp.append(X[j][0])
        v_to_c.append(tmp)

def decode_soft(X, H):
    v_to_c = []
    for i in range(0, H.shape[0]):
        tmp = []
        for j in range(0, H.shape[1]):
            if H[i, j] == 1:
                tmp.append(X[j][0])
        v_to_c.append(tmp)
    for it in range(0, 10):
        c_to_v = [[] for _ in range(H.shape[1])]
        for i in range(0, H.shape[0]):
            signpro = 1
            tanpro = 1
            for j in v_to_c[i]:
                signpro *= math.copysign(1, j)
                tanpro *= math.tanh(abs(j) / 2)

            tmp = []
            for j in v_to_c[i]:
                try:
                    val = math.atanh(tanpro / math.tanh(math.fabs(j) / 2))
                except ValueError:
                    val = 100
                tmp.append(signpro / math.copysign(1, j) * 2 * val)
            j = 0

            for k in range(0, H.shape[1]):
                if H[i,k] == 1:
                    c_to_v[k].append(tmp[j])
                    j += 1
        v_to_c = [[] for _ in range(H.shape[0])]
        L = numpy.zeros(X.shape)
        for i in range(0, H.shape[1]):
            su = sum(c_to_v[i]) + X[i][0]
            L[i][0] = su
            tmp = []
            for j in c_to_v[i]:
                tmp.append(su - j)
            
            j = 0
            for k in range(0, H.shape[0]):
                if H[k, i] == 1:
                    v_to_c[k].append(tmp[j])
                    j += 1
    return 1*(L < 0)


print("test")
"""
block = numpy.array([1, 0, 1, 0, 0, 0, 0, 0]);
min_in = numpy.ones(8) * 4
min2_in = numpy.ones(8) * 6
min_id_in = numpy.ones(8, dtype=block.dtype) * 10
sign_in = numpy.zeros(8, dtype=block.dtype)
data = numpy.array([[1, 2, 3, 4, 5, 6, 7, 8], [9, 10, 11, 12, 13, 14, 15, 16]]).T;


min_in, min2_in, min_id_in, sign_in, signs = cn_global(min_in, min2_in, min_id_in, sign_in, block, data, 0)
print(signs)
print("ids", min_id_in)
print("min", min_in)
print("min2", min2_in)
print(cn_local(min_in, min2_in, min_id_in, signs, 0, 2, 0, 8, 0))
"""
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
block_size = 27

block_vector = numpy.zeros(block_size, dtype=Hqc.dtype)
block_vector[0] = 1
block_vector[2] = 1
X = numpy.random.standard_normal(Hqc.shape[1] * block_size)

#decode_qc(X, Hqc, block_vector)

"""

H = numpy.array([
        [1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
        [0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0],
        [0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0]])


#e = numpy.transpose(numpy.array([[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]))
X = numpy.transpose(numpy.array([[1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0]]))
X_org = X.copy()
e = numpy.random.standard_normal(X.shape) * 0.2
#X = ( X + e ) % 2
X = ( X + e )
print(X)
#print(numpy.dot(H, X) % 2)
#X = decode_hard(X, H)
X = (1 - 2 * X) / (2 * 0.2)
print(X)
X = decode_soft(X, H)
print(X)

print(numpy.array_equal(X, X_org))
"""


