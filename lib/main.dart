import 'dart:ffi';

import 'package:activite2/databasemanager.dart';
import 'package:activite2/modele/redacteur.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MonApplication());
}

class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Magazine",
      debugShowCheckedModeBanner: false,
      home: PageAccueil(),
    );
  }
}

class PageAccueil extends StatelessWidget {
  const PageAccueil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gestion des redacteurs",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(245, 32, 139, 1),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
      body: RedacteurInterface(),
    );
  }
}

class RedacteurInterface extends StatefulWidget {
  const RedacteurInterface({super.key});

  @override
  State<RedacteurInterface> createState() => _RedacteurInterfaceState();
}

class _RedacteurInterfaceState extends State<RedacteurInterface> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final List<Redacteur> _redacteurs = [];

  @override
  void initState() {
    super.initState();
    _chargerRedacteurs();
  }

  Future<void> _chargerRedacteurs() async {
    final data = await DatabaseManager.instance.getAllRedacteurs();
    setState(() {
      _redacteurs.clear();
      _redacteurs.addAll(data);
    });
  }

  Future<void> _ajouterRedacteurs() async {
    if (_nomController.text.isEmpty ||
        _prenomController.text.isEmpty ||
        _emailController.text.isEmpty)
      return;

    final redacteur = Redacteur.sansId(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      email: _emailController.text.trim(),
    );

    final id = await DatabaseManager.instance.insertRedacteur(redacteur);
    redacteur.id = id;

    setState(() {
      _redacteurs.add(redacteur);
    });

    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();
  }

  void _editerRedacteur(Redacteur redacteur) {
    final nomCtrl = TextEditingController(text: redacteur.nom);
    final prenomCtrl = TextEditingController(text: redacteur.prenom);
    final emailCtrl = TextEditingController(text: redacteur.email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier le redacteur"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nomCtrl, "Nom"),
              const SizedBox(height: 8),
              _buildTextField(prenomCtrl, "Prénom"),
              const SizedBox(height: 8),
              _buildTextField(
                emailCtrl,
                "Email",
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Annuler"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Enregistrer"),
              onPressed: () async {
                await DatabaseManager.instance.updateRedacteur(redacteur);

                setState(() {
                  redacteur.nom = nomCtrl.text.trim();
                  redacteur.prenom = prenomCtrl.text.trim();
                  redacteur.email = emailCtrl.text.trim();
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _supprimerRedacteur(Redacteur redacteur) async {
    final bool? confirmer = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: Text(
            "Voulez-vous vraiment supprimer ${redacteur.nomComplet} ?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );

    if (confirmer == true) {
      await DatabaseManager.instance.deleteRedacteur(redacteur.id!);

      setState(() {
        _redacteurs.remove(redacteur);
      });
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildTextField(_nomController, "Nom"),
          const SizedBox(height: 10),
          _buildTextField(_prenomController, "Prénom"),
          const SizedBox(height: 10),
          _buildTextField(
            _emailController,
            "Email",
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () => _ajouterRedacteurs(),
              child: const Text(
                "ENREGISTRER",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _redacteurs.length,
              itemBuilder: (context, index) {
                final redacteur = _redacteurs[index];

                return Card(
                  child: ListTile(
                    title: Text(
                      redacteur.nomComplet,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(redacteur.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _supprimerRedacteur(redacteur),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.red),
                          onPressed: () => _editerRedacteur(redacteur),
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
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
