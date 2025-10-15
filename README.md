# 📊 Event Log Parser DApp

A powerful Clarity smart contract for indexing, storing, and analyzing blockchain events with comprehensive analytics capabilities and intelligent reporting.

## 🚀 Features

- **📝 Event Logging**: Store structured events with metadata
- **🔍 Advanced Indexing**: Query events by user, category, severity, and type
- **📈 Analytics Engine**: Real-time analytics and statistics
- **👥 User Tracking**: Per-user event statistics and history
- **🏷️ Category Management**: Organize events by custom categories
- **⚡ Bulk Operations**: Process multiple events efficiently
- **🔐 Access Control**: Owner-only administrative functions
- **⏸️ Contract Pausing**: Emergency pause/resume functionality
- **🔔 Event Subscriptions**: Real-time monitoring and alerts
- **📊 Aggregation Reports**: Automated hourly and daily analytics
- **📈 Trend Analysis**: Historical data patterns and insights
- **🛡️ Schema Validation**: Type-safe event validation with custom schemas
- **✅ Data Quality**: Automatic validation and error tracking
- **🏷️ Event Tagging**: Dynamic labeling and multi-dimensional organization
- **🔍 Tag-based Search**: Advanced filtering and discovery by tags

## 🛠️ Installation

1. **Clone the repository**:
```bash
git clone <repository-url>
cd event-log-parser-dapp
```

2. **Install Clarinet** (if not already installed):
```bash
npm install -g @hirosystems/clarinet
```

3. **Initialize the project**:
```bash
clarinet check
```

## 📖 Usage

### Basic Event Logging

```clarity
;; Log a simple event
(contract-call? .event-log-parser-depp log-event 
  "user-login" 
  "User logged in successfully" 
  "authentication" 
  u1)
```

### Bulk Event Logging

```clarity
;; Log multiple events at once
(contract-call? .event-log-parser-depp bulk-log-events 
  (list 
    {event-type: "user-signup", data: "New user registered", category: "user", severity: u1}
    {event-type: "payment", data: "Payment processed", category: "transaction", severity: u2}
  ))
```

### Query Events

```clarity
;; Get recent events
(contract-call? .event-log-parser-depp get-recent-events u10)

;; Get events by user
(contract-call? .event-log-parser-depp get-events-by-user 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u5)

;; Get events by category
(contract-call? .event-log-parser-depp get-events-by-category "authentication" u10)
```

### Analytics

```clarity
;; Get contract analytics summary
(contract-call? .event-log-parser-depp get-analytics-summary)

;; Get user statistics
(contract-call? .event-log-parser-depp get-user-stats 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Get category statistics
(contract-call? .event-log-parser-depp get-category-stats "security")
```

### Subscriptions & Alerts

```clarity
;; Create event subscription
(contract-call? .event-log-parser-depp create-subscription 
  (some "user-login") 
  (some "authentication") 
  (some u3) 
  (some u5))

;; Get user subscriptions
(contract-call? .event-log-parser-depp get-active-subscriptions-for-user tx-sender)

;; Deactivate subscription
(contract-call? .event-log-parser-depp deactivate-subscription u1)
```

### Reports & Aggregations

```clarity
;; Generate hourly report
(contract-call? .event-log-parser-depp generate-hourly-report)

;; Generate daily report
(contract-call? .event-log-parser-depp generate-daily-report)

;; Get latest reports
(contract-call? .event-log-parser-depp get-latest-reports u5)

;; Update trend metrics
(contract-call? .event-log-parser-depp update-trend-metrics "total-events")

;; Get performance metrics
(contract-call? .event-log-parser-depp get-performance-metrics)
```

### Schema Validation

```clarity
;; Create event schema
(contract-call? .event-log-parser-depp create-event-schema 
  "user-action" 
  (list "action" "user_id") 
  (list "string" "uint") 
  u10 
  u200 
  (list "user" "system") 
  u1 
  u3)

;; Get event schema
(contract-call? .event-log-parser-depp get-event-schema "user-action")

;; Validate event before logging
(contract-call? .event-log-parser-depp validate-event-against-schema 
  "user-action" 
  "User clicked button" 
  "user" 
  u2)

;; Get validation result for event
(contract-call? .event-log-parser-depp get-schema-validation u1)

;; Toggle schema validation
(contract-call? .event-log-parser-depp toggle-schema-validation)
```

### Tagging & Labels

```clarity
;; Create a custom tag
(contract-call? .event-log-parser-depp create-tag 
  "urgent" 
  "red" 
  "High priority events requiring immediate attention")

;; Tag an event
(contract-call? .event-log-parser-depp tag-event u1 u1 u5)

;; Get event tags
(contract-call? .event-log-parser-depp get-event-tags u1)

;; Search events by tag
(contract-call? .event-log-parser-depp search-events-by-tag u1)

;; Get popular tags
(contract-call? .event-log-parser-depp get-popular-tags u10)

;; Get tag by name
(contract-call? .event-log-parser-depp get-tag-by-name "urgent")

;; Untag an event
(contract-call? .event-log-parser-depp untag-event u1 u1)
```

## 🏗️ Contract Architecture

### Data Structures

