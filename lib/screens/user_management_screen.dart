import 'package:flutter/material.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/models.dart';

import 'package:ipcam/widgets/custom_notification.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final db = DatabaseHelper();
    final usersMap = await db.getUsers();
    setState(() {
      _users = usersMap.map((e) => User.fromMap(e)).toList();
    });
  }

  void _showUserForm({User? user}) {
    showDialog(
      context: context,
      builder: (context) {
        return UserFormDialog(user: user, onSave: _loadUsers);
      },
    );
  }

  void _performDeleteUser(int id) async {
    await DatabaseHelper().deleteUser(id);
    _loadUsers();
    if (mounted) {
      CustomNotificationOverlay.show(
        context,
        'تم حذف المستخدم بنجاح!',
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
          content: Text('هل أنت متأكد أنك تريد حذف المستخدم: $name؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                _performDeleteUser(id);
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
        title: const Text('إدارة المستخدمين'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _users.isEmpty
          ? const Center(
              child: Text('لم يتم العثور على مستخدمين. أضف مستخدمًا جديدًا!'),
            )
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    title: Text(user.name),
                    subtitle: Text(
                      'اسم المستخدم: ${user.username} | الصلاحية: ${user.role}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () => _showUserForm(user: user),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _confirmDelete(user.id!, user.name),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class UserFormDialog extends StatefulWidget {
  final User? user;
  final VoidCallback onSave;

  const UserFormDialog({super.key, this.user, required this.onSave});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _username;
  late String _password;
  late String _role;
  String? _phoneNumber;
  List<User> _allUsers = [];
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
    if (widget.user != null) {
      _name = widget.user!.name;
      _username = widget.user!.username;
      _password = widget.user!.password;
      _role = widget.user!.role;
      _phoneNumber = widget.user!.phoneNumber;
    } else {
      _name = '';
      _username = '';
      _password = '';
      _role = 'customer'; // Default role
      _phoneNumber = '';
    }
  }

  Future<void> _loadAllUsers() async {
    final db = DatabaseHelper();
    final usersMap = await db.getUsers();
    setState(() {
      _allUsers = usersMap.map((e) => User.fromMap(e)).toList();
    });
  }

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final db = DatabaseHelper();

      final user = User(
        id: widget.user?.id,
        name: _name,
        username: _username,
        password: _password, // Remember to hash passwords in a real app!
        role: _role,
        phoneNumber: _phoneNumber,
      );

      if (user.id == null) {
        await db.insertUser(user.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(context, 'تم إضافة المستخدم بنجاح!');
        }
      } else {
        await db.updateUser(user.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(context, 'تم تعديل المستخدم بنجاح!');
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
      title: Text(widget.user == null ? 'إضافة مستخدم' : 'تعديل مستخدم'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'الاسم'),
                validator: User.validateName,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _username,
                decoration: const InputDecoration(labelText: 'اسم المستخدم'),
                validator: (value) {
                  String? baseValidation = User.validateUsername(value);
                  if (baseValidation != null) return baseValidation;
                  // Check for uniqueness locally
                  if (_allUsers.any(
                    (user) =>
                        user.username == value && user.id != widget.user?.id,
                  )) {
                    return 'اسم المستخدم موجود بالفعل!';
                  }
                  return null;
                },
                onSaved: (value) => _username = value!,
              ),
              TextFormField(
                initialValue: _password,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال كلمة المرور';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'الصلاحية'),
                items: const [
                  DropdownMenuItem(value: 'manager', child: Text('مدير')),
                  DropdownMenuItem(value: 'observer', child: Text('مراقب')),
                  DropdownMenuItem(value: 'seller', child: Text('بائع')),
                  DropdownMenuItem(value: 'customer', child: Text('عميل')),
                ],
                onChanged: (value) {
                  setState(() {
                    _role = value!;
                  });
                },
                onSaved: (value) => _role = value!,
              ),
              TextFormField(
                initialValue: _phoneNumber,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  String? baseValidation = User.validatePhoneNumber(value);
                  if (baseValidation != null) return baseValidation;
                  // Check for uniqueness locally
                  if (_allUsers.any(
                    (user) =>
                        user.phoneNumber == value && user.id != widget.user?.id,
                  )) {
                    return 'رقم الهاتف موجود بالفعل!';
                  }
                  return null;
                },
                onSaved: (value) => _phoneNumber = value,
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
        ElevatedButton(onPressed: _saveUser, child: const Text('حفظ')),
      ],
    );
  }
}
