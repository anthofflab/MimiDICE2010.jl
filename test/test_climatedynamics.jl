using Mimi
using Base.Test
using ExcelReaders

include("../src/helpers.jl")
include("../src/parameters.jl")
include("../src/components/climatedynamics_component.jl")

@testset "climatedynamics" begin

Precision = 1.0e-11
T = 60
f = openxl("../Data/DICE2010_082710d.xlsx")

m = Model()

setindex(m, :time, collect(2005:10:2595))

addcomponent(m, climatedynamics)

# Set the parameters that would normally be internal connection from their Excel values
setparameter(m, :climatedynamics, :FORC, getparams(f, "B122:BI122", :all, "Base", T))

# Load the rest of the external parameters
p = getdice2010excelparameters("../Data/DICE2010_082710d.xlsx")
setparameter(m, :climatedynamics, :fco22x, p[:fco22x])
setparameter(m, :climatedynamics, :t2xco2, p[:t2xco2])
setparameter(m, :climatedynamics, :tatm0, p[:tatm0])
setparameter(m, :climatedynamics, :tatm1, p[:tatm1])
setparameter(m, :climatedynamics, :tocean0, p[:tocean0])
setparameter(m, :climatedynamics, :c1, p[:c1])
setparameter(m, :climatedynamics, :c3, p[:c3])
setparameter(m, :climatedynamics, :c4, p[:c4])

# Run the one-component model
run(m)

# Extract the generated variables
TATM    = m[:climatedynamics, :TATM]
TOCEAN  = m[:climatedynamics, :TOCEAN]

# Extract the true values
True_TATM   = getparams(f, "B121:BI121", :all, "Base", T)
True_TOCEAN = getparams(f, "B123:BI123", :all, "Base", T)

# Test that the values are the same
@test maximum(abs, TATM .- True_TATM) ≈ 0. atol = Precision
@test maximum(abs, TOCEAN .- True_TOCEAN) ≈ 0. atol = Precision

end