;; Curation Process Contract

(define-data-var curation-counter uint u0)

(define-map curation-processes uint {
  curator: principal,
  artwork-id: uint,
  theme: (string-ascii 100),
  curation-notes: (string-utf8 1000),
  status: (string-ascii 20),
  start-date: uint,
  end-date: uint
})

(define-public (start-curation-process (artwork-id uint) (theme (string-ascii 100)))
  (let
    ((new-id (+ (var-get curation-counter) u1)))
    (map-set curation-processes new-id {
      curator: tx-sender,
      artwork-id: artwork-id,
      theme: theme,
      curation-notes: "",
      status: "in-progress",
      start-date: block-height,
      end-date: u0
    })
    (var-set curation-counter new-id)
    (ok new-id)
  )
)

(define-public (update-curation-notes (process-id uint) (notes (string-utf8 1000)))
  (let
    ((process (unwrap! (map-get? curation-processes process-id) (err u404))))
    (asserts! (is-eq tx-sender (get curator process)) (err u403))
    (ok (map-set curation-processes process-id
      (merge process { curation-notes: notes })))
  )
)

(define-public (complete-curation-process (process-id uint))
  (let
    ((process (unwrap! (map-get? curation-processes process-id) (err u404))))
    (asserts! (is-eq tx-sender (get curator process)) (err u403))
    (ok (map-set curation-processes process-id
      (merge process {
        status: "completed",
        end-date: block-height
      })))
  )
)

(define-read-only (get-curation-process (process-id uint))
  (map-get? curation-processes process-id)
)

(define-read-only (get-curation-count)
  (var-get curation-counter)
)

