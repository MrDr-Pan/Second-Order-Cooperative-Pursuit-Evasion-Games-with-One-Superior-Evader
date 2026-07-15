import numpy as np
import torch


class RolloutBuffer:
    def __init__(self, size, obs_dim, act_dim, state_dim=None, device="cpu"):
        self.size = size
        self.obs = np.zeros((size, obs_dim), dtype=np.float32)
        self.states = np.zeros((size, state_dim or obs_dim), dtype=np.float32)
        self.actions = np.zeros((size, act_dim), dtype=np.float32)
        self.rewards = np.zeros((size, 1), dtype=np.float32)
        self.dones = np.zeros((size, 1), dtype=np.float32)
        self.values = np.zeros((size, 1), dtype=np.float32)
        self.log_probs = np.zeros((size, 1), dtype=np.float32)
        self.advantages = np.zeros((size, 1), dtype=np.float32)
        self.returns = np.zeros((size, 1), dtype=np.float32)
        self.ptr = 0
        self.full = False
        self.device = device

    def add(self, obs, state, action, reward, done, value, log_prob):
        self.obs[self.ptr] = obs
        self.states[self.ptr] = state
        self.actions[self.ptr] = action
        self.rewards[self.ptr] = reward
        self.dones[self.ptr] = done
        self.values[self.ptr] = value
        self.log_probs[self.ptr] = log_prob
        self.ptr += 1
        if self.ptr == self.size:
            self.ptr = 0
            self.full = True

    def compute_returns(self, gamma, gae_lambda, next_value):
        last_gae = 0.0
        next_value = float(np.asarray(next_value).reshape(-1)[0])
        n = self.size if self.full else self.ptr
        for t in reversed(range(n)):
            next_non_terminal = 1.0 - self.dones[t]
            next_val = next_value if t == n - 1 else self.values[t + 1]
            delta = self.rewards[t] + gamma * next_val * next_non_terminal - self.values[t]
            last_gae = delta + gamma * gae_lambda * next_non_terminal * last_gae
            self.advantages[t] = last_gae
        self.returns[:n] = self.advantages[:n] + self.values[:n]

    def as_tensors(self):
        n = self.size if self.full else self.ptr
        return {
            "obs": torch.as_tensor(self.obs[:n], device=self.device),
            "states": torch.as_tensor(self.states[:n], device=self.device),
            "actions": torch.as_tensor(self.actions[:n], device=self.device),
            "log_probs": torch.as_tensor(self.log_probs[:n], device=self.device),
            "advantages": torch.as_tensor(self.advantages[:n], device=self.device),
            "returns": torch.as_tensor(self.returns[:n], device=self.device),
        }

    def clear(self):
        self.ptr = 0
        self.full = False

