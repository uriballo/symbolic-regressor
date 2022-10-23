module GeneticOperations

include("MathExpressions.jl")

using .MathExpressions

function regularMutate(expr :: MathExpressions.MathExpr):: MathExpressions.MathExpr
end

function regularCrossover(expr1 :: MathExpressions.MathExpr, expr2 :: MathExpressions.MathExpr):: MathExpr
end

function regularFitness(expr :: MathExpressions.MathExpr, fitnessFunc :: Function):: Float64
end

end