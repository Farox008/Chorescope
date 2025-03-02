import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DanceDetailsPage extends StatefulWidget {
  final String danceName;
  final String imagePath;
  final String history;
  final List<String> keyFeatures;
  final String dressing;
  final String? videoUrl; // Video URL is optional

  const DanceDetailsPage({
    required this.danceName,
    required this.imagePath,
    required this.history,
    required this.keyFeatures,
    required this.dressing,
    this.videoUrl, // Video URL is optional
  });

  @override
  _DanceDetailsPageState createState() => _DanceDetailsPageState();
}

class _DanceDetailsPageState extends State<DanceDetailsPage> {
  YoutubePlayerController? _controller; // Nullable to prevent errors

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl!);
      if (videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // Dispose controller to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.danceName,
          style: TextStyle(color: Colors.white, fontSize: 23),
        ),
        backgroundColor: const Color.fromARGB(255, 100, 12, 5),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: widget.danceName,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(widget.imagePath,
                      width: double.infinity, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),

              // History Section
              const Text(
                "History",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 142, 4, 4)),
              ),
              const SizedBox(height: 8),
              Text(
                widget.history,
                textAlign: TextAlign.justify,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 21, 1, 1)),
              ),
              const SizedBox(height: 20),

              // Key Features Section
              const Text(
                "Key Features",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 130, 5, 5)),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding:
                      const EdgeInsets.all(8.0), // Added padding for better UI
                  child: Column(
                    children: widget.keyFeatures
                        .map((feature) => ListTile(
                              leading: const Icon(Icons.check_circle,
                                  color: Colors.green),
                              title: Text(feature,
                                  style: const TextStyle(fontSize: 16)),
                            ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Dressing & Important Aspects Section
              const Text(
                "Dressing & Important Aspects",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 126, 2, 2)),
              ),
              const SizedBox(height: 8),
              Text(
                widget.dressing,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 21, 1, 1)),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),

              // YouTube Video Section (Only if Video is Available)
              if (_controller != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Watch Performance",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 148, 1, 1)),
                    ),
                    const SizedBox(height: 8),
                    YoutubePlayer(
                      controller: _controller!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.red,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
