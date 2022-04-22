# dbx_platform
unofficial Dropbox client
Hecho en 🇵🇷 por Radamés J. Valentín Reyes



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
## Create folder
~~~dart
await dbx.createFolder(
  fileRequestTitle: "Folder creation test", 
  folderToCreate: Directory("/test"),
);
~~~
## Delete folder

~~~dart
await dbx.deleteFolder(
  folderToDelete: Directory("/test"),
);
~~~

## Folder Exists

~~~dart
await dbx.folderExists(
  folderToCheck: Directory("/test"),
);
~~~

## Upload file/Create file

~~~dart
await dbx.createFile(
  fileToUpload: File("./test_assets/test.odt"), 
  path: "/test.odt", 
  mode: WriteMode.add,
  mute: true,
);
~~~
## File exists
~~~dart
await dbx.fileExists(
  fileToCheck: File("/test.odt"),
);
~~~
## Delete file
~~~dart
await dbx.deleteFile(
  fileToDelete: File("/test.odt"),
);
~~~
## Download file
~~~dart
List<int> bytes = await dbx.readFileAsBytes(
  file: File("/test.odt"),
);
File file = File("test_files/test.odt");
file.createSync(recursive: true);
file.writeAsBytesSync(bytes);
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
