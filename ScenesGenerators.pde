Scene getMainMenuUIScene() {
  Scene result = new Scene();
  {
    Label l = new Label( "Super SERIOUS 1", width/4, 0, width/2, 200, result );
    l.disableBackground();
    l.setFill( color( 200, 200, 0 ) );
    l.setTextSize(50);
    result.addObj( l );
  }
  {
    Button b = new Button( "Play", width/4, 200, width/2, 100, result );
    b.setCallback( new ChangeAppStateCallback( AppState.LevelSelect ) );
    result.addObj( b );
  }
  {
    Button b = new Button( "Settings", width/4, 300, width/2, 100, result );
    b.setCallback( new ChangeAppStateCallback( AppState.Settings ) );
    result.addObj( b );
  }
  {
    Button b = new Button( "About us", width/4, 400, width/2, 100, result );
    b.setCallback( new ChangeAppStateCallback( AppState.About_us ) );
    result.addObj( b );
  }
  {
    Button b = new Button( "Exit", width/4, 500, width/2, 100, result );
    b.setCallback( new ExitCallback() );
    result.addObj( b );
  }
  return result;
}

Scene getLevelSelectUIScene() {
  Scene result = new Scene();
  {
    Button b = new Button( "Back", 50, 50, 200, 100, result );
    b.setCallback( new ChangeAppStateCallback( AppState.MainMenu ) );
    result.addObj( b );
  }
  //adding buttons for levels
  { 
    float horIndent = 100; //between buttons
    float vertIndent = 100;
    float upperOffset = 200;
    float leftOffset = 50; //between panel and edge of the screen
    float rightOffset = 50;
    int buttonsInRow = 3;

    float buttonWidth = (width - leftOffset - rightOffset - (buttonsInRow-1)*horIndent) / buttonsInRow;
    float buttonHeight = 200;

    int levelsCount = assets.levels.getLevelsCount( "Levels" );

    Widget levelSelectButtons =
      new Widget( "levelSelectButtons", leftOffset, upperOffset, 
      width - rightOffset - leftOffset, (buttonHeight+vertIndent)*ceil(levelsCount/3), result );
    for ( int i = 0; i < levelsCount; i++ ) {
      int rowCount = ceil( levelsCount/3 );
      int inRowCount = i % buttonsInRow;

      Button b = new Button( "Level " + (i+1), 
        (buttonWidth + horIndent)*inRowCount, (buttonHeight + vertIndent)*rowCount, 
        buttonWidth, buttonHeight, result );
      b.setCallback( new LevelSelectCallback( AppState.Game, i ) );
      levelSelectButtons.addChild( b );
    }

    result.addObj( levelSelectButtons );
  }

  return result;
}


Scene getSettingsUIScene() {
  Scene result = new Scene();
  {
    Button b = new Button( "Back", 50, 40, 200, 100, result );
    b.setCallback( new ChangeAppStateCallback( AppState.MainMenu ) );
    result.addObj( b );
  }
  {
    Switcher s = new Switcher( "Volume on/off", width/4, 200, width/2, 100, result );
    s.setSwitch( mute )
      .setOnName( "Volume OFF" )
      .setOffName( "Volume ON" )
      .setOnColor( color( 0, 0, 255 ) )
      .setOffColor( color( 255, 0, 0 ) )
      .onSwitch( new SimpleCallback() {
      public void call() {
        mute = !mute;
      }
    } 
    );
    result.addObj( s );
  }
  {
    Switcher s = new Switcher( "Debug on/off", width/4, 300, width/2, 100, result );
    s.setSwitch( mute )
      .setOnName( "Debug ON" )
      .setOffName( "Debug OFF" )
      .setOnColor( color( 255, 0, 0 ) )
      .setOffColor( color( 100, 100, 100 ) )
      .onSwitch( new SimpleCallback() {
      public void call() {
        DEBUG = !DEBUG;
      }
    } 
    );
    result.addObj( s );
  }

  return result;
}


Scene getAboutUsUIScene() {
  Scene result = new Scene();
  {
    Button b = new Button( "Back", 50, 40, 200, 100, result );
    b.setCallback( new ChangeAppStateCallback( AppState.MainMenu ) );
    result.addObj( b );
  }

  return result;
}


Scene getGameUIScene() {
  Scene result = new Scene();
  {
    Button b = new Button( "Back to main menu", 50, 40, 280, 100, result );
    b.setCallback( new ChangeAppStateCallback( AppState.MainMenu ) );
    result.addObj( b );
  }
  {
    Button b = new Button( "Back to level select", 340, 40, 280, 100, result );
    b.setCallback( new ChangeAppStateCallback( AppState.LevelSelect ) );
    result.addObj( b );
  }

  return result;
}

Scene getGameGameScene() {
  Scene result = new Scene();
  /*{
   Player p = new Player( result, 200, 200 );
   result.addObj(p);
   }
   {
   Turret t = new Turret( result, width/2, height/2, 25, 1 );
   result.addObj(t);
   }
   {
   PShape wallShape = createShape();
   wallShape.beginShape();
   wallShape.vertex( 0, 0 );
   wallShape.vertex( width, 0 );
   wallShape.vertex( width, height );
   wallShape.vertex( 0, height );
   
   wallShape.beginContour();
   wallShape.vertex( 0, 0 );
   wallShape.vertex( 50, 300 );
   wallShape.vertex( 150, 500 );
   wallShape.vertex( 140, 700 );
   wallShape.vertex( 400, 600 );
   wallShape.vertex( 700, 650 );
   wallShape.vertex( width, height );
   wallShape.vertex( 1200, 400 );
   wallShape.vertex( 1100, 200 );
   wallShape.vertex( 1050, 50 );
   wallShape.vertex( 800, 120 );
   wallShape.vertex( 500, 50 );
   wallShape.endContour();
   
   wallShape.endShape();
  /*
   PShape s = createShape();
   s.beginShape();
   // Exterior part of shape
   s.vertex(-50, -50);
   s.vertex(50, -50);
   s.vertex(50, 50);
   s.vertex(-50, 50);
   
   // Interior part of shape
   s.beginContour();
   s.vertex(-20, -20);
   s.vertex(-20, 20);
   s.vertex(20, 20);
   s.vertex(20, -20);
   s.endContour();
   
   // Finish off shape
   s.endShape();
   ShapeHitbox wallHitbox = new ShapeHitbox( wallShape, 0, 0 ); 
   Wall w = new Wall( result, wallHitbox );
   result.addObj(w);
   }*/
  verbose( "Starting loading level..." );
  assets.guns.loadGunTypes( "guntypes.txt" );
  assets.bullets.loadBulletTypes( "bullettypes.txt" );
  if ( currLevel != -1 ) {
    result = assets.levels.buildLevel( "", currLevel );
  } else {
    result = new Scene();
  }
  verbose( "Done loading levels!" );
  return result;
}
