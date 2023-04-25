

import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tweet_planner/models/tweet.dart';
import 'package:image_picker/image_picker.dart';
import '../models/media.dart';
import '../models/poll.dart';

class Write extends StatefulWidget {
  const Write({Key? key}) : super(key: key);
  static String route ='/write';
  @override
  State<Write> createState() => _WriteState();
}

class _WriteState extends State<Write> {
  //Each tweet has a characters limit of 280.
  final int tweet_limit = 280;

  //Stores every tweet as an object of Tweet class in this list.
  //Every new tweet will add into this list (or) removes the particular tweet based on the index of Tweet object
  List<Tweet> tweetObjects = [];

  //Stores every new poll object into this class. For now it doesn't needed.
  List<Poll> pollObjects = [];

  //Stores every media object in this map, just like wids.
  Map<int, List<dynamic>> imageMap = {};

  //The very much important map it is. It stores data as { 0: [TweetBox(),PollCard()],4:[TweetBox(),PollCard()]}
  //It stores the ui part of the entire write_screen. Everything depends on this map.
  Map<int,List<dynamic>> wids  = {};

  //Initialized this icon, so, that easily change it in setState(), when ever the currentObject is changed.
  Icon addicon = Icon(Icons.add,size: 30.0);

  //This one plays a key role by providing the user accessing tweet.
  late Tweet currentObject;

  //Creating an Image File
  XFile? image;
  //Image Picker Object
  final ImagePicker picker = ImagePicker();

