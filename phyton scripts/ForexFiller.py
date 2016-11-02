# -*- coding: utf-8 -*-
"""
Created on Sun Oct 23 13:30:27 2016

@author: Lorenzo
"""
import pandas as pd
import numpy as np


start_date='2016-05-31 05:23:00'
end_date='2016-08-02 18:18:00'
dates=pd.date_range(start_date,end_date,freq='1min' )

# empty dataframe
df1=pd.DataFrame(index=dates,columns=['Open','High', 'Low', 'Close', 'Volume'])
#df1=pd.DataFrame(index=dates)

dfup = pd.read_csv('forex/EURUSDup.csv',sep=',',header=None,
                 names=['Date', 'Time', 'Open','High', 'Low', 'Close', 'Volume'],
                 index_col='Date_Time', parse_dates=[[0, 1]], na_values=['nan'])
                     # date_parser=parse)

dfdown = pd.read_csv('forex/EURUSDdown.csv',sep=',',header=None,
                 names=['Date', 'Time', 'Open','High', 'Low', 'Close', 'Volume'],
                 index_col='Date_Time', parse_dates=[[0, 1]], na_values=['nan'])
                     # date_parser=parse)
#df.iloc[[2]]=np.nan

#df1.combine_first(dfup)
#dfup.combine_first(dfdown)

#df1.update(df[df1.isnull()==True])


#dfup.set_index('Date_Time', inplace=True)
#dfdown.set_index('Date_Time', inplace=True)
df2 = dfup.merge(dfdown.ix[:,dfdown.columns.difference(dfup.columns)], left_index=True, right_index=True, how="outer")
df2.update(dfdown[df2.isnull()==True])

# let's erase the columns we don't need
#del df['Tid'] 
#del df['Dealable']

# group every 15 minutes and create an OHLC bar
#grouped_data = df.resample('15Min', how='ohlc')