using Mimi
using Base.Test
using ExcelReaders

include("../src/components/co2cycle_component.jl")

@testset "co2cycle" begin

Precision = 1.0e-11
T = length(model_years)
f = openxl(joinpath(@__DIR__, "..", "Data", "DICE2010_082710d.xlsx"))

m = Model()

set_dimension!(m, :time, model_years)

add_comp!(m, co2cycle, :co2cycle)

# Set the parameters that would normally be internal connection from their Excel values
set_param!(m, :co2cycle, :E, read_params(f, "B109:BI109", T))

# Load the rest of the external parameters
p = dice2010_excel_parameters(joinpath(@__DIR__, "..", "Data", "DICE2010_082710d.xlsx"))
set_param!(m, :co2cycle, :mat0, p[:mat0])
set_param!(m, :co2cycle, :mat1, p[:mat1])
set_param!(m, :co2cycle, :mu0, p[:mu0])
set_param!(m, :co2cycle, :ml0, p[:ml0])
set_param!(m, :co2cycle, :b12, p[:b12])
set_param!(m, :co2cycle, :b23, p[:b23])
set_param!(m, :co2cycle, :b11, p[:b11])
set_param!(m, :co2cycle, :b21, p[:b21])
set_param!(m, :co2cycle, :b22, p[:b22])
set_param!(m, :co2cycle, :b32, p[:b32])
set_param!(m, :co2cycle, :b33, p[:b33])

# Run the one-component model
run(m)

# Extract the generated variables
MAT     = m[:co2cycle, :MAT]
MAT61   = m[:co2cycle, :MAT61]
ML      = m[:co2cycle, :ML]
MU      = m[:co2cycle, :MU]

# Extract the true values
True_MAT    = read_params(f, "B112:BI112", T)
True_MAT61  = read_params(f, "BJ112")
True_ML     = read_params(f, "B115:BI115", T)
True_MU     = read_params(f, "B114:BI114", T)

# Test that the values are the same
@test maximum(abs, MAT .- True_MAT) ≈ 0. atol = Precision
@test abs(MAT61 - True_MAT61) ≈ 0. atol = Precision
@test maximum(abs, ML .- True_ML) ≈ 0. atol = Precision
@test maximum(abs, MU .- True_MU) ≈ 0. atol = Precision

end