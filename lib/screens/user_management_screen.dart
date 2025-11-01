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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    final db = DatabaseHelper();
    final usersMap = await db.getUsers();
    setState(() {
      _users = usersMap.map((e) => User.fromMap(e)).toList();
      _isLoading = false;
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

  void _showPasswordChangeDialog(User user) {
    showDialog(
      context: context,
      builder: (context) {
        return PasswordChangeDialog(user: user, onSave: _loadUsers);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة المستخدمين',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
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
                    Icon(
                      Icons.people_outline,
                      size: 80,
                      color: Colors.blueGrey,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'لم يتم العثور على مستخدمين.',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'أضف مستخدمًا جديدًا!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
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
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'اسم المستخدم: ${user.username} | الصلاحية: ${user.role}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.lock,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () => _showPasswordChangeDialog(user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () => _showUserForm(user: user),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
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

class PasswordChangeDialog extends StatefulWidget {
  final User user;
  final VoidCallback onSave;

  const PasswordChangeDialog({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<PasswordChangeDialog> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<PasswordChangeDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _newPassword;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _newPassword = '';
  }

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final db = DatabaseHelper();

      final userMap = {
        'id': widget.user.id,
        'name': widget.user.name,
        'username': widget.user.username,
        'password': User.hashPassword(_newPassword),
        'role_id': widget.user.roleId,
        'phone_number': widget.user.phoneNumber,
      };

      await db.updateUser(userMap);
      if (mounted) {
        CustomNotificationOverlay.show(context, 'تم تغيير كلمة المرور بنجاح!');
        widget.onSave();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تغيير كلمة المرور'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
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
                onSaved: (value) => _newPassword = value!,
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
        ElevatedButton(onPressed: _changePassword, child: const Text('تغيير')),
      ],
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

      int? roleId;
      switch (_role) {
        case 'manager':
          roleId = 1;
          break;
        case 'observer':
          roleId = 2;
          break;
        case 'seller':
          roleId = 3;
          break;
        case 'customer':
          roleId = 4;
          break;
        default:
          roleId = 4;
      }

      final userMap = {
        'id': widget.user?.id,
        'name': _name,
        'username': _username,
        'password': widget.user != null
            ? widget.user!.password
            : User.hashPassword(_password), // Hash only for new users
        'role_id': roleId,
        'phone_number': _phoneNumber,
      };

      if (userMap['id'] == null) {
        await db.insertUser(userMap);
        if (mounted) {
          CustomNotificationOverlay.show(context, 'تم إضافة المستخدم بنجاح!');
        }
      } else {
        await db.updateUser(userMap);
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
              if (widget.user == null) // Only show password field for new users
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
