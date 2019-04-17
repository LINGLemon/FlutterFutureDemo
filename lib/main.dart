import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String showResult = '';
  String showResult1 = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('http demo'),
        ),
        body: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                fetchPost().then((CommonModel value) {
                  setState(() {
                    showResult =
                        '请求结果：\n hideAppBar: ${value.hideAppBar}\n icon: ${value.icon}\n title: ${value.title}\n url: ${value.url} statusBarColor: ${value.statusBarColor}';
                  });
                });
              },
              child: Text(
                '点击http请求数据',
                style: TextStyle(fontSize: 22),
              ),
            ),
            Text(showResult),
            Divider(),
            FutureBuilder<CommonModel>(
              future: fetchPost(),
              builder:
                  (BuildContext context, AsyncSnapshot<CommonModel> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text('ConnectionState.none');
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.active:
                    return Text('ConnectionState.active');
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text(
                        'ConnectionState.done hasError ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      );
                    } else {
                      return new Column(children: <Widget>[
                        Text('icon:${snapshot.data.icon}'),
                        Text('title:${snapshot.data.title}'),
                      ]);
                    }
                }
              },
            ),
            Divider(),
            InkWell(
              onTap: () {
                _test1();
              },
              child: Text('测试Future，结果在终端中显示'),
            ),
            InkWell(
              onTap: () {
                _test2();
              },
              child: Text('测试Future timeout，结果在终端中显示'),
            ),
            InkWell(
              onTap: () {
                _test3();
              },
              child: Text('测试Future 捕捉异常，结果在终端中显示'),
            ),
            InkWell(
              onTap: () {
                _test4();
              },
              child: Text('测试Future.whenComplete 捕捉异常，结果在终端中显示'),
            ),
          ],
        ));
  }

  // 网络请求
  Future<CommonModel> fetchPost() async {
    final response = await http
        .get('http://www.devio.org/io/flutter_app/json/test_common_model.json');
    Utf8Decoder utf8decoder = Utf8Decoder();  // fix 中文乱码
    final result = json.decode(utf8decoder.convert(response.bodyBytes));
    return CommonModel.fromJson(result);
  }

  // 4、future.whenComplete
  _test4() {
    var random = Random();
    Future.delayed(Duration(seconds: 2), () {
      if (random.nextBool()) {
        return 100;
      } else {
        throw 'boom!';
      }
    }).then(print).catchError(print).whenComplete(() {
      print('_test4 done!');
    });
  }

  // 3、捕获future的异常
  _test3() {
    _testFuture3().then((s) {
      print(s);
    }, onError: (e) {
      print('onError: ');
      print(e);
    }).catchError((e) {
      print('catchError: ');
      print(e); // onError与catchError同时存在，只会调用onError
    });
  }

  Future<String> _testFuture3() {
//    throw Error();
//    return Future.value('Success');
    return Future.error('error');
  }

  // 2、测试future timeout
  _test2() {
    Future.delayed(Duration(seconds: 3), () {
      return 1;
    }).timeout(Duration(seconds: 2)).then(print).catchError(print);
  }

  // 1、测试future
  _test1() {
    print('t1:' + DateTime.now().toString());
    _testFuture();
    print('t2:' + DateTime.now().toString());
  }

  _testFuture() async {
    int result = await Future.delayed(Duration(milliseconds: 2000), () {
      return Future.value(123);
    });
    print('t3:' + DateTime.now().toString());
  }
}

class CommonModel {
  final String icon;
  final String title;
  final String url;
  final String statusBarColor;
  final bool hideAppBar;

  CommonModel(
      {this.icon, this.title, this.url, this.statusBarColor, this.hideAppBar});

  factory CommonModel.fromJson(Map<String, dynamic> json) {
    return CommonModel(
      icon: json['icon'],
      title: json['title'],
      url: json['url'],
      statusBarColor: json['statusBarColor'],
      hideAppBar: json['hideAppBar'],
    );
  }
}
