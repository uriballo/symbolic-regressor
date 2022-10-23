"""
# Tests
# 2.3 + 2.6
expression = MathExpr(operator = true, operatorId = "+")

#addNode(expression, MathExpr(constant = true, value = 2.3), 0)
#addNode(expression, MathExpr(constant = true, value = 2.6), 1)

xpr2 = (binaryOperationNode(MathExpr(operator = true, operatorId = "+"), MathExpr(constant = true, value = 2.3), MathExpr(constant = true, value = 2.8)))
printTree(xpr2)

# x1^3 + 2x3 -1 
plus = MathExpr(operator = true, operatorId = "+")
minus = MathExpr(operator = true, operatorId = "-")
cube = MathExpr(operator = true, operatorId = "³") 
mult = MathExpr(operator = true, operatorId = "⋅")

expression3 = plus

x1 = MathExpr(parameter = true, parameterId = 1)
x3 = MathExpr(parameter = true, parameterId = 3)

one = MathExpr(constant = true, value = 1.0)

two = MathExpr(constant = true, value = 2.0)

x1Cube = unaryOperationNode(cube, x1)
twoX3 = binaryOperationNode(mult, x3, two)
twoX3m1 = binaryOperationNode(minus, twoX3, one)

expression2 = binaryOperationNode(plus, x1Cube, twoX3m1)
println()
printTree(expression2)

println()sxdszasdfgvfcdxzAsdfgtyhvc
"""