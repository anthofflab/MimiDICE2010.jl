using Mimi
using Base.Test
using ExcelReaders

include("../src/components/climatedynamics_component.jl")

@testset "climatedynamics" begin

Precision = 1.0e-11
T = length(dice2010.model_years)
f = openxl(joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx"))

m = Model()

set_dimension!(m, :time, dice2010.model_years)

add_comp!(m, climatedynamics, :climatedynamics)

# Set the parameters that would normally be internal connection from their Excel values
set_param!(m, :climatedynamics, :FORC, read_params(f, "B122:BI122", T))

# Load the rest of the external parameters
p = dice2010_excel_parameters(joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx"))
set_param!(m, :climatedynamics, :fco22x, p[:fco22x])
set_param!(m, :climatedynamics, :t2xco2, p[:t2xco2])
set_param!(m, :climatedynamics, :tatm0, p[:tatm0])
set_param!(m, :climatedynamics, :tatm1, p[:tatm1])
set_param!(m, :climatedynamics, :tocean0, p[:tocean0])
set_param!(m, :climatedynamics, :c1, p[:c1])
set_param!(m, :climatedynamics, :c3, p[:c3])
set_param!(m, :climatedynamics, :c4, p[:c4])

# Run the one-component model
run(m)

# Extract the generated variables
TATM    = m[:climatedynamics, :TATM]
TOCEAN  = m[:climatedynamics, :TOCEAN]

# Extract the true values
True_TATM   = read_params(f, "B121:BI121", T)
True_TOCEAN = read_params(f, "B123:BI123", T)

# Test that the values are the same
@test maximum(abs, TATM .- True_TATM) ≈ 0. atol = Precision
@test maximum(abs, TOCEAN .- True_TOCEAN) ≈ 0. atol = Precision

end