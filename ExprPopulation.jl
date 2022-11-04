module ExprPopulation

include("MathExpressions.jl")
include("Operators.jl")
include("GeneticOperations.jl")

import .MathExpressions as me
#using .GeneticOperations

Base.@kwdef mutable struct Population
    pop::Array{me.MathExpr} = []

    fitness::Function = fitness
    
    crossoverFunc::Function = crossover
    mutationFunc::Function = mutateN
    
    mutationProb::Real = 0.1

    functionSet::Vector{me.Operators.Operator} = [
        #me.Operators.plus,
        #me.Operators.minus,
        me.Operators.mult,
        #me.Operators.inv,
        me.Operators.div,
        me.Operators.pow2,
        me.Operators.pow3
        #me.Operators.sin_,
        #me.Operators.sqrt_,
        #me.Operators.cos_,
    ]
    terminalSet::Vector{String} = ["R", "T"]

    constantSet::Vector{Real} = [6.67430E-11]
    constantSymbols::Vector{String} = ["𝔾 "]

    inputs::Matrix{Real} = zeros(3, 3)
    outputs::Vector{Real} = zeros(3)
end

function initPopulation(
    size::Int,
    inputs,
    outputs,
)::Population
    ppl = Population(
        inputs = inputs,
        outputs = outputs,
    )

    exprs = randomSet(size, ppl)

    ppl.pop = exprs

    ppl
end

function initPopulation(size::Int, inputs, outputs, symbols, constants) 
    ppl = Population(
        inputs = inputs,
        outputs = outputs,
        constantSymbols = symbols,
        constantSet = constants,
    )
    exprs = Vector{me.MathExpr}()
    for _ in 1:size
        expr = randomExpr(ppl)
        append!(exprs, expr)
    end
    ppl.pop = exprs

    ppl
end

function randomSet(size::Int, ppl::Population)::Vector{me.MathExpr}
    exprs = Vector{me.MathExpr}()
    while length(exprs) < size
        rexpr = randomExpr(ppl)
        if rexpr ∉ exprs
            push!(exprs, rexpr)
        end
    end

    exprs
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
    mutation = randomExpr(context)
    nodeN(expr, node, mutation, context)
end

function nodeN(expr, node::Int, newnode, context::Population)
    if node == 0
        expr = newnode
    else
        leftChildNode = nothing
        rightChildNode = nothing

        if expr.arity > 0
            leftChildNode = nodeN(expr.leftChild, node - 1, newnode, context)
        end

        if expr.arity > 1
            rightChildNode = nodeN(
                expr.rightChild,
                node - me.countNodes(expr.leftChild) - 1,
                newnode,
                context,
            )
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

function crossover(expr1, expr2, context)
    nodesp2 = me.countNodes(expr2)

    mergepoint = rand(0:nodesp2-1)

    newnode = me.getRandomNode(expr1)

    nodeN(expr2, mergepoint, newnode, context)
end

function fitness(expr, inputs::Matrix{Real}, outputs::Vector{Real})
    fitnessess = Vector{Real}()
    i = 1
    for column in eachcol(inputs)
        push!(fitnessess, me.evaluateExpr(expr, column) - outputs[i])
        i = i + 1
    end
    1/(abs(sum(fitnessess)) + me.exprComplexity(expr))
end

# Selects a random expr.
function select(exprs, context)
    idx = rand(1:length(exprs))

    exprs[idx]
end

# Selects the n best exprs from a population.
function selectN(exprs, context, n)
    sortedExprs =
        sort(exprs, by = expr -> context.fitness(expr, context.inputs, context.outputs))
    
    asc = reverse(sortedExprs)#[1:n]
    unique(asc)
end

function evolve(population, steps, tol, psize, verbose = false)
    be = me.MathExpr()
    for n in (1:steps)
        # Select
        selected = (selectN(population.pop, population, psize))
        be = selected[1]

        if verbose
            println("Iteration: ", n)
            println("Best Expr:")
            me.printTree(be, 0)
        end
        
        # Crossover
        for _ = 1:size(selected,1)-1
            p1 = select(selected, population)
            p2 = select(selected, population)
            
            child = crossover(p1, p2, population)

            push!(population.pop, child)
        end
        """
        # Mutate
        for i = 1:size(population.pop,1)-1
            #if rand() < population.mutationProb
                mnode = rand(0:me.countNodes(population.pop[i])-1)
                mutated = mutateN(population.pop[i], mnode, population)

                push!(population.pop, mutated)
#            end
        end
        """
        #goodChildren = selectN(children, population, size(children,1) ÷ 2)
        #goodParents = selectN(parents, population, size(parents,1) - size(goodChildren,1))
        #goodOldPop = selectN(population.pop, population, size(population.pop,1) - size(goodParents,1) - size(goodChildren,1))

        #newpop = vcat(goodChildren, goodParents, goodOldPop)
        #population.pop = unique(selectN(population.pop, population, psize))

        println("#####################################")
        for i = 1:size(population.pop,1)
            println("Expr: ", i)
            me.printTree(population.pop[i], 0)
            println("\t\tevals to: \n")
            for col in eachcol(population.inputs)
                println("\t\t\t", me.evaluateExpr(population.pop[i], col))
            end
            println("---")
        end
        println("#####################################")
        
    end
    println("\n\n##############################")
    println("Best Expr:")
    me.printTree(be, 0)
    #println("Fitness:\t\t\t", bestExpr.fitness)
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