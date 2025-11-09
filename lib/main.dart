import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

// --- Modèle de données ---
class Redacteur {
  final int? id;
  final String nom;
  final String prenom;
  final String email;

  Redacteur({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
  });


  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'nom': nom,
      'prenom': prenom,
      'email': email,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

}


class DatabaseManager {
  static const _databaseName = "Redacteurs.db";
  static const _databaseVersion = 1;

  static const table = 'redacteurs';

  static const columnId = 'id';
  static const columnNom = 'nom';
  static const columnPrenom = 'prenom';
  static const columnEmail = 'email';


  DatabaseManager._privateConstructor();

  static final DatabaseManager instance = DatabaseManager._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = p.join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }


  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnNom TEXT NOT NULL,
            $columnPrenom TEXT NOT NULL,
            $columnEmail TEXT NOT NULL UNIQUE -- AMÉLIORATION : Empêche les doublons d'email
          )
          ''');
  }

  Future<int> insertRedacteur(Redacteur redacteur) async {
    Database db = await instance.database;
    return await db.insert(table, redacteur.toMap());
  }


  Future<List<Redacteur>> getAllRedacteurs() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
        table, orderBy: '$columnNom ASC');

    return List.generate(maps.length, (i) {
      return Redacteur(
        id: maps[i]['id'],
        nom: maps[i]['nom'],
        prenom: maps[i]['prenom'],
        email: maps[i]['email'],
      );
    });
  }


  Future<int> updateRedacteur(Redacteur redacteur) async {
    Database db = await instance.database;
    return await db.update(
      table,
      redacteur.toMap(),
      where: '$columnId = ?',
      whereArgs: [redacteur.id],
    );
  }

  // Supprimer un rédacteur
  Future<int> deleteRedacteur(int id) async {
    Database db = await instance.database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MonApplication());
}

class MonApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion des Rédacteurs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: RedacteurInterface(),
    );
  }
}


class RedacteurInterface extends StatefulWidget {
  @override
  _RedacteurInterfaceState createState() => _RedacteurInterfaceState();
}

class _RedacteurInterfaceState extends State<RedacteurInterface> {
  final _formKey = GlobalKey<
      FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();

  List<Redacteur> _redacteurs = [];
  Redacteur? _redacteurSelectionne;

  @override
  void initState() {
    super.initState();
    _loadRedacteurs();
  }


  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadRedacteurs() async {
    final data = await DatabaseManager.instance.getAllRedacteurs();
    setState(() {
      _redacteurs = data;
    });
  }


  void _afficherDialogueDeModification(Redacteur redacteur) {
    // On crée des controllers spécifiques pour le dialogue
    final _dialogFormKey = GlobalKey<FormState>();
    final _nomDialogController = TextEditingController(text: redacteur.nom);
    final _prenomDialogController = TextEditingController(
        text: redacteur.prenom);
    final _emailDialogController = TextEditingController(text: redacteur.email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier le rédacteur'),
          content: Form(
            key: _dialogFormKey,
            child: SingleChildScrollView( // Pour éviter les problèmes de clavier
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nomDialogController,
                    decoration: InputDecoration(labelText: 'Nom'),
                    validator: (value) =>
                    value!.isEmpty
                        ? 'Le nom ne peut pas être vide'
                        : null,
                  ),
                  TextFormField(
                    controller: _prenomDialogController,
                    decoration: InputDecoration(labelText: 'Prénom'),
                    validator: (value) =>
                    value!.isEmpty
                        ? 'Le prénom ne peut pas être vide'
                        : null,
                  ),
                  TextFormField(
                    controller: _emailDialogController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                    value!.isEmpty
                        ? 'L\'email ne peut pas être vide'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_dialogFormKey.currentState!.validate()) {
                  final updatedRedacteur = Redacteur(
                    id: redacteur.id,
                    nom: _nomDialogController.text,
                    prenom: _prenomDialogController.text,
                    email: _emailDialogController.text,
                  );
                  await DatabaseManager.instance.updateRedacteur(
                      updatedRedacteur);
                  Navigator.of(context).pop(); // Ferme le dialogue
                  _loadRedacteurs(); // Met à jour la liste
                }
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }  void _ajouterOuModifierRedacteur({Redacteur? redacteur}) {

    if (redacteur != null) {
      _redacteurSelectionne = redacteur;
      _nomController.text = redacteur.nom;
      _prenomController.text = redacteur.prenom;
      _emailController.text = redacteur.email;
    } else {
      _redacteurSelectionne = null;
      _nomController.clear();
      _prenomController.clear();
      _emailController.clear();
    }
  }

  void _onEnregistrer() async {
    // AMÉLIORATION : On vérifie que les champs ne sont pas vides.
    if (_formKey.currentState!.validate()) {
      if (_redacteurSelectionne == null) {
        // Mode AJOUT
        final newRedacteur = Redacteur(
          nom: _nomController.text,
          prenom: _prenomController.text,
          email: _emailController.text,
        );
        await DatabaseManager.instance.insertRedacteur(newRedacteur);
      } else {
        // Mode MODIFICATION
        final updatedRedacteur = Redacteur(
          id: _redacteurSelectionne!.id,
          nom: _nomController.text,
          prenom: _prenomController.text,
          email: _emailController.text,
        );
        await DatabaseManager.instance.updateRedacteur(updatedRedacteur);
      }
      _viderFormulaire();
      _loadRedacteurs();
    }
  }

  void _viderFormulaire() {
    _formKey.currentState?.reset();
    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();
    setState(() {
      _redacteurSelectionne = null;
    });
  }

  void _confirmerSuppression(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce rédacteur ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                await DatabaseManager.instance.deleteRedacteur(id);
                _loadRedacteurs();
                Navigator.of(context).pop();
              },
              child: Text('Supprimer'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
      backgroundColor: Colors.pink,
      title: Text("Gestion des Rédacteurs"),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0), // AMÉLIORATION : Plus d'espacement
        child: Column(
          children: [
            // --- Formulaire unifié pour l'ajout et la modification ---
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: InputDecoration(
                        labelText: 'Nom', border: OutlineInputBorder()),
                    validator: (value) =>
                    value!.isEmpty
                        ? 'Veuillez entrer un nom'
                        : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _prenomController,
                    decoration: InputDecoration(
                        labelText: 'Prénom', border: OutlineInputBorder()),
                    validator: (value) =>
                    value!.isEmpty
                        ? 'Veuillez entrer un prénom'
                        : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        labelText: 'Email', border: OutlineInputBorder()),
                    validator: (value) =>
                    value!.isEmpty
                        ? 'Veuillez entrer un email'
                        : null,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _onEnregistrer,
                        icon: Icon(
                            _redacteurSelectionne == null ? Icons.add : Icons
                                .save),
                        label: Text(_redacteurSelectionne == null
                            ? 'Ajouter'
                            : 'Enregistrer'),
                      ),

                    ],
                  ),
                ],
              ),
            ),
            // --- Séparateur ---
            Divider(height: 40),
            // --- Liste des Rédacteurs ---
            Text('Liste des Rédacteurs', style: Theme
                .of(context)
                .textTheme
                .headlineSmall),
            Expanded(
              child: _redacteurs.isEmpty
                  ? Center(child: Text("Aucun rédacteur pour l'instant."))
                  : ListView.builder(
                itemCount: _redacteurs.length,
                itemBuilder: (context, index) {
                  final redacteur = _redacteurs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text('${redacteur.prenom} ${redacteur.nom}'),
                      subtitle: Text(redacteur.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _afficherDialogueDeModification(redacteur),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _confirmerSuppression(redacteur.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}