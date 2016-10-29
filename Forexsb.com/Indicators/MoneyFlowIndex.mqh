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
class MoneyFlowIndex : public Indicator
  {
public:
                     MoneyFlowIndex(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MoneyFlowIndex::MoneyFlowIndex(SlotTypes slotType)
  {
   SlotType          = slotType;
   IndicatorName     = "Money Flow Index";
   WarningMessage    = "";
   IsAllowLTF        = true;
   ExecTime          = ExecutionTime_DuringTheBar;
   IsSeparateChart   = true;
   IsDiscreteValues  = false;
   IsDefaultGroupAll = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MoneyFlowIndex::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   int period=(int) NumParam[0].Value;
   double level=NumParam[1].Value;
   int previous=CheckParam[0].Checked ? 1 : 0;

   int firstBar=period+previous+2;

// Calculating Money Flow
   double adMf[]; ArrayResize(adMf,Data.Bars);ArrayInitialize(adMf,0);
   for(int bar=1; bar<Data.Bars; bar++)
     {
      double dAvg=(Data.High[bar]+Data.Low[bar]+Data.Close[bar])/3;
      double dAvg1=(Data.High[bar-1]+Data.Low[bar-1]+Data.Close[bar-1])/3;
      if(dAvg>dAvg1)
         adMf[bar]=adMf[bar-1]+dAvg*Data.Volume[bar];
      else if(dAvg<dAvg1)
         adMf[bar]=adMf[bar-1]-dAvg*Data.Volume[bar];
      else
         adMf[bar]=adMf[bar-1];
     }

// Calculating Money Flow Index
   double adMfi[]; ArrayResize(adMfi,Data.Bars);ArrayInitialize(adMfi,0);
   for(int bar=period+1; bar<Data.Bars; bar++)
     {
      double dPmf = 0;
      double dNmf = 0;
      for(int index=0; index<period; index++)
        {
         if(adMf[bar-index]>adMf[bar-index-1])
            dPmf+=adMf[bar-index]-adMf[bar-index-1];
         if(adMf[bar-index]<adMf[bar-index-1])
            dNmf+=adMf[bar-index-1]-adMf[bar-index];
        }
      if(MathAbs(dNmf)<Epsilon())
         adMfi[bar]=100.0;
      else
         adMfi[bar]=100.0 -(100.0/(1.0+(dPmf/dNmf)));
     }

// Saving the components

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Money Flow Index";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,adMfi);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].FirstBar=firstBar;

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].FirstBar=firstBar;

// Sets the Component's type
   if(SlotType==SlotTypes_OpenFilter)
     {
      Component[1].DataType = IndComponentType_AllowOpenLong;
      Component[1].CompName = "Is long entry allowed";
      Component[2].DataType = IndComponentType_AllowOpenShort;
      Component[2].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[1].DataType = IndComponentType_ForceCloseLong;
      Component[1].CompName = "Close out long position";
      Component[2].DataType = IndComponentType_ForceCloseShort;
      Component[2].CompName = "Close out short position";
     }

// Calculation of the logic
   IndicatorLogic indLogic=IndicatorLogic_It_does_not_act_as_a_filter;

   if(ListParam[0].Text=="MFI rises")
      indLogic=IndicatorLogic_The_indicator_rises;
   else if(ListParam[0].Text=="MFI falls")
      indLogic=IndicatorLogic_The_indicator_falls;
   else if(ListParam[0].Text=="MFI is higher than the Level line")
      indLogic=IndicatorLogic_The_indicator_is_higher_than_the_level_line;
   else if(ListParam[0].Text=="MFI is lower than the Level line")
      indLogic=IndicatorLogic_The_indicator_is_lower_than_the_level_line;
   else if(ListParam[0].Text=="MFI crosses the Level line upward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_upward;
   else if(ListParam[0].Text=="MFI crosses the Level line downward")
      indLogic=IndicatorLogic_The_indicator_crosses_the_level_line_downward;
   else if(ListParam[0].Text=="MFI changes its direction upward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_upward;
   else if(ListParam[0].Text=="MFI changes its direction downward")
      indLogic=IndicatorLogic_The_indicator_changes_its_direction_downward;

   OscillatorLogic(firstBar,previous,adMfi,level,100-level,Component[1],Component[2],indLogic);
  }
//+------------------------------------------------------------------+
