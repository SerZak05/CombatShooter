/** Utility class for lines */
class Line {
  //ax + by = c
  float a, b, c;
  PVector norm;
  Line( final float a, final float b, final float c ) {
    this.a = a;
    this.b = b;
    this.c = c;
    norm = new PVector( a, b );
  }
  Line( final PVector p1, final PVector p2 ) {
    a = p2.y - p1.y;
    b = p1.x - p2.x;
    c = p1.x*p2.y - p2.x*p1.y;
    norm = new PVector( a, b );
  }

  /** Checks, if this line has a point with some precision */
  boolean hasPoint( final PVector p ) {
    return abs(a*p.x + b*p.y - c) < 0.01d;
  }

  PVector intersection( final Line l ) {
    if ( l.a == a && l.b == b ) {
      //paralell
      return null;
    }
    PVector inters = new PVector( (c*l.b - l.c*b) / (a*l.b-l.a*b), (l.a*c-a*l.c) / (b*l.a-l.b*a) );    
    return inters;
  }

  /** Returns vector from -> line. */
  PVector perpend( final PVector from ) {
    return PVector.mult( norm, -(a*from.x + b*from.y - c) / (a*a + b*b));
  }

  float dist( final PVector p ) {
    return perpend( p ).mag();
  }

  String toString() {
    return "Line: " + a + "x + " + b + "y = " + c;
  }
}

/** "Отрезок" */
class Section extends Line {
  PVector begin, end;
  Section( final PVector p1, final PVector p2 ) {
    super( p1, p2 );
    begin = p1;
    end = p2;
  }

  /** Checks if this section has a point with some precision. */
  boolean hasPoint( final PVector p ) {
    //if ( !super.hasPoint( p ) ) return false;
    if ( end.x == begin.x ) {
      return abs(p.x - begin.x) < 0.01 && ( ( p.y < begin.y && p.y > end.y ) || ( p.y > begin.y && p.y < end.y ) );
    }
    if ( end.y == begin.y ) {
      return abs(p.y - begin.y) < 0.01 && ( ( p.x < begin.x && p.x > end.x ) || ( p.x > begin.x && p.x < end.x ) );
    }
    float dx = (p.x-begin.x)/(end.x-begin.x);
    float dy = (p.y-begin.y)/(end.y-begin.y);
    return abs( dx - dy ) < 0.01 && dx > 0 && dx < 1;
    /*float t = PVector.sub( p, begin ).mag() / PVector.sub( end, begin ).mag();
     return t > 0 && t < 1;*/
  }

  String toString() {
    return "Section: " + begin + end;
  }
}

/** An interface for all hitboxes. */
interface Hitbox {
  /**
   * Checks, if the point p is inside.
   * Not implemented yet for polygons.
   */
  boolean contains( PVector p );
  /** 
   * Checks if [p1, p2] intersects hitbox,
   * if true, returns intersection point, null otherwise.
   */
  PVector hasIntersection( PVector p1, PVector p2 );
  /** Returns null, if not hit, returns new bounced velocity otherwise. */
  PVector isHit( PVector from, PVector to );
  /** Returns shortest path from a point to hitbox. */
  PVector distVector( final PVector from );

  //float dist( PVector from );
  void move( PVector movement );
  void draw();
}


/** Hitbox made of polygon */
class ShapeHitbox implements Hitbox {
  PShape shape;
  ShapeHitbox() {
    shape = null;
  }

  ShapeHitbox( PShape sh, float x, float y ) {
    sh.translate( x, y );
    shape = sh;
  }

  /** Not implemented. */
  boolean contains( PVector p ) {
    //return shape.contains( p.x, p.y );
    //TODO contains with shapes
    return false;
  }

  /** Help function. Finds an intersection of two sections. */
  private PVector walkThrough( PVector c1, PVector c2, PVector coor, PVector ncoor ) {
    // from "https://habr.com/en/post/267037/" //
    PVector cut1 = ncoor.copy().sub(coor);
    PVector cut2 = c2.copy().sub(c1);
    PVector prod1, prod2;

    prod1 = cut1.copy().cross(PVector.sub(c1, coor));
    prod2 = cut1.copy().cross(PVector.sub(c2, coor));

    if ( prod1.copy().normalize().z == prod2.copy().normalize().z ) {
      return null;
    }

    prod1 = cut2.copy().cross(PVector.sub(coor, c1));
    prod2 = cut2.copy().cross(PVector.sub(ncoor, c2));

    if ( prod1.copy().normalize().z == prod2.copy().normalize().z ) {
      return null;
    }

    PVector cross = new PVector(
      coor.x + cut1.x*abs(prod1.z)/abs(prod2.z-prod1.z), 
      -(coor.y + cut1.x*abs(prod1.z)/abs(prod2.z-prod1.z)) );
    return cross;
  }


