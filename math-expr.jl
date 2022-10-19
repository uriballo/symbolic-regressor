module MathExprs
using SymbolicUtils

# Struct that represents a math expression.
#   * `mutable` -> keyword that makes instances modifiable, required for genetic mutations.
#   * `Base.@kwdef` -> macro that allows default values and keyword-based constructors.
Base.@kwdef mutable struct MathExpr 
    # Arity. 
    arity :: Int = 0

    # Expression type.
    constant  :: Bool = false
    parameter :: Bool = false
    operator  :: Bool = false

    # Expression values.
    value       :: Float64 = 0.0
    parameterId :: Int = 0
    operatorId  :: String = ""

    opratorF :: Function = identity

    # Childs for arity >=1 expressions.
    leftChild  :: Union{MathExpr, Nothing} = nothing
    rightChild :: Union{MathExpr, Nothing} = nothing
end

function printTree(expr :: Union{MathExpr, Nothing})
    if typeof(expr) == Nothing
        return
    end

    printTree(expr.leftChild)

    expr.constant ? print(expr.value) : (expr.operator ? print(expr.operatorId) : print("x$(expr.parameterId)"))

    printTree(expr.rightChild)
end

# Given a math expr it adds a node to it.
#   * note that it only adds to left/right child of the node passed as a param.
function addNode(expr :: MathExpr, newNode :: MathExpr, position:: Int)
    if position == 0
        expr.leftChild = newNode
    else 
        expr.rightChild = newNode
    end
end

function binaryOperationNode(op:: MathExpr, leftParam :: MathExpr, rightParam :: MathExpr)
    # must create a copy, otherwise we won't mutate the full parameter expression.
    op2 = op
    op2.leftChild = leftParam
    op2.rightChild = rightParam
    op = op2
    #addNode(op, leftParam, 0)
    #addNode(op, rightParam, 1)
end

function unaryOperationNode(op:: MathExpr, param :: MathExpr)
    # must create a copy, otherwise we won't mutate the full parameter expression.
    op2 = op
    op2.leftChild = param
    op = op2
    #addNode(op, param, 0)
end

# Calculates the number of nodes in a math expression
function exprNodes(expr:: MathExpr):: Int
    if(expr.arity == 0) # constant or parameter
        return 1
    elseif (expr.arity == 1) # unary operator
        return 1 + exprNodes(expr.leftChild)
    else
        return 1 + exprNodes(expr.leftChild) + exprNodes(expr.rightChild)
    end
end

# Calculates the complexity (as depth) of the math expression.
function exprComplexity(expr:: MathExpr)::Int
    if(expr.arity == 0) # constant or parameter
        return 1
    elseif (expr.arity == 1) # unary operator
        return 1 + exprComplexity(expr.leftChild)
    else
        return 1 + max(exprComplexity(expr.leftChild) + exprComplexity(expr.rightChild))
    end

end

# Converts all params to constants for a given set of inputs
function mapInputsToParams(expr :: MathExpr, inputs :: Array{Float})

end

# Evaluates a MathExpr.
#   * the expression must have been converted so it has all params mapped to inputs.
function evaluateExpr(expr :: MathExpr):: Float64
"""
if leaf 
    return expr.value
elif unaryOperator
    return expr.operatorId(eval(op.leftChild)))
else
    retrun op(op.leftChild, rightChild)
"""
end

# Converts the expression from MathExpr → symbolic and simplifies it.
function simplifyExpr(expr:: MathExpr)
end


# Tests
# 2.3 + 2.6
expression = MathExpr(operator = true, operatorId = "+")

#addNode(expression, MathExpr(constant = true, value = 2.3), 0)
#addNode(expression, MathExpr(constant = true, value = 2.6), 1)

xpr2 = (binaryOperationNode(MathExpr(operator = true, operatorId = "+"), MathExpr(constant = true, value = 2.3), MathExpr(constant = true, value = 2.8)))
printTree(xpr2)

# x1^3 + 2x3 -1 
plus = MathExpr(operator = true, operatorId = "+")
minus = MathExpr(operator = true, operatorId = "-")
cube = MathExpr(operator = true, operatorId = "³") 
mult = MathExpr(operator = true, operatorId = "⋅")

expression3 = plus

x1 = MathExpr(parameter = true, parameterId = 1)
x3 = MathExpr(parameter = true, parameterId = 3)

one = MathExpr(constant = true, value = 1.0)

two = MathExpr(constant = true, value = 2.0)

x1Cube = unaryOperationNode(cube, x1)
twoX3 = binaryOperationNode(mult, x3, two)
twoX3m1 = binaryOperationNode(minus, twoX3, one)

expression2 = binaryOperationNode(plus, x1Cube, twoX3m1)
println()
printTree(expression2)

println()
end