const datafile = joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx")

"""
    read_params(f, range::String, count::Int, sheet::String="Base")

Get parameters from DICE2010 excel sheet. Returns a Dictionary with two keys,
:shared and :unshared, each holding a dictionary of shared (keys are a Tuple of 
(component, parameter) and unshared (keys are parameter_name) parameter values.

`range` is a single cell or a range of cells in the excel sheet.
  Must be a cell reference of the form "A27" or a range "B56:B77".

`count` is the length of the time dimension; ignored if range
   refers to a single cell.

`sheet` is the name of the worksheet in the Excel file to read from.
  Defaults to "Base".

Examples:
    values = read_params(f, "B15:BI15", 40)   # read only the first 40 values

    value = read_params(f, "A27", sheet="Parameters")
    value = read_params(f, "A27:A27", sheet="Parameters") # same as above
"""
function read_params(f, range::String, T::Int=60; sheet::String="Base")
    data = f[sheet][range]
    parts = split(range, ":")
    return (length(parts) == 1 || parts[1] == parts[2]) ? data : Vector{Float64}(data[1:T])
end

function dice2010_excel_parameters(filename=datafile; nsteps=nothing)
    p_unshared = Dict{Tuple{Symbol, Symbol},Any}()
    p_shared = Dict{Symbol, Any}()
    
    # the number of time-indexed values to read
    nsteps = nsteps == nothing ? length(2005:10:2595) : nsteps

    # Open DICE_2010 Excel file to read parameters
    f = readxlsx(filename)

    #
    # SHARED PARAMETERS 
    #

    p_shared[:fco22x] = read_params(f, "B77")   # Forcings of equilibrium CO2 doubling (Wm-2)
    p_shared[:MIU] = read_params(f, "B133:BI133", nsteps) # emissions control rate
    p_shared[:l] = read_params(f, "B27:BI27", nsteps)       # Population (millions)

    #
    # COMPONENT PARAMETERS 
    #

    # Preferences
    p_unshared[(:welfare,:elasmu)]   = read_params(f, "B19")               # Elasticity of marginal utility of consumption
    p_unshared[(:welfare, :rr)]      = read_params(f, "B18:BI18", nsteps)       # Social time preference factor

    # Population and technology
    p_unshared[(:grosseconomy, :gama)]    = read_params(f, "B9")                # Capital elasticity in production function
    p_unshared[(:grosseconomy, :dk)]      = read_params(f, "B10")               # Depreciation rate on capital (per year)
    p_unshared[(:grosseconomy, :k0)]      = read_params(f, "B13")               # Initial capital value (trill 2005 USD)
    p_unshared[(:grosseconomy, :al)]      = read_params(f, "B21:BI21", nsteps)       # Level of total factor productivity

    # Emissions parameters
    p_unshared[(:emissions, :sigma)] = read_params(f, "B46:BI46", nsteps)
    p_unshared[(:emissions, :etree)] = read_params(f, "B52:BI52", nsteps)
    p_unshared[(:neteconomy, :S)]     = read_params(f, "B132:BI132", nsteps) / 100   # savings rate

    # Carbon cycle
    p_unshared[(:co2cycle, :mat0)]    = read_params(f, "B57")   # Initial Concentration in atmosphere 2000 (GtC)
    p_unshared[(:co2cycle, :mat1)]    = read_params(f, "B58")   # Initial Concentration in atmosphere 2010 (GtC)
    p_unshared[(:co2cycle, :mu0)]     = read_params(f, "B59")   # Initial Concentration in biosphere/shallow oceans (GtC)
    p_unshared[(:co2cycle, :ml0)]     = read_params(f, "B60")   # Initial Concentration in deep oceans (GtC)

    # Flow parameters
    p_unshared[(:co2cycle, :b12)] = read_params(f, "B64") / 100 # Carbon cycle transition matrix atmosphere to shallow ocean
    p_unshared[(:co2cycle, :b23)] = read_params(f, "B67") / 100 # Carbon cycle transition matrix shallow to deep ocean

    # Parameters for long-run consistency of carbon cycle
    p_unshared[(:co2cycle, :b11)] = read_params(f, "B62") / 100 # Carbon cycle transition matrix atmosphere to atmosphere
    p_unshared[(:co2cycle, :b21)] = read_params(f, "B63") / 100 # Carbon cycle transition matrix biosphere/shallow oceans to atmosphere
    p_unshared[(:co2cycle, :b22)] = read_params(f, "B65") / 100 # Carbon cycle transition matrix shallow ocean to shallow oceans
    p_unshared[(:co2cycle, :b32)] = read_params(f, "B66") / 100 # Carbon cycle transition matrix deep ocean to shallow ocean
    p_unshared[(:co2cycle, :b33)] = read_params(f, "B68") / 100 # Carbon cycle transition matrix deep ocean to deep oceans

    # Climate model parameters
    p_unshared[(:climatedynamics, :t2xco2)]  = read_params(f, "B76")   # Equilibrium temp impact (oC per doubling CO2)
    p_unshared[(:climatedynamics, :tatm0)]   = read_params(f, "B73")   # Initial lower stratum temp change (C from 1900)
    p_unshared[(:climatedynamics, :tatm1)]   = read_params(f, "C73")   # Initial atmospheric temp change 2015 (C from 1900)
    p_unshared[(:climatedynamics, :tocean0)] = read_params(f, "B74")   # Initial lower stratum temp change (C from 1900)

    # Transient TSC Correction ("Speed of Adjustment Parameter")
    p_unshared[(:climatedynamics, :c1)]      = read_params(f, "B75")   # Climate equation coefficient for upper level
    p_unshared[(:climatedynamics, :c3)]      = read_params(f, "B78")   # Transfer coefficient upper to lower stratum
    p_unshared[(:climatedynamics, :c4)]      = read_params(f, "B79")   # Transfer coefficient for lower level

    # Climate damage parameters
    p_unshared[(:damages, :a1)] = read_params(f, "B33")   # Damage coefficient
    p_unshared[(:damages, :a2)] = read_params(f, "B34")   # Damage quadratic term
    p_unshared[(:damages, :a3)] = read_params(f, "B35")   # Damage exponent

    # Abatement cost
    p_unshared[(:neteconomy, :expcost2)]    = read_params(f, "B44")               # Exponent of control cost function
    p_unshared[(:neteconomy, :pbacktime)]   = read_params(f, "B42:BI42", nsteps)       # backstop price
    # Adjusted cost for backstop (or: "Abatement cost function coefficient")
    p_unshared[(:neteconomy, :cost1)]       = read_params(f, "B37:BI37", nsteps)

    # Scaling and inessential parameters
    p_unshared[(:welfare, :scale1)] = read_params(f, "B88")    # Multiplicative scaling coefficient
    p_unshared[(:welfare, :scale2)] = read_params(f, "B89")    # Additive scaling coefficient

    # Exogenous forcing for other greenhouse gases
    p_unshared[(:radiativeforcing, :forcoth)] = read_params(f, "B70:BI70", nsteps)

    # Fraction of emissions in control regime
    p_unshared[(:neteconomy, :partfract)] = read_params(f, "B82:BI82", nsteps)

    # SLR Parameters

    p_unshared[(:damages, :b1)] = read_params(f, "B51", sheet="Parameters")
    p_unshared[(:damages, :b2)] = read_params(f, "B52", sheet="Parameters")
    p_unshared[(:damages, :b3)] = read_params(f, "B53", sheet="Parameters")

    p_unshared[(:sealevelrise, :therm0)] = read_params(f, "B178") # meters above 2000
    p_unshared[(:sealevelrise, :gsic0)]  = read_params(f, "B179")
    p_unshared[(:sealevelrise, :gis0)]   = read_params(f, "B180")
    p_unshared[(:sealevelrise, :ais0)]   = read_params(f, "B181")

    p_unshared[(:sealevelrise, :therm_asym)] = read_params(f, "B173")
    p_unshared[(:sealevelrise, :gsic_asym)]  = read_params(f, "B174")
    p_unshared[(:sealevelrise, :gis_asym)]   = read_params(f, "B175")
    p_unshared[(:sealevelrise, :ais_asym)]   = read_params(f, "B176")

    p_unshared[(:sealevelrise, :thermrate)]  = read_params(f, "C173")
    p_unshared[(:sealevelrise, :gsicrate)]   = read_params(f, "C174")
    p_unshared[(:sealevelrise, :gisrate)]    = read_params(f, "C175")
    p_unshared[(:sealevelrise, :aisrate)]    = read_params(f, "C176")

    p_unshared[(:sealevelrise, :slrthreshold)] = read_params(f, "D176")

    return Dict(:unshared => p_unshared, :shared => p_shared)
end
