final float SHORTEST_ACTION_LEN = 0.5;
final float BRAKE_EXEC_TIME = 0.3;
final float TORQUE_PEAK_SEC = 0.1;
class Action extends UIComponent {
  final ActionType type;
  float duration;
  int speed;
  Motor motor;
  Action(ActionType type, float duration, int speed) {
    this.type = type;
    this.duration = duration;
    this.speed = speed;
  }
  Action copy() {
    Action copy = new Action(this.type, this.duration, this.speed);
    return copy;
  }
  Motor getMotor() {
    return motor;
  }
  void setMotor(Motor motor) {
    this.motor = motor;
  }
  void drawSelf(){
    drawRect();
    drawLabel();
    drawStatus();
  }
  float getDuration() {
    return duration;
  }
  void setDuration(float duration) {
    this.duration = duration;
  }
  int getSpeed() {
    return speed;
  }
  void setSpeed(int speed) {
    this.speed = speed;
  }
  ActionType getType() {
    return type;
  }
  JSONObject toJSON() {
    JSONObject json = new JSONObject();
    json.setString("type", this.type.name());
    json.setFloat("duration", this.duration);
    json.setInt("speed", this.speed);
    return json;
  }
  String getLabel() {
    if (type == ActionType.SPEED) {
      int fakeSpeed = speed == 255 ? 250 : speed == -255 ? -250 : speed;
      return Integer.toString(round(map(fakeSpeed, -250, 250, -100, 100))) + "%";
    } else if (type == ActionType.BRAKE) {
      return "BRAKE";
    }
    return type.name();
  }
  color getFillColor() {
     if (this.type == ActionType.BRAKE) return getRed();
     if (this.speed == 0) return getWhite();
     if (this.speed > 0) return getCWColor();
     return getCCWColor();
  }
  float getWidth() {
    return timeManager.secondsToPixels(this.getDuration());
  }
  float getCenterX() {
    return getWidth() / 2 + x;
  }
  float getCenterY() {
    return y + ROW_HEIGHT / 2;
  }
  boolean isMouseOver() {
    if (mouseX > x 
      && mouseX < x + getWidth()
      && mouseY > y
      && mouseY < y + ROW_HEIGHT) return true;
    return false;
  }
  void drawRect() {
    fill(this.getFillColor());
    strokeWeight(1);
    stroke(getGrey());
    float actionWidth = this.getWidth();
    rect(x, y, actionWidth, ROW_HEIGHT);
    if (this.type == ActionType.BRAKE && this.getDuration() > BRAKE_EXEC_TIME) {
      float darkWidth = timeManager.secondsToPixels(BRAKE_EXEC_TIME);
      strokeWeight(0);
      fill(getLightRed());
      rect(x + darkWidth, y, actionWidth - darkWidth, ROW_HEIGHT);
      strokeWeight(1);
    }
  }

  void drawLabel() {
    fill(getBlack());
    textAlign(CENTER, CENTER);
    useTitleFont();
    float centerX = this.getCenterX();
    float centerY = this.getCenterY();
    float textWidth = textWidth("BRAKE");
    float actionWidth = this.getWidth();
    if (textWidth > actionWidth) {
      pushMatrix();
      translate(this.x + actionWidth / 2, this.y + ROW_HEIGHT / 2); // Center the rotation
      rotate(-HALF_PI); // Rotate 90 degrees
      text(this.getLabel(), 0, 0);
      popMatrix();
      return;
    }
    if (this.type == ActionType.BRAKE) {
      text(this.getLabel(), centerX, centerY);
      return;
    }
    if (!motor.drawer.showRpm || speed == 0) {
      text("SPIN", centerX, centerY - 15);
      text(this.getLabel(), centerX, centerY + 15);
    } else {
      int rpm = page.rpmMapper.getRPM(motor.fw + "fw", abs(speed));
      text("SPIN", centerX, centerY - 25);
      text(this.getLabel(), centerX, centerY);
      text("RPM: " + str(speed > 0 ? rpm : -rpm), centerX, centerY + 25);
    }
  }

  void drawStatus() {
    float labelWidth = this.getWidth();
    String label = this.getLabel();
    float textWidth = textWidth(label);
    float centerX = this.getCenterX();
    float centerY = this.getCenterY();
    int actionIndex = this.motor.getActionIndex(this);
    Action lastAction = actionIndex == 0 ? null : this.motor.getAction(actionIndex - 1);
    RotationDirection torqueDirection = this.motor.getTorqueDirection(this, lastAction);
    if (!motor.drawer.showTorque) return;
    imageMode(CENTER);
    float iconX = x + timeManager.secondsToPixels(TORQUE_PEAK_SEC);
    if (torqueDirection == RotationDirection.CW) {
      PImage icon = this.type == ActionType.BRAKE ? cwBigTorqueIcon : cwTorqueIcon;
      image(icon, iconX, y + ROW_HEIGHT - ICON_SIZE);
    } else if (torqueDirection == RotationDirection.CCW) {
      PImage icon = this.type == ActionType.BRAKE ? ccwBigTorqueIcon : ccwTorqueIcon;
      image(icon, iconX, y + ICON_SIZE);
    }
    imageMode(CORNER);
  }
}

