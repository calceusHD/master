#!/usr/bin/env python3
import numpy
import math
import numpy.random


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



H = numpy.array([
        [1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
        [0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0],
        [0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0]])


e = numpy.transpose(numpy.array([[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]))
X = numpy.transpose(numpy.array([[1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0]]))
X_org = X.copy()
#e = numpy.random.standard_normal(X.shape) * 0.01
X = ( X + e ) % 2
print(X)
print(numpy.dot(H, X) % 2)
X = decode_hard(X, H)
#X = (1 - 2 * X) / (2 * 0.1)
##print(X)
#X = decode_soft(X, H)
print(X)

print(numpy.array_equal(X, X_org))



