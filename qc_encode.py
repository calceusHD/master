#!/usr/bin/env python3
import numpy
import matplotlib.pyplot as plt
from scipy.linalg import lu
from numpy.linalg import matrix_rank

#start of an qc optimezed enocder that has some registers to reduce the logic usage and should calculate the parity bits over multiple clock cycles

def calculate_alt(H):
    A = H.copy()
    for i in range(0, A.shape[0]-1):
        elems = A.shape[1] - numpy.argmax(numpy.flip(A, axis=1), axis=1)
        minrow = numpy.argmin(elems[i:]) + i
        print(numpy.argmin(elems))
        A[[i, minrow]] = A[[minrow, i]]
    for i in range(A.shape[1]-1, 0, -1):
        elems = numpy.argmax(A, axis=0)
        print(A)
        print(elems)
        minrow = numpy.argmax(elems[:i])
        print(numpy.argmin(elems))
        A[:,[i, minrow]] = A[:,[minrow, i]]


    print(elems)

    print(A)
