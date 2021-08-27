/**
 * Gun module.
 * Provides a simple interface for shooting bullets.
 * Loads itself from a file using assets.
 */
class Gun {
  String type;
  String ammoType;

  //private float shootingSpeed; //shoots per second
  private int shootingSpeed; ///< frames between shoots
  //private float reloadTime; ///< in seconds
  private int reloadTime; ///< in frames
  //private Timer shootingTimer = new Timer();
  private int currReload = 0;

  private PImage texture;

  private String[] shootSound;

  PVector coor;
  PVector bulletSpawn; ///< the end of a gun (where bullets spawn) in relative
  float rot = 0; ///< in radians

  private AudioSource m_audio = new AudioSource( null, assets.audio );
  Gun( String type, float x, float y ) {
    this.type = type;
    build();
    coor = new PVector( x, y );
    bulletSpawn = new PVector( 0, 0 );
  }

  Gun( String type, float x, float y, float offsetX, float offsetY ) {
    this.type = type;
    build();
    coor = new PVector( x, y );
    bulletSpawn = new PVector( offsetX, offsetY );
  }

  /** Builds a gun from a file */
  private void build() {
    JSONObject typeData = assets.guns.getGunType( type ); 
    ammoType = typeData.getString( "ammoType" );

    shootingSpeed = typeData.getInt( "shootingSpeed" );
    reloadTime = typeData.getInt( "reloadTime" );

    texture = assets.img.getImg( typeData.getString( "textureName" ) );

    shootSound = typeData.getJSONArray( "shootSound" ).getStringArray();
  }

  void setCoors( float x, float y ) {
    coor.x = x;
    coor.y = y;
  }

  void setBulletOffset( float offX, float offY ) {
    bulletSpawn.x = offX;
    bulletSpawn.y = offY;
  }

  void setShootingSpeed( int sp ) {
    shootingSpeed = sp;
  }

  /** Called each tick */
  void update() {
    if ( currReload > 0 ) currReload--;
    m_audio.update();
  }

  /** Returns, if the gun has shot */
  boolean shoot( Scene sc ) {
    //if ( !shootingTimer.check() ) {
    if ( currReload == 0 ) {
      /*Bullet b = new Bullet( sc, 
       coor.x + bulletSpawn.x*cos(rot) - bulletSpawn.y*sin(rot), 
       coor.y + bulletSpawn.x*sin(rot) + bulletSpawn.y*cos(rot), 50, rot, 15 );*/
      Bullet b = new Bullet( ammoType, sc, 
        coor.x + bulletSpawn.x*cos(rot) - bulletSpawn.y*sin(rot), 
        coor.y + bulletSpawn.x*sin(rot) + bulletSpawn.y*cos(rot), rot );
      sc.addObj( b );

      currReload = shootingSpeed;
      //shootingTimer.set( 1000/shootingSpeed );

      //play sound
      int randomSound = (int)random( shootSound.length );
      m_audio.playSound( shootSound[randomSound] );
      return true;
    }
    return false;
  }

  /** Rotates gun, it will face towards @param to */
  void rotateTo( PVector to ) {
    rot = atan( (to.y - coor.y) / (to.x - coor.x) );
    if ( to.x < coor.x ) {
      rot += PI;
    }
  }

  void draw() {
    pushMatrix();
    rotate( rot );
    //stroke( 200, 200, 50 );
    //line( 0, 0, 50, 0 );
    translate( bulletSpawn.x, bulletSpawn.y );
    /*if ( !shootingTimer.check() ) {
     //texture = assets.loadImg( "gun.png" );
     } else {
     //texture = assets.loadImg( "gunReloading.png" );
     }*/
    image( texture, -texture.width, -texture.height/2 );
    popMatrix();
  }
}



class Bullet extends Object {
  //float lifespan; //in seconds
  int lifespan; ///< in frames
  //private Timer lifeTimer;
  PVector velosity;
  boolean canBounce;

  float damage;

  int stacksize;

  private Movable m_movable;

  Bullet( String typeName, Scene sc, float x, float y, float angle ) {
    super( sc, x, y );
    JSONObject typeData = assets.bullets.getBulletType( typeName );
    lifespan = typeData.getInt( "lifespan" );
    damage = typeData.getFloat( "damage" );
    stacksize = typeData.getInt( "stacksize" );
    canBounce = typeData.getBoolean( "canRicochet" );

    float vel = typeData.getFloat( "speed" );
    velosity = new PVector( vel*cos(angle), vel*sin(angle) );
    m_movable = new Movable( this, MovableType.Projectile );
    m_movable.canBounce = canBounce;
    behaviours.add( m_movable );

    //lifeTimer = new Timer( lifespan );
  }
  /*Bullet( Scene sc, float x, float y, int lifespan, PVector vel ) {
   super( sc, x, y );
   this.lifespan = lifespan;
   velosity = vel;
   }*/

  void update() {
    //coor.add( velosity );
    ArrayList<Behaviour> targets = m_scene.getBehaviours( BehaviourType.Destroyable );
    for ( int i = 0; i < targets.size(); i++ ) {
      Destroyable t = (Destroyable)targets.get(i);
      if ( t.onDamage( this ) ) {
        m_scene.removeObj( this );
        return;
      }
    }

    m_movable.move( coor, velosity );
    //if ( !lifeTimer.check() ) m_scene.removeObj( this );
    if ( --lifespan <= 0 ) m_scene.removeObj( this );
  }

  void draw() {
    fill( 255 );
    ellipse( coor.x, coor.y, 5, 5 );
    if ( DEBUG ) {
      stroke( 255, 0, 0 );
      line( coor.x, coor.y, coor.x + velosity.x, coor.y + velosity.y );
    }
  }
}
