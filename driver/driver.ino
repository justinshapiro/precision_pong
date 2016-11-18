#include <Wire.h>

// Accelerometer addresses
#define MPU9150_ACCEL_XOUT_H       0x43   // R  0x3B is default and wrong 
#define MPU9150_ACCEL_XOUT_L       0x44   // R  0x3C is default and wrong
#define MPU9150_GYRO_XOUT_H        0x3B   // R  0x43 is default and wrong
#define MPU9150_GYRO_XOUT_L        0x3C   // R  0x44 is default and wrong
#define MPU9150_PWR_MGMT_1         0x6B   // R/W
#define MPU9150_PWR_MGMT_2         0x6C   // R/W

// Ultrasonic sensor pin modes
#define trigPin 13
#define echoPin 12

// Accelerometer globals
int MPU9150_I2C_ADDRESS = 0x68; // try 0x69 if 0x68 doesn't work
int cmps[3];
int accl[3];
int gyro[3];
int temp;

bool no_jump = false;
int last_largest_dist = 0;

// Filter globals
short sampleSize = 0; // Size for array acess
const short MAXSAMPLE = 1, MAXRANGE = 480, MINRANGE = 100; // Set ranges
short Samples[MAXSAMPLE]; // Array for sample collection

void setup() {
  // Initialize the Serial Bus for printing data.
  Serial.begin (9600);

  // Initialize the 'Wire' class for the I2C-bus.
  Wire.begin();

  // Clear the 'sleep' bit to start the sensor.
  MPU9150_writeSensor(MPU9150_PWR_MGMT_1, 0);

  // Set pinModes for the Ultrasonic Sensor
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
}

void loop() {
  short duration, distance, average = 0; // Distance vars

  sendUltrasonicData(duration, distance, average);
  //sendAccelerometerData();
  
  delay(20);
}

void sendUltrasonicData(short duration, short distance, short average) {
  TOP:
  digitalWrite(trigPin, LOW); 
  delayMicroseconds(2); 
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  duration = pulseIn(echoPin, HIGH);
  distance = (5 * duration) / 29.1; // convert duration to ms
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
    
    //Serial.print("&");
    Serial.print(average - MINRANGE); // Print the average sample  
    Serial.print("*");
  }
  else {
    //Serial.print("&");
    Serial.print(average - MINRANGE); // Print raw sample if Size == 0
    Serial.print("*");
  }
    
  if (sampleSize == MAXSAMPLE - 1) 
    sampleSize = 0; // Reset sampleSize
  else 
    ++sampleSize;
}

void sendAccelerometerData() {
  Serial.print("@");
  Serial.print(MPU9150_readSensor(MPU9150_ACCEL_XOUT_L,MPU9150_ACCEL_XOUT_H));
  Serial.print("#");
}

////////////////////////////////////////////////////////////
///////// I2C functions to get easier all values ///////////
////////////////////////////////////////////////////////////

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
