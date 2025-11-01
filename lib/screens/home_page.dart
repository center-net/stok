import 'package:flutter/material.dart';
import 'package:ipcam/screens/user_management_screen.dart';
import 'package:ipcam/screens/vendor_management_screen.dart';
import 'package:ipcam/screens/store_management_screen.dart';
import 'package:ipcam/screens/category_management_screen.dart';
import 'package:ipcam/screens/product_management_screen.dart';
import 'package:ipcam/screens/cashier_sales_screen.dart';
import 'package:ipcam/screens/purchase_invoice_screen.dart';
import 'package:ipcam/screens/sale_invoice_screen.dart';
import 'package:ipcam/screens/purchase_return_screen.dart';
import 'package:ipcam/screens/sale_return_screen.dart';
import 'package:ipcam/screens/serial_management_screen.dart';
import 'package:ipcam/screens/role_management_screen.dart';
import 'package:ipcam/screens/login_page.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الصفحة الرئيسية',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'مرحباً، ${user['username']}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('إدارة المستخدمين'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.storefront),
              title: const Text('إدارة الموردين'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VendorManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.warehouse),
              title: const Text('إدارة المتاجر'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StoreManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('إدارة الفئات'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoryManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('إدارة المنتجات'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('فواتير الشراء'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PurchaseInvoiceScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text('فواتير البيع'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SaleInvoiceScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_return),
              title: const Text('مرتجعات الشراء'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PurchaseReturnScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_return),
              title: const Text('مرتجعات البيع'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SaleReturnScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.barcode_reader),
              title: const Text('الأرقام التسلسلية'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SerialManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale_rounded),
              title: const Text('لوحة مبيعات الكاشير'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CashierSalesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('إدارة الأدوار والصلاحيات'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoleManagementScreen(),
                  ),
                );
              },
            ),
            const Divider(), // Add a divider for better separation
          ],
        ),
      ),
      body: const Center(
        child: Text('مرحباً بك في نظام إدارة المتجر! اختر خيارًا من القائمة.'),
      ),
    );
  }
}
