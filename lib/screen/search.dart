import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:image/image.dart' as img;
//import 'dart:typed_data';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> saveSearchHistory(
    String mudraName, String details, String url) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not logged in!");
      return;
    }

    // Convert email to Firestore-safe ID
    String userId = user.email!.replaceAll('.', '_');

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('search_history')
        .add({
      "mudra": mudraName,
      "details": details,
      "imageUrl": url,
      "timestamp": FieldValue.serverTimestamp(),
    });

    print("Search history saved successfully!");
  } catch (e) {
    print("Error saving search history: $e");
  }
}

class MySearch extends StatefulWidget {
  const MySearch({super.key});

  @override
  State<MySearch> createState() => _MySearchState();
}

class _MySearchState extends State<MySearch> {
  File? _selectedImage;
  String? _predictedMudra;
  //double? _confidence;
  String? _mudraDetails;
  String? _imageUrl;
  bool _showDetails = false;
  bool _show = false;
  String? _image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explore Mudras',
          style: TextStyle(color: Colors.white, fontSize: 25.sp),
        ),
        backgroundColor: const Color.fromARGB(255, 153, 1, 1),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            width: 400.w,
            height: 1000.h,
            color: const Color.fromARGB(255, 255, 234, 234),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 8.h,
                ),
                SizedBox(
                  height: 20.h,
                  //width: 20,

                  child: Lottie.asset(
                    'assets/animations/Animation - 2.json',
                    repeat: false,
                    width: 25.w,
                    height: 15.h,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Search Mudra',
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 125, 1, 1)),
                ),
                SizedBox(height: 5.h),
                MaterialButton(
                  onPressed: _pickImageFromGallery,
                  color: const Color.fromARGB(255, 175, 0, 0),
                  child: Text(
                    'Upload From Gallery',
                    style: TextStyle(color: Colors.white, fontSize: 15.sp),
                  ),
                ),
                SizedBox(height: 5.h),
                MaterialButton(
                  onPressed: _captureImageFromCamera,
                  color: const Color.fromARGB(255, 175, 0, 0),
                  child: Text(
                    'Capture from Camera',
                    style: TextStyle(color: Colors.white, fontSize: 15.sp),
                  ),
                ),
                SizedBox(height: 5.h),
                if (_selectedImage != null)
                  Column(
                    children: [
                      Image.file(_selectedImage!,
                          width: 50.w, height: 50.h, fit: BoxFit.cover),
                      SizedBox(height: 5.h),
                      if (_predictedMudra != null || _show == true)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Mudra: $_predictedMudra",
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 148, 0, 0)),
                                ),
                                const SizedBox(height: 5),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showDetails = !_showDetails;
                                    });
                                  },
                                  child: Text(
                                    _showDetails
                                        ? "Hide Details"
                                        : "Show Details",
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 148, 0, 0)),
                                  ),
                                ),
                                if (_showDetails && _mudraDetails != null)
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.r)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Details about $_predictedMudra",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 134, 29, 29)),
                                            ),
                                            SizedBox(height: 5.h),
                                            Column(
                                              children: [
                                                Text(
                                                  _mudraDetails ??
                                                      'No details available.',
                                                  style: TextStyle(
                                                      fontSize: 12.h,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255, 101, 8, 8)),
                                                ),

                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  child: Image.asset(
                                                    _imageUrl ??
                                                        'assets/mudras/default.png',
                                                    width: 150,
                                                    height: 150,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                // Show a loader until the image loads
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                else
                  const Text(
                    'Please select an image',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    _updateSelectedImage(pickedFile);
  }

  Future<void> _captureImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    _updateSelectedImage(pickedFile);
  }

  void _updateSelectedImage(XFile? pickedFile) {
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      _showSnackBar("No image selected.");
      return;
    }

    try {
      if (mounted) {
        setState(() => _show = true); // Show loading indicator
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("http://192.168.130.248:5000/predict"),
      );
      request.files.add(
          await http.MultipartFile.fromPath('image', _selectedImage!.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var decodedResponse = json.decode(responseBody);

      if (response.statusCode == 200 && decodedResponse.containsKey('mudra')) {
        if (mounted) {
          setState(() {
            _predictedMudra = decodedResponse['mudra'];

            _mudraDetails =
                decodedResponse['details'] ?? "No details available.";

            _imageUrl = decodedResponse['imageUrl'];
          });
          saveSearchHistory(_predictedMudra!, _mudraDetails!, _imageUrl!);
        }
      } else {
        _showSnackBar(
            "Error: ${decodedResponse['error'] ?? 'Unexpected error occurred'}");
        if (mounted) {
          setState(() {
            _predictedMudra = null;
            _mudraDetails = null;
          });
        }
      }
    } catch (e) {
      _showSnackBar("Failed to connect to API: $e");
      if (mounted) {
        setState(() {
          _predictedMudra = null;
          _mudraDetails = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _show = false); // Hide loading indicator
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String?> getImageUrlByName(String mudraName) async {
    String userId =
        FirebaseAuth.instance.currentUser!.email!.replaceAll('.', '_');

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('search_history')
          .where('mudra', isEqualTo: mudraName)
          .limit(1) // Limit to one result
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['imageUrl'];
      } else {
        return null; // No image found
      }
    } catch (e) {
      print('Error fetching image URL: $e');
      return null;
    }
  }
}
