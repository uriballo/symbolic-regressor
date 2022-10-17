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

# TESTS
randomExpr = MathExpr(constant= true, value = 2.0)

println(randomExpr.value)

end