module dice2010

using Mimi
using ExcelReaders

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

export getparams, construct_dice, dice2010_excel_parameters

# Allow these to be accessed by, e.g., EPA DICE model
model_years = 2005:10:2595

#
# N.B. See dice2010-defmodel.jl for the @defmodel version of the following
#

<<<<<<< Updated upstream
const global datafile = joinpath(dirname(@__FILE__), "..", "Data", "DICE2010_082710d.xlsx")
p = getdice2010excelparameters(datafile)

DICE = Model()
set_dimension!(DICE, :time, 2005:10:2595)

addcomponent(DICE,grosseconomy, :grosseconomy)
addcomponent(DICE,emissions, :emissions)
addcomponent(DICE,co2cycle, :co2cycle)
addcomponent(DICE,radiativeforcing, :radiativeforcing)
addcomponent(DICE,climatedynamics, :climatedynamics)
addcomponent(DICE,sealevelrise, :sealevelrise)
addcomponent(DICE,damages, :damages)
addcomponent(DICE,neteconomy, :neteconomy)
addcomponent(DICE,welfare, :welfare)

#GROSS ECONOMY COMPONENT
set_parameter!(DICE, :grosseconomy, :al, p[:al])
set_parameter!(DICE, :grosseconomy, :l, p[:l])
set_parameter!(DICE, :grosseconomy, :gama, p[:gama])
set_parameter!(DICE, :grosseconomy, :dk, p[:dk])
set_parameter!(DICE, :grosseconomy, :k0, p[:k0])

# Note: offset=1 => dependence is on on prior timestep, i.e., not a cycle
connect_parameter(DICE, :grosseconomy, :I, :neteconomy, :I, offset=1)


#EMISSIONS COMPONENT
set_parameter!(DICE, :emissions, :sigma, p[:sigma])
set_parameter!(DICE, :emissions, :MIU, p[:miubase])
set_parameter!(DICE, :emissions, :etree, p[:etree]) 

connect_parameter(DICE, :emissions, :YGROSS, :grosseconomy, :YGROSS, offset=0)


#CO2 CYCLE COMPONENT
set_parameter!(DICE, :co2cycle, :mat0, p[:mat0])
set_parameter!(DICE, :co2cycle, :mat1, p[:mat1])
set_parameter!(DICE, :co2cycle, :mu0, p[:mu0])
set_parameter!(DICE, :co2cycle, :ml0, p[:ml0])
set_parameter!(DICE, :co2cycle, :b12, p[:b12])
set_parameter!(DICE, :co2cycle, :b23, p[:b23])
set_parameter!(DICE, :co2cycle, :b11, p[:b11])
set_parameter!(DICE, :co2cycle, :b21, p[:b21])
set_parameter!(DICE, :co2cycle, :b22, p[:b22])
set_parameter!(DICE, :co2cycle, :b32, p[:b32])
set_parameter!(DICE, :co2cycle, :b33, p[:b33])

connect_parameter(DICE, :co2cycle, :E, :emissions, :E, offset=0)


#RADIATIVE FORCING COMPONENT
set_parameter!(DICE, :radiativeforcing, :forcoth, p[:forcoth])
set_parameter!(DICE, :radiativeforcing, :fco22x, p[:fco22x])

connect_parameter(DICE, :radiativeforcing, :MAT, :co2cycle, :MAT, offset=0)
connect_parameter(DICE, :radiativeforcing, :MAT61, :co2cycle, :MAT61, offset=0)


#CLIMATE DYNAMICS COMPONENT
set_parameter!(DICE, :climatedynamics, :fco22x, p[:fco22x])
set_parameter!(DICE, :climatedynamics, :t2xco2, p[:t2xco2])
set_parameter!(DICE, :climatedynamics, :tatm0, p[:tatm0])
set_parameter!(DICE, :climatedynamics, :tatm1, p[:tatm1])
set_parameter!(DICE, :climatedynamics, :tocean0, p[:tocean0])
set_parameter!(DICE, :climatedynamics, :c1, p[:c1])
set_parameter!(DICE, :climatedynamics, :c3, p[:c3])
set_parameter!(DICE, :climatedynamics, :c4, p[:c4])

connect_parameter(DICE, :climatedynamics, :FORC, :radiativeforcing, :FORC, offset=0)


# SEA LEVEL RISE COMPONENT
set_parameter!(DICE, :sealevelrise, :therm0, p[:therm0])
set_parameter!(DICE, :sealevelrise, :gsic0, p[:gsic0])
set_parameter!(DICE, :sealevelrise, :gis0, p[:gis0])
set_parameter!(DICE, :sealevelrise, :ais0, p[:ais0])
set_parameter!(DICE, :sealevelrise, :therm_asym, p[:therm_asym])
set_parameter!(DICE, :sealevelrise, :gsic_asym, p[:gsic_asym])
set_parameter!(DICE, :sealevelrise, :gis_asym, p[:gis_asym])
set_parameter!(DICE, :sealevelrise, :ais_asym, p[:ais_asym])
set_parameter!(DICE, :sealevelrise, :thermrate, p[:thermrate])
set_parameter!(DICE, :sealevelrise, :gsicrate, p[:gsicrate])
set_parameter!(DICE, :sealevelrise, :gisrate, p[:gisrate])
set_parameter!(DICE, :sealevelrise, :aisrate, p[:aisrate])
set_parameter!(DICE, :sealevelrise, :slrthreshold, p[:slrthreshold])

