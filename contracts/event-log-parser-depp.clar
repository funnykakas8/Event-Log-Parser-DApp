(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_PARAMS (err u400))
(define-constant ERR_ALREADY_EXISTS (err u409))
(define-constant ERR_SUBSCRIPTION_LIMIT (err u429))
(define-constant ERR_SCHEMA_NOT_FOUND (err u430))
(define-constant ERR_VALIDATION_FAILED (err u431))
(define-constant ERR_SCHEMA_EXISTS (err u432))
(define-constant ERR_TAG_LIMIT (err u433))
(define-constant ERR_TAG_NOT_FOUND (err u434))
(define-constant ERR_TAG_EXISTS (err u435))

(define-data-var next-event-id uint u1)
(define-data-var total-events uint u0)
(define-data-var contract-paused bool false)
(define-data-var next-subscription-id uint u1)
(define-data-var total-subscriptions uint u0)
(define-data-var next-report-id uint u1)
(define-data-var last-aggregation-block uint u0)
(define-data-var next-schema-id uint u1)
(define-data-var schema-validation-enabled bool true)
(define-data-var next-tag-id uint u1)
(define-data-var total-tags uint u0)

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

(define-map aggregation-reports
  uint
  {
    report-type: (string-ascii 20),
    time-period: uint,
    start-block: uint,
    end-block: uint,
    total-events: uint,
    unique-users: uint,
    top-category: (string-ascii 50),
    avg-severity: uint,
    critical-events: uint,
    generated-at: uint
  }
)

(define-map hourly-aggregations
  uint
  {
    hour-block: uint,
    event-count: uint,
    user-count: uint,
    category-breakdown: (list 5 {category: (string-ascii 50), count: uint}),
    severity-distribution: (list 5 uint),
    peak-activity: bool
  }
)

(define-map trend-analysis
  (string-ascii 50)
  {
    metric-name: (string-ascii 50),
    current-value: uint,
    previous-value: uint,
    trend-direction: (string-ascii 10),
    change-percentage: uint,
    last-calculated: uint
  }
)

(define-map event-schemas
  (string-ascii 50)
  {
    schema-id: uint,
    event-type: (string-ascii 50),
    required-fields: (list 5 (string-ascii 30)),
    field-types: (list 5 (string-ascii 20)),
    min-data-length: uint,
    max-data-length: uint,
    allowed-categories: (list 10 (string-ascii 50)),
    min-severity: uint,
    max-severity: uint,
    active: bool,
    created-by: principal,
    created-at: uint,
    version: uint
  }
)

(define-map schema-validations
  uint
  {
    event-id: uint,
    schema-used: (string-ascii 50),
    validation-passed: bool,
    validation-errors: (list 5 (string-ascii 100)),
    validated-at: uint
  }
)

(define-map tags
  uint
  {
    tag-id: uint,
    tag-name: (string-ascii 50),
    tag-color: (string-ascii 20),
    description: (string-ascii 200),
    created-by: principal,
    created-at: uint,
    usage-count: uint,
    active: bool
  }
)

(define-map tag-names
  (string-ascii 50)
  uint
)

(define-map event-tags
  {event-id: uint, tag-id: uint}
  {
    tagged-by: principal,
    tagged-at: uint,
    weight: uint
  }
)

(define-map event-tag-list
  uint
  {
    tags: (list 10 uint),
    tag-count: uint,
    last-tagged: uint
  }
)

(define-map tag-events
  uint
  {
    event-ids: (list 20 uint),
    event-count: uint,
    last-event: uint
  }
)

(define-map user-tags
  principal
  {
    created-tags: (list 20 uint),
    total-created: uint,
    last-created: uint
  }
)

