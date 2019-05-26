include("../src/components/emissions_component.jl")

@testset "emissions" begin

Precision = 1.0e-11
T = length(MimiDICE2010.model_years)
f = openxl(joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx"))

m = Model()

set_dimension!(m, :time, MimiDICE2010.model_years)

add_comp!(m, emissions, :emissions)

# Set the parameters that would normally be internal connection from their Excel values
set_param!(m, :emissions, :YGROSS, read_params(f, "B92:BI92", T))

# Load the rest of the external parameters
p = dice2010_excel_parameters(joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx"))
set_param!(m, :emissions, :sigma, p[:sigma])
set_param!(m, :emissions, :MIU, p[:miubase])
set_param!(m, :emissions, :etree, p[:etree])

# Run the one-component model
run(m)

# Extract the generated variables
CCA     = m[:emissions, :CCA]
E       = m[:emissions, :E]
EIND    = m[:emissions, :EIND]

# Extract the true values
True_CCA    = read_params(f, "B117:BI117", T)
True_E      = read_params(f, "B109:BI109", T)
True_EIND   = read_params(f, "B110:BI110", T)

# Test that the values are the same
@test maximum(abs, CCA .- True_CCA) ≈ 0. atol = Precision
@test maximum(abs, E .- True_E) ≈ 0. atol = Precision
@test maximum(abs, EIND .- True_EIND) ≈ 0. atol = Precision

end