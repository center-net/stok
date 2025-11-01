import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ipcam/models.dart'; // Import the models

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'ipcam.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    String schemaSql = await rootBundle.loadString('schema.sql');
    List<String> statements = schemaSql.split(';');
    for (String statement in statements) {
      if (statement.trim().isNotEmpty) {
        await db.execute(statement);
      }
    }

    // Insert a default admin user if no users exist
    var count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM Users'),
    );
    if (count == 0) {
      await db.insert('Users', {
        'name': 'المستخدم المسؤول',
        'username': 'admin',
        'password': User.hashPassword('admin'), // Hash the password
        'role': 'manager',
        'phone_number': '1234567890',
      });
    }
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('Users', user);
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.update(
      'Users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  Future<int> deleteUser(int id) async {
    Database db = await database;
    return await db.delete('Users', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> authenticateUser(
    String username,
    String password,
  ) async {
    Database db = await database;
    List<Map<String, dynamic>> users = await db.query(
      'Users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, User.hashPassword(password)],
    );
    if (users.isNotEmpty) {
      return users.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    Database db = await database;
    return await db.query('Users');
  }

  Future<User?> getUserById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> users = await db.query(
      'Users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (users.isNotEmpty) {
      return User.fromMap(users.first);
    } else {
      return null;
    }
  }

  // Vendor CRUD Operations
  Future<int> insertVendor(Map<String, dynamic> vendor) async {
    Database db = await database;
    return await db.insert('Vendors', vendor);
  }

  Future<int> updateVendor(Map<String, dynamic> vendor) async {
    Database db = await database;
    return await db.update(
      'Vendors',
      vendor,
      where: 'id = ?',
      whereArgs: [vendor['id']],
    );
  }

  Future<int> deleteVendor(int id) async {
    Database db = await database;
    return await db.delete('Vendors', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getVendors() async {
    Database db = await database;
    return await db.query('Vendors');
  }

  Future<Vendor?> getVendorById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> vendors = await db.query(
      'Vendors',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (vendors.isNotEmpty) {
      return Vendor.fromMap(vendors.first);
    } else {
      return null;
    }
  }

  // Store CRUD Operations
  Future<int> insertStore(Map<String, dynamic> store) async {
    Database db = await database;
    return await db.insert('Stores', store);
  }

  Future<int> updateStore(Map<String, dynamic> store) async {
    Database db = await database;
    return await db.update(
      'Stores',
      store,
      where: 'id = ?',
      whereArgs: [store['id']],
    );
  }

  Future<int> deleteStore(int id) async {
    Database db = await database;
    return await db.delete('Stores', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getStores() async {
    Database db = await database;
    return await db.query('Stores');
  }

  Future<Store?> getStoreById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> stores = await db.query(
      'Stores',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (stores.isNotEmpty) {
      return Store.fromMap(stores.first);
    } else {
      return null;
    }
  }

  // Category CRUD Operations
  Future<int> insertCategory(Map<String, dynamic> category) async {
    Database db = await database;
    return await db.insert('Categories', category);
  }

  Future<int> updateCategory(Map<String, dynamic> category) async {
    Database db = await database;
    return await db.update(
      'Categories',
      category,
      where: 'id = ?',
      whereArgs: [category['id']],
    );
  }

  Future<int> deleteCategory(int id) async {
    Database db = await database;
    return await db.delete('Categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    Database db = await database;
    return await db.query('Categories');
  }

  Future<Category?> getCategoryById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> categories = await db.query(
      'Categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (categories.isNotEmpty) {
      return Category.fromMap(categories.first);
    } else {
      return null;
    }
  }

  // Product CRUD Operations
  Future<int> insertProduct(Map<String, dynamic> product) async {
    Database db = await database;
    return await db.insert('Products', product);
  }

  Future<int> updateProduct(Map<String, dynamic> product) async {
    Database db = await database;
    return await db.update(
      'Products',
      product,
      where: 'id = ?',
      whereArgs: [product['id']],
    );
  }

  Future<int> deleteProduct(int id) async {
    Database db = await database;
    return await db.delete('Products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    Database db = await database;
    return await db.query('Products');
  }

  Future<Product?> getProductById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> products = await db.query(
      'Products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (products.isNotEmpty) {
      return Product.fromMap(products.first);
    } else {
      return null;
    }
  }

  Future<int> updateProductQuantity(int productId, int quantityChange) async {
    Database db = await database;
    return await db.rawUpdate(
      'UPDATE Products SET quantity_in_stock = quantity_in_stock + ? WHERE id = ?',
      [quantityChange, productId],
    );
  }

  // PurchaseInvoice CRUD Operations
  Future<int> insertPurchaseInvoice(Map<String, dynamic> invoice) async {
    Database db = await database;
    return await db.insert('PurchaseInvoices', invoice);
  }

  Future<int> updatePurchaseInvoice(Map<String, dynamic> invoice) async {
    Database db = await database;
    return await db.update(
      'PurchaseInvoices',
      invoice,
      where: 'id = ?',
      whereArgs: [invoice['id']],
    );
  }

  Future<int> deletePurchaseInvoice(int id) async {
    Database db = await database;
    return await db.delete(
      'PurchaseInvoices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPurchaseInvoices() async {
    Database db = await database;
    return await db.query('PurchaseInvoices');
  }

  Future<PurchaseInvoice?> getPurchaseInvoiceById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> invoices = await db.query(
      'PurchaseInvoices',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (invoices.isNotEmpty) {
      return PurchaseInvoice.fromMap(invoices.first);
    } else {
      return null;
    }
  }

  // PurchaseInvoiceDetail CRUD Operations
  Future<int> insertPurchaseInvoiceDetail(Map<String, dynamic> detail) async {
    final db = await database;
    final id = await db.insert('PurchaseInvoiceDetails', detail);
    await updateProductQuantity(
      detail['product_id'] as int,
      detail['quantity'] as int,
    );
    return id;
  }

  Future<int> updatePurchaseInvoiceDetail(Map<String, dynamic> detail) async {
    final db = await database;
    // Get old quantity to adjust stock correctly
    final oldDetail = await getPurchaseInvoiceDetailById(detail['id'] as int);
    if (oldDetail != null) {
      await updateProductQuantity(
        oldDetail.productId,
        -(oldDetail.quantity),
      ); // Remove old quantity
      await updateProductQuantity(
        detail['product_id'] as int,
        detail['quantity'] as int,
      ); // Add new quantity
    } else {
      await updateProductQuantity(
        detail['product_id'] as int,
        detail['quantity'] as int,
      );
    }
    return await db.update(
      'PurchaseInvoiceDetails',
      detail,
      where: 'id = ?',
      whereArgs: [detail['id']],
    );
  }

  Future<void> deletePurchaseInvoiceDetail(int id) async {
    final db = await database;
    final detail = await getPurchaseInvoiceDetailById(id);
    if (detail != null) {
      await updateProductQuantity(detail.productId, -detail.quantity);
    }
    await db.delete('PurchaseInvoiceDetails', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getPurchaseInvoiceDetails(
    int purchaseInvoiceId,
  ) async {
    Database db = await database;
    return await db.query(
      'PurchaseInvoiceDetails',
      where: 'purchase_invoice_id = ?',
      whereArgs: [purchaseInvoiceId],
    );
  }

  Future<PurchaseInvoiceDetail?> getPurchaseInvoiceDetailById(int id) async {
    final db = await database;
    final details = await db.query(
      'PurchaseInvoiceDetails',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (details.isNotEmpty) {
      return PurchaseInvoiceDetail.fromMap(details.first);
    }
    return null;
  }

  // SaleInvoice CRUD Operations
  Future<int> insertSaleInvoice(Map<String, dynamic> invoice) async {
    Database db = await database;
    return await db.insert('SaleInvoices', invoice);
  }

  Future<int> updateSaleInvoice(Map<String, dynamic> invoice) async {
    Database db = await database;
    return await db.update(
      'SaleInvoices',
      invoice,
      where: 'id = ?',
      whereArgs: [invoice['id']],
    );
  }

  Future<int> deleteSaleInvoice(int id) async {
    Database db = await database;
    return await db.delete('SaleInvoices', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getSaleInvoices() async {
    final db = await database;
    return await db.query('SaleInvoices', orderBy: 'invoice_date DESC');
  }

  Future<SaleInvoice?> getSaleInvoiceById(int id) async {
    final db = await database;
    final invoices = await db.query(
      'SaleInvoices',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (invoices.isNotEmpty) {
      return SaleInvoice.fromMap(invoices.first);
    }
    return null;
  }

  // SaleInvoiceDetail CRUD Operations
  Future<int> insertSaleInvoiceDetail(Map<String, dynamic> detail) async {
    final db = await database;
    final id = await db.insert('SaleInvoiceDetails', detail);
    await updateProductQuantity(
      detail['product_id'] as int,
      -(detail['quantity'] as int),
    ); // Decrease stock for sale
    return id;
  }

  Future<int> updateSaleInvoiceDetail(Map<String, dynamic> detail) async {
    final db = await database;
    // Get old quantity to adjust stock correctly
    final oldDetail = await getSaleInvoiceDetailById(detail['id'] as int);
    if (oldDetail != null) {
      await updateProductQuantity(
        oldDetail.productId,
        oldDetail.quantity,
      ); // Re-add old quantity
      await updateProductQuantity(
        detail['product_id'] as int,
        -(detail['quantity'] as int),
      ); // Remove new quantity
    } else {
      await updateProductQuantity(
        detail['product_id'] as int,
        -(detail['quantity'] as int),
      );
    }
    return await db.update(
      'SaleInvoiceDetails',
      detail,
      where: 'id = ?',
      whereArgs: [detail['id']],
    );
  }

  Future<void> deleteSaleInvoiceDetail(int id) async {
    final db = await database;
    final detail = await getSaleInvoiceDetailById(id);
    if (detail != null) {
      await updateProductQuantity(
        detail.productId,
        detail.quantity,
      ); // Return to stock
    }
    await db.delete('SaleInvoiceDetails', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getSaleInvoiceDetails(
    int saleInvoiceId,
  ) async {
    Database db = await database;
    return await db.query(
      'SaleInvoiceDetails',
      where: 'sale_invoice_id = ?',
      whereArgs: [saleInvoiceId],
    );
  }

  Future<SaleInvoiceDetail?> getSaleInvoiceDetailById(int id) async {
    final db = await database;
    final details = await db.query(
      'SaleInvoiceDetails',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (details.isNotEmpty) {
      return SaleInvoiceDetail.fromMap(details.first);
    }
    return null;
  }

  // Serial CRUD Operations
  Future<int> insertSerial(Map<String, dynamic> serial) async {
    final db = await database;
    return await db.insert('Serials', serial);
  }

  Future<int> updateSerial(Map<String, dynamic> serial) async {
    final db = await database;
    return await db.update(
      'Serials',
      serial,
      where: 'id = ?',
      whereArgs: [serial['id']],
    );
  }

  Future<void> deleteSerial(int id) async {
    final db = await database;
    await db.delete('Serials', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getSerials() async {
    Database db = await database;
    return await db.query('Serials');
  }

  Future<Serial?> getSerialById(int id) async {
    final db = await database;
    final serials = await db.query('Serials', where: 'id = ?', whereArgs: [id]);
    if (serials.isNotEmpty) {
      return Serial.fromMap(serials.first);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getSerialsByProductId(
    int productId,
  ) async {
    Database db = await database;
    return await db.query(
      'Serials',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<List<Map<String, dynamic>>> getSerialsByPurchaseInvoiceDetailId(
    int purchaseInvoiceDetailId,
  ) async {
    Database db = await database;
    return await db.query(
      'Serials',
      where: 'purchase_invoice_detail_id = ?',
      whereArgs: [purchaseInvoiceDetailId],
    );
  }

  Future<List<Map<String, dynamic>>> getSerialsBySaleInvoiceDetailId(
    int saleInvoiceDetailId,
  ) async {
    Database db = await database;
    return await db.query(
      'Serials',
      where: 'sale_invoice_detail_id = ?',
      whereArgs: [saleInvoiceDetailId],
    );
  }

  // PurchaseReturn CRUD Operations
  Future<int> insertPurchaseReturn(Map<String, dynamic> purchaseReturn) async {
    final db = await database;
    final id = await db.insert('PurchaseReturns', purchaseReturn);
    await updateProductQuantity(
      purchaseReturn['product_id'] as int,
      -(purchaseReturn['quantity'] as int),
    ); // Decrease stock for returned purchase
    return id;
  }

  Future<int> updatePurchaseReturn(Map<String, dynamic> purchaseReturn) async {
    final db = await database;
    final oldReturn = await getPurchaseReturnById(purchaseReturn['id'] as int);
    if (oldReturn != null) {
      await updateProductQuantity(
        oldReturn.productId,
        oldReturn.quantity,
      ); // Re-add old quantity
      await updateProductQuantity(
        purchaseReturn['product_id'] as int,
        -(purchaseReturn['quantity'] as int),
      ); // Decrease new quantity
    } else {
      await updateProductQuantity(
        purchaseReturn['product_id'] as int,
        -(purchaseReturn['quantity'] as int),
      );
    }
    return await db.update(
      'PurchaseReturns',
      purchaseReturn,
      where: 'id = ?',
      whereArgs: [purchaseReturn['id']],
    );
  }

  Future<void> deletePurchaseReturn(int id) async {
    final db = await database;
    final pr = await getPurchaseReturnById(id);
    if (pr != null) {
      await updateProductQuantity(
        pr.productId,
        pr.quantity,
      ); // Increase stock from deleted return
    }
    await db.delete('PurchaseReturns', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getPurchaseReturns() async {
    Database db = await database;
    return await db.query('PurchaseReturns');
  }

  Future<PurchaseReturn?> getPurchaseReturnById(int id) async {
    final db = await database;
    final returns = await db.query(
      'PurchaseReturns',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (returns.isNotEmpty) {
      return PurchaseReturn.fromMap(returns.first);
    }
    return null;
  }

  // SaleReturn CRUD Operations
  Future<int> insertSaleReturn(Map<String, dynamic> saleReturn) async {
    final db = await database;
    final id = await db.insert('SaleReturns', saleReturn);
    await updateProductQuantity(
      saleReturn['product_id'] as int,
      saleReturn['quantity'] as int,
    ); // Increase stock for returned sale
    return id;
  }

  Future<int> updateSaleReturn(Map<String, dynamic> saleReturn) async {
    final db = await database;
    final oldReturn = await getSaleReturnById(saleReturn['id'] as int);
    if (oldReturn != null) {
      await updateProductQuantity(
        oldReturn.productId,
        -(oldReturn.quantity),
      ); // Remove old quantity
      await updateProductQuantity(
        saleReturn['product_id'] as int,
        saleReturn['quantity'] as int,
      ); // Add new quantity
    } else {
      await updateProductQuantity(
        saleReturn['product_id'] as int,
        saleReturn['quantity'] as int,
      );
    }
    return await db.update(
      'SaleReturns',
      saleReturn,
      where: 'id = ?',
      whereArgs: [saleReturn['id']],
    );
  }

  Future<void> deleteSaleReturn(int id) async {
    final db = await database;
    final sr = await getSaleReturnById(id);
    if (sr != null) {
      await updateProductQuantity(
        sr.productId,
        -(sr.quantity),
      ); // Decrease stock from deleted return
    }
    await db.delete('SaleReturns', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getSaleReturns() async {
    Database db = await database;
    return await db.query('SaleReturns');
  }

  Future<SaleReturn?> getSaleReturnById(int id) async {
    final db = await database;
    final returns = await db.query(
      'SaleReturns',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (returns.isNotEmpty) {
      return SaleReturn.fromMap(returns.first);
    }
    return null;
  }
}
