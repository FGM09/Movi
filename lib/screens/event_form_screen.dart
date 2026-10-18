import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';

class EventFormScreen extends StatefulWidget {
  final EventModel? eventToEdit;

  const EventFormScreen({super.key, this.eventToEdit});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _participantsController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late EventCategory _selectedCategory;
  late bool _isConfirmed;

  @override
  void initState() {
    super.initState();
    final event = widget.eventToEdit;

    _titleController = TextEditingController(text: event?.title ?? '');
    _descriptionController = TextEditingController(text: event?.description ?? '');
    _locationController = TextEditingController(text: event?.location ?? '');
    _participantsController = TextEditingController(
      text: event != null ? event.participants.join(', ') : '',
    );

    _selectedDate = event?.dateTime ?? DateTime.now().add(const Duration(days: 1));
    _selectedTime = event != null
        ? TimeOfDay(hour: event.dateTime.hour, minute: event.dateTime.minute)
        : const TimeOfDay(hour: 19, minute: 0);

    _selectedCategory = event?.category ?? EventCategory.social;
    _isConfirmed = event?.isConfirmed ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _participantsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState?.validate() ?? false) {
      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final participantsList = _participantsController.text
          .split(',')
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();

      final currentEmail = AuthService().currentUser?.email ?? 'usuario@movi.com';

      if (widget.eventToEdit != null) {
        final updated = widget.eventToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dateTime: combinedDateTime,
          location: _locationController.text.trim(),
          participants: participantsList,
          isConfirmed: _isConfirmed,
          category: _selectedCategory,
        );
        EventService().updateEvent(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento atualizado com sucesso!')),
        );
      } else {
        final newEvent = EventModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dateTime: combinedDateTime,
          location: _locationController.text.trim(),
          participants: participantsList,
          isConfirmed: _isConfirmed,
          category: _selectedCategory,
          creatorEmail: currentEmail,
        );
        EventService().addEvent(newEvent);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento criado com sucesso!')),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.eventToEdit != null;

    final dateString =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
    final timeString =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Evento' : 'Novo Evento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título do Evento *',
                  hintText: 'Ex: Aniversário, Reunião, Futebol',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe o título do evento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<EventCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: EventCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text('${cat.emoji} ${cat.label}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Date & Time Selectors
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Data *',
                          prefixIcon: const Icon(Icons.calendar_month),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          dateString,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Horário *',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          timeString,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Local *',
                  hintText: 'Ex: Sala 3, Endereço, Link de Vídeo',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe o local do evento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Detalhes, pauta ou orientações sobre o evento...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.description_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Participants
              TextFormField(
                controller: _participantsController,
                decoration: InputDecoration(
                  labelText: 'Participantes (separados por vírgula)',
                  hintText: 'Ex: Ana, Carlos, Pedro, Maria',
                  prefixIcon: const Icon(Icons.people_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status Switch
              SwitchListTile(
                title: const Text('Status do Evento'),
                subtitle: Text(
                  _isConfirmed ? 'Presença/Evento Confirmado' : 'Status Pendente',
                  style: TextStyle(
                    color: _isConfirmed ? Colors.green[800] : Colors.orange[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: _isConfirmed,
                activeColor: Colors.green,
                onChanged: (val) {
                  setState(() {
                    _isConfirmed = val;
                  });
                },
                secondary: Icon(
                  _isConfirmed ? Icons.check_circle_outline : Icons.pending_outlined,
                  color: _isConfirmed ? Colors.green : Colors.orange,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    isEditing ? 'SALVAR ALTERAÇÕES' : 'CRIAR EVENTO',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
