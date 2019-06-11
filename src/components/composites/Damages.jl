
@defcomposite Damages begin

    # Add child components
    component(damages)
    component(neteconomy)
    component(welfare)

    # Resolve parameter namespace collisions
    YGROSS = damages.YGROSS, neteconomy.YGROSS

    # Make internal connections
    neteconomy.DAMFRAC = damages.DAMFRAC
    welfare.CPC = neteconomy.CPC

    # Export variables
    I = neteconomy.I 
    
end