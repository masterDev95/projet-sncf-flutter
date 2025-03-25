import 'dart:io';

import 'package:flutter/material.dart';
import 'package:projet_sncf/main.dart';
import 'package:projet_sncf/utils/app_colors.dart';

class DownloadProgressDialog extends StatefulWidget {
  final String url;

  const DownloadProgressDialog({super.key, required this.url});

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    File apk = await downloadApk(widget.url, (progressValue) {
      setState(() {
        progress = progressValue;
      });
    });

    await installApkWithOpenFile(apk.path);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Téléchargement en cours'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.secondaryColorButLight,
          ),
          const SizedBox(height: 20),
          Text('${(progress * 100).toStringAsFixed(2)}% téléchargé'),
        ],
      ),
    );
  }
}
