module MathExprs

# `mutable` so its intances can be modified
# Base.@kwdef -> macro that allows default values and keyword-based constructors
Base.@kwdef mutable struct MathExpr 
    """
    isconstant :: Bool
    isparameter :: Bool 
    isoperator :: Bool

    constantVal :: Float64
    parameterIndex :: Int
    operator:: ? ∈ [+, -, *, /, log, sin, cos, tan, e^, ^]

    arity :: Int ∈ [0,2] i.e. constant, unary-operator, binary-operator.

    leftExpr
    rightExpr
    """
    # 
    arity :: Int = 0

    #
    constant  :: Bool  = false
    parameter :: Bool = false
    operator  :: Bool = false

    #
    value       :: Float64 = 0.0
    parameterId :: Int = 0
    operatorId  :: String = ""

    #
    leftChild  :: Union{MathExpr, Nothing} = nothing
    rightChild :: Union{MathExpr, Nothing} = nothing
end

randomExpr = MathExpr(constant= true, value = 2.0)

println(randomExpr.value)

end