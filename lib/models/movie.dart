class MovieModel {
  final int id;
  final String title;
  final String summary;
  final String? imageUrl;
  final double rating;
  final List<String> genres;
  final String premiered;
  final String location;
  final String scheduleTime;

  MovieModel({
    required this.id,
    required this.title,
    required this.summary,
    this.imageUrl,
    required this.rating,
    required this.genres,
    required this.premiered,
    required this.location,
    required this.scheduleTime,
  });

  static String _cleanHtml(String? html) {
    if (html == null) return 'Sem descrição disponível.';
    return html.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').trim();
  }

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    final show = json.containsKey('show') ? json['show'] : json;

    final imageMap = show['image'] as Map<String, dynamic>?;
    final ratingMap = show['rating'] as Map<String, dynamic>?;
    final networkMap = show['network'] as Map<String, dynamic>?;
    final scheduleMap = show['schedule'] as Map<String, dynamic>?;
    final genresList = (show['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    final time = scheduleMap?['time']?.toString() ?? '20:00';
    final days = (scheduleMap?['days'] as List<dynamic>?)?.join(', ') ?? '';

    return MovieModel(
      id: show['id'] ?? 0,
      title: show['name'] ?? 'Sem Título',
      summary: _cleanHtml(show['summary']),
      imageUrl: imageMap?['medium'] ?? imageMap?['original'],
      rating: (ratingMap?['average'] as num?)?.toDouble() ?? 0.0,
      genres: genresList,
      premiered: show['premiered'] ?? 'Em breve',
      location: networkMap?['name'] ?? 'Streaming / Cinema',
      scheduleTime: days.isNotEmpty ? '$days às $time' : 'Horário: $time',
    );
  }
}
