class Scene {
  public String name = "default";
  PVector origin = new PVector( 0, 0 );

  private ArrayList<Object> objects = new ArrayList<Object>();
  private ArrayList<Object> toDelete = new ArrayList<Object>();
  private ArrayList<Object> toAdd = new ArrayList<Object>();

  void addObj( Object obj ) {
    if ( obj == null ) return;
    obj.m_scene = this;
    toAdd.add( obj );
  }
  void removeObj( Object obj ) {
    if ( obj == null ) return;
    toDelete.add( obj );
  }

  ArrayList<Object> getObjByBehaviour( BehaviourType t ) {
    ArrayList<Object> result = new ArrayList<Object>();
    for ( int i = 0; i < objects.size(); i++ ) {
      if ( objects.get(i).hasBehaviour( t ) ) result.add( objects.get(i) );
    }
    return result;
  }

  ArrayList<Behaviour> getBehaviours( BehaviourType t ) {
    ArrayList<Behaviour> result = new ArrayList<Behaviour>();
    for ( int i = 0; i < objects.size(); i++ ) {
      Behaviour b = objects.get(i).getBehaviour( t );
      if ( b != null ) result.add( b );
    }
    return result;
  }

  void update() {
    for ( Object obj : objects ) {
      obj.update();
    }
    for ( Object toDel : toDelete ) {
      objects.remove( toDel );
    }
    toDelete.clear();
    for ( Object newObj : toAdd ) {
      objects.add( newObj );
    }
    toAdd.clear();
  }

  void draw() {
    for ( Object obj : objects ) {
      pushMatrix();
      pushStyle();
      obj.draw();
      popStyle();
      popMatrix();
    }
  }
}
