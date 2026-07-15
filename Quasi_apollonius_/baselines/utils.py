from dataclasses import asdict, dataclass
from pathlib import Path

import numpy as np
import torch


@dataclass
class OptimConfig:
    gamma: float = 0.99
    tau: float = 0.005
    actor_lr: float = 1e-4
    critic_lr: float = 1e-3
    grad_clip: float | None = 0.5


@dataclass
class PPOConfig:
    gamma: float = 0.99
    gae_lambda: float = 0.95
    clip_ratio: float = 0.2
    entropy_coef: float = 0.01
    value_coef: float = 0.5
    lr: float = 3e-4
    grad_clip: float | None = 0.5


class RunningMeanStd:
    def __init__(self, shape, eps=1e-4):
        self.mean = np.zeros(shape, dtype=np.float64)
        self.var = np.ones(shape, dtype=np.float64)
        self.count = eps

    def update(self, x):
        x = np.asarray(x, dtype=np.float64)
        batch_mean = x.mean(axis=0)
        batch_var = x.var(axis=0)
        batch_count = x.shape[0]
        self._update_from_moments(batch_mean, batch_var, batch_count)

    def normalize(self, x, clip=10.0):
        x = (x - self.mean) / np.sqrt(self.var + 1e-8)
        return np.clip(x, -clip, clip)

    def _update_from_moments(self, batch_mean, batch_var, batch_count):
        delta = batch_mean - self.mean
        total_count = self.count + batch_count
        new_mean = self.mean + delta * batch_count / total_count
        m_a = self.var * self.count
        m_b = batch_var * batch_count
        m_2 = m_a + m_b + np.square(delta) * self.count * batch_count / total_count
        self.mean = new_mean
        self.var = m_2 / total_count
        self.count = total_count


class OUNoise:
    def __init__(self, act_dim, mu=0.0, theta=0.15, sigma=0.2):
        self.act_dim = act_dim
        self.mu = mu
        self.theta = theta
        self.sigma = sigma
        self.state = np.ones(act_dim, dtype=np.float32) * mu

    def reset(self):
        self.state = np.ones(self.act_dim, dtype=np.float32) * self.mu

    def sample(self):
        dx = self.theta * (self.mu - self.state) + self.sigma * np.random.randn(self.act_dim)
        self.state = self.state + dx
        return self.state.astype(np.float32)


class LinearSchedule:
    def __init__(self, start, end, duration):
        self.start = start
        self.end = end
        self.duration = max(1, duration)

    def value(self, step):
        frac = min(max(step / self.duration, 0.0), 1.0)
        return self.start + frac * (self.end - self.start)


def to_tensor(x, device):
    return torch.as_tensor(x, dtype=torch.float32, device=device)


def save_checkpoint(path, **objects):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    torch.save(objects, path)


def load_checkpoint(path, device="cpu"):
    return torch.load(path, map_location=device)


def dataclass_to_dict(config):
    return asdict(config)

