# EncloSOS

Certificates are mathematical functions whose existence offers a formal guarantee for dynamical system properties. These certificates do not necessitate the explicit computation of system trajectories and, as such, provide a convenient way to ensure the reliability and trustworthiness of control systems. Among these certificates, the Lyapunov function is one of the most renowned examples: many works in the literature were devoted to the computational search of Lyapunov functions.

On the other hand, barrier certificates were introduced to ensure that the system will not enter undesirable or unsafe states.[^PJ:04] Finding barrier certificates is typically a challenging task, similar to the search for Lyapunov functions. Nevertheless, when dealing with polynomial dynamical systems and initial and unsafe sets defined as basic semialgebraic sets (defined by an intersection of polynomial inequalities), a feasible computational approach using sum-of-squares (SOS) is available.

In the context of obstacle avoidance problems, an unsafe set contains the obstacle. In many real-world scenarios, however, these obstacles do not have a direct semialgebraic description but are typically represented as point clouds obtained by sampling. Thus, to formulate a SOS feasibility problem with these obstacles, one must find an adequate semialgebraic set over-approximating them. A common approach in the literature is to compute a minimal-volume ellipsoid containing the sampled points from the obstacle. However, this approach can be overly conservative and may limit its applicability for scenarios with more complex object shapes. For instance, in a pick-and-place task, a robot might need to pick up an object located at the bottom of a box without colliding with the edges of the box:[^SKCFSBH:24]

<p align="center"><img src="https://github.com/martinschonger/enclosos/assets/6695626/85c232b0-393d-4092-93c4-7b296a97fad3" width="700"></p>

To address these challenges, we propose **EncloSOS**, a MATLAB toolbox implementing various algorithms for computing semialgebraic enclosures in obstacle-rich environments.

[^PJ:04]: 
    Prajna, S., and Jadbabaie, A. "Safety verification of hybrid systems using barrier certificates." _International Workshop on Hybrid Systems: Computation and Control_. Berlin, Heidelberg: Springer Berlin Heidelberg, 2004.
[^SKCFSBH:24]:
    Schonger, M., Kussaba, H., Chen, L., Figueredo, L., Swikir, A., Billard, A., and Haddadin, S. "Learning Barrier-Certified Polynomial Dynamical Systems for Obstacle Avoidance with Robots." _Proceedings of the 41st IEEE International Conference on Robotics and Automation (ICRA)_, 2024.

### Demo

https://github.com/martinschonger/enclosos/assets/6695626/3f0c01ba-8bc8-4562-a73a-1e031f07d72c

### Setup
Install MATLAB (tested with R2023a).

Install the MathWorks toolboxes
[Image Processing Toolbox](https://www.mathworks.com/products/image-processing.html),
[Optimization Toolbox](https://www.mathworks.com/products/optimization.html),
[Statistics and Machine Learning Toolbox](https://www.mathworks.com/products/statistics.html), and
[Symbolic Math Toolbox](https://www.mathworks.com/products/symbolic.html).

Install the third party tool [YALMIP](https://yalmip.github.io/).

### Usage
Run `enclosos.mlapp`.

Configure the parameters via the GUI as desired, hit the "compute" button, and check the result in the figure window.

Optionally, make adjustments and recompute as needed.

Optionally, save the computed polynomial to an m-file.

(Optionally, recreate the shown u-shaped semi-algebraic set by using the settings from `ushape_settings.txt`.)

### Citation

```bibtex
@Article{enclosos2024,
  title = {{EncloSOS}: A {MATLAB} Toolbox for Computing Semi-Algebraic Enclosures},
  author = {Schonger, Martin and Kussaba, Hugo Tadashi M. and Swikir, Abdalla and Billard, Aude and Haddadin, Sami},
  journal = {Manuscript in preparation},
  year = {2024},
}
```

### Contact
martin.schonger@tum.de

This software was created as part of Martin Schonger's master's thesis in Computer Science at the Technical University of Munich's (TUM) School of Computation, Information and Technology (CIT).

Copyright © 2024 Martin Schonger
This software is licensed under the GPLv3.
