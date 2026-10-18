enum EventCategory {
  social('Social', '🎉'),
  trabalho('Trabalho', '💼'),
  esporte('Esporte', '⚽'),
  estudo('Estudo', '📚'),
  outros('Outros', '📌');

  final String label;
  final String emoji;

  const EventCategory(this.label, this.emoji);
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final List<String> participants;
  final bool isConfirmed;
  final EventCategory category;
  final String creatorEmail;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.participants,
    this.isConfirmed = true,
    this.category = EventCategory.social,
    required this.creatorEmail,
  });

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    List<String>? participants,
    bool? isConfirmed,
    EventCategory? category,
    String? creatorEmail,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      participants: participants ?? List.from(this.participants),
      isConfirmed: isConfirmed ?? this.isConfirmed,
      category: category ?? this.category,
      creatorEmail: creatorEmail ?? this.creatorEmail,
    );
  }
}
