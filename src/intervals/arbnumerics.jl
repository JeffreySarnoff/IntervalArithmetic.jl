# ArbNumerics is imported in IntervalArithmetic.jl
using ArbNumerics: ArbFloat, ArbReal, ArbComplex, 
    setworkingprecsion, setextrabits,
    setball, setinterval, lobound, hibound

export gamma

const SupplementalBits = 32

mutable struct PriorPrecision
    type::Type
    prec::Int
end    

# initialize to something that does not occur
const PriorPrec = PriorPrecision(UInt8, -1)  

function resetworkingprecision(supplementalbits::Int=SupplementalBits)
    typ, prec = precision(Interval)
    if prec !== PriorPrec.prec    
        workingprec = prec + supplementalbits
        setextrabits(0)
        setworkingprecision(ArbFloat, workingprec)
        # uncomment to future-proof
        # setworkingprecision(ArbReal, workingprec)
        # setworkingprecision(ArbComplex, workingprec)
        PriorPrec.type = typ
        PriorPrec.prec = prec
    end
    return nothing
end

function arbreal(x::Interval)
    resetworkingprecision()
    xlo = x.lo
    xhi = x.hi
    extraprec = Prior.prec + SupplementalBits
    lo = copy(ArbFloat(x, extraprec), Prior.prec, RoundDown)
    hi = copy(ArbFloat(x, extraprec), Prior.prec, RoundUp)
    return setinterval(lo, hi)
 end
 
function gamma(x::Interva{T}) where T
    result = gamma(arbreal(x))
    lo, hi = ArbNumerics.interval(result)
    ylo, yhi = T(lo), T(hi)
    return Interval(ylo, yhi)
 end 
    
