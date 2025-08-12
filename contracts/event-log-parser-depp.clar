(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_PARAMS (err u400))
(define-constant ERR_ALREADY_EXISTS (err u409))
(define-constant ERR_SUBSCRIPTION_LIMIT (err u429))

(define-data-var next-event-id uint u1)
(define-data-var total-events uint u0)
(define-data-var contract-paused bool false)
(define-data-var next-subscription-id uint u1)
(define-data-var total-subscriptions uint u0)

(define-map events
  uint
  {
    event-type: (string-ascii 50),
    user-address: principal,
    stacks-block-height: uint,
    timestamp: uint,
    data: (string-ascii 500),
    category: (string-ascii 50),
    severity: uint,
    indexed: bool
  }
)

(define-map event-categories
  (string-ascii 50)
  {
    total-count: uint,
    last-event-id: uint,
    created-at: uint
  }
)

(define-map user-event-stats
  principal
  {
    total-events: uint,
    last-event-id: uint,
    first-event-at: uint,
    last-event-at: uint
  }
)

(define-map daily-event-counts
  uint
  {
    date: uint,
    total-events: uint,
    unique-users: uint
  }
)

(define-map event-type-analytics
  (string-ascii 50)
  {
    count: uint,
    avg-severity: uint,
    last-occurrence: uint
  }
)

(define-map subscriptions
  uint
  {
    subscriber: principal,
    event-type: (optional (string-ascii 50)),
    category: (optional (string-ascii 50)),
    min-severity: (optional uint),
    max-severity: (optional uint),
    active: bool,
    created-at: uint,
    last-triggered: uint,
    trigger-count: uint
  }
)

(define-map user-subscriptions
  principal
  {
    subscription-ids: (list 20 uint),
    total-active: uint,
    last-created: uint
  }
)

(define-map subscription-alerts
  uint
  {
    subscription-id: uint,
    event-id: uint,
    triggered-at: uint,
    processed: bool
  }
)

(define-read-only (get-contract-info)
  {
    total-events: (var-get total-events),
    next-event-id: (var-get next-event-id),
    contract-paused: (var-get contract-paused),
    total-subscriptions: (var-get total-subscriptions),
    owner: CONTRACT_OWNER
  }
)

(define-read-only (get-event (event-id uint))
  (map-get? events event-id)
)

(define-read-only (get-user-stats (user principal))
  (map-get? user-event-stats user)
)

(define-read-only (get-category-stats (category (string-ascii 50)))
  (map-get? event-categories category)
)

(define-read-only (get-daily-stats (date uint))
  (map-get? daily-event-counts date)
)

(define-read-only (get-event-type-analytics (event-type (string-ascii 50)))
  (map-get? event-type-analytics event-type)
)

(define-read-only (get-subscription (subscription-id uint))
  (map-get? subscriptions subscription-id)
)

(define-read-only (get-user-subscriptions (user principal))
  (map-get? user-subscriptions user)
)

(define-read-only (get-subscription-alert (alert-id uint))
  (map-get? subscription-alerts alert-id)
)

(define-read-only (get-active-subscriptions-for-user (user principal))
  (let ((user-subs (get-user-subscriptions user)))
    (if (is-some user-subs)
      (let ((subs (unwrap-panic user-subs)))
        (filter check-active-subscription (get subscription-ids subs))
      )
      (list)
    )
  )
)

(define-read-only (get-subscription-stats (subscription-id uint))
  (let ((sub-data (get-subscription subscription-id)))
    (if (is-some sub-data)
      (let ((sub (unwrap-panic sub-data)))
        (some {
          active: (get active sub),
          trigger-count: (get trigger-count sub),
          last-triggered: (get last-triggered sub),
          created-at: (get created-at sub)
        })
      )
      none
    )
  )
)

(define-read-only (get-events-by-user (user principal) (limit uint))
  (let ((user-stats (get-user-stats user)))
    (if (is-some user-stats)
      (let ((stats (unwrap-panic user-stats))
            (start-id (get last-event-id stats))
            (max-check (+ start-id limit)))
        (fold check-user-events (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) (list)))
      (list)
    )
  )
)

(define-read-only (get-events-by-category (category (string-ascii 50)) (limit uint))
  (let ((cat-stats (get-category-stats category)))
    (if (is-some cat-stats)
      (let ((stats (unwrap-panic cat-stats))
            (last-id (get last-event-id stats)))
        (fold check-category-events (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) (list)))
      (list)
    )
  )
)

(define-read-only (get-recent-events (limit uint))
  (let ((current-id (var-get next-event-id)))
    (if (> current-id u1)
      (fold check-recent-events (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) (list))
      (list)
    )
  )
)

