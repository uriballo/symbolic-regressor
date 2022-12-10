include("GTPopulation.jl")
using JSON

import .GTPopulation as GP

"""
Parameters by A Field Guide to Genetic Programming
    population size (should be at least 500)
    probability of mutation
    > (half-and-half) range 2-6 is optimal
    number of generations betweem 10 and 50
"""

struct SRRUN
    input::String
    output::String

    generations::Int64
    populationsize::Int64

    mutationprob::Float64
    parentsselected::Float64

    functionset::Array{String,1}
    terminalset::Array{Tuple{String, Number},1}
    parameterset::Array{Tuple{String, Int64},1}

    fitnessfunc::String
    crossoverfunc::String
    mutationfunc::String
    selectionfunc::String
end


function initrun(srrun)
    iters = srrun.generations

    population = GP.genpopconfig(
        srrun.input,
        srrun.output,
        srrun.populationsize,
        srrun.mutationprob,
        srrun.parentsselected,
        srrun.functionset,
        srrun.terminalset,
        srrun.parameterset,
        srrun.fitnessfunc,
        srrun.crossoverfunc,
        srrun.mutationfunc,
        srrun.selectionfunc
    )

    @time begin
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
    println("\t--config,      -c\tSpecify the config file to use")
    println("\t\t\t\t\t* e.g. kepler-config.json > /config/kepler-config.json")
    println("\n[?] Do you want to see the JSON structure for the config file? (y/n)")
    s = readline()
    if s == "y"
        println(
            "----------------------------------------------------------------------------------------",
        )
        println("JSON Structure:")
        println("\t{")
        println("\t\t\"input\": \"file_in_config_folder.csv\",")
        println("\t\t\"output\": \"file_in_config_folder.csv\",")
        println("\t\t\"generations\": INT,")
        println("\t\t\"population-size\": INT,")
        println("\t\t\"mutation-prob:\": FLOAT,")
        println("\t\t\"parents-selected\": FLOAT,")
        println("\t\t\"function-set\": [\"^x\", \"1/x\", \"sin\", ...],")
        println("\t\t\"constant-set\": [")
        println("\t\t\t{")
        println("\t\t\t\t\"symbol\": \"constant_symbol\",")
        println("\t\t\t\t\"value\": FLOAT or INT")
        println("\t\t\t},")
        println("\t\t\t{")
        println("\t\t\t\t\"symbol\": \"constant_symbol\",")
        println("\t\t\t\t\"value\": FLOAT or INT")
        println("\t\t\t},")
        println("\t\t\t...")
        println("\t\t],")
        println("\t\t\"parameter-set\": [")
        println("\t\t\t{")
        println("\t\t\t\t\"symbol\": \"parameter_symbol\",")
        println("\t\t\t\t\"index\": INT")
        println("\t\t\t},")
        println("\t\t\t{")
        println("\t\t\t\t\"symbol\": \"parameter_symbol\",")
        println("\t\t\t\t\"index\": INT")
        println("\t\t\t},")
        println("\t\t\t...")
        println("\t\t],")
        println("\t\t\"fitness-function\": \"function_name (must be in GTPopulation.jl)\",")
        println(
            "\t\t\"crossover-function\": \"function_name (must be in GTPopulation.jl)\",",
        )
        println("\t\t\"mutation-function\": \"function_name (must be in GTPopulation.jl)\"")
        println(
            "\t\t\"selection-function\": \"function_name (must be in GTPopulation.jl)\"",
        )
        println("\t}")
    end
    println(
        "----------------------------------------------------------------------------------------",
    )

end

function main()
    if "--help" ∈ ARGS || "-h" ∈ ARGS
        help()
    else
        configpath = "kepler-config.json"
        for arg in ARGS
            sparg = split(arg, "=")
            prefix = sparg[1]

            if prefix == "--config" || prefix == "-c"
                configpath = sparg[2]
            end
        end

        config = JSON.parsefile("../configs/" * configpath)

        constantsJSON = config["constant-set"]
        parametersJSON = config["parameter-set"]

        constants = [(constantsJSON[i]["symbol"], constantsJSON[i]["value"]) for i in eachindex(constantsJSON)]
        parameters = [(parametersJSON[i]["symbol"], parametersJSON[i]["index"]) for i in eachindex(parametersJSON)]

        
        run = SRRUN(
            config["input"],
            config["output"],
            config["generations"],
            config["population-size"],
            config["mutation-prob"],
            config["parents-selected"],
            config["function-set"],
            constants,
            parameters,
            config["fitness-function"],
            config["crossover-function"],
            config["mutation-function"],
            config["selection-function"],
        )
        

        initrun(run)
    end
end

main()
