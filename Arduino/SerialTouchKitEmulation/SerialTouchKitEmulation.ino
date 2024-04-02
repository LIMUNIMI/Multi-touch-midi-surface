void setup() {
  Serial.begin(115200);

}

int arr1[4] = {0,0,0,0};
int arr2[4] = {1,0,0,0};
int arr3[4] = {2,0,0,0};


void printArr(int arr[4]) {
  Serial.print(arr[0]);
  Serial.print(',');
  Serial.print(arr[1]);
  Serial.print(',');
  Serial.print(arr[2]);
  Serial.print(',');
  Serial.print(arr[3]);
  Serial.println();
}

void loop() {
  
  for (int i = 1; i<4; i++) {
    if (i != 1) {
      arr1[i-1] = 0;
    }
    arr1[i] = 1;
    delay(500);
    printArr(arr1);
    printArr(arr2);
    printArr(arr3);
  }

  arr1[3] = 0;
  arr2[3] = 1;
  printArr(arr1);
  printArr(arr2);
  printArr(arr3);
  delay(500);

  arr2[3] = 0;
  arr3[3] = 1;
  printArr(arr1);
  printArr(arr2);
  printArr(arr3);
  delay(500);
  
  arr3[3] = 0;
  arr3[2] = 1;
  printArr(arr1);
  printArr(arr2);
  printArr(arr3);
  delay(500);

  arr3[2] = 0;
  arr3[1] = 1;
  printArr(arr1);
  printArr(arr2);
  printArr(arr3);
  delay(500);

  arr3[1] = 0;
  arr2[2] = 1;
  printArr(arr1);
  printArr(arr2);
  printArr(arr3);
  delay(500);

  arr2[2] = 0;
  printArr(arr1);
  printArr(arr2);
  printArr(arr3);
  delay(500);


}
