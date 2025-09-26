# vhdl-single-octave-keyboard
EE221 Fall 2024 Semester Mini Project

# Single-Octave Keyboard (VHDL) — Altera DE1-SoC

**Top entity:** `octave1`  
**Purpose:** Drive a piezo buzzer with a musical tone selected by slide switches and show the note/frequency on four 7-segment displays.

## What it does
- Reads `SW[7:0]` and selects the **highest-priority** asserted switch (7 highest → 0 lowest).
- Generates a square wave on `buzzer` at the mapped note frequency.
- When no switches are on, output is silent and displays are blank.
- Shows the **note letter** on `seg7_0` and the **frequency (Hz)** as three decimal digits on `seg7_1..seg7_3`.
- `resetn` (active-low) clears the counter and silences output until released.

## I/O (logical roles)
- **Inputs:**  
  - `clk` — 50 MHz system clock  
  - `resetn` — active-low reset  
  - `switch[7:0]` — note selectors (priority encoder)
- **Outputs:**  
  - `buzzer` — square-wave tone  
  - `seg7_0` — note letter (active-low segments)  
  - `seg7_1..seg7_3` — frequency hundreds/tens/ones (active-low segments)

## Note map
| Selected switch | Note | Frequency (Hz) | seg7_0 |
|---|---|---:|---|
| SW7 | A' | 880 | A |
| SW6 | G# | 831 | G |
| SW5 | F# | 740 | F |
| SW4 | E  | 659 | E |
| SW3 | D  | 587 | D |
| SW2 | C# | 554 | C |
| SW1 | B  | 494 | B |
| SW0 | A  | 440 | A |

