
abstract type InvariantList <: AbstractInvariant end

title(invs::InvariantList) = invs.title
description(invs::InvariantList) = invs.description


# ## `AllInvariant`

struct AllInvariant{I<:AbstractInvariant} <: InvariantList
    invariants::Vector{I}
    title::String
    description::Union{Nothing, String}
    shortcircuit::Bool
end

AllInvariant(
    invariants, title::String;
    description = nothing,
    shortcircuit = true,
    kwargs...
) = invariant(AllInvariant(invariants, title, description, shortcircuit); kwargs...)

function satisfies(invs::AllInvariant, input)
    results = []
    keepchecking = true
    for inv in invs.invariants
        if !keepchecking
            push!(results, missing)
            continue
        else
            res = try
                satisfies(inv, input)
            catch e
                "Unexpected error while checking invariant: $e"
            end
            push!(results, res)
            if !isnothing(res) && invs.shortcircuit
                keepchecking = false
            end
        end

    end
    return all(isnothing, results) ? nothing : results
end


# ## `AnyInvariant`

struct AnyInvariant{I<:AbstractInvariant} <: InvariantList
    invariants::Vector{I}
    title::String
    description::Union{Nothing, String}
end

AnyInvariant(
    invariants, title::String;
    description = nothing,
    shortcircuit = true,
    kwargs...
) = invariant(AnyInvariant(invariants, title, description); kwargs...)


function satisfies(invs::AnyInvariant, input)
    results = []

    for inv in invs.invariants
        res = satisfies(inv, input)
        push!(results, res)
        if isnothing(res)
            return nothing
        end
    end
    return results
end
