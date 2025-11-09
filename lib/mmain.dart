import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}

class DbConstants {
  static const dbName = 'utilisateurs_database.db';
}

class DatabaseHelper {
  // Le "singleton" permet de s'assurer qu'on a toujours la même instance de la base de données
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), DbConstants.dbName);
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    } catch (e) {
      print('Erreur lors de l\'initialisation de la base de données: $e');
      rethrow;
    }
  }

  // Crée la table lors de la création de la base de données
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Utilisateur (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE
      )
    ''');
  }

}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magazine',
      debugShowCheckedModeBanner: false,
      home:const MyHomePage(title: 'Magazine Infos'),

    );
  }

}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          title: Text("Magazine Infos"),
          titleTextStyle:TextStyle(color: Colors.white,fontSize:20) ,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.menu,color: Colors.white,),
            onPressed: () {},
          ),
          actions: [IconButton(
            icon: const Icon(Icons.search,color: Colors.white,),
            onPressed: () {},
          ),],
        ),
        body: SingleChildScrollView(
          child:  Column( children:[
            Image(
                image:AssetImage('assets/images/427727.jpg',)
            ),
            PartieTitre(),
            PartieTexte(),
            PartieIcone(),
            PartieRubrique(),
          ]),
        ));
  }
}

class PartieTitre extends StatelessWidget {
  const PartieTitre({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        width: double.infinity ,
        padding: const EdgeInsets.all(20) ,
        child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                textAlign: TextAlign.center ,
                'Bienvenue au Magazine Infos Manga',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800 , ),
              ),
              Text(
                "Votre magazine numérique, votre source d'inspiration",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500 ),
                textAlign: TextAlign.center ,

              ),
            ]
        )
    );
  }
}

class PartieTexte extends StatelessWidget {
  const PartieTexte({super.key});

  @override
  Widget build(BuildContext contexte) {
    return Container(
        width: double.infinity ,
        padding: const EdgeInsets.all(10) ,
        child: const Text(
            "Ce si est un magazine qui vous informe et vous permet de trouver l'inspiration et des recomandations "
                "Ici vous trouverer largement ce qu'il faut pour vous travaillez, et aussi pour vous amusez."
                "Partant du dernier films de démon slayer a celui de chainsaw man vous aurais toute l'actualiter manga"
        )
    );
  }
}

class PartieIcone extends StatelessWidget {
  const PartieIcone({super.key});

  @override
  Widget build(BuildContext contexte) {
    return Container(
        padding: const EdgeInsets.only (bottom: 10) ,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column (
                children: [
                  const Icon(Icons.phone, color: Colors.pink),
                  const SizedBox(height: 5),
                  Text(
                    "Tel".toUpperCase(),
                    style: const TextStyle(color: Colors.pink),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column (
                children: [
                  const Icon(Icons.mail, color: Colors.pink),
                  const SizedBox(height: 5),
                  Text(
                    "Mail".toUpperCase(),
                    style: const TextStyle(color: Colors.pink),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column (
                children: [
                  const Icon(Icons.share, color: Colors.pink),
                  const SizedBox(height: 5),
                  Text(
                    "Partage".toUpperCase(),
                    style: const TextStyle(color: Colors.pink),
                  )
                ],
              ),
            )
          ],
        )
    );
  }
}

class PartieRubrique extends StatelessWidget {
  const PartieRubrique({super.key});

  @override
  Widget build(BuildContext contexte) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20) ,
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const Image(image: AssetImage('assets/images/itachi1.png'),width:200,),

                ),
                Text("     "),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const Image(image: AssetImage('assets/images/itachi-uchiha-naruto-amoled-black-background-minimal-art-3840x2160-6478.jpg'), width: 200,),
                )
              ],
            )
        ));
  }
}

