;; ----------------------------------------------------------------------------------
;; Contract: token-faucet.clar
;; Description: A simple STX token faucet with per-user cooldowns and limited distribution.
;; ----------------------------------------------------------------------------------

;; Constants
(define-constant CLAIM_AMOUNT u1000000) ;; Amount of micro-STX per claim (1 STX = 1,000,000 micro-STX)
(define-constant COOLDOWN_BLOCKS u1440) ;; Cooldown period in blocks (~1 day assuming 1 block per minute)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-COOLDOWN-ACTIVE (err u101))
(define-constant ERR-INSUFFICIENT_FUNDS (err u102))

;; Data variables
(define-data-var contract-owner principal tx-sender)
(define-data-var faucet-balance uint u0) ;; Balance of STX in faucet

;; Maps
;; Records last block height when a user claimed
(define-map last-claim
  principal
  uint
)

;; Records total claimed amount per user
(define-map total-claimed
  principal
  uint
)

;; ---------------------------------------------
;; Public: Owner can deposit STX to faucet
;; ---------------------------------------------
(define-public (deposit-faucet (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    ;; Transfer STX from sender to this contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    ;; Update faucet balance
    (var-set faucet-balance (+ (var-get faucet-balance) amount))
    (print { action: "deposit-faucet", from: tx-sender, amount: amount })
    (ok true)
  )
)

;; ---------------------------------------------
;; Public: User claims tokens from faucet
;; ---------------------------------------------
(define-public (claim)
  (let (
        (last-block (default-to u0 (map-get? last-claim tx-sender)))
        (current-block stacks-block-height)
        (time-elapsed (- current-block last-block))
        (balance (var-get faucet-balance))
       )
    ;; Check cooldown
    (asserts! (>= time-elapsed COOLDOWN_BLOCKS) ERR-COOLDOWN-ACTIVE)

    ;; Check faucet balance sufficient
    (asserts! (>= balance CLAIM_AMOUNT) ERR-INSUFFICIENT_FUNDS)

    ;; Transfer STX to caller
    (try! (stx-transfer? CLAIM_AMOUNT (as-contract tx-sender) tx-sender))

    ;; Update faucet balance
    (var-set faucet-balance (- balance CLAIM_AMOUNT))

    ;; Update claim info
    (map-set last-claim tx-sender current-block)
    (let ((prev-total (default-to u0 (map-get? total-claimed tx-sender))))
      (map-set total-claimed tx-sender (+ prev-total CLAIM_AMOUNT))
    )

    (print { action: "claim", claimant: tx-sender, amount: CLAIM_AMOUNT, block: current-block })
    (ok true)
  )
)

;; ---------------------------------------------
;; Read-only: Get last claim block of user
;; ---------------------------------------------
(define-read-only (get-last-claim (user principal))
  (ok (default-to u0 (map-get? last-claim user)))
)

;; ---------------------------------------------
;; Read-only: Get total claimed by user
;; ---------------------------------------------
(define-read-only (get-total-claimed (user principal))
  (ok (default-to u0 (map-get? total-claimed user)))
)

;; ---------------------------------------------
;; Read-only: Get faucet balance
;; ---------------------------------------------
(define-read-only (get-faucet-balance)
  (ok (var-get faucet-balance))
)
