# Second-Order Cooperative Pursuit-Evasion Games with One Superior Evader

Official implementation of **“Second-Order Cooperative Pursuit-Evasion Games with One Superior Evader”**.

## Overview

This repository contains the code for a cooperative pursuit-evasion framework under **second-order dynamics**, where multiple pursuers attempt to encircle and capture **one superior evader** with stronger maneuverability.

Unlike most existing pursuit-evasion studies that rely on **first-order models** and the classical **Apollonius Circle**, this work addresses the more challenging and realistic setting of **unbounded second-order systems**, in which velocity is not bounded and the standard geometric framework is no longer directly applicable. To tackle this problem, the paper proposes a new geometric formulation called the **Quasi-Apollonius Circle (QAC)**, together with a learning-based cooperative encirclement algorithm based on **multi-agent deep reinforcement learning (MADRL)** and a **Transformer-based prediction network**. 

## Motivation

In classical encirclement problems, capture feasibility is often analyzed using the Apollonius Circle and the corresponding occupied angle. However, that framework is mainly suitable for **first-order systems**. In second-order systems without velocity bounds, maximum speed is undefined, which makes the classical Apollonius-circle-based analysis no longer valid.

This paper focuses on two fundamental questions:

1. How to characterize whether encirclement is feasible when the Apollonius Circle is not applicable.
2. How multiple pursuers should coordinate to maintain encirclement integrity and eventually capture a superior evader. 

## Main Idea

The proposed framework combines **geometry-driven analysis** and **learning-based control**:

- A new geometric object, the **Quasi-Apollonius Circle (QAC)**, is introduced to characterize the dynamic interaction region between a pursuer and a superior evader under second-order dynamics.
- Based on QAC, the paper defines a generalized **occupied angle** as a criterion for evaluating whether the evader is fully enclosed.
- Since the QAC can have highly complex shapes, the occupied angle is computed indirectly through **polynomial root analysis** and **multi-start optimization**, without explicitly solving the QAC shape.
- To generate practical cooperative strategies, the paper further develops a **MADRL framework** under centralized training and decentralized execution.
- A **decoder-only Transformer prediction network** is incorporated to predict the evader’s future motion from historical states, helping pursuers make more proactive decisions. 

## Contributions

The main contributions of this work are:

1. **A geometric formulation for second-order pursuit-evasion games**  
   The paper introduces the Quasi-Apollonius Circle (QAC), which extends geometric encirclement analysis to second-order systems without velocity constraints.

2. **An occupied-angle computation algorithm**  
   An algorithm based on polynomial repeated-root conditions and multi-start optimization is proposed to compute the occupied angle without explicitly deriving the QAC boundary.

3. **A predictive multi-agent reinforcement learning framework**  
   A MADRL-based encirclement strategy is developed, enhanced with a decoder-only Transformer predictor that estimates the evader’s future trajectory and improves cooperative pursuit performance. 

## Method

### 1. Second-order pursuit-evasion model

Both pursuers and evader are modeled as **double-integrator systems**, where the states include position and velocity, and the control input is directional acceleration. The setting assumes:

- multiple pursuers and one evader,
- identical acceleration magnitudes for all pursuers,
- the evader has a larger acceleration magnitude,
- the evader is initially inside the encirclement formed by the pursuers,
- pursuers do not know the exact evasion strategy in advance, but can estimate it from historical information. 

### 2. Quasi-Apollonius Circle (QAC)

For second-order dynamics, the reachable positions of both agents at a given future time form circles in space, and the set of all possible intersection points over time defines the **QAC**. Unlike the classical Apollonius Circle, the QAC may be highly nontrivial: depending on the relative initial velocity and direction, it can deform, split into multiple closed components, and change topology.

This makes QAC a more suitable geometric object for analyzing pursuit-evasion interactions in second-order systems. 

### 3. Occupied angle criterion

The occupied angle is generalized from first-order encirclement theory to the second-order case. Instead of directly computing tangent lines from an explicit QAC equation, the paper derives a quartic polynomial in time and uses the repeated-root condition to identify tangency directions. These directions determine the occupied-angle range of each pursuer.

Encirclement is considered feasible when the occupied angles induced by all pursuers jointly cover the full angular domain around the evader without gaps. 

### 4. MADRL with Transformer prediction

To learn cooperative capture policies, the paper formulates the task as a **Decentralized Partially Observable Markov Decision Process (DPO-MDP)** and adopts a **Centralized Training with Decentralized Execution (CTDE)** framework.

A decoder-only Transformer prediction network is used to model the evader’s future trajectory from historical state sequences. By incorporating predicted future information into decision-making, pursuers can act more proactively and improve encirclement and capture performance in highly dynamic scenarios.



## Citation

If you find this repository useful, please cite the corresponding paper:

@article{li2025second,
  title={Second-Order Cooperative Pursuit-Evasion Games with One Superior Evader},
  author={Li, Dongyu and Pan, Biyue and Hu, Qinglei and Liu, Hanyu and Ge, Shuzhi Sam},
  journal={Authorea Preprints},
  year={2025},
  publisher={Authorea}
}
