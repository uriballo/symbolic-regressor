module MathExpressions 

include("Operators.jl")

using .Operators

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

    # Expression numerical values.
    value       :: Real = 0.0 # value of a constant or a parameter for a given instance.
    parameterId :: Int = 0    # index of the parameter e.g. 1 for x1, 3 for x3...  
    parameterSymbol :: String = "x"

    # Expression functional values.
    operatorId  :: String = ""       # id of the operator, see Operators.jl for available operators.
    operatorF :: Function = identity # function associated to the id.

    # Childs for arity >=1 expressions.
    leftChild  :: Union{MathExpr, Nothing} = nothing # first parameter for binary operators or parameter of unary ones.
    rightChild :: Union{MathExpr, Nothing} = nothing # second parameter for binary operators.
end

# Creates a MathExpr that represents a constant value.
function constantNode(value :: Real)::MathExpr
    return MathExpr(constant = true, value = value, arity = 0)
end

# Creates a MathExpr that represents a parameter.
#   * the 'id' will be the entry of the vector of inputs that will be used when evaluated.
#   * id >= 1, since julia uses 1-based indexing.
function parameterNode(id :: Int, symbol:: String):: MathExpr
    return MathExpr(parameter = true, parameterId = id, arity = 0, parameterSymbol = symbol)
end

# Creates a MathExpr that respresents a binary operation.
function operatorNode(id:: String, p1:: Union{MathExpr, Nothing}, p2::Union{MathExpr, Nothing}):: MathExpr
    operatorFunc = Operators.strToOperator(id)

    return MathExpr(operator = true , arity = 2, operatorId = id, operatorF = operatorFunc, leftChild = p1, rightChild = p2)
end

# Creates a MathExpr that represents an unary operation.
function operatorNode(id:: String, p1:: Union{MathExpr, Nothing} = nothing):: MathExpr
    operatorFunc = Operators.strToOperator(id)

    return MathExpr(operator = true , arity = 1, operatorId = id, operatorF = operatorFunc, leftChild = p1)
end

# Prints a MathExpr through console.
function printTree(expr :: Union{MathExpr, Nothing})
    if typeof(expr) == Nothing
        return
    end

    printTree(expr.leftChild)

    expr.constant ? print(expr.value) : (expr.operator ? print(" ", expr.operatorId, " ") : print(expr.parameterSymbol))

    printTree(expr.rightChild)
end

# Calculates the number of nodes in a MathExpr.
function exprNodes(expr:: MathExpr):: Int
    if (expr.arity == 0) # constant or parameter
        return 1
    elseif (expr.arity == 1) # unary operator
        return 1 + exprNodes(expr.leftChild)
    else # binary operator
        return 1 + exprNodes(expr.leftChild) + exprNodes(expr.rightChild)
    end
end

# Calculates the complexity (as depth) of a MathExpr.
function exprComplexity(expr:: MathExpr)::Int
    if(expr.arity == 0) # constant or parameter
        return 1
    elseif (expr.arity == 1) # unary operator
        return 1 + exprComplexity(expr.leftChild)
    else
        return 1 + max(exprComplexity(expr.leftChild),exprComplexity(expr.rightChild))
    end

end

# Evaluates a MathExpr without any input parameters taken into account.
#   * useful only for constant expressions.
function evaluateExpr(expr :: MathExpr):: Real
    if (expr.arity == 0)
        return expr.value
    elseif (expr.arity == 1)
        return expr.operatorF(evaluateExpr(expr.leftChild))
    else
        return expr.operatorF(evaluateExpr(expr.leftChild), evaluateExpr(expr.rightChild))  
    end
end

# Evaluates a MathExpr with input parameters.
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
        return expr.operatorF(evaluateExpr(expr.leftChild, inputs), evaluateExpr(expr.rightChild, inputs))  
    end
end

end