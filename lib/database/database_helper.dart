import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';
import '../models/business_profile.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/line_item.dart';
import '../models/payment.dart';
import '../models/app_settings.dart';
import 'tables.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${Tables.businessProfile} (
        id INTEGER PRIMARY KEY,
        first_name TEXT NOT NULL,
        middle_name TEXT,
        last_name TEXT NOT NULL,
        address1 TEXT,
        address2 TEXT,
        address3 TEXT,
        city TEXT,
        state TEXT,
        country TEXT,
        district TEXT,
        pin_code TEXT,
        phone TEXT,
        email TEXT,
        logo_path TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${Tables.customers} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        middle_name TEXT,
        last_name TEXT NOT NULL,
        address1 TEXT,
        address2 TEXT,
        address3 TEXT,
        city TEXT,
        state TEXT,
        country TEXT,
        district TEXT,
        pin_code TEXT,
        phone TEXT,
        email TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${Tables.invoices} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        invoice_no INTEGER NOT NULL,
        date TEXT NOT NULL,
        total_amount REAL NOT NULL DEFAULT 0,
        cgst_rate REAL NOT NULL DEFAULT 0,
        sgst_rate REAL NOT NULL DEFAULT 0,
        cgst_amount REAL NOT NULL DEFAULT 0,
        sgst_amount REAL NOT NULL DEFAULT 0,
        net_payable REAL NOT NULL DEFAULT 0,
        amount_paid REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'unpaid',
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (customer_id) REFERENCES ${Tables.customers}(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX idx_invoice_customer_no
      ON ${Tables.invoices}(customer_id, invoice_no)
    ''');

    await db.execute('''
      CREATE TABLE ${Tables.lineItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        item_no INTEGER NOT NULL,
        description TEXT NOT NULL,
        mm REAL,
        hh REAL,
        w REAL,
        nos REAL,
        qty REAL NOT NULL,
        rate REAL NOT NULL,
        amount REAL NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES ${Tables.invoices}(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${Tables.payments} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        created_at TEXT,
        FOREIGN KEY (invoice_id) REFERENCES ${Tables.invoices}(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${Tables.appSettings} (
        id INTEGER PRIMARY KEY,
        cgst_rate REAL NOT NULL DEFAULT ${AppConstants.defaultCgstRate},
        sgst_rate REAL NOT NULL DEFAULT ${AppConstants.defaultSgstRate}
      )
    ''');

    await db.insert(Tables.appSettings, {
      'id': 1,
      'cgst_rate': AppConstants.defaultCgstRate,
      'sgst_rate': AppConstants.defaultSgstRate,
    });
  }

  // ---------- Business Profile ----------

  Future<BusinessProfile?> getBusinessProfile() async {
    final db = await database;
    final rows =
        await db.query(Tables.businessProfile, where: 'id = 1', limit: 1);
    if (rows.isEmpty) return null;
    return BusinessProfile.fromMap(rows.first);
  }

  Future<int> saveBusinessProfile(BusinessProfile profile) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final existing = await getBusinessProfile();
    if (existing == null) {
      return db.insert(
        Tables.businessProfile,
        profile.copyWith(id: 1, createdAt: now, updatedAt: now).toMap(),
      );
    } else {
      return db.update(
        Tables.businessProfile,
        profile.copyWith(updatedAt: now).toMap(),
        where: 'id = 1',
      );
    }
  }

  // ---------- Customers ----------

  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT c.*,
        COALESCE(
          (SELECT SUM(i.net_payable - i.amount_paid)
           FROM ${Tables.invoices} i
           WHERE i.customer_id = c.id AND i.status != 'fully_paid'),
          0
        ) AS outstanding_balance
      FROM ${Tables.customers} c
      ORDER BY c.first_name, c.last_name
    ''');
    return rows.map(Customer.fromMap).toList();
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await database;
    final rows = await db.query(Tables.customers, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Customer.fromMap(rows.first);
  }

  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return db.insert(
      Tables.customers,
      customer.copyWith(createdAt: now, updatedAt: now).toMap(),
    );
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return db.update(
      Tables.customers,
      customer.copyWith(updatedAt: now).toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return db.delete(Tables.customers, where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Invoices ----------

  Future<List<Invoice>> getInvoicesByCustomer(int customerId,
      {String? statusFilter}) async {
    final db = await database;
    final where = statusFilter != null
        ? 'customer_id = ? AND status = ?'
        : 'customer_id = ?';
    final args =
        statusFilter != null ? [customerId, statusFilter] : [customerId];
    final rows = await db.query(
      Tables.invoices,
      where: where,
      whereArgs: args,
      orderBy: 'invoice_no DESC',
    );
    return rows.map(Invoice.fromMap).toList();
  }

  Future<Invoice?> getInvoiceById(int id) async {
    final db = await database;
    final rows =
        await db.query(Tables.invoices, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final invoice = Invoice.fromMap(rows.first);
    final items = await getLineItemsByInvoice(id);
    final pays = await getPaymentsByInvoice(id);
    return invoice.copyWith(lineItems: items, payments: pays);
  }

  Future<int> getNextInvoiceNo(int customerId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(MAX(invoice_no), 0) + 1 AS next_no FROM ${Tables.invoices} WHERE customer_id = ?',
      [customerId],
    );
    return result.first['next_no'] as int;
  }

  Future<int> insertInvoice(Invoice invoice, List<LineItem> items) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    int invoiceId = 0;
    await db.transaction((txn) async {
      invoiceId = await txn.insert(
        Tables.invoices,
        invoice.copyWith(createdAt: now, updatedAt: now).toMap(),
      );
      for (var i = 0; i < items.length; i++) {
        await txn.insert(
          Tables.lineItems,
          items[i]
              .copyWith(invoiceId: invoiceId, itemNo: i + 1)
              .toMap(),
        );
      }
    });
    return invoiceId;
  }

  Future<int> updateInvoice(Invoice invoice, List<LineItem> items) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.update(
        Tables.invoices,
        invoice.copyWith(updatedAt: now).toMap(),
        where: 'id = ?',
        whereArgs: [invoice.id],
      );
      await txn.delete(
        Tables.lineItems,
        where: 'invoice_id = ?',
        whereArgs: [invoice.id],
      );
      for (var i = 0; i < items.length; i++) {
        await txn.insert(
          Tables.lineItems,
          items[i]
              .copyWith(invoiceId: invoice.id, itemNo: i + 1)
              .toMap(),
        );
      }
    });
    return invoice.id!;
  }

  Future<void> updateInvoicePayment(
      int invoiceId, double amountPaid, String status) async {
    final db = await database;
    await db.update(
      Tables.invoices,
      {
        'amount_paid': amountPaid,
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
  }

  Future<int> deleteInvoice(int invoiceId) async {
    final db = await database;
    return db.transaction((txn) async {
      await txn.delete(
        Tables.payments,
        where: 'invoice_id = ?',
        whereArgs: [invoiceId],
      );
      await txn.delete(
        Tables.lineItems,
        where: 'invoice_id = ?',
        whereArgs: [invoiceId],
      );
      return txn.delete(
        Tables.invoices,
        where: 'id = ?',
        whereArgs: [invoiceId],
      );
    });
  }

  // ---------- Line Items ----------

  Future<List<LineItem>> getLineItemsByInvoice(int invoiceId) async {
    final db = await database;
    final rows = await db.query(
      Tables.lineItems,
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
      orderBy: 'item_no ASC',
    );
    return rows.map(LineItem.fromMap).toList();
  }

  // ---------- Payments ----------

  Future<List<Payment>> getPaymentsByInvoice(int invoiceId) async {
    final db = await database;
    final rows = await db.query(
      Tables.payments,
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
      orderBy: 'date ASC',
    );
    return rows.map(Payment.fromMap).toList();
  }

  Future<int> insertPayment(Payment payment, double newAmountPaid,
      double netPayable) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    int paymentId = 0;
    await db.transaction((txn) async {
      paymentId = await txn.insert(
        Tables.payments,
        payment.copyWith(createdAt: now).toMap(),
      );
      final newStatus = newAmountPaid >= netPayable
          ? 'fully_paid'
          : 'partially_paid';
      await txn.update(
        Tables.invoices,
        {
          'amount_paid': newAmountPaid,
          'status': newStatus,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [payment.invoiceId],
      );
    });
    return paymentId;
  }

  Future<void> markInvoiceFullyPaid(int invoiceId) async {
    final db = await database;
    await db.update(
      Tables.invoices,
      {
        'status': 'fully_paid',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
  }

  // ---------- Settings ----------

  Future<AppSettings> getSettings() async {
    final db = await database;
    final rows = await db.query(Tables.appSettings, where: 'id = 1', limit: 1);
    if (rows.isEmpty) return const AppSettings();
    return AppSettings.fromMap(rows.first);
  }

  Future<int> updateSettings(AppSettings settings) async {
    final db = await database;
    return db.update(
      Tables.appSettings,
      settings.toMap(),
      where: 'id = 1',
    );
  }

  // ---------- Export / Import ----------

  Future<Map<String, dynamic>> exportAllData() async {
    final db = await database;
    return {
      'metadata': {
        'exported_at': DateTime.now().toIso8601String(),
        'version': AppConstants.dbVersion,
      },
      Tables.businessProfile: await db.query(Tables.businessProfile),
      Tables.customers: await db.query(Tables.customers),
      Tables.invoices: await db.query(Tables.invoices),
      Tables.lineItems: await db.query(Tables.lineItems),
      Tables.payments: await db.query(Tables.payments),
      Tables.appSettings: await db.query(Tables.appSettings),
    };
  }

  Future<void> importAllData(Map<String, dynamic> data) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final table in [
        Tables.payments,
        Tables.lineItems,
        Tables.invoices,
        Tables.customers,
        Tables.businessProfile,
        Tables.appSettings,
      ]) {
        await txn.delete(table);
      }
      for (final row
          in (data[Tables.businessProfile] as List<dynamic>? ?? [])) {
        await txn.insert(Tables.businessProfile,
            Map<String, dynamic>.from(row as Map));
      }
      for (final row in (data[Tables.customers] as List<dynamic>? ?? [])) {
        await txn.insert(
            Tables.customers, Map<String, dynamic>.from(row as Map));
      }
      for (final row in (data[Tables.invoices] as List<dynamic>? ?? [])) {
        await txn.insert(
            Tables.invoices, Map<String, dynamic>.from(row as Map));
      }
      for (final row in (data[Tables.lineItems] as List<dynamic>? ?? [])) {
        await txn.insert(
            Tables.lineItems, Map<String, dynamic>.from(row as Map));
      }
      for (final row in (data[Tables.payments] as List<dynamic>? ?? [])) {
        await txn.insert(
            Tables.payments, Map<String, dynamic>.from(row as Map));
      }
      for (final row in (data[Tables.appSettings] as List<dynamic>? ?? [])) {
        await txn.insert(
            Tables.appSettings, Map<String, dynamic>.from(row as Map));
      }
    });
  }
}
