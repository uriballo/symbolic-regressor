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

function strToOperator(operator:: String)::Operator
    @match operator begin
        "^-1"  => inv
        "inv"  => inv
        "^2"   => pow2
        "pow2" => pow2
        "^3"   => pow3
        "pow3" => pow3
        "^4"   => pow4
        "pow4" => pow4 
        "^5"   => pow5
        "pow5" => pow5
        "sin"  => sin_
        "cos"  => cos_
        "+"    => plus
        "plus" => plus
        "*"    => mult
        "mult" => mult
        "/"    => div
        "div"  => div
        "log"  => log_
        "e^"   => exp
        "exp"  => exp
        "sqr"  => sqrt_
        "powN" => powN
        "^n"   => powN
        _      => identity   
    end    
end

end
