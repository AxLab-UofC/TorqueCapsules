/********************************************************************************
Controls a single motor with serial communication.
Only support instant basic control:
1. speed & direction
2. brake

To use:
1. Change `MotorPins motor` according to your Arduino pin configuration
2. Send string to serial 
  * '-256' means brake
  * any number between -255, 255 means speed
  * sign indicates direction

********************************************************************************/

// Function to control a motor

void processMotorCmds(uint8_t dir_flag, uint8_t speed) {
  if (dir_flag == 1 && speed == 0) {
    Serial.println("CMD >>>>>>      brake");
    digitalWrite(motor.brakePin, LOW);
    digitalWrite(LED_RED, LOW);
    digitalWrite(LED_GREEN, HIGH);

  } else {
    digitalWrite(motor.brakePin, HIGH);
    bool dir = (bool) dir_flag;
    digitalWrite(motor.dirPin, -dir);
    analogWrite(motor.speedPin, speed);
    Serial.print("CMD >>>>>>     speed  ");
    Serial.println(speed);
    digitalWrite(LED_RED, HIGH);
    digitalWrite(LED_GREEN, LOW);
  }
}