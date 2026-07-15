import copy

import torch
import torch.nn.functional as F

from .networks import AttentionCritic, DeterministicActor, soft_update
from .utils import load_checkpoint, save_checkpoint


class MAACAgent:
    def __init__(self, obs_dim, act_dim, n_agents, agent_id, act_limit=1.0, actor_lr=1e-4, critic_lr=1e-3, device="cpu"):
        self.agent_id = agent_id
        self.actor = DeterministicActor(obs_dim, act_dim, act_limit=act_limit).to(device)
        self.critic = AttentionCritic(obs_dim, act_dim, n_agents).to(device)
        self.target_actor = copy.deepcopy(self.actor).to(device)
        self.target_critic = copy.deepcopy(self.critic).to(device)
        self.actor_opt = torch.optim.Adam(self.actor.parameters(), lr=actor_lr)
        self.critic_opt = torch.optim.Adam(self.critic.parameters(), lr=critic_lr)


class MAAC:
    def __init__(
        self,
        n_agents,
        obs_dim,
        act_dim,
        act_limit=1.0,
        gamma=0.99,
        tau=0.005,
        actor_lr=1e-4,
        critic_lr=1e-3,
        device="cpu",
    ):
        self.n_agents = n_agents
        self.gamma = gamma
        self.tau = tau
        self.device = torch.device(device)
        self.agents = [
            MAACAgent(obs_dim, act_dim, n_agents, i, act_limit, actor_lr, critic_lr, self.device)
            for i in range(n_agents)
        ]
        self.total_updates = 0

    @torch.no_grad()
    def act(self, obs, noise_std=0.0):
        obs = torch.as_tensor(obs, dtype=torch.float32, device=self.device)
        actions = []
        for i, agent in enumerate(self.agents):
            action = agent.actor(obs[i].unsqueeze(0)).squeeze(0)
            if noise_std > 0:
                action = action + noise_std * torch.randn_like(action)
            actions.append(torch.clamp(action, -1.0, 1.0))
        return torch.stack(actions, dim=0).cpu().numpy()

    def update(self, batch, grad_clip=0.5):
        obs = batch["obs"].float()
        acts = batch["acts"].float()
        rews = batch["rews"].float()
        next_obs = batch["next_obs"].float()
        done = batch["done"].float()

        metrics = {}
        with torch.no_grad():
            target_next_acts = torch.stack(
                [agent.target_actor(next_obs[:, i]) for i, agent in enumerate(self.agents)],
                dim=1,
            )

        for i, agent in enumerate(self.agents):
            with torch.no_grad():
                next_q = agent.target_critic(next_obs, target_next_acts, i)
                target_q = rews[:, i] + self.gamma * (1.0 - done[:, i]) * next_q

            q = agent.critic(obs, acts, i)
            critic_loss = F.mse_loss(q, target_q)

            agent.critic_opt.zero_grad()
            critic_loss.backward()
            if grad_clip is not None:
                torch.nn.utils.clip_grad_norm_(agent.critic.parameters(), grad_clip)
            agent.critic_opt.step()

            policy_acts = acts.clone()
            policy_acts[:, i] = agent.actor(obs[:, i])
            actor_loss = -agent.critic(obs, policy_acts, i).mean()

            agent.actor_opt.zero_grad()
            actor_loss.backward()
            if grad_clip is not None:
                torch.nn.utils.clip_grad_norm_(agent.actor.parameters(), grad_clip)
            agent.actor_opt.step()

            soft_update(agent.target_actor, agent.actor, self.tau)
            soft_update(agent.target_critic, agent.critic, self.tau)

            metrics[f"agent_{i}_critic_loss"] = critic_loss.item()
            metrics[f"agent_{i}_actor_loss"] = actor_loss.item()

        self.total_updates += 1
        metrics["updates"] = self.total_updates
        return metrics

    def save(self, path):
        payload = {"total_updates": self.total_updates, "agents": []}
        for agent in self.agents:
            payload["agents"].append(
                {
                    "actor": agent.actor.state_dict(),
                    "critic": agent.critic.state_dict(),
                    "target_actor": agent.target_actor.state_dict(),
                    "target_critic": agent.target_critic.state_dict(),
                    "actor_opt": agent.actor_opt.state_dict(),
                    "critic_opt": agent.critic_opt.state_dict(),
                }
            )
        save_checkpoint(path, **payload)

    def load(self, path):
        ckpt = load_checkpoint(path, self.device)
        for agent, state in zip(self.agents, ckpt["agents"]):
            agent.actor.load_state_dict(state["actor"])
            agent.critic.load_state_dict(state["critic"])
            agent.target_actor.load_state_dict(state["target_actor"])
            agent.target_critic.load_state_dict(state["target_critic"])
            agent.actor_opt.load_state_dict(state["actor_opt"])
            agent.critic_opt.load_state_dict(state["critic_opt"])
        self.total_updates = ckpt.get("total_updates", 0)
