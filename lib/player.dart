import 'package:assets_audio_player/assets_audio_player.dart';

class Player {
  
  static final _assetsAudioPlayer = AssetsAudioPlayer();
    
  static void _play(String asset)  {
    if(_assetsAudioPlayer.isPlaying.value){
      _assetsAudioPlayer.stop();
    }
    _assetsAudioPlayer.open(AssetsAudio(
        asset: "$asset",
        folder: "assets/sounds/",
    ));
    _assetsAudioPlayer.play();
  }

  static void initGame() {
    _play('init-game.mp3');
  }

  static void acceptGame() {
    _play('accept-game.mp3');
  }

  static void errorGame() {
    _play('erro-game.mp3');
  }

}
