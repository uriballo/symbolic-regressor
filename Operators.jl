module Operators

using Match

struct Operator
    application :: Function

    symbol :: String
end

# Unary Operators
idtty = Operator(x -> x, "𝐈")
inv   = Operator(x -> 1/x, "⁻¹")
pow2  = Operator(x -> x^2, "²")
pow3  = Operator(x -> x^3, "³")
pow4  = Operator(x -> x^4, "⁴")
pow5  = Operator(x -> x^5, "⁵")
exp   = Operator(x -> e^x, "ℯ")
sin_  = Operator(x -> sin(x), "sin")
cos_  = Operator(x -> cos(x), "cos")
log_  = Operator(x -> x < 0 ? 0 : log(x), "log")
sqrt_ = Operator(x -> x < 0 ? 0 : sqrt(x), "√")

# Binary Operators
plus  = Operator((x,y) -> x + y, "+") 
minus = Operator((x,y) -> x - y, "-") 
mult  = Operator((x,y) -> x * y, "⋅") 
div   = Operator((x,y) -> x / y, "÷")
powN  = Operator((x,y) -> x^y, "^")  

# Custom Operators
x⁻¹(x) = 1/x
x²(x)  = x^2
x³(x)  = x^3
x⁴(x)  = x^4
x⁵(x)  = x^5

eˣ(x) = ℯ^x # \euler to represent number 'e', Base.MathConstants.e

function strToOperator(operator:: String)::Function
    @match operator begin
        "^-1" => x⁻¹
        "^2"  => x² 
        "^3"  => x³
        "^4"  => x⁴
        "^5"  => x⁵
        "sin" => sin
        "cos" => cos
        "+"   => +
        "*"   => *
        "/"   => /
        "log" => log
        "e^"  => eˣ
        "sqr" => sqrt
        _     => identity   
    end    
end

end
