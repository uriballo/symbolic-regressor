module MathExprs

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
    addNode(op, leftParam, 0)
    addNode(op, rightParam, 1)
end

function unaryOperationNode(op:: MathExpr, param :: MathExpr)
    addNode(op, param, 0)
end

# Tests
# 2.3 + 2.6
expression = MathExpr(operator = true, operatorId = "+")

addNode(expression, MathExpr(constant = true, value = 2.3), 0)
addNode(expression, MathExpr(constant = true, value = 2.6), 1)

printTree(expression)
# x1^3 + 2x3 -1 
# TODO: Fix Method ERROR
plus = MathExpr(operator = true, operatorId = "+")
minus = MathExpr(operator = true, operatorId = "-")
cube = MathExpr(operator = true, operatorId = "³") 
mult = MathExpr(operator = true, operatorId = "⋅")

x1 = MathExpr(parameter = true, parameterId = 1)
x3 = MathExpr(parameter = true, parameterId = 3)

one = MathExpr(constant = true, value = 1.0)

two = MathExpr(constant = true, value = 2.0)

x1Cube = unaryOperationNode(cube, x1)
twoX3 = binaryOperationNode(mult, x3, two)
twoX3m1 = binaryOperationNode(minus, twoX3, one)

expression2 = MathExpr(plus, x1Cube, twoX3m1)

printTree(expression2)

println()
end