import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:sexy_api_client/sexy_api_client.dart';

//-------------------------------------------------------------------------------------------------------
//Variables
const int four_mega_bytes = 4194304;
//-------------------------------------------------------------------------------------------------------
//Enum
enum WriteMode{
  ///Do not overwrite an existing file if there is a conflict. The autorename strategy is to append a number to the file name. For example, "document.txt" might become "document (2).txt".
  add,
  ///Always overwrite the existing file. The autorename strategy is the same as it is for add.
  overwrite,
  /// String(min_length=9, pattern="[0-9a-f]+")Overwrite if the given "rev" matches the existing file's "rev". The supplied value should be the latest known "rev" of the file, for example, from FileMetadata, from when the file was last downloaded by the app. This will cause the file on the Dropbox servers to be overwritten if the given "rev" matches the existing file's current "rev" on the Dropbox servers. The autorename strategy is to append the string "conflicted copy" to the file name. For example, "document.txt" might become "document (conflicted copy).txt" or "document (Panda's conflicted copy).txt".
  update,
}
//-------------------------------------------------------------------------------------------------------
//local functions
String _writeModeToString(WriteMode mode){
  String stringyfiedMode = mode.toString();
  return stringyfiedMode.substring(stringyfiedMode.lastIndexOf(".") + 1);
}
void _errorThrower(String serverResponse){
  Map<String,dynamic> parsedServerResponse;
  try{
    parsedServerResponse = jsonDecode(serverResponse);
    if(parsedServerResponse["error"] != null){
      throw parsedServerResponse["error_summary"];
    }
  }catch(err){
    //Nada
  }
}
//-------------------------------------------------------------------------------------------------------
//Dropbox platform methods access
//https://www.dropbox.com/developers/documentation/http/documentation
class DBX {
  DBX({
    required this.accessToken,
    required this.appKey,
    required this.appSecret,
  });
  final String accessToken;
  final String appKey;
  final String appSecret;
  Future<String> createFolder({
    ///String(pattern="(/(.|[\r\n])*)|(ns:[0-9]+(/.*)?)")Path in the user's Dropbox to create.
    required Directory folderToCreate,
    ///BooleanIf there's a conflict, have the Dropbox server try to autorename the folder to avoid the conflict. The default for this field is False.
    bool autoRename = false,
  })async{
    Map<String,dynamic> parameters = {
      "autorename" : autoRename,
      "path" : folderToCreate.path,
    };
    String response = await SexyAPI(
      url: "https://api.dropboxapi.com",
      path: "/2/files/create_folder_v2",
      parameters: {},
    ).post(
      headers: {
        "Content-Type" : "application/json",
        "Authorization" : "Bearer $accessToken",
      },
      body: jsonEncode(parameters),
    );
    _errorThrower(response);
    return response;
  }
  Future<String> deleteFolder({
    required Directory folderToDelete,
  })async{
    Map<String,dynamic> parameters = {
      "path" : folderToDelete.path,
    };
    String response = await SexyAPI(
      url: "https://api.dropboxapi.com",
      path: "/2/files/delete_v2",
      parameters: {},
    ).post(
      headers: {
        "Content-Type" : "application/json",
        "Authorization" : "Bearer $accessToken",
      },
      body: jsonEncode(parameters),
    );
    _errorThrower(response);
    return response;
  }
  Future<bool> folderExists({
    required Directory folderToCheck,
  })async{
    Map<String,dynamic> parameters = {
      "include_deleted": false,
      "include_has_explicit_shared_members": false,
      "include_media_info": false,
      "path": folderToCheck.path,
    };
    String response = await SexyAPI(
      url: "https://api.dropboxapi.com",
      path: "/2/files/get_metadata",
      parameters: {},
    ).post(
      headers: {
        "Content-Type" : "application/json",
        "Authorization" : "Bearer $accessToken",
      },
      body: jsonEncode(parameters),
    );
    try{
      _errorThrower(response);
      return true;
    }catch(error){
      if(error == "path/not_found/."){
        return false;
      }else{
        throw error;
      }
    }
  }
  //TODO: List folder contents. Return a list of both directories and files
  
  
  //https://www.dropbox.com/developers/documentation/http/documentation#files-upload
  Future<String> createFile({
    ///File on your system that you want to upload
    required File fileToUpload,
    ///Path where it will be placed on dropbox
    required String path,
    required WriteMode mode,
    ///BooleanIf there's a conflict, as determined by mode, have the Dropbox server try to autorename the file to avoid conflict. The default for this field is False.
    bool autorename = false,
    ///The value to store as the client_modified timestamp. Dropbox automatically records the time at which the file was written to the Dropbox servers. It can also record an additional timestamp, provided by Dropbox desktop clients, mobile clients, and API apps of when the file was actually created or modified. This field is optional.
    DateTime? client_modified,
    ///BooleanNormally, users are made aware of any file modifications in their Dropbox account via notifications in the client software. If true, this tells the clients that this modification shouldn't result in a user notification. The default for this field is False.
    bool mute = false,
    ///BooleanBe more strict about how each WriteMode detects conflict. For example, always return a conflict error when mode = WriteMode.update and the given "rev" doesn't match the existing file's "rev", even if the existing file has been deleted. This also forces a conflict even when the target path refers to a file with identical contents. The default for this field is False.
    bool strict_conflict = false,
    /*///String(min_length=64, max_length=64)?A hash of the file content uploaded in this call. If provided and the uploaded content does not match this hash, an error will be returned. For more information see our Content hash page. This field is optional.
    required String content_hash,*/
  })async{
    Map<String,dynamic> dropboxApiArguments = {
      "path" : path,
      "mode" : _writeModeToString(mode),
      "autorename" :autorename,
      "mute" : mute,
      "strict_conflict" : strict_conflict,
    };
    String response = await SexyAPI(
      url: "https://content.dropboxapi.com", 
      path: "/2/files/upload",
      parameters: {},
    ).post(
      headers: {
        "Content-Type" : "application/octet-stream",
        "Authorization" : "Bearer $accessToken",
        "Dropbox-API-Arg" : jsonEncode(dropboxApiArguments),
      },
      body: await fileToUpload.readAsBytes(),
    );
    _errorThrower(response);
    return response;
  }
  Future<bool> fileExists({
    required File fileToCheck,
  })async{
    Map<String,dynamic> parameters = {
      "include_deleted": false,
      "include_has_explicit_shared_members": false,
      "include_media_info": false,
      "path": fileToCheck.path,
    };
    String response = await SexyAPI(
      url: "https://api.dropboxapi.com",
      path: "/2/files/get_metadata",
      parameters: {},
    ).post(
      headers: {
        "Content-Type" : "application/json",
        "Authorization" : "Bearer $accessToken",
      },
      body: jsonEncode(parameters),
    );
    try{
      _errorThrower(response);
      return true;
    }catch(error){
      if(error == "path/not_found/."){
        return false;
      }else{
        throw error;
      }
    }
  }
  Future<String> deleteFile({
    required File fileToDelete,
  })async{
    Map<String,dynamic> parameters = {
      "path" : fileToDelete.path,
    };
    String response = await SexyAPI(
      url: "https://api.dropboxapi.com",
      path: "/2/files/delete_v2",
      parameters: {},
    ).post(
      headers: {
        "Content-Type" : "application/json",
        "Authorization" : "Bearer $accessToken",
      },
      body: jsonEncode(parameters),
    );
    _errorThrower(response);
    return response;
  }
  Future<List<int>> readFileAsBytes({
    required File file,
  })async{
    Map<String,dynamic> parameters = {
      "path" : file.path,
    };
    String response = await SexyAPI(
      url: "https://content.dropboxapi.com",
      path: "/2/files/download",
      parameters: {},
    ).post(
      headers: {
        "Authorization" : "Bearer $accessToken",
        "Dropbox-API-Arg" : jsonEncode(parameters),
        "Accept" : 'application/json',
      },
      body: null,
    );
    _errorThrower(response);
    return response.codeUnits;
  }
}
//TODO: List directory
//TODO: Download file content