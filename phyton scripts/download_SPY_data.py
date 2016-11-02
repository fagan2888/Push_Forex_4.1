# -*- coding: utf-8 -*-
"""
Created on Thu Sep 22 22:48:57 2016

@author: Lorenzo
"""

import pandas as pd
import pandas_datareader.data as web
import datetime

start = datetime.datetime(2010, 1, 1)
end = datetime.datetime(2012, 1, 2)
symbol = "GOOG"
filename = symbol + ".csv"

data = web.DataReader(symbol, 'yahoo', start, end)

data.to_csv(path_or_buf=filename, sep= ' ')

#print(data)

#f = open(filename, 'w')
#f.write(data.content )
#f.close()