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

class TrailingStopLimit : public Indicator
{
public:
    TrailingStopLimit(SlotTypes slotType)
    {
        SlotType = slotType;
        
        IndicatorName     = "Trailing Stop Limit";

        IsAllowLTF        = true;
        ExecTime          = ExecutionTime_DuringTheBar;
        IsSeparateChart   = false;
        IsDiscreteValues  = false;
        IsDefaultGroupAll = false;
    }

    virtual void Calculate(DataSet &dataSet);
};

void TrailingStopLimit::Calculate(DataSet &dataSet)
{
    Data = GetPointer(dataSet);

    // Saving the components
    ArrayResize(Component[0].Value, Data.Bars);
    ArrayInitialize(Component[0].Value,0);
    Component[0].CompName = "Trailing Stop for a transferred position";
    Component[0].DataType = IndComponentType_Other;
    Component[0].ShowInDynInfo = false;
    Component[0].FirstBar = 2;
}
