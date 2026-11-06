# Hardware reference

## Supported reference: ESP32-S3 USB barcode wedge

`esp32_s3_barcode_wedge/scanflow_barcode_wedge.ino` forwards scans from a
UART barcode reader to a computer as USB keyboard input. Connect the reader's
UART TX to ESP32-S3 GPIO 18 and UART RX to GPIO 17, and use a shared ground.
Configure the reader for 9600 baud, 8-N-1, and newline-terminated scans. Check
the module's electrical specifications and use a level shifter when needed;
do not connect a 5 V UART output directly to an ESP32-S3 GPIO.

The cashier must be signed in to the ScanFlow POS app and focus the
"Scan barcode or enter SKU" field. A valid scan is submitted with Enter and
resolved by the authenticated POS API against the business catalogue. This
firmware does not send prices, stock changes, payment results, credentials, or
network requests. It is an input peripheral, not a trusted device identity.

## Not implemented by this reference

This is not smart-trolley/RFID firmware and does not provide device enrollment,
device authentication, basket synchronization, payment processing, or exit
verification. Do not rely on it for loss prevention or inventory control.
Those workflows require a separate device API and authenticated device
provisioning. The sketch is a reference implementation and has not been
verified on physical hardware.

## Build

Use Arduino IDE or `arduino-cli` with the Espressif ESP32 board package. Select
an ESP32-S3 board with native USB OTG/USB-CDC enabled. The native
`USBHIDKeyboard`/TinyUSB interfaces are provided by the ESP32 Arduino core;
installing the board package is required before compiling. Test with a
non-production POS account and a test catalogue before connecting a scanner.
