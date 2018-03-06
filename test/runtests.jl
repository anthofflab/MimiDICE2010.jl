using Base.Test
using Mimi
using ExcelReaders

#------------------------------------------------------------------------------
#   1. Run the component-specific tests
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

m = getdiceexcel();
run(m)

f=openxl(joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx"))

#Test Precision
Precision = 1.0e-11

#Time Periods
T=60

#TATM Test (temperature increase)
True_TATM = getparams(f, "B121:BI121", :all, "Base", T);
@test maximum(abs, m[:climatedynamics, :TATM] .- True_TATM) ≈ 0. atol = Precision

#MAT Test (carbon concentration atmosphere)
True_MAT = getparams(f, "B112:BI112", :all, "Base", T);
@test maximum(abs, m[:co2cycle, :MAT] .- True_MAT) ≈ 0. atol = Precision

#DAMFRAC Test (damages fraction)
True_DAMFRAC = getparams(f, "B93:BI93", :all, "Base", T);
@test maximum(abs, m[:damages, :DAMFRAC] .- True_DAMFRAC) ≈ 0. atol = Precision

#E Test (emissions)
True_E = getparams(f, "B109:BI109", :all, "Base", T);
@test maximum(abs, m[:emissions, :E] .- True_E) ≈ 0. atol = Precision

#YGROSS Test (gross output)
True_YGROSS = getparams(f, "B92:BI92", :all, "Base", T);
@test maximum(abs, m[:grosseconomy, :YGROSS] .- True_YGROSS) ≈ 0. atol = Precision

#CPC Test (per capita consumption)
True_CPC = getparams(f, "B126:BI126", :all, "Base", T);
@test maximum(abs, m[:neteconomy, :CPC] .- True_CPC) ≈ 0. atol = Precision

#FORC Test (radiative forcing)
True_FORC = getparams(f, "B122:BI122", :all, "Base", T);
@test maximum(abs, m[:radiativeforcing, :FORC] .- True_FORC) ≈ 0. atol = Precision

True_UTILITY = getparams(f, "B130:B130", :single, "Base", T);
@test maximum(abs, m[:welfare, :UTILITY] .- True_UTILITY) ≈ 0. atol = Precision

end
