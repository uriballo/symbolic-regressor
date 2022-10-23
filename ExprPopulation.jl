module ExprPopulation

include("MathExpressions.jl")
include("GeneticOperations.jl")

using .MathExpressions
using .GeneticOperations

Base.@kwdef mutable struct Population
    population2 :: Array{MathExpressions.MathExpr} 
    
    fitness :: Function = identity
    crossoverFunc :: Function = identity
    mutationFunc :: Function = identity
    
    mutationProb :: Float64 = 0.0
end

end