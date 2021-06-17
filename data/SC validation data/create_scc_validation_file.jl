# This file can be used to create the validation file for deterministic scc values. 
# It will create a validation file containing all possibilities of parameter values 
# defined in the specs dictionary below produce the same results. 

using MimiDICE2010
using DataFrames
using Query
using CSVFiles
using Test

specs = Dict([
    :year => [2015, 2055],
    :eta => [0, 1.5],
    :prtp => [0.015, 0.03],
    :last_year => [2295, 2595],
    :pulse_size => [1e3, 1e7, 1e10]
])

results = DataFrame(year = [], eta = [], prtp = [], last_year = [], pulse_size = [], SC = [])

for year in specs[:year]
    for eta in specs[:eta]
        for prtp in specs[:prtp]
            for last_year in specs[:last_year]
                for pulse_size in specs[:pulse_size]
                    sc = MimiDICE2010.compute_scc(year=Int(year), eta=eta, prtp=prtp, last_year=Int(last_year), pulse_size=pulse_size)
                    push!(results, (year, eta, prtp, last_year, pulse_size, sc))
                end
            end
        end
    end
end

path = joinpath(@__DIR__, "deterministic_sc_values_v1-0-1.csv")
save(path, results)
