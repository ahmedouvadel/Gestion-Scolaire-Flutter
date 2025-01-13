import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupesScreen extends StatelessWidget {
  // Contrôleur de texte pour le champ d'ajout ou de modification du groupe
  final TextEditingController _libelleController = TextEditingController();

  // Fonction pour ajouter un groupe
  void _addGroup(BuildContext context) {
    // Affichage d'une boîte de dialogue pour saisir le nom du groupe
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Ajouter un Groupe', // Titre du dialogue
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        content: TextField(
          controller: _libelleController, // Contrôleur pour le champ de texte
          decoration: InputDecoration(
            labelText: 'Libellé', // Texte explicatif du champ
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(12), // Coins arrondis pour un design moderne
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          // Bouton pour ajouter le groupe
          TextButton(
            onPressed: () {
              // Ajout du groupe dans Firestore
              FirebaseFirestore.instance.collection('groupes').add({
                'libelle': _libelleController.text, // Libellé du groupe
              });
              _libelleController.clear(); // Réinitialiser le champ
              Navigator.of(ctx).pop(); // Fermer la boîte de dialogue
            },
            child: Text(
              'Ajouter',
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue, // Couleur du bouton
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Coins arrondis
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour modifier un groupe existant
  void _editGroup(BuildContext context, String groupeId, String currentLibelle) {
    _libelleController.text = currentLibelle; // Pré-remplir le champ avec le libellé actuel
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Modifier le Groupe',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        content: TextField(
          controller: _libelleController,
          decoration: InputDecoration(
            labelText: 'Libellé',
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(12),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          // Bouton pour mettre à jour le groupe
          TextButton(
            onPressed: () {
              // Mise à jour du groupe dans Firestore
              FirebaseFirestore.instance.collection('groupes').doc(groupeId).update({
                'libelle': _libelleController.text, // Mise à jour du libellé
              });
              _libelleController.clear(); // Réinitialiser le champ
              Navigator.of(ctx).pop(); // Fermer la boîte de dialogue
            },
            child: Text(
              'Mettre à jour',
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue, // Couleur du bouton
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour supprimer un groupe
  void _deleteGroup(BuildContext context, String groupeId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Confirmer la suppression',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer ce groupe et tous les étudiants associés ?',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          // Bouton pour supprimer le groupe et ses étudiants
          TextButton(
            onPressed: () async {
              // Récupérer et supprimer tous les étudiants associés à ce groupe
              final studentsSnapshot = await FirebaseFirestore.instance
                  .collection('etudiants')
                  .where('groupe_id', isEqualTo: groupeId)
                  .get();
              for (var student in studentsSnapshot.docs) {
                student.reference.delete(); // Supprimer chaque étudiant
              }

              // Supprimer le groupe
              FirebaseFirestore.instance.collection('groupes').doc(groupeId).delete();
              Navigator.of(ctx).pop(); // Fermer la boîte de dialogue
            },
            child: Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red, // Couleur rouge pour la suppression
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Bouton pour annuler la suppression
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Fermer la boîte de dialogue sans faire de modifications
            },
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Groupes', // Titre de la page
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue, // Couleur de fond de la barre d'applications
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('groupes').snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator()); // Afficher un indicateur de chargement si les données ne sont pas encore prêtes

          final groupes = snapshot.data!.docs; // Liste des groupes récupérés

          // Affichage des groupes dans une liste déroulante
          return ListView.builder(
            itemCount: groupes.length,
            itemBuilder: (ctx, index) {
              final groupe = groupes[index]; // Récupérer chaque groupe
              return Card(
                elevation: 4, // Ombre pour la carte
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // Coins arrondis de la carte
                ),
                child: ListTile(
                  title: Text(
                    groupe['libelle'], // Afficher le libellé du groupe
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icône de modification
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editGroup(context, groupe.id, groupe['libelle']),
                      ),
                      // Icône de suppression
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteGroup(context, groupe.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.blue, // Couleur du bouton d'ajout
        onPressed: () => _addGroup(context), // Action pour ajouter un groupe
      ),
    );
  }
}
