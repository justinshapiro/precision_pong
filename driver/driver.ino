#include <Wire.h>

// Accelerometer addresses
#define MPU9150_ACCEL_XOUT_H       0x43   // R  0x3B is default and wrong 
#define MPU9150_ACCEL_XOUT_L       0x44   // R  0x3C is default and wrong
#define MPU9150_ACCEL_YOUT_H       0x45   // R  0x3d is default and wrong
#define MPU9150_ACCEL_YOUT_L       0x46   // R  0x3E is default and wrong
#define MPU9150_GYRO_XOUT_H        0x3B   // R  0x43 is default and wrong
#define MPU9150_GYRO_XOUT_L        0x3C   // R  0x44 is default and wrong
#define MPU9150_GYRO_YOUT_H        0x3D   // R  0x45 is default and wrong
#define MPU9150_GYRO_YOUT_L        0x3E   // R  0x46 is default and wrong
#define MPU9150_PWR_MGMT_1         0x6B   // R/W
#define MPU9150_PWR_MGMT_2         0x6C   // R/W

// Ultrasonic sensor pin modes
#define trigger 13
#define echo 12

// Accelerometer globals
int MPU9150_I2C_ADDRESS = 0x68; // try 0x69 if 0x68 doesn't work
int cmps[3];
int accl[3];
int gyro[3];

// Filter globals
short sampleSize = 0; // Size for array acess
const short MAXSAMPLE = 1, MAXRANGE = 480, MINRANGE = 100; // Set ranges
short Samples[MAXSAMPLE]; // Array for sample collection

void setup() {
  // Initialize the serial bus for printing data
  Serial.begin(9600);

  // Initialize accelerometer
  Wire.begin();
  MPU9150_writeSensor(MPU9150_PWR_MGMT_1, 0);

  // Set pin modes for the Ultrasonic Sensor
  pinMode(trigger, OUTPUT);
  pinMode(echo, INPUT);
}

void loop() {
  // Send data to Processing
  Serial.print(getData());  

  // Synchronize with Processing's frame rate
  delay(20);
}

String getData() {
  String data_str = "";
  short duration = 0, distance = 0, average = 0;
  
  TOP:
  digitalWrite(trigger, LOW); 
  delayMicroseconds(2); // do not remove
  digitalWrite(trigger, HIGH);
  delayMicroseconds(10); // do not remove
  digitalWrite(trigger, LOW);
  
  duration = pulseIn(echo, HIGH);
  distance = (5 * duration) / 29.1; // convert duration to mm
  
  Samples[sampleSize] = distance;
  average = distance;

  if (Samples[sampleSize] >= MAXRANGE) { 
    Samples[sampleSize] = 0; 
    goto TOP; 
  }
  else if (Samples[sampleSize] <= MINRANGE) { 
    Samples[sampleSize] = 0; 
    goto TOP; 
  }

  if (sampleSize != 0) {
    average = 0; // Clear average
  
    // Add all samples
    for (short inc = 0; inc < sampleSize; ++inc)
      average += Samples[inc]; 
    
    average = average / sampleSize; // Get average sample by divisions
    
    data_str = String(average - MINRANGE) + "*" + getAccelerometerData() + "#";
  }
  else 
    data_str = String(average - MINRANGE) + "*" + getAccelerometerData() + "#";
    
  if (sampleSize == MAXSAMPLE - 1) 
    sampleSize = 0; // Reset sampleSize
  else 
    ++sampleSize;

  return data_str;
}

String getAccelerometerData() {
  String accel_data = String(MPU9150_readSensor(MPU9150_ACCEL_XOUT_L,MPU9150_ACCEL_XOUT_H)) + "&" +
                      String(MPU9150_readSensor(MPU9150_ACCEL_YOUT_L,MPU9150_ACCEL_YOUT_H));
  return accel_data;
}

// All functions below are for getting accelerometer data
int MPU9150_readSensor(int addrL, int addrH){
  Wire.beginTransmission(MPU9150_I2C_ADDRESS);
  Wire.write(addrL);
  Wire.endTransmission(false);

  Wire.requestFrom(MPU9150_I2C_ADDRESS, 1, true);
  byte L = Wire.read();

  Wire.beginTransmission(MPU9150_I2C_ADDRESS);
  Wire.write(addrH);
  Wire.endTransmission(false);

  Wire.requestFrom(MPU9150_I2C_ADDRESS, 1, true);
  byte H = Wire.read();

  return (int16_t)((H<<8)+L);
}

int MPU9150_readSensor(int addr){
  Wire.beginTransmission(MPU9150_I2C_ADDRESS);
  Wire.write(addr);
  Wire.endTransmission(false);

  Wire.requestFrom(MPU9150_I2C_ADDRESS, 1, true);
  return Wire.read();
}

int MPU9150_writeSensor(int addr,int data){
  Wire.beginTransmission(MPU9150_I2C_ADDRESS);
  Wire.write(addr);
  Wire.write(data);
  Wire.endTransmission(true);

  return 1;
}
