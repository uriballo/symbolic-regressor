module GTrees

"""
> Genetic Tree Type
"""
abstract type GTree end
abstract type GTLeaf <: GTree end
abstract type GTNode <: GTree end

mutable struct GTConstant <: GTLeaf
    val::Number    # numerical value of the constant, e.g. 3.1415...
    symbol::String # symbol that represents the constant, e.g. "π".
end

mutable struct GTParameter <: GTLeaf
    id::Int        # index of the parameter in the vector of inputs, e.g. 2 for the second input. 
    symbol::String # symbol that represents the parameter, e.g. "x".
end

mutable struct GTUnaryNode <: GTNode
    func::Function # function/operation that the node represents.
    symbol::String # symbol that represents the function/operation, e.g. "sin".
    input::GTree   # input of the function/operation.
    arity::Int     # arity of the operator, in this case 1.

    # Constructors
    GTUnaryNode(func, symbol) = new(func, symbol, GTParameter(0, "∅"), 1)
    GTUnaryNode(func, symbol, input) = new(func, symbol, input, 1)
end

mutable struct GTBinaryNode <: GTNode
    func::Function         # function/operation that the node represents.
    symbol::String         # symbol that represents the function/operation, e.g. "+".
    input::Array{GTree,1} # inputs of the function/operation.
    arity::Int             # arity of the operator, in this case 2.

    # Constructors
    GTBinaryNode(func, symbol) =
        new(func, symbol, [GTParameter(0, "∅"), GTParameter(0, "∅")], 2)
    GTBinaryNode(func, symbol, input) = new(func, symbol, input, 2)
end

"""
> Base Methods for GTree Type
"""

# Prints a constant node symbol.
function Base.show(io::IO, node::GTConstant)
    print(io, node.symbol)
end

# Prints a parameter node symbol.
function Base.show(io::IO, node::GTParameter)
    print(io, node.symbol)
end

# Prints a unary node symbol and its input in prefix notation e.g. +(2, 2) for 2+2.
function Base.show(io::IO, node::GTBinaryNode)
    print(io, node.symbol, "(", node.input[1], ", ", node.input[2], ")")
end

# Prints a binary node symbol and its inputs in prefix notation e.g. ²(x) for x².
function Base.show(io::IO, node::GTUnaryNode)
    print(io, node.symbol, "(", node.input, ")")
end

# Returns a copy of a constant node.
function Base.copy(node::GTConstant)
    GTConstant(node.val, node.symbol)
end

# Returns a copy of a parameter node.
function Base.copy(node::GTParameter)
    GTParameter(node.id, node.symbol)
end

# Returns a copy of a unary node.
function Base.copy(node::GTBinaryNode)
    GTBinaryNode(node.func, node.symbol, [copy(node.input[1]), copy(node.input[2])])
end

# Returns a copy of a binary node.
function Base.copy(node::GTUnaryNode)
    GTUnaryNode(node.func, node.symbol, node.input)
end

"""
> GTree Utils Multiple Dispatch
"""

####################
# Returns the number of nodes of a GTree.

function nnodes(node::GTLeaf)
    1
end

function nnodes(node::GTUnaryNode)
    1 + nnodes(node.input)
end

function nnodes(node::GTBinaryNode)
    1 + nnodes(node.input[1]) + nnodes(node.input[2])
end

####################
# Returns the depth of a GTree.

function depth(node::GTLeaf)
    1
end

function depth(node::GTUnaryNode)
    1 + depth(node.input)
end

function depth(node::GTBinaryNode)
    1 + max(depth(node.input[1]), depth(node.input[2]))
end

####################
# Returns the ith node (in preorder) of a GTree. 

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

####################
# Returns a copy of a GTree with the ith node (in preorder) replaced by a new node.

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
            GTBinaryNode(
                node.func,
                node.symbol,
                [node.input[1], set(node.input[2], i - 1 - nnodes(node.input[1]), newnode)],
            )
        else
            GTBinaryNode(
                node.func,
                node.symbol,
                [set(node.input[1], i - 1, newnode), node.input[2]],
            )
        end
    end
end