(define-read-only (get-events-by-severity (min-severity uint) (max-severity uint))
  (let ((current-id (var-get next-event-id)))
    (fold check-severity-events (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) (list))
  )
)

(define-read-only (get-analytics-summary)
  {
    total-events: (var-get total-events),
    total-categories: (len (list "system" "user" "transaction" "error" "security")),
    avg-events-per-user: (if (> (var-get total-events) u0) (/ (var-get total-events) u10) u0),
    contract-age: (- stacks-block-height u1000000)
  }
)

(define-private (check-user-events (index uint) (acc (list 10 uint)))
  (let ((current-id (var-get next-event-id))
        (check-id (if (> current-id index) (- current-id index) u0)))
    (if (and (> check-id u0) (< (len acc) u10))
      (let ((event-data (get-event check-id)))
        (if (is-some event-data)
          (let ((event (unwrap-panic event-data)))
            (if (is-eq (get user-address event) tx-sender)
              (unwrap-panic (as-max-len? (append acc check-id) u10))
              acc
            )
          )
          acc
        )
      )
      acc
    )
  )
)

(define-private (check-category-events (index uint) (acc (list 10 uint)))
  (let ((current-id (var-get next-event-id))
        (check-id (if (> current-id index) (- current-id index) u0)))
    (if (and (> check-id u0) (< (len acc) u10))
      (let ((event-data (get-event check-id)))
        (if (is-some event-data)
          (let ((event (unwrap-panic event-data)))
            (unwrap-panic (as-max-len? (append acc check-id) u10))
          )
          acc
        )
      )
      acc
    )
  )
)

(define-private (check-recent-events (index uint) (acc (list 10 uint)))
  (let ((current-id (var-get next-event-id))
        (check-id (if (> current-id index) (- current-id index) u0)))
    (if (and (> check-id u0) (< (len acc) u10))
      (unwrap-panic (as-max-len? (append acc check-id) u10))
      acc
    )
  )
)

(define-private (check-active-subscription (subscription-id uint))
  (let ((sub-data (get-subscription subscription-id)))
    (if (is-some sub-data)
      (let ((sub (unwrap-panic sub-data)))
        (get active sub)
      )
      false
    )
  )
)

(define-private (check-severity-events (index uint) (acc (list 10 uint)))
  (let ((current-id (var-get next-event-id))
        (check-id (if (> current-id index) (- current-id index) u0)))
    (if (and (> check-id u0) (< (len acc) u10))
      (let ((event-data (get-event check-id)))
        (if (is-some event-data)
          (let ((event (unwrap-panic event-data)))
            (if (and (>= (get severity event) u1) (<= (get severity event) u5))
              (unwrap-panic (as-max-len? (append acc check-id) u10))
              acc
            )
          )
          acc
        )
      )
      acc
    )
  )
)

(define-private (update-user-stats (user principal) (event-id uint))
  (let ((existing-stats (get-user-stats user)))
    (if (is-some existing-stats)
      (let ((stats (unwrap-panic existing-stats)))
        (map-set user-event-stats user {
          total-events: (+ (get total-events stats) u1),
          last-event-id: event-id,
          first-event-at: (get first-event-at stats),
          last-event-at: stacks-block-height
        })
      )
      (map-set user-event-stats user {
        total-events: u1,
        last-event-id: event-id,
        first-event-at: stacks-block-height,
        last-event-at: stacks-block-height
      })
    )
  )
)

(define-private (update-category-stats (category (string-ascii 50)) (event-id uint))
  (let ((existing-stats (get-category-stats category)))
    (if (is-some existing-stats)
      (let ((stats (unwrap-panic existing-stats)))
        (map-set event-categories category {
          total-count: (+ (get total-count stats) u1),
          last-event-id: event-id,
          created-at: (get created-at stats)
        })
      )
      (map-set event-categories category {
        total-count: u1,
        last-event-id: event-id,
        created-at: stacks-block-height
      })
    )
  )
)

(define-private (update-event-type-analytics (event-type (string-ascii 50)) (severity uint))
  (let ((existing-analytics (get-event-type-analytics event-type)))
    (if (is-some existing-analytics)
      (let ((analytics (unwrap-panic existing-analytics)))
        (map-set event-type-analytics event-type {
          count: (+ (get count analytics) u1),
          avg-severity: (/ (+ (* (get avg-severity analytics) (get count analytics)) severity) (+ (get count analytics) u1)),
          last-occurrence: stacks-block-height
        })
      )
      (map-set event-type-analytics event-type {
        count: u1,
        avg-severity: severity,
        last-occurrence: stacks-block-height
      })
    )
  )
)

