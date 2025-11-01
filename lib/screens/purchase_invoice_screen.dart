import 'package:flutter/material.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/models.dart';
import 'package:intl/intl.dart' as intl; // Import with prefix

import 'package:ipcam/widgets/custom_notification.dart';

class PurchaseInvoiceScreen extends StatefulWidget {
  const PurchaseInvoiceScreen({super.key});

  @override
  State<PurchaseInvoiceScreen> createState() => _PurchaseInvoiceScreenState();
}

class _PurchaseInvoiceScreenState extends State<PurchaseInvoiceScreen> {
  List<PurchaseInvoice> _purchaseInvoices = [];
  List<Vendor> _vendors = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper();
    final invoicesMap = await db.getPurchaseInvoices();
    final vendorsMap = await db.getVendors();
    setState(() {
      _purchaseInvoices = invoicesMap
          .map((e) => PurchaseInvoice.fromMap(e))
          .toList();
      _vendors = vendorsMap.map((e) => Vendor.fromMap(e)).toList();
    });
  }

  String _getVendorName(int? vendorId) {
    if (vendorId == null) return 'N/A';
    try {
      return _vendors.firstWhere((vendor) => vendor.id == vendorId).name;
    } catch (e) {
      return 'مورد غير معروف';
    }
  }

  void _showPurchaseInvoiceForm({PurchaseInvoice? invoice}) {
    showDialog(
      context: context,
      builder: (context) {
        return PurchaseInvoiceFormDialog(
          invoice: invoice,
          onSave: _loadData,
          vendors: _vendors,
        );
      },
    );
  }

  void _performDeletePurchaseInvoice(int id) async {
    await DatabaseHelper().deletePurchaseInvoice(id);
    _loadData();
    if (mounted) {
      CustomNotificationOverlay.show(
        context,
        'تم حذف فاتورة الشراء بنجاح!',
        backgroundColor: Colors.red,
      );
    }
  }

  void _confirmDelete(int id, String invoiceNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text(
            'هل أنت متأكد أنك تريد حذف فاتورة الشراء رقم: $invoiceNumber؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                _performDeletePurchaseInvoice(id);
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
          'فواتير الشراء',
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
      body: _purchaseInvoices.isEmpty
          ? const Center(
              child: Text('لم يتم العثور على فواتير شراء. أضف واحدة جديدة!'),
            )
          : ListView.builder(
              itemCount: _purchaseInvoices.length,
              itemBuilder: (context, index) {
                final invoice = _purchaseInvoices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    title: Text('رقم الفاتورة: ${invoice.invoiceNumber}'),
                    subtitle: Text(
                      'المورد: ${_getVendorName(invoice.vendorId)} | الإجمالي: د.ل${invoice.totalAmount.toStringAsFixed(2)}\nالتاريخ: ' +
                          intl.DateFormat.yMd().add_jm().format(
                            DateTime.parse(invoice.invoiceDate),
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
                              _showPurchaseInvoiceForm(invoice: invoice),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _confirmDelete(
                            invoice.id!,
                            invoice.invoiceNumber,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.info,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            // TODO: Navigate to Purchase Invoice Details screen
                            print(
                              'View details for invoice ${invoice.invoiceNumber}',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPurchaseInvoiceForm(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class PurchaseInvoiceFormDialog extends StatefulWidget {
  final PurchaseInvoice? invoice;
  final VoidCallback onSave;
  final List<Vendor> vendors;

  const PurchaseInvoiceFormDialog({
    super.key,
    this.invoice,
    required this.onSave,
    required this.vendors,
  });

  @override
  State<PurchaseInvoiceFormDialog> createState() =>
      _PurchaseInvoiceFormDialogState();
}

class _PurchaseInvoiceFormDialogState extends State<PurchaseInvoiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _invoiceNumber;
  late String _invoiceDate;
  int? _vendorId;
  late double _totalAmount;
  late double _paidAmount;
  late double _remainingAmount;

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _invoiceNumber = widget.invoice!.invoiceNumber;
      _invoiceDate = widget.invoice!.invoiceDate;
      _vendorId = widget.invoice!.vendorId;
      _totalAmount = widget.invoice!.totalAmount;
      _paidAmount = widget.invoice!.paidAmount;
      _remainingAmount = widget.invoice!.remainingAmount;
    } else {
      _invoiceNumber = DateTime.now().millisecondsSinceEpoch.toString();
      _invoiceDate = DateTime.now().toIso8601String();
      _vendorId = null;
      _totalAmount = 0.0;
      _paidAmount = 0.0;
      _remainingAmount = 0.0;
    }
  }

  void _savePurchaseInvoice() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final db = DatabaseHelper();

      final invoice = PurchaseInvoice(
        id: widget.invoice?.id,
        invoiceNumber: _invoiceNumber,
        invoiceDate: _invoiceDate,
        vendorId: _vendorId,
        totalAmount: _totalAmount,
        paidAmount: _paidAmount,
        remainingAmount: _remainingAmount,
      );

      if (invoice.id == null) {
        await db.insertPurchaseInvoice(invoice.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(
            context,
            'تم إضافة فاتورة الشراء بنجاح!',
          );
        }
      } else {
        await db.updatePurchaseInvoice(invoice.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(
            context,
            'تم تعديل فاتورة الشراء بنجاح!',
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
        widget.invoice == null ? 'إضافة فاتورة شراء' : 'تعديل فاتورة شراء',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                initialValue: _invoiceNumber,
                decoration: const InputDecoration(labelText: 'رقم الفاتورة'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الفاتورة';
                  }
                  return null;
                },
                onSaved: (value) => _invoiceNumber = value!,
              ),
              DropdownButtonFormField<int?>(
                initialValue: _vendorId,
                decoration: const InputDecoration(labelText: 'المورد'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('اختر المورد'),
                  ),
                  ...widget.vendors.map(
                    (vendor) => DropdownMenuItem(
                      value: vendor.id,
                      child: Text(vendor.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _vendorId = value;
                  });
                },
                onSaved: (value) => _vendorId = value,
              ),
              TextFormField(
                initialValue: _totalAmount.toStringAsFixed(2),
                decoration: const InputDecoration(labelText: 'المبلغ الإجمالي'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال المبلغ الإجمالي';
                  }
                  if (double.tryParse(value) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
                onSaved: (value) => _totalAmount = double.parse(value!),
              ),
              TextFormField(
                initialValue: _paidAmount.toStringAsFixed(2),
                decoration: const InputDecoration(labelText: 'المبلغ المدفوع'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال المبلغ المدفوع';
                  }
                  if (double.tryParse(value) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
                onSaved: (value) => _paidAmount = double.parse(value!),
                onChanged: (value) {
                  setState(() {
                    _paidAmount = double.tryParse(value) ?? 0.0;
                    _remainingAmount = _totalAmount - _paidAmount;
                  });
                },
              ),
              TextFormField(
                initialValue: _remainingAmount.toStringAsFixed(2),
                decoration: const InputDecoration(labelText: 'المبلغ المتبقي'),
                keyboardType: TextInputType.number,
                readOnly: true,
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
          onPressed: _savePurchaseInvoice,
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
