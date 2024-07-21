// manage time for grouped play/pause/reset/simulate
// for managing time for individual motors, see Motor
class TimeManager {
  TimeManager() {}
  float totalSeconds = 0;
  float currSeconds = 0;
  void updateTotalSeconds() {
    if (page.actionControl.durationSlider.locked) {
      return;
    }
    float longestSequence = 0;
    for (Motor motor : page.motors) {
      longestSequence = max(longestSequence, motor.getSequenceLength());
    }
    this.totalSeconds = longestSequence;
  }

  float getCurrSeconds() {
    return currSeconds;
  }

  float getTotalSeconds() {
    return totalSeconds;
  }

  float secondsToPixels(float time) {
    return time * (USABLE_WIDTH / max(ceil(totalSeconds) + 1, MIN_SECONDS));
  }
  float pixelsToSeconds(float pixels) {
    return pixels / (USABLE_WIDTH / max(ceil(totalSeconds) + 1, MIN_SECONDS));
  }
  
  void advanceTime() {
    float endTime = totalSeconds == 0 ? MIN_SECONDS : totalSeconds;
    float nextSeconds = currSeconds + (1 / frameRate);
    if (nextSeconds > endTime) {
      currSeconds = nextSeconds - endTime;
      page.loopPlayState();
    } else {
      currSeconds = nextSeconds;
    }
  }

  void advanceIndividualMotors() {
    for (Motor motor : page.motors) {
      if (motor.playIndividual) advanceIndividualMotor(motor);
    }
  }

  void advanceIndividualMotor(Motor motor) {
    float endTime = motor.getSequenceLength();
    float nextSeconds = motor.individualSeconds + (1 / frameRate);
    if (nextSeconds > endTime) {
      motor.individualSeconds = nextSeconds - endTime;
      motor.loopPlayState();
    } else {
      motor.individualSeconds = nextSeconds;
    }
  }

  void updateTime() {
    updateTotalSeconds();
    page.state.advanceTime();
  }

  void resetTime() {
    currSeconds = 0;
  }
}
