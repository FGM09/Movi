import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import 'event_form_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventService _eventService = EventService();
  final _participantController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _eventService.addListener(_refresh);
  }

  @override
  void dispose() {
    _eventService.removeListener(_refresh);
    _participantController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year às $hour:$minute';
  }

  void _addParticipant() {
    final name = _participantController.text.trim();
    if (name.isNotEmpty) {
      _eventService.addParticipant(widget.eventId, name);
      _participantController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name adicionado como participante!')),
      );
    }
  }

  void _confirmDelete(EventModel event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Evento'),
        content: Text('Tem certeza de que deseja excluir "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _eventService.deleteEvent(event.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Evento excluído com sucesso.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventIndex = _eventService.events.indexWhere((e) => e.id == widget.eventId);

    if (eventIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes do Evento')),
        body: const Center(child: Text('Evento não encontrado.')),
      );
    }

    final event = _eventService.events[eventIndex];
    final isConfirmed = event.isConfirmed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Evento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar Evento',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventFormScreen(eventToEdit: event),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Excluir Evento',
            onPressed: () => _confirmDelete(event),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: theme.colorScheme.primaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        avatar: Text(event.category.emoji),
                        label: Text(
                          event.category.label,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _eventService.toggleConfirmation(event.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                event.isConfirmed
                                    ? 'Confirmação alterada para Pendente'
                                    : 'Presença Confirmada com sucesso!',
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          isConfirmed ? Icons.check_circle : Icons.pending_actions,
                          color: isConfirmed ? Colors.white : Colors.black87,
                        ),
                        label: Text(
                          isConfirmed ? 'CONFIRMADO' : 'PENDENTE',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isConfirmed ? Colors.green[700] : Colors.amber[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Cards
                  _buildInfoRow(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Data e Horário',
                    value: _formatDateTime(event.dateTime),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    icon: Icons.location_on,
                    title: 'Local',
                    value: event.location,
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Descrição',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description.isNotEmpty
                        ? event.description
                        : 'Nenhuma descrição informada.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Participants Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Participantes (${event.participants.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quick Add Participant Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _participantController,
                          decoration: InputDecoration(
                            hintText: 'Nome do participante...',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addParticipant,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Adicionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (event.participants.isEmpty)
                    Text(
                      'Nenhum participante adicionado ainda.',
                      style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                    )
                  else
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: event.participants.map((participant) {
                        return Chip(
                          avatar: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            child: Text(
                              participant.isNotEmpty ? participant[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                          label: Text(participant),
                          onDeleted: () {
                            _eventService.removeParticipant(event.id, participant);
                          },
                          deleteIcon: const Icon(Icons.close, size: 16),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
