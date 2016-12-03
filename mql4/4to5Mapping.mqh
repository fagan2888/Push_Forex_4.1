//+------------------------------------------------------------------+
//|                                                  4to5Mapping.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

double Bid() {
   MqlTick last_tick;
   SymbolInfoTick(_Symbol,last_tick);
   return last_tick.bid;
}

datetime iTime(string symbol,int tf,int index)
{
   if(index < 0) return(-1);
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   datetime Arr[];
   if(CopyTime(symbol, timeframe, index, 1, Arr)>0)
        return(Arr[0]);
   else return(-1);
}

double iOpen(string symbol,int tf,int index)

{   
   if(index < 0) return(-1);
   double Arr[];
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(CopyOpen(symbol,timeframe, index, 1, Arr)>0) 
        return(Arr[0]);
   else return(-1);
}

double iHigh(string symbol,int tf,int index)
{   
   if(index < 0) return(-1);
   double Arr[];
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(CopyHigh(symbol,timeframe, index, 1, Arr)>0) 
        return(Arr[0]);
   else return(-1);
}

double iLow(string symbol,int tf,int index)
{   
   if(index < 0) return(-1);
   double Arr[];
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(CopyLow(symbol,timeframe, index, 1, Arr)>0) 
        return(Arr[0]);
   else return(-1);
}

double iClose(string symbol,int tf,int index)
{   
   if(index < 0) return(-1);
   double Arr[];
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(CopyClose(symbol,timeframe, index, 1, Arr)>0) 
        return(Arr[0]);
   else return(-1);
}

double iVolume(string symbol,int tf,int index)
{   
   if(index < 0) return(-1);
   long Arr[];
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(CopyTickVolume(symbol, timeframe, index, 1, Arr)>0)
        return(Arr[0]);
   else return(-1);
}

int TimeYear(datetime date)
{
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.year);
}


int TimeMonth(datetime date)
{
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.mon);
}


int TimeDay(datetime date)
{
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day);
}

int Day()
{
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.day);
}

int Month()
{
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.mon);
}

int Year()
{
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.year);
}

string DoubleToStr(double d)
{
   return DoubleToString(d);
}

double StrToDouble(string s)
{
   return StringToDouble(s);
}

int StrToInteger(string s)
{
   return StringToInteger(s);
}

string IntegerToStr(int i)
{
   return IntegerToString(i);
}

ENUM_TIMEFRAMES TFMigrate(int tf)
  {
   switch(tf)
     {
      case 0: return(PERIOD_CURRENT);
      case 1: return(PERIOD_M1);
      case 5: return(PERIOD_M5);
      case 15: return(PERIOD_M15);
      case 30: return(PERIOD_M30);
      case 60: return(PERIOD_H1);
      case 240: return(PERIOD_H4);
      case 1440: return(PERIOD_D1);
      case 10080: return(PERIOD_W1);
      case 43200: return(PERIOD_MN1);
      
      case 2: return(PERIOD_M2);
      case 3: return(PERIOD_M3);
      case 4: return(PERIOD_M4);      
      case 6: return(PERIOD_M6);
      case 10: return(PERIOD_M10);
      case 12: return(PERIOD_M12);
      case 16385: return(PERIOD_H1);
      case 16386: return(PERIOD_H2);
      case 16387: return(PERIOD_H3);
      case 16388: return(PERIOD_H4);
      case 16390: return(PERIOD_H6);
      case 16392: return(PERIOD_H8);
      case 16396: return(PERIOD_H12);
      case 16408: return(PERIOD_D1);
      case 32769: return(PERIOD_W1);
      case 49153: return(PERIOD_MN1);      
      default: return(PERIOD_CURRENT);
     }
  }