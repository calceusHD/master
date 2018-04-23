#!/usr/bin/env python3
import numpy
from scipy.linalg import lu
from numpy.linalg import matrix_rank

def calculate_G(H):
    #print(matrix_rank(H))
    h = 0
    k = H.shape[1] - H.shape[0]
    k0 = k
    m = H.shape[0]
    n = H.shape[1]
    while h < m and k < n:
        i_max = numpy.argmax(H[h:,k]) + h
        #print(h, k)
        if H[i_max, k] == 0:
            k += 1
        else:
            H[[i_max,h],:] = H[[h,i_max],:]
            for i in range(h + 1, m):
                f = H[i, k]
                #print(f)
                H[i, k] = 0
                if f > 0:
                    for j in range(k + 1, n):
                        H[i, j] = (H[i, j] + H[h, j]) % 2
                    for j in range(0, k0):
                        H[i, j] = (H[i, j] + H[h, j]) % 2
            h += 1
            k += 1
            #print(H)



    #really ??
    offset = H.shape[1] - H.shape[0]
    for i in range(0, H.shape[1] - offset):
        if (H[i,i+offset] == 0):
            tmp = numpy.zeros((1, H.shape[1]), dtype=H.dtype)
            tmp[0,i + offset] = 1
            H = numpy.insert(H, i, values=tmp, axis=0)
            H = numpy.delete(H, (H.shape[0]-1), axis=0)

    #print(H)

    for i in range(0, H.shape[1] - offset):
        for j in range(i + 1, H.shape[1] - offset):
            if (H[i, j + offset] == 1):
                H[i, :] = ( H[i, :] + H[j, :] ) % 2


    #print(H)
    P = numpy.transpose(H[:,:-H.shape[0]])
    #print(P)
    G = numpy.zeros((P.shape[0], H.shape[1]), H.dtype)
    G[:,:G.shape[0]] = numpy.identity(G.shape[0])

    G[:,G.shape[0]:] = P

    #print(G)
    return G

def encode_message(x, G):
    return numpy.dot(x, G) % 2;

H = numpy.array([
        [1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
        [0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0],
        [0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0]])
"""
H = numpy.array([
    [1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0],
    [0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
    [0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1],
    [0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0],
    [0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1],
    [0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0]])
"""
G = calculate_G(H)
U = numpy.array([[1, 0, 0, 1, 0, 1, 0, 0]])
print("H:", H)
print("U:", U)
print("G:", G)
print("M:", encode_message(U, G))

