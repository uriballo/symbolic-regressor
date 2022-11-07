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

    Operator(symbol::String, arity::Int, act::Function) =
        new(symbol, arity, act, Constant("", 0), Constant("", 0))
    Operator(symbol::String, arity::Int, act::Function, leftInput::SymNode) =
        new(symbol, arity, act, leftInput, Constant("", 0))
    Operator(symbol::String, arity::Int, act::Function, rightInput::SymNode) =
        new(symbol, arity, act, Constant("", 0), rightInput)
    Operator(
        symbol::String,
        arity::Int,
        act::Function,
        leftInput::SymNode,
        rightInput::SymNode,
    ) = new(symbol, arity, act, leftInput, rightInput)
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
    if node.arity > 0
        op.leftInput = copy(node.leftInput)
    end
    if node.arity > 1
        op.rightInput = copy(node.rightInput)
    end
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

function Base.isequal(a::Constant, b::Constant)
    a.symbol == b.symbol && a.value == b.value
end

function Base.isequal(a::Param, b::Param)
    a.symbol == b.symbol && a.id == b.id
end

function Base.isequal(a::Operator, b::Operator)
    a.symbol == b.symbol &&
        a.arity == b.arity &&
        a.act == b.act &&
        a.leftInput == b.leftInput &&
        a.rightInput == b.rightInput
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
eval(x::Operator, inputs) =
    x.arity == 1 ? x.act(eval(x.leftInput, inputs)) :
    x.act(eval(x.leftInput, inputs), eval(x.rightInput, inputs))

nnodes(node::Operator) =
    1 + node.arity == 1 ? nnodes(node.leftInput) :
    nnodes(node.leftInput) + nnodes(node.rightInput)
nnodes(node::SymNode) = 1
nnodes(node::Nothing) = 0

complexity(node::Operator) = 1 + max(nnodes(node.leftInput), nnodes(node.rightInput))
complexity(node::SymNode) = 1

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
        rnode = lnode = nothing
        if i > 0
            lnode = get(node.leftInput, n - 1)
        end
        if i > 1
            rnode = get(node.rightInput, n - nnodes(node.leftInput) - 1)
        end

        rnode === nothing ? lnode : (rnode === nothing ? nothing : rnode)
    end
end

function set!(node::Param, n::Int, newnode::SymNode)
    if n == 0
        node = copy(newnode)
    end
end

function set!(node::Constant, n::Int, newnode::SymNode)
    if n == 0
        node = copy(newnode)
    end
end

function set!(node::Operator, n::Int, newnode)
    if n == 0
        node = copy(newnode)
    else
        i = node.arity
        rnode = lnode = nothing
        if i > 0
            lnode = set!(node.leftInput, n - 1, newnode)
        end
        if i > 1
            rnode = set!(node.rightInput, n - nnodes(node.leftInput) - 1, newnode)
        end

        if lnode === nothing && rnode === nothing
            nothing
        else
            if lnode !== nothing
                node.leftInput = lnode
            elseif rnode !== nothing
                node.rightInput = rnode
            end
        end
    end
end

function set(node::Param, n::Int, newnode::SymNode)
    if n == 0
        node = copy(newnode)
    end
    node
end

function set(node::Constant, n::Int, newnode::SymNode)
    if n == 0
        node = copy(newnode)
    end
    node
end

function set(node::Operator, n::Int, newnode)
    if n == 0
        node = copy(newnode)
        node
    else
        i = node.arity
        rnode = lnode = nothing
        if i > 0
            lnode = set!(node.leftInput, n - 1, newnode)
        end
        if i > 1
            rnode = set!(node.rightInput, n - nnodes(node.leftInput) - 1, newnode)
        end

        if lnode === nothing && rnode === nothing
            node
        else
            if lnode !== nothing
                node.leftInput = lnode
            elseif rnode !== nothing
                node.rightInput = rnode
            end
            node
        end
    end
end

function random(node::SymNode)
    get(node, rand(0:nnodes(node)-1))
end

end # module
