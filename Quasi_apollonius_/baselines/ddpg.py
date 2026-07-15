import copy

import torch
import torch.nn.functional as F

from .networks import Critic, DeterministicActor, soft_update
from .utils import load_checkpoint, save_checkpoint


class DDPGAgent:
    def __init__(
        self,
        obs_dim,
        act_dim,
        act_limit=1.0,
        gamma=0.99,
        tau=0.005,
        actor_lr=1e-4,
        critic_lr=1e-3,
        device="cpu",
    ):
        self.device = torch.device(device)
        self.gamma = gamma
        self.tau = tau

        self.actor = DeterministicActor(obs_dim, act_dim, act_limit=act_limit).to(self.device)
        self.critic = Critic(obs_dim + act_dim).to(self.device)
        self.target_actor = copy.deepcopy(self.actor).to(self.device)
        self.target_critic = copy.deepcopy(self.critic).to(self.device)

        self.actor_opt = torch.optim.Adam(self.actor.parameters(), lr=actor_lr)
        self.critic_opt = torch.optim.Adam(self.critic.parameters(), lr=critic_lr)
        self.total_updates = 0

    @torch.no_grad()
    def act(self, obs, noise_std=0.0):
        obs = torch.as_tensor(obs, dtype=torch.float32, device=self.device).unsqueeze(0)
        action = self.actor(obs).squeeze(0)
        if noise_std > 0:
            action = action + noise_std * torch.randn_like(action)
        return torch.clamp(action, -1.0, 1.0).cpu().numpy()

    def update(self, batch, grad_clip=0.5):
        obs = batch["obs"].float()
        acts = batch["acts"].float()
        rews = batch["rews"].float()
        next_obs = batch["next_obs"].float()
        done = batch["done"].float()

        with torch.no_grad():
            next_acts = self.target_actor(next_obs)
            next_q = self.target_critic(torch.cat([next_obs, next_acts], dim=-1))
            target_q = rews + self.gamma * (1.0 - done) * next_q

        q = self.critic(torch.cat([obs, acts], dim=-1))
        critic_loss = F.mse_loss(q, target_q)

        self.critic_opt.zero_grad()
        critic_loss.backward()
        if grad_clip is not None:
            torch.nn.utils.clip_grad_norm_(self.critic.parameters(), grad_clip)
        self.critic_opt.step()

        policy_acts = self.actor(obs)
        actor_loss = -self.critic(torch.cat([obs, policy_acts], dim=-1)).mean()

        self.actor_opt.zero_grad()
        actor_loss.backward()
        if grad_clip is not None:
            torch.nn.utils.clip_grad_norm_(self.actor.parameters(), grad_clip)
        self.actor_opt.step()

        soft_update(self.target_actor, self.actor, self.tau)
        soft_update(self.target_critic, self.critic, self.tau)

        self.total_updates += 1
        return {"critic_loss": critic_loss.item(), "actor_loss": actor_loss.item(), "updates": self.total_updates}

    def save(self, path):
        save_checkpoint(
            path,
            actor=self.actor.state_dict(),
            critic=self.critic.state_dict(),
            target_actor=self.target_actor.state_dict(),
            target_critic=self.target_critic.state_dict(),
            actor_opt=self.actor_opt.state_dict(),
            critic_opt=self.critic_opt.state_dict(),
            total_updates=self.total_updates,
        )

    def load(self, path):
        ckpt = load_checkpoint(path, self.device)
        self.actor.load_state_dict(ckpt["actor"])
        self.critic.load_state_dict(ckpt["critic"])
        self.target_actor.load_state_dict(ckpt["target_actor"])
        self.target_critic.load_state_dict(ckpt["target_critic"])
        self.actor_opt.load_state_dict(ckpt["actor_opt"])
        self.critic_opt.load_state_dict(ckpt["critic_opt"])
        self.total_updates = ckpt.get("total_updates", 0)
