# hdmi-led-monitor
This is an FPGA design for the PYNQ-Z1 board that turns an HDMI input into a live display on addressable LED strips. It crops an 18 × 15 region from each incoming frame and streams those pixels over SPI to LED strips arranged in rows, forming a low-resolution monitor.

## Demo
The video shows an 18 × 15 WebGL animation playing on the LED display. The animation runs in the top-left corner of a laptop’s screen. The laptop sends its display over HDMI to the FPGA, which appears to it as an external monitor. The FPGA crops each frame to that top-left 18 × 15 region and streams the pixels to the LED strips.

https://github.com/user-attachments/assets/3c236088-f6e0-4645-a183-1dcea1df374d

## Design
<img width="2340" height="1090" alt="image" src="https://github.com/user-attachments/assets/efd5597b-c1e2-486f-9acb-c6423d5de7bb" />

The HDMI input goes to Digilent’s dvi2rgb IP, which outputs each frame as RGB pixel data along with a pixel clock and VSync and VDE timing signals. The frame_cropper module counts pixels using VDE, resets at each VSync, and keeps only the pixels in the top-left 18 × 15 corner of the frame. It passes those pixels to rgb2spi, which double-buffers them: one buffer fills in the pixel clock domain while the other drains as an SPI stream in the SPI clock domain. VSync is passed into the SPI clock domain through synchronizer, so the buffers swap cleanly at frame boundaries.

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
