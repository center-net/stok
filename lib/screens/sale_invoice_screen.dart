import 'package:flutter/material.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/models.dart';
import 'package:intl/intl.dart' as intl; // Import with prefix

import 'package:ipcam/widgets/custom_notification.dart';

class SaleInvoiceScreen extends StatefulWidget {
  const SaleInvoiceScreen({super.key});

  @override
  State<SaleInvoiceScreen> createState() => _SaleInvoiceScreenState();
}

class _SaleInvoiceScreenState extends State<SaleInvoiceScreen> {
  List<SaleInvoice> _saleInvoices = [];
  List<User> _customers = []; // Assuming customers are users

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper();
    final invoicesMap = await db.getSaleInvoices();
    final customersMap = await db
        .getUsers(); // Get all users, some of them are customers
    setState(() {
      _saleInvoices = invoicesMap.map((e) => SaleInvoice.fromMap(e)).toList();
      _customers = customersMap.map((e) => User.fromMap(e)).toList();
    });
  }

  String _getCustomerName(int? customerId) {
    if (customerId == null) return 'N/A';
    try {
      return _customers.firstWhere((user) => user.id == customerId).name;
    } catch (e) {
      return 'عميل غير معروف';
    }
  }

  void _showSaleInvoiceForm({SaleInvoice? invoice}) {
    showDialog(
      context: context,
      builder: (context) {
        return SaleInvoiceFormDialog(
          invoice: invoice,
          onSave: _loadData,
          customers: _customers,
        );
      },
    );
  }

  void _performDeleteSaleInvoice(int id) async {
    await DatabaseHelper().deleteSaleInvoice(id);
    _loadData();
    if (mounted) {
      CustomNotificationOverlay.show(
        context,
        'تم حذف فاتورة البيع بنجاح!',
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
            'هل أنت متأكد أنك تريد حذف فاتورة البيع رقم: $invoiceNumber؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                _performDeleteSaleInvoice(id);
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
          'فواتير البيع',
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
      body: _saleInvoices.isEmpty
          ? const Center(child: Text('لم يتم العثور على فواتير بيع.'))
          : ListView.builder(
              itemCount: _saleInvoices.length,
              itemBuilder: (context, index) {
                final invoice = _saleInvoices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    title: Text('رقم الفاتورة: ${invoice.invoiceNumber}'),
                    subtitle: Text(
                      'العميل: ${_getCustomerName(invoice.customerId)} | الإجمالي: د.ل${invoice.totalAmount.toStringAsFixed(2)}\nالتاريخ: ' +
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
                              _showSaleInvoiceForm(invoice: invoice),
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
                            // TODO: Navigate to Sale Invoice Details screen
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
        onPressed: () => _showSaleInvoiceForm(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class SaleInvoiceFormDialog extends StatefulWidget {
  final SaleInvoice? invoice;
  final VoidCallback onSave;
  final List<User> customers;

  const SaleInvoiceFormDialog({
    super.key,
    this.invoice,
    required this.onSave,
    required this.customers,
  });

  @override
  State<SaleInvoiceFormDialog> createState() => _SaleInvoiceFormDialogState();
}

class _SaleInvoiceFormDialogState extends State<SaleInvoiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _invoiceNumber;
  late String _invoiceDate;
  int? _customerId;
  late double _totalAmount;
  late double _paidAmount;
  late double _remainingAmount;

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _invoiceNumber = widget.invoice!.invoiceNumber;
      _invoiceDate = widget.invoice!.invoiceDate;
      _customerId = widget.invoice!.customerId;
      _totalAmount = widget.invoice!.totalAmount;
      _paidAmount = widget.invoice!.paidAmount;
      _remainingAmount = widget.invoice!.remainingAmount;
    } else {
      _invoiceNumber = DateTime.now().millisecondsSinceEpoch.toString();
      _invoiceDate = DateTime.now().toIso8601String();
      _customerId = null;
      _totalAmount = 0.0;
      _paidAmount = 0.0;
      _remainingAmount = 0.0;
    }
  }

  void _saveSaleInvoice() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final db = DatabaseHelper();

      final invoice = SaleInvoice(
        id: widget.invoice?.id,
        invoiceNumber: _invoiceNumber,
        invoiceDate: _invoiceDate,
        customerId: _customerId,
        totalAmount: _totalAmount,
        paidAmount: _paidAmount,
        remainingAmount: _remainingAmount,
      );

      if (invoice.id == null) {
        await db.insertSaleInvoice(invoice.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(
            context,
            'تم إضافة فاتورة البيع بنجاح!',
          );
        }
      } else {
        await db.updateSaleInvoice(invoice.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(
            context,
            'تم تعديل فاتورة البيع بنجاح!',
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
        widget.invoice == null ? 'إضافة فاتورة بيع' : 'تعديل فاتورة بيع',
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
                initialValue: _customerId,
                decoration: const InputDecoration(labelText: 'العميل'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('اختر العميل'),
                  ),
                  ...widget.customers.map(
                    (customer) => DropdownMenuItem(
                      value: customer.id,
                      child: Text(customer.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _customerId = value;
                  });
                },
                onSaved: (value) => _customerId = value,
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
        ElevatedButton(onPressed: _saveSaleInvoice, child: const Text('حفظ')),
      ],
    );
  }
}
