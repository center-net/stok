import 'package:flutter/material.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/models.dart';
import 'package:intl/intl.dart' as intl; // Import with prefix

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
      return 'Unknown Invoice';
    }
  }

  String _getProductName(int productId) {
    try {
      return _products.firstWhere((product) => product.id == productId).name;
    } catch (e) {
      return 'Unknown Product';
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

  void _deleteSaleReturn(int id) async {
    await DatabaseHelper().deleteSaleReturn(id);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale Return deleted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Returns'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _saleReturns.isEmpty
          ? const Center(child: Text('No sale returns found.'))
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
                      'Product: ${_getProductName(sr.productId)} | Qty: ${sr.quantity}',
                    ),
                    subtitle: Text(
                      'Invoice: ${_getInvoiceNumber(sr.saleInvoiceId)} | Date: ' +
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
                          onPressed: () => _deleteSaleReturn(sr.id!),
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
      } else {
        await db.updateSaleReturn(saleReturn.toMap());
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
        widget.saleReturn == null ? 'Add Sale Return' : 'Edit Sale Return',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonFormField<int?>(
                value: _saleInvoiceId,
                decoration: const InputDecoration(labelText: 'Sale Invoice'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Select Invoice'),
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
                    return 'Please select an invoice';
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
                decoration: const InputDecoration(labelText: 'Product'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Select Product'),
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
                    return 'Please select a product';
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
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid positive integer';
                  }
                  return null;
                },
                onSaved: (value) => _quantity = int.parse(value!),
              ),
              TextFormField(
                initialValue: _reason,
                decoration: const InputDecoration(
                  labelText: 'Reason (Optional)',
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveSaleReturn, child: const Text('Save')),
      ],
    );
  }
}
