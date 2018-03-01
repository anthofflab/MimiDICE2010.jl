using Mimi

@defcomp sealevelrise begin

    ThermSLR    = Variable(index=[time])    # Path of SLR from thermal expansion
    GSICSLR     = Variable(index=[time])    # Path of SLR from G&SIC
    GISSLR      = Variable(index=[time])    # Path of SLR from GIS
    AISSLR      = Variable(index=[time])    # Path of SLR from AIS
    TotSLR      = Variable(index=[time])    # Path of total SLR

    tempA       = Parameter(index=[time])   # Path of atmospheric temperature anomalies (from climate dynamics?)

    therm0      = Parameter()   # Initial SLR from thermal expansion (meters above 2000)
    gsic0       = Parameter()   # Initial SLR from G&SIC
    gis0        = Parameter()   # Initial SLR from GIS
    ais0        = Parameter()   # Initial SLR from AIS

    therm_asym  = Parameter()   # Asymptotic rise from thermal expansion 
    gsic_asym   = Parameter()   # Asymptotic rise from G&SIC 
    gis_asym    = Parameter()   # Asymptotic rise from GIS 
    ais_asym    = Parameter()   # Asymptotic rise from AIS 

    thermrate   = Parameter()   # Rate of thermal expansion
    gsicrate    = Parameter()   # Rate of G&SIC
    gisrate     = Parameter()   # Rate of GIS
    aisrate     = Parameter()   # Rate of AIS

    slrthreshold = Parameter()  # Temperature threshold for AIS

end 

function run_timestep(state::sealevelrise, t::Int)
    p = state.Parameters
    v = state.Variables

    if t==1
        v.ThermSLR[t]   = p.therm0
        v.GSICSLR[t]    = p.gsic0 
        v.GISSLR[t]     = p.gis0
        v.AISSLR[t]      = p.ais0
    else
        v.ThermSLR[t]   = v.ThermSLR[t-1] + p.thermrate * p.tempA[t]
        v.GSICSLR[t]    = v.GSICSLR[t-1] + p.gsicrate * (p.gsic_asym - v.GSICSLR[t-1]) * p.tempA[t]
        v.GISSLR[t]     = v.GISSLR[t-1] + p.gisrate * (p.gis_asym - v.GISSLR[t-1]) * p.tempA[t]
        v.AISSLR[t]     = 0
        if p.tempA[t] > p.slrthreshold
            v.AISSLR[t] = v.AISSLR[t-1] + p.aisrate * (p.ais_asym - v.AISSLR[t-1]) * p.tempA[t]
        end 
    end

    v.TotSLR[t] = v.ThermSLR[t] + v.GSICSLR[t] + v.GISSLR[t] + v.AISSLR[t]

end 