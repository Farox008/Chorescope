import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyProfile extends StatefulWidget {
  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String? username = '';
  String? expandedSearchId;

  @override
  void initState() {
    super.initState();
    loadUsername();
  }

  Future<void> loadUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        username = 'User'; // Default name if user is not logged in
      });
      return;
    }

    // Convert email to Firestore-safe ID
    String userId = user.email!.replaceAll('.', '_');

    try {
      // Fetch the first document from the 'details' subcollection
      QuerySnapshot detailsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('details')
          .limit(1) // Get only one document
          .get();

      if (detailsSnapshot.docs.isNotEmpty) {
        setState(() {
          username = detailsSnapshot.docs.first.get('username') ?? 'User';
        });
      } else {
        setState(() {
          username = 'User';
        });
      }
    } catch (e) {
      print("Error fetching username: $e");
      setState(() {
        username = 'User';
      });
    }
  }

  void toggleExpand(String docId) {
    setState(() {
      expandedSearchId = (expandedSearchId == docId) ? null : docId;
    });
  }

  Stream<QuerySnapshot> getSearchHistory() {
    String userId =
        FirebaseAuth.instance.currentUser!.email!.replaceAll('.', '_');
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('search_history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void deleteSearch(String docId) {
    String userId =
        FirebaseAuth.instance.currentUser!.email!.replaceAll('.', '_');
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('search_history')
        .doc(docId) // Corrected: Now targeting a specific document
        .delete();
  }

  void deleteAllHistory() async {
    String userId =
        FirebaseAuth.instance.currentUser!.email!.replaceAll('.', '_');
    var historyCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('search_history');

    var snapshots = await historyCollection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  void signout(BuildContext ctx) {
    Navigator.of(ctx).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx) {
      return MyLogin();
    }), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
            style: TextStyle(color: Colors.white, fontSize: 30)),
        backgroundColor: Color.fromARGB(255, 153, 1, 1),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20.0),
              CircleAvatar(
                radius: 50.0,
                child: Lottie.asset(
                  'assets/animations/Animation-1.json',
                  repeat: false,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                backgroundColor: Color.fromARGB(221, 233, 204, 204),
              ),
              SizedBox(height: 20.0),
              Text("Welcome $username!",
                  style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 101, 7, 7))),
              SizedBox(height: 20.0),
              ElevatedButton.icon(
                onPressed: () => history(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 142, 23, 15)),
                icon: Icon(Icons.history, color: Colors.white),
                label: Text('History', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => signout(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 142, 23, 15)),
                icon: Icon(Icons.exit_to_app, color: Colors.white),
                label: Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void history(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: 600,
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: getSearchHistory(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        var searches = snapshot.data!.docs;
                        if (searches.isEmpty) {
                          return Center(
                            child: Text(
                              "No history found.",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: searches.length,
                          itemBuilder: (context, index) {
                            var search = searches[index];
                            String docId = search.id;
                            bool isExpanded = (expandedSearchId == docId);

                            return Card(
                              margin: EdgeInsets.all(8),
                              color: Color.fromARGB(255, 122, 18, 18),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          AssetImage(search['imageUrl']),
                                    ),
                                    title: Text(
                                      search['mudra'],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      search['timestamp'] != null
                                          ? (search['timestamp'] as Timestamp)
                                              .toDate()
                                              .toString()
                                          : 'No timestamp',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            setModalState(() {
                                              expandedSearchId =
                                                  isExpanded ? null : docId;
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.white),
                                          onPressed: () => deleteSearch(docId),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isExpanded)
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                15), // Adjust radius as needed
                                            child: Image.asset(
                                              search['imageUrl'],
                                              width: 200,
                                              height: 200,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            search['details'] ??
                                                'No details available',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: deleteAllHistory,
                      child: Text('Clear All History'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
