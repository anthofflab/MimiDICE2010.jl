using Mimi
using Base.Test
using ExcelReaders

include("../src/components/grosseconomy_component.jl")

@testset "grosseconomy" begin

Precision = 1.0e-11
T = length(model_years)
f = openxl(joinpath(@__DIR__, "..", "Data", "DICE2010_082710d.xlsx"))

m = Model()

set_dimension!(m, :time, model_years)

add_comp!(m, grosseconomy, :grosseconomy)

# Set the parameters that would normally be internal connection from their Excel values
set_param!(m, :grosseconomy, :I, read_params(f, "B101:BI101", T))

# Load the rest of the external parameters
p = dice2010_excel_parameters(joinpath(@__DIR__, "..", "Data", "DICE2010_082710d.xlsx"))
set_param!(m, :grosseconomy, :al, p[:al])
set_param!(m, :grosseconomy, :l, p[:l])
set_param!(m, :grosseconomy, :gama, p[:gama])
set_param!(m, :grosseconomy, :dk, p[:dk])
set_param!(m, :grosseconomy, :k0, p[:k0])

# Run the one-component model
run(m)

# Extract the generated variables
K       = m[:grosseconomy, :K]
YGROSS  = m[:grosseconomy, :YGROSS]

# Extract the true values
True_K      = read_params(f, "B102:BI102", T)
True_YGROSS = read_params(f, "B92:BI92", T)

# Test that the values are the same
@test maximum(abs, K .- True_K) ≈ 0. atol = Precision
@test maximum(abs, YGROSS .- True_YGROSS) ≈ 0. atol = Precision

end