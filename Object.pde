/**
 * Base for all objects on a scene.
 * Every object contains some behaviours that it can update annd somehow link together.
 * You can search for some behaviour in a given object.
 * Also scene can search for objects with a given behaviour.
 */
class Object {
  Scene m_scene;
  //final String typeName;
  PVector coor;

  ArrayList<Behaviour> behaviours = new ArrayList<Behaviour>();
  Object( Scene sc, String name, PVector c ) {
    m_scene = sc;
    coor = c;
  }
  Object( Scene sc, float x, float y ) {
    m_scene = sc;
    //typeName = name;
    coor = new PVector( x, y );
  }

  void addBehaviour( Behaviour b ) {
    if ( !behaviours.contains(b) ) behaviours.add( b );
  }

  boolean hasBehaviour( BehaviourType t ) {
    for ( int i = 0; i < behaviours.size(); i++ ) {
      if ( behaviours.get(i).type == t ) return true;
    }
    return false;
  }

  Behaviour getBehaviour( BehaviourType t ) {
    for ( int i = 0; i < behaviours.size(); i++ ) {
      if ( behaviours.get(i).type == t ) return behaviours.get(i);
    }
    return null;
  }

  void update() {
    verbose( "object is updating" );
  }

  void draw() {
    verbose( "object is drawing" );
  }
}
