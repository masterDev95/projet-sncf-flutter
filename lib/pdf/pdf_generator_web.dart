import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'package:pdf/widgets.dart' as pw;

Future<void> generatePdf(pw.Document pdf) async {
  final pdfBytes = await pdf.save();
  List<int> fileInts = List.from(pdfBytes);

  web.HTMLAnchorElement()
    ..href =
        "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}"
    ..setAttribute("download", "${DateTime.now().millisecondsSinceEpoch}.pdf")
    ..click();

  if (kDebugMode) {
    print("PDF téléchargé depuis le web.");
  }
}
