#include <Arduino.h>
#include "USB.h"
#include "USBHIDKeyboard.h"

namespace {
constexpr int kScannerRxPin = 18;
constexpr int kScannerTxPin = 17;
constexpr size_t kMaxBarcodeLength = 96;
constexpr unsigned long kScannerBaud = 9600;

HardwareSerial scanner(1);
USBHIDKeyboard keyboard;
String barcode;
bool invalidScan = false;

bool isAllowedBarcodeCharacter(char value) {
  return (value >= '0' && value <= '9') ||
         (value >= 'A' && value <= 'Z') ||
         (value >= 'a' && value <= 'z') ||
         value == '-' || value == '_' || value == '.' || value == '/';
}

void submitScan() {
  if (!invalidScan && !barcode.isEmpty()) {
    keyboard.print(barcode);
    keyboard.write(KEY_RETURN);
  }
  barcode = "";
  invalidScan = false;
}
}  // namespace

void setup() {
  barcode.reserve(kMaxBarcodeLength);
  scanner.begin(kScannerBaud, SERIAL_8N1, kScannerRxPin, kScannerTxPin);
  USB.begin();
  keyboard.begin();
}

void loop() {
  while (scanner.available() > 0) {
    const char value = static_cast<char>(scanner.read());
    if (value == '\r' || value == '\n') {
      submitScan();
    } else if (isAllowedBarcodeCharacter(value) &&
               barcode.length() < kMaxBarcodeLength) {
      barcode += value;
    } else {
      invalidScan = true;
    }
  }
}
