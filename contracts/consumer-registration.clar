;; Consumer Registration Contract
;; Records energy users and their consumption profiles

(define-data-var admin principal tx-sender)

;; Map to store registered consumers
(define-map consumers principal
  {
    name: (string-utf8 100),
    location: (string-utf8 100),
    max-capacity: uint,
    registration-date: uint,
    active: bool
  }
)

;; Register a new consumer
(define-public (register-consumer (name (string-utf8 100)) (location (string-utf8 100)) (max-capacity uint))
  (ok (map-set consumers tx-sender
    {
      name: name,
      location: location,
      max-capacity: max-capacity,
      registration-date: block-height,
      active: true
    }
  ))
)

;; Update consumer profile
(define-public (update-consumer (name (string-utf8 100)) (location (string-utf8 100)) (max-capacity uint))
  (let ((consumer (unwrap! (map-get? consumers tx-sender) (err u1))))
    (ok (map-set consumers tx-sender
      (merge consumer {
        name: name,
        location: location,
        max-capacity: max-capacity
      })
    ))
  )
)

;; Deactivate consumer
(define-public (deactivate-consumer)
  (let ((consumer (unwrap! (map-get? consumers tx-sender) (err u1))))
    (ok (map-set consumers tx-sender
      (merge consumer {
        active: false
      })
    ))
  )
)

;; Reactivate consumer
(define-public (reactivate-consumer)
  (let ((consumer (unwrap! (map-get? consumers tx-sender) (err u1))))
    (ok (map-set consumers tx-sender
      (merge consumer {
        active: true
      })
    ))
  )
)

;; Check if a consumer is active
(define-read-only (is-active-consumer (consumer-principal principal))
  (default-to false (get active (map-get? consumers consumer-principal)))
)

;; Get consumer details
(define-read-only (get-consumer-details (consumer-principal principal))
  (map-get? consumers consumer-principal)
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (var-set admin new-admin))
  )
)
