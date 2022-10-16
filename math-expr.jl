# `mutable` so it can be modified
mutable struct MathExpr 
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
end

function print(mathExpr)
end

function toSymbolic(mathExpr: MathExpr)
end

function evaluateExpr(mathExpr: MathExpr, inputs: [Float64])
end

