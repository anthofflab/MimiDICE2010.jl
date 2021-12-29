include("../src/components/damages_component.jl")

@testset "damages" begin

    Precision = 1.0e-11
    T = length(MimiDICE2010.model_years)
    f = readxlsx(joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx"))

    m = Model()

    set_dimension!(m, :time, MimiDICE2010.model_years)

    add_comp!(m, damages, :damages)

    # Set the parameters that would normally be internal connection from their Excel values
    update_param!(m, :damages, :TATM, read_params(f, "B121:BI121", T))
    update_param!(m, :damages, :YGROSS, read_params(f, "B92:BI92", T))
    update_param!(m, :damages, :TotSLR, read_params(f, "B182:BI182", T))

    # Load the rest of the external parameters
    p = dice2010_excel_parameters(joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx"))
    update_param!(m, :damages, :a1, p[:unshared][(:damages, :a1)])
    update_param!(m, :damages, :a2, p[:unshared][(:damages, :a2)])
    update_param!(m, :damages, :a3, p[:unshared][(:damages, :a3)])
    update_param!(m, :damages, :b1, p[:unshared][(:damages, :b1)])
    update_param!(m, :damages, :b2, p[:unshared][(:damages, :b2)])
    update_param!(m, :damages, :b3, p[:unshared][(:damages, :b3)])

    # Run the one-component model
    run(m)

    # Extract the generated variables
    DAMFRAC = m[:damages, :DAMFRAC]

    # Extract the true values
    True_DAMFRAC = read_params(f, "B93:BI93", T)

    # Test that the values are the same
    @test maximum(abs, DAMFRAC .- True_DAMFRAC) ≈ 0. atol = Precision

end