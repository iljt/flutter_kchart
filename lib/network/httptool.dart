import 'package:dio/dio.dart';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/services.dart';

class HttpTool {
  final Dio dio = Dio();
  static final HttpTool tool = new HttpTool();

  HttpTool(){
    dio.interceptors.add(new LogInterceptor(responseBody: true));
  }

  //先从网络加载，再从assets加载
/*  get(url,parmas,{Map<String,dynamic> header}) async{
    Options option = new Options(method: "get");
    option.responseType = ResponseType.json;
    Response response;
   try {
     response = await dio.request<String>(url,data: parmas,options: option).timeout(Duration(seconds: 2));
     print("netss url= $url parmas= $parmas" );
     if(response.data is DioError) {
       print("netss DioError" );
       return null;
     }
     print("netss="+response.data);
     return json.decode(response.data);
   } *//*on DioError*//* catch(e){
   // print("netss err url= $url parmas= $parmas e.message= ${e.message}" );
    print("netss url= $url url.toString()= ${url.toString()}   ${url.toString().contains("1min")}" );
    var result ;
      if(url.toString().contains("1min")){
        result = await rootBundle.loadString('assets/k1min.json');
      }else if(url.toString().contains("5min")){
        result = await rootBundle.loadString('assets/k5min.json');
      }else if(url.toString().contains("15min")){
        result = await rootBundle.loadString('assets/k15min.json');
      }else if(url.toString().contains("30min")){
        result = await rootBundle.loadString('assets/k30min.json');
      }else if(url.toString().contains("60min")){
        result = await rootBundle.loadString('assets/k60min.json');
      }else if(url.toString().contains("4hour")){
        result = await rootBundle.loadString('assets/k4hour.json');
      }else if(url.toString().contains("1day")){
        result = await rootBundle.loadString('assets/k1day.json');
      }else if(url.toString().contains("1week")){
        result = await rootBundle.loadString('assets/kweek.json');
      }else if(url.toString().contains("1mon")){
        result = await rootBundle.loadString('assets/kmon.json');
      }else if(url.toString().contains("1year")){
        result = await rootBundle.loadString('assets/kyear.json');
      }
     return json.decode(result);
   }
  }*/


  //从网络加载
  get(url,parmas,{Map<String,dynamic> header}) async{
      Options option = new Options(method: "get");
      option.responseType = ResponseType.json;
      Response response;
      try {
        response = await dio.request<String>(url,data: parmas,options: option).timeout(Duration(seconds: 7));
        print("netss url= $url parmas= $parmas" );
        if(response.data is DioError) {
          print("netss DioError" );
          return null;
        }
        print("netss="+response.data);
        return json.decode(response.data);
      } /*on DioError*/ catch(e){
        //loadFromAssets(url)
      }
  }

  //从assets加载
  loadFromAssets(url) async{
    print("netss url= $url url.toString()= ${url.toString()}   ${url.toString().contains("1min")}" );
    var result ;
    if(url.toString().contains("1min")){
      result = await rootBundle.loadString('assets/k1min.json');
    }else if(url.toString().contains("5min")){
      result = await rootBundle.loadString('assets/k5min.json');
    }else if(url.toString().contains("15min")){
      result = await rootBundle.loadString('assets/k15min.json');
    }else if(url.toString().contains("30min")){
      result = await rootBundle.loadString('assets/k30min.json');
    }else if(url.toString().contains("60min")){
      result = await rootBundle.loadString('assets/k60min.json');
    }else if(url.toString().contains("4hour")){
      result = await rootBundle.loadString('assets/k4hour.json');
    }else if(url.toString().contains("1day")){
      result = await rootBundle.loadString('assets/k1day.json');
    }else if(url.toString().contains("1week")){
      result = await rootBundle.loadString('assets/kweek.json');
    }else if(url.toString().contains("1mon")){
      result = await rootBundle.loadString('assets/kmon.json');
    }else if(url.toString().contains("1year")){
      result = await rootBundle.loadString('assets/kyear.json');
    }
    return json.decode(result);
  }
}