import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


const String idColumn = "idColumn";
const String nameColumn = "nameColumn";
const String emailColumn = "emailColumn";
const String imageColumn = "imageColumn";
const String photoColumn = "photoColumn";
const String table = "contactTable";
const String query = 'CREATE TABLE $table ($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,$photoColumn TEXT,$imageColumn TEXT)';

class ContactHelper{
 static final ContactHelper _intance = ContactHelper.internal();
  factory ContactHelper() => _intance;
  ContactHelper.internal();

  late Database _db;

  Future<Database> get db async {
    if(_db!=null){
      return _db;
    }else{
      _db = await initDb();
      return _db;
    }
    
  }
  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contatc.db");
    return await openDatabase(path,version: 1,onCreate: (Database db,int newerVersion)async{
      await db.execute(query);
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(table, contact.toMap());
    return contact;
  }
 Future<int> deleteContact(int id)async {
    Database dbContact = await db;
    return await dbContact.delete(table,where: "$idColumn = ?",whereArgs: [id]);
  }
  Future<int> updateContact(Contact contact)async{
    Database dbContact = await db;
    return await dbContact.update(table, contact.toMap(), where: "$idColumn = ?",whereArgs: [contact.id]);
  }
 Future<List<Contact>> getAllContacts()async{
    Database dbContact = await db;
    List mapList = await dbContact.rawQuery("SELECT * FROM $table");
    List<Contact> listContacts = [];
    for(Map map in mapList){
      listContacts.add(Contact.fromMap(map));
    }
    return listContacts;
  }

  Future<int> getNamber()async{
    Database dbContact = await db;
    return await Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $table"));

  }
Future<void> close() async {
  Database dbContact = await db;
  await dbContact.close();

}
  Future<Contact> getContact(int id) async{
    Database dbContact = await db;
    List<Map<String,dynamic>> maps = dbContact.query(
      table,
      columns: [idColumn,nameColumn,emailColumn,photoColumn,imageColumn],
      where: "$idColumn = ?",
      whereArgs: [id]
    ) as List<Map<String, dynamic>>;
    return Contact.fromMap(maps.first);
  }
}



class Contact{
 
  int? id;
  String? name;
  String? photo;
  String? email;
  String? image;

  Contact.fromMap(Map map){
    id = map[idColumn];
    name = map[nameColumn];
    photo = map[photoColumn];
    email = map[emailColumn];
    image = map[imageColumn];
    
  }
  Map<String,dynamic> toMap(){
    Map <String,dynamic> map ={
      nameColumn:name,
      photoColumn:photo,
      emailColumn:email,
      imageColumn:image

    };
      if(id!=null){
        map[idColumn] = id;
      }
    return map;
  }

  @override
  String toString() {
    
    return "{Contact{id: $id, name:$name,email:$email,photo:$photo,image:$image}}";
  }
}