/**
 * DEBUG flag
 *
 * Indicates debug mode
 */
boolean DEBUG = false;


/** Prints message if DEBUG mode is active */
void verbose( String str ) {
  if ( DEBUG ) println( str );
}

/** Utility class */
class Timer {
  private float startTime;
  private float totalTime;
  //private boolean isRunning = false;
  Timer() {
    startTime = 0;
    totalTime = 0;
  }
  Timer( float time ) {
    set( time );
  }

  void set( float time ) {
    startTime = millis();
    totalTime = time;
    //isRunning = true;
  }

  boolean check() {
    /*if ( millis() >= startTime + totalTime ) {
     isRunning = false;
     return false;
     } else {
     isRunning = true;
     return true;
     }*/
    return millis() < startTime + totalTime;
  }
}


/** Utility function. Parses string "<int> <int>" to PVector */
PVector parseCoors( String str ) {
  String[] coors = str.split( " " );
  if ( coors.length == 2 ) {
    return new PVector( parseFloat( coors[0]), parseFloat( coors[1] ) );
  } else if ( coors.length > 2 ) {
    return new PVector( 
      parseFloat( coors[0] ), 
      parseFloat( coors[1] ), 
      parseFloat( coors[2] )
      );
  } else return null;
}
