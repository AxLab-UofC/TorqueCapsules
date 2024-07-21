final float BOTTOM_RATIO = 0.15;
final float GAP_ROW_RATIO = 0.05;
final int BOTTOM_GAP = int(SCREEN_HEIGHT * BOTTOM_RATIO);
final int TOP_GAP = 30;
final int ROW_HEIGHT = int((SCREEN_HEIGHT - BOTTOM_GAP - TOP_GAP) / (MAX_MOTORS + (MAX_MOTORS - 1) * GAP_ROW_RATIO));
final int ROW_GAP = int(ROW_HEIGHT * GAP_ROW_RATIO);

final int bodySize = 14;
final int titleSize = 18;

final int MOTOR_COL_WIDTH = int(ROW_HEIGHT * 1.2);
final int STATUS_COL_WIDTH = int(ROW_HEIGHT);
final int ACTION_START_X = MOTOR_COL_WIDTH + STATUS_COL_WIDTH;
final int BOTTOM_CENTER_Y = SCREEN_HEIGHT - BOTTOM_GAP / 2;
final int ICON_SIZE = 30;
final int LARGE_ICON_SIZE = 60;
final int SMALL_ICON_SIZE = 20;
final int USABLE_WIDTH = SCREEN_WIDTH - ACTION_START_X - 5;
final float BOX_WIDTH = ROW_HEIGHT * 0.5;
final float ICON_LABEL_MARGIN = 5;
final int SLIDER_WIDTH = ICON_SIZE / 3;
final int POPUP_WIDTH = 300;
final int POPUP_HEIGHT = 200;

final String FILE_NAME = "sequence.json"; // Change the file name and location as desired
final String TORQUE_JSON_NAME = "./data/unit_all_testonce.json";
final String RPM_JSON_NAME = "./data/rpm.json";

class Page extends UIComponent {
  String name;
  final List<Motor> motors;             // List of all motors
  Action selectedAction;          // Currently selected action
  ActionControl actionControl; // Controller for the selected action
  
  final Button simulateButton;
  final Button playButton;              // Button to play/pause the sequence
  final Button resetButton;             // Button to reset the time
  final Button addMotorButton;
  final Button loadButton;
  final Button saveButton;

  float x, y;

  TorqueChartMapper torqueChartMapper;
  RPMMapper rpmMapper;

  PageState state;
  PageState defaultState;
  PageState realPlayState;
  PageState simulatePlayState;
  PageState realPauseState;
  PageState simulatePauseState;
  PageState individualMotorState;

  String popupText = null;
  int popupCountdown = 0;
  Motor selectedMotor = null;
  Motor copiedMotor = null;

  Page(String name) {
    this.name = name;

    this.actionControl = new ActionControl();
    
    this.simulateButton = initSimulateButton();
    this.playButton = initPlayButton();
    this.resetButton = initResetButton();
    this.addMotorButton = initAddMotorButton();
    this.loadButton = initLoadButton();
    this.saveButton = initSaveButton();
    
    motors = new ArrayList<Motor>();
    motors.add(new Motor(0));

    this.torqueChartMapper = new TorqueChartMapper(loadJSONObject(TORQUE_JSON_NAME));
    this.rpmMapper = new RPMMapper(loadJSONObject(RPM_JSON_NAME));

    defaultState = new DefaultState(this);
    realPlayState = new RealPlayState(this);
    realPauseState = new RealPauseState(this);
    simulatePlayState = new SimulatePlayState(this);
    simulatePauseState = new SimulatePauseState(this);
    individualMotorState = new IndividualMotorState(this);
    state = defaultState;
  }

  void setState(PageState state) {
    this.state = state;
  }

  PageState getDefaultState() {
    return defaultState;
  }

  PageState getRealPlayState() {
    return realPlayState;
  }

  PageState getSimulatePlayState() {
    return simulatePlayState;
  }

  PageState getRealPauseState() {
    return realPauseState;
  }

  PageState getSimulatePauseState() {
    return simulatePauseState;
  }

  PageState getIndividualMotorState() {
    return individualMotorState;
  }
  
  Action getSelectedAction() {
    return selectedAction;
  }
  
  void setSelectedAction(Action action) {
    selectedAction = action;
  }

  Button initSimulateButton() {
    return initIconButton("simulatePlayButton", new ControlListener() {
      public void controlEvent(ControlEvent event) {
        if (event.getName().equals("simulatePlayButton")) {
          page.state.clickSimulate();
        }
      }
    }, simulateIcon, LARGE_ICON_SIZE);
  }
  
