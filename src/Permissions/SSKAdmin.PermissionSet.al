namespace SmartStock.Permissions;

using SmartStock.Codeunits;
using SmartStock.Pages;
using SmartStock.Tables;

permissionset 50100 "SSK Admin"
{
    Caption = 'SmartStock Administrator';
    Assignable = true;

    Permissions =
        table "SSK SmartStock Setup" = X,
        tabledata "SSK SmartStock Setup" = RIMD,
        table "SSK Adjustment Reason" = X,
        tabledata "SSK Adjustment Reason" = RIMD,
        table "SSK Adjustment Header" = X,
        tabledata "SSK Adjustment Header" = RIMD,
        table "SSK Adjustment Line" = X,
        tabledata "SSK Adjustment Line" = RIMD,
        table "SSK Activities Cue" = X,
        tabledata "SSK Activities Cue" = RIMD,
        table "SSK Alert Log" = X,
        tabledata "SSK Alert Log" = RIMD,
        page "SSK SmartStock Setup" = X,
        page "SSK Adjustment Reasons" = X,
        page "SSK Stock Adjustment" = X,
        page "SSK Stock Adj. Subform" = X,
        page "SSK Stock Adj. List" = X,
        page "SSK Alert Log List" = X,
        codeunit "SSK Stock Adjustment Post" = X;
}

