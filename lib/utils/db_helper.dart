import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
class DatabaseHelper
{
  static final _dbname = 'newnote.db';
  static final _dbversion = 1;
  static final tableName = 'notes';
  static final columnId = 'id';
  static final columnTitle = 'title';
  static final columnDesc = 'desc';
  
  static final columnDate = 'date';

  static Database? _database;
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbname);
    return await openDatabase(path, version:_dbversion, onCreate: _onCreate);
  }
  Future _onCreate(Database db,int version) async{
    await db.execute('''
    CREATE TABLE $tableName(
    $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
    $columnTitle TEXT NOT NULL,
    $columnDesc TEXT NOT NULL,
    $columnDate TEXT NOT NULL
    )

''');
  }
  Future<int> insert(Map<String,dynamic> row) async{
    Database db = await instance.database;
    return await db.insert(tableName, row);
  }
  Future<List<Map<String,dynamic>>> queryAll() async{
    Database db = await instance.database;
    return await db.query(tableName);
  }
  Future<List<Map<String, dynamic>>> searchQuery(String searchString) async {
    Database db = await instance.database;
    return await db.rawQuery(''' 
    Select * from $tableName where $columnTitle like %$searchString%
    
   
    ''');
    //return await db.query(_tableName, where: 'title LIKE ? ' whereArgs: [searchString]);
  }
  //delete
  Future<int> delete(int id) async{
    Database db = await instance.database;
    return await db.delete(tableName,where: '$columnId = ?',whereArgs: [id]);

    // return db.rawDelete('''

    // DELETE FROM $_tableName WHERE _id = ? whereArgs: [$sid] 
    // ''');
  }
Future<int> update(Map<String, dynamic> row) async {
  Database db = await instance.database;
  int id = row[columnId]; // Assuming 'columnId' is the key for the ID in your map

  // Convert DateTime objects to a suitable format before updating
  if (row[columnDate] is DateTime) {
    row[columnDate] = row[columnDate].toIso8601String();
  }

  return await db.update(tableName, row, where: '$columnId = ?', whereArgs: [id]);
}


}
