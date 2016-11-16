#include <Wire.h>

#define MPU9150_ACCEL_XOUT_H       0x43   // R  0x3B is default and wrong 
#define MPU9150_ACCEL_XOUT_L       0x44   // R  0x3C is default and wrong

#define MPU9150_GYRO_XOUT_H        0x3B   // R  0x43 is default and wrong
#define MPU9150_GYRO_XOUT_L        0x3C   // R  0x44 is default and wrong

#define MPU9150_PWR_MGMT_1         0x6B   // R/W
#define MPU9150_PWR_MGMT_2         0x6C   // R/W

// try 0x69 if 0x68 doesn't work
int MPU9150_I2C_ADDRESS = 0x68;

int cmps[3];
int accl[3];
int gyro[3];
int temp;

void setup() {
  // Initialize the Serial Bus for printing data.
  Serial.begin(115200);

  // Initialize the 'Wire' class for the I2C-bus.
  Wire.begin();

  // Clear the 'sleep' bit to start the sensor.
  MPU9150_writeSensor(MPU9150_PWR_MGMT_1, 0);

  //MPU9150_setupCompass();   
}

void loop() {  
  Serial.print(MPU9150_readSensor(MPU9150_ACCEL_XOUT_L,MPU9150_ACCEL_XOUT_H));
  Serial.print("  ");
  Serial.println();
  delay(100);
  }
  //Serial.println("");      // prints another carriage return


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
