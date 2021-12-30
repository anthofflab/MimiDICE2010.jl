module MimiDICE2010

using Mimi
using XLSX:readxlsx

include("parameters.jl")
include("marginaldamage.jl")

include("components/grosseconomy_component.jl")
include("components/emissions_component.jl")
include("components/co2cycle_component.jl")
include("components/radiativeforcing_component.jl")
include("components/climatedynamics_component.jl")
include("components/sealevelrise_component.jl")
include("components/damages_component.jl")
include("components/neteconomy_component.jl")
include("components/welfare_component.jl")

export construct_dice

# Allow these to be accessed by, e.g., EPA DICE model
const model_years = 2005:10:2595

function get_model(params=nothing)
    params_dict = params == nothing ? dice2010_excel_parameters() : params

    m = Model()
    set_dimension!(m, :time, model_years)

    # --------------------------------------------------------------------------
    # Add components in order
    # --------------------------------------------------------------------------

    add_comp!(m, grosseconomy)
    add_comp!(m, emissions)
    add_comp!(m, co2cycle)
    add_comp!(m, radiativeforcing)
    add_comp!(m, climatedynamics)
    add_comp!(m, sealevelrise)
    add_comp!(m, damages)
    add_comp!(m, neteconomy)
    add_comp!(m, welfare)

    # --------------------------------------------------------------------------
    # Make internal parameter connections
    # --------------------------------------------------------------------------

    # Socioeconomics
    connect_param!(m, :grosseconomy, :I, :neteconomy, :I)
    connect_param!(m, :emissions, :YGROSS, :grosseconomy, :YGROSS)
    
    # Climate
    connect_param!(m, :co2cycle, :E, :emissions, :E)
    connect_param!(m, :radiativeforcing, :MAT, :co2cycle, :MAT)
    connect_param!(m, :radiativeforcing, :MAT_final, :co2cycle, :MAT_final)
    connect_param!(m, :climatedynamics, :FORC, :radiativeforcing, :FORC)
    connect_param!(m, :sealevelrise, :TATM, :climatedynamics, :TATM)

    # Damages
    connect_param!(m, :damages, :TATM, :climatedynamics, :TATM)
    connect_param!(m, :damages, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :damages, :TotSLR, :sealevelrise, :TotSLR)
    connect_param!(m, :neteconomy, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :neteconomy, :DAMFRAC, :damages, :DAMFRAC)
    connect_param!(m, :welfare, :CPC, :neteconomy, :CPC)

    # --------------------------------------------------------------------------
    # Set external parameter values 
    # --------------------------------------------------------------------------

    # Set unshared parameters - name is a Tuple{Symbol, Symbol} of (component_name, param_name)
    for (name, value) in params_dict[:unshared]
        update_param!(m, name[1], name[2], value)
    end

    # Set shared parameters - name is a Symbol representing the param_name, here
    # we will create a shared model parameter with the same name as the component
    # parameter and then connect our component parameters to this shared model parameter
    add_shared_param!(m, :fco22x, params_dict[:shared][:fco22x])
    connect_param!(m, :climatedynamics, :fco22x, :fco22x)
    connect_param!(m, :radiativeforcing, :fco22x, :fco22x)

    add_shared_param!(m, :MIU, params_dict[:shared][:MIU], dims = [:time])
    connect_param!(m, :neteconomy, :MIU, :MIU)
    connect_param!(m, :emissions, :MIU, :MIU)

    add_shared_param!(m, :l, params_dict[:shared][:l], dims = [:time])
    connect_param!(m, :neteconomy, :l, :l)
    connect_param!(m, :grosseconomy, :l, :l)
    connect_param!(m, :welfare, :l, :l)

    return m
end

construct_dice = get_model # still export the old version of the function name

end # module