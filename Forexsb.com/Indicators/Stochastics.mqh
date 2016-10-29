//+--------------------------------------------------------------------+
//| Copyright:  (C) 2016 Forex Software Ltd.                           |
//| Website:    http://forexsb.com/                                    |
//| Support:    http://forexsb.com/forum/                              |
//| License:    Proprietary under the following circumstances:         |
//|                                                                    |
//| This code is a part of Forex Strategy Builder. It is free for      |
//| use as an integral part of Forex Strategy Builder.                 |
//| One can modify it in order to improve the code or to fit it for    |
//| personal use. This code or any part of it cannot be used in        |
//| other applications without a permission.                           |
//| The contact information cannot be changed.                         |
//|                                                                    |
//| NO LIABILITY FOR CONSEQUENTIAL DAMAGES                             |
//|                                                                    |
//| In no event shall the author be liable for any damages whatsoever  |
//| (including, without limitation, incidental, direct, indirect and   |
//| consequential damages, damages for loss of business profits,       |
//| business interruption, loss of business information, or other      |
//| pecuniary loss) arising out of the use or inability to use this    |
//| product, even if advised of the possibility of such damages.       |
//+--------------------------------------------------------------------+

#property copyright "Copyright (C) 2016 Forex Software Ltd."
#property link      "http://forexsb.com"
#property version   "2.1"
#property strict

#include <Forexsb.com/Indicator.mqh>
#include <Forexsb.com/Enumerations.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Stochastics : public Indicator
  {
public:
   Stochastics(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Stochastics";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_DuringTheBar;
      IsSeparateChart   = true;
      IsDiscreteValues  = false;
      IsDefaultGroupAll = false;
     }

   virtual void Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Stochastics::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading parameters
   MAMethod maMethod=(MAMethod)ListParam[1].Index;
   int iK     = (int)NumParam[0].Value;
   int iDFast = (int)NumParam[1].Value;
   int iDSlow = (int)NumParam[2].Value;
   int iLevel = (int)NumParam[3].Value;
   int previous  = CheckParam[0].Checked ? 1 : 0;

// Calculation
   int firstBar=iK+iDFast+iDSlow+3;

   double adHighs[]; ArrayResize(adHighs,Data.Bars); ArrayInitialize(adHighs,0);
   double adLows[];  ArrayResize(adLows,Data.Bars);  ArrayInitialize(adLows,0);
   for(int bar=0; bar<iK; bar++)
     {
      double min = DBL_MAX;
      double max = DBL_MIN;
      for(int i=0; i<bar; i++)
        {
         if(Data.High[bar - i] > max) max = Data.High[bar - i];
         if(Data.Low[bar  - i] < min) min = Data.Low[bar  - i];
        }
      adHighs[bar] = max;
      adLows[bar]  = min;
     }
   adHighs[0] = Data.High[0];
   adLows[0]  = Data.Low[0];

   for(int bar=iK; bar<Data.Bars; bar++)
     {
      double min = DBL_MAX;
      double max = DBL_MIN;
      for(int i=0; i<iK; i++)
        {
         if(Data.High[bar - i] > max) max = Data.High[bar - i];
         if(Data.Low[bar  - i] < min) min = Data.Low[bar  - i];
        }
      adHighs[bar] = max;
      adLows[bar]  = min;
     }

   double adK[];  ArrayResize(adK,Data.Bars);  ArrayInitialize(adK,0);
   for(int bar=iK; bar<Data.Bars; bar++)
     {
      if(adHighs[bar]==adLows[bar])
         adK[bar]=50;
      else
         adK[bar]=100 *(Data.Close[bar]-adLows[bar])/(adHighs[bar]-adLows[bar]);
     }

   double adDFast[]; ArrayResize(adDFast,Data.Bars);  ArrayInitialize(adDFast,0);
   for(int bar=iDFast; bar<Data.Bars; bar++)
     {
      double dSumHigh = 0;
      double dSumLow  = 0;
      for(int i=0; i<iDFast; i++)
        {
         dSumLow  += Data.Close[bar - i]   - adLows[bar - i];
         dSumHigh += adHighs[bar - i] - adLows[bar - i];
        }
      if(dSumHigh==0)
         adDFast[bar]=100;
      else
         adDFast[bar]=100*dSumLow/dSumHigh;
     }

   double adDSlow[]; MovingAverage(iDSlow,0,maMethod,adDFast,adDSlow);

// Saving components

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName   = "%K";
   Component[0].DataType   = IndComponentType_IndicatorValue;
   Component[0].FirstBar   = firstBar;
   ArrayCopy(Component[0].Value,adK);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName   = "Fast %D";
   Component[1].DataType   = IndComponentType_IndicatorValue;
   Component[1].FirstBar   = firstBar;
   ArrayCopy(Component[1].Value,adDFast);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].CompName   = "Slow %D";
   Component[2].DataType   = IndComponentType_IndicatorValue;
   Component[2].FirstBar   = firstBar;
   ArrayCopy(Component[2].Value,adDSlow);

   ArrayResize(Component[3].Value,Data.Bars);
   Component[3].FirstBar=firstBar;

   ArrayResize(Component[4].Value,Data.Bars);
   Component[4].FirstBar=firstBar;

// Sets Component's type
   if(SlotType==SlotTypes_OpenFilter)
     {
      Component[3].DataType = IndComponentType_AllowOpenLong;
      Component[3].CompName = "Is long entry allowed";
      Component[4].DataType = IndComponentType_AllowOpenShort;
      Component[4].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[3].DataType = IndComponentType_ForceCloseLong;
      Component[3].CompName = "Close out long position";
      Component[4].DataType = IndComponentType_ForceCloseShort;
      Component[4].CompName = "Close out short position";
     }

// Calculation of logic
   IndicatorLogic indLogic=IndicatorLogic_It_does_not_act_as_a_filter;

   if(ListParam[0].Text=="%K crosses Slow %D upward")
      IndicatorCrossesAnotherIndicatorUpwardLogic(firstBar,previous,adK,adDSlow,Component[3],Component[4]);
   else if(ListParam[0].Text=="%K crosses Slow %D downward")
      IndicatorCrossesAnotherIndicatorDownwardLogic(firstBar,previous,adK,adDSlow,Component[3],Component[4]);
   else if(ListParam[0].Text=="%K is higher than Slow %D")
      IndicatorIsHigherThanAnotherIndicatorLogic(firstBar,previous,adK,adDSlow,Component[3],Component[4]);
   else if(ListParam[0].Text=="%K is lower than Slow %D")
      IndicatorIsLowerThanAnotherIndicatorLogic(firstBar,previous,adK,adDSlow,Component[3],Component[4]);
   else
     {
      if(ListParam[0].Text=="Slow %D rises")
         indLogic=IndicatorLogic_The_indicator_rises;
      else if(ListParam[0].Text=="Slow %D falls")
         indLogic=IndicatorLogic_The_indicator_falls;
      else if(ListParam[0].Text=="Slow %D is higher than Level line")
         indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
      else if(ListParam[0].Text=="Slow %D is lower than Level line")
         indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
      else if(ListParam[0].Text=="Slow %D crosses Level line upward")
         indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
      else if(ListParam[0].Text=="Slow %D crosses Level line downward")
         indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
      else if(ListParam[0].Text=="Slow %D changes its direction upward")
         indLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
      else if(ListParam[0].Text=="Slow %D changes its direction downward")
         indLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

      OscillatorLogic(firstBar,previous,adDSlow,iLevel,100-iLevel,Component[3],Component[4],indLogic);
     }
  }
//+------------------------------------------------------------------+
