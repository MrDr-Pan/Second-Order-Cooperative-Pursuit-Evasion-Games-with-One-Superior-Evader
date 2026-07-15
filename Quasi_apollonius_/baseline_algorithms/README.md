Baseline algorithm modules
==========================

This folder contains baseline reinforcement learning modules for comparison:

- DDPG
- MADDPG
- MAAC
- MAPPO

The files provide the main actor-critic structures and update procedures. They are written as reusable modules and can be connected to a task-specific environment, training loop, and evaluation script. Hidden-layer sizes and critic output dimensions can be configured when constructing each algorithm.

Package layout:

```text
baselines/
  ddpg.py              DDPG agent
  maddpg.py            MADDPG multi-agent learner
  maac.py              Attention-critic multi-agent learner
  mappo.py             MAPPO agent
  networks.py          Actor, critic, and attention modules
  replay_buffer.py     Off-policy replay buffers
  rollout_buffer.py    On-policy rollout buffer
  utils.py             Noise, schedules, normalization, and checkpoints
```

Basic usage:

```python
from baselines import DDPGAgent, MADDPG, MAAC, MAPPOAgent

agent = DDPGAgent(
    obs_dim=16,
    act_dim=2,
    actor_hidden_dims=(256, 256, 128),
    critic_hidden_dims=(256, 256, 128),
    critic_output_dim=1,
)
action = agent.act(obs)
```