(define-private (check-subscription-match (subscription-id uint) (event-type (string-ascii 50)) (category (string-ascii 50)) (severity uint))
  (let ((sub-data (get-subscription subscription-id)))
    (if (is-some sub-data)
      (let ((sub (unwrap-panic sub-data)))
        (and 
          (get active sub)
          (match (get event-type sub)
            some-type (is-eq some-type event-type)
            true
          )
          (match (get category sub)
            some-category (is-eq some-category category)
            true
          )
          (match (get min-severity sub)
            min-sev (>= severity min-sev)
            true
          )
          (match (get max-severity sub)
            max-sev (<= severity max-sev)
            true
          )
        )
      )
      false
    )
  )
)

(define-private (trigger-subscription-alerts (event-id uint) (event-type (string-ascii 50)) (category (string-ascii 50)) (severity uint))
  (let ((current-sub-id (var-get next-subscription-id)))
    (fold check-and-trigger-subscription (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20) event-id)
  )
)

(define-private (check-and-trigger-subscription (index uint) (event-id uint))
  (let ((current-sub-id (var-get next-subscription-id))
        (check-id (if (> current-sub-id index) (- current-sub-id index) u0)))
    (if (> check-id u0)
      (let ((event-data (get-event event-id)))
        (if (is-some event-data)
          (let ((event (unwrap-panic event-data)))
            (if (check-subscription-match check-id (get event-type event) (get category event) (get severity event))
              (begin
                (update-subscription-trigger check-id event-id)
                event-id
              )
              event-id
            )
          )
          event-id
        )
      )
      event-id
    )
  )
)

(define-private (update-subscription-trigger (subscription-id uint) (event-id uint))
  (let ((sub-data (get-subscription subscription-id)))
    (if (is-some sub-data)
      (let ((sub (unwrap-panic sub-data)))
        (map-set subscriptions subscription-id (merge sub {
          last-triggered: stacks-block-height,
          trigger-count: (+ (get trigger-count sub) u1)
        }))
      )
      false
    )
  )
)

(define-public (log-event (event-type (string-ascii 50)) (data (string-ascii 500)) (category (string-ascii 50)) (severity uint))
  (let ((event-id (var-get next-event-id)))
    (asserts! (not (var-get contract-paused)) ERR_UNAUTHORIZED)
    (asserts! (and (> severity u0) (<= severity u5)) ERR_INVALID_PARAMS)
    (asserts! (> (len event-type) u0) ERR_INVALID_PARAMS)
    (asserts! (> (len category) u0) ERR_INVALID_PARAMS)
    
    (map-set events event-id {
      event-type: event-type,
      user-address: tx-sender,
      stacks-block-height: stacks-block-height,
      timestamp: stacks-block-height,
      data: data,
      category: category,
      severity: severity,
      indexed: true
    })
    
    (update-user-stats tx-sender event-id)
    (update-category-stats category event-id)
    (update-event-type-analytics event-type severity)
    (trigger-subscription-alerts event-id event-type category severity)
    
    (var-set next-event-id (+ event-id u1))
    (var-set total-events (+ (var-get total-events) u1))
    
    (ok event-id)
  )
)

(define-public (bulk-log-events (events-data (list 10 {event-type: (string-ascii 50), data: (string-ascii 500), category: (string-ascii 50), severity: uint})))
  (let ((results (map process-bulk-event events-data)))
    (ok results)
  )
)

(define-private (process-bulk-event (event-data {event-type: (string-ascii 50), data: (string-ascii 500), category: (string-ascii 50), severity: uint}))
  (log-event 
    (get event-type event-data)
    (get data event-data)
    (get category event-data)
    (get severity event-data)
  )
)

(define-public (delete-event (event-id uint))
  (let ((event-data (get-event event-id)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-some event-data) ERR_NOT_FOUND)
    
    (map-delete events event-id)
    (var-set total-events (- (var-get total-events) u1))
    
    (ok true)
  )
)

(define-public (pause-contract)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (var-set contract-paused true)
    (ok true)
  )
)

(define-public (resume-contract)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (var-set contract-paused false)
    (ok true)
  )
)

(define-public (update-event-data (event-id uint) (new-data (string-ascii 500)))
  (let ((event-data (get-event event-id)))
    (asserts! (is-some event-data) ERR_NOT_FOUND)
    (let ((event (unwrap-panic event-data)))
      (asserts! (is-eq (get user-address event) tx-sender) ERR_UNAUTHORIZED)
      
      (map-set events event-id (merge event {data: new-data}))
      (ok true)
    )
  )
)

(define-public (reindex-event (event-id uint))
  (let ((event-data (get-event event-id)))
    (asserts! (is-some event-data) ERR_NOT_FOUND)
    (let ((event (unwrap-panic event-data)))
      (asserts! (is-eq (get user-address event) tx-sender) ERR_UNAUTHORIZED)
      
      (map-set events event-id (merge event {indexed: true}))
      (ok true)
    )
  )
)

