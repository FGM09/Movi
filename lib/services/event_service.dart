import 'package:flutter/material.dart';
import '../models/event.dart';

class EventService extends ChangeNotifier {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal() {
    _initSampleData();
  }

  final List<EventModel> _events = [];

  List<EventModel> get events => List.unmodifiable(_events);

  void _initSampleData() {
    final now = DateTime.now();
    _events.addAll([
      EventModel(
        id: '1',
        title: 'Reunião de Alinhamento do Projeto',
        description: 'Definição das metas do próximo trimestre e revisão de entregas da equipe.',
        dateTime: now.add(const Duration(days: 1, hours: 4)),
        location: 'Sala de Conferência A - Bloco B',
        participants: ['Carlos Silva', 'Ana Oliveira', 'Mariana Santos', 'Pedro Costa'],
        isConfirmed: true,
        category: EventCategory.trabalho,
        creatorEmail: 'carlos@movi.com',
      ),
      EventModel(
        id: '2',
        title: 'Aniversário da Ana',
        description: 'Comemoração de aniversário com bolo, salgados e bebidas. Traga seu bom humor!',
        dateTime: now.add(const Duration(days: 3, hours: 8)),
        location: 'Espaço de Festas Sol & Mar - Av. Principal 123',
        participants: ['Ana Oliveira', 'Lucas Pereira', 'Beatriz Lima', 'Felipe Souza', 'Carlos Silva'],
        isConfirmed: true,
        category: EventCategory.social,
        creatorEmail: 'ana@movi.com',
      ),
      EventModel(
        id: '3',
        title: 'Torneio Amador de Futebol 5',
        description: 'Partida entre amigos. Levar chuteira society e camisa vermelha ou branca.',
        dateTime: now.add(const Duration(days: 5, hours: 2)),
        location: 'Quadra Arena Sports - R. dos Esportes 45',
        participants: ['Carlos Silva', 'Gabriel Alves', 'Rodrigo Rocha'],
        isConfirmed: false,
        category: EventCategory.esporte,
        creatorEmail: 'carlos@movi.com',
      ),
      EventModel(
        id: '4',
        title: 'Grupo de Estudo Flutter & Dart',
        description: 'Sessão de estudos sobre arquitetura e gerenciamento de estado em Flutter.',
        dateTime: now.add(const Duration(days: 7, hours: 5)),
        location: 'Biblioteca Central - Sala 12',
        participants: ['Mariana Santos', 'Carlos Silva', 'Lucas Pereira'],
        isConfirmed: true,
        category: EventCategory.estudo,
        creatorEmail: 'carlos@movi.com',
      ),
    ]);
  }

  List<EventModel> getFilteredEvents({
    String query = '',
    EventCategory? category,
    bool? confirmedOnly,
  }) {
    return _events.where((e) {
      final matchesQuery = query.isEmpty ||
          e.title.toLowerCase().contains(query.toLowerCase()) ||
          e.location.toLowerCase().contains(query.toLowerCase()) ||
          e.description.toLowerCase().contains(query.toLowerCase()) ||
          e.participants.any((p) => p.toLowerCase().contains(query.toLowerCase()));

      final matchesCategory = category == null || e.category == category;
      final matchesConfirmed = confirmedOnly == null || e.isConfirmed == confirmedOnly;

      return matchesQuery && matchesCategory && matchesConfirmed;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  void addEvent(EventModel event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(EventModel updatedEvent) {
    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();
    }
  }

  void deleteEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void toggleConfirmation(String id) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events[index] = _events[index].copyWith(
        isConfirmed: !_events[index].isConfirmed,
      );
      notifyListeners();
    }
  }

  void addParticipant(String eventId, String participantName) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final currentList = List<String>.from(_events[index].participants);
      if (!currentList.contains(participantName)) {
        currentList.add(participantName);
        _events[index] = _events[index].copyWith(participants: currentList);
        notifyListeners();
      }
    }
  }

  void removeParticipant(String eventId, String participantName) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final currentList = List<String>.from(_events[index].participants);
      currentList.remove(participantName);
      _events[index] = _events[index].copyWith(participants: currentList);
      notifyListeners();
    }
  }
}
