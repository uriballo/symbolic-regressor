module GTPopulation

using CSV
using DataFrames

include("GTree.jl")

import .GTrees as GT

struct Config
    fitness::Function
    crossover::Function
    mutate::Function
    selection::Function

    mutationprob::Float64

    termset::Array{GT.GTLeaf, 1}
    funcset::Array{GT.GTNode, 1}

    inputs::Matrix{Float64}
    outputs::Vector{Float64}
    nparents::Int
end

mutable struct Population
    population::Array{GT.GTree,1}
    context::Config
end

function Base.show(io::IO, pop::Population)
    println(io,"###############################")
    println(io,"# Population Size: ", length(pop.population))
    for i in 1:length(pop.population)
        println(io, "> $i.", pop.population[i])
    end
end

"""
Population Dynamics
"""
function roulette(population, n)
    winners = []
    inputs = population.context.inputs
    outputs = population.context.outputs
    pop = population.population

    fitnesses = [population.context.fitness(x, inputs, outputs) for x in pop]
    probabilities = fitnesses ./ sum(fitnesses)
    # TODO: finish
end

function elitist(population, n)
    inputs = population.context.inputs
    outputs = population.context.outputs
    pop = population.population
    ctx = population.context

    sorted = sort(pop, by = x -> ctx.fitness(x, inputs, outputs), rev = false)
    sorted[1:n]
end

function loadinputs(filename)
    inputs = CSV.read("../data/" * filename, DataFrame)

    transpose(Matrix(inputs))
end

function loadoutputs(filename)
    outputs = CSV.read("../data/" * filename, DataFrame)

    vec(Matrix(outputs))
end

function evolve(population, generations, verbose = false)
    ctx = population.context
    pop = population.population

    for i in 1:generations
        parents = elitist(population, ctx.nparents)

        if verbose 
            println("#############################")
            println("Generation $i")
            println("Best Candidate: $(parents[1])")
            println("\tFitness: $(ctx.fitness(parents[1], ctx.inputs, ctx.outputs))")  
        end

        children = []
        for parent in parents 
            secondparent = parents[rand(1:length(parents))]
            child = ctx.crossover(parent, secondparent)
            if rand() < ctx.mutationprob
                child = ctx.mutate(child, ctx.funcset, ctx.termset)
            end
            push!(children, child)
        end

        population.population = vcat(parents, children)
    end
end


"""
Parameters by A Field Guide to Genetic Programming
    population size (should be at least 500)
    probability of mutation
    > (half-and-half) range 2-6 is optimal
    number of generations betweem 10 and 50
"""

FuncSet = [
    GT.GTUnaryNode(x -> x^2, "²"),
    GT.GTUnaryNode(x -> x^3, "³"),
    GT.GTUnaryNode(x -> 1/x, "⁻¹"),
    GT.GTBinaryNode(+, "+"),
    GT.GTBinaryNode(-, "-"),
    GT.GTBinaryNode(*, "×"),
    GT.GTBinaryNode(/, "÷"),
]

TermSet = [
    GT.GTParameter(1, "R"),
    GT.GTParameter(2, "T"),
]

sampleConfig = Config(
    GT.L2fitness,
    GT.crossover,
    GT.mutate,
    elitist,
    0.15,
    TermSet,
    FuncSet,
    loadinputs("kepler1618-inputs.csv"),
    loadoutputs("kepler1618-outputs.csv"),
    250
)

samplePop = Population(GT.halfandhalf(500, sampleConfig.funcset, sampleConfig.termset, 2, 6), sampleConfig)

evolve(samplePop, 10, true)

"""
kepler = GT.GTBinaryNode(/, "÷", [GT.GTUnaryNode(x -> x^3, "³", GT.GTParameter(1, "R")), GT.GTUnaryNode(x -> x^2, "²", GT.GTParameter(2, "T"))])

println("KEPLER\n: ", GT.L2fitness(kepler, sampleConfig.inputs, sampleConfig.outputs))

for x in eachcol(sampleConfig.inputs)
    println(GT.eval(kepler, x))
end
"""
end