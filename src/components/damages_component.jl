using Mimi


@defcomp damages begin
    DAMAGES = Variable(index=[time])    #Damages (trillions 2005 USD per year)
    DAMFRAC = Variable(index=[time])    #Increase in temperature of atmosphere (degrees C from 1900)

    TATM    = Parameter(index=[time])   #Increase temperature of atmosphere (degrees C from 1900)
    YGROSS  = Parameter(index=[time])   #Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
    a1      = Parameter()               #Damage intercept
    a2      = Parameter()               #Damage quadratic term
    a3      = Parameter()               #Damage exponent
    
    TotSLR  = Parameter(index=[time])   # Path of total SLR
    b1      = Parameter()               # Coefficient on SLR
    b2      = Parameter()               # Coefficient on quadratic SLR term
    b3      = Parameter()               # SLR exponent
end


function run_timestep(state::damages, t::Int)
    v = state.Variables
    p = state.Parameters

    #Define function for DAMFRAC
    v.DAMFRAC[t] = p.a1 * p.TATM[t] + p.a2 * p.TATM[t] ^ p.a3 + p.b1 * p.TotSLR[t] + p.b2 * p.TotSLR[t] ^ p.b3 

    #Define function for DAMAGES
    v.DAMAGES[t] = p.YGROSS[t] * v.DAMFRAC[t]
    
end
