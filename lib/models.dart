class User {
  int? id;
  String name;
  String username;
  String password;
  String role;
  String? phoneNumber;

  User({
    this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.role,
    this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'role': role,
      'phone_number': phoneNumber,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
      phoneNumber: map['phone_number'],
    );
  }
}

class Vendor {
  int? id;
  String name;
  String? phoneNumber;
  String? address;

  Vendor({this.id, required this.name, this.phoneNumber, this.address});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'address': address,
    };
  }

  factory Vendor.fromMap(Map<String, dynamic> map) {
    return Vendor(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phone_number'],
      address: map['address'],
    );
  }
}

class Store {
  int? id;
  String name;
  String storeNumber;
  String? phoneNumber;
  int? managerId;
  String? address;

  Store({
    this.id,
    required this.name,
    required this.storeNumber,
    this.phoneNumber,
    this.managerId,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'store_number': storeNumber,
      'phone_number': phoneNumber,
      'manager_id': managerId,
      'address': address,
    };
  }

  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['id'],
      name: map['name'],
      storeNumber: map['store_number'],
      phoneNumber: map['phone_number'],
      managerId: map['manager_id'],
      address: map['address'],
    );
  }
}

class Category {
  int? id;
  String name;

  Category({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(id: map['id'], name: map['name']);
  }
}

class Product {
  int? id;
  String productCode;
  String name;
  String? imageUrl;
  int? categoryId;
  String? barcode;
  double purchasePrice;
  double salePrice1;
  double? salePrice2;
  double? salePrice3;
  int quantityInStock;

  Product({
    this.id,
    required this.productCode,
    required this.name,
    this.imageUrl,
    this.categoryId,
    this.barcode,
    required this.purchasePrice,
    required this.salePrice1,
    this.salePrice2,
    this.salePrice3,
    this.quantityInStock = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_code': productCode,
      'name': name,
      'image_url': imageUrl,
      'category_id': categoryId,
      'barcode': barcode,
      'purchase_price': purchasePrice,
      'sale_price_1': salePrice1,
      'sale_price_2': salePrice2,
      'sale_price_3': salePrice3,
      'quantity_in_stock': quantityInStock,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      productCode: map['product_code'],
      name: map['name'],
      imageUrl: map['image_url'],
      categoryId: map['category_id'],
      barcode: map['barcode'],
      purchasePrice: map['purchase_price'],
      salePrice1: map['sale_price_1'],
      salePrice2: map['sale_price_2'],
      salePrice3: map['sale_price_3'],
      quantityInStock: map['quantity_in_stock'],
    );
  }
}

class PurchaseInvoice {
  int? id;
  String invoiceNumber;
  String invoiceDate;
  int? vendorId;
  double totalAmount;
  double paidAmount;
  double remainingAmount;

  PurchaseInvoice({
    this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    this.vendorId,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate,
      'vendor_id': vendorId,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
    };
  }

  factory PurchaseInvoice.fromMap(Map<String, dynamic> map) {
    return PurchaseInvoice(
      id: map['id'],
      invoiceNumber: map['invoice_number'],
      invoiceDate: map['invoice_date'],
      vendorId: map['vendor_id'],
      totalAmount: map['total_amount'],
      paidAmount: map['paid_amount'],
      remainingAmount: map['remaining_amount'],
    );
  }
}

class PurchaseInvoiceDetail {
  int? id;
  int purchaseInvoiceId;
  int productId;
  int quantity;
  double purchasePrice;

  PurchaseInvoiceDetail({
    this.id,
    required this.purchaseInvoiceId,
    required this.productId,
    required this.quantity,
    required this.purchasePrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_invoice_id': purchaseInvoiceId,
      'product_id': productId,
      'quantity': quantity,
      'purchase_price': purchasePrice,
    };
  }

