using Mimi


@defcomp co2cycle begin
    MAT     = Variable(index=[time])    #Carbon concentration increase in atmosphere (GtC from 1750)
    MAT61   = Variable()                #MAT calculation one timestep further than the model's index  
    ML      = Variable(index=[time])    #Carbon concentration increase in lower oceans (GtC from 1750)
    MU      = Variable(index=[time])    #Carbon concentration increase in shallow oceans (GtC from 1750)

    E       = Parameter(index=[time])   #Total CO2 emissions (GtCO2 per year)
    mat0    = Parameter()               #Initial Concentration in atmosphere 2000 (GtC)
    mat1    = Parameter()               #Concentration 2010 (GtC)
    ml0     = Parameter()               #Initial Concentration in lower strata (GtC)
    mu0     = Parameter()               #Initial Concentration in upper strata (GtC)

    #Parameters for long-run consistency of carbon cycle
    b11     = Parameter()               #Carbon cycle transition matrix atmosphere to atmosphere
    b12     = Parameter()               #Carbon cycle transition matrix atmosphere to shallow ocean
    b21     = Parameter()               #Carbon cycle transition matrix biosphere/shallow oceans to atmosphere
    b22     = Parameter()               #Carbon cycle transition matrix shallow ocean to shallow oceans
    b23     = Parameter()               #Carbon cycle transition matrix shallow to deep ocean
    b32     = Parameter()               #Carbon cycle transition matrix deep ocean to shallow ocean
    b33     = Parameter()               #Carbon cycle transition matrix deep ocean to deep oceans

    function run_timestep(p, v, d, t)
        # Define functions for MU, ML, and MAT
        if is_first(t)
            v.MU[t] = p.mu0

            v.ML[t] = p.ml0

            v.MAT[1] = p.mat0
            v.MAT[2] = p.mat1

        else      

            v.MU[t] = v.MAT[t-1] * p.b12 + v.MU[t-1] * p.b22 + v.ML[t-1] * p.b32

            v.ML[t] = v.ML[t-1] * p.b33 + v.MU[t-1] * p.b23

            #TODO: change to a non-t.t access when porting to 1.0
            if t.t < 60
                v.MAT[t+1] = v.MAT[t] * p.b11 + v.MU[t] * p.b21 + p.E[t] * 10
            
            #TODO: change to is_timestep(t, 60) when porting to 1.0
            elseif t.t == 60
                v.MAT61 = v.MAT[t] * p.b11 + v.MU[t] * p.b21 + p.E[t] * 10
            end
        end
    end
end
