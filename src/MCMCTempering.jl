module MCMCTempering

import AbstractMCMC
import Distributions
import Random

using ProgressLogging: ProgressLogging
using ConcreteStructs: @concrete
using Setfield: @set, @set!

using InverseFunctions

using DocStringExtensions

include("adaptation.jl")
include("swapping.jl")
include("state.jl")
include("sampler.jl")
include("sampling.jl")
include("ladders.jl")
include("stepping.jl")
include("model.jl")

export tempered,
    tempered_sample,
    TemperedSampler,
    make_tempered_model,
    StandardSwap,
    RandomPermutationSwap,
    NonReversibleSwap

function AbstractMCMC.bundle_samples(
    ts::Vector,
    model::AbstractMCMC.AbstractModel,
    sampler::TemperedSampler,
    state::TemperedState,
    chain_type::Type;
    kwargs...
)
    AbstractMCMC.bundle_samples(
        ts, model, sampler_for_chain(sampler, state, 1), state_for_chain(state, 1), chain_type;
        kwargs...
    )
end

end
