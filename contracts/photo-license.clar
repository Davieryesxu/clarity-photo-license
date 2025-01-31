;; Photo License Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-invalid-price (err u101))
(define-constant err-already-licensed (err u102))
(define-constant err-not-found (err u103))

;; Data Variables
(define-data-var license-counter uint u0)

;; Maps
(define-map photos
    {photo-id: uint}
    {
        owner: principal,
        price: uint,
        title: (string-ascii 100),
        description: (string-ascii 500),
        timestamp: uint
    }
)

(define-map licenses 
    {photo-id: uint, licensee: principal}
    {
        expiry: uint,
        terms: (string-ascii 200)
    }
)

;; Public Functions
(define-public (register-photo (price uint) (title (string-ascii 100)) (description (string-ascii 500)))
    (let
        (
            (photo-id (+ (var-get license-counter) u1))
        )
        (if (> price u0)
            (begin
                (map-set photos 
                    {photo-id: photo-id}
                    {
                        owner: tx-sender,
                        price: price,
                        title: title,
                        description: description,
                        timestamp: block-height
                    }
                )
                (var-set license-counter photo-id)
                (ok photo-id)
            )
            err-invalid-price
        )
    )
)

(define-public (purchase-license (photo-id uint) (terms (string-ascii 200)) (duration uint))
    (let (
        (photo (unwrap! (map-get? photos {photo-id: photo-id}) err-not-found))
        (expiry (+ block-height duration))
    )
        (if (is-none (map-get? licenses {photo-id: photo-id, licensee: tx-sender}))
            (begin
                (try! (stx-transfer? (get price photo) tx-sender (get owner photo)))
                (map-set licenses 
                    {photo-id: photo-id, licensee: tx-sender}
                    {expiry: expiry, terms: terms}
                )
                (ok true)
            )
            err-already-licensed
        )
    )
)

;; Read only functions
(define-read-only (get-photo-details (photo-id uint))
    (ok (map-get? photos {photo-id: photo-id}))
)

(define-read-only (get-license-details (photo-id uint) (licensee principal))
    (ok (map-get? licenses {photo-id: photo-id, licensee: licensee}))
)

(define-read-only (get-total-photos)
    (ok (var-get license-counter))
)