  factory PurchaseInvoiceDetail.fromMap(Map<String, dynamic> map) {
    return PurchaseInvoiceDetail(
      id: map['id'],
      purchaseInvoiceId: map['purchase_invoice_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      purchasePrice: map['purchase_price'],
    );
  }
}

class SaleInvoice {
  int? id;
  String invoiceNumber;
  String invoiceDate;
  int? customerId;
  double totalAmount;
  double paidAmount;
  double remainingAmount;

  SaleInvoice({
    this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    this.customerId,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate,
      'customer_id': customerId,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
    };
  }

  factory SaleInvoice.fromMap(Map<String, dynamic> map) {
    return SaleInvoice(
      id: map['id'],
      invoiceNumber: map['invoice_number'],
      invoiceDate: map['invoice_date'],
      customerId: map['customer_id'],
      totalAmount: map['total_amount'],
      paidAmount: map['paid_amount'],
      remainingAmount: map['remaining_amount'],
    );
  }
}

class SaleInvoiceDetail {
  int? id;
  int saleInvoiceId;
  int productId;
  int quantity;
  double salePrice;

  SaleInvoiceDetail({
    this.id,
    required this.saleInvoiceId,
    required this.productId,
    required this.quantity,
    required this.salePrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_invoice_id': saleInvoiceId,
      'product_id': productId,
      'quantity': quantity,
      'sale_price': salePrice,
    };
  }

  factory SaleInvoiceDetail.fromMap(Map<String, dynamic> map) {
    return SaleInvoiceDetail(
      id: map['id'],
      saleInvoiceId: map['sale_invoice_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      salePrice: map['sale_price'],
    );
  }
}

class Serial {
  int? id;
  int productId;
  String serialNumber;
  int? purchaseInvoiceDetailId;
  int? saleInvoiceDetailId;
  String status;

  Serial({
    this.id,
    required this.productId,
    required this.serialNumber,
    this.purchaseInvoiceDetailId,
    this.saleInvoiceDetailId,
    this.status = 'in_stock',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'serial_number': serialNumber,
      'purchase_invoice_detail_id': purchaseInvoiceDetailId,
      'sale_invoice_detail_id': saleInvoiceDetailId,
      'status': status,
    };
  }

  factory Serial.fromMap(Map<String, dynamic> map) {
    return Serial(
      id: map['id'],
      productId: map['product_id'],
      serialNumber: map['serial_number'],
      purchaseInvoiceDetailId: map['purchase_invoice_detail_id'],
      saleInvoiceDetailId: map['sale_invoice_detail_id'],
      status: map['status'],
    );
  }
}

class PurchaseReturn {
  int? id;
  int purchaseInvoiceId;
  int productId;
  int quantity;
  String returnDate;
  String? reason;

  PurchaseReturn({
    this.id,
    required this.purchaseInvoiceId,
    required this.productId,
    required this.quantity,
    required this.returnDate,
    this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_invoice_id': purchaseInvoiceId,
      'product_id': productId,
      'quantity': quantity,
      'return_date': returnDate,
      'reason': reason,
    };
  }

  factory PurchaseReturn.fromMap(Map<String, dynamic> map) {
    return PurchaseReturn(
      id: map['id'],
      purchaseInvoiceId: map['purchase_invoice_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      returnDate: map['return_date'],
      reason: map['reason'],
    );
  }
}

class SaleReturn {
  int? id;
  int saleInvoiceId;
  int productId;
  int quantity;
  String returnDate;
  String? reason;

  SaleReturn({
    this.id,
    required this.saleInvoiceId,
    required this.productId,
    required this.quantity,
    required this.returnDate,
    this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_invoice_id': saleInvoiceId,
      'product_id': productId,
      'quantity': quantity,
      'return_date': returnDate,
      'reason': reason,
    };
  }

  factory SaleReturn.fromMap(Map<String, dynamic> map) {
    return SaleReturn(
      id: map['id'],
      saleInvoiceId: map['sale_invoice_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      returnDate: map['return_date'],
      reason: map['reason'],
    );
  }
}
