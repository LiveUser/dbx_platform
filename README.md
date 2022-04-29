# dbx_platform
unofficial Dropbox client<br/>
Hecho en 🇵🇷 por Radamés J. Valentín Reyes

## Important notes

- File System paths on DropBox Platform must always start with a "/"
- Note: dbx_directory must have a "/" on the right of the folder name(end of the path) in order for "Download entire folder as .zip" function to work properly

Getting an API key and other required info
------------------------------------------------------------

## Step 1

Tap/click the image below to visit the Dropbox developer website and tap the button that says "App console" on the top right corner. Login or create an account if necessary.

[![Dropbox developer website](https://by3302files.storage.live.com/y4mcBsi8sAyQqYZqtqpow8kmEPftMNI4C9SMZFQIB5LFazZe15aZYir-JAPPEiRHXX9rsfhfx0gDfEPdFP9i_YSPfzw9iqpi4qwefJ-N7RYkRH3VVHaF0VzPM1AMsb4Xsx2keGqfqfMxJPYuVgEv0TgszjPa_zhebCHFj0_XWPvofpkKFvKKv2vu7oMZjU9Cg5r?width=1920&height=1020&cropmode=none)](https://developers.dropbox.com/)

## Step 2

![Create app page](https://by3302files.storage.live.com/y4mC_kTvb-oBJJ82BlcvgTUmtdNOgyPByjO8qB0m4wiThjwQk48SRQAiSFTkGuDoavYRFO5SEFkBWldo8Z9u0BDAwa5BSegG1_yVQOJvmd0VYUCo_07j_tKXWDUVo3BUMpVbduBGNwHcx7qru5KA9Xn_dHWGNzmVVsuOtPiCppU7GRF9rm2Kkl4ULFC5cEYuMyp?width=1920&height=1020&cropmode=none)

## Step 3

Make selections from the given options and tap/click on Create app button

![Make selections from the given options](https://by3302files.storage.live.com/y4mEBWrWr7A8sCJJkSvLbuONqa0MjINPY_Ms67aQ9_l3JwVQdOmXmof5aYiNSenjMkekSCRNrDJjr7y8vdt0kuQbjbN6m7K-qy1FUEPu-zErkLBUcIQJkSBrZv20y6GNmOQvwgsaUMdeH9e4Lpa0AOtQ7Ioe3tEmnH_QLaCJ2GKpej3fDremvsvqZ6vBhnX7NhN?width=1920&height=1020&cropmode=none)

## Step 4

Enable permissions from the app page on the developer console. You need read and write permissions enabled so that your API calls don't throw an error.

![Permissions](https://by3302files.storage.live.com/y4m2pb9NxBurZoS679ACQYGYO6j3AgGfpinzVOImoFxlu5v0bUdwJYIeP7fGTw367okAjxj5PE5QtIB1I0QPIGBth4GppSBXCxvPFDhccb-1I-FpkgPn2RFjDwgftE8BxBWdyH_6aalJhx7He4v0Af9rLC2dnL6H1VOjhM3lbhoVbxzTwLlvFhx0WOrWrgzczlp?width=1920&height=1020&cropmode=none)

## Step 5

Generate an access token. Go to the Settings tab of your app to generate the access token, copy the app key and app secret for later use.

![Token generation](https://by3302files.storage.live.com/y4m_bthdrTFZJjG6Pls752KES_5Rc43RVyrgnY-12A7GPT6AVd_ytw85QLMrUdIlrLLO_cipxpFPOQ25s87kJojFmnQpZNyrIEEAMVM-Tfo8Ad3gVzrRtN7_EHSG3fgyPA5GfRgL51H8rGds05Cd3VOfhoWvUDpknkOjRc1z2sRE571Pdbo-yikcWfha8GqFqpN?width=1920&height=1020&cropmode=none)


------------------------------------------------------------

Import the dart package
------------------------------------------------------------
~~~dart
import 'package:dbx_platform/dbx_platform.dart';
import 'dart:io';
~~~
------------------------------------------------------------
Dropbox instance
------------------------------------------------------------
~~~dart
DBX dbx = DBX(
  accessToken: accessToken, 
  appKey: appKey,
  appSecret: appSecret,
);
~~~
------------------------------------------------------------
Functions(performs the API calls)
------------------------------------------------------------
## Create folder/directory

Creates a directory on the specified path.

~~~dart
await dbx.createFolder(
  folderToCreate: DBX_Directory(
    path: "/test",
  ),
);
~~~
## Delete DBX_Item

Deletes the specified item. Can delete both DBX_File and DBX_Directory.

~~~dart
await dbx.deleteItem(
  dbx_item: DBX_Directory(
	path: "/test",
  ),
);
~~~

## DBX_Item Exists

Returns a Boolean value telling whether or not the specified item exists.

~~~dart
await dbx.itemExists(
  dbx_item: DBX_Directory(
	path: "/test",
  ),
);
~~~

## Upload file/Create file

Creates a file on dropbox and saves the byte data from the specified local file into the created DBX_File on the cloud. If the file exists it can be overwriten by changing the mode.

~~~dart
await dbx.createFile(
  fileToUpload: File("./test_assets/test.odt"), 
  fileToCreate: DBX_File(
    path: "/test.odt",
  ), 
  mode: WriteMode.add,
  mute: true,
);
~~~
## Read file as bytes (download file)

Returns a list of bytes if the file exists

~~~dart
List<int> bytes = await dbx.readFileAsBytes(
  dbx_file: DBX_File(path: "/test.odt"),
);
File file = File("test_files/test.odt");
file.createSync(recursive: true);
file.writeAsBytesSync(bytes);
~~~
## Read file as String

Returns the file content as a string if the file exists

~~~dart
String stringContent = await dbx.readFileAsString(
  dbx_file: DBX_File(path: "/test.odt"),
);
~~~
## Get item metadata

Returns the item metadata if the item exists. Returns null if it does not.

~~~dart
DBX_Item_Metadata? dbx_item_metadata = await dbx.itemMetadata(
  dbx_item: DBX_File(path: "/test.odt"),
);
if(dbx_item_metadata != null){
  print(dbx_item_metadata.name);
  print("Modified by client on : ${dbx_item_metadata.client_modified.toString()}");
  print("File size: ${dbx_item_metadata.size}");
}
~~~
## List folder/directory contents
Get a list of all of the items within a folder/directory
~~~dart
await dbx.list(
  dbx_directory: DBX_Directory(path: "/database"),
);
~~~
## Download entire folder as .zip

Downloads a DBX_Directory as a .zip and saves it to the desired output file location

~~~dart
await dbx.downloadEntireFolderAsZip(
  dbx_directory: DBX_Directory(path: "/database/"), 
  output: File("test_database/entireFolder.zip"),
),
~~~
## Get thumbnail

Generates and returns a thumbnail of the specified image

~~~dart
List<int> bytes = await dbx.getThumbnail(
  image: dropboxFile,
  format: ThumbnailFormat.png,
);
~~~
## Create file from memory

Creates a file and saves in it the bytes that you suply from your memory

~~~dart
await dbx.createFileFromMemory(
  bytes: bytes, 
  fileToCreate: dbx_file, 
  mode: WriteMode.add,
);
~~~
## Search
~~~dart
SearchResults searchResults = await dbx.search(searchQuery: "file full of metadata");
~~~

------------------------------------------------------------
# Note
Must choose Full Dropbox access in order to avoid getting an error when using the tag functions. I don't know why but unfortunately that's how it works(or at least in April 29 2022 9am UTC-4).
![Full Dropbox Access screen](https://by3302files.storage.live.com/y4mtKsb6srMwYNV0XRbWD6UUi61YxIcFrKFuHvOCqjWYsJHl0Q-phx343N0-I-l3tIfO1KWBLExev8Cg0l5YWS7yU-dkHDr75JnU8DkpQVC1QbZNjUuce6iEimg7245IBR3HUyMQ6nHLEVpewoyC6hMFm1cc3xaWk6XlZB1Dz07Lp1QZwrXBQ_a5yafhHFyyigU?width=1920&height=1020&cropmode=none)

## Add tag

Adds a certain tag to a file

~~~dart
await dbx.addTag(
  dbx_file: fileFullOfTags, 
  tag_text: "Hello",
);
~~~
## Remove Tag

Removes the specified tag from the specified file

~~~dart
await dbx.removeTag(
  dbx_file: fileFullOfTags, 
  tag_text: "Hello",
);
~~~
## Get tags

Retrieves the tags asociated with the files sent as parameters and adds them to the corresponding files.

~~~dart
List<DBX_File> filesWithTags = await dbx.getTags(files: []);
~~~

------------------------------------------------------------
## Full Examples
### Example 1
Creating files and folders and listing a folder's contents
~~~dart
//Create 2 folders. database and something_cool inside of database
await dbx.createFolder(
  folderToCreate: DBX_Directory(path: "/database/something_cool"),
);
//Create a file inside the database folder
await dbx.createFile(
  fileToUpload: File("test_database/test.odt"), 
  fileToCreate: DBX_File(path: "/database/test.odt"), 
  mode: WriteMode.add,
);
//List all database folder contents
List<DBX_Item> items = await dbx.list(
  dbx_directory: DBX_Directory(path: "/database"),
);
//Print the list
print(items);
~~~
### Example 2
Uploading an image file, downloading and saving a thumbnail.
~~~dart
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
~~~
### Example 3
Create a file 
~~~dart
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
~~~
### Example 4
Metadata
~~~dart
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
~~~
### Example 5
Search
~~~dart
SearchResults searchResults = await dbx.search(searchQuery: "file full of metadata");
print(searchResults.items);
~~~
------------------------------------------------------------
## Contribute/donate by tapping on the Pay Pal logo/image

<a href="https://www.paypal.com/paypalme/onlinespawn"><img src="https://www.paypalobjects.com/webstatic/mktg/logo/pp_cc_mark_74x46.jpg"/></a>

------------------------------------------------------------
## References
- https://www.dropboxforum.com/t5/Dropbox-API-Support-Feedback/Share-a-folder-for-uploading-files/td-p/472686
- https://www.dropbox.com/developers/documentation/http/documentation#file_requests-create
- https://www.dropbox.com/developers/reference/auth-types#user
- https://www.dropbox.com/developers/reference/content-hash
- https://www.dropboxforum.com/t5/Dropbox-API-Support-Feedback/Error-in-call-to-API-function-quot-files-upload-quot-HTTP-header/td-p/461110
- https://riptutorial.com/dropbox-api/example/1356/uploading-a-file-via-curl
- https://riptutorial.com/ebook/dropbox-api
- https://riptutorial.com/dropbox-api/example/1348/downloading-a-file-via-curl
- https://reqbin.com/req/c-woh4qwov/curl-content-type
