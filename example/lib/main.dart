import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';

void main() {
  runApp(const DownloadExampleApp());
}

class DownloadExampleApp extends StatelessWidget {
  const DownloadExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Download Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const DownloadTestScreen(),
    );
  }
}

class DownloadTestScreen extends StatefulWidget {
  const DownloadTestScreen({super.key});

  @override
  State<DownloadTestScreen> createState() => DownloadTestScreenState();
}

class DownloadTestScreenState extends State<DownloadTestScreen> {
  final DownloadManager downloadManager = DownloadManager();

  final TextEditingController urlController = TextEditingController();

  DownloadTask? currentTask;
  bool downloading = false;

  Future<void> startDownload() async {
    final url = urlController.text.trim();

    if (url.isEmpty) {
      showMessage('Please enter a download URL');
      return;
    }

    setState(() {
      downloading = true;
      currentTask = null;
    });

    try {
      final task = await downloadManager.startDownload(
        url: url,
        fileName: getFileNameFromUrl(url),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        currentTask = task;
        downloading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        downloading = false;
      });

      showMessage(
        'Download failed: $error',
      );
    }
  }

  String getFileNameFromUrl(String url) {
    final uri = Uri.tryParse(url);

    if (uri == null || uri.pathSegments.isEmpty) {
      return 'download_file';
    }

    final fileName = uri.pathSegments.last;

    if (fileName.isEmpty) {
      return 'download_file';
    }

    return fileName;
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    urlController.dispose();
    downloadManager.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initializeDownloadManager();
  }

  Future<void> initializeDownloadManager() async {
    await downloadManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            const Text(
              'Download File',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Enter a direct file URL to start downloading.',
            ),

            const SizedBox(height: 24),

            TextField(
              controller: urlController,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Download URL',
                hintText: 'https://example.com/file.pdf',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: downloading ? null : startDownload,
              icon: const Icon(Icons.download),
              label: Text(
                downloading ? 'Downloading...' : 'Download',
              ),
            ),

            const SizedBox(height: 40),

            StreamBuilder<DownloadTask>(
              stream: downloadManager.taskStream,
              builder: (context, snapshot) {
                final task = snapshot.data ?? currentTask;

                if (task == null) {
                  return const Center(
                    child: Text(
                      'No active download',
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      task.fileName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    LinearProgressIndicator(
                      value: task.progress,
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(task.progress * 100).toStringAsFixed(0)}%',
                        ),
                        Text(
                          task.status.name,
                        ),
                      ],
                    ),

                    if (task.filePath != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        task.filePath!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}