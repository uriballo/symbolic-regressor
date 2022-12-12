include("GTPopulation.jl")
include("Utils.jl")

using JSON

import .GTPopulation as GP

struct SRRUN
    input::String
    output::String

    generations::Int64
    populationsize::Int64

    mutationprob::Float64
    parentsselected::Float64

    functionset::Array{String,1}
    terminalset::Array{Tuple{String,Number},1}
    parameterset::Array{Tuple{String,Int64},1}

    fitnessfunc::String
    crossoverfunc::String
    mutationfunc::String
    selectionfunc::String
end


function initrun(srrun)
    iters = srrun.generations

    context = GP.genpopcontext(
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
        srrun.selectionfunc,
    )

    @time begin
        GP.evolve(context, iters, true)
    end
end

function main()
    if "--help" ∈ ARGS || "-h" ∈ ARGS
        help()
    else
        configpath = "kepler.json"
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

        constants = [
            (constantsJSON[i]["symbol"], constantsJSON[i]["value"]) for
            i in eachindex(constantsJSON)
        ]
        parameters = [
            (parametersJSON[i]["symbol"], parametersJSON[i]["index"]) for
            i in eachindex(parametersJSON)
        ]


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
