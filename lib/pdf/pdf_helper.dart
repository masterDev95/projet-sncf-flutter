import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:projet_sncf/enums/rechargement.dart';
import 'package:projet_sncf/enums/type_service.dart';
import '../models/gare_section_data.dart';

class PdfHelper {
  late pw.Document _doc;

  late pw.Font _fontRegular;
  late pw.Font _fontBold;
  late pw.Font _fontItalic;
  late pw.Font _fontBoldItalic;

  late pw.MemoryImage _logo;
  late pw.MemoryImage _checkIcon;
  late pw.MemoryImage _cancelIcon;
  late pw.MemoryImage _personIcon;

  final List<pw.Widget> _sections = [];

  String date;
  TypeService typeService;

  PdfHelper(this.date, this.typeService);

  /// Initialise polices + images
  Future<void> init() async {
    _fontRegular = await _loadFont('assets/fonts/IBMPlexSans-Regular.ttf');
    _fontBold = await _loadFont('assets/fonts/IBMPlexSans-Bold.ttf');
    _fontItalic = await _loadFont('assets/fonts/IBMPlexSans-Italic.ttf');
    _fontBoldItalic = await _loadFont(
      'assets/fonts/IBMPlexSans-BoldItalic.ttf',
    );

    _logo = await _loadImage('assets/images/logo.png');
    _checkIcon = await _loadImage('assets/images/check_circle.png');
    _cancelIcon = await _loadImage('assets/images/cancel.png');
    _personIcon = await _loadImage('assets/images/person.png');

    _doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: _fontRegular,
        bold: _fontBold,
        italic: _fontItalic,
        boldItalic: _fontBoldItalic,
      ),
    );
  }

  /// Ajoute une section de gare
  void addSection(GareSectionData data) {
    _sections.add(
      pw.Builder(builder: (context) => _buildGareSection(data, context)),
    );
    _sections.add(pw.SizedBox(height: 24)); // espace entre sections
  }

  /// Construit le PDF
  pw.Document build() {
    _doc.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildHeader(),
          pw.SizedBox(height: 32),
          ..._sections,
        ],
      ),
    );
    return _doc;
  }

  /// Sauvegarde le fichier localement
  Future<void> save(String path) async {
    final file = File(path);
    await file.writeAsBytes(await _doc.save());
  }

  /// Header du rapport
  pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Image(_logo, width: 100),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text("Rapport", style: pw.TextStyle(fontSize: 32)),
            pw.Text(date, style: pw.TextStyle(fontSize: 16)),
            pw.Text(
              typeService == TypeService.matinee ? "Matinée" : "Soirée",
              style: pw.TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  /// Section d'une gare (style Argenteuil)
  pw.Widget _buildGareSection(GareSectionData data, pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          data.gare,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 32),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 40),
          child: pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#570036'),
              borderRadius: pw.BorderRadius.circular(20),
            ),
            width: double.infinity,
            child: pw.Column(
              children: [
                // Profil
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#660040'),
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Image(_personIcon, width: 24),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              data.personnes,
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Badges
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBadge(
                      'SAM',
                      image: data.sam ? _checkIcon : _cancelIcon,
                    ),
                    _buildBadge(
                      'AGITE',
                      image: data.agite ? _checkIcon : _cancelIcon,
                    ),
                    _buildBadge('CAB', label: data.cab),
                  ],
                ),
                pw.SizedBox(height: 20),

                pw.Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 12),
                  textAlign: pw.TextAlign.justify,
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 40),
        pw.TableHelper.fromTextArray(
          context: context,
          headers: [
            'ART',
            'Rechargement',
            '5cts',
            'Prévoir monnaie',
            'Chgt bobineaux',
            'Prévoir bobineaux',
            'Retrait caisse',
            'Commentaire',
          ],
          data: data.artList.map((art) {
            return [
              art.nom,
              art.rechargements.map((e) => rechargementLabel(e)).join(', '),
              art.nombrePiecesDeCinqCentimes.toString(),
              art.doitPrevoirMonnaie ? "Oui" : "Non",
              art.changementDeBobineaux ? "Oui" : "Non",
              art.doitPrevoirBobineaux ? "Oui" : "Non",
              art.isRetraitCaisseEffectue ? "Oui" : "Non",
              art.commentaire.isNotEmpty ? art.commentaire : "Vide",
            ];
          }).toList(),
          cellStyle: pw.TextStyle(fontSize: 8),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
          ),
          cellAlignment: pw.Alignment.centerLeft,
          columnWidths: {
            0: const pw.FixedColumnWidth(30),
            1: const pw.FixedColumnWidth(90),
            2: const pw.FixedColumnWidth(30),
            3: const pw.FixedColumnWidth(45),
            4: const pw.FixedColumnWidth(55),
            5: const pw.FixedColumnWidth(55),
            6: const pw.FixedColumnWidth(45),
            7: const pw.FlexColumnWidth(),
          },
          cellPadding: const pw.EdgeInsets.all(4),
          headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
          border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey600),
        ),
      ],
    );
  }

  String rechargementLabel(Rechargement r) {
    switch (r) {
      case Rechargement.cinqCts:
        return "5 cts";
      case Rechargement.dixCts:
        return "10 cts";
      case Rechargement.vingtCts:
        return "20 cts";
      case Rechargement.cinquanteCts:
        return "50 cts";
      case Rechargement.unEuro:
        return "1 €";
      case Rechargement.deuxEuros:
        return "2 €";
    }
  }

  /// Badge (image ou texte)
  pw.Widget _buildBadge(String title, {pw.MemoryImage? image, String? label}) {
    return pw.Container(
      width: 110,
      height: 64,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#660040'),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: image != null
          ? pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                pw.SizedBox(width: 4),
                pw.Image(image, width: 32),
              ],
            )
          : pw.Column(
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  label ?? '',
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 10),
                ),
              ],
            ),
    );
  }

  /// Charge une police
  Future<pw.Font> _loadFont(String path) async {
    final data = await rootBundle.load(path);
    return pw.Font.ttf(data);
  }

  /// Charge une image
  Future<pw.MemoryImage> _loadImage(String path) async {
    final data = await rootBundle.load(path);
    return pw.MemoryImage(data.buffer.asUint8List());
  }

  /// Force un saut de page
  void addPageBreak() {
    _sections.add(pw.NewPage());
  }
}
