// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'film_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$FilmService extends FilmService {
  _$FilmService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = FilmService;

  @override
  Future<Response<dynamic>> getFilms() {
    final Uri $url = client.baseUrl.resolve('/film');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getFilm(String id) {
    final Uri $url = client.baseUrl.resolve('/film/$id');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> createFilm(Map<String, dynamic> body) {
    final Uri $url = client.baseUrl.resolve('/film');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateFilm(
    String id,
    Map<String, dynamic> body,
  ) {
    final Uri $url = client.baseUrl.resolve('/film/$id');
    final $body = body;
    final Request $request = Request('PUT', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteFilm(String id) {
    final Uri $url = client.baseUrl.resolve('/film/$id');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}
