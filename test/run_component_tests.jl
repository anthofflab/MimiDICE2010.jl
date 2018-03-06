using Base.Test

@testset "dice2010-components" begin

include("test_climatedynamics.jl")
include("test_co2cycle.jl")
include("test_damages.jl")
include("test_emissions.jl")
include("test_grosseconomy.jl")
#include("test_neteconomy.jl")
include("test_radiativeforcing.jl")
include("test_sealevelrise.jl")
include("test_welfare.jl")

end 