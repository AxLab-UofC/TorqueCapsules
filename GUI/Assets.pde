PImage playIcon;
PImage playGreyIcon;
PImage pauseIcon;
PImage circleIcon;
PImage cwIcon;
PImage ccwIcon;
PImage cwTorqueIcon;
PImage ccwTorqueIcon;
PImage cwBigTorqueIcon;
PImage ccwBigTorqueIcon;
PImage plusIcon;
PImage resetIcon;
PImage minusIcon;
PImage saveIcon;
PImage loadIcon;
PImage onIcon;
PImage offIcon;
PImage trashIcon;
PImage simulateIcon;
PImage simulatePauseIcon;
PImage simulateGreyIcon;
PFont roboto14;
PFont roboto18;
PFont roboto12;
PFont roboto8;
ControlFont controlFont;
void loadMyFont() {
  roboto14 = createFont("./fonts/Roboto-Regular.ttf", 14);
  roboto18 = createFont("./fonts/Roboto-Regular.ttf", 18);
  roboto12 = createFont("./fonts/Roboto-Regular.ttf", 12);
  roboto8 = createFont("./fonts/Roboto-Regular.ttf", 8);
  controlFont = new ControlFont(roboto14, 14);
  useBodyFont();
}
void loadIcons() {
  playIcon = loadImage("./icons/play.png");
  playIcon.resize(LARGE_ICON_SIZE, LARGE_ICON_SIZE);
  playGreyIcon = loadImage("./icons/play-grey.png");
  playGreyIcon.resize(LARGE_ICON_SIZE, LARGE_ICON_SIZE);
  pauseIcon = loadImage("./icons/pause.png");
  pauseIcon.resize(LARGE_ICON_SIZE, LARGE_ICON_SIZE);
  circleIcon = loadImage("./icons/circle.png");
  circleIcon.resize(LARGE_ICON_SIZE, LARGE_ICON_SIZE);
  cwIcon = loadImage("./icons/cw.png");
  cwIcon.resize(LARGE_ICON_SIZE, LARGE_ICON_SIZE);
  cwTorqueIcon = loadImage("./icons/cw-torque.png");
  cwTorqueIcon.resize(ICON_SIZE, ICON_SIZE);
  ccwTorqueIcon = loadImage("./icons/ccw-torque.png");
  ccwTorqueIcon.resize(ICON_SIZE, ICON_SIZE);
  cwBigTorqueIcon = loadImage("./icons/cw-torque.png");
  cwBigTorqueIcon.resize(LARGE_ICON_SIZE, LARGE_ICON_SIZE);
  ccwBigTorqueIcon = loadImage("./icons/ccw-torque.png");
  ccwBigTorqueIcon.resize(LARGE_ICON_SIZE, LARGE_ICON_SIZE);
  ccwIcon = loadImage("./icons/ccw.png");
  ccwIcon.resize(LARGE_ICON_SIZE, LARGE_ICON_SIZE);
  plusIcon = loadImage("./icons/plus.png");
  plusIcon.resize(ICON_SIZE, ICON_SIZE);
  resetIcon = loadImage("./icons/reset.png");
  resetIcon.resize(LARGE_ICON_SIZE, LARGE_ICON_SIZE);
  minusIcon = loadImage("./icons/minus.png");
  minusIcon.resize(SMALL_ICON_SIZE, SMALL_ICON_SIZE);
  saveIcon = loadImage("./icons/save.png");
  saveIcon.resize(ICON_SIZE, ICON_SIZE);
  loadIcon = loadImage("./icons/upload.png");
  loadIcon.resize(ICON_SIZE, ICON_SIZE);
  onIcon = loadImage("./icons/on.png");
  onIcon.resize(ICON_SIZE, ICON_SIZE);
  offIcon = loadImage("./icons/off.png");
  offIcon.resize(ICON_SIZE, ICON_SIZE);
  trashIcon = loadImage("./icons/trash.png");
  trashIcon.resize(SMALL_ICON_SIZE, SMALL_ICON_SIZE);
  simulateIcon = loadImage("./icons/preview.png");
  simulateIcon.resize(LARGE_ICON_SIZE, LARGE_ICON_SIZE);
  simulatePauseIcon = loadImage("./icons/preview-pause.png");
  simulatePauseIcon.resize(LARGE_ICON_SIZE, LARGE_ICON_SIZE);
  simulateGreyIcon = loadImage("./icons/preview-grey.png");
  simulateGreyIcon.resize(LARGE_ICON_SIZE, LARGE_ICON_SIZE);
}