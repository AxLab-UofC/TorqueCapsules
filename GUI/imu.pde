class MotorIMU {
    float accX;
    float accY;
    float accZ;
    float gyrX;
    float gyrY;
    float gyrZ;

    MotorIMU() {
       this.accX = 0;
       this.accY = 0;
       this.accZ = 0;
       this.gyrX = 0;
       this.gyrY = 0;
       this.gyrZ = 0;
    }
        
    float getAccX() {
        return accX;
    }
    
    float getAccY() {
        return accY;
    }

    float getAccZ() {
        return accZ;
    }

    float getGyrX() {
        return gyrX;
    }

    float getGyrY() {
        return gyrY;
    }

    float getGyrZ() {
        return gyrZ;
    }
}