(define-read-only (get-contract-info)
  {
    total-events: (var-get total-events),
    next-event-id: (var-get next-event-id),
    contract-paused: (var-get contract-paused),
    total-subscriptions: (var-get total-subscriptions),
    next-report-id: (var-get next-report-id),
    last-aggregation-block: (var-get last-aggregation-block),
    next-schema-id: (var-get next-schema-id),
    schema-validation-enabled: (var-get schema-validation-enabled),
    next-tag-id: (var-get next-tag-id),
    total-tags: (var-get total-tags),
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

(define-read-only (get-aggregation-report (report-id uint))
  (map-get? aggregation-reports report-id)
)

(define-read-only (get-hourly-aggregation (hour-block uint))
  (map-get? hourly-aggregations hour-block)
)

(define-read-only (get-trend-analysis (metric-name (string-ascii 50)))
  (map-get? trend-analysis metric-name)
)

(define-read-only (get-event-schema (event-type (string-ascii 50)))
  (map-get? event-schemas event-type)
)

(define-read-only (get-schema-validation (event-id uint))
  (map-get? schema-validations event-id)
)

(define-read-only (get-tag (tag-id uint))
  (map-get? tags tag-id)
)

(define-read-only (get-tag-by-name (tag-name (string-ascii 50)))
  (let ((tag-id-opt (map-get? tag-names tag-name)))
    (if (is-some tag-id-opt)
      (get-tag (unwrap-panic tag-id-opt))
      none
    )
  )
)

(define-read-only (get-event-tags (event-id uint))
  (map-get? event-tag-list event-id)
)

(define-read-only (get-tag-events (tag-id uint))
  (map-get? tag-events tag-id)
)

(define-read-only (get-user-tags (user principal))
  (map-get? user-tags user)
)

(define-read-only (is-event-tagged (event-id uint) (tag-id uint))
  (is-some (map-get? event-tags {event-id: event-id, tag-id: tag-id}))
)

(define-read-only (get-popular-tags (limit uint))
  (fold check-popular-tags (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) (list))
)

(define-read-only (search-events-by-tag (tag-id uint))
  (let ((tag-event-data (get-tag-events tag-id)))
    (if (is-some tag-event-data)
      (get event-ids (unwrap-panic tag-event-data))
      (list)
    )
  )
)

(define-read-only (get-all-schemas)
  (list 
    (get-event-schema "user-action")
    (get-event-schema "system-event")
    (get-event-schema "transaction")
    (get-event-schema "security-alert")
    (get-event-schema "error-log")
  )
)

(define-read-only (validate-event-against-schema (event-type (string-ascii 50)) (data (string-ascii 500)) (category (string-ascii 50)) (severity uint))
  (let ((schema (get-event-schema event-type)))
    (if (is-some schema)
      (let ((schema-data (unwrap-panic schema)))
        {
          has-schema: true,
          validation-result: (perform-schema-validation schema-data data category severity),
          schema-active: (get active schema-data)
        }
      )
      {
        has-schema: false,
        validation-result: false,
        schema-active: false
      }
    )
  )
)

(define-read-only (get-latest-reports (limit uint))
  (let ((current-report-id (var-get next-report-id)))
    (if (> current-report-id u1)
      (fold check-recent-reports (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) (list))
      (list)
    )
  )
)

(define-read-only (get-performance-metrics)
  {
    events-per-hour: (calculate-hourly-rate),
    peak-usage-block: (find-peak-usage-hour),
    trend-summary: (get-trending-metrics),
    efficiency-score: (calculate-efficiency-score)
  }
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

(define-private (check-recent-reports (index uint) (acc (list 10 uint)))
  (let ((current-report-id (var-get next-report-id))
        (check-id (if (> current-report-id index) (- current-report-id index) u0)))
    (if (and (> check-id u0) (< (len acc) u10))
      (unwrap-panic (as-max-len? (append acc check-id) u10))
      acc
    )
  )
)

(define-private (calculate-hourly-rate)
  (let ((current-hour (/ stacks-block-height u100)))
    (if (> (var-get total-events) u0)
      (/ (var-get total-events) (if (> current-hour u0) current-hour u1))
      u0
    )
  )
)

(define-private (find-peak-usage-hour)
  (let ((current-hour (/ stacks-block-height u100)))
    (fold find-max-hour-activity (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) current-hour)
  )
)

(define-private (find-max-hour-activity (offset uint) (current-max uint))
  (let ((check-hour (- (/ stacks-block-height u100) offset))
        (hour-data (get-hourly-aggregation check-hour)))
    (if (is-some hour-data)
      (let ((data (unwrap-panic hour-data)))
        (if (> (get event-count data) (get event-count (unwrap-panic (get-hourly-aggregation current-max))))
          check-hour
          current-max
        )
      )
      current-max
    )
  )
)

(define-private (get-trending-metrics)
  (list 
    (get-trend-analysis "total-events")
    (get-trend-analysis "unique-users")
    (get-trend-analysis "avg-severity")
  )
)

(define-private (perform-schema-validation (schema {schema-id: uint, event-type: (string-ascii 50), required-fields: (list 5 (string-ascii 30)), field-types: (list 5 (string-ascii 20)), min-data-length: uint, max-data-length: uint, allowed-categories: (list 10 (string-ascii 50)), min-severity: uint, max-severity: uint, active: bool, created-by: principal, created-at: uint, version: uint}) (data (string-ascii 500)) (category (string-ascii 50)) (severity uint))
  (and
    (get active schema)
    (>= (len data) (get min-data-length schema))
    (<= (len data) (get max-data-length schema))
    (>= severity (get min-severity schema))
    (<= severity (get max-severity schema))
    (is-category-allowed category (get allowed-categories schema))
  )
)

(define-private (is-category-allowed (category (string-ascii 50)) (allowed-categories (list 10 (string-ascii 50))))
  (or 
    (is-eq (len allowed-categories) u0)
    (is-some (index-of allowed-categories category))
  )
)

(define-private (validate-event-data (event-type (string-ascii 50)) (data (string-ascii 500)) (category (string-ascii 50)) (severity uint))
  (if (var-get schema-validation-enabled)
    (let ((schema (get-event-schema event-type)))
      (if (is-some schema)
        (perform-schema-validation (unwrap-panic schema) data category severity)
        true
      )
    )
    true
  )
)

(define-private (check-popular-tags (index uint) (acc (list 10 uint)))
  (let ((tag-id (if (<= index (var-get next-tag-id)) index u0)))
    (if (and (> tag-id u0) (< (len acc) u10))
      (let ((tag-data (get-tag tag-id)))
        (if (is-some tag-data)
          (let ((tag (unwrap-panic tag-data)))
            (if (get active tag)
              (unwrap-panic (as-max-len? (append acc tag-id) u10))
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

(define-private (update-tag-usage-count (tag-id uint))
  (let ((tag-data (get-tag tag-id)))
    (if (is-some tag-data)
      (let ((tag (unwrap-panic tag-data)))
        (map-set tags tag-id (merge tag {
          usage-count: (+ (get usage-count tag) u1)
        }))
      )
      false
    )
  )
)

(define-private (record-validation-result (event-id uint) (event-type (string-ascii 50)) (validation-passed bool) (errors (list 5 (string-ascii 100))))
  (map-set schema-validations event-id {
    event-id: event-id,
    schema-used: event-type,
    validation-passed: validation-passed,
    validation-errors: errors,
    validated-at: stacks-block-height
  })
)

(define-private (calculate-efficiency-score)
  (let ((total (var-get total-events))
        (hours-active (/ (- stacks-block-height u1000000) u100)))
    (if (and (> total u0) (> hours-active u0))
      (/ (* total u100) hours-active)
      u0
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
  (let ((event-id (var-get next-event-id))
        (validation-passed (validate-event-data event-type data category severity)))
    (asserts! (not (var-get contract-paused)) ERR_UNAUTHORIZED)
    (asserts! (and (> severity u0) (<= severity u5)) ERR_INVALID_PARAMS)
    (asserts! (> (len event-type) u0) ERR_INVALID_PARAMS)
    (asserts! (> (len category) u0) ERR_INVALID_PARAMS)
    (asserts! validation-passed ERR_VALIDATION_FAILED)
    
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
    (update-hourly-aggregation)
    (record-validation-result event-id event-type validation-passed (list))
    
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

(define-private (update-hourly-aggregation)
  (let ((current-hour (/ stacks-block-height u100))
        (existing-hour (get-hourly-aggregation current-hour)))
    (if (is-some existing-hour)
      (let ((hour-data (unwrap-panic existing-hour)))
        (map-set hourly-aggregations current-hour {
          hour-block: current-hour,
          event-count: (+ (get event-count hour-data) u1),
          user-count: (get user-count hour-data),
          category-breakdown: (get category-breakdown hour-data),
          severity-distribution: (get severity-distribution hour-data),
          peak-activity: (> (+ (get event-count hour-data) u1) u50)
        })
      )
      (map-set hourly-aggregations current-hour {
        hour-block: current-hour,
        event-count: u1,
        user-count: u1,
        category-breakdown: (list),
        severity-distribution: (list u0 u0 u0 u0 u0),
        peak-activity: false
      })
    )
  )
)

(define-public (generate-hourly-report)
  (let ((current-hour (/ stacks-block-height u100))
        (report-id (var-get next-report-id)))
    (asserts! (not (var-get contract-paused)) ERR_UNAUTHORIZED)
    (asserts! (> (- current-hour (var-get last-aggregation-block)) u1) ERR_INVALID_PARAMS)
    
    (let ((hour-data (get-hourly-aggregation (- current-hour u1))))
      (if (is-some hour-data)
        (let ((data (unwrap-panic hour-data)))
          (map-set aggregation-reports report-id {
            report-type: "hourly",
            time-period: (- current-hour u1),
            start-block: (* (- current-hour u1) u100),
            end-block: (* current-hour u100),
            total-events: (get event-count data),
            unique-users: (get user-count data),
            top-category: "system",
            avg-severity: u2,
            critical-events: u0,
            generated-at: stacks-block-height
          })
          (var-set next-report-id (+ report-id u1))
          (var-set last-aggregation-block current-hour)
          (ok report-id)
        )
        ERR_NOT_FOUND
      )
    )
  )
)

(define-public (generate-daily-report)
  (let ((current-day (/ stacks-block-height u2400))
        (report-id (var-get next-report-id)))
    (asserts! (not (var-get contract-paused)) ERR_UNAUTHORIZED)
    
    (let ((day-events (calculate-daily-events (- current-day u1)))
          (day-users (calculate-daily-users (- current-day u1))))
      (map-set aggregation-reports report-id {
        report-type: "daily",
        time-period: (- current-day u1),
        start-block: (* (- current-day u1) u2400),
        end-block: (* current-day u2400),
        total-events: day-events,
        unique-users: day-users,
        top-category: (find-top-category-for-period (- current-day u1)),
        avg-severity: (calculate-avg-severity-for-period (- current-day u1)),
        critical-events: (count-critical-events-for-period (- current-day u1)),
        generated-at: stacks-block-height
      })
      (var-set next-report-id (+ report-id u1))
      (ok report-id)
    )
  )
)

(define-public (update-trend-metrics (metric-name (string-ascii 50)))
  (let ((current-value (get-current-metric-value metric-name))
        (existing-trend (get-trend-analysis metric-name)))
    (if (is-some existing-trend)
      (let ((trend (unwrap-panic existing-trend))
            (prev-value (get current-value trend)))
        (map-set trend-analysis metric-name {
          metric-name: metric-name,
          current-value: current-value,
          previous-value: prev-value,
          trend-direction: (calculate-trend-direction current-value prev-value),
          change-percentage: (calculate-change-percentage current-value prev-value),
          last-calculated: stacks-block-height
        })
      )
      (map-set trend-analysis metric-name {
        metric-name: metric-name,
        current-value: current-value,
        previous-value: u0,
        trend-direction: "stable",
        change-percentage: u0,
        last-calculated: stacks-block-height
      })
    )
    (ok true)
  )
)

(define-private (calculate-daily-events (day uint))
  (let ((start-block (* day u2400))
        (end-block (* (+ day u1) u2400)))
    (fold count-events-in-range (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10) u0)
  )
)

(define-private (calculate-daily-users (day uint))
  u10
)

(define-private (find-top-category-for-period (day uint))
  "system"
)

(define-private (calculate-avg-severity-for-period (day uint))
  u2
)

(define-private (count-critical-events-for-period (day uint))
  u0
)

(define-private (count-events-in-range (index uint) (acc uint))
  (+ acc u1)
)

(define-private (get-current-metric-value (metric-name (string-ascii 50)))
  (if (is-eq metric-name "total-events")
    (var-get total-events)
    (if (is-eq metric-name "unique-users") 
      u100
      u2
    )
  )
)

(define-private (calculate-trend-direction (current uint) (previous uint))
  (if (> current previous)
    "up"
    (if (< current previous)
      "down"
      "stable"
    )
  )
)

(define-private (calculate-change-percentage (current uint) (previous uint))
  (if (> previous u0)
    (/ (* (if (> current previous) (- current previous) (- previous current)) u100) previous)
    u0
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

(define-public (create-event-schema (event-type (string-ascii 50)) (required-fields (list 5 (string-ascii 30))) (field-types (list 5 (string-ascii 20))) (min-data-length uint) (max-data-length uint) (allowed-categories (list 10 (string-ascii 50))) (min-severity uint) (max-severity uint))
  (let ((schema-id (var-get next-schema-id))
        (existing-schema (get-event-schema event-type)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-none existing-schema) ERR_SCHEMA_EXISTS)
    (asserts! (> (len event-type) u0) ERR_INVALID_PARAMS)
    (asserts! (and (>= min-severity u1) (<= max-severity u5) (<= min-severity max-severity)) ERR_INVALID_PARAMS)
    (asserts! (<= min-data-length max-data-length) ERR_INVALID_PARAMS)
    
    (map-set event-schemas event-type {
      schema-id: schema-id,
      event-type: event-type,
      required-fields: required-fields,
      field-types: field-types,
      min-data-length: min-data-length,
      max-data-length: max-data-length,
      allowed-categories: allowed-categories,
      min-severity: min-severity,
      max-severity: max-severity,
      active: true,
      created-by: tx-sender,
      created-at: stacks-block-height,
      version: u1
    })
    
    (var-set next-schema-id (+ schema-id u1))
    (ok schema-id)
  )
)

(define-public (update-event-schema (event-type (string-ascii 50)) (min-data-length uint) (max-data-length uint) (min-severity uint) (max-severity uint))
  (let ((existing-schema (get-event-schema event-type)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-some existing-schema) ERR_SCHEMA_NOT_FOUND)
    (asserts! (and (>= min-severity u1) (<= max-severity u5) (<= min-severity max-severity)) ERR_INVALID_PARAMS)
    (asserts! (<= min-data-length max-data-length) ERR_INVALID_PARAMS)
    
    (let ((schema (unwrap-panic existing-schema)))
      (map-set event-schemas event-type (merge schema {
        min-data-length: min-data-length,
        max-data-length: max-data-length,
        min-severity: min-severity,
        max-severity: max-severity,
        version: (+ (get version schema) u1)
      }))
    )
    (ok true)
  )
)

(define-public (activate-schema (event-type (string-ascii 50)))
  (let ((existing-schema (get-event-schema event-type)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-some existing-schema) ERR_SCHEMA_NOT_FOUND)
    
    (let ((schema (unwrap-panic existing-schema)))
      (map-set event-schemas event-type (merge schema {active: true}))
    )
    (ok true)
  )
)

(define-public (deactivate-schema (event-type (string-ascii 50)))
  (let ((existing-schema (get-event-schema event-type)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-some existing-schema) ERR_SCHEMA_NOT_FOUND)
    
    (let ((schema (unwrap-panic existing-schema)))
      (map-set event-schemas event-type (merge schema {active: false}))
    )
    (ok true)
  )
)

(define-public (toggle-schema-validation)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (var-set schema-validation-enabled (not (var-get schema-validation-enabled)))
    (ok (var-get schema-validation-enabled))
  )
)

(define-public (delete-schema (event-type (string-ascii 50)))
  (let ((existing-schema (get-event-schema event-type)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-some existing-schema) ERR_SCHEMA_NOT_FOUND)
    
    (map-delete event-schemas event-type)
    (ok true)
  )
)

(define-public (create-tag (tag-name (string-ascii 50)) (tag-color (string-ascii 20)) (description (string-ascii 200)))
  (let ((tag-id (var-get next-tag-id))
        (existing-tag (map-get? tag-names tag-name))
        (user-tag-data (get-user-tags tx-sender)))
    (asserts! (is-none existing-tag) ERR_TAG_EXISTS)
    (asserts! (> (len tag-name) u0) ERR_INVALID_PARAMS)
    (asserts! (if (is-some user-tag-data)
                (< (get total-created (unwrap-panic user-tag-data)) u20)
                true) ERR_TAG_LIMIT)
    
    (map-set tags tag-id {
      tag-id: tag-id,
      tag-name: tag-name,
      tag-color: tag-color,
      description: description,
      created-by: tx-sender,
      created-at: stacks-block-height,
      usage-count: u0,
      active: true
    })
    
    (map-set tag-names tag-name tag-id)
    (update-user-tag-list tx-sender tag-id)
    
    (var-set next-tag-id (+ tag-id u1))
    (var-set total-tags (+ (var-get total-tags) u1))
    
    (ok tag-id)
  )
)

(define-private (update-user-tag-list (user principal) (tag-id uint))
  (let ((existing-tags (get-user-tags user)))
    (if (is-some existing-tags)
      (let ((user-tag-data (unwrap-panic existing-tags)))
        (map-set user-tags user {
          created-tags: (unwrap-panic (as-max-len? (append (get created-tags user-tag-data) tag-id) u20)),
          total-created: (+ (get total-created user-tag-data) u1),
          last-created: stacks-block-height
        })
      )
      (map-set user-tags user {
        created-tags: (list tag-id),
        total-created: u1,
        last-created: stacks-block-height
      })
    )
  )
)

(define-public (tag-event (event-id uint) (tag-id uint) (weight uint))
  (let ((event-data (get-event event-id))
        (tag-data (get-tag tag-id))
        (event-tag-data (get-event-tags event-id)))
    (asserts! (is-some event-data) ERR_NOT_FOUND)
    (asserts! (is-some tag-data) ERR_TAG_NOT_FOUND)
    (asserts! (not (is-event-tagged event-id tag-id)) ERR_ALREADY_EXISTS)
    (asserts! (and (>= weight u1) (<= weight u5)) ERR_INVALID_PARAMS)
    (asserts! (if (is-some event-tag-data)
                (< (get tag-count (unwrap-panic event-tag-data)) u10)
                true) ERR_TAG_LIMIT)
    
    (map-set event-tags {event-id: event-id, tag-id: tag-id} {
      tagged-by: tx-sender,
      tagged-at: stacks-block-height,
      weight: weight
    })
    
    (update-event-tag-list event-id tag-id)
    (update-tag-event-list tag-id event-id)
    (update-tag-usage-count tag-id)
    
    (ok true)
  )
)

(define-private (update-event-tag-list (event-id uint) (tag-id uint))
  (let ((existing-tags (get-event-tags event-id)))
    (if (is-some existing-tags)
      (let ((tag-list (unwrap-panic existing-tags)))
        (map-set event-tag-list event-id {
          tags: (unwrap-panic (as-max-len? (append (get tags tag-list) tag-id) u10)),
          tag-count: (+ (get tag-count tag-list) u1),
          last-tagged: stacks-block-height
        })
      )
      (map-set event-tag-list event-id {
        tags: (list tag-id),
        tag-count: u1,
        last-tagged: stacks-block-height
      })
    )
  )
)

(define-private (update-tag-event-list (tag-id uint) (event-id uint))
  (let ((existing-events (get-tag-events tag-id)))
    (if (is-some existing-events)
      (let ((event-list (unwrap-panic existing-events)))
        (map-set tag-events tag-id {
          event-ids: (unwrap-panic (as-max-len? (append (get event-ids event-list) event-id) u20)),
          event-count: (+ (get event-count event-list) u1),
          last-event: event-id
        })
      )
      (map-set tag-events tag-id {
        event-ids: (list event-id),
        event-count: u1,
        last-event: event-id
      })
    )
  )
)

(define-public (untag-event (event-id uint) (tag-id uint))
  (let ((event-tag-data (map-get? event-tags {event-id: event-id, tag-id: tag-id})))
    (asserts! (is-some event-tag-data) ERR_NOT_FOUND)
    (asserts! (is-eq (get tagged-by (unwrap-panic event-tag-data)) tx-sender) ERR_UNAUTHORIZED)
    
    (map-delete event-tags {event-id: event-id, tag-id: tag-id})
    (ok true)
  )
)

(define-public (update-tag (tag-id uint) (tag-color (string-ascii 20)) (description (string-ascii 200)))
  (let ((tag-data (get-tag tag-id)))
    (asserts! (is-some tag-data) ERR_TAG_NOT_FOUND)
    (let ((tag (unwrap-panic tag-data)))
      (asserts! (is-eq (get created-by tag) tx-sender) ERR_UNAUTHORIZED)
      
      (map-set tags tag-id (merge tag {
        tag-color: tag-color,
        description: description
      }))
      (ok true)
    )
  )
)

(define-public (deactivate-tag (tag-id uint))
  (let ((tag-data (get-tag tag-id)))
    (asserts! (is-some tag-data) ERR_TAG_NOT_FOUND)
    (let ((tag (unwrap-panic tag-data)))
      (asserts! (is-eq (get created-by tag) tx-sender) ERR_UNAUTHORIZED)
      
      (map-set tags tag-id (merge tag {active: false}))
      (ok true)
    )
  )
)

(define-public (reactivate-tag (tag-id uint))
  (let ((tag-data (get-tag tag-id)))
    (asserts! (is-some tag-data) ERR_TAG_NOT_FOUND)
    (let ((tag (unwrap-panic tag-data)))
      (asserts! (is-eq (get created-by tag) tx-sender) ERR_UNAUTHORIZED)
      
      (map-set tags tag-id (merge tag {active: true}))
      (ok true)
    )
  )
)
