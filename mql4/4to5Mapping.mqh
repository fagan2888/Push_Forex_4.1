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
#include <Expert\Expert.mqh> 
#include <trade\trade.mqh>

double Bid() {
   MqlTick last_tick;
   SymbolInfoTick(_Symbol,last_tick);
   return last_tick.bid;
}


double Ask() {
   MqlTick last_tick;
   SymbolInfoTick(_Symbol,last_tick);
   return last_tick.ask;
}

void RefreshRates()
{
   //NO-OP in mql5
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

long StrToInteger(string s)
{
   return StringToInteger(s);
}

string IntegerToStr(int i)
{
   return IntegerToString(i);
}

long OrderType()
{
   return OrderGetInteger(ORDER_TYPE);
}

bool OrderSelect(ulong ticket, int selectMode, int isLiveTicket)
{
   //ignore last two params in mql5, use HistoryDealSelect for historic
   return PositionSelect(ticket);
}

//int ticket = OrderSend(Symbol(),OP_BUY,1,Ask(),50,sl,tp,"commento",magic,0,CLR_NONE);      
ulong OrderSend(string sybmbol, ENUM_ORDER_TYPE type, double volume, double price,
         ulong deviation, double sl, double tp, string comment, long const magic_number, datetime expiration, int ignoreme) 
{ 
//--- prepare a request 
   MqlTradeRequest request={0}; 
   request.symbol=sybmbol;                
   request.type=type;                     
   request.volume=volume;                 
   request.price=price;  
   request.deviation = deviation;
   request.sl=sl;        
   request.tp=tp;        
   request.magic=magic_number; 
   request.comment = comment;
   request.expiration = expiration;
   request.action=TRADE_ACTION_PENDING;   

   MqlTradeResult result={0}; 
   if(OrderSend(request,result))
   {
      Print(__FUNCTION__,":",result.comment);
      if(result.retcode==10009 || result.retcode==10008) //Request is completed or order placed
      {
         return result.deal;
      }
      else {
         Print("Trade failed, result code: " + IntegerToString(result.retcode));
         return -1;
      }
   }
   else
   {
      return GetLastError();
   }
}

double OrderOpenPrice()
{
   return PositionGetDouble(POSITION_PRICE_OPEN);
}

double OrderStopLoss()
{
   return PositionGetDouble(POSITION_SL);
}

double OrderTakeProfit()
{
   return PositionGetDouble(POSITION_TP);
}

bool OrderClose(ulong ticket, ulong deviation)
{
   CTrade trade;
   return trade.PositionClose(ticket, deviation);
}

#define SELECT_BY_TICKET 0   //Pending order of BUY LIMIT type 
#define SELECT_BY_POS 1      //Pending order of SELL STOP type 
#define MODE_TRADES  0       //Pending order of SELL LIMIT type 
#define MODE_HISTORY 1       //Pending order of BUY STOP type 
#define OP_BUY  ORDER_TYPE_BUY
#define OP_SELL ORDER_TYPE_SELL
#define Point SymbolInfoDouble(_Symbol,SYMBOL_POINT);

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