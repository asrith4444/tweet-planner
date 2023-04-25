import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';

class Media{
  Media({required this.index});
  int index;
  List<dynamic> files = [];
  List<int> uploadMedia(){
    List<int> temp = [];
    //TODO Upload Media files into cloud from here!
    return temp;
  }
  List<File> convertUint8ListToFile(){
    List<File> tempFiles = [];
    files.forEach((element) {
      if(element is File){
        print('It is file!');
        tempFiles.add(element);
      }
      else{
        //File f  = File.fromRawPath(element);
        File f = File('user_${DateTime.now().microsecondsSinceEpoch}.jpg').writeAsBytes(element) as File;
        tempFiles.add(f);
      }
    });
    return tempFiles;
  }
  Future<void> uploadImages() async {
    List<File> media = convertUint8ListToFile();
    media.forEach((element)async {
      print(element.path);
      final String path = await Supabase.instance.client.storage.from('media').upload(
        'public/user_${DateTime.now().microsecondsSinceEpoch}',
        //element.path,
        element,);
      //   fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      // );
      print(path);
    });

    // final avatarFile = File('path/to/file');
    // final String path = await supabase.storage.from('avatars').upload(
    //   'public/avatar1.png',
    //   avatarFile,
    //   fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    // );
  }
}
/*


 */