# Git Workflow Strategy: Managing Multiple Feature Branches

This document outlines a strategy for managing concurrent development of multiple features (e.g., "10 branches") and merging them into `main` efficiently and safely.

## The Goal

To have multiple work streams (branches) active simultaneously and merge them into the production branch (`main`) with minimal conflicts and "hussle".

## The Strategy: Feature Branch Workflow

We will use a standard **Feature Branch Workflow** with a focus on **Rebasing** to keep history clean and linear.

### 1. Naming Convention

Give your branches descriptive names or use a consistent prefix/suffix if they are related to a specific sprint or user.

*   `feat/dashboard-providers`
*   `feat/student-repository`
*   `fix/login-bug`
*   `reco-branch` (Personal/Review branch)

### 2. Workflow for a Single Feature

1.  **Start from `main`**: Always branch off the latest `main`.
    ```bash
    git checkout main
    git pull origin main
    git checkout -b feat/my-new-feature
    ```

2.  **Work and Commit**: Make small, logical commits.

3.  **Stay Updated (Rebase)**: If `main` changes while you are working, **rebase** your branch on top of `main` instead of merging `main` into your branch. This keeps your changes "on top" and avoids "merge bubbles".
    ```bash
    git fetch origin
    git rebase origin/main
    ```
    *   *Resolve conflicts if they arise during rebase.*

### 3. Merging to `main`

When a feature is ready:

1.  **Final Rebase**: Ensure you are up to date.
    ```bash
    git checkout feat/my-new-feature
    git pull --rebase origin main
    ```

2.  **Squash and Merge (Recommended for GitHub/GitLab UI)**:
    When using a Pull Request (PR), use "Squash and Merge". This combines all your work-in-progress commits into one clean commit on `main`.

    **OR**

    **CLI Merge**:
    ```bash
    git checkout main
    git pull origin main
    git merge --no-ff feat/my-new-feature
    git push origin main
    ```

## Handling "10 Branches" at Once

If you have 10 separate branches pending:

1.  **Identify Dependencies**: Do any branches depend on others?
    *   *Independent*: Can be merged in any order.
    *   *Dependent*: Merge the base branch first.

2.  **Sequential Merge Strategy**:
    Merge one branch at a time, update your local `main`, then rebase the remaining branches.

    *   **Step 1**: Merge Branch A into `main`.
    *   **Step 2**: Check out Branch B.
    *   **Step 3**: `git pull --rebase origin main` (Branch B now includes Branch A's changes).
    *   **Step 4**: Test Branch B.
    *   **Step 5**: Merge Branch B.
    *   Repeat.

    *Why rebase?* It highlights conflicts immediately in Branch B's context, forcing you to resolve them before the merge, ensuring `main` stays broken-free.

## Summary Checklist

1.  [ ] **Branch** from updated `main`.
2.  [ ] **Work** on your feature.
3.  [ ] **Rebase** often if `main` is moving fast (`git pull --rebase origin main`).
4.  [ ] **Verify** tests pass after rebase.
5.  [ ] **Merge** to `main` (Squash or No-FF).
6.  [ ] **Delete** the old feature branch.

## Quick Command Reference

```bash
# Start new work
git checkout main
git pull
git checkout -b feat/amazing-feature

# Update your branch with latest main changes
git checkout feat/amazing-feature
git pull --rebase origin main

# Finish work
git push origin feat/amazing-feature
# (Open PR and merge via UI)
```
