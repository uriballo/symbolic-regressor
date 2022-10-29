module GeneticOperations

include("MathExpressions.jl")

using .MathExpressions

# (delete subTree) || (replace subTree by random Expr) || (replace function at node) || (turn function into constant)
function regularMutate(expr::MathExpressions.MathExpr)::MathExpressions.MathExpr
    """
    coinFlip subtree || node -> pick random node
    if (subtree)
        coinflip ? delete : subByRandom
    else if node
        if operator
            coinflip ? replacebyRandomOperator : turnIntoConstant 
        else if constant
            ???
    """
end

function regularCrossover(
    expr1::MathExpressions.MathExpr,
    expr2::MathExpressions.MathExpr,
)::MathExpr end

function regularFitness(expr::MathExpressions.MathExpr, fitnessFunc::Function)::Float64 end

end
