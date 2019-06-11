# the structure is currently:
#                                                     DICE2010                        
#              ----------------------------------------------------------------------------------------------
#              |                                         |                                                   |
#       SocioEconomics                                Climate                                             Damages 
#       -------------                ---------------------------------------------                  -------------------
#      |             |               |            |                |              |                 |        |         |
# grosseconomy  emissions       co2cycle  radiativeforcing  climatedynamics  sealevelrise       damages  neteconomy  welfare       

@defcomposite DICE2010 begin

    # Add child components
    component(SocioEconomics)
    component(Climate)
    component(Damages)

    # Make internal connections
    Climate.E = SocioEconomics.E
    Damages.YGROSS = SocioEconomics.YGROSS
    Damages.TATM = Climate.TATM
    Damages.TotSLR = Climate.TotSLR
    SocioEconomics.I = Damages.I

end