include("../src/components/radiativeforcing_component.jl")

@testset "radiativeforcing" begin

    Precision = 1.0e-11
    T = length(MimiDICE2010.model_years)
    f = readxlsx(joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx"))

    m = Model()

    set_dimension!(m, :time, MimiDICE2010.model_years)

    add_comp!(m, radiativeforcing, :radiativeforcing)

# Set the parameters that would normally be internal connection from their Excel values
    set_param!(m, :radiativeforcing, :MAT, read_params(f, "B112:BI112", T))
    set_param!(m, :radiativeforcing, :MAT_final, read_params(f, "BJ112"))

# Load the rest of the external parameters
    p = dice2010_excel_parameters(joinpath(@__DIR__, "..", "data", "DICE2010_082710d.xlsx"))
    set_param!(m, :radiativeforcing, :forcoth, p[:forcoth])
    set_param!(m, :radiativeforcing, :fco22x, p[:fco22x])

# Run the one-component model
    run(m)

# Extract the generated variables
    FORC = m[:radiativeforcing, :FORC]

# Extract the true values
    True_FORC    = read_params(f, "B122:BI122", T)

# Test that the values are the same
    @test maximum(abs, FORC .- True_FORC) ≈ 0. atol = Precision

end