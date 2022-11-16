include("GTPopulation.jl")

import .GTPopulation as GP

"""
Parameters by A Field Guide to Genetic Programming
    population size (should be at least 500)
    probability of mutation
    > (half-and-half) range 2-6 is optimal
    number of generations betweem 10 and 50
"""

struct SRRUN
    conf::String
    inputs::String
    outputs::String
    gens::Int
    fitnessfunc::String
    crossoverfunc::String
    mutationfunc::String

    mutationprob::Float32
    nparents::Int
    popsize::Int
    time::Bool
end

function initrun(srrun)
    iters = srrun.gens

    usedefault = srrun.conf != "none"

    population = GP.genpopconfig(
        srrun.conf,
        srrun.inputs,
        srrun.outputs,
        srrun.fitnessfunc,
        srrun.crossoverfunc,
        srrun.mutationfunc,
        srrun.mutationprob,
        srrun.nparents,
        srrun.popsize,
        usedefault,
    )
    if srrun.time
        @time begin
            GP.evolve(population, iters, true)
        end
    else
        GP.evolve(population, iters, true)
    end
end

function help()
    println(
        "----------------------------------------------------------------------------------------",
    )
    println("Usage: SymbolicR.jl [OPTIONS]")
    println("Options:")
    println("\t--help,        -h\tPrint this help message")
    println("\t--config,      -c\tSpecify a sample configuration to use")
    println("\t\t\t\t\t* kepler > kepler's third law config")
    println("\t\t\t\t\t* trig   > sin(θ) config")
    println("\t--input,       -i\tSpecify the input matrix csv file")
    println("\t\t\t\t\t* csv must be in /data")
    println("\t--output,      -o\tSpecify the output vector csv file")
    println("\t\t\t\t\t* csv must be in /data")
    println("\t--generations, -g\tSpecify the number of generations to run")
    println("\t--fitness,     -f\tSpecify the fitness function to use")
    println("\t\t\t\t\t* l2    > L2 distance")
    println(
        "\t\t\t\t\t* cosim > inverse cosine similarity (multiplied by -1 so the closer to -1)",
    )
    println("\t--selection,   -s\tSpecify the selection function to use")
    println("\t\t\t\t\t* NOT AVAILABLE YET, ONLY ONE FUNC IMPLEMENTED")
    println("\t--crossover,   -x\tSpecify the crossover function to use")
    println("\t\t\t\t\t* NOT AVAILABLE YET, ONLY ONE FUNC IMPLEMENTED")
    println("\t--mutation,    -m\tSpecify the mutation function to use")
    println("\t\t\t\t\t* NOT AVAILABLE YET, ONLY ONE FUNC IMPLEMENTED")
    println("\t--mprob,       -p\tSpecify the mutation probability")
    println("\t\t\t\t\t* ∈ [0, 1]")
    println("\t--popsize,     -ps\tSpecify the population size")
    println("\t--nparents,    -np\tSpecify the number of parents to use")
    println("\t\t\t\t\t* ∈ (0, population size]")
    println("\t--funcset,     -fs\tSpecify the function set to use")
    println("\t\t\t\t\t* NOT AVAILABLE YET, uses kepler's set")
    println("\t--termset,     -ts\tSpecify the terminal set to use")
    println("\t\t\t\t\t* NOT AVAILABLE YET, uses kepler's set")
    println("\t-t,               \tMeasure time spent running the evolution loop")
    println("\t\t\t\t\t* ignores time spent reading the files and initializing population")
    println(
        "----------------------------------------------------------------------------------------",
    )
end

function main()
    configuration = inputmat = outputvec = generations = fitness = nothing
    crossover = mutation = mutationprob = nparents = popsize = nothing

    configuration = "none"
    inputmat = "kepler1618-inputs.csv"
    outputvec = "kepler1618-outputs.csv"
    generations = 10
    fitness = "l2"
    crossover = "crossover"
    mutation = "mutation"
    mutationprob = 0.15
    nparents = 250
    popsize = 500
    time = "-t" ∈ ARGS

    if "--help" ∈ ARGS || "-h" ∈ ARGS
        help()
    else
        for arg in ARGS
            sparg = split(arg, "=")
            prefix = sparg[1]

            if prefix == "--config" || prefix == "-c"
                configuration = sparg[2]
            elseif prefix == "--inputs" || prefix == "-i"
                inputmat = sparg[2]
            elseif prefix == "--outputs" || prefix == "-o"
                outputvec = sparg[2]
            elseif prefix == "--generations" || prefix == "-g"
                generations = parse(Int, sparg[2])
            elseif prefix == "--fitness" || prefix == "-f"
                fitness = sparg[2]
            elseif prefix == "--crossover" || prefix == "-x"
                crossover = sparg[2]
            elseif prefix == "--mutation" || prefix == "-m"
                mutation = sparg[2]
            elseif prefix == "--mprob" || prefix == "-p"
                mutationprob = parse(Float32, sparg[2])
            elseif prefix == "--nparents" || prefix == "-np"
                nparents = parse(Int, sparg[2])
            elseif prefix == "--popsize" || prefix == "-ps"
                popsize = parse(Int, sparg[2])
            elseif prefix != "-t"
                println("[!] Invalid argument: $arg")
                println("\t\t it will be ignored.")
                println("\t\t use -h or --help for help")
            end
        end

        if nparents > popsize
            nparents = 0.5 * popsize
        end

        run = SRRUN(
            configuration,
            inputmat,
            outputvec,
            generations,
            fitness,
            crossover,
            mutation,
            mutationprob,
            nparents,
            popsize,
            time,
        )
        initrun(run)
    end
end


main()