  Button initPlayButton() {
    return initIconButton("playToggle", new ControlListener() {
      public void controlEvent(ControlEvent event) {
        if (event.getName().equals("playToggle")) {
          page.state.clickPlay();
        }
      }
    }, playIcon, LARGE_ICON_SIZE);
  }

  Button initAddMotorButton() {
    return initIconButton("addMotor", new ControlListener() {
      public void controlEvent(ControlEvent event) {
        if (!page.state.canModify()) return;
        if (event.getName().equals("addMotor")) {
          if (motors.size() < MAX_MOTORS) motors.add(new Motor(motors.size()));
        }
      }
    }, plusIcon, ICON_SIZE);
  }

  void loopPlayState() {
    for (Motor motor : motors) {
      motor.loopPlayState();
    }
  }

  void reset() {
    page.selectedAction = null;
    timeManager.resetTime();
    for (Motor motor : motors) {
      osc_send_speed(0, motor.getId());
      motor.reset();
    }
  }
  
  Button initResetButton() {
    return initIconButton("reset", new ControlListener() {
      public void controlEvent(ControlEvent event) {
        if (event.getName().equals("reset")) {
          page.state.clickReset();
        }
      }
    }, resetIcon, LARGE_ICON_SIZE);
  }
  
  Button initSaveButton() {
    return initIconButton("SaveJSON", new ControlListener() {
      public void controlEvent(ControlEvent event) {
        if (event.getName().equals("SaveJSON")) {
          try {
            saveJSONObject(page.toJSON(), FILE_NAME);
            println("Sequence saved to " + FILE_NAME);
          } catch (Exception e) {
            println("Error saving file: ");
            e.printStackTrace();
          }
        }
      }
    }, saveIcon, ICON_SIZE);
  }
  
  Button initLoadButton() {
    return initIconButton("LoadJSON", new ControlListener() {
      public void controlEvent(ControlEvent event) {
        if (event.getName().equals("LoadJSON")) {
          try {
            page.loadPageJSON(loadJSONObject(FILE_NAME));
            println("Sequence loaded from " + FILE_NAME);
          } catch (Exception e) {
            println("Error loading file: ");
            e.printStackTrace();
          }
        }
      }
    }, loadIcon, ICON_SIZE);
  }

  boolean hitIndividualMotor(int n) {
    if (n >= this.motors.size()) return false;
    selectedMotor = this.motors.get(n);
    if (selectedMotor.actions.size() > 0) {
      if (selectedMotor.playIndividual) {
        selectedMotor.reset();
        osc_send_speed(0, selectedMotor.getId());
      } else {
        selectedMotor.playIndividual = true;
      }
      return true;
    }
    return false;
  }
  
  void drawHorizontalLines() {
    stroke(getBlack());
    strokeWeight(1);
    float y = TOP_GAP;
    for (int i = 0; i < MAX_MOTORS; i++) {
      line(0, y, width, y);
      y += ROW_HEIGHT;
      line(0, y, width, y);
      y += ROW_GAP;
    }
  }
  
  void drawVerticalLines() {
    stroke(getBlack());
    float y = TOP_GAP;
    
    for (int i = 0; i < MAX_MOTORS; i++) {
      line(MOTOR_COL_WIDTH, y, MOTOR_COL_WIDTH, y + ROW_HEIGHT);
      line(ACTION_START_X, y, ACTION_START_X, y + ROW_HEIGHT);
      y += ROW_GAP + ROW_HEIGHT;
    }
  }

  void setChildrenXY() {
    for (Motor motor : motors) {
      motor.setXY(0, motor.getId() * (ROW_HEIGHT + ROW_GAP) + TOP_GAP);
    }
  }
  void drawChildren() {
    motors.forEach(motor -> motor.draw());
  }

  void drawTitles() {
    fill(getBlack());
    useTitleFont();
    textAlign(CENTER, CENTER);
    text("Status", x + MOTOR_COL_WIDTH + STATUS_COL_WIDTH / 2,TOP_GAP / 2);
  }
  void drawMotorEditButtons() {
    addMotorButton.setPosition((MOTOR_COL_WIDTH - ICON_SIZE) / 2, TOP_GAP + motors.size() * (ROW_HEIGHT + ROW_GAP) + (ROW_HEIGHT - ICON_SIZE) / 2);
    if (motors.size() >= 4) {
      addMotorButton.hide();
    } else {
      addMotorButton.show();
    }
  }
  void drawInstructions() {
    float insX = 30;
    textAlign(LEFT, CENTER);
    useInsFont();
    fill(getBlack());
    text("Click to select an action. Arrow keys to reorder. Scroll to change speed", insX, BOTTOM_CENTER_Y - 40);
    text("Drag the right side of selected action to change duration", insX, BOTTOM_CENTER_Y - 20);
    text("For each motor, you can toggle displays of RPM and Torque and rotate through Flywheel setup", insX, BOTTOM_CENTER_Y);
    text("[Space] to play/pause, [R] to reset, [C] to copy a motor's actions, [V] to paste", insX, BOTTOM_CENTER_Y + 20);
    text("Increase Gyro force with bigger/more flywheels", insX, BOTTOM_CENTER_Y + 40);
  }

