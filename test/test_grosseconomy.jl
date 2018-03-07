using Mimi
using Base.Test
using ExcelReaders

include("../src/helpers.jl")
include("../src/parameters.jl")
include("../src/components/grosseconomy_component.jl")

@testset "grosseconomy" begin

Precision = 1.0e-11
T = 60
f = openxl(joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx"))

m = Model()

setindex(m, :time, collect(2005:10:2595))

addcomponent(m, grosseconomy)

# Set the parameters that would normally be internal connection from their Excel values
setparameter(m, :grosseconomy, :I, getparams(f, "B101:BI101", :all, "Base", T))

# Load the rest of the external parameters
p = getdice2010excelparameters(joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx"))
setparameter(m, :grosseconomy, :al, p[:al])
setparameter(m, :grosseconomy, :l, p[:l])
setparameter(m, :grosseconomy, :gama, p[:gama])
setparameter(m, :grosseconomy, :dk, p[:dk])
setparameter(m, :grosseconomy, :k0, p[:k0])

# Run the one-component model
run(m)

# Extract the generated variables
K       = m[:grosseconomy, :K]
YGROSS  = m[:grosseconomy, :YGROSS]

# Extract the true values
True_K      = getparams(f, "B102:BI102", :all, "Base", T)
True_YGROSS = getparams(f, "B92:BI92", :all, "Base", T)

# Test that the values are the same
@test maximum(abs, K .- True_K) ≈ 0. atol = Precision
@test maximum(abs, YGROSS .- True_YGROSS) ≈ 0. atol = Precision

end