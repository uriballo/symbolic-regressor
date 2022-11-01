module MathExpressions

include("Operators.jl")

using .Operators

# Struct that represents a math expression.
#   * `mutable` -> keyword that makes instances modifiable, required for genetic mutations.
#   * `Base.@kwdef` -> macro that allows default values and keyword-based constructors.
Base.@kwdef mutable struct MathExpr
    # Arity. 
    arity::Int = 0

    # Expression type.
    constant::Bool = false
    parameter::Bool = false
    operator::Bool = false

    # Expression numerical values.
    value::Real = 0.0 # value of a constant or a parameter for a given instance.
    parameterId::Int = 0    # index of the parameter e.g. 1 for x1, 3 for x3...  
    parameterSymbol::String = "Χ"

    # Expression functional values.
    operatorOp::Operators.Operator = Operators.idtty

    # Childs for arity >=1 expressions.
    leftChild::Union{MathExpr,Nothing} = nothing # first parameter for binary operators or parameter of unary ones.
    rightChild::Union{MathExpr,Nothing} = nothing # second parameter for binary operators.
end

# Creates a MathExpr that represents a constant value.
function constantNode(value::Real)::MathExpr
    return MathExpr(constant = true, value = value, arity = 0)
end

# Creates a MathExpr that represents a parameter.
#   * the 'id' will be the entry of the vector of inputs that will be used when evaluated.
#   * id >= 1, since julia uses 1-based indexing.
function parameterNode(id::Int, symbol::String)::MathExpr
    return MathExpr(parameter = true, parameterId = id, arity = 0, parameterSymbol = symbol)
end

# Creates a MathExpr that respresents a binary operation.
function operatorNode(
    id::String,
    p1::Union{MathExpr,Nothing},
    p2::Union{MathExpr,Nothing},
)::MathExpr
    operatorFunc = Operators.strToOperator(id)

    return MathExpr(
        operator = true,
        arity = 2,
        operatorOp = operatorFunc,
        leftChild = p1,
        rightChild = p2,
    )
end

# Creates a MathExpr that represents an unary operation.
function operatorNode(id::String, p1::Union{MathExpr,Nothing} = nothing)::MathExpr
    operatorFunc = Operators.strToOperator(id)

    return MathExpr(
        operator = true,
        arity = 1,
        operatorOp = operatorFunc,
        leftChild = p1,
    )
end

# Creates a MathExpr that represents an empty operator.
function operatorNode(operatorF::Operators.Operator)::MathExpr
    return MathExpr(
        operator = true,
        arity = operatorF.arity,
        operatorOp = operatorF,
    )
end

# Prints a MathExpr through console.
function printTree(expr)   
    if expr.arity > 0
        printTree(expr.leftChild)
    end

    if expr.constant 
        print(expr.value)
    elseif expr.operator 
        print(expr.operatorOp.symbol)
    else
        print(expr.parameterSymbol)
    end

    #expr.constant ? print(expr.value) :
    #(expr.operator ? print(expr.operatorOp.symbol) : print(expr.parameterSymbol))
    if expr.arity == 2
        printTree(expr.rightChild)
    end
end

# Calculates the number of nodes in a MathExpr.
function countNodes(expr::MathExpr)::Int
    if (expr.arity == 0) # constant or parameter
        return 1
    elseif (expr.arity == 1) # unary operator
        return 1 + countNodes(expr.leftChild)
    else # binary operator
        return 1 + countNodes(expr.leftChild) + countNodes(expr.rightChild)
    end
end

function countNodes(expr::Nothing)::Int
    return 0
end

# Calculates the complexity (as depth) of a MathExpr.
function exprComplexity(expr::MathExpr)::Int
    if (expr.arity == 0) # constant or parameter
        return 1
    elseif (expr.arity == 1) # unary operator
        return 1 + exprComplexity(expr.leftChild)
    else
        return 1 + max(exprComplexity(expr.leftChild), exprComplexity(expr.rightChild))
    end

end

# Evaluates a MathExpr without any input parameters taken into account.
#   * useful only for constant expressions.
function evaluateExpr(expr::MathExpr)::Real
    if (expr.arity == 0)
        return expr.value
    elseif (expr.arity == 1)
        return expr.operatorOp.application(evaluateExpr(expr.leftChild))
    else
        return expr.operatorOp.application(
            evaluateExpr(expr.leftChild),
            evaluateExpr(expr.rightChild),
        )
    end
end

# Evaluates a MathExpr with input parameters.
function evaluateExpr(expr::MathExpr, inputs::Vector{Float64})::Real
    if (expr.arity == 0)
        if expr.parameter
            return inputs[expr.parameterId]
        else
            return expr.value
        end
    elseif (expr.arity == 1)
        return expr.operatorOp.application(evaluateExpr(expr.leftChild, inputs))
    else
        return expr.operatorOp.application(
            evaluateExpr(expr.leftChild, inputs),
            evaluateExpr(expr.rightChild, inputs),
        )
    end
end

# Auxiliary Functions

# Conversions to MathExpr.
function toMathExpr(expr::MathExpr)
    expr
end

function toMathExpr(expr::Nothing):: MathExpr
    return MathExpr()
end

# Returns the nth node.
function getNode(expr::Union{MathExpr,Nothing}, node::Int)::Union{MathExpr,Nothing}
    if typeof(expr) != Nothing
        if node == 0
            return expr
        else 
            leftChildNode = nothing
            rightChildNode = nothing 

            if expr.arity >= 1
                leftChildNode = getNode(expr.leftChild, node - 1) 
            end
        
            if expr.arity > 1 
                rightChildNode = getNode(expr.rightChild, node - countNodes(expr.leftChild) -1 )
            end

            return typeof(rightChildNode) == Nothing ? leftChildNode : rightChildNode
        end
    end
end

function replaceNode(expr::Union{MathExpr,Nothing}, nnode::Int, nodeExpr::MathExpr)
    if typeof(expr) != Nothing
        if nnode == 0
            expr = nodeExpr
        else 
            replaceNode(expr.leftChild, nnode -1, nodeExpr)
            replaceNode(expr.rightChild, nnode -1 - countNodes(expr.leftChild), nodeExpr)
        end
    end
end

# Operator -> Operator
function replaceOperator(expr::MathExpr, operator::Operators.Operator)
    if expr.arity == operator.arity
       expr.operatorOp = operator
       expr 
    end
    expr
end

# (Constant || Param) -> Param
function replaceParameter(expr::MathExpr, param::Int, sym::String)
    if expr.constant
        expr.constant = false
        expr.parameter = true
        expr.value = 0.0
    end

    expr.parameterId = param
    expr.parameterSymbol = sym

    expr
end

# (Constant || Param) -> Constant
function replaceConstant(expr::MathExpr, cvalue::Real)
    if expr.parameter
        expr.parameter = false
        expr.constant = true
        expr.parameterId = 0
    end

    expr.value = cvalue

    expr
end

# Returns a random node.
function randomNode(expr::MathExpr)::MathExpr    
    randomValue = rand(0:countNodes(expr)-1)
    toMathExpr(getNode(expr, randomValue))
end

function randomNode(params, operators)::MathExpr
   type = rand(1:4)
   if type == 1
        return constantNode(10*rand())
   elseif type == 2
        param = rand(1:size(params, 1))

        return parameterNode(param, params[param])
   else
        op = rand(1:size(operators,1))

        return operatorNode(operators[op])
   end 
end

function append(expr, side, apExpr)
end

end