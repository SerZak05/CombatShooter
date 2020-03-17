/** Class for managing an inventory. */
class Inventory {
  private ArrayList<Item> items = new ArrayList<Item>();
  private Item currentItem = null;

  void addItem( Item i ) {
    items.add( i );
  }

  ArrayList<Item> getByType( ItemType t ) {
    ArrayList<Item> result = new ArrayList<Item>();
    for ( Item i : items ) {
      if ( i.type == t ) result.add( i );
    }
    return result;
  }
}

enum ItemType {
  Gun, Ammo, Kit
}
/** Base class for items. */
class Item {
  ItemType type;
  Item( ItemType t ) {
    type = t;
  }
}

class GunItem extends Item {
  final String gunType;
  GunItem( final String t ) {
    super( ItemType.Gun );
    gunType = t;
  }
}

class AmmoItem extends Item {
  final String ammoType;
  final int ammoCount;
  AmmoItem( final String t, final int c ) {
    super( ItemType.Ammo );
    ammoType = t;
    ammoCount = c;
  }
}
