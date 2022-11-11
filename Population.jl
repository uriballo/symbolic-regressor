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

    constantProb::Float64 # Probability of a constant being chosen when creating a random expression.
    terminalProb::Float64 # Probability of a terminal being chosen when creating a random expression.
    operatorProb::Float64 # Probability of an operator being chosen when creating a random expression.

    percentageofparents::Float64 # Percentage of parents to use per generation, ∈ (0, 1]

    inputs::Matrix{Float64}
    outputs::Vector{Float64}
end

mutable struct SymPopulation
    config::Config

    population::Array{sym.SymNode,1}
end

function Base.show(io::IO, ppl::SymPopulation)
    println(io, "# Population:")
    for i = 1:length(ppl.population)
        println(io, "  ", i, ": ", ppl.population[i])
        println(
            io,
            "    Fitness: ",
            ppl.config.fitness(ppl.population[i], ppl.config.inputs, ppl.config.outputs),
            "\n",
        )
    end
end

function Base.:∉(x, xs)
    for i in eachindex(xs)
        if x == xs[i]
            return false
        end
    end
    true
end

function Base.unique(ppl)
    uniqueppl = Array{sym.SymNode,1}()

    for i in eachindex(ppl)
        if (ppl[i] ∉ uniqueppl)
            push!(uniqueppl, ppl[i])
        end
    end
    uniqueppl
end

function randomNode(config)
    type = rand()
    if type < config.constantProb
        ct = copy(config.constantSet[rand(1:length(config.constantSet))])
        ct
    elseif type < config.terminalProb
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

function fitnessMSE(symexpr::sym.SymNode, inputs, outputs)
    prediction = []

    for column in eachcol(inputs)
        pred = sym.eval(symexpr, column)
        push!(prediction, pred)
    end

    if all(isone, prediction)
        return 999
    end

    sum((prediction .- outputs) .^ 2) / length(outputs)
end

function fitness(symexpr::sym.SymNode, inputsMatrix, outputsVector)
    # L2 Metric
    prediction = []

    for column in eachcol(inputsMatrix)
        pred = sym.eval(symexpr, column)
        push!(prediction, pred)
    end

    if all(isone, prediction)
        return 999
    end

    normpred = sqrt(sum(prediction .^ 2))
    normout = sqrt(sum(outputsVector .^ 2))

    prednormalized = prediction ./ normpred
    outnormalized = outputsVector ./ normout

    ftness = sqrt(sum((outnormalized .- prednormalized) .^ 2))

    ftness === NaN ? 999 : ftness
end

function fitness(symexpr::sym.Constant, inputsMatrix, outputsVector)
    999 # we suppose that a constant does not model any phenomenon
end

# Multiple Dispatch
function crossover(symexpr1::sym.Constant, symexpr2::sym.Constant)
    rand() < 0.5 ? copy(symexpr1) : copy(symexpr2)
end

function crossover(symexpr1::sym.Param, symexpr2::sym.Param)
    rand() < 0.5 ? copy(symexpr1) : copy(symexpr2)
end

function crossover(symexpr1::sym.Param, symexpr2::sym.Constant)
    rand() < 0.5 ? copy(symexpr1) : copy(symexpr2)
end

function crossover(symexpr1::sym.Constant, symexpr2::sym.Param)
    crossover(symexpr2, symexpr1)
end

function crossover(symexpr1::sym.Operator, symexpr2::sym.Operator)
    choice = rand()

    if choice < 0.5
        chosenNode = sym.random(symexpr1)
        nodePosition = rand(0:sym.nnodes(symexpr2)-1)
        child = copy(symexpr2)
        child = sym.set(child, nodePosition, chosenNode)
    else
        chosenNode = sym.random(symexpr2)
        nodePosition = rand(0:sym.nnodes(symexpr1)-1)
        child = copy(symexpr1)
        child = sym.set(child, nodePosition, chosenNode)
    end

    child
