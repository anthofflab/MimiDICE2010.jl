using Mimi
using Base.Test
using ExcelReaders

include("../src/helpers.jl")
include("../src/parameters.jl")
include("../src/components/radiativeforcing_component.jl")

Precision = 1.0e-11
T = 60
f = openxl("../Data/DICE2010_082710d.xlsx")

m = Model()

setindex(m, :time, collect(2005:10:2595))

addcomponent(m, radiativeforcing)

# Set the parameters that would normally be internal connection from their Excel values
setparameter(m, :radiativeforcing, :MAT, getparams(f, "B112:BI112", :all, "Base", T))

# Load the rest of the external parameters
p = getdice2010excelparameters("../Data/DICE2010_082710d.xlsx")
setparameter(m, :radiativeforcing, :forcoth, p[:forcoth])
setparameter(m, :radiativeforcing, :fco22x, p[:fco22x])

# Run the one-component model
run(m)

# Extract the generated variables
FORC = m[:radiativeforcing, :FORC]

# Extract the true values
True_FORC    = getparams(f, "B122:BI122", :all, "Base", T)

# Test that the values are the same
@test maximum(abs, FORC .- True_FORC) ≈ 0. atol = Precision
