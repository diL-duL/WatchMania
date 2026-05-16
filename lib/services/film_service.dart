import 'package:chopper/chopper.dart';

part 'film_service.chopper.dart';

@ChopperApi(baseUrl: '/film')
abstract class FilmService extends ChopperService {
  static FilmService create([ChopperClient? client]) =>
      _$FilmService(client);

  /// GET /film — Get all films
  @GET()
  Future<Response> getFilms();

  /// GET /film/{id} — Get film by ID
  @GET(path: '/{id}')
  Future<Response> getFilm(@Path('id') String id);

  /// POST /film — Create a new film
  @POST()
  Future<Response> createFilm(@Body() Map<String, dynamic> body);

  /// PUT /film/{id} — Update an existing film
  @PUT(path: '/{id}')
  Future<Response> updateFilm(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  /// DELETE /film/{id} — Delete a film
  @DELETE(path: '/{id}')
  Future<Response> deleteFilm(@Path('id') String id);
}

