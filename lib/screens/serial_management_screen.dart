import 'package:flutter/material.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/models.dart';

import 'package:ipcam/widgets/custom_notification.dart';

class SerialManagementScreen extends StatefulWidget {
  const SerialManagementScreen({super.key});

  @override
  State<SerialManagementScreen> createState() => _SerialManagementScreenState();
}

class _SerialManagementScreenState extends State<SerialManagementScreen> {
  List<Serial> _serials = [];
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper();
    final serialsMap = await db.getSerials();
    final productsMap = await db.getProducts();
    setState(() {
      _serials = serialsMap.map((e) => Serial.fromMap(e)).toList();
      _products = productsMap.map((e) => Product.fromMap(e)).toList();
    });
  }

  String _getProductName(int productId) {
    try {
      return _products.firstWhere((product) => product.id == productId).name;
    } catch (e) {
      return 'منتج غير معروف';
    }
  }

  void _showSerialForm({Serial? serial}) {
    showDialog(
      context: context,
      builder: (context) {
        return SerialFormDialog(
          serial: serial,
          onSave: _loadData,
          products: _products,
        );
      },
    );
  }

  void _performDeleteSerial(int id) async {
    await DatabaseHelper().deleteSerial(id);
    _loadData();
    if (mounted) {
      CustomNotificationOverlay.show(
        context,
        'تم حذف الرقم التسلسلي بنجاح!',
        backgroundColor: Colors.red,
      );
    }
  }

  void _confirmDelete(int id, String serialNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text(
            'هل أنت متأكد أنك تريد حذف الرقم التسلسلي: $serialNumber؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                _performDeleteSerial(id);
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
          'إدارة الأرقام التسلسلية',
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
      body: _serials.isEmpty
          ? const Center(
              child: Text('لم يتم العثور على أرقام تسلسلية. أضف رقما جديدا!'),
            )
          : ListView.builder(
              itemCount: _serials.length,
              itemBuilder: (context, index) {
                final serial = _serials[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    title: Text('الرقم التسلسلي: ${serial.serialNumber}'),
                    subtitle: Text(
                      'المنتج: ${_getProductName(serial.productId)} | الحالة: ${serial.status}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () => _showSerialForm(serial: serial),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () =>
                              _confirmDelete(serial.id!, serial.serialNumber),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSerialForm(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class SerialFormDialog extends StatefulWidget {
  final Serial? serial;
  final VoidCallback onSave;
  final List<Product> products;

  const SerialFormDialog({
    super.key,
    this.serial,
    required this.onSave,
    required this.products,
  });

  @override
  State<SerialFormDialog> createState() => _SerialFormDialogState();
}

class _SerialFormDialogState extends State<SerialFormDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _productId;
  late String _serialNumber;
  String? _status;

  @override
  void initState() {
    super.initState();
    if (widget.serial != null) {
      _productId = widget.serial!.productId;
      _serialNumber = widget.serial!.serialNumber;
      _status = widget.serial!.status;
    } else {
      _productId = null;
      _serialNumber = '';
      _status = 'in_stock'; // Default status
    }
  }

  void _saveSerial() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final db = DatabaseHelper();

      final serial = Serial(
        id: widget.serial?.id,
        productId: _productId!,
        serialNumber: _serialNumber,
        status: _status!,
      );

      if (serial.id == null) {
        await db.insertSerial(serial.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(
            context,
            'تم إضافة الرقم التسلسلي بنجاح!',
          );
        }
      } else {
        await db.updateSerial(serial.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(
            context,
            'تم تعديل الرقم التسلسلي بنجاح!',
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
        widget.serial == null ? 'إضافة رقم تسلسلي' : 'تعديل رقم تسلسلي',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
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
                initialValue: _serialNumber,
                decoration: const InputDecoration(labelText: 'الرقم التسلسلي'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الرقم التسلسلي';
                  }
                  return null;
                },
                onSaved: (value) => _serialNumber = value!,
              ),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'الحالة'),
                items: const [
                  DropdownMenuItem(value: 'in_stock', child: Text('في المخزن')),
                  DropdownMenuItem(value: 'sold', child: Text('مباع')),
                  DropdownMenuItem(
                    value: 'returned_purchase',
                    child: Text('مرتجع (شراء)'),
                  ),
                  DropdownMenuItem(
                    value: 'returned_sale',
                    child: Text('مرتجع (بيع)'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                onSaved: (value) => _status = value!,
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
        ElevatedButton(onPressed: _saveSerial, child: const Text('حفظ')),
      ],
    );
  }
}
