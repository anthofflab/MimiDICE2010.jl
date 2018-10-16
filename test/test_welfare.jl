using Mimi
using Base.Test
using ExcelReaders

include("../src/components/welfare_component.jl")

@testset "welfare" begin

Precision = 1.0e-11
T = 60
f = openxl(joinpath(@__DIR__, "..", "Data", "DICE2010_082710d.xlsx"))

m = Model()

set_dimension!(m, :time, model_years)

add_comp!(m, welfare, :welfare)

# Set the parameters that would normally be internal connection from their Excel values
set_param!(m, :welfare, :CPC, read_params(f, "B126:BI126", T))

# Load the rest of the external parameters
p = dice2010_excel_parameters(joinpath(@__DIR__, "..", "Data", "DICE2010_082710d.xlsx"))
set_param!(m, :welfare, :l, p[:l])
set_param!(m, :welfare, :elasmu, p[:elasmu])
set_param!(m, :welfare, :rr, p[:rr])
set_param!(m, :welfare, :scale1, p[:scale1])
set_param!(m, :welfare, :scale2, p[:scale2])

# Run the one-component model
run(m)

# Extract the generated variables
CEMUTOTPER  = m[:welfare, :CEMUTOTPER]
PERIODU     = m[:welfare, :PERIODU]
UTILITY     = m[:welfare, :UTILITY]

# Extract the true values
True_CEMUTOTPER = read_params(f, "B129:BI129", T)
True_PERIODU    = read_params(f, "B128:BI128", T)
True_UTILITY    = read_params(f, "B130")

# Test that the values are the same
@test maximum(abs, CEMUTOTPER .- True_CEMUTOTPER) ≈ 0. atol = Precision
@test maximum(abs, PERIODU .- True_PERIODU) ≈ 0. atol = Precision
@test abs(UTILITY - True_UTILITY) ≈ 0. atol = Precision

end