  PVector hasIntersection( PVector p1, PVector p2 ) {
    ArrayList<PVector> intersections = new ArrayList<PVector>();

    PVector intersection = null;
    PVector firstVertex = new PVector(), secondVertex = new PVector();
    // iterating through sides
    for ( int i = 0; i < shape.getVertexCount(); i++ ) {
      firstVertex = shape.getVertex(i);
      secondVertex = shape.getVertex( (i+1) % shape.getVertexCount() );
      intersection = walkThrough( firstVertex, secondVertex, p1, p2 );
      //println( "Side:", firstVertex, secondVertex, "Intercection:", intersection );
      // if intersection was found, memorize
      if ( intersection != null ) {
        intersections.add( intersection );
      }
    }

    if ( intersections.isEmpty() ) return null;
    // finding the closest intersection
    intersection = intersections.get(0);
    for ( PVector p : intersections ) {
      if ( p1.dist( p ) < p1.dist( intersection ) ) {
        intersection = p;
      }
    }
    intersection.y = -intersection.y;

    return intersection;
  }

  /**
   * Checks, if a point travelling from @param from to @param to will collide.
   * Returns null if it won`t collide, vector of new bounced velosity otherwise.
   * Modifies @param from to intersection point.
   */
  PVector isHit( PVector from, PVector to ) {
    //println( "isHit(", from, to, ")" );
    ArrayList<PVector> intersections = new ArrayList<PVector>();
    IntList sides = new IntList();

    PVector intersection = null;
    PVector firstVertex = new PVector(), secondVertex = new PVector();
    // iterating through sides
    for ( int i = 0; i < shape.getVertexCount(); i++ ) {
      firstVertex = shape.getVertex(i);
      secondVertex = shape.getVertex( (i+1) % shape.getVertexCount() );
      intersection = walkThrough( firstVertex, secondVertex, from, to );
      //println( "Side:", firstVertex, secondVertex, "Intercection:", intersection );
      // if intersection was found, memorize
      if ( intersection != null ) {
        intersections.add( intersection );
        sides.append( i );
      }
    }

    // if intersection wasn`t found, you can go
    if ( intersections.isEmpty() ) return null;


    //find the closest one
    int intersectedSide = sides.get(0);
    intersection = intersections.get(0);
    for ( int i = 0; i < intersections.size(); i++ ) {
      PVector p = intersections.get(i);
      if ( from.dist( p ) < from.dist( intersection ) ) {
        intersection = p;
        intersectedSide = sides.get(i);
      }
    }
    intersection.y = -intersection.y;

    firstVertex = firstVertex = shape.getVertex( intersectedSide );
    secondVertex = shape.getVertex( (intersectedSide+1) % shape.getVertexCount() );

    PVector vel = PVector.sub( to, from ); //speed vector
    PVector side = PVector.sub( secondVertex, firstVertex ); //side vector
    float a = PVector.angleBetween( vel, side ); 
    //println( degrees(a) );

    float magToSide = vel.mag() * sin(a); //magnitide of vector perpendicular to the side
    float magBySide = vel.mag() * cos(a); //magnitide of vector aligned to the side
    //println( "Magnitudes:", magToSide, magBySide );
    PVector velBySide = vel.copy(); 
    velBySide.rotate( -a ); 
    velBySide.mult( magBySide/vel.mag() ); 
    PVector velToSide = vel.copy(); 
    velToSide.rotate(HALF_PI - a); 
    velToSide.mult( magToSide/vel.mag() ); 
    //println( "Vectors: by side:", velBySide, "to side:", velToSide );

    vel = PVector.add( velBySide, velToSide.mult( -1 ) );
    from = intersection;

    return vel;
  }


  PVector distVector( final PVector from ) {
    PVector result = new PVector( 10e6, 10e6 );
    for ( int i = 0; i < shape.getVertexCount(); i++ ) {
      PVector vertex1 = shape.getVertex( i );
      PVector vertex2 = shape.getVertex( (i+1)%shape.getVertexCount() );

      if ( from.dist( vertex1 ) < result.mag() ) {
        result = PVector.sub( vertex1, from );
        //println( "Dist from - vertex:", result );
      }

      Section side = new Section( vertex1, vertex2 );

      PVector perpendicular = side.perpend( from );
      if ( perpendicular.mag() < result.mag() &&
        side.hasPoint( PVector.add( from, perpendicular ) ) ) {
        result = perpendicular;
        //println( "Distance from - side:", result );
      }
    }
    //verbose( result + "" );

    return result;
  }

