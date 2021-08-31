/** Global file manager. Can load and save files. */
class Assets {
  String dataFolder;        ///< root folder of the game

  AudioRepository audio;    ///< global audio repository
  ImageRepository img;      ///< global image repository
  LevelRepository levels;   ///< global level repository
  GunRepository guns;       ///< global gun repository
  BulletRepository bullets; ///< global bullet repository

  Assets( String fold ) {
    dataFolder = fold;
    audio = new AudioRepository( this );
    img = new ImageRepository( this );
    levels = new LevelRepository( this );
    guns = new GunRepository( this );
    bullets = new BulletRepository( this );
  }
  
  /** Returns file by local (from dataFolder) name */
  File getFile( final String name ) {
    return sketchFile( dataFolder + name );
  }
  
  String getAbsolutePath() {
    return getFile("").getPath();
  }
}

/** Interface for objects` builders */
interface Builder {
  
  /** Builds an object and puts it on the scene @param sc */
  Object build( Scene sc );
  
  /** Adds line to object data */
  void addLine( String str );
}

class DummyBuilder implements Builder {
  Object build( Scene sc ) {
    return null;
  }
  void addLine( String str ) {
  }
}

/** Interface for objects` serializers */
interface Serializer {
  
  /** Serializes object */
  String[] serialize();
  
  /** Sets object to serialize */
  void setObject( Object obj );
}