- **📋 Events Map**: Stores all event data with unique IDs
- **🏷️ Categories Map**: Tracks category-specific statistics
- **👤 User Stats Map**: Maintains per-user analytics
- **📊 Daily Counts Map**: Aggregates daily event metrics
- **🔬 Type Analytics Map**: Analyzes event types and patterns
- **🔔 Subscriptions Map**: Manages event monitoring subscriptions
- **📊 Aggregation Reports Map**: Stores generated time-based reports
- **⏰ Hourly Aggregations Map**: Real-time hourly activity summaries
- **📈 Trend Analysis Map**: Historical trend tracking and insights
- **🛡️ Event Schemas Map**: Defines validation rules for event types
- **✅ Schema Validations Map**: Tracks validation results and errors
- **🏷️ Tags Map**: Custom labels with metadata and usage statistics
- **🔗 Event-Tags Map**: Many-to-many relationships between events and tags
- **📊 Tag Events Map**: Reverse lookup for finding tagged events

### Event Structure

Each event contains:
- `event-type`: Type identifier (string-ascii 50)
- `user-address`: Address of the event creator
- `block-height`: Blockchain height when logged
- `timestamp`: Event timestamp
- `data`: Event payload (string-ascii 500)
- `category`: Event category (string-ascii 50)
- `severity`: Severity level (1-5)
- `indexed`: Indexing status (bool)

## 🔧 Testing

Run the test suite:
```bash
clarinet test
```

## 📊 Analytics Features

### 📈 Real-time Metrics
- Total events logged
- Events per user
- Category distributions
- Severity patterns
- Hourly activity rates
- Peak usage detection

### 🔍 Advanced Queries
- Filter by date range
- Search by severity level
- User activity tracking
- Category-based analytics
- Subscription monitoring
- Alert history tracking

### 📋 Automated Reporting
- **⏰ Hourly Reports**: Activity summaries every 100 blocks
- **📅 Daily Reports**: Comprehensive 24-hour analytics
- **📈 Trend Analysis**: Growth patterns and change detection
- **🎯 Performance Metrics**: Efficiency scoring and optimization insights
- **🔔 Subscription Analytics**: Alert trigger statistics and patterns

### 🔬 Business Intelligence
- **📊 Time-series Analysis**: Historical data visualization
- **🎯 Peak Usage Detection**: Identify high-traffic periods
- **📈 Growth Trending**: Track platform adoption and engagement
- **⚡ Efficiency Scoring**: Measure contract performance and usage

## 🛡️ Data Validation & Quality

### 📋 Schema Definition
- **🎯 Type Safety**: Define required fields and data types
- **📏 Length Constraints**: Min/max data length validation
- **🏷️ Category Restrictions**: Whitelist allowed categories
- **⚖️ Severity Bounds**: Configure acceptable severity ranges
- **🔄 Schema Versioning**: Track schema evolution over time

### ✅ Automatic Validation
- **🔍 Pre-logging Checks**: Events validated before storage
- **📊 Validation Tracking**: Complete audit trail of validation results
- **🚫 Invalid Event Blocking**: Malformed events rejected automatically
- **📈 Quality Metrics**: Track validation success rates and error patterns

### 🔧 Schema Management
- **👑 Owner Controls**: Admin-only schema creation and updates
- **⚡ Runtime Toggle**: Enable/disable validation without downtime
- **🎛️ Flexible Updates**: Modify constraints without recreation
- **🗑️ Schema Cleanup**: Remove obsolete schemas safely

## 🏷️ Dynamic Tagging System

### 📌 Tag Creation & Management
- **🎨 Custom Labels**: Create tags with names, colors, and descriptions
- **👥 User Ownership**: Per-user tag creation and management
- **📊 Usage Tracking**: Automatic counting of tag applications
- **🔄 Tag Lifecycle**: Activate/deactivate tags without deletion

### 🔗 Event Organization
- **🎯 Multi-tagging**: Attach up to 10 tags per event
- **⚖️ Weighted Tags**: Priority weights (1-5) for tag importance
- **🔍 Tag Search**: Find all events with specific tags
- **📈 Tag Analytics**: Track popular tags and usage patterns

### 💡 Advanced Features
- **🎨 Color Coding**: Visual organization with custom colors
- **📝 Rich Descriptions**: Detailed tag documentation
- **🚀 Popular Tags**: Discover trending labels
- **🔎 Tag Discovery**: Find tags by name or browse all

## 🛡️ Security Features

- **🔐 Owner-only Functions**: Administrative controls
- **⏸️ Emergency Pause**: Contract suspension capability
- **✅ Input Validation**: Comprehensive parameter checking
- **🚫 Access Control**: User-specific permissions

## 🚀 Advanced Usage

### Event Categories
Common categories include:
- `authentication`: Login/logout events
- `transaction`: Payment and transfer events
- `security`: Security-related events
- `user`: User actions and interactions
- `system`: System-level events

### Severity Levels
- `1`: Info - General information
- `2`: Low - Minor events
- `3`: Medium - Standard events
- `4`: High - Important events
- `5`: Critical - Critical events

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📜 License

MIT License - see LICENSE file for details

## 🔗 Links

- [Clarity Documentation](https://docs.stacks.co/clarity/)
- [Clarinet Documentation](https://docs.hiro.so/clarinet/)
- [Stacks Blockchain](https://www.stacks.co/)

---

Built with ❤️ using Clarity and Clarinet
