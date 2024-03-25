import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'kchart/flutter_kchart.dart';
import 'dart:convert';
import 'kchart/chart_style.dart';
import 'kline_vertical_widget.dart';
import 'kline_data_controller.dart';
import 'network/httptool.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'USDT-BTC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  List<KLineEntity> datas = [];
  bool showLoading = true;
  KLineDataController dataController = KLineDataController();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData(dataController.periodModel.period);
    rootBundle.loadString('assets/depth.json').then((result) {
      final parseJson = json.decode(result);
      Map tick = parseJson['tick'];
      var bids = tick['bids'].map((item) => DepthEntity(item[0], item[1])).toList().cast<DepthEntity>();
      var asks = tick['asks'].map((item) => DepthEntity(item[0], item[1])).toList().cast<DepthEntity>();
//      initDepth(bids, asks);
    });

    dataController.changePeriodClick = (KLinePeriodModel model){
      getData(model.period);
    };

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: ChartColors.bgColor,
      body: Stack(
        children: <Widget>[
          KLineVerticalWidget(datas: datas, dataController: dataController),
          Offstage(
            offstage: !showLoading,
            child:  Container(
                width: double.infinity,
                height: 450,
                alignment: Alignment.center,
                child: CircularProgressIndicator()
            ),
          ),
        ],
      ),
    );
  }

  Timer _timer;
  void getData(String period) async {
    //webSocket
   /* final wsUrl = Uri.parse('ws://example.com');
    final channel = WebSocketChannel.connect(wsUrl);

    await channel.ready;

    channel.stream.listen((message) {
      print("message= "+message);
      channel.sink.add('received!');
      channel.sink.close(status.goingAway);
    });*/

    setState(() {
      datas = [];
      showLoading = true;
    });
    if(_timer!=null){
      _timer.cancel();
    }
    var timeDuration=5;
    if(period == "1min"){
       timeDuration = 5;
    }else if(period == "5min"){
       timeDuration = 5*60;
    }else if(period == "15min"){
       timeDuration = 15*60;
    }else if(period == "30min"){
       timeDuration = 30*60;
    }else if(period == "60min"){
      timeDuration = 60*60;
    }else if(period == "4hour"){
      timeDuration = 4*60*60;
    }else if(period == "1day"){
      timeDuration = 24*60*60;
    }else if(period == "1week"){
      timeDuration = 7*24*60*60;
    }else if(period == "1mon"){
      timeDuration = 30*24*60*60;
    }else if(period == "1year"){
      timeDuration = 12*30*24*60*60;
    }
    var timeInterval =  Duration(seconds: timeDuration);
    _timer = Timer.periodic(timeInterval , (timer){
      // 循环一定要记得设置取消条件，手动取消
      /* if(someCondition is true){
        _timer.cancel();
      }*/
      //更新最后一条数据
      //拷贝一个对象，修改数据
      print("Timer execute");
    /*  id: K线数据的时间戳或者唯一标识符。
        open: 该时间段开盘价，即开始时的价格。
        close: 该时间段收盘价，即结束时的价格。
        low: 该时间段内的最低价。
        high: 该时间段内的最高价。
        amount: 该时间段内的成交量，即交易量。
        vol: 该时间段内的成交额，交易总额。
        count: 交易次数，即在该时间段内发生了多少笔交易。*/
       var kLineEntity = KLineEntity.fromJson(datas.last.toJson());
       kLineEntity.id = kLineEntity.id +timeDuration /*60 * 60 * 24*/;//拼接坐标x轴时间
       kLineEntity.open = kLineEntity.close;
       kLineEntity.close += (Random().nextInt(100) - 50).toDouble();
       datas.last.high = max(datas.last.high, datas.last.close);
       datas.last.low = min(datas.last.low, datas.last.close);
       kLineEntity.vol += (Random().nextInt(10000) - 2000);
       DataUtil.addLastData(datas, kLineEntity);
       setState(() {});
    });
    //先从assets加载，再从网络加载
    Map<String,dynamic> results = await  HttpTool.tool.loadFromAssets('https://api.huobi.br.com/market/history/kline?period=${period ?? '1day'}&size=300&symbol=btcusdt');
    List list = results["data"];
   // print('netss result=$list');
    datas = list
        .map((item) => KLineEntity.fromJson(item))
        .toList()
        .reversed
        .toList()
        .cast<KLineEntity>();
    DataUtil.calculate(datas);
    showLoading = false;
    setState(() {});
    Map<String,dynamic> results2 = await  HttpTool.tool.get('https://api.huobi.br.com/market/history/kline?period=${period ?? '1day'}&size=300&symbol=btcusdt', null);
    List list2 = results2["data"];
    // print('netss result=$list');
    print('netss result list2 =$list2');
    datas = list2
        .map((item) => KLineEntity.fromJson(item))
        .toList()
        .reversed
        .toList()
        .cast<KLineEntity>();
    DataUtil.calculate(datas);
    setState(() {});


//      Map parseJson = json.decode(result);
//      List list = parseJson['data'];
//      datas = list.map((item) => KLineEntity.fromJson(item)).toList().reversed.toList().cast<KLineEntity>();
//      DataUtil.calculate(datas);
//      showLoading = false;
//      setState(() {});

  }

  @override
  void dispose() {
    // 组件销毁时判断Timer是否仍然处于激活状态，是则取消
    if(_timer.isActive){
      _timer.cancel();
    }
    super.dispose();
  }
}
