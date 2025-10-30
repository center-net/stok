import 'package:flutter/material.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/models.dart';
import 'package:intl/intl.dart' as intl; // Import with prefix

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

  void _deletePurchaseReturn(int id) async {
    await DatabaseHelper().deletePurchaseReturn(id);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase Return deleted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Returns'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _purchaseReturns.isEmpty
          ? const Center(child: Text('No purchase returns found.'))
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
                      'Product: ${_getProductName(pr.productId)} | Qty: ${pr.quantity}',
                    ),
                    subtitle: Text(
                      'Invoice: ${_getInvoiceNumber(pr.purchaseInvoiceId)} | Date: ' +
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
                          onPressed: () => _deletePurchaseReturn(pr.id!),
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
      } else {
        await db.updatePurchaseReturn(purchaseReturn.toMap());
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
            ? 'Add Purchase Return'
            : 'Edit Purchase Return',
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
                  labelText: 'Purchase Invoice',
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Select Invoice'),
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
                    return 'Please select an invoice';
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
        ElevatedButton(
          onPressed: _savePurchaseReturn,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
