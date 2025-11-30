import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class InvoiceService {
  Future<void> generateInvoice(Map<String, dynamic> billData, String billId) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    final amount = (billData['amount'] ?? 0).toDouble();
    final month = billData['month'] ?? 'Unknown';
    final paidAt = (billData['paidAt'] as dynamic)?.toDate() ?? DateTime.now();
    final invoiceNumber = 'INV-${billId.substring(0, 6).toUpperCase()}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Spring Valley', style: pw.TextStyle(font: boldFont, fontSize: 24, color: PdfColors.green800)),
                      pw.Text('Housing Society', style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE', style: pw.TextStyle(font: boldFont, fontSize: 20, color: PdfColors.black)),
                      pw.Text(invoiceNumber, style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Bill To
              pw.Text('Bill To:', style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey600)),
              pw.SizedBox(height: 4),
              pw.Text('Resident', style: pw.TextStyle(font: boldFont, fontSize: 14)), // Can add name if available
              pw.SizedBox(height: 20),

              // Details Table
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _buildRow('Description', 'Amount', isHeader: true, font: boldFont),
                    pw.Divider(color: PdfColors.grey300),
                    _buildRow('Maintenance Charges - $month', 'Rs. ${NumberFormat('#,##,###').format(amount)}', font: font),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Total Amount Paid', style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text('Rs. ${NumberFormat('#,##,###').format(amount)}', style: pw.TextStyle(font: boldFont, fontSize: 24, color: PdfColors.green800)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Footer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Paid on: ${DateFormat('dd MMM yyyy').format(paidAt)}', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600)),
                  pw.Text('Thank you for your payment!', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600)),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_$invoiceNumber',
    );
  }

  pw.Widget _buildRow(String label, String value, {bool isHeader = false, required pw.Font font}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: isHeader ? 12 : 14, color: isHeader ? PdfColors.grey600 : PdfColors.black)),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: isHeader ? 12 : 14, color: isHeader ? PdfColors.grey600 : PdfColors.black)),
        ],
      ),
    );
  }
}
