class ImportExport {
  String exportData(List<Map<String, dynamic>> maps) {
    List<String> delims = [
      '"',
      "'",
      "|",
      ":",
      "-",
    ];

    //print(delims);
    //print("");

    for (int m = 0; m < maps.length; m++) {
      for (int delim = 0; delim < delims.length; delim++) {
        if (maps[m]["name"].toString().contains(delims[delim])) {
          if (delims.contains(delims[delim])) {
            delims.remove(delims[delim]);
            delim--;
          }
        }
        //print(delims);
      }
      //print("");
    }

    //print("");
    //print("----------");
    //print("");

    if (delims.length == 0) {
      return "false";
    } else {
      String delimiter = delims[0];
      String returnVal = 'Delimiter=${delims[0]},';
      for (Map<String, dynamic> m in maps) {
        returnVal +=
            "Item=$delimiter${m["name"]}$delimiter,IsDone=$delimiter${m["isDone"]}$delimiter,";
      }
      return returnVal;
    }
  }

/* List<Map<String, dynamic>> stringToMaps(String string) {
  bool delimiterTextExists = string.substring(0, 10) == "Delimiter=";
  String afterDelimiter = string.substring(12);
  String delimiter = string[10];
  List<String> split = afterDelimiter.split(delimiter);
  bool correctNumberOfDelims = (split.length - 1) % 4 == 0;

  List<Map<String, dynamic>> returnVal = [];

  if (delimiterTextExists && correctNumberOfDelims) {
    returnVal.add(
      {"isValid": true},
    );
    for (int i = 0; i < split.length; i++) {

    }
  } else {
    returnVal.add(
      {"isValid": false},
    );
  }
  return returnVal;
}
 */

  List<Map<String, dynamic>> importData(String string) {
    bool delimiterTextExists = string.substring(0, 10) == "Delimiter=";
    String afterDelimiter = string.substring(12);
    String delimiter = string[10];
    List<String> split = afterDelimiter.split(delimiter);
    bool correctNumberOfDelims = (split.length - 1) % 4 == 0;

    /* 

  print("");
  for (int i = 0; i < split.length; i++) {
    print(split[i]);
  }
  print(""); 

  */

    List<Map<String, dynamic>> returnVal = [];

    /* 
  
  print('delimiterTextExists? $delimiterTextExists');
  print('correctNumberOfDelims? $correctNumberOfDelims');
  
  */

    if (delimiterTextExists && correctNumberOfDelims) {
      returnVal.add(
        {"isValid": true},
      );
      for (int i = 0; i < (split.length - 1) / 4; i++) {
        int index = (4 * i) + 1;
        String name = split[index];
        bool isDone = false;
        if (split[index + 2].toLowerCase() == "true") {
          isDone = false;
        } else if (split[index + 2].toLowerCase() == "false") {
          isDone = false;
        } else {
          returnVal[0] = {"isValid": false};
        }
        returnVal.add(
          {
            "name": name,
            "isDone": isDone,
          },
        );
      }
    } else {
      returnVal.add(
        {"isValid": false},
      );
    }
    print(returnVal);
    return returnVal;
  }
}
