class Film {
  final String? id;
  final String judul;
  final String ringkasan;
  final String gambarPoster;
  final String gambarSampul;
  final int tanggalRilis;
  final int skorRating;
  final String kategori;
  final String urlTrailer;

  Film({
    this.id,
    required this.judul,
    required this.ringkasan,
    required this.gambarPoster,
    required this.gambarSampul,
    required this.tanggalRilis,
    required this.skorRating,
    required this.kategori,
    required this.urlTrailer,
  });

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      id: json['id']?.toString(),
      judul: json['judul'] ?? '',
      ringkasan: json['ringkasan'] ?? '',
      gambarPoster: json['gambar_poster'] ?? '',
      gambarSampul: json['gambar_sampul'] ?? '',
      tanggalRilis: json['tanggal_rilis'] is int
          ? json['tanggal_rilis']
          : int.tryParse(json['tanggal_rilis']?.toString() ?? '0') ?? 0,
      skorRating: json['skor_rating'] is int
          ? json['skor_rating']
          : int.tryParse(json['skor_rating']?.toString() ?? '0') ?? 0,
      kategori: json['kategori'] ?? '',
      urlTrailer: json['url_trailer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'ringkasan': ringkasan,
      'gambar_poster': gambarPoster,
      'gambar_sampul': gambarSampul,
      'tanggal_rilis': tanggalRilis,
      'skor_rating': skorRating,
      'kategori': kategori,
      'url_trailer': urlTrailer,
    };
  }

  Film copyWith({
    String? id,
    String? judul,
    String? ringkasan,
    String? gambarPoster,
    String? gambarSampul,
    int? tanggalRilis,
    int? skorRating,
    String? kategori,
    String? urlTrailer,
  }) {
    return Film(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      ringkasan: ringkasan ?? this.ringkasan,
      gambarPoster: gambarPoster ?? this.gambarPoster,
      gambarSampul: gambarSampul ?? this.gambarSampul,
      tanggalRilis: tanggalRilis ?? this.tanggalRilis,
      skorRating: skorRating ?? this.skorRating,
      kategori: kategori ?? this.kategori,
      urlTrailer: urlTrailer ?? this.urlTrailer,
    );
  }
}
