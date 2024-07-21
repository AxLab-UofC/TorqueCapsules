// use only one instead of one drawer for one motor
class MotorDrawer {
  final Motor motor;
  final Button addSpeedButton;
  final Button addBrakeButton;
  final Button setFWButton;
  final Button showRpmToggle;
  final Button showTorqueToggle;
  final Button clearMotorButton;
  float x, y;
  boolean showRpm = false;
  boolean showTorque = true;
  MotorDrawer(Motor motor) {
    this.motor = motor;
    this.addSpeedButton = initAddSpeedButton();
    this.addBrakeButton = initAddBrakeButton();
    this.setFWButton = initSetFWButton();
    this.showRpmToggle = initShowRpmToggle();
    this.showTorqueToggle = initShowTorqueToggle();
    this.clearMotorButton = initClearMotorButton();
  }
  
  // cp5 controllers are hard to cleanup, so we have to do it manually
  // These are the only dynamically created cp5 controllers
  void clear() {
    cp5.remove("AddSpeed-" + motor.getId());
    cp5.remove("AddBrake-" + motor.getId());
    cp5.remove("SetFW-" + motor.getId());
    cp5.remove("ToggleShowRPM-" + motor.getId());
    cp5.remove("ToggleShowTorque-" + motor.getId());
    cp5.remove("ClearMotor-" + motor.getId());
  }
  
  void drawLabels() {
    stroke(getBlack());
    fill(getBlack());
    useTitleFont();
    textAlign(LEFT, TOP);
    clearMotorButton.setPosition(MOTOR_COL_WIDTH - SMALL_ICON_SIZE, y + 5);
    float linespace = (ROW_HEIGHT - ICON_SIZE / 2 - titleSize - bodySize * 3) / 4;
    float yGap = linespace + bodySize;
    float textY = y + ICON_SIZE / 2;
    text("Motor " + str(motor.getId() + 1), x + ICON_SIZE / 2, textY);
    textY += yGap + (titleSize - bodySize) * 2;
    useBodyFont();
    textAlign(LEFT, CENTER);
    float textX = x + ICON_SIZE;
    float buttonX = textX + textWidth("Flywheels") + ICON_SIZE;
    
    text("Flywheels", textX, textY);
    setFWButton.setPosition(buttonX, textY - ICON_SIZE / 2);
    textY += yGap;

    text("RPM", textX, textY);
    showRpmToggle.setPosition(buttonX, textY - ICON_SIZE / 2);
    textY += yGap;

    text("Torque", textX, textY);
    showTorqueToggle.setPosition(buttonX, textY - ICON_SIZE / 2);

    textAlign(CENTER, CENTER);
  }
  
  Button createActionButton(String name, String caption, ActionType type) {
    String buttonName = name + "-" + motor.getId();
    return initTextButton(buttonName, new ControlListener() {
      public void controlEvent(ControlEvent event) {
        if (!page.state.canModify()) return;
        if (event.getName().equals(buttonName)) {
          Action createdAction = createAction(type);
          motor.insertAction(createdAction, motor.getActions().size());
        }
      }
    }, caption, 100, 30).setColorBackground(color(getActionDefaultColor(type), 200)).setColorLabel(getBlack());
  }
  
  Button initAddSpeedButton() {
    return createActionButton("AddSpeed", "+ Speed", ActionType.SPEED);
  }
  
  Button initAddBrakeButton() {
    return createActionButton("AddBrake", "+ Brake", ActionType.BRAKE);
  }

  Button initClearMotorButton() {
    String name = "ClearMotor" + "-" + motor.getId();
    return initIconButton(name, new ControlListener() {
      public void controlEvent(ControlEvent event) {
        if (!page.state.canModify()) return;
        if (event.getName().equals(name)) {
          if (motor.actions.isEmpty()) return;
          motor.actions.clear();
          osc_send_speed(0, motor.getId());
        }
      }
    }, trashIcon, SMALL_ICON_SIZE);
  }
  
  Button initSetFWButton() {
    String name = "SetFW" + "-" + motor.getId();
    return initTextButton(name, new ControlListener() {
      public void controlEvent(ControlEvent event) {
        if (event.getName().equals(name)) {
          motor.drawer.incrementFW();
        }
      }
    }, str(motor.fw), ICON_SIZE, ICON_SIZE).setColorBackground(getLightGrey()).setColorLabel(getWhite());
  }

