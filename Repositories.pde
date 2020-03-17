import java.lang.Thread;
import java.lang.Runnable;

/*class AudioRepository {
  private final String soundFolder = "Sounds/";
  private Assets m_assets;
  private HashMap<String, SoundFile> sounds = new HashMap<String, SoundFile>();
  //private ArrayList<AudioSource> sources = new ArrayList<AudioSource>();
  //private volatile StringList playingSounds = new StringList();
  AudioRepository( Assets ass ) {
    m_assets = ass;
  }

  void saveFile( final String name ) {
    if ( !sounds.containsKey( name ) ) {
      sounds.put( name, loadSound( m_assets.dataFolder + soundFolder + name ) );
    }
  }

  //preload from default folder
  void preload() {
    preload( m_assets.getFile( soundFolder ) );
  }

  void preload( final File f ) {
    if ( !f.exists() ) return;
    if ( f.isDirectory() ) {
      File[] list = f.listFiles();
      for ( File f_ : list ) preload( f_ );
    } else {
      saveFile( f.getPath().substring( (m_assets.getFile("").getPath() + soundFolder).length(), f.getPath().length() ) );
    }
  }

  void preload( final String[] files ) {
    for ( int i = 0; i < files.length; i++ ) {
      File f = m_assets.getFile( files[i] );
      preload( f );
    }
  }

  private SoundFile getFile( final String name ) {
    SoundFile sound = null;
    saveFile( name );
    sound = sounds.get( name );
    return sound;
  }

  //returns a sound thread
  Thread playSound( final String name ) {
    if ( mute ) return null;
    File f = m_assets.getFile( soundFolder + name );
    if ( f.isDirectory() ) {
      return playRandomSound( name );
    }

    java.lang.Runnable task = new Runnable() {
      @Override
        public void run() {
        SoundFile sound = null;
        try {
          synchronized (sounds) {
            sound = getFile( name );
          }
          if ( sound == null ) return;
          //if ( sound.isPlaying() ) return;
          sound.play();

          Thread.currentThread().sleep( (long)(sound.duration()*1000) );
        }
        catch ( InterruptedException e ) {
          sound.stop();
        }
        finally {
          //Thread.currentThread().stop();
          return;
        }
      }
    };

    Thread th = new Thread( task );
    return th;
  }

  Thread playSound( final String name, final int t ) {
    if ( mute ) return null;

    java.lang.Runnable task = new Runnable() {
      @Override
        public void run() {
        SoundFile sound = null;
        try {
          synchronized (sounds) {
            sound = getFile( name );
          }
          if ( sound == null ) return;
          //if ( sound.isPlaying() ) return;
          sound.play();

          Thread.sleep( t );
        }
        catch ( InterruptedException e ) {
        }
        finally {
          sound.stop();
          //Thread.currentThread().stop();
          return;
        }
      }
    };

    Thread th = new Thread( task );
    return th;
  }

  //plays random sound in given category (directory)
  Thread playRandomSound( final String category ) {
    if ( mute ) return null;
    File dir = m_assets.getFile( "Sounds/" + category );
    if ( dir.exists() && dir.isDirectory() ) {
      File[] files = dir.listFiles();
      StringList sounds = new StringList();

      //checking files
      for ( int i = 0; i < files.length; i++ ) {
        if ( files[i].exists() && files[i].isFile() ) {
          sounds.append( files[i].getName() );
          //if one of those sounds is playing, return
          //SoundFile s = loadSound( files[i].getPath() );
          //if ( s.isPlaying() ) return;
        }
      }

      int randomSound = (int)random( sounds.size() );
      return playSound( category + "/" + sounds.get( randomSound ) );
    } else {
      return null;
    }
  }
}*/



class ImageRepository {
  private Assets m_assets;
  private HashMap<String, PImage> images = new HashMap<String, PImage>();

  private final String imgFolder = "";

  ImageRepository( Assets ass ) {
    m_assets = ass;
  }

  void preload( final String folder ) {
  }

  void preload( File f ) {
    if ( !f.exists() ) return;
    if ( f.isDirectory() ) {
      File[] files = f.listFiles();
      for ( int i = 0; i < files.length; i++ ) {
        preload( files[i] );
      }
    } else {
      saveImg( f.getPath().substring( m_assets.getFile( imgFolder ).getPath().length(), f.getPath().length() ) );
    }
  }

  void saveImg( final String name ) {
    if ( !images.containsKey( name ) ) {
      images.put( name, loadImage( m_assets.getFile( name ).getPath() ) );
    }
  }

  PImage getImg( final String name ) {
    saveImg( name );
    PImage result = images.get( name );
    return result;
  }
}

class LevelRepository {
  private Assets m_assets;
  private HashMap<String, String[]> levelsData = new HashMap<String, String[]>();

  private final String m_folder = "Levels/";

  LevelRepository( Assets ass ) {
    m_assets = ass;
  }

  void preload() {
    saveLevel( m_folder );
  }

