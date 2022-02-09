import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Temp extends StatefulWidget {
  const Temp({Key key}) : super(key: key);

  @override
  _TempState createState() => _TempState();
}

class _TempState extends State<Temp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ListView"),
        brightness: Brightness.dark,
      ),
      body: Container(
              child: WebView(
                initialUrl: Uri.dataFromString('<html><body><iframe src="https://open.spotify.com/embed/album/3aeT26ypiF8fCWImdu0cGs" width="300" height="180" frameborder="0" allowtransparency="true" allow="encrypted-media"></iframe></body></html>', mimeType: 'text/html').toString(),
                javascriptMode: JavascriptMode.unrestricted,
              )),
    );
  }


  Widget _getChild(BuildContext context, int index) {
    return Container(
      key: ObjectKey('$index'),
      color: Colors.yellow,
      child: Center(
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text('$index'),
        ),
      ),
    );
  }
}

class HeaderWidget extends StatelessWidget {
  final String text;

  HeaderWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Text(text),
      color: Colors.grey[200],
    );
  }
}

class BodyWidget extends StatelessWidget {
  final Color color;

  BodyWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 2,
            color: buttonPrimary,
          )),
      margin: EdgeInsets.only(
        top: 10,
      ),
      child: CommonNetworkImage(
        height: 70,
        width: 70,
        radius: 35,
        imageUrl: "",
      ),
    );
  }
}

List<StaggeredTile> _staggeredTiles = <StaggeredTile>[
  StaggeredTile.count(2, 2),
  StaggeredTile.count(2, 1),
  StaggeredTile.count(1, 2),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(2, 2),
  StaggeredTile.count(1, 2),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(3, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(4, 1),
  StaggeredTile.count(2, 2),
  StaggeredTile.count(2, 1),
  StaggeredTile.count(1, 2),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(2, 2),
  StaggeredTile.count(1, 2),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(3, 1),
  StaggeredTile.count(1, 1),
  StaggeredTile.count(4, 1),
];

List<Widget> _tiles = <Widget>[
  _Example01Tile(Colors.green, Icons.widgets),
  _Example01Tile(Colors.lightBlue, Icons.wifi),
  _Example01Tile(Colors.amber, Icons.panorama_wide_angle),
  _Example01Tile(Colors.brown, Icons.map),
  _Example01Tile(Colors.deepOrange, Icons.send),
  _Example01Tile(Colors.indigo, Icons.airline_seat_flat),
  _Example01Tile(Colors.red, Icons.bluetooth),
  _Example01Tile(Colors.pink, Icons.battery_alert),
  _Example01Tile(Colors.purple, Icons.desktop_windows),
  _Example01Tile(Colors.blue, Icons.radio),
  _Example01Tile(Colors.green, Icons.widgets),
  _Example01Tile(Colors.lightBlue, Icons.wifi),
  _Example01Tile(Colors.amber, Icons.panorama_wide_angle),
  _Example01Tile(Colors.brown, Icons.map),
  _Example01Tile(Colors.deepOrange, Icons.send),
  _Example01Tile(Colors.indigo, Icons.airline_seat_flat),
  _Example01Tile(Colors.red, Icons.bluetooth),
  _Example01Tile(Colors.pink, Icons.battery_alert),
  _Example01Tile(Colors.purple, Icons.desktop_windows),
  _Example01Tile(Colors.blue, Icons.radio),
];

class _Example01Tile extends StatelessWidget {
  const _Example01Tile(this.backgroundColor, this.iconData);

  final Color backgroundColor;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: InkWell(
        onTap: () {},
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              iconData,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
