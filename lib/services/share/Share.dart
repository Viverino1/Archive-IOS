import 'dart:io';
import "package:flutter_cache_manager/flutter_cache_manager.dart";
import "package:http/http.dart" as http;
import "package:instagram_share/instagram_share.dart";
import "package:path_provider/path_provider.dart";
import "package:social_share/social_share.dart";

import "../../classes.dart";

class InstaShare{
  static void share(PostData post) async{
    var file = await DefaultCacheManager().getSingleFile(post.pics[0]);

    print(file.exists());

    SocialShare.shareInstagramStory(appId: "1575051319739539", backgroundBottomColor: "#15616D", backgroundTopColor: "#15616D", imagePath: file.path);
  }
}