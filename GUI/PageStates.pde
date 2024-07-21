interface PageState {
  void clickPlay();
  void clickSimulate();
  void clickReset();
  void hitSpace();
  void clickNumber(int n);
  void advanceTime();
  boolean canModify();
}
class DefaultState implements PageState {
  Page page;
  DefaultState(Page page) {
    this.page = page;
  }
  void clickPlay() {
    page.playButton.setImage(pauseIcon);
    page.simulateButton.setImage(simulateGreyIcon);
    page.setState(page.getRealPlayState());
    page.selectedAction = null;
  }
  void clickSimulate() {
    page.simulateButton.setImage(simulatePauseIcon);
    page.setState(page.getSimulatePlayState());
    page.playButton.setImage(playGreyIcon);
  }
  void clickReset() {}
  void hitSpace() {
    clickPlay();
  }
  void clickNumber(int n) {
    if (page.hitIndividualMotor(n - 1)) page.setState(page.getIndividualMotorState());
  }
  void advanceTime() {}
  boolean canModify() {
    return true;
  }
}
class RealPlayState implements PageState {
  Page page;
  RealPlayState(Page page) {
    this.page = page;
  }
  void clickPlay() {
    page.playButton.setImage(playIcon);
    page.setState(page.getRealPauseState());
    page.selectedAction = null;
  }
  void clickSimulate() {}
  void clickReset() {
    page.playButton.setImage(playIcon);
    page.simulateButton.setImage(simulateIcon);
    page.reset();
    page.setState(page.getDefaultState());
  }
  void hitSpace() {
    clickPlay();
  }
  void clickNumber(int n) {}
  void advanceTime() {
    timeManager.advanceTime();
    page.execute();
  }
  boolean canModify() {
    return false;
  }
}
class RealPauseState implements PageState {
  Page page;
  RealPauseState(Page page) {
    this.page = page;
  }
  void clickPlay() {
    page.playButton.setImage(pauseIcon);
    page.setState(page.getRealPlayState());
    page.selectedAction = null;
  }
  void clickSimulate() {}
  void clickReset() {
    page.reset();
    page.setState(page.getDefaultState());
    page.simulateButton.setImage(simulateIcon);
  }
  void hitSpace() {
    clickPlay();
  }
  void clickNumber(int n) {}
  void advanceTime() {}
  boolean canModify() {
    return true;
  }
}
class SimulatePlayState implements PageState {
  Page page;
  SimulatePlayState(Page page) {
    this.page = page;
  }
  void clickPlay() {}
  void clickSimulate() {
    page.simulateButton.setImage(simulateIcon);
    page.setState(page.getSimulatePauseState());
    page.selectedAction = null;
  }
  void clickReset() {
    page.reset();
    page.setState(page.getDefaultState());
    page.simulateButton.setImage(simulateIcon);
    page.playButton.setImage(playIcon);
  }
  void hitSpace() {
    clickSimulate();
  }
  void clickNumber(int n) {}
  void advanceTime() {
    timeManager.advanceTime();
    page.simulate();
  }
  boolean canModify() {
    return false;
  }
}
class SimulatePauseState implements PageState {
  Page page;
  SimulatePauseState(Page page) {
    this.page = page;
  }
  void clickPlay() {}
  void clickSimulate() {
    page.simulateButton.setImage(simulatePauseIcon);
    page.setState(page.getSimulatePlayState());
    page.selectedAction = null;
  }
  void clickReset() {
    page.reset();
    page.setState(page.getDefaultState());
    page.playButton.setImage(playIcon);
  }
  void hitSpace() {
    clickSimulate();
  }
  void clickNumber(int n) {}
  void advanceTime() {}
  boolean canModify() {
    return true;
  }
}
class IndividualMotorState implements PageState {
  Page page;
  IndividualMotorState(Page page) {
    this.page = page;
  }
  void clickPlay() {}
  void clickSimulate() {}
  void clickReset() {
    page.playButton.setImage(playIcon);
    page.simulateButton.setImage(simulateIcon);
    page.reset();
    page.setState(page.getDefaultState());;
  }
  void hitSpace() {}
  void clickNumber(int n) {
    page.hitIndividualMotor(n - 1);
  }
  void advanceTime() {
    timeManager.advanceIndividualMotors();
    page.executeIndividually();
  }
  boolean canModify() {
    return true;
  }
}