import 'package:flutter/material.dart';

class RoleManagementScreen extends StatelessWidget {
  const RoleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأدوار والصلاحيات'),
      ),
      body: const Center(
        child: Text('محتوى شاشة إدارة الأدوار والصلاحيات'),
      ),
    );
  }
}
