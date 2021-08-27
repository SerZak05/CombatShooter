/**
 * Game "CombatShooter"
 *
 * Simple 2D shooter game
 */

import processing.sound.*;
Sound s;

boolean mute = false;
float volume = 1;

Assets assets = new Assets( "data/" );

enum AppState {
  MainMenu, Game, Settings, LevelSelect, About_us
}
AppState currentState = AppState.MainMenu;

void changeState( AppState st ) {
  uiScene = createUIScene( st );
  gameScene = createGameScene( st );
  currentState = st;
}

int currLevel = -1; //-1 for no level

Scene uiScene = new Scene();
Scene gameScene = new Scene();

color backGround = color( 0, 0, 0 );

void setup() {
  fullScreen();
  changeState( AppState.MainMenu );
  //LevelSelectCallback.selectedLevel = 0;

  assets.audio.preload();
}

void draw() {
  //if ( mute ) {
  //  s.volume( 0 );
  //} else {
  //  s.volume( volume );
  //}
  background( backGround );

  uiScene.update();
  gameScene.update();
  pushMatrix();
  translate( -gameScene.origin.x, -gameScene.origin.y );
  gameScene.draw();
  popMatrix();
  uiScene.draw();

  currentMouseState = MouseState.None;
}

Scene createUIScene( AppState st ) {
  Scene result = new Scene();
  switch ( st ) {
  case MainMenu :
    result = getMainMenuUIScene();
    break;
  case Game :
    result = getGameUIScene();
    break;
  case LevelSelect :
    result = getLevelSelectUIScene();
    break;
  case Settings :
    result = getSettingsUIScene();
    break;
  case About_us :
    result = getAboutUsUIScene();
    break;
  default :
    break;
  }
  return result;
}

Scene createGameScene( AppState st ) {
  Scene result = new Scene();
  switch ( st ) {
  case Game :
    result = getGameGameScene();
    break;
  default :
    break;
  }
  return result;
}

/** 
 * Utility function. Loads sound file.
 * Sound file cannot be loaded locally (PApplet is needed). 
 */
SoundFile loadSound( String path ) {
  return new SoundFile( this, path );
}
