import 'dart:io';

import 'package:pcfitment/model/lang_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const dbName = 'pcFitment.db';
  static const dbVersion = 22;
  static const multipleUserTable = 'multipleUserTable';
  static const langTable = 'langTable';

  static const columnId = 'id';
  static const columnLoginUserName = 'username';
  static const columnLoginUserEmail = 'useremail';
  static const columnLoginUserPassword = 'password';
  static const columnLoginUserId = 'userid';

  static const columnLangKey = 'TextContent';
  static const columnLangCode = 'DefaultLanguageCode';
  static const columnLangVale = 'Translated';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    //String path = join(await getDatabasesPath(), dbName);
    String path = join(directory.path, dbName);
    return await openDatabase(path, version: dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createUserTable(db);
    await _createLangTable(db);
  }

  //TODO : User Table
  Future<void> _createUserTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $multipleUserTable (
      $columnId INTEGER PRIMARY KEY,
      $columnLoginUserName TEXT NOT NULL,
      $columnLoginUserEmail TEXT NOT NULL,
      $columnLoginUserPassword TEXT NOT NULL,
      $columnLoginUserId TEXT NOT NULL
    )
  ''');
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(
      multipleUserTable,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    Database db = await instance.database;
    return await db.query(multipleUserTable);
  }

  Future<int> updateUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(
      multipleUserTable,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    Database db = await instance.database;
    return await db.delete(
      multipleUserTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTable(String tableName) async {
    Database db = await instance.database;
    await db.rawQuery('DELETE FROM $tableName');
  }

  Future<List<Map<String, dynamic>>> getUserByUserId(String userId) async {
    Database db = await instance.database;
    return await db.query(multipleUserTable,
        where: '$columnLoginUserId = ?', whereArgs: [userId]);
  }

  static closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  Future<bool> tableExists() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$multipleUserTable'");
    return tables.isNotEmpty;
  }

  //TODO : Language Table
  Future<void> _createLangTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $langTable (
      $columnLangKey TEXT NOT NULL,
      $columnLangCode TEXT NOT NULL,
      $columnLangVale TEXT NOT NULL
    )
  ''');
  }

  Future<void> insertLang(List<LangModel> textContents) async {
    Database db = await instance.database;
    Batch batch = db.batch();
    for (var content in textContents) {
      batch.insert(
        langTable,
        content.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<LangModel>> getLang() async {
    final List<Map<String, dynamic>> maps = await _database!.query(langTable);
    return List.generate(maps.length, (index) {
      return LangModel(
        textContent: maps[index]['TextContent'],
        defaultLanguageCode: maps[index]['DefaultLanguageCode'],
        translated: maps[index]['Translated'],
      );
    });
  }
}
