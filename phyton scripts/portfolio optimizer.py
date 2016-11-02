# -*- coding: utf-8 -*-
"""
Created on Fri Oct 28 16:47:27 2016

@author: Lorenzo
"""

import numpy as np
import pandas as pd
import pandas.io.data as web
import matplotlib.pyplot as plt
import scipy.optimize as sco
import os
import datetime

def get_webdata(data,symbols,start,end):
    for sym in symbols:
        df_temp = web.DataReader(sym, 'yahoo', start, end)['Adj Close']
        df_temp = df_temp.to_frame()
        df_temp=df_temp.rename(columns={'Adj Close':sym})
        data=data.join(df_temp)
        data=data.dropna()
    return data

def symbol_to_path(symbol, base_dir="data"):
    """Return CSV file path given ticker symbol."""
    return os.path.join(base_dir, "{}.csv".format(str(symbol)))

def statistics(weights,rets):
    """ Returns portfolio statistics.
    Parameters
    ==========
    weights : array-like
    weights for different securities in portfolio
    Returns
    =======
    pret : float
    expected portfolio return
    pvol : float
    expected portfolio volatility
    pret / pvol : float
    Sharpe ratio for rf=0
    """
    weights = np.array(weights)
    pret = np.sum(rets.mean() * weights) * 252
    pvol = np.sqrt(np.dot(weights.T, np.dot(rets.cov() * 252, weights)))

    return np.array([pret, pvol, pret / pvol])





def test_run():

    # ManualInput:
    symbols = ['AAPL', 'AMZN', 'GOOGL', 'NFLX', 'ITX.MC', 'LUX']
    
    total_investment = 10000  # in EUR / USD (non guardo l'exchange rate...)
        
    
    noa = len(symbols)

    # Define a date range
    start = datetime.datetime(2015, 1, 2)
    end = datetime.date.today()
    dates = pd.date_range(start, end)

    data = pd.DataFrame(index=dates)

#    for sym in symbols:
#        df_temp = pd.read_csv(symbol_to_path(sym), sep=',', index_col='Date',
#                              parse_dates=True, usecols=['Date','Adj Close'],
#                              na_values=['nan'])
#                            
#        df_temp=df_temp.rename(columns={'Adj Close':sym})
#        data=data.join(df_temp)
#        data=data.dropna()

    data = get_webdata(data,symbols,start,end)
    
    (data / data.ix[0] * 100).plot(figsize=(25, 13))

    rets = np.log(data / data.shift(1))
    
    # show mean returns and covariance of the stocks in the portfolio
    print('yearly mean returns of single stocks:')
    print(rets.mean() * 252)
    print('yearly covariance matrix:')
    print(rets.cov() * 252 )
    print('correlation matrix:')
    print(rets.corr())
    
    weights = np.random.random(noa)
    weights /= np.sum(weights)
    
    # simulate some portfolios with different weight and plot it
    prets = []
    pvols = []
    for p in range (5000):
        weights = np.random.random(noa)
        weights /= np.sum(weights)
        prets.append(np.sum(rets.mean() * weights) * 252)
        pvols.append(np.sqrt(np.dot(weights.T,
                                    np.dot(rets.cov() * 252, weights))))
                                    
    prets = np.array(prets)
    pvols = np.array(pvols)

#    plt.figure(figsize=(30, 18))
#    plt.scatter(pvols, prets, c=prets / pvols, marker='o')
#    plt.grid(True)
#    plt.xlabel('expected volatility')
#    plt.ylabel('expected return')
#    plt.colorbar(label='Sharpe ratio')

    # constrains on the weight
    cons = ({'type': 'eq', 'fun': lambda x: np.sum(x) - 1})
    bnds = tuple((0, 1) for x in range(noa))

    # initial guess: equal weight    
    weigths = noa * [1. / noa,]
  

    # Optimize for Sharp Ratio  
    def min_func_sharpe(weights):
        pret = np.sum(rets.mean() * weights) * 252
        pvol = np.sqrt(np.dot(weights.T, np.dot(rets.cov() * 252, weights)))
        return -pret / pvol

    opts = sco.minimize(min_func_sharpe, noa * [1. / noa,], method='SLSQP',
                        bounds=bnds, constraints=cons)
                        
    invested_portfolio = opts['x'] * total_investment
    stock_quantity = np.floor( np.array( invested_portfolio/data[-1:] ) )

    print()
    print('MAX SHARP RATIO PORTFOLIO:')
    print('optimized weigths:')
    print(opts['x'].round(3))
    print('nr of stocks to buy:')
    print(stock_quantity)
    print('statistics of the optimized portfolio: mean - variance - Sharp ratio')    
    print(statistics(opts['x'], rets).round(3))

    # Optimize for Variance
    def min_func_variance(weights):
        return statistics(weights, rets)[1] ** 2
        
    optv = sco.minimize(min_func_variance, noa * [1. / noa,],
                        method='SLSQP', bounds=bnds,
                        constraints=cons)
                        
    invested_portfolio = optv['x'] * total_investment
    stock_quantity = np.floor( np.array( invested_portfolio/data[-1:] ) )


    print()
    print('MIN VARIANCE PORTFOLIO:')
    print('optimized weigths:')
    print(optv['x'].round(3))
    print('nr of stocks to buy:')
    print(stock_quantity)
    print('statistics of the optimized portfolio: mean - variance - Sharp ratio')    
    print(statistics(optv['x'], rets).round(3))
    
    # Efficient Frontier
    def min_func_port(weights):
        return statistics(weights, rets)[1]

    trets = np.linspace(0.0, 0.25, 50)
    tvols = []

    for tret in trets:
        cons = ({'type': 'eq', 'fun': lambda x: statistics(x, rets)[0] - tret},
                {'type': 'eq', 'fun': lambda x: np.sum(x) - 1})
        res = sco.minimize(min_func_port, noa * [1. / noa,], method='SLSQP',
                                   bounds=bnds, constraints=cons)
        tvols.append(res['fun'])

    tvols = np.array(tvols)

    plt.figure(figsize=(25, 13))
    plt.scatter(pvols, prets,
                c=np.array(prets) / np.array(pvols), marker='o')
    # random portfolio composition
    plt.scatter(tvols, trets,
                c=trets / tvols, marker='x',markersize=15.0)
    # efficient frontier
    plt.plot(statistics(opts['x'], rets)[1], statistics(opts['x'], rets)[0],
             'r*', markersize=30.0)
    # portfolio with highest Sharpe ratio
    plt.plot(statistics(optv['x'], rets)[1], statistics(optv['x'], rets)[0],
             'y*', markersize=30.0)
    # minimum variance portfolio
    plt.grid(True)
    plt.xlabel('expected volatility')
    plt.ylabel('expected return')
    plt.colorbar(label='Sharpe ratio')

    osportfolio = (data/data.ix[0] * 100).multiply(opts['x'],axis=1).sum(1)
    
    ovportfolio = (data/data.ix[0] * 100).multiply(optv['x'],axis=1).sum(1)
    
    # plot the historical returns of two optimal portfolio
    plt.figure(figsize=(25, 13))
    plt.plot(osportfolio, label='Max Sharp Ratio Potf.')
    plt.plot(ovportfolio, label='Min Variance Porf.')
    plt.legend()
    
if __name__ == "__main__":
    test_run()
