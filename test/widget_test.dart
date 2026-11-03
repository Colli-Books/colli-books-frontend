import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:colli_books_frontend/main.dart';
import 'package:colli_books_frontend/core/widgets/fullscreen_image_viewer.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
  });

  test('isPdfCover correctly detects pdf files by extension and bytes', () {
    expect(isPdfCover('livro.pdf', null), isTrue);
    expect(isPdfCover('LIVRO.PDF', null), isTrue);
    expect(isPdfCover('capa.png', null), isFalse);
    expect(isPdfCover(null, null), isFalse);

    // Magic bytes %PDF-
    final pdfBytes = [0x25, 0x50, 0x44, 0x46, 0x2D, 0x31];
    expect(isPdfCover('arquivo_sem_extensao', Uint8List.fromList(pdfBytes)), isTrue);
  });
}
