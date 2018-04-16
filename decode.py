#!/usr/bin/env python3
import numpy

H = numpy.array([
        [1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
        [0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0],
        [0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0]])


e = numpy.transpose(numpy.array([[0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0]]))
X = numpy.transpose(numpy.array([[1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0]]))
X_org = X.copy()
X = ( X + e ) % 2

print(numpy.dot(H, X) % 2)

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


print(X)

print(numpy.array_equal(X, X_org))

print((1 + len(c_to_v[1])) // 2)


