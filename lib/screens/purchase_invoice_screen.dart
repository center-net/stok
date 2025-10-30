import 'package:flutter/material.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/models.dart';
import 'package:intl/intl.dart' as intl; // Import with prefix

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
      return 'Unknown Vendor';
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

  void _deletePurchaseInvoice(int id) async {
    await DatabaseHelper().deletePurchaseInvoice(id);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase Invoice deleted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Invoices'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _purchaseInvoices.isEmpty
          ? const Center(
              child: Text('No purchase invoices found. Add a new one!'),
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
                    title: Text('Invoice No: ${invoice.invoiceNumber}'),
                    subtitle: Text(
                      'Vendor: ${_getVendorName(invoice.vendorId)} | Total: \$${invoice.totalAmount.toStringAsFixed(2)}\nDate: ' +
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
                          onPressed: () => _deletePurchaseInvoice(invoice.id!),
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
      } else {
        await db.updatePurchaseInvoice(invoice.toMap());
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
        widget.invoice == null
            ? 'Add Purchase Invoice'
            : 'Edit Purchase Invoice',
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
                initialValue: _vendorId,
                decoration: const InputDecoration(labelText: 'Vendor'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Select Vendor'),
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
        ElevatedButton(
          onPressed: _savePurchaseInvoice,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
