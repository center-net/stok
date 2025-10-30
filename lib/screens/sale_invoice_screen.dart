import 'package:flutter/material.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/models.dart';
import 'package:intl/intl.dart' as intl; // Import with prefix

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
      return 'Unknown Customer';
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

  void _deleteSaleInvoice(int id) async {
    await DatabaseHelper().deleteSaleInvoice(id);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale Invoice deleted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Invoices'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _saleInvoices.isEmpty
          ? const Center(child: Text('No sales invoices found.'))
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
                    title: Text('Invoice No: ${invoice.invoiceNumber}'),
                    subtitle: Text(
                      'Customer: ${_getCustomerName(invoice.customerId)} | Total: \$${invoice.totalAmount.toStringAsFixed(2)}\nDate: ' +
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
                          onPressed: () => _deleteSaleInvoice(invoice.id!),
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
      } else {
        await db.updateSaleInvoice(invoice.toMap());
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
        widget.invoice == null ? 'Add Sale Invoice' : 'Edit Sale Invoice',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                initialValue: _invoiceNumber,
                decoration: const InputDecoration(labelText: 'Invoice Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an invoice number';
                  }
                  return null;
                },
                onSaved: (value) => _invoiceNumber = value!,
              ),
              DropdownButtonFormField<int?>(
                initialValue: _customerId,
                decoration: const InputDecoration(labelText: 'Customer'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Select Customer'),
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
                decoration: const InputDecoration(labelText: 'Total Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => _totalAmount = double.parse(value!),
              ),
              TextFormField(
                initialValue: _paidAmount.toStringAsFixed(2),
                decoration: const InputDecoration(labelText: 'Paid Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter paid amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
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
                decoration: const InputDecoration(
                  labelText: 'Remaining Amount',
                ),
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveSaleInvoice, child: const Text('Save')),
      ],
    );
  }
}