  void drawControlButtons() {
    float iconY = BOTTOM_CENTER_Y - LARGE_ICON_SIZE / 2;
    float centerIconX = width / 2 - LARGE_ICON_SIZE * 0.5;
    simulateButton.setPosition(centerIconX - LARGE_ICON_SIZE * 1.5, iconY);
    playButton.setPosition(centerIconX, iconY);
    resetButton.setPosition(centerIconX + LARGE_ICON_SIZE * 1.5, iconY);

    textAlign(CENTER, CENTER);
    float labelY = iconY + LARGE_ICON_SIZE + ICON_LABEL_MARGIN;
    text("Simulate", centerIconX - LARGE_ICON_SIZE, labelY);
    text("Play/Pause", centerIconX + LARGE_ICON_SIZE / 2, labelY);
    text("Reset", centerIconX + LARGE_ICON_SIZE * 2, labelY);

    saveButton.setPosition(width - ICON_SIZE * 1.5, BOTTOM_CENTER_Y - ICON_SIZE - 15);
    text("Save", width - ICON_SIZE * 1.5 + ICON_SIZE / 2, BOTTOM_CENTER_Y - 15 + ICON_LABEL_MARGIN);
    loadButton.setPosition(width - ICON_SIZE * 1.5, BOTTOM_CENTER_Y + 10);
    text("Load", width - ICON_SIZE * 1.5 + ICON_SIZE / 2, BOTTOM_CENTER_Y + ICON_SIZE + 10 + ICON_LABEL_MARGIN);
  }

  void drawPopup() {
    if (this.popupText == null) return;
    textAlign(CENTER, CENTER);
    useTitleFont();
    fill(getWhite());
    strokeWeight(3);
    rect((width - POPUP_WIDTH) / 2, (height - POPUP_HEIGHT) / 2, POPUP_WIDTH, POPUP_HEIGHT);
    fill(getBlack());
    strokeWeight(1);
    text(this.popupText, width / 2, height / 2);
    this.popupCountdown -= 1;
    if (this.popupCountdown <= 0) this.popupText = null;
  }

  void drawSelf() {
    drawTitles();
    drawMotorEditButtons();
    drawTimeline();
    actionControl.draw();
    drawInstructions();
    drawHorizontalLines();
    drawVerticalLines();
    drawControlButtons();

    drawPopup();
  }

  void execute() {
    for (Motor motor : motors) {
      motor.execute();
    }
  }

  void executeIndividually() {
    for (Motor motor : motors) {
      if (motor.playIndividual) motor.execute();
    }
  }

  void simulate() {
   for (Motor motor : motors) {
      motor.simulate();
    } 
  }
  
  JSONObject toJSON() {
    JSONObject json = new JSONObject();
    json.setString("name", name);
    JSONArray motorsJSON = new JSONArray();
    for (int i = 0; i < motors.size(); i++) {
      motorsJSON.setJSONObject(i, motors.get(i).toJSON());
    }
    json.setJSONArray("motors", motorsJSON);
    return json;
  }

  Motor loadMotorJSON(JSONObject json, int id) {
    Motor motor = new Motor(id);
    JSONArray actionsJSON = json.getJSONArray("actions");
    for (int i = 0; i < actionsJSON.size(); i++) {
      JSONObject actionJSON = actionsJSON.getJSONObject(i);
      motor.insertAction(loadActionJSON(actionJSON), i);
    }
    return motor;
  }

  void loadPageJSON(JSONObject json) {
    this.reset();
    for (Motor motor : this.motors) {
      motor.drawer.clear();
    }
    this.motors.clear();
    JSONArray motorsJSON = json.getJSONArray("motors");
    for (int i = 0; i < motorsJSON.size(); i++) {
      JSONObject motorJSON = motorsJSON.getJSONObject(i);
      this.motors.add(this.loadMotorJSON(motorJSON, i));
    }
  }
}
