#define trigPin 13
#define echoPin 12

short sampleSize = 0; // Size for array acess
const short MAXSAMPLE = 15, MAXRANGE = 460, MINRANGE = 100; // Set ranges
short Samples[MAXSAMPLE]; // Array for sample collection

void setup() {
  
  Serial.begin (9600); // Set baud rate
  pinMode(trigPin, OUTPUT); // Outgoing pin
  pinMode(echoPin, INPUT); // Incoming pin
  
}

void loop() {
  
  short duration, distance, average = 0; // Distance vars

  TOP:
  
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH);
  distance = (5 * duration) / 29.1; // Get distance in MM

  Samples[sampleSize] = distance;
  average = distance;

  if (Samples[sampleSize] >= MAXRANGE) { Samples[sampleSize] = 0; goto TOP; }
  else if (Samples[sampleSize] <= MINRANGE) { Samples[sampleSize] = 0; goto TOP; }

  if (sampleSize != 0){
  
  average = 0; // Clear average
  for (short inc = 0; inc < sampleSize; ++inc){ average += Samples[inc]; } // Add all samples
  average = average / sampleSize; // Get average sample by divisions
  Serial.println(average); // Print the average sample

  }
  
  else Serial.println(average); // Print raw sample if Size == 0
  
  if (sampleSize == MAXSAMPLE - 1) sampleSize = 0; // Reset sampleSize
  else ++sampleSize;
  
  delay(100);
  
}

