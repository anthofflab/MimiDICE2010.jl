include("../src/components/neteconomy_component.jl")

@testset "neteconomy" begin

    Precision = 1.0e-11
    T = 60
    f = readxlsx(joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx"))

    m = Model()

    set_dimension!(m, :time, MimiDICE2010.model_years)

    add_comp!(m, neteconomy, :neteconomy)

    # Set the parameters that would normally be internal connection from their Excel values
    update_param!(m, :neteconomy, :YGROSS, read_params(f, "B92:BI92", T))
    update_param!(m, :neteconomy, :DAMFRAC, read_params(f, "B93:BI93", T))

    # Load the rest of the external parameters
    p = dice2010_excel_parameters(joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx"))
    update_param!(m, :neteconomy, :cost1, p[:unshared][(:neteconomy, :cost1)])
    update_param!(m, :neteconomy, :MIU, p[:shared][:MIU]) # shared parameter
    update_param!(m, :neteconomy, :expcost2, p[:unshared][(:neteconomy, :expcost2)])
    update_param!(m, :neteconomy, :partfract, p[:unshared][(:neteconomy, :partfract)])
    update_param!(m, :neteconomy, :pbacktime, p[:unshared][(:neteconomy, :pbacktime)])
    update_param!(m, :neteconomy, :S,  p[:unshared][(:neteconomy, :S)])
    update_param!(m, :neteconomy, :l, p[:shared][:l]) # shared parameter

    # Run the one-component model
    run(m)

    # Extract the generated variables
    ABATECOST   = m[:neteconomy, :ABATECOST]
    C           = m[:neteconomy, :C]
    CPC         = m[:neteconomy, :CPC]
    CPRICE      = m[:neteconomy, :CPRICE]
    I           = m[:neteconomy, :I]
    Y           = m[:neteconomy, :Y]
    YNET        = m[:neteconomy, :YNET]

    # Extract the true values
    True_ABATECOST  = read_params(f, "B97:BI97", T)
    True_C          = read_params(f, "B125:BI125", T)
    True_CPC        = read_params(f, "B126:BI126", T)
    True_CPRICE     = read_params(f, "B134:BI134", T)
    True_I          = read_params(f, "B101:BI101", T)
    True_Y          = read_params(f, "B98:BI98", T)
    True_YNET       = read_params(f, "B95:BI95", T)


    # Test that the values are the same
    @test maximum(abs, ABATECOST .- True_ABATECOST) ≈ 0. atol = Precision
    @test maximum(abs, C .- True_C) ≈ 0. atol = Precision
    @test maximum(abs, CPC .- True_CPC) ≈ 0. atol = Precision
    @test maximum(abs, CPRICE .- True_CPRICE) ≈ 0. atol = Precision
    @test maximum(abs, I .- True_I) ≈ 0. atol = Precision
    @test maximum(abs, Y .- True_Y) ≈ 0. atol = Precision
    @test maximum(abs, YNET .- True_YNET) ≈ 0. atol = Precision

end
