module dice2010

using Mimi
import Mimi.read_params

include("parameters.jl")
include("components/grosseconomy_component.jl")
include("components/emissions_component.jl")
include("components/co2cycle_component.jl")
include("components/radiativeforcing_component.jl")
include("components/climatedynamics_component.jl")
include("components/sealevelrise_component.jl")
include("components/damages_component.jl")
include("components/neteconomy_component.jl")
include("components/welfare_component.jl")

export read_params, DICE

@defmodel DICE begin
    p = dice2010_excel_parameters()
    
    DICE = Model()
    index[time] = 2005:10:2595

    component(grosseconomy)
    component(emissions)
    component(co2cycle)
    component(radiativeforcing)
    component(climatedynamics)
    component(sealevelrise)
    component(damages)
    component(neteconomy)
    component(welfare)


    #GROSS ECONOMY COMPONENT
    grosseconomy.al     = p[:al]
    grosseconomy.l      = p[:l]
    grosseconomy.gama   = p[:gama]
    grosseconomy.dk     = p[:dk]
    grosseconomy.k0     = p[:k0]

    # Note that dependence is on prior timestep ("[t-1]")
    neteconomy.I[t-1] => grosseconomy.I


    #EMISSIONS COMPONENT
    emissions.sigma = p[:sigma]
    emissions.MIU   = p[:miubase]
    emissions.etree  = p[:etree]

    grosseconomy.YGROSS => emissions.YGROSS
        

    #CO2 CYCLE COMPONENT
    co2cycle.mat0   = p[:mat0]
    co2cycle.mat1   = p[:mat1]
    co2cycle.mu0    = p[:mu0]
    co2cycle.ml0    = p[:ml0]
    co2cycle.b12    = p[:b12]
    co2cycle.b23    = p[:b23]
    co2cycle.b11    = p[:b11]
    co2cycle.b21    = p[:b21]
    co2cycle.b22    = p[:b22]
    co2cycle.b32    = p[:b32]
    co2cycle.b33    = p[:b33]

    emissions.E => co2cycle.E
    

    #RADIATIVE FORCING COMPONENT
    radiativeforcing.forcoth    = p[:forcoth]
    radiativeforcing.fco22x     = p[:fco22x]

    co2cycle.MAT => radiativeforcing.MAT
    co2cycle.MAT61 => radiativeforcing.MAT61
    

    #CLIMATE DYNAMICS COMPONENT
    climatedynamics.fco22x  = p[:fco22x]
    climatedynamics.t2xco2  = p[:t2xco2]
    climatedynamics.tatm0   = p[:tatm0]
    climatedynamics.tatm1   = p[:tatm1]
    climatedynamics.tocean0 = p[:tocean0]
    climatedynamics.c1      = p[:c1]
    climatedynamics.c3      = p[:c3]
    climatedynamics.c4      = p[:c4]

    radiativeforcing.FORC => climatedynamics.FORC
    

    # SEA LEVEL RISE COMPONENT
    sealevelrise.therm0         = p[:therm0]
    sealevelrise.gsic0          = p[:gsic0]
    sealevelrise.gis0           = p[:gis0]
    sealevelrise.ais0           = p[:ais0]
    sealevelrise.therm_asyDICE  = p[:therm_asym]
    sealevelrise.gsic_asyDICE   = p[:gsic_asym]
    sealevelrise.gis_asyDICE    = p[:gis_asym]
    sealevelrise.ais_asyDICE    = p[:ais_asym]
    sealevelrise.thermrate      = p[:thermrate]
    sealevelrise.gsicrate       = p[:gsicrate]
    sealevelrise.gisrate        = p[:gisrate]
    sealevelrise.aisrate        = p[:aisrate]
    sealevelrise.slrthreshold   = p[:slrthreshold]

    climatedynamics.TATM => sealevelrise.TATDICE


    #DAMAGES COMPONENT
    damages.a1  = p[:a1]
    damages.a2  = p[:a2]
    damages.a3  = p[:a3]
    damages.b1  = p[:slrcoeff]
    damages.b2  = p[:slrcoeffsq]
    damages.b3  = p[:slrexp]

    climatedynamics.TATM    => damages.TATDICE
    grosseconomy.YGROSS     => damages.YGROSS
    sealevelrise.TotSLR     => damages.TotSLR

    #NET ECONOMY COMPONENT
    neteconomy.cost1        =  p[:cost1]
    neteconomy.MIU          = p[:miubase]
    neteconomy.expcost2     = p[:expcost2]
    neteconomy.partfract    = p[:partfract]
    neteconomy.pbacktime    = p[:pbacktime]
    neteconomy.S            = p[:savebase]
    neteconomy.l            = p[:l]

    grosseconomy.YGROSS => neteconomy.YGROSS
    damages.DAMFRAC => neteconomy.DAMFRAC

    #WELFARE COMPONENT
    welfare.l       = p[:l]
    welfare.elasmu  = p[:elasmu]
    welfare.rr      = p[:rr]
    welfare.scale1  = p[:scale1]
    welfare.scale2  = p[:scale2]

    neteconomy.CPC => welfare.CPC

end #@defmodel

end #module
