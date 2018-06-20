#!/usr/bin/env python3
import numpy
from scipy.linalg import lu
from numpy.linalg import matrix_rank

def calculate_G(Hin):
    H = Hin.copy()
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

def qc_to_pcm(Hin, bs):
    Hout = numpy.zeros(numpy.array(Hin.shape) * bs, dtype=Hin.dtype)
    for i in range(0, Hin.shape[0]):
        for j in range(0, Hin.shape[1]):
            if Hin[i, j] >= 0:
                Hout[i * bs:(i + 1) * bs, j * bs:(j + 1) * bs] = numpy.roll(numpy.identity(bs), Hin[i, j], axis=1)
    return Hout

def L_inv(A):
    return 0
        

def encode_precompute(H_alt, gap):
    rv = {}
    m = H_alt.shape[0]
    n = H_alt.shape[1]
    A = H_alt[:m - gap, :n - m]
    B = H_alt[:m - gap, n - m:-(m - gap)]
    C = H_alt[-gap:, :n - m]
    D = H_alt[-gap:, n - m:-(m - gap)]
    E = H_alt[-gap:, -(m - gap):]
    T = H_alt[:m - gap, -(m - gap):]
    rv["A"] = A
    rv["B"] = B
    rv["C"] = C
    rv["E"] = E
    rv["T"] = T
    Tinv = numpy.linalg.inv(T).astype(T.dtype) % 2
    # -E Tinv A + C
    theta = (numpy.matmul(- numpy.matmul(E, Tinv), B) + D)
    thetainv = numpy.linalg.inv(theta).astype(theta.dtype) % 2
    rv["thetainv"] = thetainv



    return rv

def encode_ast(pre, s):
    As = numpy.matmul(pre["A"], numpy.transpose(s)) % 2
    TAs = numpy.linalg.solve(pre["T"], As).astype(s.dtype) % 2
    ETAs = numpy.matmul(-pre["E"], TAs) % 2
    Cs = numpy.matmul(pre["C"], numpy.transpose(s)) % 2
    ETAsCs = (ETAs + Cs) % 2
    p1 = numpy.matmul(-pre["thetainv"], ETAsCs) % 2

    Bp1 = numpy.matmul(pre["B"], p1) % 2
    AsBp1 = (As + Bp1) % 2
    p2 = -numpy.linalg.solve(pre["T"], AsBp1).astype(s.dtype) % 2
    print(p1)
    return numpy.concatenate((numpy.transpose(s), p1, p2))




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


H = qc_to_pcm(Hqc, 27)
tmp = (H, 27)
print("returned\n", tmp)
G = calculate_G(H)
pre = encode_precompute(tmp[0], tmp[1])
U = numpy.random.randint(2, size=(1, H.shape[0]))
U = numpy.ones((1, H.shape[0]))
print(U.shape)
print(pre["A"].shape)
M = encode_ast(pre, U)
#print(M)
M2 = numpy.transpose(encode_message(U, G))
#print(M == M2)

