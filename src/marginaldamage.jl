# A general note here that some of this functionality may appear confusing because
# we do not convert from GtC to GtCO2 until the end in the `_compute_scc` function,
# so while the `pulse_size` argument should be interpreted as GtCO2, in practice it is used
# as GtC through the climate system perturbation steps and not converted to GtCO2 
# until the final  post-processing computation of marginal damages

"""
    compute_scc(m::Model=get_model(); year::Union{Int,Nothing}=nothing, 
                last_year::Int=model_years[end], prtp::Float64=0.015, 
                eta::Float64=1.5, pulse_size=1e10)

Computes the social cost of CO2 for an emissions pulse in `year` for the provided MimiDICE2010
model from it's start through the `last_year`, which will default to 2595, the last
year of DICE's default `model_years`. If no model is provided, the default model from MimiDICE2010.get_model() is used.
Ramsey discounting is used with a pure rate of time preference of `prtp` and inequality aversion of `eta`.
`pulse_size` controls the size of the marginal emission pulse, which is the total
pulse of CO2 in tons that DICE's structure spreads across ten years starting 
in the specified `year`.  The SCC will always be returned in dollars per ton CO2 since 
is normalized by the `pulse_size`.
"""
function compute_scc(m::Model=get_model(); year::Union{Int,Nothing}=nothing, last_year::Int=model_years[end], prtp::Float64=0.015, eta::Float64=1.5, pulse_size=1e10)
    year === nothing ? error("Must specify an emission year. Try `compute_scc(m, year=2015)`.") : nothing
    !(last_year in model_years) ? error("Invalid value of $last_year for last_year. last_year must be within the model's time index $model_years.") : nothing
    !(year in model_years[1]:10:last_year) ? error("Cannot compute the scc for year $year, year must be within the model's time index $(model_years[1]):10:$last_year.") : nothing

    mm = get_marginal_model(m; year=year, pulse_size=pulse_size)

    return _compute_scc(mm, year=year, last_year=last_year, prtp=prtp, eta=eta)
end

"""
    compute_scc_mm(m::Model=get_model(); year::Union{Int,Nothing}=nothing, 
                    last_year::Int=model_years[end], prtp::Float64=0.015, 
                    eta::Float64=1.5, pulse_size=1e10)

Returns a NamedTuple (scc=scc, mm=mm) of the social cost of carbon and the MarginalModel used to compute it.
Computes the social cost of CO2 for an emissions pulse in `year` for the provided MimiDICE2010 model 
from it's start through the `last_year`, which will default to 2595, the last
year of DICE's default `model_years`. If no model is provided, the default model 
from MimiDICE2010.get_model() is used. Ramsey discounting is used with a pure rate of 
time preference of `prtp` and inequality aversion of `eta`. `pulse_size` controls 
the size of the marginal emission pulse, which is the total pulse of CO2 in tons 
that DICE's structure spreads across ten years starting  in the specified `year`.
The SCC will always be returned in dollars per ton CO2 since it is normalized by 
the `pulse_size`.
"""
function compute_scc_mm(m::Model=get_model(); year::Union{Int,Nothing}=nothing, last_year::Int=model_years[end], prtp::Float64=0.015, eta::Float64=1.5, pulse_size=1e10)
    year === nothing ? error("Must specify an emission year. Try `compute_scc_mm(m, year=2015)`.") : nothing
    !(last_year in model_years) ? error("Invalid value of $last_year for last_year. last_year must be within the model's time index $model_years.") : nothing
    !(year in model_years[1]:10:last_year) ? error("Cannot compute the scc for year $year, year must be within the model's time index $(model_years[1]):10:$last_year.") : nothing

    # note here that the pulse size will be used as the `delta` parameter for 
    # the `MarginalModel` and thus allow computation of the SCC to return units of
    # dollars per ton, as long as `pulse_size` is in tons
    mm = get_marginal_model(m; year=year, pulse_size=pulse_size)
    scc = _compute_scc(mm; year=year, last_year=last_year, prtp=prtp, eta=eta)
    
    return (scc = scc, mm = mm)
end

