include("../src/components/climatedynamics_component.jl")

@testset "climatedynamics" begin

    Precision = 1.0e-11
    T = length(MimiDICE2010.model_years)
    f = readxlsx(joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx"))

    m = Model()

    set_dimension!(m, :time, MimiDICE2010.model_years)

    add_comp!(m, climatedynamics, :climatedynamics)

    # Set the parameters that would normally be internal connection from their Excel values

    update_param!(m, :climatedynamics, :FORC, read_params(f, "B122:BI122", T))

    # Load the rest of the external parameters
    p = dice2010_excel_parameters(joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx"))
    update_param!(m, :climatedynamics, :fco22x, p[:shared][:fco22x]) # shared parameter
    update_param!(m, :climatedynamics, :t2xco2, p[:unshared][(:climatedynamics, :t2xco2)])
    update_param!(m, :climatedynamics, :tatm0, p[:unshared][(:climatedynamics, :tatm0)])
    update_param!(m, :climatedynamics, :tatm1, p[:unshared][(:climatedynamics, :tatm1)])
    update_param!(m, :climatedynamics, :tocean0, p[:unshared][(:climatedynamics, :tocean0)])
    update_param!(m, :climatedynamics, :c1, p[:unshared][(:climatedynamics, :c1)])
    update_param!(m, :climatedynamics, :c3, p[:unshared][(:climatedynamics, :c3)])
    update_param!(m, :climatedynamics, :c4, p[:unshared][(:climatedynamics, :c4)])

    # Run the one-component model
    run(m)

    # Extract the generated variables
    TATM    = m[:climatedynamics, :TATM]
    TOCEAN  = m[:climatedynamics, :TOCEAN]

    # Extract the true values
    True_TATM   = read_params(f, "B121:BI121", T)
    True_TOCEAN = read_params(f, "B123:BI123", T)

    # Test that the values are the same
    @test maximum(abs, TATM .- True_TATM) ≈ 0. atol = Precision
    @test maximum(abs, TOCEAN .- True_TOCEAN) ≈ 0. atol = Precision

end
