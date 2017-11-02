# Impac! - Maestrano Finance Bolt Changelog

### v1.0.0
- Daily granularity by default on Cashflow widgets
- Chart layout to return unix timestamps in series (replacing labels)
- Threshold KPI target currency conversion
- [IMPAC-644] Map Journals entities from Connec! (with journal lines)
- Build cash widgets based on journal lines totals instead of `TotalsPerAccounts` aggregates
- Create `ParentEntity` helper class to facilitate the fetching of parent entities during mapping
- Build spec helpers for entities

### v0.4.0
- Format headers for Cash Balance widget ("Cash on Hand" instead of "CASHONHAND")
- Add Kpis#show endpoint
- KPIs targets to return index of trigger interval
- Use SparkPost to send email alerts

### v0.3.1
- Limit max number of Sidekiq concurrent jobs to 50
- Optimise entities creation ActiveRecord query
- Silence entities parameters from the logs

### v0.3
- Add Multi-currency support
- Handle notifications asynchronously
- Compute KPIs after all notifications received (configurable delay)
- Code styling changes

### v0.2
- Add Cash Balance widget
- Add Cash Projection widget
- Create local Datamodel based on Connec! entities or aggregates
- Add notifications endpoint
- Configure MySQL DB, which is fed on reception of notifications
- Warden authentication using Impac private keys
- Add Cash Projection KPI
- Recalculate KPIs on notification reception and send alerts
- Add API documentation

### v0.1
Implements base logic, including:
- `api/v1/widgets` endpoint
- Base widget with layouts support and validations
- Layouts rendering
- Connec! reports requester
- HistParameter helper model
- Full testing / coding practices suite
