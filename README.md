A simple, rate-limited STX faucet built with Clarity. This contract allows users to claim a small amount of STX at fixed intervals (per-user cooldown) and enables the contract owner to deposit tokens for distribution.

---

## 📜 Contract Overview

| Item | Details |
|------|---------|
| **Contract Name** | `token-faucet.clar` |
| **Language** | Clarity |
| **Purpose** | Distribute STX to users with daily limits |
| **Network** | Stacks Blockchain |

---

## ⚙️ Features

- ✅ **Fixed Claim Amount**: Each user can claim a fixed amount (1 STX).
- ⏳ **Cooldown Period**: 1 claim per user per day (`1440` block cooldown).
- 🔒 **Owner-Only Deposit**: Only the contract owner can fund the faucet.
- 📈 **Claim Tracking**: Keeps track of last claim and total amount claimed per user.
- 🔍 **Public Read Access**: Check faucet balance, user claim history, and total claimed.

---

## 🧠 Constants

| Name | Value | Description |
|------|-------|-------------|
| `CLAIM_AMOUNT` | `u1000000` | Amount of STX (in micro-STX) per claim — 1 STX |
| `COOLDOWN_BLOCKS` | `u1440` | ~1 day cooldown (assuming 1 block/min) |

---

## ⚠️ Error Codes

| Code | Error | Description |
|------|-------|-------------|
| `err u100` | `ERR-NOT-AUTHORIZED` | Only the contract owner can deposit STX |
| `err u101` | `ERR-COOLDOWN-ACTIVE` | User must wait before next claim |
| `err u102` | `ERR-INSUFFICIENT_FUNDS` | Faucet does not have enough STX |

---

## 🔐 Access Control

- `contract-owner`: Set at deployment (`tx-sender`)
- Only the owner can call `deposit-faucet`

---

## 📦 Public Functions

### 🪙 `deposit-faucet(amount)`

- **Access**: Contract owner only
- **Description**: Deposits STX into the faucet for users to claim

### 💸 `claim()`

- **Access**: Public
- **Description**: Transfers `1 STX` to caller if cooldown is satisfied and faucet has funds

---

## 📖 Read-Only Functions

| Function | Description |
|---------|-------------|
| `get-last-claim(user)` | Returns the last block height when the user claimed STX |
| `get-total-claimed(user)` | Returns the total STX (in micro-STX) claimed by the user |
| `get-faucet-balance()` | Returns current STX balance of the faucet |

---

## 🛠 Example Usage

### Owner Deposits STX into Faucet

(deposit-faucet u10000000) ;; Deposit 10 STX
User Claims STX
(claim) ;; Will succeed if cooldown has passed
Get User’s Claim History
(get-last-claim 'SP123...)
(get-total-claimed 'SP123...)
Check Faucet Balance
(get-faucet-balance)
🧪 Suggested Improvements (TODO)
 Add configurable claim amount and cooldown via constructor

 Add contract pause/resume functionality

 Add test cases using Clarinet

 Frontend for claim UI (wallet integration)