connect_parameter(DICE, :sealevelrise, :TATM, :climatedynamics, :TATM, offset=0)


#DAMAGES COMPONENT
set_parameter!(DICE, :damages, :a1, p[:a1])
set_parameter!(DICE, :damages, :a2, p[:a2])
set_parameter!(DICE, :damages, :a3, p[:a3])
set_parameter!(DICE, :damages, :b1, p[:slrcoeff])
set_parameter!(DICE, :damages, :b2, p[:slrcoeffsq])
set_parameter!(DICE, :damages, :b3, p[:slrexp])

connect_parameter(DICE, :damages, :TATM, :climatedynamics, :TATM)
connect_parameter(DICE, :damages, :YGROSS, :grosseconomy, :YGROSS)
connect_parameter(DICE, :damages, :TotSLR, :sealevelrise, :TotSLR)


#NET ECONOMY COMPONENT
set_parameter!(DICE, :neteconomy, :cost1, p[:cost1])
set_parameter!(DICE, :neteconomy, :MIU, p[:miubase])
set_parameter!(DICE, :neteconomy, :expcost2, p[:expcost2])
set_parameter!(DICE, :neteconomy, :partfract, p[:partfract])
set_parameter!(DICE, :neteconomy, :pbacktime, p[:pbacktime])
set_parameter!(DICE, :neteconomy, :S, p[:savebase])
set_parameter!(DICE, :neteconomy, :l, p[:l])

connect_parameter(DICE, :neteconomy, :YGROSS, :grosseconomy, :YGROSS, offset=0)
#connect_parameter(DICE, :neteconomy, :DAMAGES, :damages, :DAMAGES)
connect_parameter(DICE, :neteconomy, :DAMFRAC, :damages, :DAMFRAC, offset=0)


#WELFARE COMPONENT
set_parameter!(DICE, :welfare, :l, p[:l])
set_parameter!(DICE, :welfare, :elasmu, p[:elasmu])
set_parameter!(DICE, :welfare, :rr, p[:rr])
set_parameter!(DICE, :welfare, :scale1, p[:scale1])
set_parameter!(DICE, :welfare, :scale2, p[:scale2])

connect_parameter(DICE, :welfare, :CPC, :neteconomy, :CPC, offset=0)

