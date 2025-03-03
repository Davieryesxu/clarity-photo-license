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
(define-constant err-invalid-duration (err u108))

;; [Previous constants and data variables remain unchanged]

;; Added validation for minimum and maximum duration
(define-constant min-license-duration u1)
(define-constant max-license-duration u52560) ;; Max 1 year in blocks (assuming 10-minute blocks)

;; [Previous maps and events remain unchanged]

(define-private (validate-license-duration (duration uint))
    (and 
        (>= duration min-license-duration)
        (<= duration max-license-duration)
    )
)

(define-private (is-license-expired (license {expiry: uint, terms: (string-ascii 200), commercial-use: bool}))
    (<= (get expiry license) block-height)
)

;; Enhanced log-event function with additional details
(define-private (log-event-with-details 
    (event-type (string-ascii 20)) 
    (photo-id uint)
    (duration (optional uint))
  )
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

;; Updated renew-license function with enhanced validation and logic
(define-public (renew-license (photo-id uint) (duration uint))
    (let (
        (license (unwrap! (map-get? licenses {photo-id: photo-id, licensee: tx-sender}) err-not-found))
        (photo (unwrap! (map-get? photos {photo-id: photo-id}) err-not-found))
        (license-price (if (get commercial-use license) (* (get price photo) u2) (get price photo)))
    )
        (begin
            (asserts! (validate-license-duration duration) err-invalid-duration)
            ;; Allow renewal only if license is active or recently expired (within 100 blocks)
            (asserts! (or 
                (not (is-license-expired license))
                (<= (- block-height (get expiry license)) u100)
            ) err-license-expired)
            (try! (distribute-payment photo-id license-price))
            (map-set licenses
                {photo-id: photo-id, licensee: tx-sender}
                {
                    expiry: (+ block-height duration),
                    terms: (get terms license),
                    commercial-use: (get commercial-use license)
                }
            )
            (try! (log-event-with-details "license_renewed" photo-id (some duration)))
            (ok true)
        )
    )
)

;; [Rest of the contract remains unchanged]
