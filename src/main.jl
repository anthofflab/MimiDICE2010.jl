using Mimi

include("dice2010.jl")
using dice2010

DICE = construct_dice()
run(DICE)

explore(DICE)
