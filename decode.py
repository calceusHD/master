#!/usr/bin/env python3
import numpy
import math
import numpy.random
import encode

def cn_global(current_min, current_min2, current_min_id, current_sign, block_vector, data_in, offset):
    #ahahahahahahrhgrhgrha y do i even allow non identity submatrices?!?!
    nonz = numpy.nonzero(block_vector)
    
    f = numpy.abs(data_in)
    fs = numpy.copy(data_in)
    for i in range(0, f.shape[1]):
        f[:,i] = numpy.roll(f[:,i], -nonz[0][i])
        fs[:,i] = numpy.roll(data_in[:,i], -nonz[0][i])

    new_min = numpy.min(numpy.column_stack((current_min, f)), axis=1)
    tmp = numpy.argmin(numpy.column_stack((current_min, f)), axis=1)
    new_min_id = (tmp > 0) * (offset + tmp - 1) + (tmp == 0) * current_min_id
    new_min2 = numpy.partition(numpy.column_stack((current_min, current_min2, f)), 1, axis=1)[:, 1]

    new_sign = (current_sign + numpy.sum(fs < 0, axis=1)) % 2
    signs_out = fs < 0

    return new_min, new_min2, new_min_id, new_sign, signs_out

def cn_local(min_data, min2_data, min_id_data, min_signs, signs, sign_offset, weight, row, block_size, column):
    # returns the messages for the 1 in the current submatrix...
    relevant_signs = (signs[row * block_size:(row + 1) * block_size, sign_offset:sign_offset+weight] + numpy.array([min_signs,]*weight).transpose()) % 2
    
    tmp = numpy.array([numpy.arange(weight) + column * weight,]*block_size)
    id_tmp = numpy.array([min_id_data,]*weight).transpose()
    
    numbers = numpy.array([min_data,]*weight).transpose() * (tmp != id_tmp)  + numpy.array([min2_data,]*weight).transpose() * (tmp == id_tmp)
    relevant_signs = relevant_signs == 1
    rv = numbers * (relevant_signs * -1 + (~relevant_signs) * 1)
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
    
    
    # init
    X_block = numpy.reshape(X, (-1, block_size)).transpose()
    row_offsets = numpy.cumsum(Hqc >= 0, axis=1) - 1

    full_H = encode.qc_to_pcm(Hqc, block_vector)
    
    for it in range(0, 3):
        
        #we start with the global check node calculation
        if it > 0:
            for i in range(0, Hqc.shape[0]):
                min_tmp = numpy.full(block_size, numpy.inf)
                min2_tmp = numpy.full(block_size, numpy.inf)
                min_id_tmp = numpy.zeros(block_size, dtype=block_vector.dtype)
                sign_tmp = numpy.zeros(block_size, dtype=block_vector.dtype)
                row_os = 0
                for j in range(0, Hqc.shape[1]):
                    if Hqc[i, j] >= 0:
                        current_data = cn_local(gl_min[:,i], gl_min2[:,i], gl_min_id[:,i], gl_sign[:,i], signs, row_os * block_weight, block_weight, i, block_size, j)
                        current_data = numpy.roll(current_data, Hqc[i, j], axis=0)
                        current_data = vn_local(vn_sums[:,j], current_data)
                        current_data = numpy.roll(current_data, -Hqc[i, j], axis=0)
                        min_tmp, min2_tmp, min_id_tmp, sign_tmp, sign_res = cn_global(min_tmp, min2_tmp, min_id_tmp, sign_tmp, block_vector, current_data, j * block_weight)
                        signs[i * block_size:(i + 1) * block_size, row_os * block_weight:(row_os + 1) * block_weight] = sign_res
                        row_os += 1
                
                #when we collect all data from a row we write it to the global arrays
                gl_min[:,i] = min_tmp
                gl_min2[:,i] = min2_tmp
                gl_min_id[:,i] = min_id_tmp
                gl_sign[:,i] = sign_tmp
            #print(numpy.sum(gl_sign), numpy.sum(numpy.dot(full_H, numpy.reshape(vn_sums.transpose(), (-1)) < 0) % 2))

            if numpy.sum(numpy.dot(full_H, numpy.reshape(vn_sums.transpose(), (-1)) < 0) % 2) == 0:
                break

        #as the local check node calculation stores no state it will only be implicitly used
        #now follows the global variable node, this basically sums all columns
        for i in range(0, Hqc.shape[1]):
            sum_tmp = X_block[:,i] #numpy.zeros(block_size)
            for j in range(0, Hqc.shape[0]):
                if Hqc[j, i] >= 0:
                    row_os = row_offsets[j, i] # this has to be stored some better way, maybe as part of the instruction
                    current_data = cn_local(gl_min[:,j], gl_min2[:,j], gl_min_id[:,j], gl_sign[:,j], signs, row_os * block_weight, block_weight, j, block_size, i)

                    current_data = numpy.roll(current_data, Hqc[j, i], axis=0)
                    sum_tmp = vn_global(sum_tmp, current_data)
            vn_sums[:,i] = sum_tmp
    
    #print(gl_sign)
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


