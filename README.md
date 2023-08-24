# layoutManager



```dart
static Future<void> initPlugin({
    bool firebaseEnabled = false,
    bool firebaseRemoteEnabled = false,
    bool parseEnabled = false,
    bool parseRemoteEnabled = false,
    bool parseFunctionEnabled = false,
    List<String>? keys,
    String? limitedKey,
    String? parseAppId,
    String? parseServerUrl,
    String? parseClientKey,
  }) 
```

Called when the application starts in the main() method.<br>
The following values are specified for Firebase Remote Config:<br>
    `.bool firebaseEnabled = true,`.<br>
    `.bool firebaseRemoteEnabled = true,`.<br>
<br>
The following values are specified for Parse Remote Config:<br>
   ` bool parseEnabled = true,`.<br>
   ` bool parseRemoteEnabled = true,`.<br>
   ` String? parseAppId = 'Some value',`.<br>
   ` String? parseServerUrl = 'Some value',`.<br>
   ` String? parseClientKey = 'Some value',`.<br>.
<br>
The following values are specified for the Parse Cloud Function:<br>
    `bool parseEnabled = true,`<br>
    `bool parseFunctionEnabled = true,`<br>
    `String? parseAppId = 'Some value',`<br>
    `String? parseServerUrl = 'Some value',`<br>
    ` String? parseClientKey = 'Some value',`.<br>.
<br>
    `List<String>? keys`,<br>
keys field all keys that are used for links.<br>
    `String? limitedKey`,<br>
The limitedKey field is the name of the key to filter out restrictions<br>
    
```dart
class LayoutProvider{
  final String uuid;
  final String? label;
  final Color backgroundColor;
  final Widget responseWidget; 
}
```

This is a wrapper widget for displaying context.<br>
  `final String uuid = key to the value in RemoteConfig;`<br>
  `final String? label = the name of the cloud function;`<br>
  `final Colour backgroundColor = colour for the transition;`<br>
  `final Widget responseWidget = the main widget to display if there is no data from the database;` <br>