  private void saveLevel( File f ) {
    verbose( "Saving level: " + f.getPath().substring( m_assets.getFile( m_folder ).getPath().length(), f.getPath().length() ) );
    if ( !f.exists() ) return;
    if ( f.isFile() ) {
      String[] strings = loadStrings( f.getPath() );
      //empty file
      if ( strings.length == 0 ) return;

      //levelsData.put( strings[0], strings );
      levelsData.put( f.getPath().substring( m_assets.getFile( m_folder ).getPath().length() + 1, f.getPath().length() ), 
        strings );
    } else if ( f.isDirectory() ) {
      File[] files = f.listFiles();
      for ( int i = 0; i < files.length; i++ ) {
        saveLevel( files[i] );
      }
    }
  }

  void saveLevel( final String name ) {
    if ( levelsData.containsKey( name ) ) return;
    saveLevel( m_assets.getFile( m_folder + name ) );
  }

  String[] getLevelData( final String name ) {
    verbose( "Getting level: " + name );
    saveLevel( name );
    return levelsData.get( name );
  }

  int getLevelsCount( String levelFolderName ) {
    File folder = m_assets.getFile( levelFolderName );
    if ( folder.exists() && folder.isDirectory() ) {
      String[] files = folder.list();
      return files.length;
    }
    return 0;
  }

  boolean saveLevel( Scene sc, String fileName ) {
    return false;
  }

  /** Deserializes level from a file. */
  Scene buildLevel( final String name ) {
    verbose( "Reading file..." );
    String[] file = getLevelData( name );

    Scene result = new Scene();

    Builder currBuilder = new DummyBuilder();
    for ( int i = 1; i < file.length; i++ ) {
      verbose( "Reading line..." );
      String line = file[i];
      if ( line.isEmpty() ) continue;
      //"#" means new object
      if ( line.startsWith("#") ) {
        result.addObj( currBuilder.build( result ) );

        //one # means end of the file
        if ( line.length() == 1 ) break;

        verbose( "# - new object with name " + line.substring( 1, line.length() ) );

        currBuilder = builderSwitch( line.substring( 1, line.length() ) );
        continue;
      } else {
        currBuilder.addLine( line );
      }
    }

    return result;
  }

  /** Builds level from file in a directory. */
  Scene buildLevel( final String levelFolderName, final int numInFolder ) {
    verbose( "Loading level " + numInFolder + " from dir " + levelFolderName );
    File folder = m_assets.getFile( m_folder + levelFolderName );
    if ( folder.exists() && folder.isDirectory() ) {
      String[] files = folder.list();
      if ( files.length > numInFolder ) {
        /*if ( !levelFolderName.endsWith("/") || levelFolderName == "" ) {
         return buildLevel( levelFolderName + "/" + files[numInFolder] );
         } else {
         return buildLevel( levelFolderName + files[numInFolder] );
         }*/
        return buildLevel( levelFolderName + files[numInFolder] );
      }
    }
    return null;
  }

  /** Chooses builder by name. */
  private Builder builderSwitch( final String name ) {
    Builder result;
    switch ( name ) {
    case "Turret" :
      verbose( "Choosing turret builder" );
      result = new TurretBuilder();
      break;
    case "Wall" :
      verbose( "Choosing wall builder" );
      result = new WallBuilder();
      break;
    case "Player" :
      verbose( "Choosing player builder" );
      result = new PlayerBuilder();
      break;
    default :
      verbose( "Choosing dummy builder" );
      result = new DummyBuilder();
    }

    return result;
  }
}



class GunRepository {
  private Assets m_assets;
  private HashMap<String, JSONObject> gunTypes = new HashMap<String, JSONObject>();

  GunRepository( Assets ass ) {
    m_assets = ass;
  }

  void loadGunTypes( String fileName ) {
    verbose( "Loading gun types..." );
    JSONArray types = loadJSONArray( m_assets.dataFolder + fileName );

    for ( int i = 0; i < types.size(); i++ ) {
      JSONObject obj = types.getJSONObject(i);
      gunTypes.put( obj.getString( "name" ), obj );
    }
    verbose( "Done!" );
  }

  JSONObject getGunType( String name ) {
    JSONObject result = null;
    if ( gunTypes.containsKey( name ) ) result = gunTypes.get( name );
    return result;
  }

  void clear() {
    gunTypes.clear();
  }
}




class BulletRepository {
  private Assets m_assets;
  private HashMap<String, JSONObject> bulletTypes = new HashMap<String, JSONObject>();

  BulletRepository( Assets ass ) {
    m_assets = ass;
  }


  void loadBulletTypes( String fileName ) {
    verbose( "Loading bullet types..." );
    JSONArray types = loadJSONArray( m_assets.dataFolder + fileName );

    for ( int i = 0; i < types.size(); i++ ) {
      JSONObject obj = types.getJSONObject(i);
      bulletTypes.put( obj.getString( "name" ), obj );
    }
    verbose( "Done!" );
  }


  JSONObject getBulletType( String name ) {
    JSONObject result = null;
    if ( bulletTypes.containsKey( name ) ) result = bulletTypes.get( name );
    return result;
  }

  void clear() {
    bulletTypes.clear();
  }
}
