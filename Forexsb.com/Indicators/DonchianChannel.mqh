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
#property version   "2.01"
#property strict

#include <Forexsb.com/Indicator.mqh>
#include <Forexsb.com/Enumerations.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class DonchianChannel : public Indicator
  {
public:
                     DonchianChannel(SlotTypes slotType);
   virtual void      Calculate(DataSet &dataSet);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DonchianChannel::DonchianChannel(SlotTypes slotType)
  {
   SlotType          = slotType;
   IndicatorName     = "Donchian Channel";
   WarningMessage    = "";
   IsAllowLTF        = true;
   ExecTime          = ExecutionTime_DuringTheBar;
   IsSeparateChart   = false;
   IsDiscreteValues  = false;
   IsDefaultGroupAll = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DonchianChannel::Calculate(DataSet &dataSet)
  {
   Data=GetPointer(dataSet);

   string logicRule=ListParam[0].Text;

   int period   = (int) NumParam[0].Value;
   int shift    = (int) NumParam[1].Value;
   int previous = CheckParam[0].Checked ? 1 : 0;

   double upperBand[]; ArrayResize(upperBand, Data.Bars); ArrayInitialize(upperBand, 0);
   double lowerBand[]; ArrayResize(lowerBand, Data.Bars); ArrayInitialize(lowerBand, 0);

   int firstBar=period+shift+previous+2;

   for(int bar=period+previous+2; bar<Data.Bars-shift; bar++)
     {
      double max = DBL_MIN;
      double min = DBL_MAX;
      for(int i=0; i<period; i++)
        {
         if(Data.High[bar-i]>max)
            max=Data.High[bar-i];
         if(Data.Low[bar-i]<min)
            min=Data.Low[bar-i];
        }
      upperBand[bar + shift] = max;
      lowerBand[bar + shift] = min;
     }

   ArrayResize(Component[0].Value,Data.Bars);
   Component[0].CompName = "Upper Band";
   Component[0].DataType = IndComponentType_IndicatorValue;
   Component[0].FirstBar = firstBar;
   ArrayCopy(Component[0].Value,upperBand);

   ArrayResize(Component[1].Value,Data.Bars);
   Component[1].CompName = "Lower Band";
   Component[1].DataType = IndComponentType_IndicatorValue;
   Component[1].FirstBar = firstBar;
   ArrayCopy(Component[1].Value,lowerBand);

   ArrayResize(Component[2].Value,Data.Bars);
   Component[2].FirstBar=firstBar;

   ArrayResize(Component[3].Value,Data.Bars);
   Component[3].FirstBar=firstBar;

   if(SlotType==SlotTypes_Open)
     {
      Component[2].DataType = IndComponentType_OpenLongPrice;
      Component[2].CompName = "Long position entry price";
      Component[3].DataType = IndComponentType_OpenShortPrice;
      Component[3].CompName = "Short position entry price";
     }
   else if(SlotType==SlotTypes_OpenFilter)
     {
      Component[2].DataType = IndComponentType_AllowOpenLong;
      Component[2].CompName = "Is long entry allowed";
      Component[3].DataType = IndComponentType_AllowOpenShort;
      Component[3].CompName = "Is short entry allowed";
     }
   else if(SlotType==SlotTypes_Close)
     {
      Component[2].DataType = IndComponentType_CloseLongPrice;
      Component[2].CompName = "Long position closing price";
      Component[3].DataType = IndComponentType_CloseShortPrice;
      Component[3].CompName = "Short position closing price";
     }
   else if(SlotType==SlotTypes_CloseFilter)
     {
      Component[2].DataType = IndComponentType_ForceCloseLong;
      Component[2].CompName = "Close out long position";
      Component[3].DataType = IndComponentType_ForceCloseShort;
      Component[3].CompName = "Close out short position";
     }

   if(SlotType==SlotTypes_Open || SlotType==SlotTypes_Close)
     {
      if(period>1)
        {
         for(int bar=firstBar; bar<Data.Bars; bar++)
           {
            // Covers the cases when the price can pass through the band without a signal.
            double open=Data.Open[bar]; // Current open price

                                        // Upper band
            double valueUp=upperBand[bar-previous]; // Current value
            double valueUp1=upperBand[bar-previous-1]; // Previous value
            double tempValUp=valueUp;

            if((valueUp1>Data.High[bar-1] && valueUp<open) || // The Data.Open price jumps above the indicator
               (valueUp1 < Data.Low[bar-1]  && valueUp > open) || // The Data.Open price jumps below the indicator
               (Data.Close[bar-1] < valueUp && valueUp < open) || // The Data.Open price is in a positive gap
               (Data.Close[bar-1] > valueUp && valueUp > open))   // The Data.Open price is in a negative gap
               tempValUp=open; // The entry/exit level is moved to Data.Open price

            // Lower band
            double valueDown=lowerBand[bar-previous]; // Current value
            double valueDown1=lowerBand[bar-previous-1]; // Previous value
            double tempValDown=valueDown;

            if((valueDown1>Data.High[bar-1] && valueDown<open) || // The Data.Open price jumps above the indicator
               (valueDown1 < Data.Low[bar-1] && valueDown > open)  || // The Data.Open price jumps below the indicator
               (Data.Close[bar-1] < valueDown && valueDown < open) || // The Data.Open price is in a positive gap
               (Data.Close[bar-1]>valueDown && valueDown>open)) // The Data.Open price is in a negative gap
               tempValDown=open; // The entry/exit level is moved to Data.Open price

            if(logicRule=="Enter long at Upper Band" ||
               logicRule=="Exit long at Upper Band")
              {
               Component[2].Value[bar] = tempValUp;
               Component[3].Value[bar] = tempValDown;
              }
            else
              {
               Component[2].Value[bar] = tempValDown;
               Component[3].Value[bar] = tempValUp;
              }
           }
        }
      else
        {
         for(int bar=2; bar<Data.Bars; bar++)
           {
            if(logicRule=="Enter long at Upper Band" || logicRule=="Exit long at Upper Band")
              {
               Component[2].Value[bar] = upperBand[bar - previous];
               Component[3].Value[bar] = lowerBand[bar - previous];
              }
            else
              {
               Component[2].Value[bar] = lowerBand[bar - previous];
               Component[3].Value[bar] = upperBand[bar - previous];
              }
           }
        }
     }
   else
     {
      if(logicRule=="The bar opens below Upper Band")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_below_the_Upper_Band);
      else if(logicRule=="The bar opens above Upper Band")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_above_the_Upper_Band);
      else if(logicRule=="The bar opens below Lower Band")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_below_the_Lower_Band);
      else if(logicRule=="The bar opens above Lower Band")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_above_the_Lower_Band);
      else if(logicRule=="The bar opens below Upper Band after opening above it")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_below_Upper_Band_after_above);
      else if(logicRule=="The bar opens above Upper Band after opening below it")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_above_Upper_Band_after_below);
      else if(logicRule=="The bar opens below Lower Band after opening above it")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_below_Lower_Band_after_above);
      else if(logicRule=="The bar opens above Lower Band after opening below it")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_opens_above_Lower_Band_after_below);
      else if(logicRule=="The position opens above Upper Band")
        {
         Component[0].PosPriceDependence = PositionPriceDependence_PriceBuyHigher;
         Component[1].PosPriceDependence = PositionPriceDependence_PriceSellLower;
         Component[2].DataType = IndComponentType_Other;
         Component[3].DataType = IndComponentType_Other;
         Component[2].ShowInDynInfo = false;
         Component[3].ShowInDynInfo = false;
        }
      else if(logicRule=="The position opens below Upper Band")
        {
         Component[0].PosPriceDependence = PositionPriceDependence_PriceBuyLower;
         Component[1].PosPriceDependence = PositionPriceDependence_PriceSellHigher;
         Component[2].DataType = IndComponentType_Other;
         Component[3].DataType = IndComponentType_Other;
         Component[2].ShowInDynInfo = false;
         Component[3].ShowInDynInfo = false;
        }
      else if(logicRule=="The position opens above Lower Band")
        {
         Component[0].PosPriceDependence = PositionPriceDependence_PriceSellLower;
         Component[1].PosPriceDependence = PositionPriceDependence_PriceBuyHigher;
         Component[2].DataType = IndComponentType_Other;
         Component[3].DataType = IndComponentType_Other;
         Component[2].ShowInDynInfo = false;
         Component[3].ShowInDynInfo = false;
        }
      else if(logicRule=="The position opens below Lower Band")
        {
         Component[0].PosPriceDependence = PositionPriceDependence_PriceSellHigher;
         Component[1].PosPriceDependence = PositionPriceDependence_PriceBuyLower;
         Component[2].DataType = IndComponentType_Other;
         Component[3].DataType = IndComponentType_Other;
         Component[2].ShowInDynInfo = false;
         Component[3].ShowInDynInfo = false;
        }
      else if(logicRule=="The bar closes below Upper Band")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_closes_below_the_Upper_Band);
      else if(logicRule=="The bar closes above Upper Band")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_closes_above_the_Upper_Band);
      else if(logicRule=="The bar closes below Lower Band")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_closes_below_the_Lower_Band);
      else if(logicRule=="The bar closes above Lower Band")
         BandIndicatorLogic(firstBar,previous,upperBand,lowerBand,Component[2],Component[3],BandIndLogic_The_bar_closes_above_the_Lower_Band);
     }
  }
//+------------------------------------------------------------------+
