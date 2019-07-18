import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game_genius/player.dart';
import 'package:random_color/random_color.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<Color> colors = RandomColor().randomColors(count: 4);
  String colorName;
  int status = 0;
  int score = 0;
  int record = 0;
  int page = 0;
  int lifes = 3;
  bool sound = true;

  String _randomColorName(){
    int rd = Random.secure().nextInt(4);      
    return getColorNameFromColor(colors[rd]).getName;
  }

  void _handlerColors(){
    setState(() {
      colors = RandomColor().randomColors(count: 4);
      colorName = _randomColorName();
      status = 0;      
    });
  }

  void _showRecord(){
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(        
        backgroundColor: Colors.grey[800],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[            
            Text('RECORDE', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.yellowAccent
            )),
            SizedBox(height: 15),
            Text('$record', style: TextStyle(
              fontSize: 34, fontWeight: FontWeight.bold, color: Colors.yellowAccent
            ))
          ],
        ),
      )
    );
  }

  void _showHelp(){
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(        
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.help, color: Colors.blue, size: 30),
            SizedBox(height: 20),
            Text('Aprenda um pouco mais sobre as cores e suas infinitas variações. O jogo, Genius Color possui uma lista com mais de 1000 cores e suas respectivas nomeações (ENG). Tente adivinhar o maximo de cores correspondente ao nome mostrado no topo. Pontue +1 caso acerte ou -1 caso contrario.. Aprenda jogando, exercite seu cerebro', textAlign: TextAlign.justify),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () => Navigator.pop(ctx),
          )
        ],
      )
    );
  }

  void _initGame(){
    if(score == 0 && sound){
      Player.initGame();
    }
    setState((){
      colorName = _randomColorName();
      page = 1;
    });
  }    

  void _resetGame(){
    setState(() {
      status = 0;
      score = 0;
      record = 0;
      page = 0;
      lifes = 3;
    });
  }

  void _tapBoxColor(Color color){
    setState(() {
      String name = getColorNameFromColor(color).getName;
      if(colorName == name){
        if(sound) Player.acceptGame();
        status = 1;
        score++;
      }else{
        if(sound) Player.errorGame();
        status = 2;
        if (score > 0) score--;
      }
    });
    Timer(Duration(seconds: 1), () => _handlerColors());
  }

  void _saveScore(){
    if(score > record){
      print('save');
      setState(() => record = score);
      SharedPreferences.getInstance().then((prefs){
        prefs.setInt('score', score);
      });
    }
  }

  void _lifeUsage(){
    if(lifes > 0){
      _handlerColors();
      setState(() => lifes--);
    }
  }

  void _launchUrl() async {
    const url = 'https://play.google.com/store/apps/details?id=br.com.game_genius';    
    if (await canLaunch(url)) {
      await launch(url);
    }else{
      print('nops');
    }
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs){
      int core = prefs.getInt('score');
      if(core != null){
        setState(() => record = core);
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: page > 0 ? Row(
          children: <Widget>[
            Expanded(
              child: Text('PONTOS: $score', textAlign: TextAlign.center, 
                style: TextStyle(fontWeight: FontWeight.bold,color: Colors.yellowAccent)
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.pause_circle_outline, color: Colors.white),
              onPressed: (){
                setState(() => page = 0);
                _saveScore();
              }
            ),
            Expanded(
              child: Text('RECORDE:  $record', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, 
                color: Colors.white
              )),
            ),            
          ],
        ): null,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[800],
        child: page > 0 ? _buildGame() : _menuGame(),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[800],
        child: Row(
          children: <Widget>[
            FlatButton.icon(
              padding: EdgeInsets.zero,
              icon: Icon(sound ? Icons.volume_up : Icons.volume_off, color: Colors.white),
              label: Text('SOM', style: TextStyle(color: Colors.white)),
              onPressed: () => setState(() => sound = !sound),
            ),
            Visibility(
              visible: page == 1,
              child: Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(lifes >= 1 ? Icons.favorite : Icons.favorite_border, color: Colors.yellow),
                    Icon(lifes >= 2 ? Icons.favorite : Icons.favorite_border, color: Colors.yellow),
                    Icon(lifes == 3 ? Icons.favorite : Icons.favorite_border, color: Colors.yellow)
                  ],
                ),
              ),
            ),
            Visibility(
              visible: page == 1,
              child: FlatButton.icon(
                icon: Icon(Icons.redo, color: Colors.white),
                label: Text('PULAR', style: TextStyle(color: Colors.white)),
                onPressed: _lifeUsage
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _boxColor(Color color, int index){
    return GestureDetector(
      onTap: () => _tapBoxColor(color),
      child: Container(
        decoration: BoxDecoration(
          color: color,                    
          borderRadius: BorderRadius.only(
            topLeft: index == 0 ? Radius.circular(50) : Radius.zero,
            topRight: index == 1 ? Radius.circular(50) : Radius.zero,
            bottomLeft: index == 2 ? Radius.circular(50) : Radius.zero,
            bottomRight: index == 3 ? Radius.circular(50) : Radius.zero
          )
        ),
        height: (MediaQuery.of(context).size.height / 5),
        width: (MediaQuery.of(context).size.width / 2) - 40,
      ),
    );
  }

  Widget _menuGame() {
    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Text('GENIUS COLOR', style: TextStyle(fontFamily: 'Hanged', fontSize: 50, color: Colors.white)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[              
                _coreButton(score == 0 ? 'JOGAR' : 'CONTINUAR',
                  icon: Icon(Icons.play_arrow, color: Colors.white, size: 40),
                  fontSize: score == 0 ? 30 : 24,
                  backgroundColor: Color(0xFF009432),
                  onTap: _initGame
                ),
                _coreButton('RECORDE',
                  icon: Icon(Icons.stars, color: Colors.white, size: 38),
                  fontSize: 28,
                  backgroundColor: Color(0xFF3c40c6),
                  onTap: _showRecord
                ),
                _coreButton('AJUDA',
                  icon: Icon(Icons.help, color: Colors.white, size: 38),
                  backgroundColor: Color(0xFFF79F1F),
                  onTap: _showHelp
                ),
                _coreButton('SAIR',
                  icon: Icon(Icons.exit_to_app, color: Colors.white, size: 38),
                  backgroundColor: Color(0xFFEA2027),
                  onTap: (){
                    _saveScore();
                    exit(0);
                  }
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton.icon(
                      icon: Icon(Icons.thumb_up, color: Colors.white),
                      label: Text('AVALIE', style: TextStyle(color: Colors.white)),
                      onPressed: _launchUrl,
                    ),
                    FlatButton.icon(
                      icon: Icon(Icons.share, color: Colors.white),
                      label: Text('COMPARTILHE', style: TextStyle(color: Colors.white), softWrap: false),
                      onPressed: () => Share.text(
                        'Genius Color', 'Teste suas habilidades com as cores!\n\nhttps://play.google.com/store/apps/details?id=br.com.game_genius', 'text/plain'
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGame() {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,                
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Text(colorName != null ? colorName.toUpperCase() : 'COLOR NAME', 
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35, color: Colors.white,
                  )),
                ),
                Text(status == 1 ? 'Acertou' : status == 2 ? 'Errado' : '?????', 
                  textAlign: TextAlign.center, 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, 
                  color: status == 1 ? Colors.greenAccent : status == 2 ? Colors.red : Colors.yellow)
                ),
              ],
            )
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(                        
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _boxColor(colors[0], 0),
                  _boxColor(colors[1], 1),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _boxColor(colors[2], 2),
                  _boxColor(colors[3], 3)
                ],
              ),               
            ],
          ),
        ),
      ],
    );
  }

  Widget _coreButton(String label, {Icon icon, Color backgroundColor, double fontSize = 26.0, Function onTap}){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: 60, right: 60, bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(10),
          color: backgroundColor
        ),
        child: ListTile(
          leading: icon,
          title: Text(label, 
            style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold),
            softWrap: false
          ),
        ),
      ),
    );
  }


}