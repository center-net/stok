import 'package:flutter/material.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/models.dart';
import 'package:intl/intl.dart' as intl; // Import with prefix

import 'package:ipcam/widgets/custom_notification.dart';

class SaleReturnScreen extends StatefulWidget {
  const SaleReturnScreen({super.key});

  @override
  State<SaleReturnScreen> createState() => _SaleReturnScreenState();
}

class _SaleReturnScreenState extends State<SaleReturnScreen> {
  List<SaleReturn> _saleReturns = [];
  List<SaleInvoice> _saleInvoices = [];
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper();
    final returnsMap = await db.getSaleReturns();
    final invoicesMap = await db.getSaleInvoices();
    final productsMap = await db.getProducts();
    setState(() {
      _saleReturns = returnsMap.map((e) => SaleReturn.fromMap(e)).toList();
      _saleInvoices = invoicesMap.map((e) => SaleInvoice.fromMap(e)).toList();
      _products = productsMap.map((e) => Product.fromMap(e)).toList();
    });
  }

  String _getInvoiceNumber(int invoiceId) {
    try {
      return _saleInvoices
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

  void _showSaleReturnForm({SaleReturn? saleReturn}) {
    showDialog(
      context: context,
      builder: (context) {
        return SaleReturnFormDialog(
          saleReturn: saleReturn,
          onSave: _loadData,
          saleInvoices: _saleInvoices,
          products: _products,
        );
      },
    );
  }

  void _performDeleteSaleReturn(int id) async {
    await DatabaseHelper().deleteSaleReturn(id);
    _loadData();
    if (mounted) {
      CustomNotificationOverlay.show(
        context,
        'تم حذف مرتجع البيع بنجاح!',
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
          content: Text(
            'هل أنت متأكد أنك تريد حذف مرتجع البيع لـ $quantity من $productName؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                _performDeleteSaleReturn(id);
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
        title: const Text(
          'مرتجعات البيع',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: _saleReturns.isEmpty
          ? const Center(child: Text('لم يتم العثور على مرتجعات بيع.'))
          : ListView.builder(
              itemCount: _saleReturns.length,
              itemBuilder: (context, index) {
                final sr = _saleReturns[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    title: Text(
                      'المنتج: ${_getProductName(sr.productId)} | الكمية: ${sr.quantity}',
                    ),
                    subtitle: Text(
                      'الفاتورة: ${_getInvoiceNumber(sr.saleInvoiceId)} | التاريخ: ' +
                          intl.DateFormat.yMd().format(
                            DateTime.parse(sr.returnDate),
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
                          onPressed: () => _showSaleReturnForm(saleReturn: sr),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _confirmDelete(
                            sr.id!,
                            _getProductName(sr.productId),
                            sr.quantity,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSaleReturnForm(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class SaleReturnFormDialog extends StatefulWidget {
  final SaleReturn? saleReturn;
  final VoidCallback onSave;
  final List<SaleInvoice> saleInvoices;
  final List<Product> products;

  const SaleReturnFormDialog({
    super.key,
    this.saleReturn,
    required this.onSave,
    required this.saleInvoices,
    required this.products,
  });

  @override
  State<SaleReturnFormDialog> createState() => _SaleReturnFormDialogState();
}

class _SaleReturnFormDialogState extends State<SaleReturnFormDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _saleInvoiceId;
  int? _productId;
  late int _quantity;
  late String _returnDate;
  String? _reason;

  @override
  void initState() {
    super.initState();
    if (widget.saleReturn != null) {
      _saleInvoiceId = widget.saleReturn!.saleInvoiceId;
      _productId = widget.saleReturn!.productId;
      _quantity = widget.saleReturn!.quantity;
      _returnDate = widget.saleReturn!.returnDate;
      _reason = widget.saleReturn!.reason;
    } else {
      _saleInvoiceId = null;
      _productId = null;
      _quantity = 1;
      _returnDate = DateTime.now().toIso8601String();
      _reason = '';
    }
  }

  void _saveSaleReturn() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final db = DatabaseHelper();

      final saleReturn = SaleReturn(
        id: widget.saleReturn?.id,
        saleInvoiceId: _saleInvoiceId!,
        productId: _productId!,
        quantity: _quantity,
        returnDate: _returnDate,
        reason: _reason,
      );

      if (saleReturn.id == null) {
        await db.insertSaleReturn(saleReturn.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(
            context,
            'تم إضافة مرتجع البيع بنجاح!',
          );
        }
      } else {
        await db.updateSaleReturn(saleReturn.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(
            context,
            'تم تعديل مرتجع البيع بنجاح!',
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
        widget.saleReturn == null ? 'إضافة مرتجع بيع' : 'تعديل مرتجع بيع',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonFormField<int?>(
                value: _saleInvoiceId,
                decoration: const InputDecoration(labelText: 'فاتورة البيع'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('اختر الفاتورة'),
                  ),
                  ...widget.saleInvoices.map(
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
                    _saleInvoiceId = value;
                  });
                },
                onSaved: (value) => _saleInvoiceId = value,
              ),
              DropdownButtonFormField<int?>(
                value: _productId,
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
                decoration: const InputDecoration(labelText: 'السبب (اختياري)'),
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
        ElevatedButton(onPressed: _saveSaleReturn, child: const Text('حفظ')),
      ],
    );
  }
}
