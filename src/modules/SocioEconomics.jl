
@defcomposite SocioEconomics begin

    # Export variables YGROSS and E because they are needed for top level connections with the Climate and Damages modules
    component(grosseconomy; exports = [YGROSS, I])  # should we also export parameter :I because it will receive an internal connection in the :top component?
    component(emissions; exports = [E])

    # Would like to make connections that are internal to this composite component here
    # Maybe the following syntax:
    emissions.YGROSS = grosseconomy.YGROSS
    # OR other possible syntax:
    connect(emissions => YGROSS, grosseconomy => YGROSS)

end