import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../l10n/app_localizations.dart';
import '../../../src/models/purchase_model.dart';
import '../../../src/providers/purchase_provider.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/utils/responsive_breakpoints.dart';
import '../globals/text_button.dart';

class DeletePurchaseDialog extends StatelessWidget {
  final PurchaseModel purchase;

  const DeletePurchaseDialog({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.borderRadius('large')),
      ),
      backgroundColor: AppTheme.creamWhite,
      child: Container(
        width: 35.w,
        padding: EdgeInsets.all(context.mainPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon
            Container(
              padding: EdgeInsets.all(context.cardPadding),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_forever_rounded,
                color: Colors.red.shade700,
                size: context.iconSize('large'),
              ),
            ),
            SizedBox(height: context.mainPadding),

            // Title
            Text(
              l10n.deletePurchase ?? "Delete Purchase",
              style: TextStyle(
                fontSize: context.headerFontSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.charcoalGray,
              ),
            ),
            SizedBox(height: context.smallPadding),

            // Confirmation message
            Text(
              "Are you sure you want to delete invoice #${purchase.invoiceNumber}?\n\nThis action cannot be undone and will permanently remove this purchase record.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.bodyFontSize,
                color: AppTheme.charcoalGray,
              ),
            ),
            SizedBox(height: context.mainPadding),

            // Invoice details preview
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.mainPadding),
              decoration: BoxDecoration(
                color: AppTheme.primaryMaroon.withOpacity(0.05),
                borderRadius: BorderRadius.circular(context.borderRadius('small')),
                border: Border.all(color: AppTheme.primaryMaroon.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow("Invoice #", purchase.invoiceNumber),
                  SizedBox(height: context.smallPadding / 2),
                  _infoRow("Vendor", purchase.vendorDetail?.name ?? "N/A"),
                  SizedBox(height: context.smallPadding / 2),
                  _infoRow("Total", "Rs. ${purchase.total.toStringAsFixed(2)}"),
                ],
              ),
            ),

            SizedBox(height: context.mainPadding),

            // Warning text
            Text(
              "⚠️ This action is permanent",
              style: TextStyle(
                fontSize: context.captionFontSize,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: context.mainPadding),

            // Action Buttons - FIXED ✅
            Consumer<PurchaseProvider>(
              builder: (context, provider, child) {
                return Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: PremiumButton(
                        text: l10n.cancel ?? "Cancel",
                        onPressed: () => Navigator.pop(context),
                        isOutlined: true,
                        backgroundColor: AppTheme.charcoalGray,
                        height: 45,
                      ),
                    ),
                    SizedBox(width: context.smallPadding),

                    // Delete Button - FIXED ✅
                    Expanded(
                      child: PremiumButton(
                        text: "Delete Purchase",
                        isLoading: provider.isLoading,
                        onPressed: provider.isLoading
                            ? null
                            : () => _handleDelete(context, provider),
                        backgroundColor: Colors.red.shade600,
                        height: 45,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Delete handler - FIXED ✅
  void _handleDelete(BuildContext context, PurchaseProvider provider) async {
    if (purchase.id == null || purchase.id!.isEmpty) {
      _showError(context, "Cannot delete: Invalid purchase ID");
      return;
    }

    final success = await provider.deletePurchase(purchase.id!);

    if (!context.mounted) return;

    Navigator.pop(context); // Close dialog first
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label:",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalGray,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $message"),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }
}
