# SmartStock 📦
### Smart Inventory Management System for Microsoft Dynamics 365 Business Central

![Business Central](https://img.shields.io/badge/Dynamics_365-Business_Central_v26-blue?logo=microsoft)
![AL Language](https://img.shields.io/badge/Language-AL-teal)
![Runtime](https://img.shields.io/badge/Runtime-15.0-green)
![Target](https://img.shields.io/badge/Target-Cloud-orange)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

---

## 🌟 Overview
**SmartStock** is an intelligent, modern AL extension for **Microsoft Dynamics 365 Business Central**. It bridges the gap between basic out-of-the-box inventory management and complex Directed Put-Away / Pick WMS by providing:

* **Real-time Safety Stock & Reorder Triggers:** Dynamic minimum and maximum buffer thresholds per item.
* **Two-Tier Stock Adjustment Workflow:** Reason-coded adjustment documents with automated supervisor approval thresholds.
* **Audit-Safe Posting via Codeunit 22 (`Item Jnl.-Post Line`):** Strict financial and inventory ledger integrity without reinventing custom ledger tables.
* **Real-time KPI Activities Cues & Health Dashboard:** Interactive cues tracking low-stock items, pending approvals, and expiring lots.
* **Background Automated Alert Engine:** Job queue-ready monitoring (`SSK Stock Alert Mgt`) flagging breached thresholds and batch expirations.
* **Audit-Ready Printable Reports:** Integrated RDLC stock adjustment reports for documentation and regulatory audit trails.
* **Lot & Batch Expiry Tracking (FEFO):** Prevents stock spoilage and alerts managers to lots nearing expiration.
* **Role-Tailored Security & Permissions:** Pre-configured `SSK Admin` and `SSK Clerk` permission sets adhering to modern Business Central security models.

---

## 📂 Project Structure

```
d:\inventory management system\
│
├── .vscode/
│   ├── extensions.json       # Recommended VS Code / Antigravity extensions
│   ├── launch.json           # Cloud Sandbox debugger configurations
│   ├── ruleset.json          # CodeCop / PerTenantExtensionCop rules
│   └── settings.json         # AL formatter & CRS rules
│
├── src/
│   ├── Codeunits/
│   │   ├── SSKStockAdjustmentPost.Codeunit.al # Core posting engine
│   │   └── SSKStockAlertMgt.Codeunit.al       # Automated stock & expiry alert engine
│   │
│   ├── Enums/
│   │   ├── SSKAlertSeverity.Enum.al           # Info, Warning, Critical
│   │   ├── SSKDocumentStatus.Enum.al          # Draft, Pending, Approved, Posted
│   │   ├── SSKInventoryVelocity.Enum.al       # ABC velocity classifications
│   │   └── SSKStockMovementType.Enum.al       # Positive / Negative adjustments
│   │
│   ├── Pages/
│   │   ├── SSKActivitiesCue.Page.al           # Interactive Role Center activities cue
│   │   ├── SSKAdjustmentReasons.Page.al       # Reason code setup list
│   │   ├── SSKAlertLogList.Page.al            # Alert history & real-time scanner
│   │   ├── SSKItemCardExt.PageExt.al          # Item Card extensions
│   │   ├── SSKItemListExt.PageExt.al          # Item List extensions
│   │   ├── SSKLocationCardExt.PageExt.al      # Location Card extensions
│   │   ├── SSKLocationListExt.PageExt.al      # Location List extensions
│   │   ├── SSKSmartStockSetup.Page.al         # System configuration card
│   │   ├── SSKStockAdjList.Page.al            # Adjustment document overview
│   │   ├── SSKStockAdjSubform.Page.al         # Adjustment lines subform
│   │   └── SSKStockAdjustment.Page.al         # Main adjustment document card
│   │
│   ├── Permissions/
│   │   ├── SSKAdmin.PermissionSet.al          # Administrator permission set
│   │   └── SSKClerk.PermissionSet.al          # Floor clerk permission set
│   │
│   ├── Reports/
│   │   ├── SSKStockAdjustment.Report.al       # Printable stock adjustment document
│   │   └── SSKStockAdjustment.rdlc            # Standard RDLC report layout
│   │
│   └── Tables/
│       ├── SSKActivitiesCue.Table.al          # Role center KPI cue table
│       ├── SSKAdjustmentHeader.Table.al       # Adjustment document header
│       ├── SSKAdjustmentLine.Table.al         # Adjustment document lines
│       ├── SSKAdjustmentReason.Table.al       # Movement reason dictionary
│       ├── SSKAlertLog.Table.al               # Background alert audit log
│       ├── SSKItemExt.TableExt.al             # Item (Table 27) extension
│       ├── SSKLocationExt.TableExt.al         # Location (Table 14) extension
│       └── SSKSmartStockSetup.Table.al        # Configuration singleton table
│
├── .gitignore
├── app.json                                   # App manifest
└── README.md
```

---

## 🛠️ Key Architectural Patterns

1. **Zero Reinvention of Ledger Tables ("Golden Rule"):**
   * Standard Business Central `Item Ledger Entry` (Table 32) and `Value Entry` (Table 5802) remain the single source of truth for stock quantities and financial valuations.
   * All adjustments flow through `Codeunit 22 ("Item Jnl.-Post Line")`.

2. **Master-Detail Document Integrity:**
   * Adjustments cannot be deleted once submitted or approved.
   * Negative adjustments validate real-time available inventory at the target location.

3. **Full Security Compliance:**
   * Includes modern AL `permissionset` objects granting full CRUD and execution rights to authorized users while preventing unauthorized schema access.

4. **Location Restriction Guards:**
   * Locations can be flagged with `SSK Disallow Manual Adjust` to restrict manual stock changes, verified across header assignment, line entry, and the final posting pipeline.

---

## 🚀 Getting Started

### Prerequisites
* Microsoft Dynamics 365 Business Central Cloud Sandbox (v26+).
* Visual Studio Code or Antigravity IDE.
* AL Language extension for Microsoft Dynamics 365 Business Central (`ms-dynamics-smb.al`).

### Compilation
The project can be compiled directly using the AL compiler (`alc.exe`):
```powershell
alc.exe /project:"." /packagecachepath:".\.alpackages" /out:".\SmartStock.app"
```

### Publishing to Sandbox
1. Open the project folder in VS Code or Antigravity IDE.
2. Ensure your target environment is specified in `.vscode/launch.json`.
3. Press `F5` to start debugging or `Ctrl + F5` to run without debugging.

