import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/utils/string.dart';
import 'package:flutter_maps/view-models/homePageViewModel.dart';
import 'package:flutter_maps/views/pages/addUser.dart';
import 'package:flutter_maps/views/pages/detailUser.dart';
import 'package:flutter_maps/views/widgets/buildCachedImage.dart';
import 'package:stacked/stacked.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomePageViewModel>.reactive(
      viewModelBuilder: () => HomePageViewModel(),
      onModelReady: (model) => model.getUsers,
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Flutter Maps'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddUser())),
              )
            ],
          ),
          body: (!model.isLoadingScreen)
              ? ListView.builder(
                  itemCount: model.list.length,
                  itemBuilder: (context, index) {
                    final user = model.list[index];
                    return InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DetailUser(id: user.id, isPrefs: false))),
                      child: ListTile(
                        leading: Container(
                          height: 50,
                          width: 50,
                          child: BuildCachedImage(
                            imgUrl: StringApp().getPhoto + user.image,
                          ),
                        ),
                        title: AutoSizeText(
                          user.nama,
                          maxLines: 2,
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(Icons.date_range,
                                    color: Colors.blue, size: 18),
                                SizedBox(width: 5),
                                Text(
                                  user.tanggalLahir,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Icon(Icons.location_on,
                                    color: Colors.blue, size: 18),
                                SizedBox(width: 5),
                                Flexible(
                                  child: AutoSizeText(
                                    model.location ?? '',
                                    maxLines: 3,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        );
      },
    );
  }
}
