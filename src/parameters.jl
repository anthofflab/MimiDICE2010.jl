using ExcelReaders
include("helpers.jl")

function getdice2010excelparameters(filename)
    p = Dict{Symbol,Any}()

    T = 60

    #Open DICE_2010 Excel file to read parameters
    f = openxl(filename)

    # Preferences
    p[:elasmu]  = getparams(f, "B19:B19", :single, "Base", 1)   # Elasticity of marginal utility of consumption
    p[:rr]      = getparams(f, "B18:BI18", :all, "Base", T)     # Social time preference factor

    # Population and technology
    p[:gama]    = getparams(f, "B9:B9", :single, "Base", 1)     # Capital elasticity in production function
    p[:l]       = getparams(f, "B27:BI27", :all, "Base", T)     # Population (millions)
    p[:dk]      = getparams(f, "B10:B10", :single, "Base", 1)   # Depreciation rate on capital (per year)
    p[:k0]      = getparams(f, "B13:B13", :single, "Base", 1)   # Initial capital value (trill 2005 USD)
    p[:al]      = getparams(f, "B21:BI21", :all, "Base", T)     # Level of total factor productivity

    # Emissions parameters
    p[:sigma]   = getparams(f, "B46:BI46", :all, "Base", T)
    p[:etree]   = getparams(f, "B52:BI52", :all, "Base", T)
    p[:miubase] = getparams(f, "B133:BI133", :all, "Base", T)  # emissions control rate
    p[:savebase]= getparams(f, "B132:BI132", :all, "Base", T) / 100   # savings rate

    # Carbon cycle
    p[:mat0]    = getparams(f, "B57:B57", :single, "Base", 1)   # Initial Concentration in atmosphere 2000 (GtC)
    p[:mat1]    = getparams(f, "B58:B58", :single, "Base", 1)   # Initial Concentration in atmosphere 2010 (GtC)
    p[:mu0]     = getparams(f, "B59:B59", :single, "Base", 1)   # Initial Concentration in biosphere/shallow oceans (GtC)
    p[:ml0]     = getparams(f, "B60:B60", :single, "Base", 1)   # Initial Concentration in deep oceans (GtC)

    # Flow parameters
    p[:b12] = getparams(f, "B64:B64", :single, "Base", 1) / 100 # Carbon cycle transition matrix atmosphere to shallow ocean
    p[:b23] = getparams(f, "B67:B67", :single, "Base", 1) / 100 # Carbon cycle transition matrix shallow to deep ocean

    # Parameters for long-run consistency of carbon cycle
    p[:b11] = getparams(f, "B62:B62", :single, "Base", 1) / 100 # Carbon cycle transition matrix atmosphere to atmosphere 
    p[:b21] = getparams(f, "B63:B63", :single, "Base", 1) / 100 # Carbon cycle transition matrix biosphere/shallow oceans to atmosphere        
    p[:b22] = getparams(f, "B65:B65", :single, "Base", 1) / 100 # Carbon cycle transition matrix shallow ocean to shallow oceans              
    p[:b32] = getparams(f, "B66:B66", :single, "Base", 1) / 100 # Carbon cycle transition matrix deep ocean to shallow ocean                    
    p[:b33] = getparams(f, "B68:B68", :single, "Base", 1) / 100 # Carbon cycle transition matrix deep ocean to deep oceans                  

    # Climate model parameters
    p[:t2xco2]  = getparams(f, "B76:B76", :single, "Base", 1)   # Equilibrium temp impact (oC per doubling CO2)
    p[:tatm0]   = getparams(f, "B73:B73", :single, "Base", 1)   # Initial lower stratum temp change (C from 1900)
    p[:tatm1]   = getparams(f, "C73:C73", :single, "Base", 1)   # Initial atmospheric temp change 2015 (C from 1900)
    p[:tocean0] = getparams(f, "B74:B74", :single, "Base", 1)   # Initial lower stratum temp change (C from 1900)

    # Transient TSC Correction ("Speed of Adjustment Parameter")
    p[:c1]      = getparams(f, "B75:B75", :single, "Base", 1)   # Climate equation coefficient for upper level
    p[:c3]      = getparams(f, "B78:B78", :single, "Base", 1)   # Transfer coefficient upper to lower stratum
    p[:c4]      = getparams(f, "B79:B79", :single, "Base", 1)   # Transfer coefficient for lower level
    p[:fco22x]  = getparams(f, "B77:B77", :single, "Base", 1)   # Forcings of equilibrium CO2 doubling (Wm-2)

    # Climate damage parameters
    p[:a1] = getparams(f, "B33:B33", :single, "Base", 1)   # Damage coefficient
    p[:a2] = getparams(f, "B34:B34", :single, "Base", 1)   # Damage quadratic term 
    p[:a3] = getparams(f, "B35:B35", :single, "Base", 1)   # Damage exponent  

    # Abatement cost
    p[:expcost2]    = getparams(f, "B44:B44", :single, "Base", 1)   # Exponent of control cost function 
    p[:pbacktime]   = getparams(f, "B42:BI42", :all, "Base", T)     # backstop price
    # Adjusted cost for backstop (or: "Abatement cost function coefficient")
    p[:cost1]       = getparams(f, "B37:BI37", :all, "Base", T)

    # Scaling and inessential parameters
    p[:scale1] = getparams(f, "B88:B88", :single, "Base", 1)    # Multiplicative scaling coefficient
    p[:scale2] = getparams(f, "B89:B89", :single, "Base", 1)    # Additive scaling coefficient

    # Exogenous forcing for other greenhouse gases
    p[:forcoth] = getparams(f, "B70:BI70", :all, "Base", T)
    
    # Fraction of emissions in control regime
    p[:partfract] = getparams(f, "B82:BI82", :all, "Base", T)
  

    #SLR Parameters

    p[:slrcoeff]    = getparams(f, "B51:B51", :single, "Parameters", 1)
    p[:slrcoeffsq]  = getparams(f, "B52:B52", :single, "Parameters", 1)
    p[:slrexp]      = getparams(f, "B53:B53", :single, "Parameters", 1)

    p[:therm0]      = getparams(f, "B178:B178", :single, "Base", 1) #meters above 2000
    p[:gsic0]       = getparams(f, "B179:B179", :single, "Base", 1)
    p[:gis0]        = getparams(f, "B180:B180", :single, "Base", 1)
    p[:ais0]        = getparams(f, "B181:B181", :single, "Base", 1)

    p[:therm_asym]  = getparams(f, "B173:B173", :single, "Base", 1)
    p[:gsic_asym]   = getparams(f, "B174:B174", :single, "Base", 1)
    p[:gis_asym]    = getparams(f, "B175:B175", :single, "Base", 1)
    p[:ais_asym]    = getparams(f, "B176:B176", :single, "Base", 1)

    p[:thermrate]   = getparams(f, "C173:C173", :single, "Base", 1)
    p[:gsicrate]    = getparams(f, "C174:C174", :single, "Base", 1)
    p[:gisrate]     = getparams(f, "C175:C175", :single, "Base", 1)
    p[:aisrate]     = getparams(f, "C176:C176", :single, "Base", 1)

    p[:slrthreshold] = getparams(f, "D176:D176", :single, "Base", 1)

    return p
end
