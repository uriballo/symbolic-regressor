using SymbolicUtils

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

function isprefixoperator(string)
    if string == "²"
        return false
    elseif string == "³"
        return false
    elseif string == "⁻¹"
        return false
    end

    return true
end

function normalizeunicode(string)
    string = replace(string,
    "²" => "^2",
    "³" => "^3",
    "⁻¹" => "^-1",
    "×" => "*",
    "÷" => "/",
    "√" => "sqrt",
    "π" => "", # since it already has a numerical value by defect we remove it from "symbols that need trasnlation".
    "𝐺" => "G")
end

function simplifycmd(expr, symbols)
    syms = normalizeunicode(join(symbols, " "))

    commandstring = "julia -e 'using SymbolicUtils; @syms " * syms *"; println(\"\\n[~] \", simplify( " * normalizeunicode(expr)*  " ))'"

    println("[!] Run the following command on a terminal to simplify the expression:")
    println("\n[>] " * commandstring)
    println()
end

# Returns the p-norm of a vector v.
function pnorm(v, p)
    absv = abs.(v)
    sum((absv) .^ p)^(1 / p)
end