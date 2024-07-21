float roundToDecimalPlace(float num, int decimal) {
  return toDecimalPlace(num, decimal, 0);
}

float floorToDecimalPlace(float num, int decimal) {
  return toDecimalPlace(num, decimal, 1);
}

float ceilToDecimalPlace(float num, int decimal) {
  return toDecimalPlace(num, decimal, 2);
}

float toDecimalPlace(float num, int decimal, int method) {
  int rounder = int(pow(10, decimal));
  switch (method) {
    case 0:
      return round(num * rounder) / (float)rounder;
    case 1:
      return floor(num * rounder) / (float)rounder;
    case 2:
      return ceil(num * rounder) / (float)rounder;
    default:
      return round(num * rounder) / (float)rounder; 
  }
}

Button initIconButton(String name, ControlListener listener, PImage icon, int iconSize) {
  return cp5.addButton(name).addListener(listener)
    .setPosition(-200, -200)
    .setImage(icon)
    .setSize(iconSize, iconSize);
}

Button initTextButton(String name, ControlListener listener, String caption, int width, int height) {
  return cp5.addButton(name).addListener(listener)
    .setPosition(-200, -200)
    .setCaptionLabel(caption)
    .setSize(width, height)
    .setFont(controlFont);
}

color getBlack() {
  return color(#151515);
}
color getWhite() {
  return color(#f7f7ff);
}
color getGrey() {
  return color(#646464);
}
color getLightGrey() {
  return color(#5D737E);
}
color getRed() {
  return color(#EA526F);
}
color getLightRed() {
  return color(#EE7C92);
}
color getBlue() {
  return color(#279AF1);
}
color getYellow() {
  return color(#FFBC42);
}
color getGreen() {
  return color(#7FB069);
}
color getCWColor() {
  return getBlue();
}
color getCCWColor() {
  return getYellow();
}
color getTorqueYAxisColor() {
  return color(#53599A);
}
color getRPMYAxisColor() {
  return color(#D5A021);
}

void useTitleFont() {
  textFont(roboto18);
}
void useBodyFont() {
  textFont(roboto14);
}
void useInsFont() {
  textFont(roboto12);
}
void useTicksFont() {
  textFont(roboto8);
}