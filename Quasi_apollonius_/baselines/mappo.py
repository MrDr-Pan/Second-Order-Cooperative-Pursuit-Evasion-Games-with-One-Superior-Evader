import torch
import torch.nn.functional as F

from .networks import CategoricalActor, Critic, GaussianActor
from .utils import load_checkpoint, save_checkpoint


class MAPPOAgent:
    def __init__(
        self,
        obs_dim,
        act_dim,
        state_dim=None,
        continuous=True,
        gamma=0.99,
        gae_lambda=0.95,
        clip_ratio=0.2,
        entropy_coef=0.01,
        value_coef=0.5,
        lr=3e-4,
        device="cpu",
    ):
        self.device = torch.device(device)
        self.gamma = gamma
        self.gae_lambda = gae_lambda
        self.clip_ratio = clip_ratio
        self.entropy_coef = entropy_coef
        self.value_coef = value_coef
        self.continuous = continuous
        self.state_dim = state_dim or obs_dim

        if continuous:
            self.actor = GaussianActor(obs_dim, act_dim).to(self.device)
        else:
            self.actor = CategoricalActor(obs_dim, act_dim).to(self.device)
        self.critic = Critic(self.state_dim).to(self.device)
        self.opt = torch.optim.Adam(list(self.actor.parameters()) + list(self.critic.parameters()), lr=lr)
        self.total_updates = 0

    @torch.no_grad()
    def act(self, obs):
        obs = torch.as_tensor(obs, dtype=torch.float32, device=self.device).unsqueeze(0)
        if self.continuous:
            action, log_prob, _ = self.actor.sample(obs)
            return action.squeeze(0).cpu().numpy(), log_prob.squeeze(0).cpu().numpy()
        dist = self.actor(obs)
        action = dist.sample()
        log_prob = dist.log_prob(action).unsqueeze(-1)
        return action.squeeze(0).cpu().numpy(), log_prob.squeeze(0).cpu().numpy()

    def evaluate_actions(self, obs, actions):
        if self.continuous:
            mu, log_std = self.actor(obs)
            std = log_std.exp()
            dist = torch.distributions.Normal(mu, std)
            raw_actions = torch.atanh(torch.clamp(actions, -0.999, 0.999))
            log_prob = dist.log_prob(raw_actions) - torch.log(1 - actions.pow(2) + 1e-6)
            entropy = dist.entropy().sum(dim=-1, keepdim=True)
            return log_prob.sum(dim=-1, keepdim=True), entropy
        dist = self.actor(obs)
        log_prob = dist.log_prob(actions.long()).unsqueeze(-1)
        entropy = dist.entropy().unsqueeze(-1)
        return log_prob, entropy

    @torch.no_grad()
    def value(self, state):
        state = torch.as_tensor(state, dtype=torch.float32, device=self.device)
        if state.dim() == 1:
            state = state.unsqueeze(0)
        return self.critic(state)

    def compute_gae(self, rewards, values, dones, next_value):
        advantages = torch.zeros_like(rewards)
        gae = torch.zeros_like(next_value)
        values_ext = torch.cat([values, next_value], dim=0)
        for t in reversed(range(rewards.shape[0])):
            delta = rewards[t] + self.gamma * (1.0 - dones[t]) * values_ext[t + 1] - values_ext[t]
            gae = delta + self.gamma * self.gae_lambda * (1.0 - dones[t]) * gae
            advantages[t] = gae
        returns = advantages + values
        return advantages, returns

    def update(self, batch, epochs=10, minibatch_size=256):
        obs = batch["obs"].float()
        states = batch.get("states", obs).float()
        actions = batch["actions"].float()
        old_log_probs = batch["log_probs"].float()
        advantages = batch["advantages"].float()
        returns = batch["returns"].float()

        advantages = (advantages - advantages.mean()) / (advantages.std() + 1e-8)
        n = obs.shape[0]
        metrics = {}

        for _ in range(epochs):
            perm = torch.randperm(n, device=self.device)
            for start in range(0, n, minibatch_size):
                idx = perm[start:start + minibatch_size]
                new_log_probs, entropy = self.evaluate_actions(obs[idx], actions[idx])
                values = self.critic(states[idx])

                ratio = torch.exp(new_log_probs - old_log_probs[idx])
                unclipped = ratio * advantages[idx]
                clipped = torch.clamp(ratio, 1.0 - self.clip_ratio, 1.0 + self.clip_ratio) * advantages[idx]
                policy_loss = -torch.min(unclipped, clipped).mean()
                value_loss = F.mse_loss(values, returns[idx])
                entropy_loss = -entropy.mean()
                loss = policy_loss + self.value_coef * value_loss + self.entropy_coef * entropy_loss

                self.opt.zero_grad()
                loss.backward()
                torch.nn.utils.clip_grad_norm_(list(self.actor.parameters()) + list(self.critic.parameters()), 0.5)
                self.opt.step()
                self.total_updates += 1

                metrics = {
                    "policy_loss": policy_loss.item(),
                    "value_loss": value_loss.item(),
                    "entropy": entropy.mean().item(),
                    "updates": self.total_updates,
                }
        return metrics

    def save(self, path):
        save_checkpoint(
            path,
            actor=self.actor.state_dict(),
            critic=self.critic.state_dict(),
            opt=self.opt.state_dict(),
            total_updates=self.total_updates,
            continuous=self.continuous,
        )

    def load(self, path):
        ckpt = load_checkpoint(path, self.device)
        self.actor.load_state_dict(ckpt["actor"])
        self.critic.load_state_dict(ckpt["critic"])
        self.opt.load_state_dict(ckpt["opt"])
        self.total_updates = ckpt.get("total_updates", 0)
