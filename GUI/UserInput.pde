void sliderDragHandler() {
  if (page.selectedAction == null || !page.state.canModify()) return;
  DurationSlider durationSlider = page.actionControl.durationSlider;
  if (durationSlider.locked && page.selectedAction != null) {
    float dx = mouseX - durationSlider.xOffset;
    float currDuration = page.selectedAction.getDuration();
    float timeDiff = timeManager.pixelsToSeconds(dx);
    float newDuration = roundToDecimalPlace(currDuration + roundToDecimalPlace(timeDiff, 1), 1);
    if (newDuration != currDuration && newDuration >= SHORTEST_ACTION_LEN) {
      page.selectedAction.setDuration(newDuration);
      durationSlider.xOffset += dx;
    }
  }
}

void sliderReleaseHandler() {
  if (page.selectedAction == null || !page.state.canModify()) return;
  DurationSlider durationSlider = page.actionControl.durationSlider;
  if (durationSlider.locked) {
    durationSlider.locked = false;
  }
}

void mousePressed() {
  if (!page.state.canModify()) return;
  Action clickedAction = findClickedAction();
  if (clickedAction != null) {
    page.selectedAction = clickedAction;
  } else {
    page.selectedAction = null;
  }
  
  DurationSlider durationSlider = page.actionControl.durationSlider;
  if (durationSlider.isMouseOver()) {
    durationSlider.locked = true;
    durationSlider.xOffset = mouseX;
  }
}

void mouseDragged() {
  sliderDragHandler();
}

void mouseReleased() {
  sliderReleaseHandler();
  Motor clickedMotor = findClickedMotor();
  if (clickedMotor == null) {
    page.selectedMotor = null;
    return;
  }
  page.selectedMotor = clickedMotor;
}

void mouseMoved() {
  if (cp5.getMouseOverList().size() > 0) {
    cursor(HAND);
    return;
  }
  if (page.selectedAction != null && page.state.canModify() && page.actionControl.durationSlider.isMouseOver()) {
    cursor(HAND);
    return;
  }
  cursor(ARROW);
}

void mouseWheel(MouseEvent event) {
  actionScrollHandler(event.getCount());
}

void keyPressed() {
  Action selectedAction = page.selectedAction;
  if (selectedAction != null && key == CODED &&
    (keyCode == UP || keyCode == DOWN || keyCode == LEFT || keyCode == RIGHT)
  ) {
      shiftAction(selectedAction);
  }
  if (key == ' ') {
    page.state.hitSpace();
  }
  if (key == 'r') {
    page.state.clickReset();
  }
  if (key == 'c' && page.selectedMotor != null && page.selectedMotor.actions.size() > 0) {
    page.copiedMotor = page.selectedMotor;
    page.popupText = "Copied Motor " + page.copiedMotor.id + "!";
    page.popupCountdown = 60 * 2;
  }
  if (key == 'v' && page.state.canModify() && page.selectedMotor != null && page.copiedMotor != null) {
    if (page.selectedMotor == page.copiedMotor) return;
    if (!page.selectedMotor.actions.isEmpty()) {
      page.selectedMotor.actions.clear();
      osc_send_speed(0, page.selectedMotor.getId());
    }
    for (Action action : page.copiedMotor.actions) {
      page.selectedMotor.insertAction(action.copy(), page.selectedMotor.actions.size());
    }
  }

  if (key >= '1' && key <= '4') {
    page.state.clickNumber(key - '0');
  }
}

Action findClickedAction() {
  for (Motor motor : page.motors) {
    for (Action action : motor.getActions()) {
      if (action.isMouseOver()) {
        return action;
      }
    }
  }
  return null;
}

Motor findClickedMotor() {
  for (Motor motor : page.motors) {
    if (motor.drawer.isMouseOver()) {
      return motor;
    }
  }
  return null;
}

void actionScrollHandler(int e) {
  if (!page.state.canModify()) return;
  Action selectedAction = page.selectedAction;
  if (selectedAction != null && selectedAction.type == ActionType.SPEED) {
    int currSpeed = selectedAction.getSpeed();
    if (currSpeed == 255) currSpeed = 250;
    if (currSpeed == -255) currSpeed = -250;
    int newSpeed = currSpeed + (e % 2) * 25;
    newSpeed = (newSpeed >= 250) ? 255 : (newSpeed <= -250) ? -255 : newSpeed;
    if (newSpeed >= 250) {
      newSpeed = 255;
    } else if (newSpeed <= -250) {
      newSpeed = -255;
    } else if (newSpeed == 25) {
      newSpeed = e > 0 ? 50 : e < 0 ? 0 : 25;
    } else if (newSpeed == -25) {
      newSpeed = e > 0 ? 0 : e < 0 ? -50 : -25;
    }
    if (newSpeed != selectedAction.getSpeed()) {
      selectedAction.setSpeed(newSpeed == 25 ? 50 : newSpeed == -25 ? -50 : newSpeed);
    }
  }
}

void shiftAction(Action action) {
  Motor oldMotor = action.motor;
  int motorId = oldMotor.id;
  int actionPos = oldMotor.actions.indexOf(action);
  if (keyCode == UP && motorId > 0) {
    Motor destMotor = page.motors.get(motorId - 1);
    float startTime = oldMotor.getActionStartTime(action);
    oldMotor.removeAction(action);
    destMotor.insertAction(action, destMotor.findIndexToInsert(startTime));
  } else if (keyCode == DOWN && motorId < page.motors.size() - 1) {
    Motor destMotor = page.motors.get(motorId + 1);
    float startTime = oldMotor.getActionStartTime(action);
    oldMotor.removeAction(action);
    destMotor.insertAction(action, destMotor.findIndexToInsert(startTime));
  } else if (keyCode == LEFT && actionPos > 0) {
    oldMotor.insertAction(oldMotor.removeAction(action), actionPos - 1);
  } else if (keyCode == RIGHT && actionPos < oldMotor.actions.size() - 1) {
    oldMotor.insertAction(oldMotor.removeAction(action), actionPos + 1);
  }
}