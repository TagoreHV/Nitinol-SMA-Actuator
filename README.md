Nitinol SMA Actuator
Overview

This project focuses on modeling a Nitinol Shape Memory Alloy (SMA) actuator in MATLAB. The main idea is to study how electrical current can be converted into mechanical actuation through Joule heating and the temperature-dependent phase transformation of Nitinol.

The model follows:

Current → Joule Heating → Temperature Rise → Phase Transformation → Recovery Strain → Actuation Force → Deflection

Project Details

The actuator is modeled using a cylindrical Nitinol wire with a diameter of 0.508 mm and a length of 250 mm. An electrical current is supplied to the wire, which generates heat due to its electrical resistance.

The temperature change is calculated using a transient energy balance that considers both Joule heating and convective heat loss.

The model considers the following transformation temperatures:

Austenite Start (As): 50°C
Austenite Finish (Af): 70°C
Martensite Start (Ms): 40°C
Martensite Finish (Mf): 30°C

A maximum recoverable strain of 4% is used to estimate the contraction of the actuator.

Mechanical Model

The actuator force is calculated from the selected actuator stress and the cross-sectional area of the wire. The resulting force is then used to estimate the deflection of a cantilever beam.

For the main simulation, a current of 1.5 A was used.

Main Results

The simulation produced the following results:

Activation temperature: 70.15°C
Activation time: 2.32 s
Maximum recovery strain: 4%
Maximum actuator force: 30.40 N
Electrical power: 2.22 W
Estimated beam tip deflection: 7.60 mm
Cooling time: 59 s
Final temperature: 25.50°C

The model also studies how changing the input current affects activation time, phase transformation, recovery strain, actuation force and beam deflection.

Results

The generated plots are available in the Results folder. They include the heating and cooling cycle, phase transformation, recovery strain, actuation force, beam deflection and current-dependent responses.

Limitations

This is a simplified analytical model. Constant thermal and electrical properties are assumed, and the phase transformation is represented using simplified linear relationships. The Martensite transformation temperatures used for cooling are assumed values. A more detailed SMA constitutive model and experimental data can be used in future work.

Future Work
Use material-specific transformation data
Improve the SMA constitutive model
Include temperature-dependent material properties
Perform experimental testing
Add ANSYS structural validation
Extend the model to multiple Nitinol actuator wires
Software

MATLAB
