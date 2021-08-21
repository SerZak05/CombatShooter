import java.util.Map;
import java.util.function.Predicate;

enum BehaviourType {
  Destroyable, Obstacle, Movable, Projectile, Warrior, Targetable, AudioSource
}

/** Base class for all behaviours */
class Behaviour {
  Object m_object; ///< parent object that has this behaviour
  BehaviourType type; ///< type of the behaviour

  Behaviour( BehaviourType t, Object obj ) {
    type = t;
    m_object = obj;
  }

  /**
   * Derived classes can implement
   * Called each tick
   * Default - empty
   */
  void update() {
  }
}

/**
 * Behaviour of hitable and destroyable objects
 * Can process hits by bullets 
 */
class Destroyable extends Behaviour {
  float max_health;
  float health; ///< current health
  Hitbox hitbox; ///< hitbox of the object

  Destroyable( Object obj ) {
    super( BehaviourType.Destroyable, obj );
  }

  /**
   * Checks if bullet @param b hits the hitbox
   * If it does, calls hit method
   */
  boolean onDamage( Bullet b ) {
    if ( hitbox.contains( b.coor ) ) {
      hit( b.damage );
      return true;
    }
    return false;
  }

  /**
   * A response for a hit
   * Called when hit by a bullet
   * Can be called in other situation
   */
  void hit( float damage ) {
    health -= damage;
  }
}

/** Behaviour for obstacles-walls on the map */
class Obstacle extends Behaviour {
  /**
   * A set that contains passingTypes of bullets
   * If an object`s type contains in this list, it will pass through
   */
  private ArrayList<MovableType> passingTypes = new ArrayList<MovableType>();
  Hitbox hitbox; ///< hitbox of a wall on the map

  Obstacle( Object obj ) {
    super( BehaviourType.Obstacle, obj );
  }

  /** Inserts a type @param t in a passingTypes */
  void setPass( MovableType t ) {
    if ( !passingTypes.contains( t ) ) {
      passingTypes.add(t);
    }
  }

  /** Removes a type @param t from a passingTypes */
  void unsetPass( MovableType t ) {
    if ( passingTypes.contains(t) ) {
      passingTypes.remove(t);
    }
  }

  /** Checks, if this type @param t can pass through */
  boolean canPass( MovableType t ) {
    return passingTypes.contains( t );
  }

  PVector isHit( PVector from, PVector to ) {
    return hitbox.isHit( from, to );
  }
}



enum MovableType {
  Character, Projectile
}

/** Behaviour of pointy fast movables (like bullets) */
class Movable extends Behaviour {
  MovableType type;
  boolean canBounce = true;
  //private int lastMove = -1;

  Movable( Object obj, MovableType t ) {
    super( BehaviourType.Movable, obj );
    type = t;
  }

  /**
   * Moves an object with coordinates @param coor by the vector @param vel
   * and writes the result coordinates and velosity into @param coor and @param vel.
   * Parameters shouldn`t be copied, so method could modify them.
   * 
   * The method finds all obstacles on the map and modifies coors and velosity to bounce.
   * If bounced, returns intersection coors, null otherwise.
   */
  PVector move( PVector coor, PVector vel ) {
    /*if ( lastMove == -1 ) {
     lastMove = millis();
     }*/

    //float dt = millis()-lastMove;

    //PVector move = vel.copy().mult( dt );

    //println( "Movable.move( ", coor, vel, " )" );
    ArrayList<Behaviour> obstacles = m_object.m_scene.getBehaviours( BehaviourType.Obstacle );
    for ( int i = 0; i < obstacles.size(); i++ ) {
      //Object obj = obstacles.get( i );
      Obstacle beh = (Obstacle)obstacles.get(i);
      if ( beh.canPass( type ) ) continue;

      PVector bounced = beh.isHit( coor, PVector.add( coor, vel ) );
      if ( bounced != null ) {
        //println( "Bounced!" );
        //println( "Prev velosity:", vel, "New velosity:", bounced );
        /*move.x = bounced.x;
         move.y = bounced.y;
         vel.x = bounced.x / dt;
         vel.y = bounced.y / dt;*/
        if ( canBounce ) {
          vel.x = bounced.x;
          vel.y = bounced.y;
        } else {
          vel.x = 0;
          vel.y = 0;
        }
        //vel = PVector.sub( bounced, PVector.add( coor, vel ) );
        //vel.mult( -1 );
        return bounced;
      }
    }

    /*coor.add( move );
     
     lastMove = millis();*/
    coor.add( vel );
    return null;
  }
}

/**
 * Uses algorithm for bouncing round movables.
 * Can be used for modeling relativly big and slow movables (like characters).
 */
class BigRoundMovable extends Movable { 
  BigRoundMovable( Object obj, MovableType t ) {
    super( obj, t );
    type = t;
  }

