macro __splatnew__(T, args)
    esc(Expr(:splatnew, T, args))
end

macro __new__(T, arg)
    esc(Expr(:new, T, arg))
end

# """
#     __new__(T, args...)
# User-level version of the `new()` pseudofunction.
# Can be used to construct most Julia types, including structs
# without default constructors, closures, etc.
# """
# @inline function __new__(T, args...)
#     @__splatnew__(T, args)
# end

@inline @generated __new__(T, x...) = Expr(:new, :T, map(n -> :(x[$n]), 1:length(x))...)
# @inline @generated __splatnew__(T, x...) = Expr(:splatnew, :T, :x)

function __splatnew__(T, t)
    return __new__(T, t...)
end

"""
Unwrap constant value from its expression container such as
GlobalRef, QuoteNode, etc. No-op if there's no known container.
"""
promote_const_value(x::QuoteNode) = x.value
promote_const_value(x::GlobalRef) = getproperty(x.mod, x.name)
promote_const_value(x) = x


function module_of(f, args...)
    if f isa Core.IntrinsicFunction || f isa Core.Builtin
        # may be actually another built-in module, but it's ok for our use case
        return Core
    else
        types = map(Core.Typeof, args)
        return which(f, types).module
    end
end


function flatten(xs)
    res = []
    for x in xs
        append!(res, x)
    end
    return res
end
