import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mt940/mt940/models/checkboxstates.dart';
import 'package:mt940/mt940/updatedscreens/DownloadPage.dart';
import 'package:mt940/mt940/widgets/SearchWidget.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool value = false;
  String query = '';
  late List<CheckBoxState> properties;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    properties = allProperties;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customize your MT940"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white70,
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildSearch(),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              children: [
                buildAllCheckDetails(checkAllProperties),
                const Divider(
                  color: Colors.white,
                ),
                // ...properties.map(buildSingleCheckbox).toList(),
              ],
            ),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              children: [
                buildGroupCheckbox1(checkallHeaders),
                const Divider(
                  color: Colors.white,
                ),
                ...properties
                    .where((element) => element.index < 6)
                    .map(buildSingleCheckbox)
                    .toList(),
              ],
            ),
            const Divider(
              color: Colors.white,
            ),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              children: [
                buildGroupCheckbox2(checkalltransactions),
                const Divider(
                  color: Colors.white,
                ),
                ...properties
                    .where((element) => element.index < 13 && element.index > 6)
                    .map(buildSingleCheckbox)
                    .toList(),
              ],
            ),
            const Divider(
              color: Colors.white,
            ),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              children: [
                buildGroupCheckbox3(checkallfooterDetails),
                const Divider(
                  color: Colors.white,
                ),
                ...properties
                    .where(
                        (element) => element.index > 13 && element.index < 20)
                    .map(buildSingleCheckbox)
                    .toList(),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async{
           
           // converter('pdf').then(((value) {
            
            //  value.isNotEmpty?toDownload():print('waiting for data');
          //  }));
           
          },
          child: const Icon(Icons.navigate_next_rounded)),
    );
  }

  Future <Map<String,dynamic>> converter(type)async{
    Map<String,dynamic> data ={};
    var url = Uri.parse("https://firebasestorage.googleapis.com/v0/b/jazia-51e09.appspot.com/o/mt940%2FSWIFTAAJgyAB8aU792.TXT?alt=media&token=d0affdd3-dd7c-4ded-ac86-573f9efd36c6");
    var dio = Dio();
    
    //print(url);
    var postData = {
    "url":url.toString(),
	"sender":"allan",
	"fields":["id","amount","currency","valueDate","description","isCredit"],
	"date":"2021-08-03",
	"format":"pdf",
	"type":"Cr",
	"openingbalance":true,
	"closingbalance":true,
	"get":"all",
	"range":{
		"start":"2021-07-03",
		"end":"2021-07-03"
}};
print(jsonEncode(postData));
  final response = await dio.post("https://645e-41-89-229-17.ngrok.io/mt940",data:jsonEncode(postData) );

        if (response.statusCode == 200) {
        setState(() {
          data =response.data;
        });
       
        if (kDebugMode) {
          print(response.data);
          
        }
       
      } else {
        setState(() {
           data = (response.data);
        });
        
       
        if (kDebugMode) {
          print((response.data));
        }
      }

    return data;
  }

  toDownload() async {
    if (kDebugMode) {
      print(allCheckedProperties);
    }
    Route route = MaterialPageRoute(builder: (context) => DownloadPage());
    Navigator.push(context, route);
  }

  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: "Property Name ",
        onChanged: searchProperty,
      );
  void searchProperty(String query) {
    final propertysearch = allProperties.where((product) {
      final tittlesearch = product.title.toLowerCase();
      final searchlower = query.trim().toLowerCase();
      return tittlesearch.contains(searchlower);
    }).toList();
    setState(() {
      this.query = query;
      properties = propertysearch;
    });
  }

  Widget buildSingleCheckbox(CheckBoxState checkbox) => CheckboxListTile(
        controlAffinity: ListTileControlAffinity.platform,
        activeColor: Colors.red,
        title: Text(checkbox.title),
        value: checkbox.value,
        onChanged: (value) => setState(() {
          checkbox.value = value!;
          checkAllProperties.value =
              properties.every((notification) => notification.value);
          allCheckedProperties.contains(checkbox.name)
              ? allCheckedProperties.remove(checkbox.name)
              : allCheckedProperties.add(checkbox.name);
          //  allCheckedProperties.add(checkbox.index);
        }),
      );
  Widget buildAllCheckDetails(CheckBoxState checkbox) => CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Colors.red,
        subtitle: const Text(
          "Selects all Properties",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        isThreeLine: true,
        title: Text(
          checkbox.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        value: checkbox.value,
        onChanged: toggleGroupAllCheckBox,
      );
  Widget buildGroupCheckbox2(CheckBoxState checkbox) => CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Colors.red,
        title: Text(
          checkbox.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        value: checkbox.value,
        onChanged: toggleGroupCheckBox2,
      );
  Widget buildGroupCheckbox1(CheckBoxState checkbox) => CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Colors.red,
        title: Text(
          checkbox.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        value: checkbox.value,
        onChanged: toggleGroupCheckBox1,
      );
  Widget buildGroupCheckbox3(CheckBoxState checkbox) => CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Colors.red,
        title: Text(
          checkbox.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        value: checkbox.value,
        onChanged: toggleGroupCheckBox3,
      );
  void toggleGroupAllCheckBox(bool? value) {
    if (value == null) {
      return;
    }
    setState(() {
      // setState(() {
      checkAllProperties.value = value;
      for (var property in properties) {
        property.value = value;
      }
      if (value == true) {
        for (var property in properties) {
          setState(() {
            allCheckedProperties.contains(property.name)
                ? null
                : allCheckedProperties.add(property.name);
          });
        }
      } else {
        setState(() {
          allCheckedProperties.clear();
        });
      }
      // });
    });
  }

  toggleGroupCheckBox1(
    bool? value,
  ) {
    if (value == null) {
      return;
    }
    setState(() {
      // setState(() {
      checkallHeaders.value = value;
      for (var property in properties.where((element) => element.index < 7)) {
        property.value = value;
      }
      if (value == true) {
        for (var property in properties.where((element) => element.index < 7)) {
          setState(() {
            allCheckedProperties.contains(property.name)
                ? null
                : allCheckedProperties.add(property.name);
          });
        }
      } else {
        setState(() {
          for (var item in properties.where((element) => element.index < 7)) {
            if (allCheckedProperties.contains(item.name)) {
              setState(() {
                allCheckedProperties.remove(item.name);
                checkAllProperties.value = value;
              });
            }
          }
        });
      }
      // });
    });
  }

  toggleGroupCheckBox2(
    bool? value,
  ) {
    if (value == null) {
      return;
    }
    setState(() {
      // setState(() {
      checkalltransactions.value = value;
      for (var property in properties
          .where((element) => element.index > 6 && element.index < 14)) {
        property.value = value;
      }
      if (value == true) {
        for (var property in properties
            .where((element) => element.index > 7 && element.index < 14)) {
          setState(() {
            allCheckedProperties.contains(property.name)
                ? null
                : allCheckedProperties.add(property.name);
          });
        }
      } else {
        setState(() {
          for (var item in properties
              .where((element) => element.index > 7 && element.index < 14)) {
            if (allCheckedProperties.contains(item.name)) {
              setState(() {
                allCheckedProperties.remove(item.name);
                checkAllProperties.value = value;
              });
            }
          }
        });
      }
      // });
    });
  }

  toggleGroupCheckBox3(
    bool? value,
  ) {
    if (value == null) {
      return;
    }
    setState(() {
      // setState(() {
      checkallfooterDetails.value = value;
      for (var property in properties.where((element) => element.index > 12)) {
        property.value = value;
      }
      if (value == true) {
        for (var property
            in properties.where((element) => element.index > 12)) {
          setState(() {
            allCheckedProperties.contains(property.name)
                ? null
                : allCheckedProperties.add(property.name);
          });
        }
      } else {
        setState(() {
          for (var item in properties.where((element) => element.index > 12)) {
            if (allCheckedProperties.contains(item.name)) {
              setState(() {
                allCheckedProperties.remove(item.name);
                checkAllProperties.value = value;
              });
            }
          }
        });
      }
      // });
    });
  }
}
