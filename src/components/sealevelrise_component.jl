using Mimi


@defcomp sealevelrise begin

    ThermSLR    = Variable(index=[time])    # Path of SLR from thermal expansion
    GSICSLR     = Variable(index=[time])    # Path of SLR from G&SIC
    GISSLR      = Variable(index=[time])    # Path of SLR from GIS
    AISSLR      = Variable(index=[time])    # Path of SLR from AIS
    TotSLR      = Variable(index=[time])    # Path of total SLR

    TATM        = Parameter(index=[time])   # Path of atmospheric temperature anomalies (from climate dynamics?)

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

    function run_timestep(p, v, d, t)
        if t==1
            v.ThermSLR[t] = thermslr = p.therm0
            v.GSICSLR[t]  = gsicslr  = p.gsic0 
            v.GISSLR[t]   = gisslr   = p.gis0
            v.AISSLR[t]   = aisslr   = p.ais0
        else
            tatm = p.TATM[t]
            old_gsicslr = v.GSICSLR[t-1]
            old_gisslr  = v.GISSLR[t-1]

            v.ThermSLR[t] = thermslr = v.ThermSLR[t-1] + p.thermrate * tatm
            v.GSICSLR[t]  = gsicslr = old_gsicslr + p.gsicrate * (p.gsic_asym - old_gsicslr) * tatm
            v.GISSLR[t]   = gisslr  = old_gisslr  + p.gisrate  * (p.gis_asym  - old_gisslr)  * tatm
            v.AISSLR[t]   = aisslr = 0

            if tatm > p.slrthreshold
                old_aisslr = v.AISSLR[t-1]
                v.AISSLR[t] = aisslr = old_aisslr + p.aisrate * (p.ais_asym - old_aisslr) * tatm
            end 
        end
    
        v.TotSLR[t] = thermslr + gsicslr + gisslr + aisslr
    end
end

# function run_timestep(p, v, d, t)
#     if t==1
#         v.ThermSLR[t]   = p.therm0
#         v.GSICSLR[t]    = p.gsic0 
#         v.GISSLR[t]     = p.gis0
#         v.AISSLR[t]      = p.ais0
#     else       
#         v.ThermSLR[t]   = v.ThermSLR[t-1] + p.thermrate * p.TATM[t]
#         v.GSICSLR[t]    = v.GSICSLR[t-1] + p.gsicrate * (p.gsic_asym - v.GSICSLR[t-1]) * p.TATM[t]
#         v.GISSLR[t]     = v.GISSLR[t-1] + p.gisrate * (p.gis_asym - v.GISSLR[t-1]) * p.TATM[t]
#         v.AISSLR[t]     = 0
#         if p.TATM[t] > p.slrthreshold
#             v.AISSLR[t] = v.AISSLR[t-1] + p.aisrate * (p.ais_asym - v.AISSLR[t-1]) * p.TATM[t]
#         end 
#     end

#     v.TotSLR[t] = v.ThermSLR[t] + v.GSICSLR[t] + v.GISSLR[t] + v.AISSLR[t]
# end
