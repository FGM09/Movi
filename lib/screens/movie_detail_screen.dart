import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/movie.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';

class MovieDetailScreen extends StatelessWidget {
  final MovieModel movie;

  const MovieDetailScreen({super.key, required this.movie});

  void _importToMyEvents(BuildContext context) {
    final userEmail = AuthService().currentUser?.email ?? 'usuario@movi.com';

    final newEvent = EventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: movie.title,
      description: 'Filme/Série importado da API: ${movie.summary}',
      dateTime: DateTime.now().add(const Duration(days: 2, hours: 3)),
      location: movie.location,
      participants: ['Você'],
      isConfirmed: true,
      category: EventCategory.social,
      creatorEmail: userEmail,
    );

    EventService().addEvent(newEvent);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${movie.title}" foi adicionado aos seus eventos!'),
        backgroundColor: Colors.green[700],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster / Header
            if (movie.imageUrl != null)
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.black,
                child: Image.network(
                  movie.imageUrl!,
                  fit: BoxFit.contain,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          movie.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (movie.rating > 0)
                        Chip(
                          avatar: const Icon(Icons.star, color: Colors.amber, size: 18),
                          label: Text(
                            movie.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.amber[50],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    children: movie.genres.map((genre) {
                      return Chip(
                        label: Text(genre),
                        backgroundColor: theme.colorScheme.primaryContainer,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  _buildDetailRow(Icons.tv, 'Rede / Plataforma', movie.location),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.schedule, 'Horário de Exibição', movie.scheduleTime),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.calendar_today, 'Estreia / Lançamento', movie.premiered),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  Text(
                    'Sinopse / Descrição',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _importToMyEvents(context),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text(
                        'ADICIONAR AOS MEUS EVENTOS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }
}
