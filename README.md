# Mimi-DICE-2010.jl

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
![](https://github.com/anthofflab/MimiDICE2010.jl/actions/workflows/jlpkgbutler-ci-master-workflow.yml/badge.svg)
[![codecov](https://codecov.io/gh/anthofflab/MimiDICE2010.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/anthofflab/MimiDICE2010.jl)

## Software Requirements

You need to install [Julia 1.6.0](https://julialang.org) or newer to run this model. You can download Julia from http://julialang.org/downloads/.

## Preparing the Software Environment

You first need to connect your julia installation with the central Mimi registry of Mimi models. This central registry is like a catalogue of models that use Mimi that is maintained by the Mimi project. To add this registry, run the following command at the julia package REPL:

```julia
pkg> registry add https://github.com/mimiframework/MimiRegistry.git
```

You only need to run this command once on a computer.
The next step is to install MimiDICE2010.jl itself. You need to run the following command at the julia package REPL:

```julia
pkg> add MimiDICE2010
```

You probably also want to install the Mimi package into your julia environment, so that you can use some of the tools in there:

```julia
pkg> add Mimi
```

## Running the model

The model uses the Mimi framework and it is highly recommended to read the Mimi documentation first to understand the code structure. For starter code on running the model just once, see the code in the file `examples/main.jl`.

The basic way to access a copy of the default MimiDICE2010 model is the following:
```
using MimiDICE2010

m = MimiDICE2010.get_model()
run(m)
```

## Calculating the Social Cost of Carbon

Here is an example of computing the social cost of carbon with MimiDICE2010. Note that the units of the returned value are dollars $/ton CO2.
```
using Mimi
using MimiDICE2010

# Get the social cost of carbon in year 2015 from the default MimiDICE2010 model:
scc = MimiDICE2010.compute_scc(year = 2015)

# You can also compute the SCC from a modified version of a MimiDICE2010 model:
m = MimiDICE2010.get_model()    # Get the default version of the MimiDICE2010 model
update_param!(m, :t2xco2, 5)    # Try a higher climate sensitivity value
scc = MimiDICE2010.compute_scc(m, year=2015)    # compute the scc from the modified model by passing it as the first argument to compute_scc
```
The first argument to the `compute_scc` function is a MimiDICE2010 model, and it is an optional argument. If no model is provided, the default MimiDICE2010 model will be used. 
There are also other keyword arguments available to `compute_scc`. Note that the user must specify a `year` for the SCC calculation, but the rest of the keyword arguments have default values.
```
compute_scc(m = get_model(),  # if no model provided, will use the default MimiDICE2010 model
    year = nothing,  # user must specify an emission year for the SCC calculation
    last_year = 2595,  # the last year to run and use for the SCC calculation. Default is the last year of the time dimension, 2595.
    prtp = 0.03,  # pure rate of time preference parameter used for constant discounting
)
```
There is an additional function for computing the SCC that also returns the MarginalModel that was used to compute it. It returns these two values as a NamedTuple of the form (scc=scc, mm=mm). The same keyword arguments from the `compute_scc` function are available for the `compute_scc_mm` function. Example:
```
using Mimi
using MimiDICE2010

result = MimiDICE2010.compute_scc_mm(year=2025, last_year=2295, prtp=0.025)

result.scc  # returns the computed SCC value

result.mm   # returns the Mimi MarginalModel

marginal_temp = result.mm[:climatedynamics, :TATM]  # marginal results from the marginal model can be accessed like this
```
