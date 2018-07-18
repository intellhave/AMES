# Non-smooth M-Estimator for Maximum Consensus Estimation

## Description
Demo program for the paper:

### ["Non-smooth M-Estimator for Maximum Consensus Estimation" (BMVC 2018 - Oral presentation)](https://www.researchgate.net/publication/326258296_Non-smooth_M-estimator_for_Maximum_Consensus_Estimation)

This demo is implemented in MATLAB, and tested on a Ubuntu Machine with
MATLAB R2018a. 

The authors highly appreciate any bug reports or comments on the algorithm,
which can be sent to: huu.le@qut.edu.au


## Usage
Run demo.m to start the demo. Two applications are provided:
* Robust linear fitting
* Robust homography estimation with quasi-convex residuals

## Paper Summary
This paper revisits the application of M-estimators for a spectrum of robust estimation
problems in computer vision, particularly with the maximum consensus criterion. Cur-
rent practice makes use of smooth robust loss functions, e.g. Huber loss, which enables
M-estimators to be tackled by such well-known optimization techniques as Iteratively
Re-weighted Least Square (IRLS). When consensus maximization is used as loss func-
tion for M-estimators, however, the optimization problem becomes non-smooth. Our
paper proposes an approach to resolve this issue. Based on the Alternating Direction
Method of Multiplier (ADMM) technique, we develop a deterministic algorithm that is
provably convergent, which enables the maximum consensus problem to be solved in the
context of M-estimator. We further show that our algorithm outperforms other differen-
tiable robust loss functions that are currently used by many practitioners. Notably, the
proposed method allows the sub-problems to be solved efficiently in parallel, thus entails
it to be implemented in distributed settings









