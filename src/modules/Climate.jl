
@defcomposite Climate begin

    # Export TATM and TotSLR because they are needed for top level connections for the Damages module
    component(co2cycle; exports = [E])
    component(radiativeforcing)    # QUESTION: radiativeforcing and climatedynamics both have external parameters of the name :fco22x, but they should both be set to the same external data value, so do I not have to rename them with export?
    component(climatedynamics; exports = [TATM]) 
    component(sealevelrise; exports = [TotSLR])

    # Would like to make connections that are internal to this composite component here
    # Maybe the following syntax:
    radiativeforcing.MAT = co2cycle.MAT
    radiativeforcing.MAT_final = co2cycle.MAT_final
    climatedynamics.FORC = radiativeforcing.FORC
    sealevelrise.TATM = climatedynamics.TATM

    # OR other possible syntax:
    connect(radiativeforcing => MAT, co2cycle => MAT)
    connect(radiativeforcing => MAT_final, co2cycle => MAT_final)
    connect(climatedynamics => FORC, radiativeforcing => FORC)
    connect(sealevelrise => TATM, climatedynamics => TATM)

end