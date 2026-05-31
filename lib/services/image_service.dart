import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageService {
  static final _picker = ImagePicker();

  static Future<String?> pickCompanyLogo() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (picked == null) return null;
      final dir = await getApplicationDocumentsDirectory();
      final dest = p.join(dir.path, 'company_logo.png');
      await File(picked.path).copy(dest);
      return dest;
    } catch (_) {
      return null;
    }
  }
}
