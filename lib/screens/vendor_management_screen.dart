import 'package:flutter/material.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/models.dart';

import 'package:ipcam/widgets/custom_notification.dart';

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

  void _performDeleteVendor(int id) async {
    await DatabaseHelper().deleteVendor(id);
    _loadVendors();
    if (mounted) {
      CustomNotificationOverlay.show(
        context,
        'تم حذف المورد بنجاح!',
        backgroundColor: Colors.red,
      );
    }
  }

  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد أنك تريد حذف المورد: $name؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                _performDeleteVendor(id);
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
          'إدارة الموردين',
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
      body: _vendors.isEmpty
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFE0E0E0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.business, size: 80, color: Colors.blueGrey),
                    SizedBox(height: 20),
                    Text(
                      'لم يتم العثور على موردين.',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'أضف موردًا جديدًا!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: _vendors.length,
              itemBuilder: (context, index) {
                final vendor = _vendors[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFF5F5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      vendor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'الهاتف: ${vendor.phoneNumber ?? 'غير متوفر'} | العنوان: ${vendor.address ?? 'غير متوفر'}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () => _showVendorForm(vendor: vendor),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () =>
                              _confirmDelete(vendor.id!, vendor.name),
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
        if (mounted) {
          CustomNotificationOverlay.show(context, 'تم إضافة المورد بنجاح!');
        }
      } else {
        await db.updateVendor(vendor.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(context, 'تم تعديل المورد بنجاح!');
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null; // Phone number is optional
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'الرجاء إدخال أرقام فقط';
                  }
                  if (value.length != 10) {
                    return 'يجب أن يتكون رقم الهاتف من 10 أرقام';
                  }
                  return null;
                },
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
