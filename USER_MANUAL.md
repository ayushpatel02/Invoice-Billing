# Invoice Billing App — User Manual

**Version 1.0**

---

## Table of Contents

1. [Getting Started](#1-getting-started)
2. [Setting Up Your Business Profile](#2-setting-up-your-business-profile)
3. [Managing Customers](#3-managing-customers)
4. [Creating an Invoice](#4-creating-an-invoice)
5. [Recording Payments](#5-recording-payments)
6. [Downloading & Sharing PDF Invoices](#6-downloading--sharing-pdf-invoices)
7. [Tax Settings (CGST & SGST)](#7-tax-settings-cgst--sgst)
8. [Backup & Restore Your Data](#8-backup--restore-your-data)
9. [Tips & Frequently Asked Questions](#9-tips--frequently-asked-questions)

---

## 1. Getting Started

When you open the app for the very first time, you will be taken to the **Business Profile Setup** screen. This is a one-time step — you only need to fill it in once.

After setup, every time you open the app you will land directly on the **Customers** screen where all your work happens.

---

## 2. Setting Up Your Business Profile

Your business profile appears on every invoice you generate. Keep it accurate.

### How to fill in the profile

1. Enter your **First Name** and **Last Name** (required).
2. Middle Name is optional.
3. Fill in your **Address** (up to 3 lines), City, District, State, Country, and Pin Code.
4. Add your **Phone Number** and **Email** (used for contact details on the invoice).
5. Tap the **circle at the top** to add your company logo. Your phone's photo gallery will open — pick your logo image.
6. Tap **Save** in the top-right corner.

### Editing the profile later

- Open the side menu (tap the ☰ icon in the top-left).
- Tap **Business Profile**.
- Make your changes and tap **Save**.

---

## 3. Managing Customers

The home screen shows a list of all your customers. Each customer card shows:
- Customer name
- Phone number
- **Outstanding balance** (red = money owed, green "Settled" = fully paid)

### Adding a new customer

1. Tap the **+** (plus) button in the bottom-right corner.
2. Fill in the customer's name, address, phone, and email.
3. Tap **Save**.

### Editing a customer

- Tap the **edit icon** (pencil) on the right side of the customer card.
- Make your changes and tap **Save**.

### Deleting a customer

- **Swipe the customer card to the left.**
- A red "Delete" area will appear.
- A confirmation dialog will ask: **"Delete [Name]? All invoices and payments will be removed."**
- Tap **Delete** to confirm, or **Cancel** to keep the customer.

> ⚠️ Deleting a customer permanently removes all their invoices and payments. This cannot be undone.

### Viewing a customer's invoices

- Tap anywhere on the customer card (not the edit icon) to open their invoice list.

---

## 4. Creating an Invoice

### Opening the invoice list

Tap a customer card to see all their invoices, organised into three tabs:
- **Unpaid** — invoices with no payment yet
- **Partially Paid** — invoices with some payment made
- **Fully Paid** — invoices completely settled

### Creating a new invoice

1. From the invoice list, tap the **+** (plus) button.
2. The **Invoice Number** is filled in automatically (per customer sequence).
3. The **Date** defaults to today. Tap it to change.
4. **Tax Rates** (CGST % and SGST %) are loaded from your settings automatically.

### Adding line items

Each line item represents one product or service.

| Field | Required? | Description |
|-------|-----------|-------------|
| Description | **Yes** | What you are billing for |
| Qty | **Yes** | Quantity |
| Rate (₹) | **Yes** | Price per unit |
| Amount | Auto | Calculated as Qty × Rate |
| MM | No | Millimetres (optional measurement) |
| H | No | Height (optional measurement) |
| W | No | Width (optional measurement) |
| Nos | No | Number of pieces (optional) |

- Tap **+ Add Item** to add more rows.
- Tap the **trash icon** on any row to remove it.
- The **Subtotal, CGST, SGST, and Net Payable** update live as you type.

### Saving the invoice

- Tap **Save Invoice** at the bottom.
- The invoice is created and you will return to the invoice list.

### Editing an invoice

- Only **Unpaid** invoices can be edited.
- Once any payment has been made, the invoice is locked (no edit button).
- To edit an unpaid invoice, tap the **pencil icon** on the invoice card.

### Deleting an invoice

- **Swipe the invoice card to the left** (works on Unpaid, Partially Paid, and Fully Paid tabs).
- A red "Delete" area will appear.
- A confirmation dialog will ask you to confirm before deleting.
- Tap **Delete** to confirm, or **Cancel** to keep the invoice.

> ⚠️ Deleting an invoice permanently removes it and all its payment records. This cannot be undone.

---

## 5. Recording Payments

### Opening the payment dialog

1. From the invoice list, tap any invoice card to open the **Invoice Detail** screen.
2. Tap **Record Payment** at the bottom.

### Entering payment details

- **Payment Amount**: Enter the amount received. It cannot exceed the remaining balance.
- **Payment Date**: Defaults to today. Tap to change the date.
- Tap **Save Payment**.

The invoice status will automatically change:
- First payment → **Partially Paid**
- Payment covers full balance → **Fully Paid**

### Mark as Fully Paid (write off balance)

If a customer pays in full but there is a small remaining balance you wish to forgive:

1. Open the Invoice Detail screen.
2. Tap **Mark as Fully Paid**.
3. Confirm in the dialog.

The remaining balance is written off and the invoice moves to Fully Paid.

### Payment History

The Invoice Detail screen shows a **Payment History** section listing every payment made, with the date and amount.

---

## 6. Downloading & Sharing PDF Invoices

### From the invoice list

- Tap the **PDF icon** on any invoice card.

### From the invoice detail screen

- Tap the **PDF icon** in the top-right corner of the screen.

### What happens next

Your phone's share/print dialog opens. You can:
- **Download** the PDF to your phone
- **Share** it via WhatsApp, Email, or any other app
- **Print** it if a printer is connected

### What the PDF includes

- Your business name, address, and logo
- Customer name and address
- Invoice number and date
- Full line items table (MM/H/W/Nos columns are only shown if they have data)
- Subtotal, CGST, SGST, Net Payable
- Amount in words (e.g., "Five Thousand Rupees Only")
- Payment received and balance due (if applicable)
- Terms & Conditions
- Signature area for both parties

---

## 7. Tax Settings (CGST & SGST)

### Changing tax rates

1. Open the side menu (☰ icon).
2. Tap **Settings**.
3. Enter your CGST % and SGST % rates.
4. Tap **Save Settings**.

### Important notes on tax

- Tax rates are **locked into each invoice at the time of creation**. Changing the settings later will not affect existing invoices.
- New invoices will use the new rates going forward.
- If your business is not registered for GST, set both rates to **0**.

---

## 8. Backup & Restore Your Data

All data is stored locally on your device. Use the export/import feature to back up your data or move it to a new phone.

### Exporting (creating a backup)

1. Go to **Settings** (side menu → Settings).
2. Tap **Export Data**.
3. A JSON backup file will be shared from your device. Save it to Google Drive, email it to yourself, or store it anywhere safe.

### Importing (restoring a backup)

> ⚠️ **Warning:** Importing will replace ALL current data on the device. Make sure to export first if you want to keep your existing data.

1. Go to **Settings**.
2. Tap **Import Data**.
3. Confirm the warning dialog.
4. Select the backup JSON file from your phone storage.
5. All customers, invoices, and payments will be restored.

---

## 9. Tips & Frequently Asked Questions

**Q: Can I have the same invoice number for different customers?**
Yes. Invoice numbers are per customer. Each customer starts from #1 and counts up independently.

**Q: Can I delete an invoice?**
Yes. Open the customer's invoice list, then swipe the invoice card to the left and confirm. This works on any tab (Unpaid, Partially Paid, Fully Paid). Deleting a customer also removes all of their invoices automatically.

**Q: The PDF shows the wrong business name. How do I fix it?**
Go to side menu → Business Profile → edit your name → Save. New PDFs will use the updated name.

**Q: I changed the CGST rate in Settings but my old invoices show the old rate.**
This is correct behaviour. Tax rates are saved at the time the invoice is created and will never change on old invoices.

**Q: The app is showing the wrong outstanding balance for a customer.**
Pull down to refresh the customer list (swipe down from the top of the screen). The balance will recalculate.

**Q: How do I add multiple payments for one invoice?**
You can record as many payments as you like. Go to Invoice Detail → Record Payment. Each payment is logged in the Payment History section.

**Q: Can I use this app without GST?**
Yes. Set CGST and SGST rates to 0 in Settings. No tax lines will appear on the invoice or PDF.

**Q: How do I share an invoice over WhatsApp?**
Tap the PDF icon on any invoice → your phone's share dialog opens → choose WhatsApp → select the contact.

---

*For technical support or feedback, contact your app provider.*
