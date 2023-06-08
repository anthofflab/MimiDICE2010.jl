include("../src/components/co2cycle_component.jl")

@testset "co2cycle" begin

    Precision = 1.0e-11
    T = length(MimiDICE2010.model_years)
    f = readxlsx(joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx"))

    m = Model()

    set_dimension!(m, :time, MimiDICE2010.model_years)

    add_comp!(m, co2cycle, :co2cycle)

    # Set the parameters that would normally be internal connection from their Excel values
    update_param!(m, :co2cycle, :E, read_params(f, "B109:BI109", T))

    # Load the rest of the external parameters
    p = dice2010_excel_parameters(joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx"))
    update_param!(m, :co2cycle, :mat0, p[:unshared][(:co2cycle, :mat0)])
    update_param!(m, :co2cycle, :mat1, p[:unshared][(:co2cycle, :mat1)])
    update_param!(m, :co2cycle, :mu0, p[:unshared][(:co2cycle, :mu0)])
    update_param!(m, :co2cycle, :ml0, p[:unshared][(:co2cycle, :ml0)])
    update_param!(m, :co2cycle, :b12, p[:unshared][(:co2cycle, :b12)])
    update_param!(m, :co2cycle, :b23, p[:unshared][(:co2cycle, :b23)])
    update_param!(m, :co2cycle, :b11, p[:unshared][(:co2cycle, :b11)])
    update_param!(m, :co2cycle, :b21, p[:unshared][(:co2cycle, :b21)])
    update_param!(m, :co2cycle, :b22, p[:unshared][(:co2cycle, :b22)])
    update_param!(m, :co2cycle, :b32, p[:unshared][(:co2cycle, :b32)])
    update_param!(m, :co2cycle, :b33, p[:unshared][(:co2cycle, :b33)])

    # Run the one-component model
    run(m)

    # Extract the generated variables
    MAT = m[:co2cycle, :MAT]
    MAT_final = m[:co2cycle, :MAT_final]
    ML = m[:co2cycle, :ML]
    MU = m[:co2cycle, :MU]

    # Extract the true values
    True_MAT = read_params(f, "B112:BI112", T)
    True_MAT_final = read_params(f, "BJ112")
    True_ML = read_params(f, "B115:BI115", T)
    True_MU = read_params(f, "B114:BI114", T)

    # Test that the values are the same
    @test maximum(abs, MAT .- True_MAT) ≈ 0. atol = Precision
    @test abs(MAT_final - True_MAT_final) ≈ 0. atol = Precision
    @test maximum(abs, ML .- True_ML) ≈ 0. atol = Precision
    @test maximum(abs, MU .- True_MU) ≈ 0. atol = Precision

end
