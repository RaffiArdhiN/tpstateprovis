// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_tp4/providers/img_provider.dart' as custom_provider;
import 'models/img_model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => custom_provider.ImageProvider(),
      child: const PictureGalleryApp(),
    ),
  );
}

class PictureGalleryApp extends StatelessWidget {
  const PictureGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Picture Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GalleryScreen(),
    );
  }
}

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Picture Gallery"),
      ),
      body: FutureBuilder(
        future: Provider.of<custom_provider.ImageProvider>(context, listen: false).fetchImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            final images = Provider.of<custom_provider.ImageProvider>(context).images;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return GestureDetector(
                  onTap: () => _showImageDetailDialog(context, image),
                  child: GridTile(
                    footer: GridTileBar(
                      backgroundColor: Colors.black54,
                      title: Text(
                        image.description,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    child: Image.network(
                    image.source, fit: BoxFit.cover),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("Error loading images"));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addImage(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showImageDetailDialog(BuildContext context, ImageModel image) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Image Details"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("ID: ${image.id}"),
              Text("Description: ${image.description}"),
              Text("Source: ${image.source}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
            TextButton(
              onPressed: () => _editImage(context, image),
              child: const Text("Edit"),
            ),
          ],
        );
      },
    );
  }

  void _editImage(BuildContext context, ImageModel image) {
    final TextEditingController descriptionController = TextEditingController(text: image.description);
    final TextEditingController sourceController = TextEditingController(text: image.source);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Image Details"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextFormField(
                controller: sourceController,
                decoration: const InputDecoration(labelText: "Source"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Provider.of<custom_provider.ImageProvider>(context, listen: false).editImage(
                  image.id,
                  descriptionController.text,
                  sourceController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _addImage(BuildContext context) {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController sourceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Image"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextFormField(
                controller: sourceController,
                decoration: const InputDecoration(labelText: "Source"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final newImage = ImageModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  description: descriptionController.text,
                  source: sourceController.text,
                );
                Provider.of<custom_provider.ImageProvider>(context, listen: false).addImage(newImage);
                Navigator.of(context).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
