import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:kino_ne/models/page.dart' as model;

class PdfExportService {
  static Future<void> exportFullNotebook(
    String title,
    List<model.Page> pages,
  ) async {
    final doc = pw.Document();

    // 日本語フォントの読み込み
    final font = await PdfGoogleFonts.notoSansJPRegular();
    final boldFont = await PdfGoogleFonts.notoSansJPBold();

    // 各ページをPDFのページとして追加
    for (var i = 0; i < pages.length; i++) {
      final pageData = pages[i];

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ヘッダー（タイトルとページ番号）
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      pageData.title,
                      style: pw.TextStyle(font: boldFont, fontSize: 20),
                    ),
                    pw.Text(
                      '${i + 1} / ${pages.length}',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  '更新日: ${pageData.updatedAt.toString().split(' ')[0]}',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColors.grey,
                  ),
                ),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 15),

                // 本文
                pw.Text(
                  pageData.content,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 13,
                    lineSpacing: 8, // 行間の調整
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    // PDFを表示・共有
    await Printing.sharePdf(
      bytes: await doc.save(),
      // ファイル名は「ノートのタイトル」など動的に変えられると良いですが、一旦固定
      filename: '$title.pdf',
    );
  }
}
