module SymExpr


# SymExpr.jl
#     * data structures for symbolic expressions
abstract type SymNode end

mutable struct Constant <: SymNode
    symbol::String
    value::Number
end

mutable struct Param <: SymNode
    symbol::String
    id::Int
end

mutable struct Operator <: SymNode
    symbol::String
    arity::Int
    act::Function

    leftInput::SymNode
    rightInput::SymNode

    Operator(symbol::String, arity::Int, act::Function) = new(symbol, arity, act)
    Operator(symbol::String, arity::Int, act::Function, leftInput::SymNode, rightInput::SymNode) = new(symbol, arity, act, leftInput, rightInput)
end

# Base methods
function Base.show(io::IO, node::Constant)
    print(io, node.symbol)
end

function Base.show(io::IO, node::Param)
    print(io, node.symbol)
end

function Base.copy(node::Constant)
    Constant(node.symbol, node.value)
end

function Base.copy(node::Param)
    Param(node.symbol, node.id)
end

function Base.copy(node::Operator) # atm only works with childless operators
    op = Operator(node.symbol, node.arity, node.act)
    op
end

function Base.show(io::IO, node::Operator)
    print(io, node.symbol)
    print(io, "(")
    i = node.arity 
    if i == 1 && node.leftInput !== nothing
        print(io, node.leftInput)
    elseif i == 2 && node.leftInput !== nothing && node.rightInput !== nothing
        print(io, node.leftInput, ", ")
        print(io, node.rightInput)
    end
    print(io, ")")
end

function Base.:(==)(a::Constant, b::Constant)
    a.symbol == b.symbol && a.value == b.value
end

function Base.:(==)(a::Param, b::Param)
    a.symbol == b.symbol && a.id == b.id
end

function Base.:(==)(a::Operator, b::Operator)
    a.symbol == b.symbol ? rand() <= 0.5 : false
end

# Computing
eval(x::Constant, inputs = []) = x.value
eval(x::Param, inputs) = inputs[x.id]
eval(x::Operator, inputs) = x.arity == 1 ? x.act(eval(x.leftInput, inputs)) : x.act(eval(x.leftInput, inputs), eval(x.rightInput, inputs))

nnodes(node::Operator) = 1 + x.arity == 1 ? nnodes(x.leftInput) : nnodes(x.leftInput) + nnodes(x.rightInput) 
nnodes(node::SymNode)  = 1
nnodes(node::Nothing)  = 0

complexity(node::Operator) = 1 + max(nnodes(node.leftInput), nnodes(node.rightInput))
complexity(node::SymNode)  = 1

function get(node::SymNode, n::Int)
    if n == 0
        node
    end
end

function get(node::Operator, n::Int)
    if n == 0 
        node
    else
        i = node.arity
        if i > 0 
            lnode = get(node.leftInput, n-1)
        end
        if i > 1
            rnode = get(node.rightInput, n - nnodes(node.leftInput) - 1)
        end

        rnode === nothing ? lnode : rnode
    end
end

function random(node::SymNode)
    get(node, rand(0:nnodes(node)-1))
end

end # module