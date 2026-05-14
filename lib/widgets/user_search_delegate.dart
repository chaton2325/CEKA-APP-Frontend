import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../screens/profile_screen.dart'; // Fixed import path

class UserSearchDelegate extends SearchDelegate {
  final ApiService _apiService;

  UserSearchDelegate(this._apiService);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 2) {
      return const Center(
        child: Text('Entrez au moins 2 caractères pour rechercher'),
      );
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder(
      future: _apiService.searchUsers(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.white),
                title: Container(width: 150, height: 12, color: Colors.white),
                subtitle: Container(width: 200, height: 10, color: Colors.white),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Erreur lors de la recherche'));
        }

        if (!snapshot.hasData || snapshot.data!.statusCode != 200) {
          return const Center(child: Text('Aucun résultat trouvé'));
        }

        final data = jsonDecode(snapshot.data!.body);
        final results = data['results'] as List;

        if (results.isEmpty) {
          return const Center(child: Text('Aucun utilisateur trouvé'));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final user = User.fromJson(results[index]['user']);
            final score = results[index]['score'];

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user.profilePhotoUrl != null
                    ? NetworkImage('${AppConstants.baseUrl}${user.profilePhotoUrl}')
                    : null,
                child: user.profilePhotoUrl == null ? const Icon(Icons.person) : null,
              ),
              title: Text(user.username),
              subtitle: Text(user.bio ?? 'Pas de bio'),
              trailing: Text('${(score * 100).toInt()}%'),
              onTap: () {
                // For now, we reuse ProfileScreen, but it might need to handle userId
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen(userId: user.id)),
                );
              },
            );
          },
        );
      },
    );
  }
}
