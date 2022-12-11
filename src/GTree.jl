module GTrees

include("Utils.jl")

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

# Prints the expression represented by a GTree using infix notation.
function Base.show(io::IO, node::GTree)
    stringtree = toString(node)
    print(io, stringtree)
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
# Returns a string representation of a GTree using infix notation.
function toString(node::GTConstant)
    node.symbol
end

function toString(node::GTParameter)
    node.symbol
end

function toString(node::GTBinaryNode)
    "(" * toString(node.input[1]) * " " * node.symbol * " " * toString(node.input[2]) * ")"
end

function toString(node::GTUnaryNode)
    if isprefixoperator(node.symbol)
        node.symbol * "(" * toString(node.input) * ")"
    else
        "(" * toString(node.input) * ")" * node.symbol
    end
end

####################
# Returns a list of the symbols of a GTree.
function exprsyms(node)
    symbolsstring = getSymbols(node)

    unique(split(symbolsstring))
end

function getSymbols(node::GTParameter)
    node.symbol * " "
end

function getSymbols(node::GTConstant)
    if node.symbol ∈ ["𝐺", "𝑒", "𝜋"]
       node.symbol * " " 
    else
        ""
    end
end

function getSymbols(node::GTBinaryNode)
    getSymbols(node.input[1]) * getSymbols(node.input[2])
end

function getSymbols(node::GTUnaryNode)
    getSymbols(node.input)
end

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
#     - the method can be either "grow" (1) or "full" (2).
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

####################
# Returns the one-point crossover of two GTrees.

function crossover(parent1, parent2)
    crossover(parent2, parent1) # crossover is "symmetric".
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
    parent2::Union{GTUnaryNode,GTBinaryNode}, # Union since the operation is the same for any combination of the arg types
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

# Applies the crossover function k-times.
function k2crossover(parent1, parent2)
    kcrossover(parent1, parent2, 2)
end

function k3crossover(parent1, parent2)
    kcrossover(parent1, parent2, 3)
end

function k4crossover(parent1, parent2)
    kcrossover(parent1, parent2, 4)
end

function kcrossover(parent1, parent2, k)
    child = copy(parent1)

    for _ = 1:k
        child = crossover(child, parent2)
    end

    child
end

"""
> Mutation Functions
"""

####################
# Returns a mutatied GTree.
function mutate(node, funcset, termset)
    mutation = randexpr(funcset, termset, rand(1:2), 1)

    mutationpoint = rand(0:nnodes(node)-1)

    set(node, mutationpoint, mutation)
end

# Applies the mutation function k-times.
function k2mutate(node, funcset, termset)
    kmutate(node, funcset, termset, 2)
end

function k3mutate(node, funcset, termset)
    kmutate(node, funcset, termset, 3)
end

function k4mutate(node, funcset, termset)
    kmutate(node, funcset, termset, 4)
end

function kmutate(node, funcset, termset, k)
    for _ = 1:k
        node = mutate(node, funcset, termset)
    end

    node
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

# Reurns an array of random GTrees.
#   - unlike halfandhalf, the method is chosen randomly for each tree.
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

# Returns the fitness of a GTree using the squared sum of errors.
#   - in theory more efficient than L2fitness due to the lack of sqrt and norms that are not really relevant for the fitness.
#   - it has a small penalization factor for complex expressions i.e. it favours simpler ones.
#   - inputs is a matrix where each column is an input vector.
#   - outputs is a vector with the output corresponding to each input vector.
function errorfitness(node, inputs, outputs)
    predictions = [eval(node, x) for x in eachcol(inputs)]

    sum((predictions .- outputs) .^ 2) + depth(node) * 7e-20
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
#   - returns values between -1 and 1, the closer to -1 the better (it's inverted to have consistency with the other fitness functions).
function cosinesim(node, inputs, outputs)
    predictions = [eval(node, x) for x in eachcol(inputs)]

    predictionnorm = pnorm(predictions, 2)

    outputnorm = pnorm(outputs, 2)

    sim = sum(predictions .* outputs) / (predictionnorm * outputnorm)
    isnan(sim) || isinf(sim) ? 999 : -sim
end

end
