import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salon_app/widgets/user%20image%20picker/take_image_button.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfieImagePicker extends StatefulWidget {
  const ProfieImagePicker({super.key});

  @override
  State<ProfieImagePicker> createState() => _ProfieImagePickerState();
}

class _ProfieImagePickerState extends State<ProfieImagePicker> {
  late ImagePicker picker;
  XFile? _userImage;
  File? savedImage;
  bool loadingImage = true;

  Future<void> saveImageToDevice(XFile image) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    // Get the directory for storing files
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String savedImagePath = '${appDocDir.path}/saved_image.png';
    //checking if file exists
    File existingFile = File(savedImagePath);
    if (await existingFile.exists()) {
      await existingFile.delete();
    }
    // Read the image bytes from XFile
    List<int> imageBytes = await image.readAsBytes();

    // Write the image bytes to a new file
    savedImage = File(savedImagePath);
    await savedImage!.writeAsBytes(imageBytes);
    checkForSavedImage();
    print('Image saved to: $savedImagePath');
  }

  Future<void> checkForSavedImage() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String savedImagePath = '${appDocDir.path}/saved_image.png';
    File imageFile = File(savedImagePath);
    if (await imageFile.exists()) {
      setState(() {
        savedImage = imageFile;
        loadingImage = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    picker = ImagePicker();
    checkForSavedImage();
  }

  void showModalSheet() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.19,
              width: double.infinity,
              child: Row(
                children: [
                  TakeImageButton(
                    source: 'camera',
                    takeImage: pickImage,
                  ),
                  TakeImageButton(
                    source: 'gallery',
                    takeImage: pickImage,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> pickImage(ImageSource source) async {
    Navigator.pop(context);
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _userImage = pickedFile;
        saveImageToDevice(pickedFile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = loadingImage
        ? const AssetImage('asset/images/loadingImageGIF.gif')
        : (_userImage != null
            ? FileImage(File(_userImage!.path))
            : savedImage != null
                ? FileImage(savedImage!)
                : const AssetImage('asset/images/profile_image_add.png'));
    return Center(
      child: Card(
        shape: const CircleBorder(),
        elevation: 20,
        child: InkWell(
          child: CircleAvatar(
            backgroundColor: Colors.brown,
            backgroundImage: content as ImageProvider,
            radius: MediaQuery.of(context).size.height * 0.089,
          ),
          onTap: () {
            showModalSheet();
          },
        ),
      ),
    );
  }
}
