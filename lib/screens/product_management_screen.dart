import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ipcam/database_helper.dart';
import 'package:ipcam/models.dart';

import 'package:ipcam/widgets/custom_notification.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  List<Product> _products = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  Future<void> _loadProducts() async {
    final db = DatabaseHelper();
    final productsMap = await db.getProducts();
    setState(() {
      _products = productsMap.map((e) => Product.fromMap(e)).toList();
    });
  }

  Future<void> _loadCategories() async {
    final db = DatabaseHelper();
    final categoriesMap = await db.getCategories();
    setState(() {
      _categories = categoriesMap.map((e) => Category.fromMap(e)).toList();
    });
  }

  String _getCategoryName(int? categoryId) {
    if (categoryId == null) return 'غير متوفر';
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId).name;
    } catch (e) {
      return 'فئة غير معروفة';
    }
  }

  void _showProductForm({Product? product}) {
    showDialog(
      context: context,
      builder: (context) {
        return ProductFormDialog(
          product: product,
          onSave: _loadProducts,
          categories: _categories,
        );
      },
    );
  }

  void _performDeleteProduct(int id) async {
    await DatabaseHelper().deleteProduct(id);
    _loadProducts();
    if (mounted) {
      CustomNotificationOverlay.show(
        context,
        'تم حذف المنتج بنجاح!',
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
          content: Text('هل أنت متأكد أنك تريد حذف المنتج: $name؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                _performDeleteProduct(id);
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
          'إدارة المنتجات',
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
      body: _products.isEmpty
          ? const Center(
              child: Text('لم يتم العثور على منتجات. أضف منتجًا جديدًا!'),
            )
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    leading:
                        product.imageUrl != null &&
                            File(product.imageUrl!).existsSync()
                        ? CircleAvatar(
                            backgroundImage: FileImage(File(product.imageUrl!)),
                          )
                        : const CircleAvatar(child: Icon(Icons.inventory)),
                    title: Text(product.name),
                    subtitle: Text(
                      'الرمز: ${product.productCode} | الفئة: ${_getCategoryName(product.categoryId)} | المخزون: ${product.quantityInStock}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () => _showProductForm(product: product),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () =>
                              _confirmDelete(product.id!, product.name),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class ProductFormDialog extends StatefulWidget {
  final Product? product;
  final VoidCallback onSave;
  final List<Category> categories;

  const ProductFormDialog({
    super.key,
    this.product,
    required this.onSave,
    required this.categories,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _productCode;
  late String _name;
  String? _imageUrl;
  int? _categoryId;
  String? _barcode;
  late double _purchasePrice;
  late double _salePrice1;
  double? _salePrice2;
  double? _salePrice3;
  late int _quantityInStock;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _productCode = widget.product!.productCode;
      _name = widget.product!.name;
      _imageUrl = widget.product!.imageUrl;
      _categoryId = widget.product!.categoryId;
      _barcode = widget.product!.barcode;
      _purchasePrice = widget.product!.purchasePrice;
      _salePrice1 = widget.product!.salePrice1;
      _salePrice2 = widget.product!.salePrice2;
      _salePrice3 = widget.product!.salePrice3;
      _quantityInStock = widget.product!.quantityInStock;
      if (_imageUrl != null) {
        _imageFile = File(_imageUrl!);
      }
    } else {
      _productCode = '';
      _name = '';
      _imageUrl = null;
      _categoryId = null;
      _barcode = '';
      _purchasePrice = 0.0;
      _salePrice1 = 0.0;
      _salePrice2 = null;
      _salePrice3 = null;
      _quantityInStock = 0;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _imageUrl = pickedFile.path;
      }
    });
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final db = DatabaseHelper();

      if (_salePrice1 < _purchasePrice ||
          (_salePrice2 != null && _salePrice2! < _purchasePrice) ||
          (_salePrice3 != null && _salePrice3! < _purchasePrice)) {
        CustomNotificationOverlay.show(
          context,
          'يجب أن تكون أسعار البيع أعلى من سعر الشراء',
          backgroundColor: Colors.red,
        );
        return;
      }

      final product = Product(
        id: widget.product?.id,
        productCode: _productCode,
        name: _name,
        imageUrl: _imageUrl,
        categoryId: _categoryId,
        barcode: _barcode,
        purchasePrice: _purchasePrice,
        salePrice1: _salePrice1,
        salePrice2: _salePrice2,
        salePrice3: _salePrice3,
        quantityInStock: _quantityInStock,
      );

      if (product.id == null) {
        await db.insertProduct(product.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(context, 'تم إضافة المنتج بنجاح!');
        }
      } else {
        await db.updateProduct(product.toMap());
        if (mounted) {
          CustomNotificationOverlay.show(context, 'تم تعديل المنتج بنجاح!');
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
      title: Text(widget.product == null ? 'إضافة منتج' : 'تعديل منتج'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                initialValue: _productCode,
                decoration: const InputDecoration(labelText: 'رمز المنتج'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رمز المنتج';
                  }
                  return null;
                },
                onSaved: (value) => _productCode = value!,
              ),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'اسم المنتج'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المنتج';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              DropdownButtonFormField<int?>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'الفئة'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('اختر الفئة'),
                  ),
                  ...widget.categories.map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _categoryId = value;
                  });
                },
                onSaved: (value) => _categoryId = value,
              ),
              TextFormField(
                initialValue: _barcode,
                decoration: const InputDecoration(labelText: 'الرمز الشريطي'),
                onSaved: (value) => _barcode = value,
              ),
              TextFormField(
                initialValue: _purchasePrice.toString(),
                decoration: const InputDecoration(labelText: 'سعر الشراء'),
                keyboardType:
                    TextInputType.number, // Changed to TextInputType.number
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال سعر الشراء';
                  }
                  if (double.tryParse(value) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
                onSaved: (value) => _purchasePrice = double.parse(value!),
              ),
              TextFormField(
                initialValue: _salePrice1.toString(),
                decoration: const InputDecoration(labelText: 'سعر البيع 1'),
                keyboardType:
                    TextInputType.number, // Changed to TextInputType.number
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال سعر البيع';
                  }
                  if (double.tryParse(value) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
                onSaved: (value) => _salePrice1 = double.parse(value!),
              ),
              TextFormField(
                initialValue: _salePrice2?.toString(),
                decoration: const InputDecoration(
                  labelText: 'سعر البيع 2 (اختياري)',
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => _salePrice2 = double.tryParse(value ?? ''),
              ),
              TextFormField(
                initialValue: _salePrice3?.toString(),
                decoration: const InputDecoration(
                  labelText: 'سعر البيع 3 (اختياري)',
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => _salePrice3 = double.tryParse(value ?? ''),
              ),
              TextFormField(
                initialValue: _quantityInStock.toString(),
                decoration: const InputDecoration(
                  labelText: 'الكمية في المخزون',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الكمية في المخزون';
                  }
                  if (int.tryParse(value) == null) {
                    return 'الرجاء إدخال عدد صحيح';
                  }
                  return null;
                },
                onSaved: (value) => _quantityInStock = int.parse(value!),
              ),
              const SizedBox(height: 16.0),
              _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  : _imageUrl != null
                  ? Image.file(
                      File(_imageUrl!),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  : const Text('لم يتم اختيار صورة.'),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('اختر صورة'),
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
        ElevatedButton(onPressed: _saveProduct, child: const Text('حفظ')),
      ],
    );
  }
}
