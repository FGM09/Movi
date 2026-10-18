import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';
import 'event_form_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();

  String _searchQuery = '';
  EventCategory? _selectedCategory;
  bool? _confirmedFilter; // null = todos, true = confirmados, false = pendentes

  @override
  void initState() {
    super.initState();
    _eventService.addListener(_onEventsChanged);
  }

  @override
  void dispose() {
    _eventService.removeListener(_onEventsChanged);
    super.dispose();
  }

  void _onEventsChanged() {
    setState(() {});
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair do Movi'),
        content: const Text('Deseja realmente fazer logout da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _authService.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _authService.currentUser;
    final filteredEvents = _eventService.getFilteredEvents(
      query: _searchQuery,
      category: _selectedCategory,
      confirmedOnly: _confirmedFilter,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.event_available, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text(
              'Movi',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          // User Greeting Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: theme.colorScheme.primaryContainer.withOpacity(0.4),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  child: Text(
                    user != null && user.name.isNotEmpty
                        ? user.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, ${user?.name ?? "Usuário"}!',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_eventService.events.length} Eventos',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por título, local ou participante...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          // Status Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: _confirmedFilter == null,
                  onSelected: (selected) {
                    setState(() {
                      _confirmedFilter = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Confirmados'),
                  avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  selected: _confirmedFilter == true,
                  onSelected: (selected) {
                    setState(() {
                      _confirmedFilter = selected ? true : null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pendentes'),
                  avatar: const Icon(Icons.pending, size: 16, color: Colors.orange),
                  selected: _confirmedFilter == false,
                  onSelected: (selected) {
                    setState(() {
                      _confirmedFilter = selected ? false : null;
                    });
                  },
                ),
              ],
            ),
          ),

          // Category Chips Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Todas Categorias'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...EventCategory.values.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text('${cat.emoji} ${cat.label}'),
                      selected: _selectedCategory == cat,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? cat : null;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 1),

          // Event List
          Expanded(
            child: filteredEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum evento encontrado',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tente mudar os filtros de busca ou crie um novo evento.',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80, top: 8),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return EventCard(
                        event: event,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailScreen(eventId: event.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EventFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Evento'),
      ),
    );
  }
}
