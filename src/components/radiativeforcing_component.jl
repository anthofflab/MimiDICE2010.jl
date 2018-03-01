using Mimi

@defcomp radiativeforcing begin
    FORC      = Variable(index=[time])   #Increase in radiative forcing (watts per m2 from 1900)

    forcoth   = Parameter(index=[time])  #Exogenous forcing for other greenhouse gases
    MAT       = Parameter(index=[time])  #Carbon concentration increase in atmosphere (GtC from 1750)
    fco22x    = Parameter()              #Forcings of equilibrium CO2 doubling (Wm-2)

end

function run_timestep(state::radiativeforcing, t::Int)
    v = state.Variables
    p = state.Parameters

    #Define function for FORC
    if t != 60
        v.FORC[t] = p.fco22x * (log((((p.MAT[t] + p.MAT[t+1]) / 2) + 0.000001)/596.4)/log(2)) + p.forcoth[t]
    else 
        # but what about during the final timestep when there is no p.MAT[t+1] ?
        # use zero? looks like that's what Excel does for the final one
        v.FORC[t] = p.fco22x * (log((((p.MAT[t] + 0) / 2) + 0.000001)/596.4)/log(2)) + p.forcoth[t]
    end
end