  void move( PVector movement ) {
    shape.translate( movement.x, movement.y );
  }

  void draw() {
    fill( 255 ); 
    shape(shape);
  }
}

/** Simplyfied vercion of ShapeHitbox */
class RectHitbox extends ShapeHitbox {
  float x, y, w, h; 
  RectHitbox() {
    x = y = w = h = 0; 
    shape = null;
  }
  RectHitbox( float x_, float y_, float w_, float h_ ) {
    x = x_; 
    y = y_; 
    w = w_; 
    h = h_; 
    shape = createShape(); 
    shape.beginShape(); 
    shape.vertex( x, y ); 
    shape.vertex( x, y+h ); 
    shape.vertex( x+w, y+h ); 
    shape.vertex( x+w, y );
  }

  boolean contains( PVector p ) {
    return p.x > x && p.x < x+w && p.y > y && p.y < y+h;
  }
}


class CircleHitbox implements Hitbox {
  PVector center; 
  float radius; 
  CircleHitbox() {
    center = new PVector( 0, 0 ); 
    radius = 0;
  }

  CircleHitbox( float x, float y, float r ) {
    center = new PVector( x, y ); 
    radius = r;
  }

  boolean contains( PVector p ) {
    return center.dist( p ) < radius;
  }

  PVector hasIntersection( PVector from, PVector to ) {
    if ( from.x == to.x && from.y == to.y ) return null; 
    //translating coors to the center
    PVector p1 = PVector.sub( from, center ); 
    PVector p2 = PVector.sub( to, center ); 
    //println( "Moving from", p1, "to", p2 );

    //constances of line equation ( ax + by + c = 0 )
    float a = p1.y - p2.y; 
    float b = p2.x - p1.x; 
    //float c = p1.x*p2.y - p2.x*p1.y;

    //find angle between line and y-axis
    float t = HALF_PI - atan( -a/b ); 
    //println( "Angle:", degrees(t) );

    //(rotate point p1).x = dist between line and the center
    float d = p1.x * cos(t) - p1.y * sin(t); 
    //println( "Dist between line and the center", d );

    if ( abs(d) > radius ) return null; 
    //intersection points
    PVector intersection1 = new PVector( d, sqrt( sq(radius) - sq(d) ) ); 
    PVector intersection2 = new PVector( d, -sqrt( sq(radius) - sq(d) ) ); 
    //rotate clockwise
    intersection1.rotate( t ); 
    intersection2.rotate( t ); 
    //println( intersection1, intersection2 );

    PVector cross; 
    //check, if this point is on the section
    if ( intersection1.x < min( p1.x, p2.x ) || intersection1.x > max( p1.x, p2.x ) ) {
      if ( intersection2.x < min( p1.x, p2.x ) || intersection2.x > max( p1.x, p2.x ) ) {
        //println( "intersections are not on the section" );
        return null;
      } else {
        cross = intersection2;
      }
    } else {
      if ( intersection2.x < min( p1.x, p2.x ) || intersection2.x > max( p1.x, p2.x ) ) {
        cross = intersection1;
      } else {
        if ( p1.dist(intersection1) > p1.dist(intersection2) ) {
          cross = intersection2;
        } else {
          cross = intersection1;
        }
      }
    }
    //inverting y (dont know why)
    cross.y = -cross.y;

    return cross;
  }

  PVector isHit( PVector from, PVector to ) {
    PVector cross = hasIntersection( from, to );
    if ( cross == null ) return null;
    PVector p1 = PVector.sub( from, center );
    PVector p2 = PVector.sub( to, center );

    //calculating new velosity
    PVector vel = PVector.sub( p2, p1 ); 
    float angle = 2*PVector.angleBetween( vel, cross ) - PI; 
    //if ( cross.y < 0 ) angle = -angle;
    //checking, from what side the movable is entering
    if ( p1.x * cross.y - p1.y * cross.x > 0 ) angle = -angle; 
    //println( degrees(angle) );

    vel.rotate(angle); 
    //vel = cross;
    /*float magToSide = vel.mag() * cos(angle); //magnitide of vector perpendicular to the side
     float magBySide = vel.mag() * sin(angle); //magnitide of vector aligned to the side
     //println( "Magnitudes:", magToSide, magBySide );
     PVector velBySide = vel.copy();
     velBySide.rotate( -angle );
     velBySide.mult( magBySide/vel.mag() );
     PVector velToSide = vel.copy();
     velToSide.rotate(HALF_PI - angle);
     velToSide.mult( magToSide/vel.mag() );
     //println( "Vectors: by side:", velBySide, "to side:", velToSide );
     
     vel = PVector.add( velBySide, velToSide.mult( -1 ) );*/

    return vel;
  }

