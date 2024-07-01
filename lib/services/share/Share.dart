import "dart:convert";
import 'dart:io';
import "package:fbla_nlc_2024/services/firebase/firestore/db.dart";
import "package:flutter/cupertino.dart";
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

Future<void> sendNotification(BuildContext context, String message) async {
  final String oneSignalAppId = "27c7ab08-f87c-4a08-81d8-fcca68c227b9";
  final String oneSignalRestApiKey = 'Yjk2NjE3OTAtZjU0OC00YjVjLTg0MTEtZDNiMjFlY2Y3MmNk';

  List<UserData> followers = await Firestore.getFollowers(context);
  List<String> followerOneSignalIds = followers.map((e) => e.onesignalId).toList();
  followerOneSignalIds.removeWhere((element) => element == "");
  print(followerOneSignalIds);

  final response = await http.post(
    Uri.parse('https://onesignal.com/api/v1/notifications'),
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Basic $oneSignalRestApiKey',
    },
    body: jsonEncode({
      'app_id': oneSignalAppId,
      'include_aliases': {"onesignal_id": [followerOneSignalIds[0]]},
      'target_channel': "push",
      // "included_segments": [
      //   "Subscribed Users"
      // ],
      'contents': {'en': message},
    }),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully!');
  } else {
    print('Failed to send notification: ${response.body}');
  }
}