add_connector_comps(DICE)
=======
function construct_dice(params=nothing)
    p = params == nothing ? dice2010_excel_parameters() : params

    m = Model()
    set_dimension!(m, :time, model_years)

    addcomponent(m, grosseconomy, :grosseconomy)
    addcomponent(m, emissions, :emissions)
    addcomponent(m, co2cycle, :co2cycle)
    addcomponent(m, radiativeforcing, :radiativeforcing)
    addcomponent(m, climatedynamics, :climatedynamics)
    addcomponent(m, sealevelrise, :sealevelrise)
    addcomponent(m, damages, :damages)
    addcomponent(m, neteconomy, :neteconomy)
    addcomponent(m, welfare, :welfare)

    #GROSS ECONOMY COMPONENT
    set_parameter!(m, :grosseconomy, :al, p[:al])
    set_parameter!(m, :grosseconomy, :l, p[:l])
    set_parameter!(m, :grosseconomy, :gama, p[:gama])
    set_parameter!(m, :grosseconomy, :dk, p[:dk])
    set_parameter!(m, :grosseconomy, :k0, p[:k0])

    # Note: offset=1 => dependence is on on prior timestep, i.e., not a cycle
    connect_parameter(m, :grosseconomy, :I, :neteconomy, :I, offset=1)


    #EMISSIONS COMPONENT
    set_parameter!(m, :emissions, :sigma, p[:sigma])
    set_parameter!(m, :emissions, :MIU, p[:miubase])
    set_parameter!(m, :emissions, :etree, p[:etree]) 

    connect_parameter(m, :emissions, :YGROSS, :grosseconomy, :YGROSS, offset=0)


    #CO2 CYCLE COMPONENT
    set_parameter!(m, :co2cycle, :mat0, p[:mat0])
    set_parameter!(m, :co2cycle, :mat1, p[:mat1])
    set_parameter!(m, :co2cycle, :mu0, p[:mu0])
    set_parameter!(m, :co2cycle, :ml0, p[:ml0])
    set_parameter!(m, :co2cycle, :b12, p[:b12])
    set_parameter!(m, :co2cycle, :b23, p[:b23])
    set_parameter!(m, :co2cycle, :b11, p[:b11])
    set_parameter!(m, :co2cycle, :b21, p[:b21])
    set_parameter!(m, :co2cycle, :b22, p[:b22])
    set_parameter!(m, :co2cycle, :b32, p[:b32])
    set_parameter!(m, :co2cycle, :b33, p[:b33])

    connect_parameter(m, :co2cycle, :E, :emissions, :E, offset=0)


    #RADIATIVE FORCING COMPONENT
    set_parameter!(m, :radiativeforcing, :forcoth, p[:forcoth])
    set_parameter!(m, :radiativeforcing, :fco22x, p[:fco22x])

    connect_parameter(m, :radiativeforcing, :MAT, :co2cycle, :MAT, offset=0)
    connect_parameter(m, :radiativeforcing, :MAT61, :co2cycle, :MAT61, offset=0)


    #CLIMATE DYNAMICS COMPONENT
    set_parameter!(m, :climatedynamics, :fco22x, p[:fco22x])
    set_parameter!(m, :climatedynamics, :t2xco2, p[:t2xco2])
    set_parameter!(m, :climatedynamics, :tatm0, p[:tatm0])
    set_parameter!(m, :climatedynamics, :tatm1, p[:tatm1])
    set_parameter!(m, :climatedynamics, :tocean0, p[:tocean0])
    set_parameter!(m, :climatedynamics, :c1, p[:c1])
    set_parameter!(m, :climatedynamics, :c3, p[:c3])
    set_parameter!(m, :climatedynamics, :c4, p[:c4])

    connect_parameter(m, :climatedynamics, :FORC, :radiativeforcing, :FORC, offset=0)


    # SEA LEVEL RISE COMPONENT
    set_parameter!(m, :sealevelrise, :therm0, p[:therm0])
    set_parameter!(m, :sealevelrise, :gsic0, p[:gsic0])
    set_parameter!(m, :sealevelrise, :gis0, p[:gis0])
    set_parameter!(m, :sealevelrise, :ais0, p[:ais0])
    set_parameter!(m, :sealevelrise, :therm_asym, p[:therm_asym])
    set_parameter!(m, :sealevelrise, :gsic_asym, p[:gsic_asym])
    set_parameter!(m, :sealevelrise, :gis_asym, p[:gis_asym])
    set_parameter!(m, :sealevelrise, :ais_asym, p[:ais_asym])
    set_parameter!(m, :sealevelrise, :thermrate, p[:thermrate])
    set_parameter!(m, :sealevelrise, :gsicrate, p[:gsicrate])
    set_parameter!(m, :sealevelrise, :gisrate, p[:gisrate])
    set_parameter!(m, :sealevelrise, :aisrate, p[:aisrate])
    set_parameter!(m, :sealevelrise, :slrthreshold, p[:slrthreshold])

    connect_parameter(m, :sealevelrise, :TATM, :climatedynamics, :TATM, offset=0)


    #DAMAGES COMPONENT
    set_parameter!(m, :damages, :a1, p[:a1])
    set_parameter!(m, :damages, :a2, p[:a2])
    set_parameter!(m, :damages, :a3, p[:a3])
    set_parameter!(m, :damages, :b1, p[:slrcoeff])
    set_parameter!(m, :damages, :b2, p[:slrcoeffsq])
    set_parameter!(m, :damages, :b3, p[:slrexp])

    connect_parameter(m, :damages, :TATM, :climatedynamics, :TATM)
    connect_parameter(m, :damages, :YGROSS, :grosseconomy, :YGROSS)
    connect_parameter(m, :damages, :TotSLR, :sealevelrise, :TotSLR)


    #NET ECONOMY COMPONENT
    set_parameter!(m, :neteconomy, :cost1, p[:cost1])
    set_parameter!(m, :neteconomy, :MIU, p[:miubase])
    set_parameter!(m, :neteconomy, :expcost2, p[:expcost2])
    set_parameter!(m, :neteconomy, :partfract, p[:partfract])
    set_parameter!(m, :neteconomy, :pbacktime, p[:pbacktime])
    set_parameter!(m, :neteconomy, :S, p[:savebase])
    set_parameter!(m, :neteconomy, :l, p[:l])

    connect_parameter(m, :neteconomy, :YGROSS, :grosseconomy, :YGROSS, offset=0)
    #connect_parameter(m, :neteconomy, :DAMAGES, :damages, :DAMAGES)
    connect_parameter(m, :neteconomy, :DAMFRAC, :damages, :DAMFRAC, offset=0)


    #WELFARE COMPONENT
    set_parameter!(m, :welfare, :l, p[:l])
    set_parameter!(m, :welfare, :elasmu, p[:elasmu])
    set_parameter!(m, :welfare, :rr, p[:rr])
    set_parameter!(m, :welfare, :scale1, p[:scale1])
    set_parameter!(m, :welfare, :scale2, p[:scale2])

    connect_parameter(m, :welfare, :CPC, :neteconomy, :CPC, offset=0)

    add_connector_comps(m)
    return m
end
>>>>>>> Stashed changes

end #module
