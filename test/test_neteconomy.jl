using Mimi
using Base.Test
using ExcelReaders

include("../src/helpers.jl")
include("../src/parameters.jl")
include("../src/components/neteconomy_component.jl")

Precision = 1.0e-11
T = 60
f = openxl("../Data/DICE2010_082710d.xlsx")

m = Model()

setindex(m, :time, collect(2005:10:2595))

addcomponent(m, neteconomy)

# Set the parameters that would normally be internal connection from their Excel values
setparameter(m, :neteconomy, :YGROSS, getparams(f, "B92:BI92", :all, "Base", T))
setparameter(m, :neteconomy, :DAMAGES, getparams(f, "", :all, "Base", T))

# Load the rest of the external parameters
p = getdice2010excelparameters("../Data/DICE2010_082710d.xlsx")
setparameter(m, :neteconomy, :cost1, p[:cost1])
setparameter(m, :neteconomy, :MIU, p[:miubase])
setparameter(m, :neteconomy, :expcost2, p[:expcost2])
setparameter(m, :neteconomy, :partfract, p[:partfract])
setparameter(m, :neteconomy, :pbacktime, p[:pbacktime])
setparameter(m, :neteconomy, :S, p[:savebase])
setparameter(m, :neteconomy, :l, p[:l])

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
True_ABATECOST  = getparams(f, "B97:BI97", :all, "Base", T)
True_C          = getparams(f, "B125:BI125", :all, "Base", T)
True_CPC        = getparams(f, "B126:BI126", :all, "Base", T)
True_CPRICE     = getparams(f, "B134:BI134", :all, "Base", T)   # this right?
True_I          = getparams(f, "B101:BI101", :all, "Base", T)
True_Y          = getparams(f, "B98:BI98", :all, "Base", T)
True_YNET       = getparams(f, "B95:BI95", :all, "Base", T)

# Test that the values are the same
@test maximum(abs, ABATECOST .- True_ABATECOST) ≈ 0. atol = Precision
@test maximum(abs, C .- True_C) ≈ 0. atol = Precision
@test maximum(abs, CPC .- True_CPC) ≈ 0. atol = Precision
@test maximum(abs, CPRICE .- True_CPRICE) ≈ 0. atol = Precision
@test maximum(abs, I .- True_I) ≈ 0. atol = Precision
@test maximum(abs, Y .- True_Y) ≈ 0. atol = Precision
@test maximum(abs, YNET .- True_YNET) ≈ 0. atol = Precision
