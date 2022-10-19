module GeneticOperations
using MathExprs

function regularMutate(expr :: MathExpr):: MathExpr
end

function regularCrossover(expr1 :: MathExpr, expr2 :: MathExpr):: MathExpr
end

function regularFitness(expr :: MathExpr, fitnessFunc :: Function):: Float64
end

end