enchant();

window.onload = function() {
  var game = new Game(500, 500);
  game.fps = 30;
  game.preload('chara1.gif');

  game.onload = function() {
    var lwf = new LWFEntity('animated_building.lwf', 'data/animated_building.lwfdata/');
    lwf.addEventListener(enchant.Event.LWF_LOADED, function(e) {
      // do something for loaded lwf.
      // for example, e.lwf.attachLWF(otherLWF)
    });
    lwf.load();
    game.rootScene.addChild(lwf);

    var bear = new Sprite(32, 32);
    bear.image = game.assets['chara1.gif'];
    bear.x = 250;
    bear.y = 50;
    bear.nextFrameDistance = 3;
    bear.currentDistance = 0;
    bear.addEventListener('enterframe', function(){
      if (bear.nextFrameDistance < bear.currentDistance) {
        if (bear.frame < 2) {
          bear.frame++;
        } else {
          bear.frame = 0;
        }
        bear.currentDistance = 0;
      } else {
        bear.currentDistance++;
      }
    });
    game.rootScene.addChild(bear);
  };

  game.start();
};
