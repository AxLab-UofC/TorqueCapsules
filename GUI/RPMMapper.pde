class RPMMapper {
  JSONObject json;
  Map<String, Integer> cache = new HashMap<>();
  Map<String, Integer> maxRpmCache = new HashMap<>();
  RPMMapper(JSONObject json) {
    this.json = json;
  }
  String key(String fw, int speed) {
    return fw + "-" + speed;
  }
  int getMaxRPM(String fw){
    try {
      if (fw.equals("3fw")) fw = "lfw";
      if (maxRpmCache.containsKey(fw)) {
        return maxRpmCache.get(fw);
      }
      int max = 0;
      for (String speed: (Collection<String>)json.getJSONObject(fw).keys()) {
        int rpm = round(json.getJSONObject(fw).getFloat(speed));
        cache.put(key(fw, Integer.parseInt(speed)), rpm);
        max = max(max, rpm);
      }
      maxRpmCache.put(fw, max);
      return maxRpmCache.get(fw);
    } catch (Exception e) {
      println("Error getting max RPM for " + fw);
      e.printStackTrace();
      return 0;
    }
  }
  int getRPM(String fw, int speed) {
    try {
      if (fw.equals("3fw")) fw = "lfw";
      if (!cache.containsKey(key(fw, speed))){
        getMaxRPM(fw);
      }
      return cache.get(key(fw, speed));
    } catch (Exception e) {
      println("Error getting RPM for " + fw + " at speed " + speed);
      e.printStackTrace();
      return 0;
    }
  }
}
