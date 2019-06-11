
@defcomposite Climate begin

    # Add child components
    component(co2cycle)
    component(radiativeforcing)
    component(climatedynamics) 
    component(sealevelrise)

    # Resolve parameter name collisions
    fco22x = radiativeforcing.fco22x, climatedynamics.fco22x

    # Make internal connections
    radiativeforcing.MAT = co2cycle.MAT
    radiativeforcing.MAT_final = co2cycle.MAT_final
    climatedynamics.FORC = radiativeforcing.FORC
    sealevelrise.TATM = climatedynamics.TATM

    # Export variables
    TATM = climatedynamics.TATM
    TotSLR = sealevelrise.TotSLR

end