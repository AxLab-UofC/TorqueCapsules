enum RotationDirection {
  IDLE,
  CW,
  CCW
}
class Motor extends UIComponent {
  final List<Action> actions = new ArrayList<Action>();   // List of actions assigned to the motor
  final MotorDrawer drawer;
  MotorIMU imu;
  final int id;
  RotationDirection motorDirection;
  RotationDirection torqueDirection;
  boolean bigTorque = false;
  int fw = 0;
  float individualSeconds = 0;
  boolean playIndividual = false;
  Set<Action> processed = new HashSet<Action>();

  Motor(int id) {
    this.imu = new MotorIMU();
    this.id = id;
    this.drawer = new MotorDrawer(this);
    this.motorDirection = RotationDirection.IDLE;
  }
  
  int getId() { return id; }
  
  // Calculate the total duration of all actions
  float getSequenceLength() {
    float total = 0;
    for (Action action : actions) {
      total += action.getDuration();
    }
    return total;
  }
  void drawSelf() {
    drawer.draw(this.x, this.y);
    drawMotorStatus(this);
    drawTorqueChart(this);
  }
  void setChildrenXY() {
    float lastEndX = MOTOR_COL_WIDTH + STATUS_COL_WIDTH;
    for (Action action : this.getActions()) {
      action.setXY(lastEndX, this.y);
      lastEndX += timeManager.secondsToPixels(action.getDuration());
    }
  }
  void drawChildren() {
    actions.forEach(action -> action.draw());
  }

  void loopPlayState() {
    processed.clear();
  }
  
  void reset() {
    loopPlayState();
    this.motorDirection = RotationDirection.IDLE;
    this.torqueDirection = RotationDirection.IDLE;
    this.bigTorque = false;
    this.individualSeconds = 0;
    this.playIndividual = false;
  }

  RotationDirection getMotorDirection(int speed) {
    return speed > 0 ? RotationDirection.CW : speed < 0 ? RotationDirection.CCW : RotationDirection.IDLE;
  }

  RotationDirection getTorqueDirection(Action currAction, Action lastAction) {
    int diff = lastAction == null ? currAction.speed : currAction.speed - lastAction.speed;
    return diff > 0 ? RotationDirection.CCW : diff < 0 ? RotationDirection.CW : RotationDirection.IDLE;
  }
  
  void execute() {
    float currTime = playIndividual ? individualSeconds : timeManager.getCurrSeconds();
    float pastTime = 0;
    for (int i = 0; i < actions.size(); i++) {
      Action action = getAction(i);
      if (pastTime > currTime) {
        return;
      }
      if (!processed.contains(action)) {
        processed.add(action);
        int speed = action.getSpeed();
        if (action.type == ActionType.SPEED) {
          this.bigTorque = false;
          osc_send_speed(speed, id);
        } else if (action.type == ActionType.BRAKE) {
          this.bigTorque = true;
          osc_send_brake(id);
        }
        this.motorDirection = getMotorDirection(speed);
        this.torqueDirection = getTorqueDirection(action, i == 0 ? null : getAction(i - 1));
        return;
      }
      pastTime += action.getDuration();
    }
  }

  void simulate() {
    float currTime = timeManager.getCurrSeconds();
    float pastTime = 0;
    for (int i = 0; i < actions.size(); i++) {
      Action action = getAction(i);
      if (pastTime > currTime) {
        return;
      }
      if (!processed.contains(action)) {
        processed.add(action);
        int speed = action.getSpeed();
        if (action.type == ActionType.SPEED) {
          this.bigTorque = false;
        } else if (action.type == ActionType.BRAKE) {
          this.bigTorque = true;
        }
        this.motorDirection = getMotorDirection(speed);
        this.torqueDirection = getTorqueDirection(action, i == 0 ? null : getAction(i - 1));
        return;
      }
      pastTime += action.getDuration();
    }
  }
  
  List<Action> getActions() { return actions; }
  
  void insertAction(Action action, int index) {
    action.setMotor(this);
    actions.add(index, action);
  }

  int getActionIndex(Action action) {
    return actions.indexOf(action);
  }

  Action getAction(int index) {
    return actions.get(index);
  }
  
  Action removeAction(Action action) {
    action.setMotor(null);
    actions.remove(getActionIndex(action));
    return action;
  }


  float getActionStartTime(Action action) {
    float startTime = 0;
    for (Action curr : getActions()) {
      if (curr == action) break;
      startTime += curr.getDuration();
    }
    return startTime;
  }
  
  int findIndexToInsert(float startTime) {
    // after the first one that ends after startTime
    float currTime = 0;
    for (int i = 0; i < actions.size(); i++) {
      if (currTime + getAction(i).getDuration() >= startTime) {
        return i + 1;
      }
      currTime += getAction(i).getDuration();
    }
    return actions.size();
  }
  
  JSONObject toJSON() {
    JSONObject json = new JSONObject();
    json.setString("address", clientAddresses[id].toString());
    JSONArray actionsJSON = new JSONArray();
    for (int i = 0; i < actions.size(); i++) {
      actionsJSON.setJSONObject(i, getAction(i).toJSON());
    }
    json.setJSONArray("actions", actionsJSON);
    return json;
  }
}

