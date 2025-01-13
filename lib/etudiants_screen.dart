import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// Classe principale de l'écran qui gère l'affichage des étudiants
class EtudiantsScreen extends StatefulWidget {
  @override
  _EtudiantsScreenState createState() => _EtudiantsScreenState();
}

// État associé à l'écran principal, gère la logique de l'interface utilisateur
class _EtudiantsScreenState extends State<EtudiantsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _dateNaissController = TextEditingController();
  String? _selectedGroupId; // Variable pour stocker le groupe sélectionné
  String _searchQuery = ''; // Variable pour stocker la requête de recherche

  // Récupère les groupes depuis Firestore pour remplir le menu déroulant
  Future<List<QueryDocumentSnapshot>> _fetchGroups() async {
    final groupsSnapshot = await FirebaseFirestore.instance.collection('groupes').get();
    return groupsSnapshot.docs;
  }

  // Fonction pour ajouter un nouvel étudiant
  void _addEtudiant(BuildContext context) async {
    final groups = await _fetchGroups(); // Récupère les groupes

    // Affiche une boîte de dialogue pour saisir les informations d'un nouvel étudiant
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: Text('Ajouter un Étudiant'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _nomController, // Contrôleur pour le nom
                    decoration: InputDecoration(labelText: 'Nom'),
                  ),
                  TextField(
                    controller: _prenomController, // Contrôleur pour le prénom
                    decoration: InputDecoration(labelText: 'Prénom'),
                  ),
                  TextField(
                    controller: _telController, // Contrôleur pour le téléphone
                    decoration: InputDecoration(labelText: 'Téléphone'),
                    keyboardType: TextInputType.phone, // Spécifie le type de clavier pour le téléphone
                  ),
                  TextField(
                    controller: _dateNaissController, // Contrôleur pour la date de naissance
                    decoration: InputDecoration(labelText: 'Date de Naissance'),
                    readOnly: true, // Rendre le champ en lecture seule
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      // Si une date est choisie, on la met dans le champ
                      if (pickedDate != null) {
                        _dateNaissController.text = pickedDate.toIso8601String().split('T')[0];
                      }
                    },
                  ),
                  // Menu déroulant pour sélectionner un groupe
                  DropdownButtonFormField<String>(
                    value: _selectedGroupId,
                    items: groups.map((group) {
                      return DropdownMenuItem<String>(
                        value: group.id, // ID du groupe
                        child: Text(group['libelle']), // Nom du groupe
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGroupId = value; // Mettre à jour le groupe sélectionné
                      });
                    },
                    decoration: InputDecoration(labelText: 'Groupe'),
                  ),
                ],
              ),
            ),
            actions: [
              // Bouton pour ajouter l'étudiant
              TextButton(
                onPressed: () {
                  // Vérifie que tous les champs sont remplis
                  if (_nomController.text.isNotEmpty &&
                      _prenomController.text.isNotEmpty &&
                      _telController.text.isNotEmpty &&
                      _dateNaissController.text.isNotEmpty &&
                      _selectedGroupId != null) {
                    // Ajoute l'étudiant dans la collection Firestore
                    FirebaseFirestore.instance.collection('etudiants').add({
                      'nom': _nomController.text,
                      'prenom': _prenomController.text,
                      'tel': _telController.text,
                      'date_naiss': _dateNaissController.text,
                      'groupe_id': _selectedGroupId,
                    });

                    // Réinitialise les champs
                    _nomController.clear();
                    _prenomController.clear();
                    _telController.clear();
                    _dateNaissController.clear();
                    _selectedGroupId = null;

                    // Ferme la boîte de dialogue
                    Navigator.of(ctx).pop();
                  } else {
                    // Si des champs sont vides, affiche un message d'erreur
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Veuillez remplir tous les champs')),
                    );
                  }
                },
                child: Text('Ajouter'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Fonction pour modifier les informations d'un étudiant
  void _editEtudiant(BuildContext context, DocumentSnapshot etudiant) async {
    _nomController.text = etudiant['nom'];
    _prenomController.text = etudiant['prenom'];
    _telController.text = etudiant['tel'];
    _dateNaissController.text = etudiant['date_naiss'];
    _selectedGroupId = etudiant['groupe_id'];

    // Récupère les groupes pour remplir le menu déroulant
    final groups = await _fetchGroups();

    // Affiche une boîte de dialogue pour modifier un étudiant
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Modifier un Étudiant',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Champ pour modifier le nom
                    TextField(
                      controller: _nomController,
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        labelStyle: TextStyle(color: Colors.blue),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Champ pour modifier le prénom
                    TextField(
                      controller: _prenomController,
                      decoration: InputDecoration(
                        labelText: 'Prénom',
                        labelStyle: TextStyle(color: Colors.blue),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Champ pour modifier le téléphone
                    TextField(
                      controller: _telController,
                      decoration: InputDecoration(
                        labelText: 'Téléphone',
                        labelStyle: TextStyle(color: Colors.blue),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 12),
                    // Champ pour modifier la date de naissance
                    TextField(
                      controller: _dateNaissController,
                      decoration: InputDecoration(
                        labelText: 'Date de Naissance',
                        labelStyle: TextStyle(color: Colors.blue),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          _dateNaissController.text = pickedDate.toIso8601String().split('T')[0];
                        }
                      },
                    ),
                    SizedBox(height: 12),
                    // Menu déroulant pour modifier le groupe
                    DropdownButtonFormField<String>(
                      value: _selectedGroupId,
                      items: groups.map((group) {
                        return DropdownMenuItem<String>(
                          value: group.id,
                          child: Text(group['libelle']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGroupId = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Groupe',
                        labelStyle: TextStyle(color: Colors.blue),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              // Bouton pour modifier l'étudiant
              TextButton(
                onPressed: () {
                  if (_nomController.text.isNotEmpty &&
                      _prenomController.text.isNotEmpty &&
                      _telController.text.isNotEmpty &&
                      _dateNaissController.text.isNotEmpty &&
                      _selectedGroupId != null) {
                    // Mise à jour de l'étudiant dans Firestore
                    FirebaseFirestore.instance.collection('etudiants').doc(etudiant.id).update({
                      'nom': _nomController.text,
                      'prenom': _prenomController.text,
                      'tel': _telController.text,
                      'date_naiss': _dateNaissController.text,
                      'groupe_id': _selectedGroupId,
                    });

                    // Réinitialise les champs
                    _nomController.clear();
                    _prenomController.clear();
                    _telController.clear();
                    _dateNaissController.clear();
                    _selectedGroupId = null;

                    // Ferme la boîte de dialogue
                    Navigator.of(ctx).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Veuillez remplir tous les champs')),
                    );
                  }
                },
                child: Text('Modifier'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Fonction pour appeler un étudiant
  Future<void> _makeCall(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  // Fonction pour gérer la recherche en temps réel
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Fonction pour afficher la liste des étudiants
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Étudiants'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged, // Gère les changements dans le champ de recherche
              decoration: InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('etudiants').snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // Filtre les étudiants en fonction de la requête de recherche
                final filteredStudents = snapshot.data!.docs.where((etudiant) {
                  return etudiant['nom']
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                      etudiant['prenom']
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredStudents.length,
                  itemBuilder: (ctx, index) {
                    final etudiant = filteredStudents[index];
                    return ListTile(
                      title: Text('${etudiant['nom']} ${etudiant['prenom']}'),
                      subtitle: Text(etudiant['tel']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icône d'appel téléphonique
                          IconButton(
                            icon: Icon(Icons.phone),
                            onPressed: () => _makeCall(etudiant['tel']),
                          ),
                          // Icône de suppression
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Confirmation avant suppression
                              FirebaseFirestore.instance.collection('etudiants').doc(etudiant.id).delete();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEtudiant(context), // Ouvre le formulaire d'ajout
        child: Icon(Icons.add),
      ),
    );
  }
}
