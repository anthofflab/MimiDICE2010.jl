using Base.Test
using Mimi
using ExcelReaders

#------------------------------------------------------------------------------
#   1. Run the independent component tests
#------------------------------------------------------------------------------

@testset "dice2010-components" begin

include("test_climatedynamics.jl")
include("test_co2cycle.jl")
include("test_damages.jl")
include("test_emissions.jl")
include("test_grosseconomy.jl")
include("test_neteconomy.jl")
include("test_radiativeforcing.jl")
include("test_sealevelrise.jl")
include("test_welfare.jl")

end 


#------------------------------------------------------------------------------
#   2. Run tests on the whole model
#------------------------------------------------------------------------------

include("../src/dice2010.jl")

@testset "DICE2010" begin

Precision = 1.0e-11
T=60
f=openxl(joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx"))

m = getdiceexcel();
run(m)


# Climate dynamics tests

TATM    = m[:climatedynamics, :TATM]
TOCEAN  = m[:climatedynamics, :TOCEAN]

True_TATM   = getparams(f, "B121:BI121", :all, "Base", T)
True_TOCEAN = getparams(f, "B123:BI123", :all, "Base", T)

@test maximum(abs, TATM .- True_TATM) ≈ 0. atol = Precision
@test maximum(abs, TOCEAN .- True_TOCEAN) ≈ 0. atol = Precision


# CO2 Cycle tests

MAT     = m[:co2cycle, :MAT]
MAT61   = m[:co2cycle, :MAT61]
ML      = m[:co2cycle, :ML]
MU      = m[:co2cycle, :MU]

True_MAT    = getparams(f, "B112:BI112", :all, "Base", T)
True_MAT61  = getparams(f, "BJ112:BJ112", :single, "Base", 1)
True_ML     = getparams(f, "B115:BI115", :all, "Base", T)
True_MU     = getparams(f, "B114:BI114", :all, "Base", T)

@test maximum(abs, MAT .- True_MAT) ≈ 0. atol = Precision
@test abs(MAT61 - True_MAT61) ≈ 0. atol = Precision
@test maximum(abs, ML .- True_ML) ≈ 0. atol = Precision
@test maximum(abs, MU .- True_MU) ≈ 0. atol = Precision


# Damages test

DAMFRAC = m[:damages, :DAMFRAC]
True_DAMFRAC    = getparams(f, "B93:BI93", :all, "Base", T)
@test maximum(abs, DAMFRAC .- True_DAMFRAC) ≈ 0. atol = Precision


# Emissions tests

CCA     = m[:emissions, :CCA]
E       = m[:emissions, :E]
EIND    = m[:emissions, :EIND]

True_CCA    = getparams(f, "B117:BI117", :all, "Base", T)
True_E      = getparams(f, "B109:BI109", :all, "Base", T)
True_EIND   = getparams(f, "B110:BI110", :all, "Base", T)

@test maximum(abs, CCA .- True_CCA) ≈ 0. atol = Precision
@test maximum(abs, E .- True_E) ≈ 0. atol = Precision
@test maximum(abs, EIND .- True_EIND) ≈ 0. atol = Precision


# Gross Economy tests

K       = m[:grosseconomy, :K]
YGROSS  = m[:grosseconomy, :YGROSS]

True_K      = getparams(f, "B102:BI102", :all, "Base", T)
True_YGROSS = getparams(f, "B92:BI92", :all, "Base", T)

@test maximum(abs, K .- True_K) ≈ 0. atol = Precision
@test maximum(abs, YGROSS .- True_YGROSS) ≈ 0. atol = Precision


# Net Economy tests

ABATECOST   = m[:neteconomy, :ABATECOST]
C           = m[:neteconomy, :C]
CPC         = m[:neteconomy, :CPC]
CPRICE      = m[:neteconomy, :CPRICE]
I           = m[:neteconomy, :I] 
Y           = m[:neteconomy, :Y]
YNET        = m[:neteconomy, :YNET]

True_ABATECOST  = getparams(f, "B97:BI97", :all, "Base", T)
True_C          = getparams(f, "B125:BI125", :all, "Base", T)
True_CPC        = getparams(f, "B126:BI126", :all, "Base", T)
True_CPRICE     = getparams(f, "B134:BI134", :all, "Base", T)
True_I          = getparams(f, "B101:BI101", :all, "Base", T)
True_Y          = getparams(f, "B98:BI98", :all, "Base", T)
True_YNET       = getparams(f, "B95:BI95", :all, "Base", T)

@test maximum(abs, ABATECOST .- True_ABATECOST) ≈ 0. atol = Precision
@test maximum(abs, C .- True_C) ≈ 0. atol = Precision
@test maximum(abs, CPC .- True_CPC) ≈ 0. atol = Precision
@test maximum(abs, CPRICE .- True_CPRICE) ≈ 0. atol = Precision
@test maximum(abs, I .- True_I) ≈ 0. atol = Precision
@test maximum(abs, Y .- True_Y) ≈ 0. atol = Precision
@test maximum(abs, YNET .- True_YNET) ≈ 0. atol = Precision


# Radiative Forcing test

FORC = m[:radiativeforcing, :FORC]
True_FORC    = getparams(f, "B122:BI122", :all, "Base", T)
@test maximum(abs, FORC .- True_FORC) ≈ 0. atol = Precision


# Sea Level Rise tests

ThermSLR    = m[:sealevelrise, :ThermSLR]
GSICSLR     = m[:sealevelrise, :GSICSLR]
GISSLR      = m[:sealevelrise, :GISSLR]
AISSLR      = m[:sealevelrise, :AISSLR]
TotSLR      = m[:sealevelrise, :TotSLR]

True_ThermSLR    = getparams(f, "B178:BI178", :all, "Base", T)
True_GSICSLR    = getparams(f, "B179:BI179", :all, "Base", T)
True_GISSLR    = getparams(f, "B180:BI180", :all, "Base", T)
True_AISSLR    = getparams(f, "B181:BI181", :all, "Base", T)
True_TotSLR    = getparams(f, "B182:BI182", :all, "Base", T)

@test maximum(abs, ThermSLR .- True_ThermSLR) ≈ 0. atol = Precision
@test maximum(abs, GSICSLR .- True_GSICSLR) ≈ 0. atol = Precision
@test maximum(abs, GISSLR .- True_GISSLR) ≈ 0. atol = Precision
@test maximum(abs, AISSLR .- True_AISSLR) ≈ 0. atol = Precision
@test maximum(abs, TotSLR .- True_TotSLR) ≈ 0. atol = Precision


# Welfare tests

CEMUTOTPER  = m[:welfare, :CEMUTOTPER]
PERIODU     = m[:welfare, :PERIODU]
UTILITY     = m[:welfare, :UTILITY]

True_CEMUTOTPER    = getparams(f, "B129:BI129", :all, "Base", T)
True_PERIODU    = getparams(f, "B128:BI128", :all, "Base", T)
True_UTILITY    = getparams(f, "B130:B130", :single, "Base", 1)

@test maximum(abs, CEMUTOTPER .- True_CEMUTOTPER) ≈ 0. atol = Precision
@test maximum(abs, PERIODU .- True_PERIODU) ≈ 0. atol = Precision
@test abs(UTILITY - True_UTILITY) ≈ 0. atol = Precision

end
