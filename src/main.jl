using Mimi

include("dice2010.jl")
using Dice2010

DICE = construct_dice()
run(DICE)

explore(DICE)
