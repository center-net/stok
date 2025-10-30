import 'package:flutter/material.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/models.dart';

class VendorManagementScreen extends StatefulWidget {
  const VendorManagementScreen({super.key});

  @override
  State<VendorManagementScreen> createState() => _VendorManagementScreenState();
}

class _VendorManagementScreenState extends State<VendorManagementScreen> {
  List<Vendor> _vendors = [];

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    final db = DatabaseHelper();
    final vendorsMap = await db.getVendors();
    setState(() {
      _vendors = vendorsMap.map((e) => Vendor.fromMap(e)).toList();
    });
  }

  void _showVendorForm({Vendor? vendor}) {
    showDialog(
      context: context,
      builder: (context) {
        return VendorFormDialog(vendor: vendor, onSave: _loadVendors);
      },
    );
  }

  void _deleteVendor(int id) async {
    await DatabaseHelper().deleteVendor(id);
    _loadVendors();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المورد بنجاح!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الموردين'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _vendors.isEmpty
          ? const Center(child: Text('لم يتم العثور على موردين. أضف موردًا جديدًا!'))
          : ListView.builder(
              itemCount: _vendors.length,
              itemBuilder: (context, index) {
                final vendor = _vendors[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    title: Text(vendor.name),
                    subtitle: Text(
                      'الهاتف: ${vendor.phoneNumber ?? 'غير متوفر'} | العنوان: ${vendor.address ?? 'غير متوفر'}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () => _showVendorForm(vendor: vendor),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _deleteVendor(vendor.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVendorForm(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class VendorFormDialog extends StatefulWidget {
  final Vendor? vendor;
  final VoidCallback onSave;

  const VendorFormDialog({super.key, this.vendor, required this.onSave});

  @override
  State<VendorFormDialog> createState() => _VendorFormDialogState();
}

class _VendorFormDialogState extends State<VendorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  String? _phoneNumber;
  String? _address;

  @override
  void initState() {
    super.initState();
    if (widget.vendor != null) {
      _name = widget.vendor!.name;
      _phoneNumber = widget.vendor!.phoneNumber;
      _address = widget.vendor!.address;
    } else {
      _name = '';
      _phoneNumber = '';
      _address = '';
    }
  }

  void _saveVendor() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final db = DatabaseHelper();

      final vendor = Vendor(
        id: widget.vendor?.id,
        name: _name,
        phoneNumber: _phoneNumber,
        address: _address,
      );

      if (vendor.id == null) {
        await db.insertVendor(vendor.toMap());
      } else {
        await db.updateVendor(vendor.toMap());
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
      title: Text(widget.vendor == null ? 'إضافة مورد' : 'تعديل مورد'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'الاسم'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الاسم';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _phoneNumber,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                keyboardType: TextInputType.phone,
                onSaved: (value) => _phoneNumber = value,
              ),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: 'العنوان'),
                maxLines: 2,
                onSaved: (value) => _address = value,
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
        ElevatedButton(onPressed: _saveVendor, child: const Text('حفظ')),
      ],
    );
  }
}
