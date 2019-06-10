# TODO: rename?

# SocioEconomics, Climate, and Damages composites are defined in their own files

# the structure is currently:
#                                                       top 
#                       /                               |                                       \
#       SocioEconomics                              Climate                                         Damages 
#       /           \               /               /       \                \                      /       \        \
# grosseconomy, emissions       co2cycle, radiativeforcing, climatedynamics, sealevelrise       damages, neteconomy, welfare       

@defcomposite top begin

    component(SocioEconomics; exports = [])
    component(Climate; exports = [])
    component(Damages; exports = [])

    # This is what the old connections were between these components in the original flat model:
    # connect_param!(m, :co2cycle, :E, :emissions, :E)
    # connect_param!(m, :damages, :TATM, :climatedynamics, :TATM)
    # connect_param!(m, :damages, :YGROSS, :grosseconomy, :YGROSS)
    # connect_param!(m, :damages, :TotSLR, :sealevelrise, :TotSLR)
    # connect_param!(m, :neteconomy, :YGROSS, :grosseconomy, :YGROSS)
    # connect_param!(m, :grosseconomy, :I, :neteconomy, :I)

    # This is what the connections between the four main modules could look like now:
    Climate.E = SocioEconomics.E    # dot syntax could access exported variable E from SocioEconomics composite 
    Damages.YGROSS = SocioEconomics.YGROSS
    Damages.TATM = Climate.TATM
    Damages.TotSLR = Climate.TotSLR
    SocioEconomics.I = Damages.I    # this is the slightly funny cyclical connection that *should* work because it is offset

end