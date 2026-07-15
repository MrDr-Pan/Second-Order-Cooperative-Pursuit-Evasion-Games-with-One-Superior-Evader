import torch
import torch.nn as nn
import torch.nn.functional as F


def mlp(input_dim, hidden_dims, output_dim, activation=nn.ReLU, output_activation=None):
    layers = []
    last_dim = input_dim
    for hidden_dim in hidden_dims:
        layers.append(nn.Linear(last_dim, hidden_dim))
        layers.append(activation())
        last_dim = hidden_dim
    layers.append(nn.Linear(last_dim, output_dim))
    if output_activation is not None:
        layers.append(output_activation())
    return nn.Sequential(*layers)


def init_layer(layer, gain=1.0):
    if isinstance(layer, nn.Linear):
        nn.init.orthogonal_(layer.weight, gain)
        nn.init.constant_(layer.bias, 0.0)
    return layer


class DeterministicActor(nn.Module):
    def __init__(self, obs_dim, act_dim, hidden_dims=(256, 256), act_limit=1.0):
        super().__init__()
        self.act_limit = act_limit
        self.net = mlp(obs_dim, hidden_dims, act_dim)
        self.apply(lambda m: init_layer(m, gain=nn.init.calculate_gain("relu")))
        init_layer(self.net[-1], gain=0.01)

    def forward(self, obs):
        return self.act_limit * torch.tanh(self.net(obs))


class GaussianActor(nn.Module):
    def __init__(self, obs_dim, act_dim, hidden_dims=(256, 256), log_std_bounds=(-20, 2)):
        super().__init__()
        self.body = mlp(obs_dim, hidden_dims, hidden_dims[-1])
        self.mu = nn.Linear(hidden_dims[-1], act_dim)
        self.log_std = nn.Linear(hidden_dims[-1], act_dim)
        self.log_std_bounds = log_std_bounds
        self.apply(lambda m: init_layer(m, gain=nn.init.calculate_gain("relu")))
        init_layer(self.mu, gain=0.01)
        init_layer(self.log_std, gain=0.01)

    def forward(self, obs):
        x = self.body(obs)
        mu = self.mu(x)
        log_std = self.log_std(x)
        log_std = torch.clamp(log_std, self.log_std_bounds[0], self.log_std_bounds[1])
        return mu, log_std

    def sample(self, obs):
        mu, log_std = self(obs)
        std = log_std.exp()
        dist = torch.distributions.Normal(mu, std)
        raw_action = dist.rsample()
        action = torch.tanh(raw_action)
        log_prob = dist.log_prob(raw_action) - torch.log(1 - action.pow(2) + 1e-6)
        return action, log_prob.sum(dim=-1, keepdim=True), torch.tanh(mu)


class CategoricalActor(nn.Module):
    def __init__(self, obs_dim, act_dim, hidden_dims=(256, 256)):
        super().__init__()
        self.net = mlp(obs_dim, hidden_dims, act_dim)
        self.apply(lambda m: init_layer(m, gain=nn.init.calculate_gain("relu")))
        init_layer(self.net[-1], gain=0.01)

    def forward(self, obs):
        logits = self.net(obs)
        return torch.distributions.Categorical(logits=logits)


class Critic(nn.Module):
    def __init__(self, input_dim, hidden_dims=(256, 256)):
        super().__init__()
        self.net = mlp(input_dim, hidden_dims, 1)
        self.apply(lambda m: init_layer(m, gain=nn.init.calculate_gain("relu")))
        init_layer(self.net[-1], gain=1.0)

    def forward(self, x):
        return self.net(x)


class AttentionCritic(nn.Module):
    def __init__(self, obs_dim, act_dim, n_agents, hidden_dim=128):
        super().__init__()
        self.n_agents = n_agents
        self.embed = nn.Linear(obs_dim + act_dim, hidden_dim)
        self.query = nn.Linear(hidden_dim, hidden_dim)
        self.key = nn.Linear(hidden_dim, hidden_dim)
        self.value = nn.Linear(hidden_dim, hidden_dim)
        self.out = mlp(hidden_dim * 2, (hidden_dim, hidden_dim), 1)
        self.apply(lambda m: init_layer(m, gain=nn.init.calculate_gain("relu")))

    def forward(self, obs, acts, agent_id):
        # obs: [batch, n_agents, obs_dim]
        x = torch.cat([obs, acts], dim=-1)
        h = F.relu(self.embed(x))
        q = self.query(h[:, agent_id:agent_id + 1])
        k = self.key(h)
        v = self.value(h)
        score = torch.matmul(q, k.transpose(-1, -2)) / (k.shape[-1] ** 0.5)
        mask = torch.ones(score.shape[-1], device=score.device, dtype=torch.bool)
        mask[agent_id] = False
        score = score.masked_fill(~mask.view(1, 1, -1), -1e9)
        weight = torch.softmax(score, dim=-1)
        context = torch.matmul(weight, v).squeeze(1)
        own = h[:, agent_id]
        return self.out(torch.cat([own, context], dim=-1))


class TwinCritic(nn.Module):
    def __init__(self, input_dim, hidden_dims=(256, 256)):
        super().__init__()
        self.q1 = Critic(input_dim, hidden_dims)
        self.q2 = Critic(input_dim, hidden_dims)

    def forward(self, x):
        return self.q1(x), self.q2(x)

    def q1_value(self, x):
        return self.q1(x)


def soft_update(target, source, tau):
    with torch.no_grad():
        for target_param, source_param in zip(target.parameters(), source.parameters()):
            target_param.data.mul_(1.0 - tau)
            target_param.data.add_(tau * source_param.data)
