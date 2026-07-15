import numpy as np
import torch


class ReplayBuffer:
    def __init__(self, obs_dim, act_dim, size, device="cpu"):
        self.obs = np.zeros((size, obs_dim), dtype=np.float32)
        self.next_obs = np.zeros((size, obs_dim), dtype=np.float32)
        self.acts = np.zeros((size, act_dim), dtype=np.float32)
        self.rews = np.zeros((size, 1), dtype=np.float32)
        self.done = np.zeros((size, 1), dtype=np.float32)
        self.size = size
        self.ptr = 0
        self.count = 0
        self.device = device

    def add(self, obs, act, rew, next_obs, done):
        self.obs[self.ptr] = obs
        self.acts[self.ptr] = act
        self.rews[self.ptr] = rew
        self.next_obs[self.ptr] = next_obs
        self.done[self.ptr] = done
        self.ptr = (self.ptr + 1) % self.size
        self.count = min(self.count + 1, self.size)

    def sample(self, batch_size):
        idx = np.random.randint(0, self.count, size=batch_size)
        return {
            "obs": torch.as_tensor(self.obs[idx], device=self.device),
            "acts": torch.as_tensor(self.acts[idx], device=self.device),
            "rews": torch.as_tensor(self.rews[idx], device=self.device),
            "next_obs": torch.as_tensor(self.next_obs[idx], device=self.device),
            "done": torch.as_tensor(self.done[idx], device=self.device),
        }

    def __len__(self):
        return self.count

    def ready(self, batch_size):
        return self.count >= batch_size


class MultiAgentReplayBuffer:
    def __init__(self, n_agents, obs_dim, act_dim, size, device="cpu"):
        self.obs = np.zeros((size, n_agents, obs_dim), dtype=np.float32)
        self.next_obs = np.zeros((size, n_agents, obs_dim), dtype=np.float32)
        self.acts = np.zeros((size, n_agents, act_dim), dtype=np.float32)
        self.rews = np.zeros((size, n_agents, 1), dtype=np.float32)
        self.done = np.zeros((size, n_agents, 1), dtype=np.float32)
        self.size = size
        self.ptr = 0
        self.count = 0
        self.device = device

    def add(self, obs, acts, rews, next_obs, done):
        self.obs[self.ptr] = obs
        self.acts[self.ptr] = acts
        self.rews[self.ptr] = np.asarray(rews).reshape(-1, 1)
        self.next_obs[self.ptr] = next_obs
        self.done[self.ptr] = np.asarray(done).reshape(-1, 1)
        self.ptr = (self.ptr + 1) % self.size
        self.count = min(self.count + 1, self.size)

    def sample(self, batch_size):
        idx = np.random.randint(0, self.count, size=batch_size)
        return {
            "obs": torch.as_tensor(self.obs[idx], device=self.device),
            "acts": torch.as_tensor(self.acts[idx], device=self.device),
            "rews": torch.as_tensor(self.rews[idx], device=self.device),
            "next_obs": torch.as_tensor(self.next_obs[idx], device=self.device),
            "done": torch.as_tensor(self.done[idx], device=self.device),
        }

    def __len__(self):
        return self.count

    def ready(self, batch_size):
        return self.count >= batch_size
