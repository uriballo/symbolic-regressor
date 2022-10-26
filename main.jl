include("MathExpressions.jl")

import .MathExpressions as me

function main()
    # Two Plus Twp
    num2 = me.constantNode(2.0)
    opTpt = me.operatorNode("+", num2, num2)
    
    println("Two Plus Two")
    me.printTree(opTpt)
    print(" = ")
    print(me.evaluateExpr(opTpt))
    println("\nn-nodes: ", me.exprNodes(opTpt))
    println("complexity: ", me.exprComplexity(opTpt))
    println("\n---")

    # Two Plus Two Params
    num2 = me.parameterNode(1)
    opTpt = me.operatorNode("+", num2, num2)
    
    println("Two Plus Two")
    me.printTree(opTpt)
    print(" = ")
    print(me.evaluateExpr(opTpt))
    println("\nn-nodes: ", me.exprNodes(opTpt))
    println("complexity: ", me.exprComplexity(opTpt))
    println("\n---")

    # x squared
    xSquare = me.operatorNode("^2", me.parameterNode(1))
    println("x Squared")
    me.printTree(xSquare)

    println(" = ", me.evaluateExpr(xSquare, [3.2, 3.4, 43, 2]))
    println("\n---")
end

main()