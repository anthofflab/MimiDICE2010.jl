
@defcomposite Damages begin

    # export variable I because it is needed for a connection with SocioEconomics
    component(damages; exports = [YGROSS, TATM, TotSLR])    # export these parameters because they will receive internal connections in the top component
    component(neteconomy; exports = [I, YGROSS])
    component(welfare)

    # Would like to make connections that are internal to this composite component here
    # Maybe the following syntax:
    neteconomy.DAMFRAC = damages.DAMFRAC
    welfare.CPC = neteconomy.CPC

    # OR other possible syntax:
    connect(neteconomy => DAMFRAC, damages => DAMFRAC)
    connect(welfare => CPC, neteconomy => CPC)

end