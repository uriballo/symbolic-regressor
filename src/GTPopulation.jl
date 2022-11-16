module GTPopulation

using CSV
using DataFrames

include("GTree.jl")

import .GTrees as GT

struct Config
    fitness::Function   # Fitness function.
    crossover::Function # Crossover function.
    mutate::Function    # Mutation function.
    selection::Function # Selection function.

    mutationprob::Float64 # Probability of mutation.

    termset::Array{GT.GTLeaf,1} # Terminal set (constants and parameters).
    funcset::Array{GT.GTNode,1} # Function set (operators).

    inputs::Matrix{Float64}  # Input data.
    outputs::Vector{Float64} # Output data.
    nparents::Int64          # Number of parents selected per generation.
end

mutable struct Population
    population::Array{GT.GTree,1} # Array of GTrees.
    context::Config               # Configuration of the population.
end

"""
> Base Methods for Population
"""

function Base.show(io::IO, pop::Population)
    println(io, "###############################")
    println(io, "# Population Size: ", length(pop.population))
    for i = 1:length(pop.population)
        println(io, "> $i.", pop.population[i])
    end
end

"""
> Population Methods
"""

# TBD
function roulette(population, n)
    winners = []
    inputs = population.context.inputs
    outputs = population.context.outputs
    pop = population.population

    fitnesses = [population.context.fitness(x, inputs, outputs) for x in pop]
    probabilities = fitnesses ./ sum(fitnesses)
    # TODO: finish
end

# Returns an array of size n with the n best GTrees from the population.
#   - uses the fitness function from the population context as a metric.
function elitist(population, n)
    inputs = population.context.inputs
    outputs = population.context.outputs
    pop = population.population
    ctx = population.context

    sorted = sort(pop, by = x -> ctx.fitness(x, inputs, outputs), rev = false)
    sorted[1:n]
end

# Retruns a matrix with the inputs from 'filename'.
#   - filename must be in the data folder.
function loadinputs(filename)
    inputs = CSV.read("../data/" * filename, DataFrame)

    transpose(Matrix(inputs))
end

# Returns a vector with the outputs from 'filename'.
#   - filename must be in the data folder.
function loadoutputs(filename)
    outputs = CSV.read("../data/" * filename, DataFrame)

    vec(Matrix(outputs))
end

# Evolves the population over the number of specified generations.
function evolve(population, generations, verbose = false)
    ctx = population.context
    pop = population.population

    for i = 1:generations
        parents = elitist(population, ctx.nparents)

        if verbose
            println("#############################")
            println("# Generation $i")
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

    final = elitist(population, 1)[1]
    println("\n\n#############################")
    println("# Final Generation")
    println("Best Candidate: $(final)")
    println("\tFitness: $(ctx.fitness(final, ctx.inputs, ctx.outputs))")
end

"""
> Sample Configs
"""

function genpopconfig(
    defaultconfig,
    inputs,
    outputs,
    fitness,
    crossover,
    mutation,
    mutationprob,
    nparents,
    popsize,
    usedefault = false,
)
    if usedefault
        conf = defaultconfig == "trig" ? trigConfig : sampleConfig
    else
        fitnessfunc = fitness == "l2" ? GT.L2fitness : GT.cosinesim
        conf = Config(
            fitnessfunc,
            GT.crossover,
            GT.mutate,
            elitist,
            mutationprob,
            TermSet,
            FuncSet,
            loadinputs(inputs),
            loadoutputs(outputs),
            nparents,
        )
    end
    Population(GT.halfandhalf(popsize, conf.funcset, conf.termset, 2, 6), conf)
end

FuncSet = [
    GT.GTUnaryNode(x -> x^2, "²"),
    GT.GTUnaryNode(x -> x^3, "³"),
    GT.GTUnaryNode(x -> 1 / x, "⁻¹"),
    GT.GTBinaryNode(+, "+"),
    GT.GTBinaryNode(-, "-"),
    GT.GTBinaryNode(*, "×"),
    GT.GTBinaryNode(/, "÷"),
]

TermSet = [GT.GTParameter(1, "R"), GT.GTParameter(2, "T")]

TrigFuncSet = [
    #GT.GTUnaryNode(sin, "sin"),
    GT.GTUnaryNode(cos, "cos"),
    GT.GTUnaryNode(tan, "tan"),
    GT.GTUnaryNode(x -> x^2, "²"),
    #GT.GTUnaryNode(x -> x^3, "³"),
    #GT.GTUnaryNode(x -> 1/x, "⁻¹"),
    GT.GTBinaryNode(+, "+"),
    GT.GTBinaryNode(-, "-"),
    GT.GTBinaryNode(*, "×"),
    GT.GTBinaryNode(/, "÷"),
    GT.GTUnaryNode(x -> sqrt(abs(x)), "√"),
]

TrigTermSet = [GT.GTParameter(1, "θ"), GT.GTConstant(π, "π"), GT.GTConstant(1, "1")]

trigConfig = Config(
    GT.L2fitness,
    GT.crossover,
    GT.mutate,
    elitist,
    0.15,
    TrigTermSet,
    TrigFuncSet,
    loadinputs("sine-inputs.csv"),
    loadoutputs("sine-outputs.csv"),
    250,
)

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
    250,
)

samplePop = Population(
    GT.halfandhalf(500, sampleConfig.funcset, sampleConfig.termset, 2, 6),
    sampleConfig,
)

trigPop = Population(
    GT.halfandhalf(500, trigConfig.funcset, trigConfig.termset, 1, 4),
    trigConfig,
)

end
