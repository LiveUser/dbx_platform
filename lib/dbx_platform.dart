import 'dart:convert';
import 'dart:io';
import 'package:sexy_api_client/sexy_api_client.dart';

//-------------------------------------------------------------------------------------------------------
//Variables and classes
//Info about the file or folder
class DBX_Item_Metadata{
  DBX_Item_Metadata({
    required this.tag,//
    this.client_modified,
    this.content_hash,
    required this.id,//
    this.is_downloadable,
    required this.name,//
    required this.path_display,//
    required this.path_lower,//
    this.rev,
    this.server_modified,
    this.size,
  });
  final String tag;
  final DateTime? client_modified;
  final String? content_hash;
  final String id;
  final bool? is_downloadable;
  final String name;
  final String path_display;
  final String path_lower;
  final String? rev;
  final DateTime? server_modified;
  final int? size;
}
class DBX_Item{
  DBX_Item({
    required this.path,
    this.metadata,
  });
  final String path;
  final DBX_Item_Metadata? metadata;
}
class DBX_Directory extends DBX_Item{
  DBX_Directory({
    required this.path,
    this.metadata,
  }):super(
    path: path,
    metadata: metadata,
  );
  final String path;
  final DBX_Item_Metadata? metadata;
}
class DBX_File extends DBX_Item{
  DBX_File({
    required this.path,
    this.metadata,
    this.tags,
  }):super(
    path: path,
    metadata: metadata,
  );
  final String path;
  final DBX_Item_Metadata? metadata;
  final List<DBX_Tag>? tags;
}
class DBX_Tag{
  DBX_Tag({
    required this.tag_text,
  });
  final String tag_text;
}
class SearchResults{
  SearchResults({
    required this.has_more,
    required this.items,
    this.cursor,
  });
  final bool has_more;
  final List<DBX_Item> items;
  ///A token to use to extract the remaining result using the search continue function
  final String? cursor;
}
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
enum ThumbnailFormat{
  jpeg,
  png,
}
enum ThumbnailSize{
  w32h32,
  w64h64,
  w128h128,
  w256h256,
  w480h320,
  w640h480,
  w960h640,
  w1024h768,
  w2048h1536,
}
enum ThumbnailMode{
  strict,
  bestfit,
  fitone_bestfit,
}
enum SearchOrderBy{
  relevance,
  last_modified_time,
}
enum FileCategory{
  ///jpg, png, gif, and more.
  image,
  ///doc, docx, txt, and more.
  document,
  ///pdf
  pdf,
  ///xlsx, xls, csv, and more.
  spreadsheet,
  ///ppt, pptx, key, and more.
  presentation,
  ///mp3, wav, mid, and more.
  audio,
  ///mov, wmv, mp4, and more.
  video,
  ///dropbox folder.
  folder,
  ///dropbox paper doc.
  paper,
  ///any file not in one of the categories above.
  others,
}
//-------------------------------------------------------------------------------------------------------
//local functions
String _enumeratedToString(Enum enumerated){
  String stringyfiedMode = enumerated.toString();
  return stringyfiedMode.substring(stringyfiedMode.lastIndexOf(".") + 1);
}
void _errorThrower(String serverResponse){
  Map<String,dynamic> parsedServerResponse;
  parsedServerResponse = jsonDecode(serverResponse);
  if(parsedServerResponse["error"] != null){
    throw parsedServerResponse["error_summary"];
  }
}
DBX_Item_Metadata _parseMetadata(String metadata){
  Map<String,dynamic> parsedMetadata = jsonDecode(metadata);
  return DBX_Item_Metadata(
    tag: parsedMetadata[".tag"], 
    client_modified: parsedMetadata["client_modified"] == null ? null : DateTime.parse(parsedMetadata["client_modified"]), 
    content_hash: parsedMetadata["content_hash"], 
    id: parsedMetadata["id"], 
    is_downloadable: parsedMetadata["is_downloadable"], 
    name: parsedMetadata["name"], 
    path_display: parsedMetadata["path_display"], 
    path_lower: parsedMetadata["path_lower"],
    rev: parsedMetadata["rev"], 
    server_modified: parsedMetadata["server_modified"] == null ? null : DateTime.parse(parsedMetadata["server_modified"]), 
    size: parsedMetadata["size"],
  );
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
    required DBX_Directory folderToCreate,
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
  Future<String> deleteItem({
    required DBX_Item dbx_item,
  })async{
    Map<String,dynamic> parameters = {
      "path" : dbx_item.path,
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
  Future<bool> itemExists({
    required DBX_Item dbx_item,
  })async{
    Map<String,dynamic> parameters = {
      "include_deleted": false,
      "include_has_explicit_shared_members": false,
      "include_media_info": false,
      "path": dbx_item.path,
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
      if((error as String).startsWith("path/not_found/")){
        return false;
      }else{
        throw error;
      }
    }
  }
  //List folder contents. Return a list of both directories and files
  Future<List<DBX_Item>> list({
    required DBX_Directory dbx_directory,
  })async{
    Map<String,dynamic> parameters = {
        "include_deleted": false,
        "include_has_explicit_shared_members": false,
        "include_media_info": false,
        "include_mounted_folders": true,
        "include_non_downloadable_files": true,
        "path": dbx_directory.path,
        "recursive": false,
    };
    String response = await SexyAPI(
      url: "https://api.dropboxapi.com",
      path: "/2/files/list_folder",
      parameters: {},
    ).post(
      headers: {
        "Content-Type" : "application/json",
        "Authorization" : "Bearer $accessToken",
      },
      body: jsonEncode(parameters),
    );
    _errorThrower(response);
    List<DBX_Item> items = [];
    Map<String,dynamic> serverResponse = jsonDecode(response);
    for(Map<String,dynamic> item in serverResponse["entries"] ?? []){
      DBX_Item_Metadata dbx_item_metadata = _parseMetadata(jsonEncode(item));
      if(dbx_item_metadata.tag == "file"){
        items.add(DBX_File(
            path: dbx_item_metadata.path_display,
            metadata: dbx_item_metadata,
          ),
        );
      }else{
        items.add(DBX_Directory(
            path: dbx_item_metadata.path_display,
            metadata: dbx_item_metadata,
          ),
        );
      }
    }
    //Return List<DBX_Item>
    return items;
  }
  //https://www.dropbox.com/developers/documentation/http/documentation#files-upload
  Future<String> createFile({
    ///File on your system that you want to upload
    required File fileToUpload,
    ///File to create on dropbox
    required DBX_File fileToCreate,
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
      "path" : fileToCreate.path,
      "mode" : _enumeratedToString(mode),
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
  //Create file with data from memory
    Future<String> createFileFromMemory({
    ///Bytes on your system's that you want to upload
    required List<int> bytes,
    ///File to create on dropbox
    required DBX_File fileToCreate,
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
      "path" : fileToCreate.path,
      "mode" : _enumeratedToString(mode),
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
      body: await bytes,
    );
    _errorThrower(response);
    return response;
  }
  Future<List<int>> readFileAsBytes({
    required DBX_File dbx_file,
  })async{
    Map<String,dynamic> parameters = {
      "path" : dbx_file.path,
    };
    String response = await SexyAPI(
      url: "https://content.dropboxapi.com",
      path: "/2/files/download",
      parameters: {},
    ).post(
      headers: {
        "Authorization" : "Bearer $accessToken",
        "Dropbox-API-Arg" : jsonEncode(parameters),
      },
      body: null,
    );
    _errorThrower(response);
    return response.codeUnits;
  }
  Future<String> readFileAsString({
    required DBX_File dbx_file,
  })async{
    Map<String,dynamic> parameters = {
      "path" : dbx_file.path,
    };
    String response = await SexyAPI(
      url: "https://content.dropboxapi.com",
      path: "/2/files/download",
      parameters: {},
    ).post(
      headers: {
        "Authorization" : "Bearer $accessToken",
        "Dropbox-API-Arg" : jsonEncode(parameters),
      },
      body: null,
    );
    _errorThrower(response);
    return response;
  }
  Future<DBX_Item_Metadata?> itemMetadata({
    required DBX_Item dbx_item,
  })async{
    //Request metadata if item exist. otherwise return null
    if(await itemExists(dbx_item: dbx_item)){
      Map<String,dynamic> parameters = {
        "include_deleted": false,
        "include_has_explicit_shared_members": false,
        "include_media_info": false,
        "path": dbx_item.path,
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
      _errorThrower(response);
      //Return parsed Metadata
      return _parseMetadata(response);
    }else{
      return null;
    }
  }
  //Download as zip
  Future<void> downloadEntireFolderAsZip({
    required DBX_Directory dbx_directory,
    required File output,
  })async{
    Map<String,dynamic> parameters = {
      "path" : dbx_directory.path,
    };
    String response = await SexyAPI(
      url: "https://content.dropboxapi.com",
      path: "/2/files/download_zip",
      parameters: {},
    ).post(
      headers: {
        "Content-Type" : "application/octet-stream",
        "Authorization" : "Bearer $accessToken",
        "Dropbox-API-Arg" : jsonEncode(parameters),
      },
      body: null,
    );
    _errorThrower(response);
    //Create the file where the output will be saved
    await output.create(recursive: true);
    //Save the bytes from the response into the output file
    await output.writeAsBytes(response.codeUnits);
  }
  Future<List<int>> getThumbnail({
    required DBX_File image,
    ThumbnailSize size = ThumbnailSize.w64h64,
    ThumbnailFormat format = ThumbnailFormat.jpeg,
    ThumbnailMode mode = ThumbnailMode.strict,
  })async{
    Map<String,dynamic> parameters = {
      //resource PathOrLink Information specifying which file to preview. This could be a path to a file, a shared link pointing to a file, or a shared link pointing to a folder, with a relative path.
      "resource": {
          ".tag": "path",
          "path": image.path,
      },
      //ThumbnailFormat The format for the thumbnail image, jpeg (default) or png. For images that are photos, jpeg should be preferred, while png is better for screenshots and digital arts. The default for this union is jpeg.
      "format": _enumeratedToString(format),
      //ThumbnailSize The size for the thumbnail image. The default for this union is w64h64.
      "size": _enumeratedToString(size),
      //ThumbnailMode How to resize and crop the image to achieve the desired size. The default for this union is strict.
      "mode": _enumeratedToString(mode),
    };
    String response = await SexyAPI(
      url: "https://content.dropboxapi.com",
      path: "/2/files/get_thumbnail_v2",
      parameters: {},
    ).post(
      headers: {
        "Content-Type" : "application/octet-stream",
        "Authorization" : "Bearer $accessToken",
        "Dropbox-API-Arg" : jsonEncode(parameters),
      },
      body: null,
    );
    return response.codeUnits;
  }
  //Get tags
  Future<List<DBX_File>> getTags({
    required List<DBX_File> files,
  })async{
    List<String> paths = [];
    List<DBX_File> filesWithMetadata = [];
    for(DBX_File file in files){
      paths.add(file.path);
    }
    Map<String,dynamic> parameters = {
      "paths" : paths,
    };
    String response = await SexyAPI(
      url: "https://api.dropboxapi.com",
      path: "/2/files/tags/get",
      parameters: {},
    ).post(
      headers: {
        "Content-Type" : "application/json",
        "Authorization" : "Bearer $accessToken",
      },
      body: jsonEncode(parameters),
    );
    _errorThrower(response);
    //Parse the response
    Map<String,dynamic> parsedJSON = jsonDecode(response);
    for(Map<String,dynamic> file in parsedJSON["paths_to_tags"]){
      List<DBX_Tag> tags = [];
      //Parse tags
      for(Map<String,dynamic> tag in file["tags"]){
        tags.add(DBX_Tag(
          tag_text: tag["tag_text"],
          ),
        );
      }
      DBX_File dbx_file = DBX_File(
        path: file["path"],
        tags: tags,
      );
      //Add the file with metadata
      filesWithMetadata.add(dbx_file);
    }
    return filesWithMetadata;
  }
  //Remove tag
  Future<String> removeTag({
    required DBX_File dbx_file,
    required String tag_text,
  })async{
    Map<String,dynamic> parameters = {
      "path" : dbx_file.path,
      "tag_text" : tag_text,
    };
    String response = await SexyAPI(
      url: "https://api.dropboxapi.com",
      path: "/2/files/tags/remove",
      parameters: {},
    ).post(
      headers: {
        "Content-Type" : "application/json",
        "Authorization" : "Bearer $accessToken",
      },
      body: jsonEncode(parameters),
    );
    if(response != "null"){
      _errorThrower(response);
    }
    return response;
  }
  //Add tags
  Future<String> addTag({
    required DBX_File dbx_file,
    required String tag_text,
  })async{
    Map<String,dynamic> parameters = {
      "path" : dbx_file.path,
      "tag_text" : tag_text,
    };
    String response = await SexyAPI(
      url: "https://api.dropboxapi.com",
      path: "/2/files/tags/add",
      parameters: {},
    ).post(
      headers: {
        "Content-Type" : "application/json",
        "Authorization" : "Bearer $accessToken",
      },
      body: jsonEncode(parameters),
    );
    if(response != "null"){
      _errorThrower(response);
    }
    return response;
  }
  Future<SearchResults> search({
    ///String(max_length=1000)The string to search for. May match across multiple fields based on the request arguments.
    required String searchQuery,
    ///String(max_length=1000)The string to search for. May match across multiple fields based on the request arguments.
    DBX_Directory? search_directory,
    int max_results = 100,
    SearchOrderBy searchOrderBy = SearchOrderBy.relevance,
    ///Boolean Restricts search to only match on filenames. The default for this field is False.
    bool filename_only = false,
    ///Restricts search to only the file categories specified. Only supported for active file search.
    List<FileCategory>? file_categories,
  })async{
    if(search_directory == null){
      search_directory = DBX_Directory(path: "/");
    }
    Map<String,dynamic> parameters = {
      /*include_highlights Boolean?Field is deprecated. Deprecated and moved this option to SearchMatchFieldOptions. This field is optional.
      "match_field_options": {
          "include_highlights": false
      },*/
      "options": {
          "file_status": "active",
          "filename_only": filename_only,
          "max_results": max_results,
          "path": search_directory.path,
          "order_by" : _enumeratedToString(searchOrderBy),
      },
      "query": searchQuery,
    };
    if(file_categories != null){
      List<String> allFileCategories = [];
      for(FileCategory fileCategory in file_categories){
        allFileCategories.add(_enumeratedToString(fileCategory));
      }
      (parameters["options"] as Map<String,dynamic>).addAll({
        "file_categories" : allFileCategories,
      });
    }
    //TODO: Perform the http request
    String response = await SexyAPI(
      url: "https://api.dropboxapi.com",
      path: "/2/files/search_v2",
      parameters: {},
    ).post(
      headers: {
        "Content-Type" : "application/json",
        "Authorization" : "Bearer $accessToken",
      },
      body: jsonEncode(parameters),
    );
    _errorThrower(response);
    Map<String,dynamic> parsedJSON = jsonDecode(response);
    List<DBX_Item> items = [];
    //Parse the items
    for(Map<String,dynamic> match in parsedJSON["matches"]){
      Map<String,dynamic> item = match["metadata"]["metadata"];
      String typeOfItem = item[".tag"];
      String itemPath = item["path_display"];
      if(typeOfItem == "file"){
        items.add(DBX_Item(
            path: itemPath,
            metadata: DBX_Item_Metadata(
              tag: typeOfItem,
              client_modified: DateTime.parse(item["client_modified"]),
              content_hash: item["content_hash"],
              id: item["id"],
              is_downloadable: item["is_downloadable"],
              name : item["name"],
              path_display: itemPath,
              path_lower: item["path_lower"],
              rev: item["rev"],
              server_modified: DateTime.parse(item["server_modified"]),
              size: item["size"],
            ),
          ),
        );
      }else{
        items.add(DBX_Directory(
            path: itemPath,
            metadata: DBX_Item_Metadata(
              tag: typeOfItem,
              client_modified: item["client_modified"],
              content_hash: item["content_hash"],
              id: item["id"],
              is_downloadable: item["is_downloadable"],
              name : item["name"],
              path_display: item["path_display"],
              path_lower: item["path_lower"],
              rev: item["rev"],
              server_modified: item["server_modified"],
              size: item["size"],
            ),
          ),
        );
      }
    }
    return SearchResults(
      has_more: parsedJSON["has_more"], 
      items: items,
      cursor: parsedJSON["cursor"],
    );
  }
  //TODO: Search continue function
}