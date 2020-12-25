@defcomp damages begin
    DAMFRAC = Variable(index=[time])    # Damages (fraction of gross output)

    TATM    = Parameter(index=[time])   # Increase temperature of atmosphere (degrees C from 1900)
    YGROSS  = Parameter(index=[time])   # Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
    a1      = Parameter()               # Damage intercept
    a2      = Parameter()               # Damage quadratic term
    a3      = Parameter()               # Damage exponent
    
    TotSLR  = Parameter(index=[time])   # Path of total SLR
    b1      = Parameter()               # Coefficient on SLR
    b2      = Parameter()               # Coefficient on quadratic SLR term
    b3      = Parameter()               # SLR exponent

    function run_timestep(p, v, d, t)
        # Define function for DAMFRAC
        v.DAMFRAC[t] = p.a1 * p.TATM[t] + p.a2 * p.TATM[t]^p.a3 + p.b1 * p.TotSLR[t] + p.b2 * p.TotSLR[t]^p.b3  
    end

end
