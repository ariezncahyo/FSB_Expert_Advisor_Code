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

class StopLoss : public Indicator
{
public:
    StopLoss(SlotTypes slotType)
    {
        SlotType = slotType;
        
        IndicatorName     = "Stop Loss";

        WarningMessage    = "";
        IsAllowLTF        = true;
        ExecTime          = ExecutionTime_DuringTheBar;
        IsSeparateChart   = false;
        IsDiscreteValues  = false;
        IsDefaultGroupAll = false;
    }

    virtual void Calculate(DataSet &dataSet);
};

void StopLoss::Calculate(DataSet &dataSet)
{
    Data = GetPointer(dataSet);
}
