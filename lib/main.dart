import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Picsum Photos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => PhotoBloc(),
        child: PhotoList(),
      ),
    );
  }
}

class PhotoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final photoBloc = BlocProvider.of<PhotoBloc>(context);
    
    // Panggil event FetchPhotos saat widget ini dibuat
    photoBloc.add(FetchPhotos());

    return Scaffold(
      appBar: AppBar(
        title: Text('Picsum Photos'),
      ),
      body: BlocBuilder<PhotoBloc, PhotoState>(
        builder: (context, state) {
          if (state is PhotoLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is PhotoLoaded) {
            return ListView.builder(
              itemCount: state.photos.length > 5 ? 5 : state.photos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(state.photos[index].downloadUrl),
                  title: Text('Photo ${(int.parse(state.photos[index].id) + 1).toString()}'),
                  subtitle: Text(state.photos[index].author),
                );
              },
            );
          } else if (state is PhotoError) {
            return Center(
              child: Text('Failed to load photos'),
            );
          }
          return Container();
        },
      ),
    );
  }
}

class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  PhotoBloc() : super(PhotoInitial()) {
    on<FetchPhotos>((event, emit) async {
      try {
        final List<Photo> photos = await _fetchPhotos();
        emit(PhotoLoaded(photos: photos));
      } catch (_) {
        emit(PhotoError());
      }
    });
  }

  Future<List<Photo>> _fetchPhotos() async {
    final response = await http.get(Uri.parse('https://picsum.photos/v2/list'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Photo> photos = [];
      for (var item in data) {
        photos.add(Photo.fromJson(item));
      }
      return photos;
    } else {
      throw Exception('Failed to load photos');
    }
  }
}

class PhotoEvent {}

class FetchPhotos extends PhotoEvent {}

class PhotoState {}

class PhotoInitial extends PhotoState {}

class PhotoLoading extends PhotoState {}

class PhotoLoaded extends PhotoState {
  final List<Photo> photos;

  PhotoLoaded({required this.photos});
}

class PhotoError extends PhotoState {}

class Photo {
  final String id;
  final String author;
  final String downloadUrl;

  Photo({
    required this.id,
    required this.author,
    required this.downloadUrl,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'].toString(),
      author: json['author'],
      downloadUrl: json['download_url'],
    );
  }
}