  /**
   * Moves an object with coordinates @param coor by the vector @param vel
   * and writes the result coordinates and velosity into @param coor and @param vel.
   * Parameters shouldn`t be copied, so method could modify them.
   * 
   * The method finds all obstacles on the map and modifies coors and velosity to bounce.
   *
   * This method calculates taking account of size.
   * If bounced, returns intersection coors, null otherwise.
   */
  PVector move( PVector coor, PVector vel, float r ) {
    ArrayList<Behaviour> obstacles = m_object.m_scene.getBehaviours( BehaviourType.Obstacle );

    boolean bounced = false;
    PVector d = null;
    for ( int i = 0; i < obstacles.size(); i++ ) {
      Obstacle beh = (Obstacle)obstacles.get(i);
      if ( beh.canPass( type ) ) continue;

      d = beh.hitbox.distVector( coor );
      if ( d.mag() < r ) {
        /** Big round movables bounce always. */
        //verbose( "Bounced! " + d );
        float a = PVector.angleBetween( vel, d );
        if ( vel.copy().rotate( a ).dot( d ) < vel.copy().rotate( -a ).dot( d ) ) {
          vel.rotate( PI - 2*a );
        } else {
          vel.rotate( PI + 2*a );
        }
        coor.add( d.mult( -(r-d.mag())/d.mag() ) );
        bounced = true;
      }
    }

    coor.add( vel );
    if ( bounced ) {
      vel.mult( 0.8 );
      return PVector.add( coor, d );
    }
    return null;
  }
}

/**
 * Behaviour of an object in a team.
 * Other objects in other teams will target an object with this behaviour.
 */
class Warrior extends Behaviour {
  int teamNum;
  Warrior( Object obj, int teamNum ) {
    super( BehaviourType.Warrior, obj );
    this.teamNum = teamNum;
  }

  int getTeamNum() {
    return teamNum;
  }
  void changeTeam( int teamNum ) {
    this.teamNum = teamNum;
  }
}

/**
 * Targeting and scanning module.
 * Scans the map for enemies and targets them.
 */
class Targetable extends Behaviour {
  Targetable( Object obj ) {
    super( BehaviourType.Targetable, obj );
  }

  /** Returns if this team @param teamNum has enemies (Warriors) on the map. */
  boolean hasEnemies( int teamNum ) {
    ArrayList<Behaviour> allWarriors = m_object.m_scene.getBehaviours( BehaviourType.Warrior );
    for ( Behaviour b : allWarriors ) {
      if ( ((Warrior)b).teamNum != teamNum ) return true;
    }

    return false;
  }

  /** Finds the closest warrior object hostile to teamnum */
  Object findByRange( PVector origin, int teamNum ) {
    ArrayList<Object> objects = m_object.m_scene.getObjByBehaviour( BehaviourType.Warrior );

    return findClosestFrom( origin, teamNum, objects );
  }

  Object findClosestFrom( PVector origin, int teamNum, ArrayList<Object> objects ) {
    //checking hostile warriors
    ArrayList<Warrior> hostiles = new ArrayList<Warrior>();
    for ( int i = 0; i < objects.size(); i++ ) {
      Object obj = objects.get(i);
      if ( obj.hasBehaviour( BehaviourType.Warrior ) ) {
        Warrior w = (Warrior)obj.getBehaviour( BehaviourType.Warrior );
        if ( teamNum != w.teamNum ) {
          hostiles.add( w );
        }
      }
    }

    //finding closest target
    Object closest = null;
    float dist = 10000;
    for ( int i = 0; i < hostiles.size(); i++ ) {
      Object obj = hostiles.get(i).m_object;
      if ( origin.dist( obj.coor ) < dist ) {
        closest = obj;
        dist = origin.dist( obj.coor );
      }
    }

    return closest;
  }
}

/** Behaviour of noizemaking objects */
class AudioSource extends Behaviour {
  private AudioRepository m_rep;
  private HashMap<String, Thread> m_threads = new HashMap<String, Thread>();
  AudioSource( Object obj, AudioRepository r ) {
    super( BehaviourType.AudioSource, obj );
    m_rep = r;
  }

  /** Returns false if this sound is already playing. */
  boolean playSound( final String name ) {
    if ( m_threads.containsKey( name ) ) return false;
    Thread th = m_rep.playSound( name );
    if ( th == null ) return true;
    th.start();
    m_threads.put( name, th );
    return true;
  }

  /**
   * Returns false if this sound is already playing.
   * Plays random sound from a given folder @param name.
   */
  boolean playRandomSound( final String name ) {
    if ( m_threads.containsKey( name ) ) return false;
    Thread th = m_rep.playRandomSound( name );
    if ( th == null ) return true;
    th.start();
    m_threads.put( name, th );
    return true;
  }

  /** 
   * Called each tick.
   * Checks, if threads are alive, deletes dead threads.
   */
  void update() {
    HashMap<String, Thread> updated_threads = new HashMap<String, Thread>();
    for ( HashMap.Entry<String, Thread> e : m_threads.entrySet() ) {
      Thread th = e.getValue();
      if ( !th.isAlive() ) {
        th.stop();
      } else {
        updated_threads.put( e.getKey(), th );
      }
    }
    m_threads = updated_threads;
  }
}


/*class Shootable extends Behaviour {
 Shootable( Object obj ) {
 super( BehaviourType.Shootable, obj );
 }
 }*/
