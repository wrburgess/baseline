# Notification Feature Outline

You are an experienced full stack Ruby on Rails developer

We need to create a notification system for our application, a Rails 8.1.2 app named Optimus

We want to model it after the AWS SMS system, but it won’t be quite as involved as that application (or collection of services), but we like the Topic > Subscriber model/approach. That doesn't mean we have to use that pattern.

Analyze the system and its requirements below and let me know your first take on what we’re asking you to create:

1. Does this system make sense?
2. Does it follow the AWS SMS system (if that's a good path) or does it have noticeable gaps?
3. What are we missing on keeping the system flexible?
4. What are we missing that will require a lot of maintenance or issues?

# NotificationSystem

## Data and Code Structures

### NotificationService - Service Module
* Located at app/services

### NotificationTopic - Model
* name, string
* timestamps

### NotificationSubscription - Model
* References: NotificationTopic
* References: User
* distribution_method, string, required
* distribution_frequency, string, required
* summarized_daily_time, time
* timestamps

### NotificationQueue - Model
* References NotificationTopic
* References NotificationSubscription
* References: User
* distribute_at, datetime
* completed_at, datetime
* timestamps

### NotificationDistributionTypes - Module
* email
* sms
* chat

### NotificationDistributionFrequencyTypes - Module
* immediate
* summarized_hourly
* summarized_daily

## Requirements and Processes

* A NotificationTopic will be something named like “User Password Changed”
* A NotificationSubscription will be something where a User wishes to subscribe to notifications related to User Password Changed
* When a User Password is changed on the users_controller update action, it will need to trigger the NotificationTopic named “User Password Changed”
* All subscribers to the topic will receive the notification based on the following factors:
    * Delivery method of email, sms, or chat posting (we are only using email first)
    * Delivery frequency of immediate, summarized_hourly, summarized_daily
    * The subscriber can choose an actual time for the summarized_daily option
* We don’t need users to subscribe to the notifications themselves. Admins can set these up for users in the admin section

### Staff requirements

* An admin user needs to be able to access the NotificationSubscription table and make changes on behalf of users
* An admin needs to be able to access the table and know which users are subscribed to which topics
* An admin needs to be able to create topics, create subscriptions, and edit/change those same instances.
