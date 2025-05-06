import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> generatePdf(pw.Document pdf) async {
  // Save the PDF to a file or display it in a viewer.
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/example.pdf');
  await file.writeAsBytes(await pdf.save());

  // Display the PDF in a viewer or share it.
  final result = await OpenFile.open(file.path);
  if (result.type == ResultType.done) {
    if (kDebugMode) {
      print("PDF opened successfully.");
    }
  } else {
    if (kDebugMode) {
      print("Failed to open PDF: ${result.message}");
    }
  }

  if (kDebugMode) {
    print("PDF généré sur mobile");
  }
}
