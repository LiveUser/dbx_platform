import 'package:dbx_platform/dbx_platform.dart';
import 'package:test/test.dart';
import 'dart:io';

const String accessToken = "sl.BGMUW2R4y4KVwLWGDHL9r-v2k_b6Z5N6dLTxts3eL2bhEaDdxUpyqST9XNnurjdVV5dnT0QeduqFwZXwxI-7xKFzI3eDU2yEm3rMD_ut-LbKd76qhzdqlyc28V-uSkVRtsQ7p9Pj";
//TODO: Change the variables below before uploading package
const String appKey = "4t391lu5bh0jo19";
const String appSecret = "4t391lu5bh0jo19";
void main() {
  DBX dbx = DBX(
    accessToken: accessToken, 
    appKey: appKey, 
    appSecret: appSecret,
  );
  test("Folder creation test", ()async{
    print(await dbx.createFolder(
        folderToCreate: Directory("/test"),
      ),
    );
  });
  test("Folder exists", ()async{
    print(await dbx.folderExists(
        folderToCheck: Directory("/test"),
      ),
    );
  });
  test("Delete folder", ()async{
    print(await dbx.deleteFolder(
        folderToDelete: Directory("/test"),
      ),
    );
  });
  test("File creation test", ()async{
    print(await dbx.createFile(
        fileToUpload: File("./test_assets/test.odt"), 
        path: "/test.odt", 
        mode: WriteMode.add,
        mute: true,
      )
    );
  });
  test("File exists test", ()async{
    print(await dbx.fileExists(
        fileToCheck: File("/test.odt"),
      ),
    );
  });
  test("Download file test", ()async{
    List<int> bytes = await dbx.readFileAsBytes(
      file: File("/test.odt"),
    );
    File file = File("test_files/test.odt");
    file.createSync(recursive: true);
    file.writeAsBytesSync(bytes);
  });
  test("File deletion test", ()async{
    print(await dbx.deleteFile(
        fileToDelete: File("/test.odt"),
      ),
    );
  });
}
