using Mimi
using Base.Test
using ExcelReaders

include("../src/helpers.jl")
include("../src/parameters.jl")
include("../src/components/co2cycle_component.jl")

@testset "co2cycle" begin

Precision = 1.0e-11
T = 60
f = openxl("../Data/DICE2010_082710d.xlsx")

m = Model()

setindex(m, :time, collect(2005:10:2595))

addcomponent(m, co2cycle)

# Set the parameters that would normally be internal connection from their Excel values
setparameter(m, :co2cycle, :E, getparams(f, "B109:BI109", :all, "Base", T))

# Load the rest of the external parameters
p = getdice2010excelparameters("../Data/DICE2010_082710d.xlsx")
setparameter(m, :co2cycle, :mat0, p[:mat0])
setparameter(m, :co2cycle, :mat1, p[:mat1])
setparameter(m, :co2cycle, :mu0, p[:mu0])
setparameter(m, :co2cycle, :ml0, p[:ml0])
setparameter(m, :co2cycle, :b12, p[:b12])
setparameter(m, :co2cycle, :b23, p[:b23])
setparameter(m, :co2cycle, :b11, p[:b11])
setparameter(m, :co2cycle, :b21, p[:b21])
setparameter(m, :co2cycle, :b22, p[:b22])
setparameter(m, :co2cycle, :b32, p[:b32])
setparameter(m, :co2cycle, :b33, p[:b33])

# Run the one-component model
run(m)

# Extract the generated variables
MAT = m[:co2cycle, :MAT]
ML  = m[:co2cycle, :ML]
MU  = m[:co2cycle, :MU]

# Extract the true values
True_MAT    = getparams(f, "B112:BI112", :all, "Base", T)
True_ML     = getparams(f, "B115:BI115", :all, "Base", T)
True_MU     = getparams(f, "B114:BI114", :all, "Base", T)

# Test that the values are the same
@test maximum(abs, MAT .- True_MAT) ≈ 0. atol = Precision
@test maximum(abs, ML .- True_ML) ≈ 0. atol = Precision
@test maximum(abs, MU .- True_MU) ≈ 0. atol = Precision

end