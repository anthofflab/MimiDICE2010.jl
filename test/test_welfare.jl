using Mimi
using Base.Test
using ExcelReaders

include("../src/helpers.jl")
include("../src/parameters.jl")
include("../src/components/welfare_component.jl")

@testset "welfare" begin

Precision = 1.0e-11
T = 60
f = openxl(joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx"))

m = Model()

setindex(m, :time, collect(2005:10:2595))

addcomponent(m, welfare)

# Set the parameters that would normally be internal connection from their Excel values
setparameter(m, :welfare, :CPC, getparams(f, "B126:BI126", :all, "Base", T))

# Load the rest of the external parameters
p = getdice2010excelparameters(joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx"))
setparameter(m, :welfare, :l, p[:l])
setparameter(m, :welfare, :elasmu, p[:elasmu])
setparameter(m, :welfare, :rr, p[:rr])
setparameter(m, :welfare, :scale1, p[:scale1])
setparameter(m, :welfare, :scale2, p[:scale2])

# Run the one-component model
run(m)

# Extract the generated variables
CEMUTOTPER  = m[:welfare, :CEMUTOTPER]
PERIODU     = m[:welfare, :PERIODU]
UTILITY     = m[:welfare, :UTILITY]

# Extract the true values
True_CEMUTOTPER    = getparams(f, "B129:BI129", :all, "Base", T)
True_PERIODU    = getparams(f, "B128:BI128", :all, "Base", T)
True_UTILITY    = getparams(f, "B130:B130", :single, "Base", 1)

# Test that the values are the same
@test maximum(abs, CEMUTOTPER .- True_CEMUTOTPER) ≈ 0. atol = Precision
@test maximum(abs, PERIODU .- True_PERIODU) ≈ 0. atol = Precision
@test abs(UTILITY - True_UTILITY) ≈ 0. atol = Precision

end