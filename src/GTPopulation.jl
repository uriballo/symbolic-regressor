module GTPopulation

using CSV
using DataFrames

include("GTree.jl")
include("Utils.jl")

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
    nparents::Float64          # Number of parents selected per generation.
end

mutable struct Context
    population::Array{GT.GTree,1} # Array of GTrees.
    config::Config               # Configuration of the population.
end

"""
> Base Methods for Population
"""

function Base.show(io::IO, pop::Context)
    println(io, "###############################")
    println(io, "# Population Size: ", length(pop.population))
    for i = 1:length(pop.population)
        println(io, "> $i.", pop.population[i])
    end
end

"""
> Population Methods
"""

# Returns an array of size n with the n best GTrees from the population.
#   - uses the fitness function from the population context as a metric.
function elitist(context, n)
    inputs = context.config.inputs
    outputs = context.config.outputs
    population = context.population
    fitness = context.config.fitness

    sorted = sort(population, by = x -> fitness(x, inputs, outputs), rev = false)
    sorted[1:n]
end

# Evolves the population in context over the number of specified generations.
function evolve(context, generations, verbose = false)
    config = context.config

    nparents = config.nparents
    fitness = config.fitness
    inputs = config.inputs
    outputs = config.outputs
    crossover = config.crossover
    mutate = config.mutate
    funcset = config.funcset
    termset = config.termset
    select = config.selection
    mutationprob = config.mutationprob

    for i = 1:generations
        parents = select(context, trunc(Int, nparents * length(context.population)))

        bestfitness = fitness(parents[1], inputs, outputs)

        if verbose
            println(
                "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
            )
            println("[#] Generation $i")
            println("\t[!] Best Candidate: $(parents[1])")
            println("\t[>] Fitness: $(bestfitness)")
        end

        children = []
        for parent in parents
            secondparent = parents[rand(1:length(parents))]
            child = crossover(parent, secondparent)
            if rand() < mutationprob
                mutatedChild = mutate(child, funcset, termset)
                push!(children, mutatedChild)
            end

            push!(children, child)
        end

        context.population = vcat(parents, children)
    end

    final = select(context, 1)[1]
    println(
        "\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
    )
    println("[#] Final Generation")
    println("\t[!] Best Candidate: $final")
    println("\t[>] Fitness: $(fitness(final, inputs, outputs))")
    println(
        "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
    )

    println()
    simplifycmd(GT.toString(final), GT.exprsyms(final))
    println(
        "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
    )
end

"""
> Initialization Methods
"""

# Given a functionset of strings returns an array of the corresponding functions.
function parsefunctionset(funcset)
    funcs = []

    for func in funcset
        f = strtofunc(func)
        if f[3] == 1
            push!(funcs, GT.GTUnaryNode(f[1], f[2]))
        else
            push!(funcs, GT.GTBinaryNode(f[1], f[2]))
        end
    end

    funcs
end

# Given a terminalset of strings and a parameterset of strings returns an array of the corresponding constants and parameters.
function parseterminalset(termset, parameterset)
    terms = []

    for term in termset
        push!(terms, GT.GTConstant(term[2], term[1]))
    end

    for param in parameterset
        push!(terms, GT.GTParameter(param[2], param[1]))
    end

    terms
end

# Given a string returns the corresponding function.
function parsefunction(func)
    if func == "elitist"
        return elitist
    elseif func == "roulette"
        return rouletteselection
    elseif func == "crossover"
        return GT.crossover
    elseif func == "2crossover"
        return GT.k2crossover
    elseif func == "3crossover"
        return GT.k3crossover
    elseif func == "4crossover"
        return GT.k4crossover
    elseif func == "mutate"
        return GT.mutate
    elseif func == "2mutate"
        return GT.k2mutate
    elseif func == "3mutate"
        return GT.k3mutate
    elseif func == "4mutate"
        return GT.k4mutate
    elseif func == "l2"
        return GT.L2fitness
    elseif func == "errorfitness"
        return GT.errorfitness
    elseif func == "cosinesim"
        return GT.cosinesim
    else
        println("Invalid function: $func")
        return nothing
    end
end

# Given configuration parameters returns a population context, which contains the population and the configuration.
function genpopcontext(
    input,
    output,
    populationsize,
    mutationprob,
    parentsselected,
    functionset,
    terminalset,
    parameterset,
    fitnessfunc,
    crossoverfunc,
    mutationfunc,
    selectionfunc,
)
    inputs = loadinputs(input)
    outputs = loadoutputs(output)
    funcset = parsefunctionset(functionset)
    termset = parseterminalset(terminalset, parameterset)
    fitfunc = parsefunction(fitnessfunc)
    crossfunc = parsefunction(crossoverfunc)
    mutfunc = parsefunction(mutationfunc)
    selectfunc = parsefunction(selectionfunc)

    initialpop = GT.genpopulation(populationsize, funcset, termset, 1, 3)

    config = Config(
        fitfunc,
        crossfunc,
        mutfunc,
        selectfunc,
        mutationprob,
        termset,
        funcset,
        inputs,
        outputs,
        parentsselected,
    )

    Context(initialpop, config)
end

end
