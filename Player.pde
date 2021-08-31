/** Class for all player-on-map activity */
class Player extends Object {
  float rad = 25;
  PVector currSpeed = new PVector( 0, 0 );
  //in seconds reference 
  /*float maxSpeed = 0.3;
   float acc = 0.1;
   float drag = 0.05;*/
  //in frames reference
  float maxSpeed = 7;
  float acc = 1.5;
  float drag = 0.5;

  private BigRoundMovable m_movable;
  private Destroyable m_destroyable;
  private Warrior m_warrior;
  private AudioSource m_audio;
  private Indicator m_health;

  Gun gun;
  Player( Scene sc, float x, float y ) {
    super( sc, x, y );
    m_movable = new BigRoundMovable( this, MovableType.Character );
    behaviours.add( m_movable );

    m_destroyable = new Destroyable( this );
    m_destroyable.max_health = 200;
    m_destroyable.health = 200;
    m_destroyable.hitbox = new CircleHitbox( x, y, rad );

    m_health = new Indicator( new PVector( -10, -30 ), new PVector( 10, -30 ), m_destroyable.health );
    m_health.background = color( 0, 100, 0 );
    m_health.c = color( 0, 200, 0 );
    behaviours.add( m_destroyable );

    m_warrior = new Warrior( this, 0 );
    behaviours.add( m_warrior );

    m_audio = new AudioSource( this, assets.audio );
    behaviours.add( m_audio );

    gun = new Gun( "rifle", x, y, 50, 25 );
  }

  void move() {
    if ( pressedKeys.hasValue( int('W') ) ) {
      currSpeed.y -= acc;
    } else if ( pressedKeys.hasValue( int('S') ) ) {
      currSpeed.y += acc;
    }
    if ( pressedKeys.hasValue( int('A') ) ) {
      currSpeed.x -= acc;
    } else if ( pressedKeys.hasValue( int('D') ) ) {
      currSpeed.x += acc;
    }

    if ( currSpeed.x > drag ) {
      currSpeed.x -= drag;
    } else if ( currSpeed.x < -drag ) {
      currSpeed.x += drag;
    } else {
      currSpeed.x = 0;
    }

    if ( currSpeed.y > drag ) {
      currSpeed.y -= drag;
    } else if ( currSpeed.y < -drag ) {
      currSpeed.y += drag;
    } else {
      currSpeed.y = 0;
    }

    currSpeed.x = constrain( currSpeed.x, -maxSpeed, maxSpeed );
    currSpeed.y = constrain( currSpeed.y, -maxSpeed, maxSpeed );
    //coor.add( currSpeed );
    PVector pcoor = coor.copy();
    m_movable.move( coor, currSpeed, rad );
    m_destroyable.hitbox.move( PVector.sub( coor, pcoor ) );

    m_scene.origin = PVector.sub( coor, new PVector( width/2, height/2 ) );

    if ( currSpeed.magSq() > 0 ) {
      m_audio.playRandomSoundWithDelay( "walk", (long)(1.0 / currSpeed.mag() + 1) * 500 );
    }
  }

  /** Called, when player loses. Activates lose sequence (game over). */
  void lose() {
    Widget loseDialog = new Widget( "LoseDialog", width/4, height/4, width/2, height/2, uiScene );
    Label l = new Label( "Game over", 0, 0, width/2, height/4, uiScene );
    l.setTextSize(30);
    loseDialog.addChild( l );

    Button b1 = new Button( "Back to main menu", 0, height/4, width/2, height/8, uiScene );
    b1.setCallback( new ChangeAppStateCallback( AppState.MainMenu ) );
    loseDialog.addChild( b1 );

    Button b2 = new Button( "Try again", 0, 3*height/8, width/2, height/8, uiScene );
    b2.setCallback( new ChangeAppStateCallback( AppState.Game ) );
    loseDialog.addChild( b2 );

    uiScene.addObj( loseDialog );
    m_scene.removeObj( this );

    //assets.audio.playSound( "gameover.wav" );
    m_audio.playSound( "gameover.wav" );
  }

  /** Called, when player wins. Activates win sequence (you win!). */
  void win() {
    m_audio.playSound( "win.wav" );

    Widget winDialog = new Widget( "WinDialog", width/4, height/4, width/2, height/2, uiScene );
    Label l = new Label( "You won!", 0, 0, width/2, height/4, uiScene );
    l.setTextSize( 30 );
    winDialog.addChild( l );

    Button b1 = new Button( "Back to main menu", 0, height/4, width/2, height/8, uiScene );
    b1.setCallback( new ChangeAppStateCallback( AppState.MainMenu ) );
    winDialog.addChild( b1 );

    Button b2 = new Button( "Back to level select", 0, 3*height/8, width/2, height/8, uiScene );
    b2.setCallback( new ChangeAppStateCallback( AppState.LevelSelect ) );
    winDialog.addChild( b2 );

    uiScene.addObj( winDialog );
  }