end

function crossover(symexpr1::sym.Operator, symexpr2)
    chosenNode = copy(symexpr2)
    nodePosition = rand(0:sym.nnodes(symexpr1)-1)
    child = copy(symexpr1)
    child = sym.set(child, nodePosition, chosenNode)

    child
end

function crossover(symexpr1, symexpr2::sym.Operator)
    crossover(symexpr2, symexpr1)
end

function mutate!(symexpr, context)
    mutation = randomExpr(context)
    mutationNode = rand(0:sym.nnodes(symexpr)-1)
    sym.set!(symexpr, mutationNode, mutation)
end

function mutate(symexpr, context)
    mutation = randomExpr(context)
    mutationNode = rand(0:sym.nnodes(symexpr)-1)

    child = copy(symexpr)

    sym.set(child, mutationNode, mutation)
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

function select(population, config, n)
    sortedpop = sortp(population, config)
    sortedpop[1:n]
end

function sortp(population, config)
    sort(population, by = x -> config.fitness(x, config.inputs, config.outputs))
end

# update so it uses the config
function evolve(population, iterations, config, verbose = false)
    population.population = sortp(population.population, config)

    for i = 1:iterations
        if verbose
            println("####################")
            println("Iteration ", i)
            println(population)
        end

        popsize = trunc(Int, size(population.population, 1) * config.percentageofparents)

        # Selection
        chosenParents = select(population.population, config, popsize)

        if verbose
            println("\n########################")
            println("Current Best: ", chosenParents[1])
            println(
                "\t\tFitness: ",
                config.fitness(chosenParents[1], config.inputs, config.outputs),
            )
        end

        # Crossover
        children = Array{sym.SymNode,1}()

        nparents = length(chosenParents)
        for i = 1:nparents
            parent1 = chosenParents[i]
            parent2 = chosenParents[rand(1:nparents)]

            child = crossover(parent1, parent2)

            push!(children, child)
        end

        newpop = vcat(chosenParents, children, population.population)

        newpopsize = length(newpop)

        # Mutation
        mutations = Array{sym.SymNode,1}()

        for j = 1:newpopsize
            if rand() < config.mutationProb
                mutated = mutate(newpop[j], config)
                push!(mutations, mutated)
            end
        end

        newpop = unique(vcat(newpop, mutations))

        # Update population
        population.population = sortp(newpop, config)
    end

    println("####################")
    sortedpop = sortp(population.population, config)
    println("Final Best: ", sortedpop[1])
    #for column in config.inputs
    #    println("Input: ", column, " Output: ", sym.eval(sortedpop[1], column))
    #end
end

BasicOperators = [
    sym.Operator("+", 2, +),
    sym.Operator("-", 2, -),
    sym.Operator("⋅", 2, *),
    sym.Operator("÷", 2, /),
    sym.Operator("²", 1, x -> x^2),
    sym.Operator("³", 1, x -> x^3),
    sym.Operator("⁻¹", 1, x -> 1 / x),
]

BasicTerminals = [sym.Param("R", 1), sym.Param("T", 2)]

BasicConstants = [sym.Constant("π", π)]

#@time begin
inputs = CSV.read("data/kepler1618-inputs.csv", DataFrame)
outputs = CSV.read("data/kepler1618-outputs.csv", DataFrame)

outputVec = vec(Matrix(outputs))
inputMat = transpose(Matrix(inputs)) #isgood
#end

"""
This config discovers Kepler's third law somewhat consistently.
"""
TestConfig = Config(
    fitness,
    crossover,
    mutate,
    1,
    BasicOperators,
    BasicTerminals,
    BasicConstants,
    0.05,
    0.55,
    0.45,
    1,
    inputMat,
    outputVec,
)

#@time begin
poppl = SymPopulation(TestConfig, seed(35, TestConfig))
evolve(poppl, 500, TestConfig, true)
println()
#end

end
