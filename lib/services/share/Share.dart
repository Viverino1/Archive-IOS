import 'dart:io';
import "package:http/http.dart" as http;
import "package:instagram_share/instagram_share.dart";
import "package:path_provider/path_provider.dart";
import "package:social_share/social_share.dart";

import "../../classes.dart";

class Share{
  static void share(PostData post) async{
    final url = Uri.parse(post.pics[0]);
    final response = await http.get(url);
    final temp = await getTemporaryDirectory();
    final File myFile = await File('${temp.path}/myItem.png').writeAsBytes(response.bodyBytes);
    print(await myFile.exists());
    SocialShare.shareInstagramStory(appId: "1575051319739539", backgroundBottomColor: "#15616D", backgroundTopColor: "#15616D", imagePath: myFile.path);
  }
}