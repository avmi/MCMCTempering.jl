
function swap_βs(Δ_state, k)
    
    Δ_state[k], Δ_state[k + 1] = Δ_state[k + 1], Δ_state[k]
    
    return Δ_state
end

function make_tempered_logπ end
function get_θ end

function get_densities_and_θs(
    model,
    sampler::AbstractMCMC.AbstractSampler,
    states,
    k::Integer,
    Δ::Vector{T},
    Δ_state::Vector{<:Integer}
) where {T<:AbstractFloat}
    
    logπk = make_tempered_logπ(model, Δ[Δ_state[k]])
    logπkp1 = make_tempered_logπ(model, Δ[Δ_state[k + 1]])
    
    θk = get_θ(states[k][2])
    θkp1 = get_θ(states[k + 1][2])
    
    return logπk, logπkp1, θk, θkp1
end


"""
    swap_acceptance_pt

Calculates and returns the swap acceptance ratio for swapping the temperature of two chains, the `k`th and `k + 1`th
- `model` an AbstractModel implementation defining the density likelihood for sampling
- `samplek` contains sampled parameters of the `k`th chain at which to calculate the log density
- `samplekp1` contains sampled parameters of the `k + 1`th chain at which to calculate the log density
- `θk` is the temperature of the `k`th chain
- `θkp1` is the temperature of the `k + 1`th chain PT may be swapping the `k`th chain's temperature with
"""
function swap_acceptance_pt(logπk, logπkp1, θk, θkp1)
    return min(
        1,
        exp(logπkp1(θk) + logπk(θkp1)) / exp(logπk(θk) + logπkp1(θkp1))
        # exp(abs(βk - βkp1) * abs(AdvancedMH.logdensity(model, samplek) - AdvancedMH.logdensity(model, samplekp1)))
    )
end


function swap_attempt(model, sampler, states, k, Δ, Δ_state)
    
    logπk, logπkp1, θk, θkp1 = get_densities_and_θs(model, sampler, states, k, Δ, Δ_state)
    
    A = swap_acceptance_pt(logπk, logπkp1, θk, θkp1)
    U = rand(Distributions.Uniform(0, 1))
    # If the proposed temperature swap is accepted according to A and U, swap the temperatures for future steps
    if U ≤ A
        Δ_state = swap_βs(Δ_state, k)
    end

    return Δ_state
end