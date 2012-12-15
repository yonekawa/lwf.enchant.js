enchant();

window.onload = function() {
  var game = new Game(420, 420);
  game.fps = 30;
  game.onload = function() {
    var lwf = new LWFEntity('animated_building.lwf', 'data/animated_building.lwfdata/');
    lwf.load();
    game.rootScene.addChild(lwf);
  };
  game.start();
};
