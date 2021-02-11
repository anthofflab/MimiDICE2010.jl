@defcomp radiativeforcing begin
    FORC      = Variable(index=[time])   # Increase in radiative forcing (watts per m2 from 1900)

    forcoth   = Parameter(index=[time])  # Exogenous forcing for other greenhouse gases
    MAT       = Parameter(index=[time])  # Carbon concentration increase in atmosphere (GtC from 1750)
    MAT_final = Parameter()              # MAT calculation one timestep further than the model's index   
    fco22x    = Parameter()              # Forcings of equilibrium CO2 doubling (Wm-2)

    function run_timestep(p, v, d, t)
        # Define function for FORC
        if ! is_last(t)
            v.FORC[t] = p.fco22x * (log((((p.MAT[t] + p.MAT[t + 1]) / 2) + 0.000001) / 596.4) / log(2)) + p.forcoth[t]
        else # final timestep
            # need to use MAT_final, calculated one step further 
            v.FORC[t] = p.fco22x * (log((((p.MAT[t] + p.MAT_final) / 2) + 0.000001) / 596.4) / log(2)) + p.forcoth[t]
        end
    end
end
