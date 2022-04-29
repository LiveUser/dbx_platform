import 'dart:convert';
import 'package:dbx_platform/dbx_platform.dart';
import 'package:test/test.dart';
import 'dart:io';

const String accessToken = "";
//Change the variables below before uploading package
const String appKey = "";
const String appSecret = "";
void main() {
  DBX dbx = DBX(
    accessToken: accessToken, 
    appKey: appKey, 
    appSecret: appSecret,
  );
  test("Folder creation test", ()async{
    print(await dbx.createFolder(
        folderToCreate: DBX_Directory(
          path: "/test",
        ),
      ),
    );
  });
  test("Folder exists", ()async{
    print(await dbx.itemExists(
        dbx_item: DBX_Directory(
          path: "/test",
        ),
      ),
    );
  });
  test("Delete folder", ()async{
    print(await dbx.deleteItem(
        dbx_item: DBX_Directory(
          path: "/test",
        ),
      ),
    );
  });
  test("File creation test", ()async{
    print(await dbx.createFile(
        fileToUpload: File("./test_assets/test.odt"), 
        fileToCreate: DBX_File(
          path: "/test.odt",
        ), 
        mode: WriteMode.add,
        mute: true,
      ),
    );
  });
  test("File exists test", ()async{
    print(await dbx.itemExists(
        dbx_item: DBX_File(
          path: "/test.odt",
        ),
      ),
    );
  });
  test("readFileAsBytes test", ()async{
    List<int> bytes = await dbx.readFileAsBytes(
      dbx_file: DBX_File(path: "/test.odt"),
    );
    File file = File("test_database/test.odt");
    file.createSync(recursive: true);
    file.writeAsBytesSync(bytes);
  });
  test("readFileAsBytes test", ()async{
    String stringContent = await dbx.readFileAsString(
      dbx_file: DBX_File(path: "/test.odt"),
    );
    prints(stringContent);
  });
  test("Get item metadata", ()async{
    DBX_Item_Metadata? dbx_item_metadata = await dbx.itemMetadata(
      dbx_item: DBX_File(path: "/test.odt"),
    );
    if(dbx_item_metadata != null){
      print(dbx_item_metadata.name);
      print("Modified by client on : ${dbx_item_metadata.client_modified!.toString()}");
      print("File size: ${dbx_item_metadata.size}");
    }
  });
  test("Folder list test", ()async{
    await dbx.createFolder(
      folderToCreate: DBX_Directory(path: "/database/something_cool"),
    );
    await dbx.createFile(
      fileToUpload: File("test_database/test.odt"), 
      fileToCreate: DBX_File(path: "/database/test.odt"), 
      mode: WriteMode.add,
    );
    List<DBX_Item> items = await dbx.list(
      dbx_directory: DBX_Directory(path: "/database"),
    );
    print(items);
  });
  test("downloadEntireFolderAsZip", ()async{
    await dbx.downloadEntireFolderAsZip(
      dbx_directory: DBX_Directory(path: "/database/"), 
      output: File("test_database/entireFolder.zip"),
    );
  });
  test("Get image thumbnail", ()async{
    //Create a test
    DBX_File dropboxFile = DBX_File(path: "/images/logo.png");
    File localImage = File("test_assets/logo.png");
    await dbx.createFile(
      fileToUpload: localImage, 
      fileToCreate: dropboxFile, 
      mode: WriteMode.add,
    );
    List<int> bytes = await dbx.getThumbnail(
      image: dropboxFile,
      format: ThumbnailFormat.png,
    );
    File output = File("test_database/logo.png");
    await output.create(recursive: true);
    await output.writeAsBytes(bytes);
  });
  test("Create file from memory", ()async{
    Map<String,dynamic> object = {
      "nombre" : "alguien",
    };
    String json = jsonEncode(object);
    DBX_File dbx_file = DBX_File(path: "/algo.json");
    await dbx.createFileFromMemory(
      bytes: json.codeUnits, 
      fileToCreate: dbx_file, 
      mode: WriteMode.add,
    );
  });
  test("Metadata file test", ()async{
    DBX_File fileFullOfMetadata = DBX_File(path: "/fileFullOfMetadata.txt");
    //Create file
    await dbx.createFileFromMemory(
      bytes: "Hello World".codeUnits, 
      fileToCreate: fileFullOfMetadata, 
      mode: WriteMode.overwrite,
    );
    //Add tag
    await dbx.addTag(
      dbx_file: fileFullOfMetadata, 
      tag_text: "Hello",
    );
    //Get files with their respective tags
    List<DBX_File> filesWithTags = await dbx.getTags(files: [
      fileFullOfMetadata,
    ]);
    print(filesWithTags.first.tags!.first.tag_text);
  });
  test("Search", ()async{
    SearchResults searchResults = await dbx.search(searchQuery: "file full of metadata");
    print(searchResults.items);
  });
  test("Remove tag", ()async{
    DBX_File fileFullOfMetadata = DBX_File(path: "/fileFullOfMetadata.txt");
    await dbx.removeTag(
      dbx_file: fileFullOfMetadata, 
      tag_text: "Hello",
    );
    //Get files with their respective tags
    List<DBX_File> filesWithTags = await dbx.getTags(files: [
      fileFullOfMetadata,
    ]);
    print(filesWithTags);
  });
}