enum ActionType { SPEED, BRAKE }

color getActionDefaultColor(ActionType type) {
  switch(type) {
    case SPEED:
      return getCWColor();
    case BRAKE:
      return getRed();
    default:
      return getCWColor();
  }
}
Action loadActionJSON(JSONObject json) {
  ActionType type = ActionType.valueOf(json.getString("type"));
  Action action = createAction(type);
  action.setDuration(json.getFloat("duration"));
  action.setSpeed(json.getInt("speed"));
  return action;
}
Action createAction(ActionType type) {
  switch(type) {
    case SPEED:
      return new Action(type, 1, 125);
    case BRAKE:
      return new Action(type, 1, 0);
    default:
      return null;
  }
}

class ActionControl {
  Button deleteButton;
  DurationSlider durationSlider;
  ActionControl() {
    this.deleteButton = initDeleteButton();
    this.durationSlider = new DurationSlider();
  }

  void draw() {
    Action selectedAction = page.selectedAction;
    if (!page.state.canModify() || selectedAction == null) {
      hide();
      return;
    }
    show();
    float x = selectedAction.x;
    float y = selectedAction.y;
    float actionWidth = selectedAction.getWidth();
    deleteButton.setPosition(x + actionWidth - SLIDER_WIDTH - SMALL_ICON_SIZE, y + 1);
    this.durationSlider.draw(x, y);
  }
  
  void show() {
    deleteButton.show();
    durationSlider.show();
  }
  
  void hide() {
    durationSlider.hide();
    deleteButton.hide();
  }
  
  Slider addSlider(String name, int x, int y, int width, float min, float max, int numTicks, String caption) {
    Slider slider = cp5.addSlider(name)
     .setPosition(x, y)
     .setWidth(width)
     .setRange(min, max)
     .setNumberOfTickMarks(numTicks)
     .setSliderMode(Slider.FLEXIBLE)
     .setColorForeground(color(207, 98, 67))
     .setColorBackground(color(40))
     .setColorActive(color(255, 138, 101));
    slider.getValueLabel().alignX(ControlP5.RIGHT).setPaddingX(0);
    slider.getCaptionLabel().alignX(ControlP5.LEFT).setPaddingX(0);
    if (!caption.isEmpty()) {
      slider.setCaptionLabel(caption);
    }
    return slider;
  }
  
  Button initDeleteButton() {
    return cp5.addButton("actionDeleteButton")
     .setPosition( -200, -200) // out of screen
     .setImage(minusIcon).setSize(SMALL_ICON_SIZE, SMALL_ICON_SIZE)
     .addListener(new ControlListener() {
      public void controlEvent(ControlEvent event) {
        if (!page.state.canModify() || page.selectedAction == null) return;
        if (event.getName().equals("actionDeleteButton")) {
          page.selectedAction.motor.removeAction(page.selectedAction);
          page.selectedAction = null;
          hide();
        }
      }
    });
  }
}

class DurationSlider {
  boolean showing = false;
  DurationSlider() {}
  void show() {
    this.showing = true;
  }
  void hide() {
    this.showing = false;
  }
  
  boolean isMouseOver() {
    Action selectedAction = page.selectedAction;
    if (!showing || !page.state.canModify() || selectedAction == null) return false;
    float y = selectedAction.y;
    float endX = selectedAction.getWidth() + selectedAction.x;
    if (mouseX > endX - SLIDER_WIDTH 
      && mouseX < endX
      && mouseY > y
      && mouseY < y + ROW_HEIGHT) return true;
    return false;
  }
  
  void draw(float x, float y) {
    Action selectedAction = page.selectedAction;
    if (!showing || !page.state.canModify() || selectedAction == null) return;
    float endX = selectedAction.getWidth() + selectedAction.x;
    fill(getGrey());
    stroke(getBlack());
    strokeWeight(1);
    rect(endX - SLIDER_WIDTH, y, SLIDER_WIDTH, ROW_HEIGHT);
    stroke(color(#404040));
    strokeWeight(1.5);
    line(endX - SLIDER_WIDTH + SLIDER_WIDTH / 2, y + 5, endX - SLIDER_WIDTH + SLIDER_WIDTH / 2, y + ROW_HEIGHT - 5);
    fill(255);
  }

  boolean locked;
  float xOffset = 0;
  float yOffset = 0;
}
