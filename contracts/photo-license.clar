;; Photo License Contract with Revenue Sharing and Categories

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-invalid-price (err u101))
(define-constant err-already-licensed (err u102))
(define-constant err-not-found (err u103))
(define-constant err-invalid-category (err u104))
(define-constant err-invalid-share (err u105))
(define-constant err-duplicate-collaborator (err u106))
(define-constant err-license-expired (err u107))

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

;; Events
(define-data-var last-event-id uint u0)

(define-map events
    {id: uint}
    {
        event-type: (string-ascii 20),
        photo-id: uint,
        user: principal,
        timestamp: uint
    }
)

;; Private Functions
(define-private (log-event (event-type (string-ascii 20)) (photo-id uint))
    (let ((event-id (+ (var-get last-event-id) u1)))
        (begin
            (map-set events 
                {id: event-id}
                {
                    event-type: event-type,
                    photo-id: photo-id,
                    user: tx-sender,
                    timestamp: block-height
                }
            )
            (var-set last-event-id event-id)
            (ok event-id)
        )
    )
)

(define-private (check-duplicate-collaborators (collaborators (list 5 {address: principal, share: uint})))
    (let ((addresses (map get-address collaborators)))
        (is-eq (len addresses) (len (get-unique-items addresses)))
    )
)

(define-private (get-address (collaborator {address: principal, share: uint}))
    (get address collaborator)
)

(define-private (get-unique-items (items (list 5 principal)))
    (fold remove-duplicates items (list))
)

(define-private (remove-duplicates (item principal) (acc (list 5 principal)))
    (if (is-some (index-of acc item))
        acc
        (append acc item)
    )
)

;; [Previous private functions remain unchanged]

;; Public Functions
(define-public (set-platform-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-not-owner)
        (asserts! (<= new-fee u100) err-invalid-share)
        (ok (var-set platform-fee new-fee))
    )
)

(define-public (renew-license (photo-id uint) (duration uint))
    (let (
        (license (unwrap! (map-get? licenses {photo-id: photo-id, licensee: tx-sender}) err-not-found))
        (photo (unwrap! (map-get? photos {photo-id: photo-id}) err-not-found))
        (license-price (if (get commercial-use license) (* (get price photo) u2) (get price photo)))
    )
        (begin
            (try! (distribute-payment photo-id license-price))
            (map-set licenses
                {photo-id: photo-id, licensee: tx-sender}
                {
                    expiry: (+ block-height duration),
                    terms: (get terms license),
                    commercial-use: (get commercial-use license)
                }
            )
            (try! (log-event "license_renewed" photo-id))
            (ok true)
        )
    )
)

;; [Previous public functions with added event logging]

;; Read only functions
(define-read-only (get-categories)
    (ok (map-to-list categories))
)

(define-read-only (is-license-valid (photo-id uint) (licensee principal))
    (match (map-get? licenses {photo-id: photo-id, licensee: licensee})
        license (ok (> (get expiry license) block-height))
        (ok false)
    )
)

;; [Previous read-only functions remain unchanged]
