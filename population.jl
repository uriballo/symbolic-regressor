module Population

include("math-expr.jl")
include("operators.jl")
include("genetic-operations.jl")

using MathExpr
using Operators
using GeneticOperations


Base.@kwdef mutable struct Population
    population :: Array{MathExpr.MathExpr} = []
    
    fitness :: Function = identity
    crossoverFunc :: Function = identity
    mutationFunc :: Function = identity
    
    mutationProb :: Float64 = 0.0
end

function evolve(iterations:: Int)

end