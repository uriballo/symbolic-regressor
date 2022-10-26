module MathExpressions 

include("Operators.jl")

using .Operators
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
    value       :: Real = 0.0
    parameterId :: Int = 0
    operatorId  :: String = ""

    operatorF :: Function = identity

    # Childs for arity >=1 expressions.
    leftChild  :: Union{MathExpr, Nothing} = nothing
    rightChild :: Union{MathExpr, Nothing} = nothing
end

function constantNode(value :: Real)::MathExpr
    return MathExpr(constant = true, value = value, arity = 0)
end

function parameterNode(id :: Int):: MathExpr
    return MathExpr(parameter = true, parameterId = id, arity = 0)
end

# Creates a _functional_ operator node.
function operatorNode(id:: String, p1:: Union{MathExpr, Nothing}, p2::Union{MathExpr, Nothing}):: MathExpr
    # If the types of p1 and p2 are different then we have just one parameter, if they are equal then we have
    # either 2 or 0.
    opArity = 2
    operatorFunc = Operators.strToOperator(id)

    return MathExpr(operator = true , arity = opArity, operatorId = id, operatorF = operatorFunc, leftChild = p1, rightChild = p2)
end

function operatorNode(id:: String, p1:: Union{MathExpr, Nothing} = nothing):: MathExpr
    # If the types of p1 and p2 are different then we have just one parameter, if they are equal then we have
    # either 2 or 0.
    opArity = 1
    operatorFunc = Operators.strToOperator(id)

    return MathExpr(operator = true , arity = opArity, operatorId = id, operatorF = operatorFunc, leftChild = p1)
end

function printTree(expr :: Union{MathExpr, Nothing})
    if typeof(expr) == Nothing
        return
    end

    printTree(expr.leftChild)

    expr.constant ? print(expr.value) : (expr.operator ? print(" ", expr.operatorId, " ") : print("x$(expr.parameterId)"))

    printTree(expr.rightChild)
end

# Calculates the number of nodes in a math expression
function exprNodes(expr:: MathExpr):: Int
    if (expr.arity == 0) # constant or parameter
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
        return 1 + max(exprComplexity(expr.leftChild),exprComplexity(expr.rightChild))
    end

end

# Adds the operator functions to a mathExpr
function subOperators(expr:: MathExpr)
    if(expr.arity == 0)
        return
    elseif (expr.arity == 1)
        auxExpr = expr
        auxExpr.operatorF = Operators.strToOperator(auxExpr.operatorId)
        expr = auxExpr
        subOperators(expr.leftChild)
    else 
        auxExpr = expr
        auxExpr.operatorF = Operators.strToOperator(auxExpr.operatorId)
        expr = auxExpr
        subOperators(expr.leftChild)
        subOperators(expr.rightChild)
    end
end

# Evaluates a MathExpr without parameters.
function evaluateExpr(expr :: MathExpr):: Real
    if (expr.arity == 0)
        return expr.value
    elseif (expr.arity == 1)
        return expr.operatorF(evaluateExpr(expr.leftChild))
    else
        return expr.operatorF(evaluateExpr(expr.leftChild), evaluateExpr(expr.rightChild))  
    end
end

# Evaluates a MathExpr with parameters.
function evaluateExpr(expr :: MathExpr, inputs :: Vector{Float64}):: Real
    if (expr.arity == 0)
        if expr.parameter
            return inputs[expr.parameterId]
        else 
            return expr.value
        end
    elseif (expr.arity == 1)
        return expr.operatorF(evaluateExpr(expr.leftChild, inputs))
    else
        return expr.operatorF(evaluateExpr(expr.leftChild, inputs), evaluateExpr(expr.rightChild))  
    end
end

function indexToNode(expr:: MathExpr, index:: Int)
    if (index == 0)
        return expr
    else
        # probably wont work bc once recursion untangles we'll have
        # old index value passed to right child.
        indexToNode(expr.leftChild, index-1)
        indexToNode(expr.rightChild, index-1)
    end 
end

function randomNode(expr:: MathExpr):: MathExpr
    nodes = exprNodes(expr)
    index = rand(1:nodes)
    
    return indexToNode(expr, index)
end

# Converts the expression from MathExpr → symbolic and simplifies it.
function simplifyExpr(expr:: MathExpr)
end

end