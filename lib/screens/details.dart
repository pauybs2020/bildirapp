import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Details extends StatefulWidget {
  final String postId, title, desc, uid, imageURL, myUid;
  Details(
      {this.postId,
      this.title,
      this.desc,
      this.uid,
      this.imageURL,
      this.myUid});
  _DetailsState createState() =>
      _DetailsState(postId, title, desc, uid, imageURL, myUid);
}

class _DetailsState extends State<Details> {
  String postId, title, desc, uid, imageURL, myUid;
  _DetailsState(
      this.postId, this.title, this.desc, this.uid, this.imageURL, this.myUid);

  final commentText = TextEditingController();
  String fullname, ppURL, postUser, myppURL;

  @override
  void initState() {
    print(imageURL);

    getPostUser().then((value) {
      print("async done");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Color(0xFF646464)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.error),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Text(
                        'Bu paylaşımda uygunsuz içerik bulunduğunu düşünüyorsan'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("HEMEN BİLDİR"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          //Postu bildirme kodu
                          Firestore.instance.collection("improper").add({
                            'post': postId,
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Center(
                        child: Image.asset(
                          "assets/images/loading.gif",
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        width: MediaQuery.of(context).size.width * 1,
                        height: 220,
                        child: Image.network(
                          imageURL,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 10, 20),
                        child: CircleAvatar(
                          backgroundColor: Color(0xFFF5F5F5),
                          backgroundImage: NetworkImage(ppURL),
                          
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(5, 15, 15, 35),
                        child: Text(
                          fullname,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF646464),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                      title,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xFF646464),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 50),
                    child: Text(
                      desc,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF646464),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFF5F5F5),
                          blurRadius:
                              10.0, // has the effect of softening the shadow
                          spreadRadius:
                              1.0, // has the effect of extending the shadow
                          offset: Offset(
                            0.0, // horizontal, move right 10
                            -9.0, // vertical, move down 10
                          ),
                        )
                      ],
                    ),
                    child: Container(
                      color: Colors.white,
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.all(20),
                      height: 105,
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Yorumlar ",
                                  style: TextStyle(
                                      fontSize: 15, color: Color(0xFF595959)),
                                ),
                                StreamBuilder(
                                    stream: Firestore.instance
                                        .collection('comments')
                                        .where('postId', isEqualTo: postId)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      String docsLength = snapshot
                                          .data.documents.length
                                          .toString();
                                      return Text(
                                        docsLength,
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFFBCBCBC)),
                                      );
                                    })
                              ],
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              FutureBuilder<String>(
                                future: Firestore.instance
                                    .collection('users')
                                    .document(myUid)
                                    .get()
                                    .then((val) {
                                  return val.data['ppURL'];
                                }),
                                builder:
                                    (context, AsyncSnapshot<String> snapshot) {
                                  if (snapshot.hasData) {
                                    return Container(
                                      child: CircleAvatar(
                                        backgroundColor: Color(0xFFF5F5F5),
                                        backgroundImage: NetworkImage(
                                          snapshot.data,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      child: Center(
                                        child: Image.asset(
                                          "assets/images/loading.gif",
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(left: 15),
                                  child: TextField(
                                    controller: commentText,
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (String str) {
                                      setState(() {
                                        commentSend();
                                      });
                                    },
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText:
                                            'Herkese açık bir yorum ekle...',
                                        hintStyle: TextStyle(
                                            color: Color(0xFFC8C8C8))),
                                  ),
                                ),
                              )
                            ],
                          ),
                          divider(),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: StreamBuilder(
                        stream: Firestore.instance
                            .collection('comments')
                            .where('postId', isEqualTo: postId)
                            .orderBy('time', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) return Text('Some Error');

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: Container(
                                height: 60,
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                                child: Text(
                                  "Henüz yorum yapılmamış",
                                  style: TextStyle(
                                    color: Color(0xFFDADADA),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            final list = snapshot.data.documents;

                            return list.isEmpty
                                ? Center(
                                    child: Container(
                                      height: 30,
                                      padding: EdgeInsets.only(top: 10),
                                      child: Text(
                                        "Henüz yorum yapılmamış..",
                                        style: TextStyle(
                                          color: Color(0xFFDADADA),
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data.documents.length,
                                    itemBuilder: (context, index) {
                                      // padding: EdgeInsets.all(16.0);
                                      return ListTile(
                                        title: Container(
                                          child: Row(
                                            children: <Widget>[
                                              FutureBuilder<String>(
                                                future: Firestore.instance
                                                    .collection('users')
                                                    .document(snapshot.data
                                                            .documents[index]
                                                        ['userId'])
                                                    .get()
                                                    .then((val) {
                                                  return val.data['ppURL'];
                                                }),
                                                builder: (context,
                                                    AsyncSnapshot<String>
                                                        snapshot) {
                                                  if (snapshot.hasData) {
                                                    return CircleAvatar(
                                                        backgroundColor:
                                                            Color(0xFFF5F5F5),
                                                        backgroundImage:
                                                            NetworkImage(
                                                                snapshot.data));
                                                  } else {
                                                    return Container();
                                                  }
                                                },
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    padding: EdgeInsets.only(
                                                        left: 15),
                                                    child:
                                                        FutureBuilder<String>(
                                                      future: Firestore.instance
                                                          .collection('users')
                                                          .document(snapshot
                                                                  .data
                                                                  .documents[
                                                              index]['userId'])
                                                          .get()
                                                          .then((val) {
                                                        return val
                                                            .data['fullname'];
                                                      }),
                                                      builder: (context,
                                                          AsyncSnapshot<String>
                                                              snapshot) {
                                                        if (snapshot.hasData) {
                                                          return Text(
                                                            snapshot.data,
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Color(
                                                                    0xFFa6a6a6)),
                                                          );
                                                        } else {
                                                          return Container();
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                    alignment:
                                                        Alignment.topLeft,
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            14, 5, 10, 0),
                                                    child: Text(
                                                      snapshot.data
                                                              .documents[index]
                                                          ['comment'],
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF595959),
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                          }
                        }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget divider() {
    return Container(
      height: 1,
      color: Color(0xFFE3E3E3),
      margin: EdgeInsets.only(top: 10.0),
    );
  }

  commentSend() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final currentUid = user.uid;

    await Firestore.instance.collection("comments").add({
      'comment': commentText.text,
      'postId': postId,
      'time': Timestamp.now(),
      'userId': currentUid,
    });
    print("TEXTFIELD TEXT: ${commentText.text}");
    commentText.clear();
  }

  getPostUserID() async {
    await Firestore.instance
        .collection('posts')
        .document(postId)
        .get()
        .then((val) {
      setState(() {
        postUser = val.data['uid'];
      });
    });
  }

  getPostUser() async {
    await getPostUserID();
    await Firestore.instance
        .collection('users')
        .document(postUser)
        .get()
        .then((val) {
      setState(() {
        fullname = val.data['fullname'];
        ppURL = val.data['ppURL'];
      });
    });
    print('FULLNAME: $fullname, PPURL: $ppURL');
  }
}
