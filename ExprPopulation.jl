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

    mutationProb::Real = 0.0

    functionSet::Vector{me.Operators.Operator} = [
        me.Operators.plus,
        me.Operators.minus,
        me.Operators.mult,
        me.Operators.inv,
        me.Operators.pow2,
        me.Operators.pow3,
        me.Operators.sin_,
        me.Operators.sqrt_,
        me.Operators.cos_,
    ]
    terminalSet::Vector{String} = ["α", "η", "β"]

    constantSet::Vector{Real} = [6.67430E-11, MathConstants.pi, MathConstants.golden]
    constantSymbols::Vector{String} = ["𝔾 ", "π", "Φ "]
end

function initPopulation(
    size::Int,
    fitnessFunc::Function,
    probMutation::Real,
    operators::Vector{me.Operators.Operator},
    parameters::Vector{String},
    constants::Vector{Real},
    symbols::Vector{String},
)::Population

    ppl = Population(
        fitness = fitnessFunc,
        mutationProb = probMutation,
        functionSet = operators,
        terminalSet = parameters,
        constantSet = constants,
        constantSymbols = symbols,
    )

    exprs = Vector{me.MathExpr}()
    for n = 1:size
        expr = randomExpr(ppl)
        append!(expr, exprs)
    end

    ppl.pop = exprs

    ppl
end

# Aggresive mutate
function aggMutate(expr, prob, context::Population)
    if expr.arity > 0
        aggMutate(expr.leftChild, prob, context)
    end

    n = rand()
    if n < prob
        expr = randomExpr(context)
    end

    if expr.arity > 1
        aggMutate(expr.rightChild, prob, context)
    end

    expr
end


# mutates the nth node
function mutateN(expr, node::Int, context)
    if node == 0
        expr = randomExpr(context)
    else
        leftChildNode = nothing
        rightChildNode = nothing

        if expr.arity > 0
            leftChildNode = mutateN(expr.leftChild, node - 1, context)
        end

        if expr.arity > 1
            rightChildNode =
                mutateN(expr.rightChild, node - me.countNodes(expr.leftChild) - 1, context)
        end

        if typeof(rightChildNode) == typeof(leftChildNode) == Nothing
            expr
        else
            expr.leftChild = leftChildNode
            expr.rightChild = rightChildNode
            expr
        end
    end
end

function evolve(population, steps, tol, verbose = false)
    for n in steps
        # Select

        # Crossover

        # Mutate

        if verbose
            println("Iteration:\t\t\t", n)
            println("Best Expr:")
            println("---placeholder---")
        end

        # if best.fitness < tol => Break 
    end
end

function randomExpr(context)
    root = me.randomNode(
        context.terminalSet,
        context.functionSet,
        context.constantSet,
        context.constantSymbols,
    )

    if root.arity > 0
        root.leftChild = randomExpr(context)
    end

    if root.arity == 2
        root.rightChild = randomExpr(context)
    end

    root
end

end
