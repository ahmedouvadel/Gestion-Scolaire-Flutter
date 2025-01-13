import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'groupes_screen.dart';
import 'etudiants_screen.dart';

void main() async {
  // Initialisation de Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion de Scolarité', // Titre de l'application
      theme: ThemeData(
        primarySwatch: Colors.blue, // Couleur principale de l'application
        focusColor: Colors.orange, // Couleur d'accentuation
        fontFamily: 'Roboto', // Police d'écriture
        visualDensity: VisualDensity
            .adaptivePlatformDensity, // Pour une meilleure densité visuelle sur tous les appareils
      ),
      initialRoute: '/', // Page d'accueil par défaut
      routes: {
        '/': (context) => HomeScreen(), // Route vers l'écran principal
        '/groupes': (context) =>
            GroupesScreen(), // Route vers l'écran des groupes
        '/etudiants': (context) =>
            EtudiantsScreen(), // Route vers l'écran des étudiants
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion de Scolarité',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent, // Nouvelle couleur pour l'AppBar
      ),
      drawer: AppDrawer(), // Menu latéral
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0), // Espacement autour du texte
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Centrer verticalement
            children: [
              Icon(Icons.school,
                  size: 100, color: Colors.blueAccent), // Icône scolaire
              SizedBox(height: 20),
              Text(
                'Bienvenue dans la Gestion de Scolarité',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Gérez vos groupes et étudiants avec facilité.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
                color: Colors
                    .blueAccent), // Changement de couleur de fond du header
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person,
                      size: 50, color: Colors.blueAccent), // Icône de profil
                ),
                SizedBox(height: 10),
                Text(
                  'Vadel ', // Nom de l'utilisateur
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Liste des éléments du menu
          ListTile(
            leading: Icon(Icons.group, color: Colors.blueAccent),
            title: Text('Groupes',
                style: TextStyle(fontSize: 18, color: Colors.black87)),
            onTap: () {
              Navigator.pushNamed(context, '/groupes');
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.blueAccent),
            title: Text('Étudiants',
                style: TextStyle(fontSize: 18, color: Colors.black87)),
            onTap: () {
              Navigator.pushNamed(context, '/etudiants');
            },
          ),
        ],
      ),
    );
  }
}
