# # Tutorials für Trixi.jl

# This repository contains a tutorial section for [Trixi.jl](https://github.com/trixi-framework/Trixi.jl),
# with interactive step-by-step explanations via [Binder](https://mybinder.org).

#md # Right now, you are using the classic documentation. The corresponding notebooks can be viewed in
#md # [nbviewer](https://nbviewer.jupyter.org/) and opened in [Binder](https://mybinder.org/) via the respective link.
    
# There are tutorials for the following topics:

# ### 1 Adding a new equation
# #### [1.1 Scalar conservation law](@ref cubic_conservation_law)
#src # [![](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/trixi-framework/TrixiTutorials/gh-pages?filepath=dev/notebooks/adding_new_equations/cubic_conservation_law.ipynb) [![](https://raw.githubusercontent.com/jupyter/design/master/logos/Badges/nbviewer_badge.svg)](https://nbviewer.jupyter.org/github/trixi-framework/TrixiTutorials/blob/gh-pages/dev/notebooks/adding_new_equations/cubic_conservation_law.ipynb)
#-
# In this tutorial, it is explained how a new equation can be added using the example of the cubic conservation law.
# First, the equation is defined using a `struct` `CubicEquation` and the physical flux. Then, the corresponding
# standard setup in Trixi.jl (`mesh`, `solver`, `semi` and `ode`) is build and the ODE problem is solved by OrdinaryDiffEq's `solve` method.

# #### [1.2 Nonconservative advection](@ref nonconservative_advection)
#src # [![](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/trixi-framework/TrixiTutorials/gh-pages?filepath=dev/notebooks/adding_new_equations/nonconservative_advection.ipynb) [![](https://raw.githubusercontent.com/jupyter/design/master/logos/Badges/nbviewer_badge.svg)](https://nbviewer.jupyter.org/github/trixi-framework/TrixiTutorials/blob/gh-pages/dev/notebooks/adding_new_equations/nonconservative_advection.ipynb)
#-
# In this part, the nonconservative linear advection equation is implemented. Then, two simulations with different level of refinement are executed and the resulting errors are compared.

# ### [2 Differentiable programming](@ref differentiable_programming)
#src # [![](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/trixi-framework/TrixiTutorials/gh-pages?filepath=dev/notebooks/differentiable_programming.ipynb) [![](https://raw.githubusercontent.com/jupyter/design/master/logos/Badges/nbviewer_badge.svg)](https://nbviewer.jupyter.org/github/trixi-framework/TrixiTutorials/blob/gh-pages/dev/notebooks/differentiable_programming.ipynb)
#-
# This part deals with some basic differentiable programming topics. For example, a Jacobian, its eigenvalues and
# a curve of total energy (through the simulation) are calculated and plotted for a few semidiscretizations.
# Moreover, an example for propagating errors with Measurement.jl is given at the end.
