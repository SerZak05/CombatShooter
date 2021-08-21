/**
 * Control module.
 * Contains global list of pressed keys and mouse state that are visible from anywhere.
 */

enum MouseState {
  None, MouseDragged, MouseReleased, MouseClicked, MouseMoved
}
MouseState currentMouseState = MouseState.None;
IntList pressedKeys = new IntList(); //stored in keyCodes

void mouseClicked() {
  currentMouseState = MouseState.MouseClicked;
}

void mouseDragged() {
  currentMouseState = MouseState.MouseDragged;
}

void mouseReleased() {
  currentMouseState = MouseState.MouseReleased;
}

void mouseMoved() {
  currentMouseState = MouseState.MouseMoved;
}

void keyPressed() {
  pressedKeys.appendUnique(keyCode);
}

void keyReleased() {
  pressedKeys.removeValue(keyCode);
}
