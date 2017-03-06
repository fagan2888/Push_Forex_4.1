
from __future__ import division
import numpy as np
import itertools as itt
import scipy as sc
from scipy import stats
import matplotlib.pyplot as plt

print("ready")

def sharpeRatio(PLmatrix):
    """

    Calculate the annualised Sharpe ratio of a returns stream
    based on a number of trading periods, N. N defaults to 252,
    which then assumes a stream of daily returns.

    The function assumes that the returns are the excess of
    those compared to a benchmark.

    Parameters
    ----------


    Returns
    -------


    Example
    -------


    """

    SR = np.sqrt(252) * np.mean(PLmatrix, axis=1) / np.std(PLmatrix, axis=1)
    #SR = np.mean(PLmatrix, axis=1)

    return SR

def PDFandCDFonRows(matrix, nbin):

    # This function calculates PDF for every row of the input matrix
    nrows, ncols = np.shape(matrix)
    PDF = np.zeros((nrows, nbin))
    unityPDF = np.zeros((nrows, nbin))
    CDF = np.zeros((nrows, nbin))
    bin_edges = np.zeros((nrows, nbin+1))

    for nr in range(nrows):
        PDF[nr, :], bin_edges[nr, :] = np.histogram(matrix[nr, :], nbin, density=True)
        unityPDF[nr, :] = PDF[nr, :] / PDF[nr, :].sum()
        CDF[nr, :] = np.cumsum(unityPDF[nr, :])

    wd = (max(bin_edges[0, :]) - min(bin_edges[0, :])) / nbin
    xCDF = np.arange(min(bin_edges[0, :]), max(bin_edges[0, :]), wd)

    return unityPDF, bin_edges, CDF, xCDF


def plotPDF(unityPDF, bin_edges, CDF, xCDF, k):

    nbin = xCDF.size
    wd = (max(bin_edges[k, :]) - min(bin_edges[k, :])) / nbin
    fig1 = plt.figure()
    fig1.suptitle('Probability Density Function')
    plt.bar(bin_edges[k, :-1], unityPDF[k, :], width=wd)
    plt.xlim(min(bin_edges[k, :]), max(bin_edges[k, :]))
    fig2 = plt.figure()
    fig2.suptitle('Cumulative Distribution Function')
    plt.plot(xCDF, CDF[k, :])


def bktValidation_01(S):
    """

    This function calculate the probability of bkt overfitting for a matrix M
    containing N coloumn of P&L each one obtained from a different combination of
    Algos parameters. 

    Parameters
    ----------


    Returns
    -------


    Example
    -------


    """

    M = np.random.randint(-10, 10, (200, 1000))

    [N, T] = np.shape(M)
    S2 = S/2
    print(N, T, S2)
    nCol = T//S
    #print(nCol)

    # M = np.ones((5, 16))
    #startCol = 0
    #for k in range(S):
    #    endCol = startCol + nCol
    #    print(startCol)
    #    print(endCol)
    #    M[:, startCol:endCol] = M[:, startCol:endCol] + k
    #    startCol = endCol
    print(M)


    Ms = np.zeros((S, N, nCol))
    #print(np.shape(Ms))
    startCol = 0
    for s in range(S):
        endCol = startCol + nCol
        #print(startRow, endRow)
        Ms[s, :, :] = M[:, startCol:endCol]
        startCol = endCol
    # print(Ms)

    indexMs = np.array(np.arange(0, S, 1))
    #print(indexMs)
    combMs2 = np.array(list(itt.combinations(indexMs, S//2)))
    #print(combMs2)

    [nCs, _] = np.shape(combMs2)
    #print(nCs)

    JIS = np.zeros((N, T//2))
    JOOS = np.zeros((N, T//2))
    RIS = np.zeros((N, nCs))
    ROOS = np.zeros((N, nCs))
    rIS = np.zeros((N, nCs))
    rOOS = np.zeros((N, nCs))
    rOOSn = np.zeros((N, nCs))
    PBO = np.zeros(N)

    for c in range(nCs):
        combIS = np.array(combMs2)[c, :]
        combOOS = np.setdiff1d(indexMs, combIS)
        #print(combIS)
        #print(combOOS)
        combMs = np.append(combIS, combOOS)
        #print(combMs)
        for s in range(S//2):
            indexIS = combIS[s]
            indexOOS = combOOS[s]
            CsIS = Ms[indexIS, :, :]
            CsOOS = Ms[indexOOS, :, :]
            if s == 0:
                JIS = CsIS
                JOOS = CsOOS
            else:
                JIS = np.c_[JIS, CsIS]
                JOOS = np.c_[JOOS, CsOOS]
            RcIS = sharpeRatio(JIS)
            RcOOS = sharpeRatio(JOOS)
            rcIS = sc.stats.rankdata(RcIS, method='ordinal')
            rcOOS = sc.stats.rankdata(RcOOS, method='ordinal')

            RIS[:, c] = RcIS
            ROOS[:, c] = RcOOS
            rIS[:, c] = rcIS
            rOOS[:, c] = rcOOS

        #print(combIS)
        #print(JIS)
        #print(combOOS)
        #print(JOOS)
        #print('IS')
        #print(RIS)
        #print(rIS)
        #print('OOS')
        #print(ROOS)
        #print(rOOS)


    print('IS')
    print(RIS)
    print(rIS)
    print('OOS')
    print(ROOS)
    print(rOOS)

    for n in range(N):
        print(n)
        nIS = np.where(rIS == (n+1))
        #print(nIS)
        rOOSn[n, :] = rOOS[nIS]

    print('rOOSn')
    print(rOOSn)

    print('omegac')
    omegac = (rOOSn) / (N + 1)
    print(omegac)
    print('logitc')
    logitc = np.log(omegac / (1 - omegac))
    print(logitc)
    print(np.shape(logitc))
    fig3 = plt.figure()
    fig3.suptitle('Logits of the Best Strategy')
    plt.plot(np.arange(0, nCs, 1), logitc[0, :])

    # calculate discrete PDF
    unityPDF_logitc, bin_edges_logitc, CDF_logitc, xCDF_logitc = PDFandCDFonRows(logitc, 20)
    plotPDF(unityPDF_logitc, bin_edges_logitc, CDF_logitc, xCDF_logitc, 0)

    # calculate Probability BackTest Overfitting (PBO)
    for n in range(N):
        PBO[n] = np.interp(0., xCDF_logitc, CDF_logitc[n, :])
    fig4 = plt.figure()
    fig4.suptitle('Probability BackTest Overfitting')
    plt.plot(PBO)

    # calculate PDF of rIS
    unityPDF_rIS, bin_edges_rIS, CDF_rIS, xCDF_rIS = PDFandCDFonRows(rIS, N)
    plotPDF(unityPDF_rIS, bin_edges_rIS, CDF_rIS, xCDF_rIS, 0)

    #Rdiff = ROOS - RIS
    #print('Rdiff')
    #print(Rdiff)
    #plt.plot(RIS[1, :], ROOS[1, :], 'o')

    #nundPerOOS = (Rdiff < 0).sum(1)
    #PundPerOOS = (nundPerOOS / nCs)*100
    #print(PundPerOOS)

    return rIS, rOOS

