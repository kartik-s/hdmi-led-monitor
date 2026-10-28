# hdmi-led-display
This is an FPGA design for the PYNQ-Z1 board that turns an HDMI input into a live display on addressable LED strips. It crops an 18 × 15 region from each incoming frame and streams those pixels over SPI to LED strips arranged in rows, forming a low-resolution monitor.

## Demo
https://github.com/user-attachments/assets/3c236088-f6e0-4645-a183-1dcea1df374d


## How to Build
1. Create the project:
```sh
vivado -mode batch -source scripts/create_project.tcl
```

2. Generate the bitstream:
```sh
vivado -mode batch -source scripts/build.tcl
```

3. Program the device:
```sh
vivado -mode batch -source scripts/program.tcl
```
