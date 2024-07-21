
// // Function to be called when speed button is pressed
// // Send speed command to Python
// public void Run() {
//   // osc send speed messages
//   // receives speed & the client address (corresponds to Python program 0, 1, etc.) the speed command should be sent to 
//   int speed = int(cp5.getController("speed").getValue());
//   OscMessage message = new OscMessage("/speed");  // create an OSC message with keyword
//   message.add(speed);  // attach the value
//   server.send(message, clientAddresses[page.activeMotorIndex]);  // sends OSC message
// }

// // Function to be called when brake button is pressed
// // Send brake command to python
// public void Brake() {
//   // osc send brake messages
//   // receives the client address (corresponds to Python program 0, 1, etc.) the speed command should be sent to 
//   OscMessage message = new OscMessage("/brake");  // create an OSC message with keyword
//   message.add(1); // You can replace 1 with any value you prefer for brake command
//   server.send(message, clientAddresses[page.activeMotorIndex]); // sends OSC message
// }

void osc_send_speed(int speed, int motor_idx) {
  println("sending", speed, "to", motor_idx);
  OscMessage message = new OscMessage("/speed");  // create an OSC message with keyword
  message.add(speed);  // attach the value
  server.send(message, clientAddresses[motor_idx]);  // sends OSC message
}

void osc_send_brake(int motor_idx) {
  println("sending brake to", motor_idx);
  OscMessage message = new OscMessage("/brake");  // create an OSC message with keyword
  message.add(1); // You can replace 1 with any value you prefer for brake command
  server.send(message, clientAddresses[motor_idx]); // sends OSC message
}

void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/imu0")==true) {  // keyword 'imu0' corresponds to Python program 0 & Motor 0
   if (theOscMessage.checkTypetag("ffffff")) {   
    Motor motor = page.motors.get(0);
    motor.imu.accX = theOscMessage.get(0).floatValue();
    motor.imu.accY = theOscMessage.get(1).floatValue();
    motor.imu.accZ = theOscMessage.get(2).floatValue();
    motor.imu.gyrX = theOscMessage.get(3).floatValue();
    motor.imu.gyrY = theOscMessage.get(4).floatValue();
    motor.imu.gyrZ = theOscMessage.get(5).floatValue();
    println("received osc imu from motor 1");
   return;
   }  
 } else if (theOscMessage.checkAddrPattern("/imu1")==true) {  // keyword 'imu1' corresponds to Python program 1 & Motor 1
   if (theOscMessage.checkTypetag("ffffff")) {   
    Motor motor = page.motors.get(1);
    motor.imu.accX = theOscMessage.get(0).floatValue();
    motor.imu.accY = theOscMessage.get(1).floatValue();
    motor.imu.accZ = theOscMessage.get(2).floatValue();
    motor.imu.gyrX = theOscMessage.get(3).floatValue();
    motor.imu.gyrY = theOscMessage.get(4).floatValue();
    motor.imu.gyrZ = theOscMessage.get(5).floatValue();
   println("received osc imu from motor 2");
   return;
   }  
 } else if (theOscMessage.checkAddrPattern("/imu2")==true) {  // keyword 'imu1' corresponds to Python program 2 & Motor 2
   if (theOscMessage.checkTypetag("ffffff")) {   
    Motor motor = page.motors.get(2);
    motor.imu.accX = theOscMessage.get(0).floatValue();
    motor.imu.accY = theOscMessage.get(1).floatValue();
    motor.imu.accZ = theOscMessage.get(2).floatValue();
    motor.imu.gyrX = theOscMessage.get(3).floatValue();
    motor.imu.gyrY = theOscMessage.get(4).floatValue();
    motor.imu.gyrZ = theOscMessage.get(5).floatValue();
   println("received osc imu from motor 2");
   return;
   }  
 } else if (theOscMessage.checkAddrPattern("/imu3")==true) {  // keyword 'imu1' corresponds to Python program 3 & Motor 3
   if (theOscMessage.checkTypetag("ffffff")) {   
    Motor motor = page.motors.get(3);
    motor.imu.accX = theOscMessage.get(0).floatValue();
    motor.imu.accY = theOscMessage.get(1).floatValue();
    motor.imu.accZ = theOscMessage.get(2).floatValue();
    motor.imu.gyrX = theOscMessage.get(3).floatValue();
    motor.imu.gyrY = theOscMessage.get(4).floatValue();
    motor.imu.gyrZ = theOscMessage.get(5).floatValue();
   println("received osc imu from motor 2");
   return;
   }  
 }
 println("Received an unknown OSC message.");
}