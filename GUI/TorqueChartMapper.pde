class TorqueChartMapper {
  JSONObject json;
  Map<String, float[][]> cache = new HashMap<>();
  Map<String, Float> maxTorqueCache = new HashMap<>();
  TorqueChartMapper(JSONObject json) {
    this.json = json;
  }
  float getMaxTorque(String fw) {
    return 0.26;
    // decided to use the biggest one, which is pretty static and can be hardcoded
    // if (fw.equals("3fw")) fw = "lfw";
    // if (maxTorqueCache.containsKey(fw)) {
    //   return maxTorqueCache.get(fw);
    // }
    // float max = 0;
    // JSONObject byBehaviors = json.getJSONObject(fw);
    // for (String behavior : (Collection<String>)byBehaviors.keys()) {
    //   JSONObject byModes = byBehaviors.getJSONObject(behavior);
    //   for (String range : (Collection<String>)byModes.keys()) {
    //     JSONObject byRanges = byModes.getJSONObject(range);
    //     JSONObject data = byRanges.getJSONArray("datasets").getJSONObject(0);
    //     if (data.getFloat("duration") <= 0.0) {
    //       continue;
    //     }
    //     max = max(max, abs(data.getFloat("max_torque")));
    //   }
    // }
    // maxTorqueCache.put(fw, ceilToDecimalPlace(max, 2));
    // return maxTorqueCache.get(fw);
  }
  float[][] getTimeToTorque(String fw, String type, String change) {
     try {
      if (fw.equals("3fw")) fw = "lfw";
      String key = fw + "-" + type + "-" + change;
      if (!cache.containsKey(key)) {
        JSONObject measured = json.getJSONObject(fw).getJSONObject(type);
        if (!measured.hasKey(change)) {
          cache.put(key, null);
          return null;
        }
        JSONObject data = measured
          .getJSONObject(change)
          .getJSONArray("datasets")
          .getJSONObject(0)
          .getJSONObject("data");
        float[] timestamps = data.getJSONArray("timestamps").toFloatArray();
        float[] torque = data.getJSONArray("torques").toFloatArray();
        float[][] timeToTorque = new float[timestamps.length][2];
        for (int i = 0; i < timestamps.length; i++) {
          timeToTorque[i][0] = timestamps[i];
          timeToTorque[i][1] = torque[i];
        }
        cache.put(key, timeToTorque);
      }
      return cache.get(key);
    } catch (Exception e) {
      println("Error getting time to torque for " + fw + " " + type + " " + change);
      e.printStackTrace();
      return null;
    }
  }
}
