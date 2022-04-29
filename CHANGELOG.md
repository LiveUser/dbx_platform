# v1.1.7+9 - April 29 2022
- search continue 1.1.6+8
# v1.1.6+8 - April 29 2022
- Added functions for:
  - Creating tags
  - Removing tags
  - Retrieving tags
- Search function
# v1.1.5+7 - April 26 2022
- removed the no longer necessary deleteFile() method
# v1.1.4+6 - April 2022
- itemExists() method fixed
- errors are now thrown rather than supressed. Don't know why I ever did that
# v1.1.3+5 - April 25 2022
- createFileFromMemory() method added
# v1.1.2+4 - April 23 2022 8:31pm UTC-4
- getThumbnail() method added
# v1.1.1+3 - April 23 2022
- Download entire folder as .zip function added and tested
# v1.1.0+2 - April  23 2022
Created the following classes/types and updated all of the functions(to make the API calls look better and be statically typed)
- DBX_Item_Metadata
- DBX_Item
- DBX_Directory
- DBX_File
Created the following methods
- itemMetadata()
- list()
# v1.0.0+1 - April 22 2022
Added functions for both File and Folders
- create
- delete
- check if exists