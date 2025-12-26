## Transactional Emails

Transactional emails are essential for user engagement and operational communication. MySaaS simplifies their setup and management.

- [1. Configuring the transport and branding](#1-configuring-the-transport-and-branding)
- [2. Registering followup descriptors](#2-registering-followup-descriptors)
- [3. Running the delivery loop](#3-running-the-delivery-loop)
- [4. Tracking opens and clicks](#4-tracking-opens-and-clicks)
- [5. Sample outreach followups](#5-sample-outreach-followups)

### 1. Configuring the transport and branding

Before any notification runs, call `BlackStack::Emails.set` with the SMTP credentials.

```ruby
BlackStack::Emails.set(
	sender_email: 'no-reply@yourdomain.com',
	from_email: 'Bryce <support@yourdomain.com>',
	from_name: 'Your Company',
	smtp_url: 'smtp.mailserver.com',
	smtp_port: 587,
	smtp_user: 'smtp-user',
	smtp_password: 'smtp-password',
	tracking_domain_protocol: 'https',
	tracking_domain_tld: 'tracking.yourdomain.com',
	tracking_domain_port: 443
)
```

### 2. Registering followup descriptors

Each followup descriptor passed to `BlackStack::Notifications.add` describes a notification type: the dataset to scan (`:objects`), the recipient helper (`:user`, `:email_to`, `:name_to`), the message body (`:body`), the subject generator (`:subject`), optional tracking flags, and any cleanup hook (`:after_deliver`) that should run once the email is enqueued (`slave/lib/notifications.rb#L69-L104`).

The `:objects` proc must return a Sequel dataset/array so the notifier can call `call().all` and iterate each row. `:body` and `:subject` are invoked per row, so you can safely query related tables and even load extensions for rendering HTML variations (`slave/extensions/mass.subaccount/MySaaSFile#L399-L586`). Keep `:track_opens` or `:track_clicks` set to `false` only when you explicitly skip tracking for that followup; otherwise the defaults are `true`.

```ruby
BlackStack::Notifications.add(
	{
		name: 'outreach_pending_approval',
		type: OUTREACH_PENDING_APPROVAL,
		track_opens: false,
		track_clicks: false,
		objects: Proc.new { DB[...] },
		user: Proc.new { |o| ... },
		email_to: Proc.new { |o| ... },
		subject: Proc.new { |o| ... },
		body: Proc.new { |o| ... },
		after_deliver: Proc.new { |o| ... }
	}
)
```
