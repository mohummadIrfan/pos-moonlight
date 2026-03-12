import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../l10n/app_localizations.dart';
import '../../../src/models/purchase_model.dart';
import '../../../src/providers/vendor_provider.dart';
import '../../../src/providers/product_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/utils/responsive_breakpoints.dart';
import '../globals/text_button.dart';
import 'purchase_table_helpers.dart';

class ViewPurchaseDetailsDialog extends StatelessWidget {
  final PurchaseModel purchase;

  const ViewPurchaseDetailsDialog({super.key, required this.purchase});

  /// Helper to robustly get the Vendor Name with Localization
  String _getVendorName(BuildContext context, AppLocalizations l10n) {
    // 1. Try direct name field (from model)
    if (purchase.vendorName != null && purchase.vendorName!.isNotEmpty) {
      return purchase.vendorName!;
    }

    // 2. Try nested object
    if (purchase.vendorDetail?.name != null) {
      return purchase.vendorDetail!.name;
    }

    // 3. Last resort: Lookup in Provider using ID
    if (purchase.vendor != null) {
      try {
        final vendorProvider = context.read<VendorProvider>();
        final foundVendor = vendorProvider.vendors.firstWhere(
              (v) => v.id == purchase.vendor,
        );
        // If found, return its name
        return foundVendor.name;
      } catch (e) {
        // Not found in the list (e.g. pagination or not loaded)
      }
    }

    return l10n.unknownVendor ?? "Unknown Vendor";
  }

  /// Helper to get Product Name robustly with Localization
  String _getProductName(BuildContext context, PurchaseItemModel item, AppLocalizations l10n) {
    // 1. Try nested detail
    if (item.productDetail?.name != null) {
      return item.productDetail!.name;
    }

    // 2. Try Lookup in Provider
    if (item.product != null) {
      try {
        final productProvider = context.read<ProductProvider>();
        final foundProduct = productProvider.products.firstWhere(
              (p) => p.id == item.product,
        );
        return foundProduct.name;
      } catch (e) {
        // Not found
      }
    }

    // 3. Fallback to ID or generic text
    return item.product ?? (l10n.unknownProduct ?? "Unknown Product");
  }

  @override
  Widget build(BuildContext context) {
    // Ensure l10n is not null
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.borderRadius('large')),
      ),
      backgroundColor: AppTheme.creamWhite,
      child: Container(
        width: 60.w, // Desktop-optimized fixed width
        constraints: BoxConstraints(maxHeight: 85.h),
        padding: EdgeInsets.all(context.mainPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            _buildHeader(context, l10n),
            const Divider(height: 32),

            // Content Section (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetaInfo(context, l10n),
                    SizedBox(height: context.mainPadding),
                    _buildItemsTable(context, l10n),
                  ],
                ),
              ),
            ),

            // Footer Section (Totals)
            const Divider(height: 32),
            _buildTotalsSection(context, l10n),

            SizedBox(height: context.mainPadding),
            _buildActionButtons(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(context.smallPadding),
          decoration: BoxDecoration(
            color: AppTheme.primaryMaroon.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            color: AppTheme.primaryMaroon,
            size: context.iconSize('medium'),
          ),
        ),
        SizedBox(width: context.smallPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.purchaseDetails ?? "Purchase Details",
                style: TextStyle(
                  fontSize: context.headerFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.charcoalGray,
                ),
              ),
              // Invoice number removed as per request
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  Widget _buildMetaInfo(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(context.mainPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius('small')),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Vendor Name (Safe Lookup)
          _infoColumn(l10n.vendor ?? "Vendor", _getVendorName(context, l10n)),

          // Date
          _infoColumn(l10n.date ?? "Date", PurchaseTableHelpers.formatDate(purchase.purchaseDate)),

          // Status removed as per request
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.charcoalGray)),
      ],
    );
  }

  Widget _buildItemsTable(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: context.smallPadding),
          child: Text(
            l10n.purchasedItems ?? "Purchased Items",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: AppTheme.primaryMaroon.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                children: [
                  _tableHeader(l10n.product),
                  _tableHeader(l10n.quantity, align: TextAlign.center),
                  _tableHeader(l10n.unitCost, align: TextAlign.right),
                  _tableHeader(l10n.total, align: TextAlign.right),
                ],
              ),
              ...purchase.items.map((item) => TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                ),
                children: [
                  // Product Name (Safe Lookup)
                  _tableCell(_getProductName(context, item, l10n)),
                  _tableCell(item.quantity.toStringAsFixed(0), align: TextAlign.center),
                  _tableCell(item.unitCost.toStringAsFixed(2), align: TextAlign.right),
                  _tableCell(item.totalPrice.toStringAsFixed(2), isBold: true, align: TextAlign.right),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tableHeader(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
        textAlign: align,
      ),
    );
  }

  Widget _tableCell(String text, {bool isBold = false, TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: isBold ? AppTheme.primaryMaroon : AppTheme.charcoalGray,
        ),
        textAlign: align,
      ),
    );
  }

  Widget _buildTotalsSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // Only showing Total as Subtotal and Tax are simplified/hidden
        _totalRow(l10n.grandTotal ?? "Grand Total", purchase.total, isMain: true),
      ],
    );
  }

  Widget _totalRow(String label, double amount, {bool isMain = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
            fontSize: isMain ? 16 : 14,
            color: isMain ? AppTheme.charcoalGray : Colors.grey[600],
          ),
        ),
        Text(
          NumberFormat.currency(symbol: '', decimalDigits: 2).format(amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isMain ? AppTheme.primaryMaroon : AppTheme.charcoalGray,
            fontSize: isMain ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PremiumButton(
          text: l10n.printInvoice ?? "Print Invoice",
          onPressed: () {
            // Print logic implementation
          },
          icon: Icons.print_rounded,
          isOutlined: true,
          width: 160,
          height: 45,
        ),
        SizedBox(width: context.mainPadding),
        PremiumButton(
          text: l10n.close ?? "Close",
          onPressed: () => Navigator.pop(context),
          width: 120,
          height: 45,
          backgroundColor: AppTheme.primaryMaroon,
        ),
      ],
    );
  }
}