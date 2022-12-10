function strtofunc(string)
    if string == "sin"
        return (sin, "sin", 1)
    elseif string == "cos"
        return (cos, "cos", 1)
    elseif string == "tan"
        return (tan, "tan", 1)
    elseif string == "^2"
        return (x -> x^2, "²", 1)
    elseif string == "^3"
        return (x -> x^3, "³", 1)
    elseif string == "^-1" || string == "1/x"
        return (x -> 1 / x, "⁻¹", 1)
    elseif string == "+"
        return (+, "+", 2)
    elseif string == "-"
        return (-, "-", 2)
    elseif string == "*"
        return (*, "×", 2)
    elseif string == "/"
        return (/, "÷", 2)
    elseif string == "sqrt"
        return (x -> sqrt(abs(x)), "√", 1)
    end
end