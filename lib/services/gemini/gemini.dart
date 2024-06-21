import 'package:google_generative_ai/google_generative_ai.dart';

class Gemini{
  static late ChatSession? chat;
  static String apiKey = 'AIzaSyDCN5R4bf3YLQWMYuiWXrPpaXUUn9s9w0A';

  static void init(){
    chat = GenerativeModel(model: 'gemini-pro', apiKey: apiKey).startChat();
  }

  static Future<String> getResponse(String msg) async{
    var response = await chat?.sendMessage(Content.text(msg));
    return response?.text?? "";
  }
}