module GeneticOperations

include("MathExpressions.jl")

import .MathExpressions as me

# (delete subTree) || (replace subTree by random Expr) || (replace function at node) || (turn function into constant)
function mutate(expr::me.MathExpr)::me.MathExpr
    nodes = me.countNodes

    regularMutate(expr, nodes)

    me.printTree(expr, 0)
end

function regularMutate(expr, nodes)
    if expr.arity > 0 
        regularMutate(expr.leftChild, nodes)
    end
    
    n = rand(1:nodes)
    if n == 1
        expr = me.randomNode
    end

    if expr.arity > 1
        regularMutate(expr.rightChild, nodes)
    end
end

function regularCrossover(expr1::me.MathExpr, expr2::me.MathExpr)::MathExpr
    """
    sub random node for random node
            produces 1 offspring
    """
end

function regularFitness(expr::me.MathExpr, fitnessFunc::Function)::Float64 end

end
