module Operators

using Match

struct Operator
    application::Function
    symbol::String
    arity::Int
end

# Unary Operators
idtty = Operator(x -> x, "𝐈", 1)
inv = Operator(x -> 1 / x, "⁻¹", 1)
pow2 = Operator(x -> x^2, "²", 1)
pow3 = Operator(x -> x^3, "³", 1)
pow4 = Operator(x -> x^4, "⁴", 1)
pow5 = Operator(x -> x^5, "⁵", 1)
exp = Operator(x -> exp(x), "ℯ", 1) # this makes things break idk why
sin_ = Operator(x -> sin(x), "sin", 1)
cos_ = Operator(x -> cos(x), "cos", 1)
log_ = Operator(x -> x < 0 ? 0 : log(x), "log", 1)
sqrt_ = Operator(x -> x < 0 ? 0 : sqrt(x), "√", 1)

# Binary Operators
plus = Operator((x, y) -> x + y, "+", 2)
minus = Operator((x, y) -> x - y, "-", 2)
mult = Operator((x, y) -> x * y, "⋅", 2)
div = Operator((x, y) -> x / y, "÷", 2)
powN = Operator((x, y) -> x^y, "^", 2)

function strToOperator(operator::String)::Operator
    @match operator begin
        "^-1" => inv
        "inv" => inv
        "^2" => pow2
        "pow2" => pow2
        "^3" => pow3
        "pow3" => pow3
        "^4" => pow4
        "pow4" => pow4
        "^5" => pow5
        "pow5" => pow5
        "sin" => sin_
        "cos" => cos_
        "+" => plus
        "plus" => plus
        "*" => mult
        "mult" => mult
        "/" => div
        "div" => div
        "log" => log_
        "e^" => exp
        "exp" => exp
        "sqr" => sqrt_
        "powN" => powN
        "^n" => powN
        _ => identity
    end
end

end
