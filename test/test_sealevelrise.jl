include("../src/components/sealevelrise_component.jl")

@testset "sealevelrise" begin

Precision = 1.0e-11
T = length(MimiDICE2010.model_years)
f = readxlsx(joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx"))

m = Model()

set_dimension!(m, :time, MimiDICE2010.model_years)

add_comp!(m, sealevelrise, :sealevelrise)

# Set the parameters that would normally be internal connection from their Excel values
set_param!(m, :sealevelrise, :TATM, read_params(f, "B121:BI121", T))

# Load the rest of the external parameters
p = dice2010_excel_parameters(joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx"))
set_param!(m, :sealevelrise, :therm0, p[:therm0])
set_param!(m, :sealevelrise, :gsic0, p[:gsic0])
set_param!(m, :sealevelrise, :gis0, p[:gis0])
set_param!(m, :sealevelrise, :ais0, p[:ais0])
set_param!(m, :sealevelrise, :therm_asym, p[:therm_asym])
set_param!(m, :sealevelrise, :gsic_asym, p[:gsic_asym])
set_param!(m, :sealevelrise, :gis_asym, p[:gis_asym])
set_param!(m, :sealevelrise, :ais_asym, p[:ais_asym])
set_param!(m, :sealevelrise, :thermrate, p[:thermrate])
set_param!(m, :sealevelrise, :gsicrate, p[:gsicrate])
set_param!(m, :sealevelrise, :gisrate, p[:gisrate])
set_param!(m, :sealevelrise, :aisrate, p[:aisrate])
set_param!(m, :sealevelrise, :slrthreshold, p[:slrthreshold])

# Run the one-component model
run(m)

# Extract the generated variables
ThermSLR    = m[:sealevelrise, :ThermSLR]
GSICSLR     = m[:sealevelrise, :GSICSLR]
GISSLR      = m[:sealevelrise, :GISSLR]
AISSLR      = m[:sealevelrise, :AISSLR]
TotSLR      = m[:sealevelrise, :TotSLR]

# Extract the true values
True_ThermSLR    = read_params(f, "B178:BI178", T)
True_GSICSLR    = read_params(f, "B179:BI179", T)
True_GISSLR    = read_params(f, "B180:BI180", T)
True_AISSLR    = read_params(f, "B181:BI181", T)
True_TotSLR    = read_params(f, "B182:BI182", T)

# Test that the values are the same
@test maximum(abs, ThermSLR .- True_ThermSLR) ≈ 0. atol = Precision
@test maximum(abs, GSICSLR .- True_GSICSLR) ≈ 0. atol = Precision
@test maximum(abs, GISSLR .- True_GISSLR) ≈ 0. atol = Precision
@test maximum(abs, AISSLR .- True_AISSLR) ≈ 0. atol = Precision
@test maximum(abs, TotSLR .- True_TotSLR) ≈ 0. atol = Precision

end