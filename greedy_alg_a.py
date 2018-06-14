#!/usr/bin/env python3
import numpy
import math
import numpy.random

def alg_a(H, alpha):
    # ok i have no real idea on how to get a good alpha
    # it should be lower than the maximum probality of erasures the code can correct
    A = H.copy()
    #Greedy Algorithm A from "Efficient Encoding of Low-Density Parity-Check Codes," Thomas J. Richardson and Rüdiger L. Urbanke
    # 0. Init
    known_cols = numpy.random.choice(a=[True, False], size=(A.shape[1]), p=[1-alpha, alpha])
    As_width = A.shape[1]
    As_height = A.shape[0]
    #for f in range(0,10):
    while (True):
        #print(known_cols * 1)
        #print(A)

        # 1. End if no know columns in A and no row of degree 1
        #print(numpy.sum(A[-As_height:,-As_width:], axis=1))
        if not (True in known_cols or 1 in numpy.sum(A[:-As_height,:-As_width], axis=1)):
            return A, As_height #stopped

        # still 1. do a diagonal extension step
        deg_1_rows = numpy.concatenate((numpy.zeros(A.shape[0]-As_height, dtype=bool),1 == numpy.sum(A[-As_height:,-As_width:], axis=1)))
        none_connected = True
        all_connected = True
        for i in range(known_cols.shape[0]-As_width, known_cols.shape[0]):
            if (known_cols[i]):
                col_connected = False
                for j in range(deg_1_rows.shape[0]-As_height, deg_1_rows.shape[0]):
                    if (deg_1_rows[j]):
                        if A[j,i] == 1:
                            none_connected = False
                            col_connected = True
                if not col_connected:
                    all_connected = False
        # the 2 options of the diagonal extension step
        if none_connected == all_connected:
            print("error this is not ok")
            return
        if none_connected:
            #do some switcheroo to get all known columns to the left
            A = numpy.concatenate((A[:,known_cols[:]], A[:, known_cols[:]==False]), axis=1)
            known_cols = numpy.concatenate((known_cols[known_cols], known_cols[known_cols==False]))
            #and remove all known columns from As
            As_width = numpy.sum(known_cols==False)
        if all_connected:
            #number of known column in As
            no_known = numpy.sum(known_cols[-As_width:])
            
            #boop all the know columns to the left
            A = numpy.concatenate((A[:,known_cols[:]], A[:, known_cols[:]==False]), axis=1)
            known_cols = numpy.concatenate((known_cols[known_cols], known_cols[known_cols==False]))  
            deg_1_rows = numpy.concatenate((numpy.zeros(A.shape[0]-As_height, dtype=bool),1 == numpy.sum(A[-As_height:,-As_width:], axis=1)))
            #now order the connected deg 1 rows to the right positions
            for i in range(0, no_known):
                current_col = i + A.shape[1] - As_width
                current_row = i + A.shape[0] - As_height
                #now we want to bring the deg 1 rows to the top so that they connect in order to the known columns
                for j in range(A.shape[0] - As_height, A.shape[0]):
                    if deg_1_rows[j] and A[j, current_col] == 1:
                        #print("swapping", current_row, "and", j)
                        A[[current_row, j],:] = A[[j, current_row],:]

                        deg_1_rows[current_row] = False #make the used row false so we dont use it again
                        break #one swap and we are good
            As_width -= no_known
            As_height -= no_known
        
        #ok so im not quite sure but if we have no columns left we are done
        #this is not described explicitly in the paper, but otherwise we fail in step 3 cause we have no column to connect to somethig
        if As_width == 0:
            #print("As_height", As_height)
            return A, As_height

        # 3. take a column in As which is connected to a row with degree 1 and declare it known

        deg_1_rows = numpy.concatenate((numpy.zeros(A.shape[0]-As_height, dtype=bool),1 == numpy.sum(A[-As_height:,-As_width:], axis=1)))
        #print(deg_1_rows)
        #print(As_width)
        for i in range(A.shape[1]-As_width, A.shape[1]):
            for j in range(A.shape[0]-As_height, A.shape[0]):
                if deg_1_rows[j]:
                    if A[j,i] == 1:
                        known_cols[i] = True
                        break
            else:
                continue
            break
        else:
            print("failed to find deg 1 row") # as we cant declare another column known we only can stop
            #print(A)
            return
        #print(known_cols)
        #print(none_connected)

        #print(all_connected)
"""

H = numpy.array([
        [1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
        [0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0],
        #[0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]])
        [0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0]])

print("returned\n", alg_a(H, .4))
"""

