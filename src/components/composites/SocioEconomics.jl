
@defcomposite SocioEconomics begin

    # Add child components
    component(grosseconomy) 
    component(emissions)

    # Make internal connections between child components
    emissions.YGROSS = grosseconomy.YGROSS

    # Export variables
    YGROSS = grosseconomy.YGROSS
    E = emissions.E

end