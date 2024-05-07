import 'dart:convert';

import 'package:d_chart/commons/config_render.dart';
import 'package:d_chart/commons/data_model.dart';
import 'package:d_chart/ordinal/pie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = true;
  String Country = 'Pakistan';
  List Countries = [];

  Map<String, dynamic> res = {};

  @override
  void initState() {
    getData(Country);
    getCountries();
    super.initState();
  }

  void getData(country) async {
    isLoading = true;
    final String url = 'https://covid-193.p.rapidapi.com/statistics';
    final Map<String, String> headers = {
      "X-RapidAPI-Key": "f45d8848eamshad6366977ca5fe3p1c8858jsnb2a47996e921",
      "X-RapidAPI-Host": "covid-193.p.rapidapi.com"
    };

    final Map<String, String> params = {"country": country};

    Uri uri = Uri.parse(url);
    uri = uri.replace(queryParameters: params);

    try {
      final response = await http.get(uri, headers: headers);
      res = await json.decode(response.body)['response'][0];

      if (res.isNotEmpty) {
        setState(() {
          isLoading = false;
          analytics[0]['value'] = res['cases']['total'];
          analytics[1]['value'] = res['cases']['recovered'];
          analytics[2]['value'] = res['deaths']['total'];
          analytics[3]['value'] = res['cases']['total'];
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = true;
      });
    }
  }

  void getCountries() async {
    final String url = 'https://covid-193.p.rapidapi.com/statistics';
    final Map<String, String> headers = {
      "X-RapidAPI-Key": "f45d8848eamshad6366977ca5fe3p1c8858jsnb2a47996e921",
      "X-RapidAPI-Host": "covid-193.p.rapidapi.com"
    };
    Uri uri = Uri.parse(url);
    try {
      final response = await http.get(uri);
      Countries = await json.decode(response.body)['response'][0];
    } catch (e) {
      print(e);
    }
  }

  List<Map> analytics = [
    {"name": "Confirmed", "value": 0, "color": Colors.grey[500]},
    {"name": "Recovered", "value": 0, "color": Colors.lightBlue},
    {"name": "Deaths", "value": 0, "color": Colors.red},
    {"name": "Cases", "value": 0, "color": Colors.black},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Covid 78.4',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            color: Colors.black,
            onPressed: () {
              setState(() {
                getData(Country);
              });
            },
          )
        ],
      ),
      drawer: Drawer(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Expanded(
            child: ListView.builder(
              itemCount: Countries.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black12, // Choose your desired color
                        width: 1.0, // Choose your desired width
                      ),
                    ),
                  ),
                  child: Text(
                    Countries[index],
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: isLoading
          ? Container(
              child: Center(
                child: Column(
                  children: [CircularProgressIndicator()],
                ),
              ),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${res['country']} Cases",
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    res['day'],
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: AspectRatio(
                      aspectRatio: 10 / 10,
                      child: DChartPieO(
                        data: [
                          OrdinalData(
                              domain: 'Total',
                              measure: res['cases']['total'],
                              color: Colors.grey[500]),
                          OrdinalData(
                              domain: 'Recovered',
                              measure: res['cases']['recovered'],
                              color: Colors.lightBlue),
                          OrdinalData(
                              domain: 'Deaths',
                              measure: res['deaths']['total'],
                              color: Colors.red),
                          OrdinalData(
                              domain: 'Confirmed',
                              measure: res['cases']['total'],
                              color: Colors.black),
                        ],
                        configRenderPie: const ConfigRenderPie(arcWidth: 50),
                      ),
                    ),
                  ),
                  Expanded(
                      child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 15,
                        childAspectRatio: 2),
                    itemCount: analytics.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: const Color.fromARGB(255, 218, 218, 218),
                            ),
                            borderRadius: BorderRadius.circular(5)),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.analytics,
                                  size: 18,
                                  color: analytics[index]['color'],
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  analytics[index]['name'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: analytics[index]['color']),
                                ),
                              ],
                            ),
                            Text(
                              analytics[index]['value'].toString(),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      );
                    },
                  ))
                ],
              ),
            ),
    );
  }
}
