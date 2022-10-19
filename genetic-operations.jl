using MathExprs

function mutate(expr :: MathExpr):: MathExpr
end

function crossover(expr1 :: MathExpr, expr2 :: MathExpr):: MathExpr
end

function fitness(expr :: MathExpr, fitnessFunc :: Function):: Float64
end