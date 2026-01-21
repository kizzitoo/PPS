;; Zero-Knowledge Commitments Contract
;; Privacy-preserving value commitments with nullifier tracking

(define-constant ERR-ALREADY-EXISTS (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-INVALID-REVEAL (err u102))
(define-constant ERR-ALREADY-NULLIFIED (err u103))
(define-constant ERR-NOT-AUTHORIZED (err u104))

(define-map commitments
  { commitment-id: uint }
  {
    owner: principal,
    commitment-hash: (buff 32),
    block-height: uint,
    revealed: bool,
    nullified: bool
  }
)

(define-map nullifiers (buff 32) bool)

(define-data-var next-commitment-id uint u0)
(define-data-var total-commitments uint u0)

(define-read-only (get-commitment (commitment-id uint))
  (map-get? commitments { commitment-id: commitment-id })
)

(define-read-only (is-nullified (nullifier-hash (buff 32)))
  (default-to false (map-get? nullifiers nullifier-hash))
)

(define-read-only (get-total-commitments)
  (ok (var-get total-commitments))
)

(define-public (create-commitment (commitment-hash (buff 32)))
  (let
    (
      (commitment-id (var-get next-commitment-id))
    )
    (map-set commitments
      { commitment-id: commitment-id }
      {
        owner: tx-sender,
        commitment-hash: commitment-hash,
        block-height: stacks-block-height,
        revealed: false,
        nullified: false
      }
    )
    
    (var-set next-commitment-id (+ commitment-id u1))
    (var-set total-commitments (+ (var-get total-commitments) u1))
    (ok commitment-id)
  )
)

(define-public (reveal-commitment
  (commitment-id uint)
  (value uint)
  (salt (buff 32)))
  (let
    (
      (commitment (unwrap! (get-commitment commitment-id) ERR-NOT-FOUND))
      (computed-hash (sha256 (concat (unwrap-panic (to-consensus-buff? value)) salt)))
    )
    (asserts! (is-eq tx-sender (get owner commitment)) ERR-NOT-AUTHORIZED)
    (asserts! (not (get revealed commitment)) ERR-ALREADY-EXISTS)
    (asserts! (is-eq computed-hash (get commitment-hash commitment)) ERR-INVALID-REVEAL)
    
    (map-set commitments
      { commitment-id: commitment-id }
      (merge commitment { revealed: true })
    )
    
    (ok true)
  )
)

(define-public (nullify-commitment
  (commitment-id uint)
  (nullifier-hash (buff 32)))
  (let
    (
      (commitment (unwrap! (get-commitment commitment-id) ERR-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender (get owner commitment)) ERR-NOT-AUTHORIZED)
    (asserts! (not (get nullified commitment)) ERR-ALREADY-NULLIFIED)
    (asserts! (not (is-nullified nullifier-hash)) ERR-ALREADY-NULLIFIED)
    
    (map-set commitments
      { commitment-id: commitment-id }
      (merge commitment { nullified: true })
    )
    
    (map-set nullifiers nullifier-hash true)
    (ok true)
  )
)

(define-public (verify-commitment
  (commitment-hash (buff 32))
  (value uint)
  (salt (buff 32)))
  (let
    (
      (computed-hash (sha256 (concat (unwrap-panic (to-consensus-buff? value)) salt)))
    )
    (ok (is-eq computed-hash commitment-hash))
  )
)