class Widget extends Object {
  String name;
  float w, h;
  color background = color( 0, 0, 0, 0 ); //transparent by default

  private ArrayList<Widget> children = new ArrayList<Widget>();
  Widget parent = null;
  Widget( String name, float x, float y, float w, float h, Scene sc ) {
    super( sc, x, y );
    this.w = w;
    this.h = h;
    this.name = name;
  }

  void addChild( Widget w ) {
    children.add( w );
    w.parent = this;
  }
  boolean removeChild( Widget w ) {
    if ( !children.contains( w ) ) return false;
    w.parent = null;
    children.remove( w );
    return true;
  }
  boolean isParentFor( Widget w ) {
    return children.contains( w );
  }

  void update() {
    for ( int i = 0; i < children.size(); i++ ) {
      children.get( i ).update();
    }
  }

  void draw() {
    translate( coor.x, coor.y );
    fill( background );
    rect( 0, 0, w, h );

    for ( int i = 0; i < children.size(); i++ ) {
      pushMatrix();
      pushStyle();
      children.get( i ).draw();
      popStyle();
      popMatrix();
    }
  }
}


class Label extends Widget {
  private color background = color( 0, 0, 200 );
  private color textColor = color( 255 );
  private boolean hasBackground = true;
  private int textSize = 20;

  Label( String name, float x, float y, float w, float h, Scene sc ) {
    super( name, x, y, w, h, sc );
  }

  void disableBackground() {
    hasBackground = false;
  }

  void setBackground( color c ) {
    hasBackground = true;
    background = c;
  }

  void setFill( color c ) {
    textColor = c;
  }

  void setTextSize( int ts ) {
    textSize = ts;
  }

  void draw() {
    if ( hasBackground ) {
      fill( background );
    } else {
      noFill();
    }
    rect( coor.x, coor.y, coor.x+w, coor.y+h );
    fill( textColor );
    textAlign( CENTER, CENTER );
    textSize( textSize );
    text( name, coor.x + w/2, coor.y + h/2 );
  }
}


interface SimpleCallback {
  void call();
}

class Button extends Widget {
  private SimpleCallback m_callback;

  Button( String name_, float x, float y, float w_, float h_, Scene sc ) {
    super( name_, x, y, w_, h_, sc );
    background = color( 255, 0, 0 );
  }

  void setCallback( SimpleCallback cb ) {
    m_callback = cb;
  }

  void update() {
    float relMouseX = mouseX, relMouseY = mouseY;
    if ( parent != null ) {
      relMouseX -= parent.coor.x;
      relMouseY -= parent.coor.y;
    }
    if ( currentMouseState == MouseState.MouseClicked ) {
      if ( relMouseX > coor.x && relMouseX < coor.x+w && relMouseY > coor.y && relMouseY < coor.y+h ) {
        m_callback.call();
      }
    }
  }

  void draw() {
    fill( background );
    rect( coor.x, coor.y, w, h );
    fill( 0 );
    textAlign( CENTER, CENTER );
    textSize( 30 );
    text( name, coor.x + w/2, coor.y + h/2 );
  }
}

class ChangeAppStateCallback implements SimpleCallback {
  AppState changeTo;
  ChangeAppStateCallback( AppState st ) {
    changeTo = st;
  }
  @Override
    void call() {
    changeState( changeTo );
  }
}

class ExitCallback implements SimpleCallback {
  @Override
    void call() {
    exit();
  }
}

class LevelSelectCallback implements SimpleCallback {
  private final AppState changeTo;
  private final int levelNum;
  //static int selectedLevel;
  LevelSelectCallback( AppState st, int lvl ) {
    changeTo = st;
    levelNum = lvl;
  }
  @Override
    void call() {
    currLevel = levelNum;
    changeState( changeTo );
  }
}

/*class SimpleSwitcherCallback implements SimpleCallback {
 //boolean switcher;
 SimpleSwitcherCallback( boolean sw ) {
 //switcher = sw;
 }
 @Override
 void call() {
 //switcher = !switcher;
 throw new 
 verbose( "Switched " + mute );
 }
 }*/


class Switcher extends Widget {
  boolean switcher = false;
  private String onName, offName;
  private String currName;
  private color onColor, offColor;
  private color currColor;
  private Button m_button;

  private SimpleCallback onSwitchCallback = null;

  Switcher( String name, float x, float y, float w, float h, Scene sc ) {
    super( name, x, y, w, h, sc );
    currName = onName = offName = name;
    currColor = onColor = offColor = color( 200, 0, 0 ); //default

    m_button = new Button( name, 0, 0, w, h, sc );
    m_button.background = onColor;
    m_button.setCallback( new SimpleCallback() {
      void call() {
        switcher = !switcher;
        onSwitchCallback.call();
      }
    } 
    );
    addChild( m_button );
  }

  Switcher setOnName( String str ) {
    onName = str;
    return this;
  }
  Switcher setOffName( String str ) {
    offName = str;
    return this;
  }

  Switcher setOnColor( color c ) {
    onColor = c;
    return this;
  }
  Switcher setOffColor( color c ) {
    offColor = c;
    return this;
  }

  Switcher setSwitch( boolean b ) {
    switcher = b;
    return this;
  }

  Switcher onSwitch( SimpleCallback cb ) {
    onSwitchCallback = cb;
    return this;
  }

  void update() {
    m_button.update();
  }

  void draw() {
    if ( switcher ) {
      currColor = onColor;
      currName = onName;
    } else {
      currColor = offColor;
      currName = offName;
    }
    m_button.background = currColor;
    m_button.name = currName;
    pushMatrix();
    translate( coor.x, coor.y );
    m_button.draw();
    popMatrix();
  }
}


class Indicator {
  float currValue; //from 0 to 1
  PVector p1, p2;
  color background = color(0), c = color(255);
  Indicator( PVector p1, PVector p2, float v ) {
    this.p1 = p1;
    this.p2 = p2;
    currValue = v;
  }

  void changeValue( float v ) {
    currValue = v;
    currValue = constrain( currValue, 0, 1 );
  }

  float getValue() {
    return currValue;
  }

  void setBackground( color bg ) {
    background = bg;
  }

  void setColor( color c ) {
    this.c = c;
  }

  void draw() {
    pushStyle();
    stroke( background );
    line( p1.x, p1.y, p2.x, p2.y );
    stroke( c );
    line( p1.x, p1.y, 
      PVector.sub( p2, p1 ).mult( currValue ).add( p1 ).x, PVector.sub( p2, p1 ).mult( currValue ).add( p1 ).y );
    popStyle();
  }
}
