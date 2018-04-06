using Mimi
using Base.Test
using ExcelReaders

include("../src/helpers.jl")
include("../src/parameters.jl")
include("../src/components/emissions_component.jl")

@testset "emissions" begin

Precision = 1.0e-11
T = 60
f = openxl(joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx"))

m = Model()

set_dimension!(m, :time, collect(2005:10:2595))

addcomponent(m, emissions, :emissions)

# Set the parameters that would normally be internal connection from their Excel values
set_parameter!(m, :emissions, :YGROSS, getparams(f, "B92:BI92", :all, "Base", T))

# Load the rest of the external parameters
p = getdice2010excelparameters(joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx"))
set_parameter!(m, :emissions, :sigma, p[:sigma])
set_parameter!(m, :emissions, :MIU, p[:miubase])
set_parameter!(m, :emissions, :etree, p[:etree])

# Run the one-component model
run(m)

# Extract the generated variables
CCA     = m[:emissions, :CCA]
E       = m[:emissions, :E]
EIND    = m[:emissions, :EIND]

# Extract the true values
True_CCA    = getparams(f, "B117:BI117", :all, "Base", T)
True_E      = getparams(f, "B109:BI109", :all, "Base", T)
True_EIND   = getparams(f, "B110:BI110", :all, "Base", T)

# Test that the values are the same
@test maximum(abs, CCA .- True_CCA) ≈ 0. atol = Precision
@test maximum(abs, E .- True_E) ≈ 0. atol = Precision
@test maximum(abs, EIND .- True_EIND) ≈ 0. atol = Precision

end