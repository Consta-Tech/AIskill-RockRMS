# Cron Expressions in Rock RMS

Rock uses **Quartz-style cron expressions** to define recurring schedules for Service Jobs. These follow a 7-field format that extends standard Unix cron with a Seconds field and a Year field.

When entering a cron expression in Rock's Service Job editor, a human-readable preview updates as soon as you leave the input field, allowing you to verify the expression before saving.


## Field Reference

A Quartz cron expression consists of 7 fields separated by spaces:

```
Seconds  Minutes  Hours  DayOfMonth  Month  DayOfWeek  Year
```

| Position | Field        | Required | Allowed Values    | Allowed Special Characters |
|----------|--------------|----------|-------------------|----------------------------|
| 1        | Seconds      | Yes      | 0 -- 59           | `, - * /`                  |
| 2        | Minutes      | Yes      | 0 -- 59           | `, - * /`                  |
| 3        | Hours        | Yes      | 0 -- 23           | `, - * /`                  |
| 4        | Day of Month | Yes      | 1 -- 31           | `, - * ? / L W`            |
| 5        | Month        | Yes      | 1 -- 12 or JAN -- DEC | `, - * /`              |
| 6        | Day of Week  | Yes      | 1 -- 7 or SUN -- SAT | `, - * ? / L #`          |
| 7        | Year         | No       | 1970 -- 2099      | `, - * /`                  |

**Day-of-week numbering:** 1 = SUN, 2 = MON, 3 = TUE, 4 = WED, 5 = THU, 6 = FRI, 7 = SAT.
Three-letter abbreviations (SUN, MON, etc.) also work and are easier to read at a glance.

**Year field:** Can be omitted entirely, but including `*` is common practice (e.g., `0 0 0 * * ? *`).


## Special Characters

| Character | Name      | Applies To                    | Meaning                                                                   |
|-----------|-----------|-------------------------------|---------------------------------------------------------------------------|
| `*`       | All       | Any field                     | Every possible value for that field                                       |
| `?`       | No value  | Day of Month, Day of Week     | "No specific value" -- used when the other day field carries the intent    |
| `-`       | Range     | Any field                     | A continuous range (e.g., `MON-FRI`, `9-17`)                              |
| `,`       | List      | Any field                     | A set of specific values (e.g., `MON,WED,FRI`)                            |
| `/`       | Increment | Any field                     | Start value / step size (e.g., `0/15` means starting at 0, every 15)      |
| `L`       | Last      | Day of Month, Day of Week     | Last day of the month, or last X-day of the month (e.g., `6L` = last Friday) |
| `W`       | Weekday   | Day of Month only             | Nearest weekday to the given day (e.g., `15W` = nearest weekday to the 15th) |
| `#`       | Nth       | Day of Week only              | Nth occurrence of a weekday in the month (e.g., `6#3` = third Friday)     |


### The `?` Rule

Quartz requires exactly one of the two "day" fields (Day of Month or Day of Week) to be `?`. You cannot use `*` in both.

- Schedule targets **specific days of the week** --> put `?` in Day of Month
- Schedule targets **specific dates**, or runs **every day** --> put `?` in Day of Week


### The `/` Increment Character

The format is `start/interval`:

- `0/15` in the Minutes field = minutes 0, 15, 30, 45
- `5/20` in the Minutes field = minutes 5, 25, 45

When the start value equals the field's minimum (0 for Minutes, 1 for Day of Month, etc.), the increment is equivalent to `*`. For example, `1/1` in Day of Month means "starting at day 1, every 1 day" -- identical to `*`. **Prefer `*` for clarity.**


## Common Expressions

| Expression                | Meaning                                        |
|---------------------------|------------------------------------------------|
| `0 0 0 * * ? *`          | Every day at midnight                          |
| `0 30 3 * * ? *`         | Every day at 3:30 AM                           |
| `0 0 * * * ? *`          | Every hour (at the top of each hour)           |
| `0 0/20 * * * ? *`       | Every 20 minutes                               |
| `0 0 6 ? * SUN *`        | Every Sunday at 6:00 AM                        |
| `0 0 8 ? * MON-FRI *`    | Weekdays at 8:00 AM                            |
| `0 0 0 1 * ? *`          | First day of every month at midnight           |
| `0 20 8 10 1 ? *`        | January 10 at 8:20 AM (fires once per year)    |
| `0 0/15 8-17 ? * MON-FRI *` | Every 15 min, 8 AM -- 5 PM, weekdays only   |


## Pitfalls

### 1. Don't forget the Seconds field

Unix cron uses 5 fields. Quartz uses 7. If you paste a 5-field expression into Rock, every field shifts and the expression will either fail or mean something completely different. Always start with `0` in the Seconds position.

```
Unix:       */5 * * * *             (every 5 minutes)
Quartz:   0 0/5 * * * ? *          (every 5 minutes)
```

### 2. One day field must be `?`

You cannot use `*` in both Day of Month and Day of Week. Exactly one must be `?`. If both are `*`, Rock will reject or misinterpret the expression.

### 3. Prefer `*` over `1/1`

Online examples often use patterns like `0 0/20 * 1/1 * ? *`. The `1/1` in Day of Month means "starting at 1, every 1" which is equivalent to `*`. The cleaner version is `0 0/20 * * * ? *`. The same applies to `0/1` in other fields.

### 4. Day-of-week: Sunday = 1, not 0

Quartz numbers days 1 (SUN) through 7 (SAT). This differs from Unix cron where Sunday is 0. Using three-letter abbreviations (`SUN`, `MON`, `FRI`, etc.) avoids this confusion entirely and is recommended.

### 5. Month numbering

Months are 1 -- 12 (January = 1). Three-letter abbreviations (`JAN`, `FEB`, etc.) work here too and help avoid off-by-one mistakes.
