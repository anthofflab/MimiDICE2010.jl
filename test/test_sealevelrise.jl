using Mimi
using Base.Test
using ExcelReaders

include("../src/helpers.jl")
include("../src/parameters.jl")
include("../src/components/sealevelrise_component.jl")

@testset "sealevelrise" begin

Precision = 1.0e-11
T = 60
f = openxl("../Data/DICE2010_082710d.xlsx")

m = Model()

setindex(m, :time, collect(2005:10:2595))

addcomponent(m, sealevelrise)

# Set the parameters that would normally be internal connection from their Excel values
setparameter(m, :sealevelrise, :TATM, getparams(f, "B121:BI121", :all, "Base", T))

# Load the rest of the external parameters
p = getdice2010excelparameters("../Data/DICE2010_082710d.xlsx")
setparameter(m, :sealevelrise, :therm0, p[:therm0])
setparameter(m, :sealevelrise, :gsic0, p[:gsic0])
setparameter(m, :sealevelrise, :gis0, p[:gis0])
setparameter(m, :sealevelrise, :ais0, p[:ais0])
setparameter(m, :sealevelrise, :therm_asym, p[:therm_asym])
setparameter(m, :sealevelrise, :gsic_asym, p[:gsic_asym])
setparameter(m, :sealevelrise, :gis_asym, p[:gis_asym])
setparameter(m, :sealevelrise, :ais_asym, p[:ais_asym])
setparameter(m, :sealevelrise, :thermrate, p[:thermrate])
setparameter(m, :sealevelrise, :gsicrate, p[:gsicrate])
setparameter(m, :sealevelrise, :gisrate, p[:gisrate])
setparameter(m, :sealevelrise, :aisrate, p[:aisrate])
setparameter(m, :sealevelrise, :slrthreshold, p[:slrthreshold])

# Run the one-component model
run(m)

# Extract the generated variables
ThermSLR    = m[:sealevelrise, :ThermSLR]
GSICSLR     = m[:sealevelrise, :GSICSLR]
GISSLR      = m[:sealevelrise, :GISSLR]
AISSLR      = m[:sealevelrise, :AISSLR]
TotSLR      = m[:sealevelrise, :TotSLR]

# Extract the true values
True_ThermSLR    = getparams(f, "B178:BI178", :all, "Base", T)
True_GSICSLR    = getparams(f, "B179:BI179", :all, "Base", T)
True_GISSLR    = getparams(f, "B180:BI180", :all, "Base", T)
True_AISSLR    = getparams(f, "B181:BI181", :all, "Base", T)
True_TotSLR    = getparams(f, "B182:BI182", :all, "Base", T)

# Test that the values are the same
@test maximum(abs, ThermSLR .- True_ThermSLR) ≈ 0. atol = Precision
@test maximum(abs, GSICSLR .- True_GSICSLR) ≈ 0. atol = Precision
@test maximum(abs, GISSLR .- True_GISSLR) ≈ 0. atol = Precision
@test maximum(abs, AISSLR .- True_AISSLR) ≈ 0. atol = Precision
@test maximum(abs, TotSLR .- True_TotSLR) ≈ 0. atol = Precision

end