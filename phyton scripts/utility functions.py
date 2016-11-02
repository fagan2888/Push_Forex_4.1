# -*- coding: utf-8 -*-
"""
Created on Sun Oct  9 20:28:18 2016

@author: Lorenzo
"""

"""Utility functions"""

import os
import pandas as pd

def symbol_to_path(symbol, base_dir="data"):
    """Return CSV file path given ticker symbol."""
    return "{}.csv".format(symbol)


def get_data(symbols, dates):
    """Read stock data (adjusted close) for given symbols from CSV files."""
    df = pd.DataFrame(index=dates)
    if 'SPY' not in symbols:  # add SPY for reference, if absent
        symbols.insert(0, 'SPY')

    for symbol in symbols:
        df_temp=pd.read_csv(symbol_to_path(symbol), sep=' ', index_col='Date', 
                            parse_dates=True, usecols=['Date','Adj Close'], 
                            na_values=['nan'])
    
        df_temp=df_temp.rename(columns={'Adj Close':symbol})
        df=df.join(df_temp)    
        
        if symbol == "SPY":
            df=df.dropna(subset=["SPY"])
    

    return df

def normalize_data(df):
    """Normalize stock prices using first row in dataframe"""
    return df/df.ix[0,:]

def plot_data(df, title="Stock prices"):
    """Plot stock prices with a custom title and meaningful axis labels."""
    ax = df.plot(title=title, fontsize=12)
    ax.set_xlabel("Date")
    ax.set_ylabel("Price")
    plt.show()


def plot_selected(df, columns, start_index, end_index):
    """Plot the desired columns over index values in the given range."""
    plot_data(df.ix[start_index:end_index,columns],title="selected data")


def test_run():
    # Define a date range
    dates = pd.date_range('2010-01-22', '2010-01-26')

    # Choose stock symbols to read
    symbols = ['GOOG', 'IBM', 'GLD']
    
    # Get stock data
    df = get_data(symbols, dates)
    print df




if __name__ == "__main__":
    test_run()
