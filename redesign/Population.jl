module Population
using CSV
using DataFrames

include("SymExpr.jl")

import .SymExpr as sym

struct Config 
    fitness::Function
    crossover::Function
    mutate::Function

    mutationProb::Float64

    functionSet::Vector{sym.Operator}
    terminalSet::Vector{sym.Param}
    constantSet::Vector{sym.Constant}

    inputs::Matrix{Float64}
    outputs::Vector{Float64}
end

mutable struct SymPopulation
    config::Config

    population::Array{sym.SymNode,1}
end


function Base.show(io::IO, ppl::SymPopulation)
    println(io, "# Population:")
    for i in 1:length(ppl.population)
        println(io, "  ", i, ": ", ppl.population[i])
        println(io, "    Fitness: ", ppl.config.fitness(ppl.population[i], ppl.config.inputs, ppl.config.outputs), "\n")
    end
end

function randomNode(config)
    type = rand()
    if type < 0.05
        ct = copy(config.constantSet[rand(1:length(config.constantSet))])
        ct
    elseif type < 0.75
        par = copy(config.terminalSet[rand(1:length(config.terminalSet))])
        par
    else
        op = copy(config.functionSet[rand(1:length(config.functionSet))])
        op
    end
end

function randomExpr(config)
    root = randomNode(config)

    if typeof(root) == sym.Operator
        if root.arity == 1
            root.leftInput = randomExpr(config)
        elseif root.arity == 2
            root.leftInput = randomExpr(config)
            root.rightInput = randomExpr(config)
        end
    end

    root
end

function fitness(symexpr::sym.SymNode, inputsMatrix, outputsVector)
    # L2 Metric

    prediction = []
    for column in eachcol(inputsMatrix)
        pred = sym.eval(symexpr, column)
        push!(prediction, pred)
    end

    normpred = sqrt(sum(prediction .^2))
    normout = sqrt(sum(outputsVector .^2))

    prednormalized = prediction ./ normpred
    outnormalized = outputsVector ./ normout

    ftness = sqrt(sum((outnormalized - prednormalized) .^ 2)) #+ sym.complexity(symexpr)/20 # we want simple expressions

    ftness === NaN ? 999 : ftness
end

function fitness(symexpr::sym.Constant, inputsMatrix, outputsVector)
    999 # we suppose that a constant does not model any phenomenon
end

function seed(size, config)
    pop = Array{sym.SymNode,1}()
    while length(pop) < size
        rexpr = randomExpr(config)
        if rexpr ∉ pop
            push!(pop, rexpr)
        end
    end

    pop
end

BasicOperators = [
    sym.Operator("+", 2, +),
    sym.Operator("-", 2, -),
    sym.Operator("⋅", 2, *),
    sym.Operator("÷", 2, /),
    sym.Operator("^2", 1, x -> x^2),
    sym.Operator("^3", 1, x -> x^3),
]

BasicTerminals = [
    sym.Param("R", 1),
    sym.Param("T", 2),
]

BasicConstants = [
    sym.Constant("𝔾", 6.67430E-11),
]

#@time begin
    inputs = CSV.read("../data/kepler1618-inputs.csv", DataFrame)
    outputs = CSV.read("../data/kepler1618-outputs.csv", DataFrame)

    outputVec = vec(Matrix(outputs))
    inputMat = transpose(Matrix(inputs)) #isgood
#end

TestConfig = Config(fitness, identity, identity, 0.1, BasicOperators, BasicTerminals, BasicConstants, inputMat, outputVec)
@time begin
    poppl = SymPopulation(TestConfig, seed(20, TestConfig))
    poppl.population = sort(poppl.population, by = x -> TestConfig.fitness(x, TestConfig.inputs, TestConfig.outputs), rev = false)
    println(poppl)
end

end