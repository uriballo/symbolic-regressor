module ExprPopulation

include("MathExpressions.jl")
include("Operators.jl")
include("GeneticOperations.jl")

import .MathExpressions as me
#using .GeneticOperations

Base.@kwdef mutable struct Population
    pop::Array{me.MathExpr} = []

    fitness::Function = identity
    crossoverFunc::Function = identity
    mutationFunc::Function = identity

    mutationProb::Float64 = 0.0

    functionSet::Vector{me.Operators.Operator} = [me.Operators.plus, me.Operators.minus, me.Operators.mult, me.Operators.inv, 
        me.Operators.pow2, me.Operators.pow3, me.Operators.sin_, me.Operators.sqrt_, me.Operators.cos_]
    terminalSet::Vector{String} = ["α", "η", "β"]

    constantSet::Vector{String} = []
    constantValues::Vector{Real} = []
end

function genPopulation()
end

function generateRandomExpr(size::Int)::me.MathExpr

end

function randomExpr(context)
   root = me.randomNode(context.terminalSet, context.functionSet) 

    if root.arity > 0
        root.leftChild = randomExpr(context) 
    end

    if root.arity == 2
        root.rightChild =randomExpr(context)
    end 

    root
end

end