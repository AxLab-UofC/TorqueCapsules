// Import necessary libraries
import controlP5.*;
import java.util.*;
import java.io.*;
import java.time.*;
import oscP5.*;
import netP5.*;
import processing.core.*;
import processing.data.*;  // add this line if Cannot find a class or type named 'JSONObject'
import processing.event.*;  // add this line if Cannot find a class or type named 'mouseEvent'
//  add 'public' modifier to the return type if Cannot find a class or type named 'Overridepublic'


// OSC
final int MAX_MOTORS = 4;

final int SCREEN_WIDTH = 1400;
final int SCREEN_HEIGHT = 810;
final int FPS = 60;

int OSC_PORT_IN = 5004; // declare 1 port in for receiving OSC messages. Messages will be differentiated by keywords
int[] OSC_PORTS_OUT = {5005, 5006, 5007, 5008};  
// declare 2+ ports out for sending messages to Python programs
// in Python program 0, create an osc server that listens on 5005. In Python program 1, create an osc server that listens on 5006.

OscP5 server;  // declare osc server
NetAddress[] clientAddresses = new NetAddress[MAX_MOTORS];  // declare osc client addresses

// Each motor object in Processing corresponds to a unique client address, Python program, and Seeed board.
// Go to osc.pde for more OSC functions
// Go to addSpeedModule & addBrakeModule for OSC function calls

// UI controls and page objects
ControlP5 cp5;

Page page;
TimeManager timeManager;
void settings() {
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
}

void setup() {
  cp5 = new ControlP5(this);
  
  // Canvas configuration
  noStroke();
  background(220);
  
  // Initialize UI components
  loadIcons();
  loadMyFont();
  page = new Page("Untitled");
  timeManager = new TimeManager();
  
  // initialize OSC server & client addresses based on declared ports
  server = new OscP5(this, OSC_PORT_IN);
  for (int i = 0; i < MAX_MOTORS; i++) {
    clientAddresses[i] = new NetAddress("127.0.0.1", OSC_PORTS_OUT[i]);
  }
  
  frameRate(FPS);
}

void draw() {
  try {
    background(getWhite());
    page.draw();
    timeManager.updateTime();
  } catch(Exception err) {
    err.printStackTrace();
    exit();
  }
}
