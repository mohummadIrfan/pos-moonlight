import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../models/sales/sale_model.dart';
import '../utils/debug_helper.dart';

class PdfInvoiceService {
  static const String companyName = 'Moon Light Events';
  static const String companyAddress = '';
  static const List<String> companyPhones = ['03344891100', '03336461731'];

  /// Generate and save PDF invoice
  static Future<String> generateInvoicePdf(SaleModel sale) async {
    try {
      DebugHelper.printInfo('PdfInvoiceService', 'Generating PDF invoice for sale: ${sale.invoiceNumber}');

      // Create PDF document
      final pdf = pw.Document();

      // Load fonts (using default fonts for now, can be customized later)
      final regularFont = pw.Font.helvetica();
      final boldFont = pw.Font.helveticaBold();

      // Build PDF content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              _buildHeader(regularFont, boldFont),
              pw.SizedBox(height: 20),
              _buildInvoiceInfo(sale, regularFont, boldFont),
              pw.SizedBox(height: 20),
              _buildCustomerInfo(sale, regularFont, boldFont),
              pw.SizedBox(height: 20),
              _buildItemsTable(sale, regularFont, boldFont),
              pw.SizedBox(height: 20),
              _buildTotalsSection(sale, regularFont, boldFont),
              pw.SizedBox(height: 20),
              _buildFooter(regularFont, boldFont),
            ];
          },
        ),
      );

      // Save PDF to file
      final fileName = 'Invoice_${sale.invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      DebugHelper.printSuccess('PdfInvoiceService', 'PDF invoice saved to: $filePath');
      return filePath;
    } catch (e) {
      DebugHelper.printError('PdfInvoiceService', e);
      rethrow;
    }
  }

  /// Preview and print PDF invoice
  static Future<void> previewAndPrintInvoice(SaleModel sale) async {
    try {
      DebugHelper.printInfo('PdfInvoiceService', 'Opening PDF preview for sale: ${sale.invoiceNumber}');

      final pdf = pw.Document();

      // Load fonts
      final regularFont = pw.Font.helvetica();
      final boldFont = pw.Font.helveticaBold();

      // Build PDF content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              _buildHeader(regularFont, boldFont),
              pw.SizedBox(height: 20),
              _buildInvoiceInfo(sale, regularFont, boldFont),
              pw.SizedBox(height: 20),
              _buildCustomerInfo(sale, regularFont, boldFont),
              pw.SizedBox(height: 20),
              _buildItemsTable(sale, regularFont, boldFont),
              pw.SizedBox(height: 20),
              _buildTotalsSection(sale, regularFont, boldFont),
              pw.SizedBox(height: 20),
              _buildFooter(regularFont, boldFont),
            ];
          },
        ),
      );

      // Show print preview
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Invoice_${sale.invoiceNumber}',
      );
    } catch (e) {
      DebugHelper.printError('PdfInvoiceService', e);
      rethrow;
    }
  }

  /// Build header section
  static pw.Widget _buildHeader(pw.Font regularFont, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          companyName,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            font: boldFont,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Phone: ${companyPhones.join(' | ')}',
          style: pw.TextStyle(fontSize: 12, font: regularFont),
        ),
        pw.SizedBox(height: 12),
        pw.Divider(thickness: 2),
      ],
    );
  }

  /// Build invoice information section
  static pw.Widget _buildInvoiceInfo(SaleModel sale, pw.Font regularFont, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  font: boldFont,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Invoice #: ${sale.invoiceNumber}',
                style: pw.TextStyle(fontSize: 14, font: boldFont),
              ),
              pw.Text(
                'Date: ${DateFormat('dd MMM yyyy').format(sale.dateOfSale)}',
                style: pw.TextStyle(fontSize: 12, font: regularFont),
              ),
              pw.Text(
                'Time: ${DateFormat('hh:mm a').format(sale.dateOfSale)}',
                style: pw.TextStyle(fontSize: 12, font: regularFont),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _buildStatusBadge(sale.status, regularFont, boldFont),
              pw.SizedBox(height: 8),
              pw.Text(
                'Payment: ${sale.paymentMethodDisplay}',
                style: pw.TextStyle(fontSize: 12, font: regularFont),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build customer information section
  static pw.Widget _buildCustomerInfo(SaleModel sale, pw.Font regularFont, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Customer Information',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              font: boldFont,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Name: ${sale.customerName}',
                      style: pw.TextStyle(fontSize: 12, font: regularFont),
                    ),
                    if (sale.customerPhone.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Phone: ${sale.customerPhone}',
                        style: pw.TextStyle(fontSize: 12, font: regularFont),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build items table
  static pw.Widget _buildItemsTable(SaleModel sale, pw.Font regularFont, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Order Details',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            font: boldFont,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: {
            0: const pw.FixedColumnWidth(40),  // Sr#
            1: const pw.FlexColumnWidth(3),   // Product
            2: const pw.FixedColumnWidth(60), // Qty
            3: const pw.FixedColumnWidth(60), // Price
            4: const pw.FixedColumnWidth(60), // Total
          },
          children: [
            // Table header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableHeaderCell('Sr#', boldFont),
                _buildTableHeaderCell('Product', boldFont),
                _buildTableHeaderCell('Qty', boldFont),
                _buildTableHeaderCell('Price', boldFont),
                _buildTableHeaderCell('Total', boldFont),
              ],
            ),
            // Table rows
            ...sale.saleItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return pw.TableRow(
                children: [
                  _buildTableCell('${index + 1}'),
                  _buildTableCell(item.productName),
                  _buildTableCell('${item.quantity}'),
                  _buildTableCell('Rs.${item.unitPrice.toStringAsFixed(2)}'),
                  _buildTableCell('Rs.${item.lineTotal.toStringAsFixed(2)}'),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  /// Build totals section
  static pw.Widget _buildTotalsSection(SaleModel sale, pw.Font regularFont, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Subtotal:',
                style: pw.TextStyle(fontSize: 12, font: regularFont),
              ),
              pw.Text(
                'Rs.${sale.subtotal.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 12, font: regularFont),
              ),
            ],
          ),
          if (sale.overallDiscount > 0) ...[
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Discount:',
                  style: pw.TextStyle(fontSize: 12, font: regularFont),
                ),
                pw.Text(
                  '-Rs.${sale.overallDiscount.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont),
                ),
              ],
            ),
          ],
          if (sale.taxConfiguration.hasTaxes) ...[
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Tax (${sale.taxSummaryDisplay}):',
                  style: pw.TextStyle(fontSize: 12, font: regularFont),
                ),
                pw.Text(
                  'Rs.${sale.taxAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont),
                ),
              ],
            ),
          ],
          pw.SizedBox(height: 8),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Grand Total:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  font: boldFont,
                ),
              ),
              pw.Text(
                'Rs.${sale.grandTotal.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  font: boldFont,
                ),
              ),
            ],
          ),
          if (sale.amountPaid > 0) ...[
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Amount Paid:',
                  style: pw.TextStyle(fontSize: 12, font: regularFont),
                ),
                pw.Text(
                  'Rs.${sale.amountPaid.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 12, font: regularFont),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Balance Due:',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    font: boldFont,
                    color: sale.remainingAmount > 0 ? PdfColors.red800 : PdfColors.green800,
                  ),
                ),
                pw.Text(
                  'Rs.${sale.remainingAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    font: boldFont,
                    color: sale.remainingAmount > 0 ? PdfColors.red800 : PdfColors.green800,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build footer section
  static pw.Widget _buildFooter(pw.Font regularFont, pw.Font boldFont) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 12),
        pw.Center(
          child: pw.Text(
            'Thank you for your business!',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              font: boldFont,
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            'This is a computer-generated invoice and does not require a signature.',
            style: pw.TextStyle(fontSize: 10, font: regularFont),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            'Generated on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 10, font: regularFont),
          ),
        ),
      ],
    );
  }

  /// Build table cell
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  /// Build table header cell
  static pw.Widget _buildTableHeaderCell(String text, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          font: boldFont,
          fontSize: 12,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Build status badge
  static pw.Widget _buildStatusBadge(String status, pw.Font regularFont, pw.Font boldFont) {
    PdfColor badgeColor;
    String displayText;

    switch (status.toUpperCase()) {
      case 'PAID':
      case 'DELIVERED':
        badgeColor = PdfColors.green800;
        displayText = 'PAID';
        break;
      case 'PARTIAL':
      case 'PARTIALLY_PAID':
      case 'INVOICED':
        badgeColor = PdfColors.orange800;
        displayText = 'PARTIAL';
        break;
      case 'UNPAID':
      case 'SENT':
        badgeColor = PdfColors.red800;
        displayText = 'UNPAID';
        break;
      case 'ISSUED':
      case 'PENDING':
        badgeColor = PdfColors.blue800;
        displayText = 'PENDING';
        break;
      case 'CANCELLED':
        badgeColor = PdfColors.grey600;
        displayText = 'CANCELLED';
        break;
      default:
        badgeColor = PdfColors.grey600;
        displayText = status;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: badgeColor,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Text(
        displayText,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          font: boldFont,
        ),
      ),
    );
  }
}
