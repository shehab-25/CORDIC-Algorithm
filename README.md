# CORDIC (Coordinate Rotation Digital Computer) Algorithm

## Project overview
This repository contains an implementation and reference model of the **CORDIC (COordinate Rotation DIgital Computer)** algorithm. The goal of the project is to implement a hardware-friendly, fixed-point CORDIC engine that computes trigonometric functions (sine, cosine), and can be adapted to compute other elementary functions (atan2, vector magnitude, hyperbolic functions) using the same iterative shift–add structure.

This repository includes:
- A fixed-point HDL implementation (Verilog) of the iterative CORDIC core.
- A MATLAB reference model used for verification and self-checking of the HDL outputs.
- Testbenches and example stimuli to exercise the design across angles and edge cases.

---

## What is CORDIC?
CORDIC is an iterative algorithm introduced by Jack E. Volder (1959) that computes a wide class of functions using only shifts, adds/subtracts, and a small lookup table of precomputed arctangents. It comes in two principal modes:

- **Rotation mode** — rotate a vector by a target angle to compute sine/cosine.
- **Vectoring mode** — rotate a vector to align with the x-axis, accumulating the rotation angle (useful for computing atan/phase or magnitude).

Because it requires no multipliers and only constant-angle lookups and bit-shifts, CORDIC is ideal for hardware platforms (FPGAs, ASICs) and low-cost calculators.

---

## Mathematical idea
Starting from an initial vector \((x_0, y_0)\) and an angle accumulator \((z_0)\), each iteration performs a micro-rotation by an angle \(\pm \alpha_i\) where \(\alpha_i = \arctan(2^{-i})\):

\[
x_{i+1} = x_i - d_i \cdot 2^{-i} y_i \\
y_{i+1} = y_i + d_i \cdot 2^{-i} x_i \\
z_{i+1} = z_i - d_i \cdot \alpha_i
\]

where \(d_i \in \{+1,-1\}\) is chosen either to reduce the residual angle (in rotation mode) or to reduce the y component (in vectoring mode). After \(N\) iterations, the outputs approximate rotated coordinates — with a known scale factor:

\[
K_N = \prod_{i=0}^{N-1} \frac{1}{\sqrt{1+2^{-2i}}}
\]

In fixed-point implementations the scale factor is either pre-compensated or corrected afterwards.

---

## Implementation
**Language & files**
- The hardware core is implemented in Verilog (files in the `hdl/`). The design is iterative and parameterizable by the number of iterations.
- A MATLAB reference model (`.m`) is included; it reproduces the same fixed-point arithmetic and provides golden outputs for verification.

**Fixed-point format**
- The HDL core uses a signed fixed-point format (Q-format). The project uses a Q-format aligned to the integer + fractional layout used across the files (for example Q1.15). Internally some stages use extended precision to avoid overflow during shifts and accumulate intermediate results before returning to the target Q-format.

**Angle normalization & quadrant handling**
- The implementation normalizes input angles to the primary range and applies quadrant reduction so that the CORDIC core receives angles within -90°..90° (or -π/2..π/2 radians). Signs of sine/cosine are adjusted according to the original quadrant.

**Shift-and-add micro-rotations**
- Each iteration implements right-shifts (`>>> i`) as the multiplier-free representation of \(2^{-i}\) and uses an `atan_table` of precomputed arctan values for the `z` accumulator.

**Scale correction**
- The repository documents how the overall CORDIC gain \(K_N\) is handled — either by pre-scaling the initial vector or by applying a post-scaling correction depending on the trade-off between hardware cost and accuracy.

**Parameterization**
- `ITERATIONS` (or a similarly named parameter) controls the number of CORDIC iterations. Increasing the number of iterations improves precision but increases latency.

---

## How to run / simulate
1. **MATLAB reference model**: run the provided `.m` script. The MATLAB model generates golden outputs (sine, cosine, angles) at the chosen fixed-point precision and a set of test vectors.

2. **HDL simulation**: use your preferred simulator (ModelSim, Questasim, or vendor tool) to run the included testbench. Typical flow:
   - Run the MATLAB script which puts the correct results in a `MATLAB_outputs.txt` file.
   - Run the provided script:
   ```tcl`
   do run.do
   - Run the testbench and compare HDL outputs against MATLAB golden outputs (the testbench includes self-checking testbench).

## Performance & accuracy
- Accuracy of sine/cosine approximations depends on:
  - Number of iterations `N`.
  - Fixed-point Q-format (fractional bits).
  - Whether the CORDIC gain `K_N` is compensated.

## Conclusion
This project demonstrated the implementation of the CORDIC algorithm in both HDL and MATLAB, highlighting its efficiency for computing trigonometric and related mathematical functions using only shift–add operations. By developing a parameterizable Verilog/SystemVerilog core and verifying it against a MATLAB reference model, we achieved a hardware-friendly design that balances accuracy and resource utilization.

The outcomes of this work include:
- A reusable and scalable CORDIC core that can be synthesized on FPGA or ASIC platforms.
- A self-checking verification flow using MATLAB golden models and HDL testbenches.
- Insight into the trade-offs between iteration count, precision, and hardware cost.
- A foundation for extending the design to hyperbolic functions, vector magnitude/phase calculations, or pipelined high-performance implementations.

Overall, the project validates CORDIC as a practical algorithm for digital hardware design, reinforcing its value in applications such as signal processing, computer graphics, robotics, and embedded systems where efficient real-time computation is essential.


## Contact Me!
- **Email:** shehabeldeen2004@gmail.com
- **LinkedIn:** (https://www.linkedin.com/in/shehabeldeen22)
- **GitHub:** (https://github.com/shehab-25)
