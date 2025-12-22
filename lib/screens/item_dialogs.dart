
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../providers/items_provider.dart';
import '../models/item.dart';

// Assuming apiServiceProvider is available

class ItemDialogs {
  static void _showSnackbar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
                color: isError
                    ? Theme.of(context).colorScheme.onErrorContainer
                    : Theme.of(context).colorScheme.onPrimaryContainer,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: isError
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isError
              ? Theme.of(context).colorScheme.errorContainer
              : Theme.of(context).colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isError
                  ? Theme.of(context).colorScheme.error.withOpacity(0.3)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
  }

  // Unified Add/Edit Dialog
  static Future<void> showAddEditDialog(BuildContext context, WidgetRef ref, [Item? itemToEdit]) async {
    final isEditing = itemToEdit != null;
    final nameController = TextEditingController(text: itemToEdit?.name ?? '');
    final priceController = TextEditingController(
      text: isEditing ? itemToEdit!.price.toStringAsFixed(2) : '',
    );
    final api = ref.read(apiServiceProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 32,
                      spreadRadius: -4,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with gradient
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withOpacity(0.9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.onPrimary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isEditing ? Icons.edit_rounded : Icons.add_circle_rounded,
                              color: colorScheme.onPrimary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              isEditing ? 'Edit Item' : 'Add New Item',
                              style: textTheme.titleLarge?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Name field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Item Name',
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.9), // Increased contrast
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceVariant.withOpacity(0.4), // Increased opacity
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.outline.withOpacity(0.3), // Increased contrast
                                    width: 1.5,
                                  ),
                                ),
                                child: TextField(
                                  controller: nameController,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface, // Ensure text is visible
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter item name',
                                    hintStyle: textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.6), // Improved contrast
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.inventory_2_outlined,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Price field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price',
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.9), // Increased contrast
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceVariant.withOpacity(0.4), // Increased opacity
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.outline.withOpacity(0.3), // Increased contrast
                                    width: 1.5,
                                  ),
                                ),
                                child: TextField(
                                  controller: priceController,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface, // Ensure text is visible
                                  ),
                                  keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '0.00',
                                    hintStyle: textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.6), // Improved contrast
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.attach_money_rounded,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.3),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(
                                'Cancel',
                                style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.9), // Increased contrast
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: isLoading
                                ? Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            )
                                : FilledButton(
                              onPressed: () async {
                                final name = nameController.text.trim();
                                final priceText = priceController.text.trim();

                                if (name.isEmpty || priceText.isEmpty) {
                                  _showSnackbar(
                                      context,
                                      'Please fill in all fields',
                                      isError: true
                                  );
                                  return;
                                }

                                try {
                                  final price = double.parse(priceText);

                                  setState(() => isLoading = true);

                                  await Future.delayed(const Duration(milliseconds: 300)); // Smooth transition

                                  if (isEditing) {
                                    await api.updateItem(itemToEdit!.id, name, price);
                                    if (context.mounted) {
                                      _showSnackbar(context, '✅ Item updated successfully');
                                    }
                                  } else {
                                    await api.createItem(name, price);
                                    if (context.mounted) {
                                      _showSnackbar(context, '✅ Item added successfully');
                                    }
                                  }

                                  ref.refresh(itemsProvider);

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    setState(() => isLoading = false);
                                    _showSnackbar(
                                        context,
                                        '❌ Error: ${e.toString().replaceAll('Exception:', '').trim()}',
                                        isError: true
                                    );
                                  }
                                }
                              },
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isEditing ? Icons.check_circle_rounded : Icons.add_rounded,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isEditing ? 'Update' : 'Add',
                                    style: textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Delete Dialog
  static Future<void> showDeleteDialog(BuildContext context, WidgetRef ref, Item item) async {
    final api = ref.read(apiServiceProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 32,
                      spreadRadius: -4,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.error.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.delete_forever_rounded,
                              color: colorScheme.error,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Confirm Deletion',
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Are you sure you want to delete this item?',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.9), // Increased contrast
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant.withOpacity(0.4), // Increased opacity
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outline.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_rounded,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: textTheme.bodyLarge?.copyWith(
                                          color: colorScheme.onSurface, // Ensure visibility
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '\$${item.price.toStringAsFixed(2)}',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurface.withOpacity(0.8), // Increased contrast
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This action cannot be reversed.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.error.withOpacity(0.9), // Increased contrast
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.3),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(
                                'Cancel',
                                style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.9), // Increased contrast
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: isLoading
                                ? Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: colorScheme.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: colorScheme.error,
                                  ),
                                ),
                              ),
                            )
                                : FilledButton.icon(
                              onPressed: () async {
                                try {
                                  setState(() => isLoading = true);

                                  await Future.delayed(const Duration(milliseconds: 300)); // Smooth transition

                                  await api.deleteItem(item.id);
                                  ref.refresh(itemsProvider);

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    _showSnackbar(context, '✅ Item deleted successfully');
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    setState(() => isLoading = false);
                                    _showSnackbar(
                                        context,
                                        '❌ Error: ${e.toString().replaceAll('Exception:', '').trim()}',
                                        isError: true
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.delete_forever_rounded),
                              label: Text(
                                'Delete',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: colorScheme.error,
                                foregroundColor: colorScheme.onError,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}