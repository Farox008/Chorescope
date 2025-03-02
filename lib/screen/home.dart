import 'package:flutter/material.dart';
import 'dance_details.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart'; // Add this import
import 'package:lottie/lottie.dart';

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  double _scale = 1.0;

  // Create a method to fetch the dance forms from Firebase
  Future<List<Map<String, dynamic>>> fetchDanceForms() async {
    try {
      // Fetch data from Firestore collection "danceForms"
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('dance_Forms').get();

      // Extract data from the query snapshot and return as a list of maps
      return querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print("Error fetching data: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ChoreoScope",
            style: TextStyle(color: Colors.white, fontSize: 30)),
        backgroundColor: const Color.fromARGB(255, 159, 15, 4),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchDanceForms(), // Fetch data from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No dance forms available.'));
          }

          final danceForms = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text(
                "Welcome to Choreoscope",
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 149, 16, 16)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                "Discover the beauty of classical dance",
                style: TextStyle(
                    fontSize: 15, color: Color.fromARGB(255, 145, 6, 6)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: SizedBox(
                  height: 280,
                  child: Listener(
                    onPointerSignal: (PointerSignalEvent event) {
                      if (event is PointerScrollEvent) {
                        setState(() {
                          if (event.scrollDelta.dy > 0) {
                            _scale += 0.1; // Zoom in
                          } else {
                            _scale -= 0.1; // Zoom out
                          }
                          _scale = _scale.clamp(
                              0.5, 3.0); // Clamp scale to reasonable limits
                        });
                      }
                    },
                    child: Transform.scale(
                      scale: _scale, // Apply scaling effect
                      child: PageView.builder(
                        itemCount: danceForms.length,
                        controller: PageController(viewportFraction: 0.7),
                        physics: const PageScrollPhysics(),
                        itemBuilder: (context, index) {
                          final dance = danceForms[index];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DanceDetailsPage(
                                      danceName: dance['name'],
                                      imagePath: dance['image'],
                                      history: dance['history'],
                                      dressing: dance['dressing'],
                                      keyFeatures: List<String>.from(
                                          dance['keyFeatures']),
                                      videoUrl: dance['videoUrl'],
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: dance['name'],
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        dance['image'],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(8),
                                          color: Colors.black54,
                                          child: Text(
                                            dance['name'],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              SizedBox(
                child: Lottie.asset(
                  'assets/animations/Animation - 3.json',
                  repeat: true,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
