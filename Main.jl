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
    println("\n---")

    # Two Plus Two Params
    num2 = me.parameterNode(1, "y")
    opTpt = me.operatorNode("+", num2, num2)
    
    println("Two Plus Two w/ Parameters")
    me.printTree(opTpt)
    print(" = ")
    print(me.evaluateExpr(opTpt, [2.0, 356.0]))
    println("\n---")

    # x squared
    xSquare = me.operatorNode("^2", me.parameterNode(1, "x"))
    println("x Squared")
    me.printTree(xSquare)

    println(" = ", me.evaluateExpr(xSquare, [3.2, 3.4, 43, 2]))
    println("\n---")

    # Kepler's Third Law Instance
    kp1 = me.operatorNode("/", me.operatorNode("^3", me.parameterNode(1, "R")), me.operatorNode("^2", me.parameterNode(2, "T")))
    println("Kepler Instance: Earth")
    me.printTree(kp1)  
    println(" = ", me.evaluateExpr(kp1, [1,365.25]))
    println("Kepler Instance: Jupiter")
    me.printTree(kp1)  
    println(" = ", me.evaluateExpr(kp1, [5.2, 4332.62]))
end

main()
