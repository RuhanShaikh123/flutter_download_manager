import 'package:open_filex/open_filex.dart';

class FileOpenService {
  Future<void> openFile(String filePath) async {
    await OpenFilex.open(filePath);
  }
}