(define-public (create-subscription (event-type (optional (string-ascii 50))) (category (optional (string-ascii 50))) (min-severity (optional uint)) (max-severity (optional uint)))
  (let ((subscription-id (var-get next-subscription-id))
        (user-subs (get-user-subscriptions tx-sender)))
    (asserts! (not (var-get contract-paused)) ERR_UNAUTHORIZED)
    (asserts! (if (is-some user-subs) 
                (< (get total-active (unwrap-panic user-subs)) u20) 
                true) ERR_SUBSCRIPTION_LIMIT)
    (asserts! (if (and (is-some min-severity) (is-some max-severity))
                (and (>= (unwrap-panic min-severity) u1) 
                     (<= (unwrap-panic max-severity) u5)
                     (<= (unwrap-panic min-severity) (unwrap-panic max-severity)))
                true) ERR_INVALID_PARAMS)
    
    (map-set subscriptions subscription-id {
      subscriber: tx-sender,
      event-type: event-type,
      category: category,
      min-severity: min-severity,
      max-severity: max-severity,
      active: true,
      created-at: stacks-block-height,
      last-triggered: u0,
      trigger-count: u0
    })
    
    (update-user-subscription-list tx-sender subscription-id)
    
    (var-set next-subscription-id (+ subscription-id u1))
    (var-set total-subscriptions (+ (var-get total-subscriptions) u1))
    
    (ok subscription-id)
  )
)

(define-private (update-user-subscription-list (user principal) (subscription-id uint))
  (let ((existing-subs (get-user-subscriptions user)))
    (if (is-some existing-subs)
      (let ((subs (unwrap-panic existing-subs)))
        (map-set user-subscriptions user {
          subscription-ids: (unwrap-panic (as-max-len? (append (get subscription-ids subs) subscription-id) u20)),
          total-active: (+ (get total-active subs) u1),
          last-created: stacks-block-height
        })
      )
      (map-set user-subscriptions user {
        subscription-ids: (list subscription-id),
        total-active: u1,
        last-created: stacks-block-height
      })
    )
  )
)

(define-public (deactivate-subscription (subscription-id uint))
  (let ((sub-data (get-subscription subscription-id)))
    (asserts! (is-some sub-data) ERR_NOT_FOUND)
    (let ((sub (unwrap-panic sub-data)))
      (asserts! (is-eq (get subscriber sub) tx-sender) ERR_UNAUTHORIZED)
      (asserts! (get active sub) ERR_INVALID_PARAMS)
      
      (map-set subscriptions subscription-id (merge sub {active: false}))
      (decrease-user-active-count tx-sender)
      
      (ok true)
    )
  )
)

(define-public (reactivate-subscription (subscription-id uint))
  (let ((sub-data (get-subscription subscription-id)))
    (asserts! (is-some sub-data) ERR_NOT_FOUND)
    (let ((sub (unwrap-panic sub-data))
          (user-subs (get-user-subscriptions tx-sender)))
      (asserts! (is-eq (get subscriber sub) tx-sender) ERR_UNAUTHORIZED)
      (asserts! (not (get active sub)) ERR_INVALID_PARAMS)
      (asserts! (if (is-some user-subs) 
                  (< (get total-active (unwrap-panic user-subs)) u20) 
                  true) ERR_SUBSCRIPTION_LIMIT)
      
      (map-set subscriptions subscription-id (merge sub {active: true}))
      (increase-user-active-count tx-sender)
      
      (ok true)
    )
  )
)

(define-private (decrease-user-active-count (user principal))
  (let ((user-subs (get-user-subscriptions user)))
    (if (is-some user-subs)
      (let ((subs (unwrap-panic user-subs)))
        (map-set user-subscriptions user (merge subs {
          total-active: (if (> (get total-active subs) u0) (- (get total-active subs) u1) u0)
        }))
      )
      false
    )
  )
)

(define-private (increase-user-active-count (user principal))
  (let ((user-subs (get-user-subscriptions user)))
    (if (is-some user-subs)
      (let ((subs (unwrap-panic user-subs)))
        (map-set user-subscriptions user (merge subs {
          total-active: (+ (get total-active subs) u1)
        }))
      )
      false
    )
  )
)

(define-public (delete-subscription (subscription-id uint))
  (let ((sub-data (get-subscription subscription-id)))
    (asserts! (is-some sub-data) ERR_NOT_FOUND)
    (let ((sub (unwrap-panic sub-data)))
      (asserts! (is-eq (get subscriber sub) tx-sender) ERR_UNAUTHORIZED)
      
      (map-delete subscriptions subscription-id)
      (if (get active sub) (decrease-user-active-count tx-sender) true)
      (var-set total-subscriptions (- (var-get total-subscriptions) u1))
      
      (ok true)
    )
  )
)
