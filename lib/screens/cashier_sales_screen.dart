import 'package:flutter/material.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/models.dart';
import 'dart:io';
import 'package:ipcam/widgets/custom_notification.dart';

class CashierSalesScreen extends StatefulWidget {
  const CashierSalesScreen({super.key});

  @override
  State<CashierSalesScreen> createState() => _CashierSalesScreenState();
}

class _CashierSalesScreenState extends State<CashierSalesScreen> {
  List<Product> _availableProducts = [];
  List<Product> _filteredProducts = [];
  List<SaleInvoiceDetail> _currentSaleDetails = [];
  final TextEditingController _searchController = TextEditingController();
  double _totalAmount = 0.0;
  double _paidAmount = 0.0;
  double _remainingAmount = 0.0;

  String _getProductName(int productId) {
    try {
      return _availableProducts.firstWhere((product) => product.id == productId).name;
    } catch (e) {
      return 'منتج غير معروف';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final db = DatabaseHelper();
    final productsMap = await db.getProducts();
    setState(() {
      _availableProducts = productsMap.map((e) => Product.fromMap(e)).toList();
      _filteredProducts = _availableProducts;
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _availableProducts.where((product) {
        return product.name.toLowerCase().contains(query) ||
            (product.barcode != null &&
                product.barcode!.toLowerCase().contains(query)) ||
            product.productCode.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _addProductToSale(Product product) {
    setState(() {
      int existingIndex = _currentSaleDetails.indexWhere(
        (detail) => detail.productId == product.id,
      );
      if (existingIndex != -1) {
        _currentSaleDetails[existingIndex].quantity++;
      } else {
        _currentSaleDetails.add(
          SaleInvoiceDetail(
            productId: product.id!,
            quantity: 1,
            salePrice: product.salePrice1, // Default to sale price 1
            saleInvoiceId:
                0, // Placeholder, will be updated when saving invoice
          ),
        );
      }
      _calculateTotals();
    });
  }

  void _removeProductFromSale(SaleInvoiceDetail detail) {
    setState(() {
      if (detail.quantity > 1) {
        detail.quantity--;
      } else {
        _currentSaleDetails.remove(detail);
      }
      _calculateTotals();
    });
  }

  void _clearSale() {
    setState(() {
      _currentSaleDetails.clear();
      _totalAmount = 0.0;
      _paidAmount = 0.0;
      _remainingAmount = 0.0;
    });
  }

  void _calculateTotals() {
    _totalAmount = _currentSaleDetails.fold(
      0.0,
      (sum, item) => sum + (item.quantity * item.salePrice),
    );
    _remainingAmount = _totalAmount - _paidAmount;
  }

  Future<void> _finalizeSale() async {
    if (_currentSaleDetails.isEmpty) {
      CustomNotificationOverlay.show(
        context,
        'الرجاء إضافة منتجات إلى الفاتورة أولاً.',
        backgroundColor: Colors.red,
      );
      return;
    }

    final db = DatabaseHelper();
    // Create SaleInvoice
    final newSaleInvoice = SaleInvoice(
      invoiceNumber: DateTime.now().millisecondsSinceEpoch
          .toString(), // Unique invoice number
      invoiceDate: DateTime.now().toIso8601String(),
      totalAmount: _totalAmount,
      paidAmount: _paidAmount,
      remainingAmount: _remainingAmount,
    );
    final invoiceId = await db.insertSaleInvoice(newSaleInvoice.toMap());

    // Insert SaleInvoiceDetails and update product quantities
    for (var detail in _currentSaleDetails) {
      detail.saleInvoiceId = invoiceId;
      await db.insertSaleInvoiceDetail(detail.toMap());
    }

    _clearSale();
    if (mounted) {
      CustomNotificationOverlay.show(
        context,
        'تم إنهاء عملية البيع بنجاح!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة مبيعات الكاشير'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'البحث عن منتجات (الاسم، الباركود، الرمز)',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.8,
              ),
              padding: const EdgeInsets.all(8.0),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return GestureDetector(
                  onTap: () => _addProductToSale(product),
                  child: Card(
                    elevation: 3,
                    child: Column(
                      children: [
                        Expanded(
                          child:
                              product.imageUrl != null &&
                                  File(product.imageUrl!).existsSync()
                              ? Image.file(
                                  File(product.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          'السعر: د.ل${product.salePrice1.toStringAsFixed(2)}',
                        ),
                        Text('المخزون: ${product.quantityInStock}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'الفاتورة الحالية:',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 8.0),
                _currentSaleDetails.isEmpty
                    ? const Text('لا توجد عناصر في الفاتورة.')
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _currentSaleDetails.length,
                        itemBuilder: (context, index) {
                          final detail = _currentSaleDetails[index];
                          final product = _availableProducts.firstWhere(
                            (p) => p.id == detail.productId,
                          );
                          return ListTile(
                            title: Text('${product.name} x ${detail.quantity}'),
                            subtitle: Text(
                              'السعر: د.ل${detail.salePrice.toStringAsFixed(2)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () =>
                                      _removeProductFromSale(detail),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  onPressed: () => _addProductToSale(product),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 16.0),
                Text(
                  'الإجمالي: د.ل${_totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'المبلغ المدفوع'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _paidAmount = double.tryParse(value) ?? 0.0;
                      _calculateTotals();
                    });
                  },
                ),
                Text(
                  'المتبقي: د.ل${_remainingAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _clearSale,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.errorContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onErrorContainer,
                      ),
                      child: const Text('مسح الفاتورة'),
                    ),
                    ElevatedButton(
                      onPressed: _finalizeSale,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                      ),
                      child: const Text('إنهاء الفاتورة'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