  Button initShowRpmToggle() {
    String name = "ToggleShowRPM" + "-" + motor.getId();
    return initIconButton(name, new ControlListener() {
      public void controlEvent(ControlEvent event) {
        if (event.getName().equals(name)) {
          motor.drawer.toggleShowRPM();
        }
      }
    }, this.showRpm ? onIcon : offIcon, ICON_SIZE);
  }

  Button initShowTorqueToggle() {
    String name = "ToggleShowTorque" + "-" + motor.getId();
    return initIconButton(name, new ControlListener() {
      public void controlEvent(ControlEvent event) {
        if (event.getName().equals(name)) {
          motor.drawer.toggleShowTorque();
        }
      }
    }, this.showTorque ? onIcon : offIcon, ICON_SIZE);
  }

  void incrementFW() {
    this.motor.fw = (this.motor.fw + 1) % 4;
    this.setFWButton.setCaptionLabel(this.motor.fw < 3 ? str(this.motor.fw) : "L");
  }

  void toggleShowRPM() {
    this.showRpm = !this.showRpm;
    this.showRpmToggle.setImage(showRpm ? onIcon : offIcon);
  }

  void toggleShowTorque() {
    this.showTorque = !this.showTorque;

    this.showTorqueToggle.setImage(showTorque ? onIcon : offIcon);
  }

  void draw(float x, float y) {
    this.x = x;
    this.y = y;
    drawLabels();
    float lastEndX = MOTOR_COL_WIDTH + STATUS_COL_WIDTH;
    for (Action action : motor.getActions()) {
      lastEndX += timeManager.secondsToPixels(action.getDuration());
    }
    float buttonHeight = addSpeedButton.getHeight();
    float addButtonsDist = motor.getActions().size() == 0 ? 80 : 10;
    addSpeedButton.setPosition(lastEndX + addButtonsDist, y + (ROW_HEIGHT - 3 * buttonHeight) / 2);
    addBrakeButton.setPosition(lastEndX + addButtonsDist, y + (ROW_HEIGHT + buttonHeight) / 2);

    if (page.selectedMotor == this.motor) {
      strokeWeight(3);
      stroke(getBlack());
      line(ACTION_START_X, y, width, y);
      line(ACTION_START_X, y + ROW_HEIGHT, width, y + ROW_HEIGHT);
      line(ACTION_START_X, y, ACTION_START_X, y + ROW_HEIGHT);
    }
  }

  boolean isMouseOver() {
    if (mouseX > ACTION_START_X
      && mouseX < width
      && mouseY > y
      && mouseY < y + ROW_HEIGHT) return true;
    return false;
  }
}

void drawMotorStatus(Motor motor) {
  float x = motor.x + MOTOR_COL_WIDTH;
  float y = motor.y;
  fill(getWhite());
  stroke(getBlack());
  strokeWeight(1);
  float boxMargin = (STATUS_COL_WIDTH - BOX_WIDTH) / 2;
  float motorIconMargin = boxMargin + (BOX_WIDTH - LARGE_ICON_SIZE) / 2;
  
  rect(x + boxMargin, y + boxMargin, BOX_WIDTH, BOX_WIDTH, 28);
  switch(motor.motorDirection) {
    case IDLE:
      image(circleIcon, x + motorIconMargin, y + motorIconMargin);
      break;
    case CCW:
      image(ccwIcon, x + motorIconMargin, y + motorIconMargin);
      break;
    case CW:
      image(cwIcon, x + motorIconMargin, y + motorIconMargin);
      break;
  }
  float torqueY = y + (BOX_WIDTH - LARGE_ICON_SIZE) / 2;
  imageMode(CENTER);
  if (motor.torqueDirection == RotationDirection.CW) {
    PImage icon = motor.bigTorque ? cwBigTorqueIcon : cwTorqueIcon;
    image(icon, x + ROW_HEIGHT - ICON_SIZE, y + ROW_HEIGHT - ICON_SIZE);
  } else if (motor.torqueDirection == RotationDirection.CCW) {
    PImage icon = motor.bigTorque ? ccwBigTorqueIcon : ccwTorqueIcon;
    image(icon, x + ROW_HEIGHT - ICON_SIZE, y + ICON_SIZE);
  }
  imageMode(CORNER);
}