  PVector distVector( final PVector p ) {
    PVector result = PVector.sub( center, p );
    result.mult( (result.mag()-radius)/result.mag() );
    return result;
  }

  void move( PVector movement ) {
    center.add( movement );
  }

  void draw() {
    fill( 255 ); 
    ellipse( center.x, center.y, radius*2, radius*2 );
  }
}

/** Group of hitboxes. */
class GroupHitbox implements Hitbox {
  ArrayList<Hitbox> hitboxes = new ArrayList<Hitbox>(); 

  boolean contains( PVector p ) {
    for ( int i = 0; i < hitboxes.size(); i++ ) {
      if ( hitboxes.get(i).contains( p ) ) return true;
    }
    return false;
  }

  PVector hasIntersection( PVector p1, PVector p2 ) {
    PVector result = null;
    for ( Hitbox h : hitboxes ) {
      PVector intersection = h.hasIntersection( p1, p2 );
      if ( intersection == null ) continue;
      if ( p1.dist( intersection ) < p1.dist( result ) ) {
        result = intersection;
      }
    }

    return result;
  }

  PVector isHit( PVector from, PVector to ) {
    for ( int i = 0; i < hitboxes.size(); i++ ) {
      PVector result = hitboxes.get(i).isHit( from, to ); 
      if ( result != null ) return result;
    }
    return null;
  }

  PVector distVector( final PVector p ) {
    PVector result = null;
    float dist = 10e6;
    for ( int i = 0; i < hitboxes.size(); i++ ) {
      PVector v = hitboxes.get(i).distVector( p );
      if ( v.mag() < dist ) {
        result = v;
        dist = v.mag();
      }
    }

    return result;
  }

  void move( PVector movement ) {
    for ( int i = 0; i < hitboxes.size(); i++ ) {
      hitboxes.get(i).move( movement );
    }
  }

  void addHitbox( Hitbox hb ) {
    hitboxes.add( hb );
  }
  void removeHitbox( Hitbox hb ) {
    hitboxes.remove( hb );
  }

  void draw() {
    for ( int i = 0; i < hitboxes.size(); i++ ) {
      hitboxes.get(i).draw();
    }
  }
}

/** A wall on a map. */
class Wall extends Object {
  private Obstacle m_obstacle; 
  Wall( Scene sc, Hitbox hb ) {
    super( sc, 0, 0 ); 
    m_obstacle = new Obstacle( this ); 
    setHitbox( hb ); 
    //m_obstacle.setPass(MovableType.Character); 
    //m_obstacle.setPass(MovableType.Projectile); 
    behaviours.add( m_obstacle );
  }

  void setHitbox( Hitbox hb ) {
    m_obstacle.hitbox = hb;
  }

  void update() {
  }

  void draw() {
    m_obstacle.hitbox.draw();
  }
}

/** Deserializer. */
class WallBuilder implements Builder {
  private ArrayList<String> stringBuffer = new ArrayList<String>(); 
  Object build( Scene sc ) {
    Hitbox h = null; 

    String hitboxType = stringBuffer.get(0); 
    switch ( hitboxType ) {

    case "Shape" : 
      PShape shape = createShape(); 
      shape.beginShape(); 

      for ( int i = 1; i < stringBuffer.size(); i++ ) {
        String line = stringBuffer.get(i); 

        switch ( line ) {
        case "contour:" : 
          shape.beginContour(); 
          break; 
        case "end_contour" : 
          shape.endContour(); 
          break; 
        default : 
          PVector p = parseCoors( line ); 
          shape.vertex( p.x, p.y );
        }
      }

      shape.endShape(); 
      h = new ShapeHitbox( shape, 0, 0 ); 
      break; 

    case "Circle" : 
      PVector coor = parseCoors( stringBuffer.get(1) );
      float r = parseFloat( stringBuffer.get(2) );
      h = new CircleHitbox( coor.x, coor.y, r );
      break; 

    default :
      //add error message here
      break;
    }

    Wall result = new Wall( sc, h ); 
    return result;
  }

  void addLine( String str ) {
    stringBuffer.add( str );
  }
}
