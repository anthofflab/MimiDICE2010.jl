using Mimi
using Base.Test
using ExcelReaders

include("../src/helpers.jl")
include("../src/parameters.jl")
include("../src/components/damages_component.jl")

Precision = 1.0e-11
T = 60
f = openxl("../Data/DICE2010_082710d.xlsx")

m = Model()

setindex(m, :time, collect(2005:10:2595))

addcomponent(m, damages)

# Set the parameters that would normally be internal connection from their Excel values
setparameter(m, :damages, :TATM, getparams(f, "B121:BI121", :all, "Base", T))
setparameter(m, :damages, :YGROSS, getparams(f, "B92:BI92", :all, "Base", T))
setparameter(m, :damages, :TotSLR, getparams(f, "B182:BI182", :all, "Base", T))

# Load the rest of the external parameters
p = getdice2010excelparameters("../Data/DICE2010_082710d.xlsx")
setparameter(m, :damages, :a1, p[:a1])
setparameter(m, :damages, :a2, p[:a2])
setparameter(m, :damages, :a3, p[:a3])
setparameter(m, :damages, :b1, p[:slrcoeff])
setparameter(m, :damages, :b2, p[:slrcoeffsq])
setparameter(m, :damages, :b3, p[:slrexp])

# Run the one-component model
run(m)

# Extract the generated variables
DAMAGES = m[:damages, :DAMAGES]
DAMFRAC = m[:damages, :DAMFRAC]

# Extract the true values
#True_DAMAGES    = getparams(f, "", :all, "Base", T)
True_DAMFRAC    = getparams(f, "B93:BI93", :all, "Base", T)

# Test that the values are the same
#@test maximum(abs, DAMAGES .- True_DAMAGES) ≈ 0. atol = Precision
@test maximum(abs, DAMFRAC .- True_DAMFRAC) ≈ 0. atol = Precision
