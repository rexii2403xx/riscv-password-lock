# RISC-V Memory-Mapped Password Lock System

## 1. Project Name

RISC-V Memory-Mapped Password Lock System

## 2. Development Board

* Digilent Basys 3 FPGA Board
* FPGA Device: Xilinx Artix-7 XC7A35T

## 3. Tool Versions

* Vivado 2025.2
* PicoRV32 RISC-V Core
* Verilog HDL

## 4. Project Structure

README.md
top.v
picorv32.v
basys3.xdc

## 5. Generate Bitstream

1. Open Vivado 2025.2.
2. Create a new RTL Project.
3. Add `top.v` and `picorv32.v`.
4. Add `basys3.xdc`.
5. Run Synthesis.
6. Run Implementation.
7. Generate Bitstream.

After successful compilation, a `.bit` file will be generated.

## 6. Modify RISC-V Program

The RISC-V program is stored in the ROM array inside `top.v`.

To modify the password or program behavior:

1. Edit the machine code values in the ROM array.
2. Save the file.
3. Re-run Synthesis.
4. Re-run Implementation.
5. Generate a new Bitstream.

## 7. Program FPGA Board

1. Connect the Basys 3 board to the PC using USB.
2. Open Vivado Hardware Manager.
3. Click **Open Target**.
4. Select **Auto Connect**.
5. Click **Program Device**.
6. Select the generated bitstream file.
7. Click **Program**.

The FPGA will start running immediately after programming.

## 8. Operation and Testing

### Password

Correct Password: `1010`

### Operation Steps

1. Set SW[3:0] to the desired value.
2. Press BTN to confirm.
3. The RISC-V CPU reads the switch value.
4. The CPU compares the input with the stored password.

### Expected Results

Correct Password:

* LED0 ON
* LED1 OFF
* Error Count Reset to 0

Wrong Password:

* LED0 OFF
* LED1 ON
* Error Count +1

The seven-segment display shows the accumulated error count.

## 9. Known Issues

* Password is currently fixed in ROM.
* Only one seven-segment digit is used.
* Maximum error count is limited to 9.
* Polling is used instead of interrupts.
* Password cannot be changed during runtime.

## 10. External Sources and License

### PicoRV32

Author: Clifford Wolf

Repository: https://github.com/YosysHQ/picorv32

License: ISC License

### Basys 3 Reference Manual

Digilent Inc.

### RISC-V Instruction Set Manual

RISC-V Foundation
