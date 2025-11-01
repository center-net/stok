import 'package:flutter/material.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/models.dart';

import 'package:ipcam/widgets/custom_notification.dart';

class StoreManagementScreen extends StatefulWidget {
  const StoreManagementScreen({super.key});

  @override
  State<StoreManagementScreen> createState() => _StoreManagementScreenState();
}

class _StoreManagementScreenState extends State<StoreManagementScreen> {
  List<Store> _stores = [];
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _loadStores();
    _loadUsers();
  }

  Future<void> _loadStores() async {
    final db = DatabaseHelper();
    final storesMap = await db.getStores();
    setState(() {
      _stores = storesMap.map((e) => Store.fromMap(e)).toList();
    });
  }

  Future<void> _loadUsers() async {
    final db = DatabaseHelper();
    final usersMap = await db.getUsers();
    setState(() {
      _users = usersMap.map((e) => User.fromMap(e)).toList();
    });
  }

  String _getManagerName(int? managerId) {
    if (managerId == null) return 'غير متوفر';
    try {
      return _users.firstWhere((user) => user.id == managerId).name;
    } catch (e) {
      return 'مستخدم غير معروف';
    }
  }

  void _showStoreForm({Store? store}) {
    showDialog(
      context: context,
      builder: (context) {
        return StoreFormDialog(
          store: store,
          onSave: _loadStores,
          users: _users,
        );
      },
    );
  }

  void _performDeleteStore(int id) async {
    await DatabaseHelper().deleteStore(id);
    _loadStores();
    if (mounted) {
      CustomNotificationOverlay.show(
        context,
        'تم حذف المتجر بنجاح!',
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
          content: Text('هل أنت متأكد أنك تريد حذف المتجر: $name؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                _performDeleteStore(id);
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
          'إدارة المتاجر',
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
      body: _stores.isEmpty
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
                    Icon(Icons.store, size: 80, color: Colors.blueGrey),
                    SizedBox(height: 20),
                    Text(
                      'لم يتم العثور على متاجر.',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'أضف متجرًا جديدًا!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: _stores.length,
              itemBuilder: (context, index) {
                final store = _stores[index];
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
                      store.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'رقم المتجر: ${store.storeNumber} | المدير: ${_getManagerName(store.managerId)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () => _showStoreForm(store: store),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () =>
                              _confirmDelete(store.id!, store.name),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStoreForm(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class StoreFormDialog extends StatefulWidget {
  final Store? store;
  final VoidCallback onSave;
  final List<User> users;

  const StoreFormDialog({
    super.key,
    this.store,
    required this.onSave,
    required this.users,
  });

  @override
  State<StoreFormDialog> createState() => _StoreFormDialogState();
}

class _StoreFormDialogState extends State<StoreFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _storeNumber;
  String? _phoneNumber;
  int? _managerId;
  String? _address;

  @override
  void initState() {
    super.initState();
    if (widget.store != null) {
      _name = widget.store!.name;
      _storeNumber = widget.store!.storeNumber;
      _phoneNumber = widget.store!.phoneNumber;
      _managerId = widget.store!.managerId;
      _address = widget.store!.address;
    } else {
      _name = '';
      _storeNumber = '';
      _phoneNumber = '';
      _managerId = null;
      _address = '';
    }
  }

  void _saveStore() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final db = DatabaseHelper();

      final store = Store(
        id: widget.store?.id,
        name: _name,
        storeNumber: _storeNumber,
        phoneNumber: _phoneNumber,
        managerId: _managerId,
        address: _address,
      );

      if (store.id == null) {
        await db.insertStore(store.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(context, 'تم إضافة المتجر بنجاح!');
        }
      } else {
        await db.updateStore(store.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(context, 'تم تعديل المتجر بنجاح!');
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
      title: Text(widget.store == null ? 'إضافة متجر' : 'تعديل متجر'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'اسم المتجر'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المتجر';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _storeNumber,
                decoration: const InputDecoration(labelText: 'رقم المتجر'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم المتجر';
                  }
                  return null;
                },
                onSaved: (value) => _storeNumber = value!,
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
              DropdownButtonFormField<int?>(
                initialValue: _managerId,
                decoration: const InputDecoration(labelText: 'مدير المتجر'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('لا أحد')),
                  ...widget.users.map(
                    (user) => DropdownMenuItem(
                      value: user.id,
                      child: Text(user.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _managerId = value;
                  });
                },
                onSaved: (value) => _managerId = value,
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
        ElevatedButton(onPressed: _saveStore, child: const Text('حفظ')),
      ],
    );
  }
}