# helper function for computing SCC from a MarginalModel, not to be exported or advertised to users
function _compute_scc(mm::MarginalModel; year::Int, last_year::Int, prtp::Float64, eta::Float64)
    ntimesteps = findfirst(isequal(last_year), model_years)     # Will run through the timestep of the specified last_year 
    run(mm, ntimesteps=ntimesteps)

    # below we convert from $ per GtC to $ per GtCO2 with 12/44
    marginal_damages = -1 * mm[:neteconomy, :C][1:ntimesteps] * 1e12 * 12 / 44 # convert from trillion $/ton C to $/ton CO2; multiply by -1 to get positive value for damages

    cpc = mm.base[:neteconomy, :CPC]

    year_index = findfirst(isequal(year), model_years)

    df = [zeros(year_index - 1)..., ((cpc[year_index] / cpc[i])^eta * 1 / (1 + prtp)^(t - year) for (i, t) in enumerate(model_years) if year <= t <= last_year)...]
    scc = sum(df .* marginal_damages * 10)  # currently implemented as a 10year step function; so each timestep of discounted marginal damages is multiplied by 10
    return scc
end

"""
    get_marginal_model(m::Model=get_model(); year::Union{Int,Nothing}=nothing, pulse_size::Float64=1e10)

Creates a Mimi MarginalModel where the provided m is the base model, and the marginal model has additional emissions of CO2 in year `year`.
If no Model m is provided, the default model from MimiDICE2010.get_model() is used as the base model.
`pulse_size` controls the size of the marginal emission pulse, which is the aggregate
pulse of CO2 in tons that DICE's structure spreads across ten years starting 
in the specified `year`. Note that regardless of this absolute pulse size, the SCC will be 
returned in units of dollars per tons long (as the `pulse_size` is in tons) through 
use of the internal machinery of `MarginalModel`s `delta` parameter.
"""
function get_marginal_model(m::Model=get_model(); year::Union{Int,Nothing}=nothing, pulse_size::Float64=1e10)
    year === nothing ? error("Must specify an emission year. Try `get_marginal_model(m, year=2015)`.") : nothing
    !(year in model_years) ? error("Cannot add marginal emissions in $year, year must be within the model's time index $(model_years[1]):10:$last_year.") : nothing

    # Pulse has a value of 1GtC per year for ten model_years; Pulse is interpreted 
    # here as units of GtC and will be converted to GtCO2 in marginal damages 
    # computation; note use of `pulse_size` as `delta` argument to the MarginalModel 
    # to allow for normalization
    mm = create_marginal_model(m, pulse_size) 
    
    # Add a marginal emission component to `m` which adds `pulse_size` of additional C 
    # emissions over ten years starting in the specified `year`.
    add_marginal_emissions!(mm.modified, year, pulse_size)

    return mm
end

"""
    add_marginal_emissions!(m::Model, year::Int, pulse_size::Float64) 

Adds a marginal emission component to `m` which adds `pulse_size` of additional CO2 
emissions over ten years starting in the specified `year`.
"""
function add_marginal_emissions!(m::Model, year::Int, pulse_size::Float64) 
    add_comp!(m, Mimi.adder, :marginalemission, before=:co2cycle)

    time = Mimi.dimension(m, :time)
    addem = zeros(length(time))

    # Unit of pulse_size is tons, but units of emissions in DICE are GtC, so we 
    # convert to GtC by dividing by 1e9, and then divide by 10 again because that 
    # pulse is emitted for ten years.     
    
    # Pulse is interpreted here as units of GtC and will be converted to 
    # GtCO2 in marginal damages computation
    addem[time[year]] = pulse_size / 1e10

    set_param!(m, :marginalemission, :add, addem)
    connect_param!(m, :marginalemission, :input, :emissions, :E)
    connect_param!(m, :co2cycle, :E, :marginalemission, :output)
end



# Old available function
function getmarginal_dice_models(;emissionyear=2015)

    DICE = get_model()
    run(DICE)

    mm = MarginalModel(DICE)
    m1 = mm.base
    m2 = mm.modified

    add_comp!(m2, Mimi.adder, :marginalemission, before=:co2cycle)

    time = Mimi.dimension(m1, :time)
    addem = zeros(length(time))
    addem[time[emissionyear]] = 1.0

    set_param!(m2, :marginalemission, :add, addem)
    connect_param!(m2, :marginalemission, :input, :emissions, :E)
    connect_param!(m2, :co2cycle, :E, :marginalemission, :output)

    run(m1)
    run(m2)

    return m1, m2
end
