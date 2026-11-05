namespace SmartStock.Permissions;

using SmartStock.Codeunits;
using SmartStock.Pages;
using SmartStock.Tables;

permissionset 50101 "SSK Clerk"
{
    Caption = 'SmartStock Clerk / Operative';
    Assignable = true;

    Permissions =
        tabledata "SSK SmartStock Setup" = R,
        tabledata "SSK Adjustment Reason" = R,
        tabledata "SSK Adjustment Header" = RIMD,
        tabledata "SSK Adjustment Line" = RIMD,
        tabledata "SSK Activities Cue" = R,
        tabledata "SSK Alert Log" = RM,
        page "SSK SmartStock Setup" = X,
        page "SSK Adjustment Reasons" = X,
        page "SSK Stock Adjustment" = X,
        page "SSK Stock Adj. Subform" = X,
        page "SSK Stock Adj. List" = X,
        page "SSK Alert Log List" = X,
        codeunit "SSK Stock Adjustment Post" = X;
}

