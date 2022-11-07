using CSV
using DataFrames

include("MathExpressions.jl")
include("ExprPopulation.jl")

import .MathExpressions as me
import .ExprPopulation as pp

function main()
    # Two Plus Twp
    num2 = me.constantNode(2.0)
    opTpt = me.operatorNode("+", num2, num2)
    """
    +
2        2
"""
    """
    println("Two Plus Two")
    me.printTree(opTpt)
    print(" = ")
    print(me.evaluateExpr(opTpt))
    println("\n---")

    # Two Plus Two Params
    num2 = me.parameterNode(1, "y")
    opTpt = me.operatorNode("+", num2, num2)
    """
    """
        +
    y        y
    """
    """
    println("Two Plus Two w/ Parameters")
    me.printTree(opTpt)
    print(" = ")
    print(me.evaluateExpr(opTpt, [2.0, 356.0]))
    println("\n---")

    # x squared
    xSquare = me.operatorNode("^2", me.parameterNode(1, "x"))
    println("x=3.2 Squared")
    me.printTree(xSquare)

    println(" = ", me.evaluateExpr(xSquare, [3.2, 3.4, 43, 2]))
    println("\n---")

    # Kepler's Third Law Instance
    kp1 = me.operatorNode(
        "/",
        me.operatorNode("^3", me.parameterNode(1, "R")),
        me.operatorNode("^2", me.parameterNode(2, "T")),
    )
    """
    """
                ÷
            ^3      ^2
        R              T

    println("Kepler Instance: Earth")
    me.printTree(kp1)
    println(" = ", me.evaluateExpr(kp1, [1, 365.25]))



    println("Kepler Instance: Jupiter")
    me.printTree(kp1)
    println(" = ", me.evaluateExpr(kp1, [5.2, 4332.62]))
    println()
    """
    """
        for _ in 1:10 
            randomNode = me.randomNode(kp1)

            if randomNode.parameter
                println("\t\t", randomNode.parameterSymbol)
            elseif randomNode.constant
                println("\t\t", randomNode.value)
            else
                println("\t\t",randomNode.operatorOp.symbol)
            end
        end
    
    kp1.leftChild.leftChild = me.replaceParameter(kp1.leftChild.leftChild, 2, "β")
    println("mod tree:")
    me.printTree(kp1)

    println("\n\n\n expr32")
    popl = pp.Population()
    expr32 = pp.randomExpr(popl)
    #println(expr32)
    me.printTree(expr32, 0)
    println()
    print(" = ")
    println(pp.me.evaluateExpr(expr32, [1.120, 2.320, 3.03, 3.4, 23.23, 123.2]))
    println()


    n = me.countNodes(expr32)
    q = rand(0:n-1)
    println("kp3")
kp3 = pp.mutateN(expr32, q, popl)
    me.printTree(kp3, 0)
    print(" = ")
    println(pp.me.evaluateExpr(kp3, [1.120, 2.320, 3.03, 3.4, 23.23, 123.2]))

    println()
    me.printTree(pp.crossover(expr32, kp3, popl), 0)
        """
    # POPULATION EVOLUTION
    size = 20
    inputs = CSV.read("symbolic-regressor/data/kepler1618-inputs.csv", DataFrame)
    outputs = CSV.read("symbolic-regressor/data/kepler1618-outputs.csv", DataFrame)

    outputVec = vec(Matrix(outputs))
    inputMat = transpose(Matrix(inputs))


    popl = pp.initPopulation(size, inputMat, outputVec)
    pp.evolve(popl, 10, 0, size, true)
    #keplerPopulation = pp.initPopulation()
end

main()
