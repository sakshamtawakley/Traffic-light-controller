Traffic Light Controller 

A finite state machine (FSM) based traffic light controller for a highway/country-road intersection, written in Verilog and verified through simulation.

Overview

The controller manages two sets of lights — hwy (highway) and cntry (country road) — using a 5-state Moore FSM. A car sensor input (X) on the country road triggers the light sequence to give the country road a green light, then returns to the default state (highway green) once the car has passed.

States

S0 — hwy: Green, cntry: Red : Default: highway flowing, country road stopped
S1 — hwy: Yellow, cntry: Red : Highway transitioning to stop
S2 — hwy: Red, cntry: Red : All-way stop (safety buffer)
S3 — hwy: Red, cntry: Green : Country road flowing
S4 — hwy: Red, cntry: Yellow : Country road transitioning to stop

Transitions:
S0 → S1: triggered when X (car detected on country road) goes high
S1 → S2 → S3: automatic, held for Y2R/R2G clock cycles respectively
S3 → S3 or S4: stays in S3 while X is high, moves to S4 once X goes low
S4 → S0: automatic, held for Y2R clock cycles
