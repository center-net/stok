CREATE TABLE IF NOT EXISTS Users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    role TEXT NOT NULL CHECK(role IN ('manager', 'observer', 'seller', 'customer')),
    phone_number TEXT
);

CREATE TABLE IF NOT EXISTS Vendors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    phone_number TEXT,
    address TEXT
);

CREATE TABLE IF NOT EXISTS Stores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    store_number TEXT NOT NULL UNIQUE,
    phone_number TEXT,
    manager_id INTEGER,
    address TEXT,
    FOREIGN KEY (manager_id) REFERENCES Users(id)
);

CREATE TABLE IF NOT EXISTS Categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    image_url TEXT,
    category_id INTEGER,
    barcode TEXT UNIQUE,
    purchase_price REAL NOT NULL,
    sale_price_1 REAL NOT NULL,
    sale_price_2 REAL,
    sale_price_3 REAL,
    quantity_in_stock INTEGER DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES Categories(id),
    CHECK (sale_price_1 >= purchase_price),
    CHECK (sale_price_2 IS NULL OR sale_price_2 >= purchase_price),
    CHECK (sale_price_3 IS NULL OR sale_price_3 >= purchase_price)
);

CREATE TABLE IF NOT EXISTS PurchaseInvoices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice_number TEXT NOT NULL UNIQUE,
    invoice_date TEXT NOT NULL,
    vendor_id INTEGER,
    total_amount REAL NOT NULL,
    paid_amount REAL NOT NULL,
    remaining_amount REAL NOT NULL,
    FOREIGN KEY (vendor_id) REFERENCES Vendors(id)
);

CREATE TABLE IF NOT EXISTS PurchaseInvoiceDetails (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_invoice_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    purchase_price REAL NOT NULL,
    FOREIGN KEY (purchase_invoice_id) REFERENCES PurchaseInvoices(id),
    FOREIGN KEY (product_id) REFERENCES Products(id)
);

CREATE TABLE IF NOT EXISTS SaleInvoices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    invoice_number TEXT NOT NULL UNIQUE,
    invoice_date TEXT NOT NULL,
    customer_id INTEGER,
    total_amount REAL NOT NULL,
    paid_amount REAL NOT NULL,
    remaining_amount REAL NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Users(id)
);

CREATE TABLE IF NOT EXISTS SaleInvoiceDetails (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sale_invoice_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    sale_price REAL NOT NULL,
    FOREIGN KEY (sale_invoice_id) REFERENCES SaleInvoices(id),
    FOREIGN KEY (product_id) REFERENCES Products(id)
);

CREATE TABLE IF NOT EXISTS Serials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    serial_number TEXT NOT NULL UNIQUE,
    purchase_invoice_detail_id INTEGER,
    sale_invoice_detail_id INTEGER,
    status TEXT NOT NULL DEFAULT 'in_stock' CHECK(status IN ('in_stock', 'sold', 'returned_purchase', 'returned_sale')),
    FOREIGN KEY (product_id) REFERENCES Products(id),
    FOREIGN KEY (purchase_invoice_detail_id) REFERENCES PurchaseInvoiceDetails(id),
    FOREIGN KEY (sale_invoice_detail_id) REFERENCES SaleInvoiceDetails(id)
);

CREATE TABLE IF NOT EXISTS PurchaseReturns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    purchase_invoice_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    return_date TEXT NOT NULL,
    reason TEXT,
    FOREIGN KEY (purchase_invoice_id) REFERENCES PurchaseInvoices(id),
    FOREIGN KEY (product_id) REFERENCES Products(id)
);

CREATE TABLE IF NOT EXISTS SaleReturns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sale_invoice_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    return_date TEXT NOT NULL,
    reason TEXT,
    FOREIGN KEY (sale_invoice_id) REFERENCES SaleInvoices(id),
    FOREIGN KEY (product_id) REFERENCES Products(id)
);
