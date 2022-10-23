module Operators

using Match
# New operators

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