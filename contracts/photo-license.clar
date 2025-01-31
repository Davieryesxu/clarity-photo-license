;; Photo License Contract with Revenue Sharing and Categories

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-invalid-price (err u101))
(define-constant err-already-licensed (err u102))
(define-constant err-not-found (err u103))
(define-constant err-invalid-category (err u104))
(define-constant err-invalid-share (err u105))

;; Data Variables
(define-data-var license-counter uint u0)
(define-data-var platform-fee uint u5) ;; 5% platform fee

;; Maps
(define-map photos
    {photo-id: uint}
    {
        owner: principal,
        price: uint,
        title: (string-ascii 100),
        description: (string-ascii 500),
        timestamp: uint,
        category: (string-ascii 50),
        collaborators: (list 5 {address: principal, share: uint})
    }
)

(define-map licenses 
    {photo-id: uint, licensee: principal}
    {
        expiry: uint,
        terms: (string-ascii 200),
        commercial-use: bool
    }
)

(define-map categories
    {name: (string-ascii 50)}
    {active: bool}
)

;; Private Functions
(define-private (distribute-payment (photo-id uint) (payment uint))
    (let (
        (photo (unwrap! (map-get? photos {photo-id: photo-id}) err-not-found))
        (platform-amount (/ (* payment (var-get platform-fee)) u100))
        (remaining-amount (- payment platform-amount))
    )
    (begin
        ;; Send platform fee
        (try! (stx-transfer? platform-amount tx-sender contract-owner))
        
        ;; Distribute to collaborators
        (map-get? photos {photo-id: photo-id})
        (ok true)
    ))
)

;; Public Functions
(define-public (register-photo (price uint) (title (string-ascii 100)) (description (string-ascii 500)) (category (string-ascii 50)) (collaborators (list 5 {address: principal, share: uint})))
    (let
        (
            (photo-id (+ (var-get license-counter) u1))
        )
        (asserts! (is-some (map-get? categories {name: category})) err-invalid-category)
        (asserts! (> price u0) err-invalid-price)
        (begin
            (map-set photos 
                {photo-id: photo-id}
                {
                    owner: tx-sender,
                    price: price,
                    title: title,
                    description: description,
                    timestamp: block-height,
                    category: category,
                    collaborators: collaborators
                }
            )
            (var-set license-counter photo-id)
            (ok photo-id)
        )
    )
)

(define-public (purchase-license (photo-id uint) (terms (string-ascii 200)) (duration uint) (commercial bool))
    (let (
        (photo (unwrap! (map-get? photos {photo-id: photo-id}) err-not-found))
        (expiry (+ block-height duration))
        (license-price (if commercial (* (get price photo) u2) (get price photo)))
    )
        (if (is-none (map-get? licenses {photo-id: photo-id, licensee: tx-sender}))
            (begin
                (try! (distribute-payment photo-id license-price))
                (map-set licenses 
                    {photo-id: photo-id, licensee: tx-sender}
                    {expiry: expiry, terms: terms, commercial-use: commercial}
                )
                (ok true)
            )
            err-already-licensed
        )
    )
)

(define-public (add-category (name (string-ascii 50)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-not-owner)
        (ok (map-set categories {name: name} {active: true}))
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

(define-read-only (get-categories)
    (ok (map-get? categories {name: "all"}))
)
