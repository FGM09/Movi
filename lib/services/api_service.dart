import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String _baseUrl = 'https://api.tvmaze.com';

  /// Busca filmes/séries populares em alta da API externa pública
  Future<List<MovieModel>> fetchPopularMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/shows'));

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.take(25).map((json) => MovieModel.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao conectar com a API externa (Código: ${response.statusCode})');
    }
  }

  /// Busca filmes por termo de pesquisa na API externa
  Future<List<MovieModel>> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      return fetchPopularMovies();
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/search/shows?q=${Uri.encodeComponent(query.trim())}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((json) => MovieModel.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao buscar filmes da API externa.');
    }
  }
}