  //we can upload image from camera or from gallery based on parameter
  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);

    File f = File(img!.path);
    //var size = await f.readAsBytes();
    var length = f.lengthSync();
    var lengthInMb = (length/1024)/1024;
    print('Length in MB: $lengthInMb');
    if((length/1024)/1024 > 5.2){
      print('Huge file need to compress it');
      var per = ((lengthInMb - 5.2)/lengthInMb)*100;
      var quality = 100 - per;

      print('Reduce $per% i.e, ${100-per}');

      var result = await FlutterImageCompress.compressWithFile(
        f.absolute.path,
        minWidth: 2300,
        minHeight: 1500,
        quality: quality.round(),
      );
      print('File size: ${f.lengthSync()}');
      print('Compressed size: ${result?.length}');
    }
    else{
      print('Small file');
    }
    setState(() {
      image = img;

      print('Image path: ${img.path} \nImage MimeType: ${img.mimeType}  \nImage length: ${length}');
      wids[wids.keys.length +1]=[
        Container(
          decoration: BoxDecoration(
              color: Colors.orange[200],
              borderRadius: BorderRadius.circular(10.0)
          ),
          padding: EdgeInsets.all(10.0),
          margin: EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.file(
              //to show image, you type like this.
              File(image!.path),
              fit: BoxFit.cover,
              //width: MediaQuery.of(context).size.width,
              width: 50,
              height: 50,
      ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(10.0)
                ),
                height: 50.0,
                width: 50.0,
                child: Icon(Icons.add),
              )
            ],
          ),
        )];
    });
  }

  void showMediaSourceAlert(bool firstTime) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Please choose media to select'),
            content: Container(
              height: MediaQuery.of(context).size.height / 8,
              child: Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    //if user click this button, user can upload image from gallery
                    onPressed: () {
                      Navigator.pop(context);
                      //getImage(ImageSource.gallery);
                      if(firstTime){
                        addImageCard(ImageSource.gallery, currentObject);
                      }else{
                        addAnotherImage(ImageSource.gallery, currentObject);
                      }

                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 50.0,),
                        Text('From Gallery'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    //if user click this button. user can upload image from camera
                    onPressed: () {
                      Navigator.pop(context);
                      //getImage(ImageSource.camera);
                      if(firstTime){
                        addImageCard(ImageSource.camera, currentObject);
                      }else{
                        addAnotherImage(ImageSource.camera, currentObject);
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera, size: 50.0,),
                        Text('From Camera'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  //Writing a method to create images container and add a single image at tweet index.
  void addImageCard(ImageSource media, Tweet tweet)async{
    var img = await picker.pickImage(source: media);
    Media m = Media(index: tweet.index);
    File f = File(img!.path);
    var length = f.lengthSync();
    var lengthInMb = (length/1024)/1024;
    print('Length in MB: $lengthInMb');
    if(lengthInMb > 5.2){
      print('Huge file need to compress it');
      var per = ((lengthInMb - 5.2)/lengthInMb)*100;
      var quality = 100 - per;
      var result = await FlutterImageCompress.compressWithFile(
        f.absolute.path,
        minWidth: 2300,
        minHeight: 1500,
        quality: quality.round(),
      );

      m.files.add(result);
    }else{
      m.files.add(f);
    }
    setState(() {
      //Creating a new media object with tweet box index. So, that the tweet and media will be  linked with index.

      //pollObjects.add(p);//Adding to poll list.
      currentObject.media= m;//Assigning the media to currentObject media, so the media and tweet will be linked.
      currentObject.isMedia = true;//Making isMedia true. So, that a new media to the current object is not created unless it deletes the already created media.
      //imageMap[tweet.index]?.add(ImageCard(m));
      wids[tweet.index]?.add([ImageCard(m)]);//Updating the UI part with adding the media to tweet using tweet index.

    });
    print('The var type is: ${f.runtimeType}');
    print('The list of files are ${m.files}');
  }
  List<Widget> getMediaList(Media m){
    List<Widget> temp = [];
    m.files.forEach((element) {
      if(element is File){
        print('This is file type image');
        temp.add(
            Image.file(
                //to show image, you type like this.
                element,
                fit: BoxFit.cover,
                width: 50,
                height: 50,
              )
        );
      }else{
        print('This is Uint8List type image');
        ImageProvider provider = MemoryImage(Uint8List.fromList(element));
         temp.add(Image(
          image: provider ,
           fit: BoxFit.cover,
           width: 50,
           height: 50
        ));
      }
    });
    if(m.files.length<4){
      temp.add(Container(
            decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(10.0)
            ),
            height: 50.0,
            width: 50.0,
            child: GestureDetector(
                onTap: (){
                  showMediaSourceAlert(false);
                },
                child: Icon(Icons.add)),
          )
          );
    }
    return temp;
  }

  void addAnotherImage(ImageSource media, Tweet tweet)async{
    var img = await picker.pickImage(source: media);
    Media? m = tweet.media;
    File f = File(img!.path);
    var length = f.lengthSync();
    var lengthInMb = (length/1024)/1024;
    print('Length in MB: $lengthInMb');
    if(lengthInMb > 5.2){
      print('Huge file need to compress it');
      var per = ((lengthInMb - 5.2)/lengthInMb)*100;
      var quality = 100 - per;
      var result = await FlutterImageCompress.compressWithFile(
        f.absolute.path,
        minWidth: 2300,
        minHeight: 1500,
        quality: quality.round(),
      );

      m?.files.add(result);
    }else{
      m?.files.add(f);
    }
    setState(() {
      //imageMap[tweet.index]?.add(ImageCard(m));
      var index = wids[tweet.index]?.length;
      wids[tweet.index]?.removeLast();
      print('this is wids list ${wids[tweet.index]}');
      wids[tweet.index]?.add(
        ImageCard(m!)
      );//Updating the UI part with adding the media to tweet using tweet index.

    });
  }

  Container ImageCard(Media m){
    return Container(
      decoration: BoxDecoration(
          color: Colors.orange[200],
          borderRadius: BorderRadius.circular(10.0)
      ),
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: getMediaList(m),
      )
    );
  }

  @override
  void initState() {
    super.initState();
    //We are initializing the tweetObjects, wids and currentObject with initial Tweet object with index 0.
    //So, that user can see a single tweet box by default.
    Tweet tempTweetObj = Tweet(index: 0);
    tweetObjects.add(tempTweetObj);
    wids[0] = [tweetBox(tempTweetObj)];//Adding ui part to wids.
    //wids.add([tweetBox(tempTweetObj)]);
    //tweetObjects.add(tempTweetObj);
    currentObject = tempTweetObj;
  }

  //To get the list of widgets into a list from wids map.
  List<Widget> getWidgetsList(){
    //Taking a temporary list to return the data of wids Map.
    List<Widget> tweets  = [];
    //Get the each value of the wids key. a key looks like {0:[]}
    wids.forEach((key, value) {
      //Get the array elements of the value.  Value looks like either [tweetBox(),pollCard()] or [tweetBox()] or [tweetBox(), [imageCard()]] (These values are can be changed by using setState()
      value.forEach((element) {
        if(element is List){
          element.forEach((listValue) {
            tweets.add(listValue);
          });
        }else{
          tweets.add(element);//Adding to temp list one by one. Because this list will given to SingleChildScroll which takes a list of widgets
        }

      });
    });
    //We need the action buttons always at the end of the row. So, we adding action buttons after adding the tweet or poll widgets.
    tweets.add(actionRow(context));
    return tweets;
  }

  //Add a poll card
  void addPollCard(Tweet tweet){
    print('A poll is adding to Tweet ${tweet.index}');
    setState(() {
      Poll p = new Poll(index: tweet.index);//Creating a new poll object with tweet box index. So, that the tweet and poll will be  linked with index.
      pollObjects.add(p);//Adding to poll list.
      currentObject.poll= p;//Assigning the poll to currentObject poll, so the poll and tweet will be linked.
      currentObject.isPoll = true;//Making isPoll true. So, that a new poll to the current object is not created unless it deletes. the already created poll.
      wids[tweet.index]?.add(pollCard(context, p));//Updating the UI part with adding the poll to tweet using tweet index.
      //wids[index]?.add();
      //print('Poll added.\nThe Poll contains');
      // pollObjects.forEach((element) {
      //   print('${element.index}');
      // });
    });
  }

  //Adding tweet
  void addTweet(){
    setState(() {
      //print(' before widget length: ${wids.length}');
      //Creating a new tweet with new index. Index plays a key role in deleting or adding new tweets or polls
      //So, I am getting the last key value of wids and incrementing. So, the index will remain unique.
      Tweet t = new Tweet(index: wids.keys.last + 1 );
      tweetObjects.add(t);//Adding to tweetObjects
      currentObject = t;//Making the new tweetObject as the currentObject
      wids[wids.keys.last + 1] = [tweetBox(t)];//And adding the UI part to the wids.
      //wids.add([tweetBox(t)]);
      //print('after widget length: ${wids.length} \t ${wids.keys}');
    });
  }

  //Remove a PollCard
  void removePollCard(Poll p){
    //Removing mainly deals with UI part and data.
    //pop the poll from the wids list. for that we nned tweet index, which we get from poll index.
    setState(() {
      wids[p.index]?.removeLast();//A poll always the last in the wids list. So remove it.
      pollObjects.remove(p);//Removing from poll list
      tweetObjects.forEach((element) {
        if(element.poll == p){
          element.isPoll = false;//Making the isPoll false will enable user to create a poll again to the same tweet.
        }
      });
      //tweetObjects[p.index].isPoll = false;
      print('Removed Poll card: ${p.index}');
      pollObjects.forEach((element) {
        print('${element.index}');
      });
    });
  }

  //Remove the tweet
  void removeTweetBox(Tweet tweet){
    setState(() {
      //Simply remove from the map with tweet index, because tweet indexes are the keys of wids.
      wids.remove(tweet.index);
      tweetObjects.remove(tweet);//removing from tweetObjects
      pollObjects.remove(tweet.poll);//removing polls if there are any polls associated with it.
      // print('Removed Tweet ${tweet.index}');
      // print('after widget length: ${wids.length} \t ${wids.keys}');
      // print('tweetObjects length: ${tweetObjects.length}');
      // tweetObjects.forEach((element) {
      //   print('${element.index}');
      // });
      currentObject = tweetObjects.last;//Making the last tweet object as current object very important.
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write!'),
      ),
      body: SingleChildScrollView(
        child: Container(

          margin: EdgeInsets.all(20.0),
          //color: Colors.white,
          child: Column(
            children: getWidgetsList(),


          ),
        ),
      ),
    );
  }

  Row actionRow(BuildContext context) {
    return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: ()async{
                        Navigator.pushNamed(context, '/giphy');

                      },
                      child: !currentObject.isMedia && !currentObject.isPoll ? Icon(Icons.gif_box,size: 30.0,) : Icon(Icons.gif,size: 30.0,),
                    ),

                    GestureDetector(
                      onTap: (){
                        if(!currentObject.isMedia && !currentObject.isPoll){
                          showMediaSourceAlert(true);
                        }

                      },
                        child: !currentObject.isMedia && !currentObject.isPoll ? Icon(Icons.photo,size: 30.0,) : Icon(Icons.photo_size_select_actual_outlined, size: 30.0,)),
                    GestureDetector(
                        onTap: (){
                          print('${currentObject.isPoll}');
                          if(!currentObject.isPoll && !currentObject.isMedia){
                            addPollCard(currentObject);
                            print('Poll Card Added with index: ${currentObject.index}');
                          }
                          //print()

                        },
                        child: !currentObject.isPoll && !currentObject.isMedia ? Icon(Icons.poll, size: 30.0,) : Icon(Icons.poll_outlined,size: 30.0,)),
                    GestureDetector(onTap: (){
                      if(tweetObjects.last.textController.text != ''){
                        addTweet();
                        setState(() {
                          addicon = Icon(Icons.add, size: 30.0,);
                        });
                      }

                    }, child: addicon),
                    Icon(Icons.schedule_outlined,size: 30.0,),
                    GestureDetector(
                        onTap: (){
                          tweetObjects.forEach((element) {
                            print(element.getTweetData());
                            print(element.media?.uploadImages());
                          });
                        },
                        child: Icon(Icons.send_rounded,size: 30.0,))
                  ],
                );
  }

  Column pollCard(BuildContext context, Poll p) {

    return Column(
      children: [
        Container(
                    margin: EdgeInsets.fromLTRB(40.0, 10.0, 0.0, 10.0),
                    decoration: BoxDecoration(
                        color: Colors.orange[200],
                      borderRadius: BorderRadius.circular(10.0)
                    ),
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [

                        Row(
                          children: [
                            GestureDetector(
                              child: Text('Poll Duration: ${p.days} Days, ${p.hours} Hrs, ${p.minutes} Mins. ',style: TextStyle(fontSize: 16.0),),
                              onTap: () => showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title:  Text('Set Poll Duration'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,

                                    children: [
                                      Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text('Days'),
                                          Text('Hours'),
                                          Text('Minutes')
                                        ],
                                      ),
                                      Row(
                                          //mainAxisAlignment: MainAxisAlignment.start,
                                          children:[
                                            NumberPicker(
                                              itemHeight: 40.0,
                                              itemWidth: 80,
                                              haptics: true,
                                              minValue: 0,
                                              maxValue: 6,
                                              value: p.days,
                                              onChanged: (value) => setState(() => p.days = value),
                                            ),

                                            NumberPicker(
                                              itemHeight: 40.0,
                                              itemWidth: 80,
                                              haptics: true,
                                              minValue: 0,
                                              maxValue: 23,
                                              value: p.hours,
                                              onChanged: (value) => setState(() => p.hours = value),
                                            ),

                                            NumberPicker(
                                              itemHeight: 40.0,
                                              itemWidth: 80,
                                              haptics: true,
                                              minValue: 0,
                                              maxValue: 59,
                                              value: p.minutes,
                                              onChanged: (value) => setState(() => p.minutes = value),
                                            ),
                                          ]
                                      ),
                                    ],
                                  ),

                                  actions: <Widget>[
                                   TextButton(
                                      onPressed: () => Navigator.pop(context, 'OK'),
                                      child: const Text('Set'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                removePollCard(p);

                              },
                              child: Icon(Icons.close_outlined),
                            )
                          ],
                        ),
                        PollOption(hintText: 'Choice 1', controller: p.choice1,),
                        SizedBox(
                          height: 10,
                        ),
                        PollOption(hintText: 'Choice 2',controller: p.choice2,),
                        SizedBox(
                          height: 10,
                        ),
                        PollOption(hintText: 'Choice 3 (Optional)',controller: p.choice3,),
                        SizedBox(
                          height: 10,
                        ),
                        PollOption(hintText: 'Choice 4 (Optional)',controller: p.choice4,),
                      ],
                    ),
                  ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  TextField tweetBox(Tweet tweet) {
    Widget? getIcon(){
      if(tweet == tweetObjects[0]){
        return Icon(Icons.create_outlined,size: 30.0);
      }
      return GestureDetector(onTap: (){
        removeTweetBox(tweet);
      }, child: Icon(Icons.clear,size: 30.0));
    }

    Color? fillColor = Colors.orange[100];
    return TextField(
      onTap: (){
        setState(() {
          currentObject = tweet;
          // fillColor = Colors.greenAccent;
          // print('you hit me!');
        });
      },
      onChanged: (str){
        setState(() {
          if(str != ''){
            addicon = Icon(Icons.add_circle,size: 30.0);
          }else{
            addicon = Icon(Icons.add,size: 30.0);
          }

        });
      },
      controller: tweet.getTextController(),
      //enabled: false,
      decoration: InputDecoration(
        //label: Icon(Icons.whatshot_rounded),
          suffixIcon: getIcon(),
          filled: true,
          fillColor: fillColor,
          focusColor: Colors.black,
          //hoverColor: Colors.greenAccent,
          hintText: 'Write a tweet or thread!',
          hintStyle: TextStyle(color: Colors.black,fontSize: 24.0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide.none
          )
      ),
      style: TextStyle(color: Colors.black,fontSize: 24.0),
      cursorColor: Colors.black,
      cursorWidth: 3.0,
      keyboardType: TextInputType.multiline,
      minLines: 5,
      maxLines: null,
      //maxLengthEnforcement: MaxLengthEnforcement.enforced,
      maxLength: tweet_limit,
    );
  }
}



class PollOption extends StatelessWidget {
  const PollOption({
    super.key,
    required this.hintText,
    required this.controller
  });
  final String hintText;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        //focusColor: Colors.blueAccent
      ),
    );
  }
}
/*
class TweetBox extends StatefulWidget {
  const TweetBox({
    super.key,
    required this.tweet_limit,
    required this.controller
  });
  final int tweet_limit;
  final TextEditingController controller;
  //static String route ='/write';
  @override
  State<TweetBox> createState() => _TweetBox( );
}

class _TweetBox extends State<TweetBox> {


  
  @override
  Widget build(BuildContext context) {
    return tweetBox();
  }

  TextField tweetBox() {
    return TextField(
    onTap: (){
      
    },
    controller: controller,
    decoration: InputDecoration(
      suffixIcon: Icon(Icons.close),
      filled: true,
      fillColor: Colors.orangeAccent,
      focusColor: Colors.black,
      hintText: 'Write a tweet or thread!',
      hintStyle: TextStyle(color: Colors.black,fontSize: 24.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide.none
      )
    ),
    style: TextStyle(color: Colors.black,fontSize: 24.0),
    cursorColor: Colors.black,
    cursorWidth: 3.0,
    keyboardType: TextInputType.multiline,
    minLines: 5,
    maxLines: null,
    //maxLengthEnforcement: MaxLengthEnforcement.enforced,
    maxLength: tweet_limit,
  );
  }
}
*/