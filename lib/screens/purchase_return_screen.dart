import 'package:flutter/material.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/models.dart';
import 'package:intl/intl.dart' as intl; // Import with prefix

import 'package:ipcam/widgets/custom_notification.dart';

class PurchaseReturnScreen extends StatefulWidget {
  const PurchaseReturnScreen({super.key});

  @override
  State<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> {
  List<PurchaseReturn> _purchaseReturns = [];
  List<PurchaseInvoice> _purchaseInvoices = [];
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper();
    final returnsMap = await db.getPurchaseReturns();
    final invoicesMap = await db.getPurchaseInvoices();
    final productsMap = await db.getProducts();
    setState(() {
      _purchaseReturns = returnsMap
          .map((e) => PurchaseReturn.fromMap(e))
          .toList();
      _purchaseInvoices = invoicesMap
          .map((e) => PurchaseInvoice.fromMap(e))
          .toList();
      _products = productsMap.map((e) => Product.fromMap(e)).toList();
    });
  }

  String _getInvoiceNumber(int invoiceId) {
    try {
      return _purchaseInvoices
          .firstWhere((invoice) => invoice.id == invoiceId)
          .invoiceNumber;
    } catch (e) {
      return 'فاتورة غير معروفة';
    }
  }

  String _getProductName(int productId) {
    try {
      return _products.firstWhere((product) => product.id == productId).name;
    } catch (e) {
      return 'منتج غير معروف';
    }
  }

  void _showPurchaseReturnForm({PurchaseReturn? purchaseReturn}) {
    showDialog(
      context: context,
      builder: (context) {
        return PurchaseReturnFormDialog(
          purchaseReturn: purchaseReturn,
          onSave: _loadData,
          purchaseInvoices: _purchaseInvoices,
          products: _products,
        );
      },
    );
  }

  void _performDeletePurchaseReturn(int id) async {
    await DatabaseHelper().deletePurchaseReturn(id);
    _loadData();
    if (mounted) {
      CustomNotificationOverlay.show(
        context,
        'تم حذف مرتجع الشراء بنجاح!',
        backgroundColor: Colors.red,
      );
    }
  }

  void _confirmDelete(int id, String productName, int quantity) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد أنك تريد حذف مرتجع الشراء لـ $quantity من $productName؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                _performDeletePurchaseReturn(id);
                Navigator.pop(context);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مرتجعات الشراء'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _purchaseReturns.isEmpty
          ? const Center(child: Text('لم يتم العثور على مرتجعات شراء.'))
          : ListView.builder(
              itemCount: _purchaseReturns.length,
              itemBuilder: (context, index) {
                final pr = _purchaseReturns[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    title: Text(
                      'المنتج: ${_getProductName(pr.productId)} | الكمية: ${pr.quantity}',
                    ),
                    subtitle: Text(
                      'الفاتورة: ${_getInvoiceNumber(pr.purchaseInvoiceId)} | التاريخ: ' +
                          intl.DateFormat.yMd().format(
                            DateTime.parse(pr.returnDate),
                          ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () =>
                              _showPurchaseReturnForm(purchaseReturn: pr),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _confirmDelete(pr.id!, _getProductName(pr.productId), pr.quantity),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPurchaseReturnForm(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class PurchaseReturnFormDialog extends StatefulWidget {
  final PurchaseReturn? purchaseReturn;
  final VoidCallback onSave;
  final List<PurchaseInvoice> purchaseInvoices;
  final List<Product> products;

  const PurchaseReturnFormDialog({
    super.key,
    this.purchaseReturn,
    required this.onSave,
    required this.purchaseInvoices,
    required this.products,
  });

  @override
  State<PurchaseReturnFormDialog> createState() =>
      _PurchaseReturnFormDialogState();
}

class _PurchaseReturnFormDialogState extends State<PurchaseReturnFormDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _purchaseInvoiceId;
  int? _productId;
  late int _quantity;
  late String _returnDate;
  String? _reason;

  @override
  void initState() {
    super.initState();
    if (widget.purchaseReturn != null) {
      _purchaseInvoiceId = widget.purchaseReturn!.purchaseInvoiceId;
      _productId = widget.purchaseReturn!.productId;
      _quantity = widget.purchaseReturn!.quantity;
      _returnDate = widget.purchaseReturn!.returnDate;
      _reason = widget.purchaseReturn!.reason;
    } else {
      _purchaseInvoiceId = null;
      _productId = null;
      _quantity = 1;
      _returnDate = DateTime.now().toIso8601String();
      _reason = '';
    }
  }

  void _savePurchaseReturn() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final db = DatabaseHelper();

      final purchaseReturn = PurchaseReturn(
        id: widget.purchaseReturn?.id,
        purchaseInvoiceId: _purchaseInvoiceId!,
        productId: _productId!,
        quantity: _quantity,
        returnDate: _returnDate,
        reason: _reason,
      );

      if (purchaseReturn.id == null) {
        await db.insertPurchaseReturn(purchaseReturn.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(
            context,
            'تم إضافة مرتجع الشراء بنجاح!',
          );
        }
      } else {
        await db.updatePurchaseReturn(purchaseReturn.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(
            context,
            'تم تعديل مرتجع الشراء بنجاح!',
          );
        }
      }
      widget.onSave();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.purchaseReturn == null
            ? 'إضافة مرتجع شراء'
            : 'تعديل مرتجع شراء',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonFormField<int?>(
                initialValue: _purchaseInvoiceId,
                decoration: const InputDecoration(
                  labelText: 'فاتورة الشراء',
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('اختر الفاتورة'),
                  ),
                  ...widget.purchaseInvoices.map(
                    (invoice) => DropdownMenuItem(
                      value: invoice.id,
                      child: Text(invoice.invoiceNumber),
                    ),
                  ),
                ],
                validator: (value) {
                  if (value == null) {
                    return 'الرجاء اختيار فاتورة';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _purchaseInvoiceId = value;
                  });
                },
                onSaved: (value) => _purchaseInvoiceId = value,
              ),
              DropdownButtonFormField<int?>(
                initialValue: _productId,
                decoration: const InputDecoration(labelText: 'المنتج'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('اختر المنتج'),
                  ),
                  ...widget.products.map(
                    (product) => DropdownMenuItem(
                      value: product.id,
                      child: Text(product.name),
                    ),
                  ),
                ],
                validator: (value) {
                  if (value == null) {
                    return 'الرجاء اختيار منتج';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _productId = value;
                  });
                },
                onSaved: (value) => _productId = value,
              ),
              TextFormField(
                initialValue: _quantity.toString(),
                decoration: const InputDecoration(labelText: 'الكمية'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الكمية';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'الرجاء إدخال عدد صحيح موجب';
                  }
                  return null;
                },
                onSaved: (value) => _quantity = int.parse(value!),
              ),
              TextFormField(
                initialValue: _reason,
                decoration: const InputDecoration(
                  labelText: 'السبب (اختياري)',
                ),
                maxLines: 2,
                onSaved: (value) => _reason = value,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _savePurchaseReturn,
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