####################
# Returns the result of evaluating a GTree with an input vector x.

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
> GTree Genetic Operations
"""

# Generates a random expression from a given set of functions, terminals, max depth and method.
# The method can be either "grow" (1) or "full" (2).
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
            func.input = [
                randexpr(funcset, termset, maxdepth - 1, method),
                randexpr(funcset, termset, maxdepth - 1, method),
            ]
        end

        expr = func
    end

    expr
end

"""
> Crossover Functions
"""

# Returns the one-point crossover of two GTrees.
function crossover(parent1, parent2)
    crossover(parent2, parent1)
end

function crossover(parent1::GTLeaf, parent2::GTLeaf)
    rand() < 0.5 ? parent1 : parent2
end

function crossover(parent1::GTLeaf, parent2::GTUnaryNode)
    gene = copy(parent1)
    child = set(parent2, rand(0:nnodes(parent2)-1), gene)

    child
end

function crossover(parent1::GTLeaf, parent2::GTBinaryNode)
    gene = copy(parent1)
    child = set(parent2, rand(0:nnodes(parent2)-1), gene)

    child
end

function crossover(
    parent1::Union{GTUnaryNode,GTBinaryNode},
    parent2::Union{GTUnaryNode,GTBinaryNode},
)
    if rand() < 0.5
        gene = get(parent1, rand(0:nnodes(parent1)-1))
        child = set(parent2, rand(0:nnodes(parent2)-1), gene)
    else
        gene = get(parent2, rand(0:nnodes(parent2)-1))
        child = set(parent1, rand(0:nnodes(parent1)-1), gene)
    end

    child
end

"""
> Mutation Functions
"""

# Returns a copy of the GTree with a mutation at a point. 
function mutate(node, funcset, termset)
    mutation = randexpr(funcset, termset, rand(1:2), 2)

    mutationpoint = rand(0:nnodes(node)-1)

    set(node, mutationpoint, mutation)
end

"""
> Seeding Functions
"""

# Returns an array of random GTrees.
#   - half of the trees are generated with the "grow" method.
#   - half of the trees are generated with the "full" method. 
function halfandhalf(size, funcset, termset, minsize, maxsize)
    population = []

    halfsize = size ÷ 2

    # Grow mode
    for _ = 1:halfsize
        push!(population, randexpr(funcset, termset, rand(minsize:maxsize), 1))
    end

    # Full mode
    for _ = 1:halfsize
        push!(population, randexpr(funcset, termset, rand(minsize:maxsize), 2))
    end

    population
end

function genpopulation(size, funcset, termset, minsize, maxsize)
    population = []

    for _ = 1:size
        push!(population, randexpr(funcset, termset, rand(minsize:maxsize), rand(1:2)))
    end

    population
end


"""
> Fitness Functions
"""

# Returns the p-norm of a vector v.
function pnorm(v, p)
    absv = abs.(v)
    sum((absv) .^ p)^(1 / p)
end

function errorfitness(node, inputs, outputs)
    predictions = [eval(node, x) for x in eachcol(inputs)]

    sum((predictions .- outputs) .^ 2)
end

# Returns the fitness of a GTree using the L2 metric.
#   - inputs is a matrix where each column is an input vector.
#   - outputs is a vector with the output corresponding to each input vector.
function L2fitness(node, inputs, outputs)
    predictions = [eval(node, x) for x in eachcol(inputs)]

    predictionnorm = pnorm(predictions, 2)
    outputnorm = pnorm(outputs, 2)

    sqrt(sum((predictions .- outputs) .^ 2)) / (predictionnorm * outputnorm)
end

# Returns the cosine similarity between the predicted values of a GTree and outputs.
#   - inputs is a matrix where each column is an input vector.
#   - outputs is a vector with the output corresponding to each input vector.
#   - returns values between -1 and 1, the closer to 1 the better.
function cosinesim(node, inputs, outputs)
    predictions = [eval(node, x) for x in eachcol(inputs)]

    predictionnorm = pnorm(predictions, 2)

    outputnorm = pnorm(outputs, 2)

    sim = sum(predictions .* outputs) / (predictionnorm * outputnorm)
    isnan(sim) || isinf(sim) ? 999 : -sim
end

end
