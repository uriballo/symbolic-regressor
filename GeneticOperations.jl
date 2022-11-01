module GeneticOperations

include("MathExpressions.jl")

import .MathExpressions as me

# (delete subTree) || (replace subTree by random Expr) || (replace function at node) || (turn function into constant)
function regularMutate(expr::me.MathExpr)::me.MathExpr
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
    randomSubExpr = me.randomNode(expr)

    coinflip = rand(1:2)

    if coinflip == 1
        mutateSubtree(expr, randomSubExpr)
    else
       mutateNode(expr, randomSubExpr) 
    end
end

function mutateSubtree(expr::me.MathExpr, subexpr::me.MathExpr)::me.MathExpr

end

function mutateNode(expr::me.MathExpr, subexpr::me.MathExpr)::me.MathExpr

end

function regularCrossover(
    expr1::me.MathExpr,
    expr2::me.MathExpr,
)::MathExpr
    """
    sub random node for random node
            produces 1 offspring
    """
end

function regularFitness(expr::me.MathExpr, fitnessFunc::Function)::Float64 end

end
