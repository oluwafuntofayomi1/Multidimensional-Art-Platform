;; Multidimensional Artwork Management Contract

(define-data-var artwork-counter uint u0)

(define-map multidimensional-artworks uint {
  artist: principal,
  title: (string-ascii 100),
  description: (string-utf8 500),
  dimensions: (list 10 (string-ascii 50)),
  creation-date: uint,
  status: (string-ascii 20)
})

(define-public (create-artwork (title (string-ascii 100)) (description (string-utf8 500)) (dimensions (list 10 (string-ascii 50))))
  (let
    ((new-id (+ (var-get artwork-counter) u1)))
    (map-set multidimensional-artworks new-id {
      artist: tx-sender,
      title: title,
      description: description,
      dimensions: dimensions,
      creation-date: block-height,
      status: "created"
    })
    (var-set artwork-counter new-id)
    (ok new-id)
  )
)

(define-public (update-artwork-status (artwork-id uint) (new-status (string-ascii 20)))
  (let
    ((artwork (unwrap! (map-get? multidimensional-artworks artwork-id) (err u404))))
    (asserts! (is-eq tx-sender (get artist artwork)) (err u403))
    (ok (map-set multidimensional-artworks artwork-id
      (merge artwork { status: new-status })))
  )
)

(define-read-only (get-artwork (artwork-id uint))
  (map-get? multidimensional-artworks artwork-id)
)

(define-read-only (get-artwork-count)
  (var-get artwork-counter)
)