  /** Called each tick. */
  void update() {
    if ( m_destroyable.health <= 0 ) {
      lose();
      return;
    }

    Targetable t = new Targetable( this );
    if ( !t.hasEnemies( m_warrior.teamNum ) ) {
      win();
      m_scene.removeObj( this );
    }

    m_audio.update();


    move();

    gun.setCoors( coor.x, coor.y );
    gun.update();
    gun.rotateTo( new PVector( mouseX + m_scene.origin.x, mouseY + m_scene.origin.y ) );
    //gun.rotateTo( m_scene.origin );

    /** You can shoot with a mouse or with a space key. */
    if ( mousePressed || pressedKeys.hasValue( ' ' )) gun.shoot( m_scene );
  }

  void draw() {
    //fill( 50, 150, 50 );
    //ellipse( coor.x, coor.y, rad*2, rad*2 );
    PImage texture = assets.img.getImg( "person.png" );
    translate( coor.x, coor.y );
    image( texture, -texture.width/2, -texture.height/2 );
    gun.draw();
    m_health.changeValue( m_destroyable.health / m_destroyable.max_health );
    m_health.draw();
  }
}

/** Deserializer. */
class PlayerBuilder implements Builder {
  private ArrayList<String> stringBuffer = new ArrayList<String>();
  Object build( Scene sc ) {
    verbose( "Parsing player..." );
    String line = stringBuffer.get(0);
    PVector coor = parseCoors( line );
    return new Player( sc, coor.x, coor.y );
  }
  void addLine( String str ) {
    stringBuffer.add( str );
  }
}


/** Stationary turret with a revolver. */
class Turret extends Object {
  float radius;
  Gun gun;

  private Warrior m_warrior;
  private Destroyable m_dest;
  private Targetable m_targetable;
  private Indicator m_health;
  private AudioSource m_audio;

  Turret( Scene sc, float x, float y, float r, int teamNum ) {
    super( sc, x, y );
    radius = r;
    gun = new Gun( "revolver", x, y, 50, 0 );

    /*Obstacle o = new Obstacle( this );
     o.setPass( MovableType.Character );
     o.setPass( MovableType.Projectile );
     o.hitbox = new CircleHitbox( x, y, r );
     behaviours.add( o );*/

    m_dest = new Destroyable( this );
    m_dest.max_health = 2;
    m_dest.health = 2;
    m_dest.hitbox = new CircleHitbox( x, y, r );

    m_health = new Indicator( new PVector( -10, -30 ), new PVector( 10, -30 ), m_dest.health ); 
    m_health.background = color( 100, 0, 0 );
    m_health.c = color( 200, 0, 0 );
    behaviours.add( m_dest );

    m_warrior = new Warrior( this, teamNum );
    behaviours.add( m_warrior );

    m_targetable = new Targetable( this );
    behaviours.add( m_targetable );

    m_audio = new AudioSource( this, assets.audio );
  }

  void update() {
    gun.update();

    if ( m_dest.health <= 0 ) {
      m_scene.removeObj( this );
      m_audio.playRandomSound( "explosion" );
      return;
    }

    //Scanning all warriors
    ArrayList<Object> allWarriors = m_scene.getObjByBehaviour( BehaviourType.Warrior );

    //finding reachable ones (we can shoot at)
    ArrayList<Object> reachableWarriors = new ArrayList<Object>();
    for ( Object obj : allWarriors ) {

      //iterating through obstacles
      ArrayList<Behaviour> obstacles = m_scene.getBehaviours( BehaviourType.Obstacle );
      boolean canPass = true;

      for ( int i = 0; i < obstacles.size(); i++ ) {
        Obstacle beh = (Obstacle)obstacles.get(i);
        if ( beh.canPass( MovableType.Projectile ) ) continue;

        if ( beh.hitbox.hasIntersection( coor, obj.coor ) != null ) {
          canPass = false;
          break;
        }
      }

      if ( canPass ) {
        reachableWarriors.add( obj );
      }
    }
    Object closest = m_targetable.findClosestFrom( coor, m_warrior.teamNum, reachableWarriors );

    if ( closest != null ) {
      gun.rotateTo( closest.coor );
      gun.shoot( m_scene );
    }
  }

  void draw() {
    fill( 150, 150, 0 );
    ellipse( coor.x, coor.y, radius*2, radius*2 );
    translate( coor.x, coor.y );
    gun.draw();
    m_health.changeValue( m_dest.health / m_dest.max_health );
    m_health.draw();
  }
}

/** Deserializer. */
class TurretBuilder implements Builder {
  ArrayList<String> stringBuffer = new ArrayList<String>();
  Object build( Scene sc ) {
    if ( stringBuffer.size() != 3 ) return null;
    String coorsStr = stringBuffer.get(0);
    String radStr = stringBuffer.get(1);
    String teamNumStr = stringBuffer.get(2);

    PVector coor = parseCoors( coorsStr );

    float radius = parseFloat( radStr );
    int teamNum = parseInt( teamNumStr );
    Turret result = new Turret( sc, coor.x, coor.y, radius, teamNum );
    return result;
  }
  void addLine( String str ) {
    stringBuffer.add( str );
  }
}
