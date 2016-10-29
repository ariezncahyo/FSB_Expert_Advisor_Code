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
class PriceMove : public Indicator
  {
public:
   PriceMove(SlotTypes slotType)
     {
      SlotType=slotType;

      IndicatorName="Price Move";

      WarningMessage    = "";
      IsAllowLTF        = true;
      ExecTime          = ExecutionTime_DuringTheBar;
      IsSeparateChart   = false;
      IsDiscreteValues  = false;
      IsDefaultGroupAll = false;
     }

   virtual void Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PriceMove::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

// Reading the parameters
   BasePrice price=(BasePrice) ListParam[1].Index;
   double margin=NumParam[0].Value*Data.Point;
   int previous=CheckParam[0].Checked ? 1 : 0;

// TimeExecution
   if(price==BasePrice_Open && MathAbs(margin-0)<Epsilon())
      ExecTime=ExecutionTime_AtBarOpening;
   else if(price== BasePrice_Close && MathAbs(margin-0)<Epsilon())
      ExecTime = ExecutionTime_AtBarClosing;
   else
      ExecTime = ExecutionTime_DuringTheBar;

// Calculation
   double adBasePr[];  Price(price,adBasePr);
   double upperBand[];  ArrayResize(upperBand,Data.Bars); ArrayInitialize(upperBand,0);
   double lowerBand[];  ArrayResize(lowerBand,Data.Bars); ArrayInitialize(lowerBand,0);

   int firstBar=previous+2;

   for(int bar=firstBar; bar<Data.Bars; bar++)
     {
      upperBand[bar] = adBasePr[bar - previous] + margin;
      lowerBand[bar] = adBasePr[bar - previous] - margin;
     }

// Saving the components
   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Up Price";
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,upperBand);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Down Price";
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,lowerBand);

   if(ListParam[0].Text=="Enter long after an upward move") 
     {
      Component[0].DataType = IndComponentType_OpenLongPrice;
      Component[1].DataType = IndComponentType_OpenShortPrice;
     }

   if(ListParam[0].Text=="Enter long after a downward move") 
     {
      Component[0].DataType = IndComponentType_OpenShortPrice;
      Component[1].DataType = IndComponentType_OpenLongPrice;
     }
  }
//+------------------------------------------------------------------+
