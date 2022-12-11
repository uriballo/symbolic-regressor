using SymbolicUtils

# Given a function in string format returns the corresponding function.
#  - limited function support.
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

# Returns a matrix with the inputs from 'filename'.
#   - filename must be in the data folder.
function loadinputs(filename)
    inputs = CSV.read("../data/" * filename, DataFrame)

    transpose(Matrix(inputs))
end

# Returns a vector with the outputs from 'filename'.
#   - filename must be in the data folder.
function loadoutputs(filename)
    outputs = CSV.read("../data/" * filename, DataFrame)

    vec(Matrix(outputs))
end

# Returns whether the string is a prefix operator e.g. sin(...) yes, ^2 not.
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

# Returns the string with the unicode characters replaced by code-accepted equivalents.
function normalizeunicode(string)
    string = replace(
        string,
        "²" => "^2",
        "³" => "^3",
        "⁻¹" => "^-1",
        "×" => "*",
        "÷" => "/",
        "√" => "sqrt",
    )
end

# Shows the command to run on a terminal to simplify the expression.
function simplifycmd(expr, symbols)
    syms = join(symbols, " ")

    commandstring =
        "julia -e 'using SymbolicUtils; @syms " *
        syms *
        "; println(\"\\n[~] \", simplify(" *
        normalizeunicode(expr) *
        "))'"

    println("[!] Run the following command on a terminal to simplify the expression:")
    println("\n[>] " * commandstring)
    println()
end

# Returns the p-norm of a vector v.
function pnorm(v, p)
    absv = abs.(v)
    sum((absv) .^ p)^(1 / p)
end
