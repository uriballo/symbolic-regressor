module GTrees

"""
> Genetic Tree Type
"""
abstract type GTree end
abstract type GTLeaf <: GTree end
abstract type GTNode <: GTree end

mutable struct GTConstant <: GTLeaf
	val::Number
	symbol::String
end

mutable struct GTParameter <: GTLeaf
	id::Int
	symbol::String
end

mutable struct GTUnaryNode <: GTNode
	func::Function
	symbol::String
	input::GTree
    arity::Int

    GTUnaryNode(func, symbol) = new(func, symbol, GTParameter(0, "∅"), 1)
    GTUnaryNode(func, symbol, input) = new(func, symbol, input, 1)
end

mutable struct GTBinaryNode <: GTNode
	func::Function
	symbol::String
	input::Array{GTree, 1}
    arity::Int

    GTBinaryNode(func, symbol) = new(func, symbol, [GTParameter(0, "∅"), GTParameter(0, "∅")],2 )
    GTBinaryNode(func, symbol, input) = new(func, symbol, input, 2)
end

"""
> Base Methods for GTree Type
"""

function Base.show(io::IO, node::GTConstant)
	print(io, node.symbol)
end

function Base.show(io::IO, node::GTParameter)
	print(io, node.symbol)
end

function Base.show(io::IO, node::GTBinaryNode)
	print(io, node.symbol, "(", node.input[1], ", ", node.input[2], ")")
end

function Base.show(io::IO, node::GTUnaryNode)
	print(io, node.symbol, "(", node.input, ")")
end

function Base.copy(node::GTConstant)
	GTConstant(node.val, node.symbol)
end

function Base.copy(node::GTParameter)
	GTParameter(node.id, node.symbol)
end

function Base.copy(node::GTBinaryNode)
	GTBinaryNode(node.func, node.symbol, [copy(node.input[1]), copy(node.input[2])])
end

function Base.copy(node::GTUnaryNode)
	GTUnaryNode(node.func, node.symbol, node.input)
end

"""
> GTree Utils
"""

function nnodes(node::GTLeaf)
	1
end

function nnodes(node::GTUnaryNode)
	1 + nnodes(node.input)
end

function nnodes(node::GTBinaryNode)
	1 + nnodes(node.input[1]) + nnodes(node.input[2])
end

function depth(node::GTLeaf)
	1
end

function depth(node::GTUnaryNode)
	1 + depth(node.input)
end

function depth(node::GTBinaryNode)
	1 + max(depth(node.input[1]), depth(node.input[2]))
end

function get(node::GTLeaf, i::Int)
	if i == 0
		node
	end
end

function get(node::GTUnaryNode, i::Int)
	if i == 0
		node
	else
		get(node.input, i - 1)
	end
end

function get(node::GTBinaryNode, i::Int)
	if i == 0
		node
	else
		l = get(node.input[1], i - 1)

		l === nothing ? get(node.input[2], i - 1 - nnodes(node.input[1])) : l
	end
end

function set(node::GTLeaf, i::Int, newnode)
    if i == 0
        newnode
    end
end

function set(node::GTUnaryNode, i::Int, newnode)
    if i == 0
        newnode
    else
        GTUnaryNode(node.func, node.symbol, set(node.input, i - 1, newnode))
    end
end

function set(node::GTBinaryNode, i::Int, newnode)
    if i == 0
        newnode
    else
        l = get(node.input[1], i - 1)

        if l === nothing
            GTBinaryNode(node.func, node.symbol, [node.input[1], set(node.input[2], i - 1 - nnodes(node.input[1]), newnode)])
        else
            GTBinaryNode(node.func, node.symbol, [set(node.input[1], i - 1, newnode), node.input[2]])
        end
    end
end

"""
> GTree Things
"""

# method 1 = grow
# method 2 = full
function randexpr(funcset, termset, maxdepth, method)
    tsize = length(termset)
    fsize = length(funcset)
    
    if maxdepth == 0 || (method == 1 && rand() < (tsize / (tsize + fsize)))
        expr = copy(termset[rand(1:length(termset))])
    else
        func = copy(funcset[rand(1:length(funcset))])

        if func.arity == 1
            func.input = randexpr(funcset, termset, maxdepth - 1, method)
        else
            func.input = [randexpr(funcset, termset, maxdepth - 1, method), randexpr(funcset, termset, maxdepth - 1, method)]
        end

        expr = func
    end

    expr
end

function randexpr(funcset, termset)
    randexpr(funcset, termset, 4, 2)
end

function eval(node::GTConstant, x)
    node.val
end

function eval(node::GTParameter, x)
    x[node.id]
end

function eval(node::GTUnaryNode, x)
    val = node.func(eval(node.input, x))
    isfinite(val) && !isnan(val) ? val : NaN
end

function eval(node::GTBinaryNode, x)
   val = node.func(eval(node.input[1], x), eval(node.input[2], x))

   isfinite(val) && !isnan(val) ? val : NaN
end

"""
> Crossover Functions
"""
function crossover(parent1, parent2)
    gene1 = get(parent1, rand(0:nnodes(parent1)-1))
    child = set(parent2, rand(0:nnodes(parent2)-1), gene1)

    child
end

"""
> Mutation Functions
"""
function mutate(node, funcset, termset)
    mutation = randexpr(funcset, termset, rand(1:2), 1)

    mutationpoint = rand(0:nnodes(node)-1)

    set(node, mutationpoint, mutation)
end

"""
> Seeding Functions
"""
# ramped half and half population
function halfandhalf(size, funcset, termset, minsize, maxsize)
    population = []

    halfsize = size ÷ 2
    
    # Grow mode
    for _ in 1:halfsize
        push!(population, randexpr(funcset, termset, rand(minsize:maxsize), 1))
    end
    
    # Full mode
    for _ in 1:halfsize
        push!(population, randexpr(funcset, termset, rand(minsize:maxsize), 2))
    end
    
    population
end

"""
> Fitness Functions
"""
function pnorm(v, p)
    absv = abs.(v)
    sum((absv).^p)^(1/p)
end

function L2fitness(node, inputs, outputs)
    predictions = [eval(node, x) for x in eachcol(inputs)] .* 10e5
    
    predictionnorm = pnorm(predictions, 2)
    outputnorm = pnorm(outputs, 2)

    sqrt(sum((predictions .- outputs).^2)) / (predictionnorm * outputnorm)
end

function cosinesim(node, inputs, outputs)
    predictions = []

    for x in eachcol(inputs)
        push!(predictions, eval(node, x))
    end
    
    for x in eachcol(inputs)
        println(x)
    end

    #if sum(predictions) / length(predictions) - 1 < 1e-6
    #    return -2
    #end
    println("----")
    println(node)
    println("PRED: ", predictions)
    println("OUTPUTS: ", outputs)
    println("----")
    predictionnorm = pnorm(predictions, 2)
    
    outputnorm = pnorm(outputs, 2)

    sim = sum(predictions .* outputs) / (predictionnorm * outputnorm)
    isnan(sim) || isinf(sim) ? -2 : sim 
end

function mse(node, inputs, outputs)
    predictions = [eval(node, x) for x in eachcol(inputs)]
    
    1/sqrt(sum((predictions .- outputs).^2))
end

end