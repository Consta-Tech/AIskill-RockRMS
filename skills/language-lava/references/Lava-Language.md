# Lava Reference

Rock RMS uses a custom templating language called **Lava**, forked from Shopify's Liquid. Lava is rendered server-side before the resulting HTML (or SQL, or other output) is processed by its respective engine.

> **Lava is NOT identical to Liquid.** Do not assume Liquid syntax works in Lava. This document is the authoritative reference for Lava as it behaves in Rock RMS.

Detailed documentation lives at https://community.rockrms.com/lava and its subpages.


---


## Syntax Basics

Lava has three fundamental syntax patterns:

| Syntax | Purpose | Example |
|--------|---------|---------|
| `{% ... %}` | Computing operations (tags, commands, logic) | `{% for row in myArray %}` |
| `{{ ... }}` | Output (rendering values) | `{{ Person.FullName }}` |
| `{[ ... ]}` | Shortcodes (reusable snippets/functions) | `{[ RootLocationId locationid:'111111' ]}` |

All other Lava syntax is built upon these three patterns. For a full reference on ShortCodes — how they work, authoring rules, and the built-in form controls — see `Lava-ShortCodes.md`.


### Rendering Order

When Lava is mixed with other languages in a template:

1. **Lava + HTML** — Lava is computed server-side first, producing pure HTML that the browser renders second.
2. **Lava + SQL** — Lava is computed first, producing pure T-SQL that the SQL engine executes second.


---


## Lava Filters

Filters transform a value using the pipe (`|`) operator. They can be chained: `{{ value | FilterA | FilterB }}`.


### Text Filters

#### Append

Appends a string to the end of the input.

Example Input:
```
"Person": {
    "FirstName": "Ted",
    "LastName": "Decker",
    "FullName": "Ted Decker"
}
```
Example Lava:
```
{{ Person.FirstName | Append:' have a great day!' }}
```
Example Output:
```
Ted have a great day!
```

#### Capitalize

Capitalizes the first letter of each word.

Example Input:
```
"Person": {
    "FullName": "ted decker"
}
```
Example Lava:
```
{{ Person.FullName | Capitalize }}
```
Example Output:
```
Ted Decker
```

#### Default

Returns a fallback value if the input is null or empty.

Example Input:
```
"Person": {
    "FullName": "Ted Decker",
    "AnniversaryDate": ''
}
```
Example Lava:
```
Anniversay Date: {{ Person.AnniversaryDate | Default:'(none)' }}
```
Example Output:
```
Anniversay Date: (none)
```

#### Downcase

Converts the entire string to lowercase.

Example Input:
```
"Person": {
    "FullName": "Ted Decker"
}
```
Example Lava:
```
{{ Person.FullName | Downcase }}
```
Example Output:
```
ted decker
```

#### Encrypt / **Decrypt**

Encrypts a string using the Rock instance's DataEncryptionKey. Decryption requires the matching key. The encryption includes an initialization vector (IV) so repeated calls produce different output for the same input.

Example Lava:
```
{% assign encryptedText = 'This is my secret!' | Encrypt %}
<p>The encrypted message is: {{ encryptedText }}</p>
{% assign decryptedText = encryptedText | Decrypt %}
<p>The decrypted message is: {{ decryptedText }}</p>
```
Example Output:
```
The encrypted message is: EAAAACRNk6LPcaap5MAIHV2+8ld/IzM2sLbG8PdcGNBDtJN5
The decrypted message is: This is my secret!
```

#### Escape

HTML-encodes a string. All `<tags>` become `&lt;tags&gt;`.

Example Input:
```
"Workflow": {
    "HtmlExample": "<span class='label label-success'>Approved</span>"
}
```
Example Lava:
```
{{ Workflow.HtmlExample | Escape }}
```
Example Output:
```
&lt;span class=&#39;label label-success&#39;&gt;Approved&lt;/span&gt;
```

#### EscapeDataString (aka **UrlEncode**)

Converts a string to its URL-encoded representation using `Uri.EscapeDataString`. Available as either filter name as of v8.

Example Input:
```
"CurrentPerson": {
    "NickName": "Ted"
    ...
}

"Context": {
    "Campus": {
        "Name": "Jackson Hole"
        ...
    }
}
```
Example Lava:
```
<a href="mailto:?subject=Welcome&body={{ body | EscapeDataString }}">Email</a>
```
Example Output:
```
<a class="btn btn-default" href="mailto:?subject=Welcome&body=You%20are%20invited%20to%20go%20to%20Fun%20Event%20with%20me%20at%20the%20Jackson%20Hole%20campus.%0AWanna%20Go%3F%20There%20will%20be%20lots%20of%20fun%20stuff%20to%20do!%0A%0AYour%20friend%2C%0A%0ATed">Email</a>
```

#### EscapeOnce

HTML-encodes a string without double-encoding existing encoded entities.

Example Lava:
```
{% assign unescaped = "Have you read 'The Lion, The Witch & the Wardrobe by C.S. Lewis'?" %}
{% assign escaped = unescaped | Escape %}
Source Text: {{ unescaped }}
Applying the Escape filter twice to the source text:
{{ unescaped | Escape | Escape }}
Applying the EscapeOnce filter twice to the source text:
{{ unescaped | EscapeOnce | EscapeOnce }}
```
Example Output:
```
Source Text: Have you read 'The Lion, The Witch & the Wardrobe by C.S. Lewis'?
Applying the Escape filter twice to the source text:
Have you read &amp;#39;The Lion, The Witch &amp;amp; the Wardrobe by C.S. Lewis&amp;#39;?
Applying the EscapeOnce filter twice to the source text:
Have you read &#39;The Lion, The Witch &amp; the Wardrobe by C.S. Lewis&#39;?
```

#### FromMarkdown

Converts a Markdown string to HTML.

Example Input:
```
"ContentChannelItem": {
    "Summary": "# Lorem Ipsum
## Lorem ipsum dolor sit amet
- Lorem ipsum dolor sit amet
- consectetur adipiscing elit
- sed do eiusmod tempor incididunt ut labore et dolore magna aliqua
";
}
```
Example Lava:
```
{{ ContentChannelItem.Summary | FromMarkdown }}
```
Example Output:
```
<h1>Lorem Ipsum</h1>
<h2>Lorem ipsum dolor sit amet</h2>
<ul>
  <li>Lorem ipsum dolor sit amet</li>
  <li>consectetur adipiscing elit</li>
  <li>sed do eiusmod tempor incididunt ut labore et dolore magna aliqua</li>
</ul>
```

#### HtmlDecode

Decodes an HTML-encoded string.

Example Input:
```
"Workflow": {
    "Name": "This &amp; That"
}
```
Example Lava:
```
This workflow is called '{{ Workflow.Name | HtmlDecode }}'.
```
Example Output:
```
This workflow is called 'This & That'.
```

#### Humanize

Converts computer-friendly strings (camelCase, underscore_case, css-classes) to human-readable text.

Example Input:
```
"Workflow": {
    "AssemblyName": "MandrillSmtp"
}
```
Example Lava:
```
This workflow is using the '{{ Workflow.AssemblyName | Humanize }}'
component.
```
Example Output:
```
This workflow is using the 'Mandrill Smtp'
component.
```

#### Linkify

Converts URLs in text into HTML anchor (`<a>`) elements.

Example Input:
```
"Item": {
    "Text": "Go to http://www.rockrms.com for more details"
}
```
Example Lava:
```
{{ Item.Text | Linkify }}
```
Example Output:
```
Go to <a href="http://www.rockrms.com " target="_blank">http://www.rockrms.com </a> for more details
```

#### NewlineToBr

Inserts `<br />` tags (with a space, self-closing slash) before all newlines. The space matters when downstream code does `Replace:'<br />'` to undo the conversion — `Replace:'<br/>'` (no space) silently no-ops.

Example Input:
```
"Workflow": {
    "Notes": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean sodales, metus id viverra semper, nibh ipsum porttitor nibh, in luctus nulla eros non sapien. Vivamus efficitur cursus condimentum.

Ut blandit felis vitae nunc feugiat euismod. Aliquam quam urna, malesuada eu rutrum et, porttitor quis nisl. In congue pulvinar euismod."
}
```
Example Lava:
```
<div>{{ Workflow.Note | NewlineToBr }} </div>
```
Example Output:
```
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean sodales, metus id viverra semper, nibh ipsum porttitor nibh, in luctus nulla eros non sapien. Vivamus efficitur cursus condimentum. <br />
<br />
Ut blandit felis vitae nunc feugiat euismod. Aliquam quam urna, malesuada eu rutrum et, porttitor quis nisl. In congue pulvinar euismod."
```

#### ObfuscateEmail

Partially hides an email address.

Example Input:
```
"Person": {
    "Email": "ted@rocksolidchurchdemo.com"
}
```
Example Lava:
```
An email has been sent to {{ Person.Email | ObfuscateEmail }}.
```
Example Output:
```
An email has been sent to txxxxx@rocksolidchurchdemo.com.
```

#### Pluralize

Pluralizes the input word, handling irregular forms (e.g., "man" → "men").

Example Input:
```
"Workflow": {
    "WorkTerm": "Request"
}
```
Example Lava:
```
There are many {{ Workflow.WorkTerm | Pluralize | Downcase }} in the system.
```
Example Output:
```
There are many requests in the system.
```

#### PluralizeForQuantity

Pluralizes only if the quantity is greater than 1.

Example Input:
```
"Group": {
    "Leaders": [
        {
            "Id": 12,
            "Name": "Ted Decker"
        },
        {
            "Id": 14,
            "Name": "Alisha Marble"
        }
    ]
}
```
Example Lava:
```
{% assign leaderCount = Group.Leaders | Size %}

{{ 'Leader' | PluralizeForQuantity:leaderCount }}: {{ leaderCount }}
```
Example Output:
```
Leaders: 2
```

#### Possessive

Returns the possessive form of a string.

Example Input:
```
"Person": {
    "NickName": "Ted"
}

"Person": {
    "NickName": "Charles"
}
```
Example Lava:
```
{{ Person.NickName | Possessive }} Group
```
Example Output:
```
Ted's Group - Charles' Group
```

#### Prepend

Prepends a string to the beginning of the input.

Example Input:
```
"Person": {
    "NickName": "Ted"
}
```
Example Lava:
```
<strong>{{ Person.NickName | Prepend:'Hello ' }}!</strong>
```
Example Output:
```
<strong>Hello Ted!</strong>
```

#### ReadTime

Estimates reading time for a string. Optional parameters: `{WordsPerMinute}` (default 275), `{SecondsPerImage}` (default 12). Results formatted as "1 hr 23 mins", "23 mins", or "30 secs".

Example Input:
```
"Item": {
    "Content": "The quick brown fox jumps over the lazy dog."
}
```
Example Lava:
```
{{ Item.Content | ReadTime:275,12 }}
```
Example Output:
```
2 secs
```

#### RegExMatch

Tests input against a regex; returns a boolean.
- If your expression contains `{` or `}` or non-valid escape sequences (e.g. `\r`, `\n`, `\s`, `\d`, `\w`), capture the expression into a variable first. **This rule applies to every regex filter in this section** — `RegExMatch`, `RegExMatchValue`, `RegExMatchValues`, and `RegExReplace`. Symptom of violating it: a parse error of the form `End of tag '%}' was expected at (line:col)`, where the column points at the next `:`, `|`, or `%}` after the offending string literal.

Example Lava:
```
{% capture expression %}\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*{% endcapture %}
{% assign isValidEmail = CurrentPerson.Email | RegExMatch: expression %}

{% if isValidEmail == true %}
    This is a valid email!
{% endif %}
```
Example Output:
```
This is a valid email!
```

#### RegExMatchValue

Returns the first matching substring, or nothing if no match.

Example Lava:
```
{% capture expression %}\d+{% endcapture %}
{% assign message = "group 12345" %}

{% assign groupId = message | RegExMatchValue: expression %}
{{ groupId }}
```
Example Output:
```
12345
```

#### RegExMatchValues

Returns an array of all matching substrings.

Example Lava:
```
{% capture expression %}\b\w+day\b{% endcapture %}
{% assign days = "Services on Saturday and Sunday" | RegExMatchValues: expression %}
Found {{ days | Size }} matches:
{% for day in days %}
 {{ day }}
{% endfor %}
```
Example Output:
```
Found 2 matches: Saturday Sunday
```

#### RegExReplace

Replaces matches of a regex pattern. Parameters: `pattern`, `replacement`, optional `flags` (`i` = case-insensitive, `m` = multiline). Back-references use .NET syntax (`$1` instead of `\1`).
- Same parser limitation as `RegExMatch` above: if the pattern contains `{`, `}`, or non-valid escape sequences (`\r`, `\n`, `\s`, `\d`, `\w`, etc.), hoist it into a `{% capture %}` first — inline string literals will trip the tag tokenizer.

Example Input:
```
"Message": "Hello Ted, how are you?"
```
Example Lava:
```
{{ 'The Rock is awesome.' | RegExReplace:'the rock','Rock','i' }}
{% capture expression %}[Hh]ello (\w+){% endcapture %}
{{ Message | RegExReplace: expression,'Greetings $1' }}
```
Example Output:
```
Rock is awesome.
Greetings Ted, how are you?
```

#### Remove

Removes all occurrences of a string (case-sensitive).

Example Input:
```
"Workflow": {
    "Note": "We Will We Will Rock You"
}
```
Example Lava:
```
<strong>{{ Workflow.Note | Remove:'We Will' }}</strong>
```
Example Output:
```
<strong>Rock You</strong>
```

#### RemoveFirst

Removes the first occurrence of a string (case-sensitive).

Example Input:
```
"Workflow": {
    "Note": "We Will we will Rock You"
}
```
Example Lava:
```
<strong>{{ Workflow.Note | RemoveFirst:'we will' }}</strong>
```
Example Output:
```
<strong>We Will Rock You</strong>
```

#### Replace

Replaces all occurrences of a string (case-sensitive).

Example Input:
```
"Workflow": {
    "Note": "We Will We Will Rock You"
}
```
Example Lava:
```
<strong>{{ Workflow.Note | Replace:'We Will','Rock Will' }}</strong>
```
Example Output:
```
<strong>Rock Will Rock Will Rock You</strong>
```

#### ReplaceFirst

Replaces the first occurrence of a string (case-sensitive).

Example Input:
```
"Workflow": {
    "Note": "We Will We Will Rock You"
}
```
Example Lava:
```
<strong>{{ Workflow.Note | ReplaceFirst:'We Will', 'Rock Will' }}</strong>
```
Example Output:
```
<strong>Rock Will We Will Rock You</strong>
```

#### ReplaceLast

Replaces the last occurrence of a string (case-sensitive).

Example Input:
```
"Workflow": {
    "Note": "Red, White, Blue"
}
```
Example Lava:
```
<strong>{{ Workflow.Note | ReplaceLast:',', ' and' }}</strong>
```
Example Output:
```
<strong>Red, White and Blue</strong>
```

#### Right

Returns the right-most characters of a string.

Example Input:
```
"CurrentPerson": {
    "LastName": "Decker"
}
```
Example Lava:
```
The last four letters are '{{ CurrentPerson.LastName | Right:4 }}'.
```
Example Output:
```
The last four letters are 'cker'.
```

#### SanitizeSql

Escapes single quotes for safe use in SQL statements. The sanitized value should always be placed inside single quotes in the query. For numeric user input, consider `AsInteger` instead.

Example Input:
```
"CurrentPerson": {
    "LastName": "O'Neal"
}
```
Example Lava:
```
{% sql %}
    SELECT [FirstName]
    FROM [Person]
    WHERE [LastName] = '{{ CurrentPerson.LastName | SanitizeSql }}'
{% endsql %}

<p>Used sanitized string {{ CurrentPerson.LastName | SanitizeSql }} to find these names.</p>
<ul>
    {% for item in results %}
        <li>{{ item.FirstName }}</li>
    {% endfor %}
</ul>
```
Example Output:
```
<p>Used sanitized string O''Neal to find these names.</p>
<ul>
    <li>Jack</li>
</ul>
```

#### SentenceCase

Converts to sentence case (first word capitalized, rest lowercase).

Example Input:
```
"Workflow": {
    "ArticleTitle": "Good To Great"
}
```
Example Lava:
```
{{ Workflow.ArticleTitle | SentenceCase }}.
```
Example Output:
```
Good to great.
```

#### Singularize

Makes plural words singular, handling irregulars (e.g., "women" → "woman").

Example Input:
```
"Workflow": {
    "ConnectionStatusType": "Members"
}
```
Example Lava:
```
Ted is a {{ Workflow.ConnectionStatusType | Singularize | Downcase }}.
```
Example Output:
```
Ted is a member.
```

#### Size

(On strings) Returns the character count including spaces.

Example Input:
```
"Person": {
    "FullName": "Ted Decker"
}
```
Example Lava:
```
{% assign nameLength = Person.FullName | Size %}

{% if nameLength < 8 %}
	{{ Person.FullName }}
{% else %}
	{{ Person.FullName | Truncate:8 }}
{% endif %}
```
Example Output:
```
Ted D...
```

#### Slice

(On strings) Returns a substring starting at a given index. Optional second parameter for length; defaults to 1 character.

Example Input:
```
"Person": {
    "SecurityCode": "GX925"
}
```
Example Lava:
```
First two characters '{{ Person.SecurityCode | Slice: 0, 2 }}'
and the last three characters '{{ Person.SecurityCode | Slice: 2, 3 }}'.
```
Example Output:
```
First two characters 'GX' and the last three characters '925'.
```

#### Split

Splits a string into an array. Parameters: `{Pattern}`, `{RemoveEmpty}` (default true), `{Maximum}`.

Example Input:
```
"Person": {
    "Email": "ted@rocksolidchurchdemo.com"
}

"Item": {
    "Title": "Topic: Man vs 10:00"
}
```
Example Lava:
```
//- Simple example
{% assign emailParts = CurrentPerson.Email | Split:'@' %}
Your email domain is: {{ emailParts[1] }}.

//- Split with Maximum option
{% assign stringParts = item.Title | Split:':', 2 %}
The first part is: {{ stringParts[0] }}
The second part is: {{ stringParts[1] }}

//- Split with Remove Empty false and Maximum option
{% assign itemsList = "A,B,,D,E,F,G" | Split:',', false, 4 %}
The first part is: {{ itemsList[0] }}
The second part is: {{ itemsList[1] }}
The third part is: {{ itemsList[2] }}
The fourth part is: {{ itemsList[3] }}
```
Example Output:
```
Your email domain is: rocksolidchurchdemo.com.

The first part is: Topic
The second part is: Man vs 10:00

The first part is: A
The second part is: B
The third part is:
The fourth part is: D,E,F,G
The fifth part is:
```

#### StripHtml

Removes all HTML tags.

Example Input:
```
"Workflow": {
    "Note": "<h1>Lorem Iipsum Dolor</h1> <p>Sit amet, consectetur adipiscing elit. Aenean sodales, metus id viverra semper.</p>"
}
```
Example Lava:
```
{{ Workflow.Note | StripHtml }}
```
Example Output:
```
Lorem Iipsum Dolor Sit amet, consectetur adipiscing elit. Aenean sodales, metus id viverra semper.
```

#### StripNewlines

Removes all newline characters (`\r\n`).

Example Input:
```
"Workflow": {
    "Notes": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean sodales, metus id viverra semper, nibh ipsum porttitor nibh, in luctus nulla eros non sapien. Vivamus efficitur cursus condimentum.

Ut blandit felis vitae nunc feugiat euismod. Aliquam quam urna, malesuada eu rutrum et, porttitor quis nisl. In congue pulvinar euismod."
}
```
Example Lava:
```
<div>{{ Workflow.Notes | StripNewlines }}</div>
```
Example Output:
```
<div>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean sodales, metus id viverra semper, nibh ipsum porttitor nibh, in luctus nulla eros non sapien. Vivamus efficitur cursus condimentum. Ut blandit felis vitae nunc feugiat euismod. Aliquam quam urna, malesuada eu rutrum et, porttitor quis nisl. In congue pulvinar euismod.</div>
```

#### TitleCase

Capitalizes the first letter of every word.

Example Input:
```
"Workflow": {
    "Name": "Job posting for groundskeeper"
}
```
Example Lava:
```
<h1>{{ Workflow.Name | TitleCase }}</h1>
```
Example Output:
```
<h1>Job Posting For Groundskeeper</h1>
```

#### ToCssClass

Converts a string to CSS class format.

Example Input:
```
"Person": {
    "ConnectionStatus": "Community Participant"
}
```
Example Lava:
```
<span class="{{ Person.ConnectionStatusValue.Value | ToCssClass }}">Label</span>
```
Example Output:
```
<span class="community-participant">Label</span>
```

#### ToPascal

Converts to PascalCase.

Example Input:
```
"Person": {
    "ConnectionStatus": "Community Participant"
}
```
Example Lava:
```
{{ Person.ConnectionStatus | ToPascal }}
```
Example Output:
```
CommunityParticipant
```

#### Trim

Removes whitespace (or a specified pattern) from both ends of a string. Trims recursively.

Example Lava:
```
<h1>Example 1:</h1>
<p>-{{ '  Ted Decker  ' | Trim }}-</p>
<hr>
<h1>Example 2:</h1>
<i>{{ '/*/*/*/Ted Decker//*/*/*' | Trim:'/*' }}</i>
```
Example Output:
```
<h1>Example 1</h1>
<p>-Ted Decker-</p>
<hr>
<h1>Example 2</h1>
<p>/Ted Decker/</p>
```

#### TrimEnd

Same as Trim but only on the trailing end.

Example Lava:
```
<h1>Example 1:</h1>
<p>-{{ '  Ted Decker  ' | TrimEnd }}-</p>
<hr>
<h1>Example 2:</h1>
<i>{{ '/*/*/*/Ted Decker//*/*/*' | TrimEnd:'/*' }}</i>
```
Example Output:
```
<h1>Example 1</h1>
<p>-  Ted Decker-</p>
<hr>
<h1>Example 2</h1>
<p>/*/*/*/Ted Decker/</p>
```

#### TrimStart

Same as Trim but only on the leading end.

Example Lava:
```
<h1>Example 1:</h1>
<p>-{{ '  Ted Decker  ' | TrimStart }}-</p>
<hr>
<h1>Example 2:</h1>
<i>{{ '/*/*/*/Ted Decker//*/*/*' | TrimStart:'/*' }}</i>
```
Example Output:
```
<h1>Example 1</h1>
<p>-Ted Decker   -</p>
<hr>
<h1>Example 2</h1>
<p>/Ted Decker//*/*/*</p>
```

#### Truncate

Shortens to a given length, appending an optional suffix (default `...`). The suffix length counts toward the total.

Example Input:
```
"Person": {
    "FullName": "Ted Decker"
}
```
Example Lava:
```
<small>{{ Person.FullName | Truncate:9,'...' }}</small>
```
Example Output:
```
<small>Ted De...</small>
```

#### TruncateWords

Shortens to a given word count, appending an optional suffix (default `...`).

Example Input:
```
"Workflow": {
    "Note": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce hendrerit odio ut ex pretium laoreet. In ac viverra urna. Nunc consectetur vulputate leo tincidunt porta."
}
```
Example Lava:
```
<p>{{ Workflow.Note | TruncateWords:7 }}</p>
```
Example Output:
```
<p>Lorem ipsum dolor sit amet, consectetur adipiscing...</p>
```

#### UnescapeDataString (aka **UrlDecode**)

URL-decodes a string.

Example Input:
```
Consider the URL:
http://www.rocksolidchurchdemo.com/page/12?EventTitle=Hello%20There
```
Example Lava:
```
{{ 'Global' | PageParameter:'EventTitle' | UnescapeDataString }}
```
Example Output:
```
Hello There
```

#### Upcase

Converts to uppercase.

Example Input:
```
"Person": {
    "FullName": "Ted Decker"
}
```
Example Lava:
```
<h1>{{ Person.FullName | Upcase }}</h1>
```
Example Output:
```
<h1>TED DECKER</h1>
```

#### WithFallback

Appends success text if non-empty, or uses fallback text if empty. Optional third parameter `'append'` changes prepend to append order (v7.4+).

Example Input:
```
"CurrentPerson": {
    "FirstName": "Theodore",
    "NickName": "Ted"
}

"CurrentPerson": {
    "FirstName": "Timoteo",
    "NickName": ""
}
```
Example Lava:
```
{{ CurrentPerson.NickName | WithFallback:', are', 'Are', 'append' }} you interested in baptism?
```
Example Output:
```
Ted, are you interested in baptism?

Are you intersted in baptism?
```


### Date Filters

These filters require a date-value as input. Use the keyword `'Now'` for the current datetime.

#### AsDateTimeUtc

Converts the input to a DateTime value in Coordinated Universal Time (UTC). If the input date doesn't specify an offset, the current Rock application timezone is assumed.
Example Lava:
```
{{ '2018-05-02T03:00:00+04:00' | AsDateTimeUtc | Date:'yyyy-MM-ddTHH:mm:sszzz' }}
```
Example Output:
```
2018-05-01T23:00:00+00:00
```

#### Date

Displays the date given a format string. The keyword `'Now'` can be used for the current datetime value.
- Date elements:
- `sd` - Returns the culture's standard shortened date format (m/d/yyyy in the US)
- `d` - Day of the month 1 - 31.
- `dd` - Two digit day of the month 01 - 31.
- `ddd` - Abbreviated day of the week (Mon, Tue, etc.)
- `dddd` - Full day of the week (Monday, Tuesday, etc.)
- `M` - The month, from 1 through 12
- `MM` - The month, from 01 through 12
- `MMM` - The abbreviated name of the month (Jan, Feb, etc.)
- `MMMM` - The full name of the month
- `yy` - The year, from 00 to 99
- `yyyy` - The year as a four-digit number
- Time elements:
- `st` - Returns the culture's standard shortened time format (h:mm am/pm in the US)
- `h` - The hour, using a 12-hour clock from 1 to 12
- `hh` - The hour, using a 12-hour clock from 01 to 12
- `H` - The hour, using a 24-hour clock from 0 to 23
- `HH` - The hour, using a 24-hour clock from 00 to 23
- `m` - The minute, from 0 through 59
- `mm` - The minute, from 00 through 59
- `s` - The second, from 0 through 59
- `ss` - The second, from 00 through 59
- `tt` - The AM/PM designator
- When the date is going to be saved to the database as an attribute value, we recommend you use the ISO standard format `yyyy-MM-ddTHH:mm:ss.fffzzz`
Example Input:
```
"Person": {
    "FirstVisit": "2/13/2011 8am"
}
```
Example Lava:
```
Ted's first visit was on {{ Person | Attribute:'FirstVisit' | Date:'dddd, MMMM d, yyyy' }}.
```
Example Output:
```
Ted's first visit was on Sunday, February 13, 2011.
```

#### DateAdd

Adds a span of time to a provided date. By default this filter assumes the amount you pass is in days. You can also pass other intervals as a second parameter.
- Valid units:
- `y` - Years
- `M` - Months
    - When adding months and years, if you are going from one month with more days than the target month, the day number will be reduced to fit within the new target month.
- `w` - Weeks
    - Adding weeks is simply a shorthand for adding by 7 days at a time
- `d` - Days
- `h` - Hours
- `m` - Minutes
- `s` - Seconds
Example Input:
```
"CurrentPerson": {
    "FirstVisit": "2/14/2011"
}
```
Example Lava:
```
Your first visit was {{ CurrentPerson | Attribute:'FirstVisit' }}. Two weeks later would be {{ CurrentPerson | Attribute:'FirstVisit' | DateAdd:14 }}.
```
Example Output:
```
Your first visit was 2/14/2011. Two weeks later would be 2/28/2011.
```

#### DateDiff

Takes two datetimes and returns the difference in the unit you provide.
- Valid units:
- `y` - Years
- `M` - Months
    - When adding months and years, if you are going from one month with more days than the target month, the day number will be reduced to fit within the new target month.
- `w` - Weeks
    - Adding weeks is simply a shorthand for adding by 7 days at a time
- `d` - Days
- `h` - Hours
- `m` - Minutes
- `s` - Seconds
- If the start date is after the end date a negative number will be displayed.
- Note: The difference in days between January 1st at 11:59pm and January 2nd at 12:01am is 0 days, while the difference between January 1st and January 2nd (without the time portion) is 1 day.
Example Input:
```
"Person": {
    "FirstVisit": "2/14/2011",
    "SecondVisit": "3/18/2011"
}
```
Example Lava:
```
It was {{ Person.FirstVisit | DateDiff:Person.SecondVisit,'d' }}
days between {{ Person.NickName }} first and second visit.
```
Example Output:
```
It was 32 days between Ted's first and second visit.
```

#### DateRangeFromSlidingFormat

Converts a sliding date range format string (e.g., from the Sliding Date Range control) into start/end dates.
Example Lava:
```
{% assign range = 'Previous|2|Week||' | DateRangeFromSlidingFormat %}
{{ range.StartDate }} - {{ range.EndDate }}
```
Example Output:
```
3/28/2022 12:00:00 AM - 4/10/2022 11:59:59 PM
```

#### DatesFromICal

Returns a list of upcoming dates from an iCal string or List of iCal strings.
- The first parameter is optional and it's the number of occurrences to display.
- The default is 1.
- A text value of 'All' can also be used to return all the occurrences (up to one year's worth).
- The second parameter is optional and controls whether to return the EndTime property of the iCal's occurrence.
- The default behavior returns the StartTime.
- This is a complex filter. The example below uses a portion of the input from the 'Calendar Items' lava file. It's only a sample and may need some changes to work correctly. See the CalendarItem.lava file in the themes folders for a working example.
Example Input:
```
"EventItemCampuses": {
    [
        {
            "ContactEmail": "jenny@rocksolidchurchdemo.com",
            "EventItemSchedules": [
                {
                    "Schedule": {
                        ... ,
                        "iCalendarContent": "BEGIN:VCALENDAR VERSION:2.0 PRODID:-//ddaysof...",
                        ... ,
                    }
                }
            ]
        }
    ]
}
```
Example Lava:
```
{% assign upcomingDates =  EventItemSchedules | Select:'Schedule' | Select:'iCalendarContent' | DatesFromICal:2 %}

<ul>
{% for date in upcomingDates %}
<li>{{ date }}</li>
{% endfor %}
</ul>

{% assign upcomingEndDates =  EventItemSchedules | Select:'Schedule' | Select:'iCalendarContent' | DatesFromICal:2,'enddatetime' %}

<ul>
{% for endDate in upcomingEndDates %}
<li>{{ endDate }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>7/15/2015 7:00:00 PM</li>
<li>7/16/2015 7:00:00 PM</li>
</ul>

<ul>
<li>7/15/2015 8:00:00 PM</li>
<li>7/16/2015 8:00:00 PM</li>
</ul>
```

#### DaysFromNow

Returns a humanized string of the number of days from now without concern for time.
Example Input:
```
"Person": {
    "FirstVisit": "2/14/2015",
}
```
Example Lava:
```
Visited {{ Person.FirstVisit | DaysFromNow }}.
```
Example Output:
```
Visited 14 days ago.
```

#### DaysInMonth

Returns the number of days in the month you provide.
- There are various options on how to provide the month/year combination to check for. Valid methods include:
- `{{ 'Now' | DaysInMonth }}` - Get the days in the current month/year.
- `{{ '2/1/2017' | DaysInMonth }}` - Get the days in the date provided.
- `{{ '' | DaysInMonth:'02','2016' }}` - Get the days based on the month/year provided.
Example Lava:
```
There are {{ 'Now' | DaysInMonth }} days in the current month.
```
Example Output:
```
There are 31 days in the current month.
```

#### DaysSince

Returns the number of days that have passed since a given date.
Example Input:
```
"Person": {
    "FullName": "Ted Decker",
    "AnniversaryDate": '12/23/1995',
}
```
Example Lava:
```
{{ Person.NickName }} was married {{ Person.AnniversaryDate | DaysSince }} days ago.
```
Example Output:
```
Ted was married 8215 days ago.
```

#### DaysUntil

Returns the number of days from now.
Example Input:
```
"Person": {
    "FullName": "Ted Decker",
    "StaffSabbatical": '5/10/2020',
}
```
Example Lava:
```
{{ Person.NickName }} can take a sabbatical in {{ Person | Attribute:'StaffSabbatical' | DaysUntil }} days.

There are just {{ '12/25/2018' | DaysUntil }} days until Christmas at Rock Solid Church.
```
Example Output:
```
Ted can take a sabbatical in 690 days.

There are just 188 days until Christmas at Rock Solid Church.
```

#### HumanizeDateTime

Compares the provided date/time to the current date/time and returns a human friendly string like 'yesterday' or '2 hours ago' or 'tomorrow' or '2 hours from now'.
Example Input:
```
"Person": {
    "FullName": "Ted Decker",
    "AnniversaryDate": '12/23/1995',
}
```
Example Lava:
```
{{ Person.NickName }} was married {{ Person.AnniversaryDate | HumanizeDateTime }}.
```
Example Output:
```
Ted was married 18 years ago.
```

#### HumanizeTimeSpan

Takes two datetimes and humanizes the difference like '1 day'. Supports 'Now' in either the start or end date.
- There is an optional precision value you can apply to the filter to enhance the detail of the description. The default value of precision is 1 which means only the largest time unit is returned.
Example Input:
```
"Person": {
    "FirstVisit": "2/14/2011",
    "SecondVisit": "3/18/2011"
}
```
Example Lava:
```
It was {{ Person.FirstVisit | HumanizeTimeSpan:Person.SecondVisit }}

It was {{ Person.FirstVisit | HumanizeTimeSpan:Person.SecondVisit,2 }}

It was {{ Person.FirstVisit | HumanizeTimeSpan:Person.SecondVisit,3 }}
```
Example Output:
```
It was 4 weeks

It was 4 weeks, 4 days

It was 4 weeks, 4 days, 3 hours
```

#### IsDateBetween

Determine if the provided date falls within a given range (inclusive). A boolean value will be returned.
- This filter will accept input in the following formats:
- String (that can be parsed into a date)
- Date
- DateTime
- DateTimeOffset
- Note: C# can make incorrect assumptions about the format of a string when parsing into a DateTime, for best results send a DateTime object.
Example Input:
```
"Items": [
    {
        "Id": 1,
        "Title": "Easter Devotional",
        "FeaturedDates": "4/10/2022 to 4/20/2022"
    },
    {
        "Id": 2,
        "Title": "Christmas Devotional",
        "FeaturedDates": "12/20/2022 to 12/31/2022"
    },
]
```
Example Lava:
```
{% assign today = '2022-04-17 07:00' | Date:'yyyy-MM-dd HH:mm' %}
{% for i in Items %}
{% assign startDate = i.FeaturedDates | Split:' to ' | First %}
{% assign endDate = i.FeaturedDates | Split:' to ' | Last %}
{% if i.FeaturedDates != '' %}
    {% assign isFeatured = today | IsDateBetween:startDate,endDate %}
    {% if isFeatured %}
        {{i.Title}}
    {% endif %}
{% endif %}
{% endfor %}
```
Example Output:
```
Easter Devotional
```

#### NextDayOfTheWeek

Advances the date to a specific day in the next 7 days.
- The second parameter is optional and it takes a boolean value (the default is 'false') to determine the date's day can match the given day. Example: `{{ "5/1/2018" | NextDayOfTheWeek:'Tuesday', true }}` would result in "5/1/2018" because it was also a Tuesday.
- The third parameter is optional and it takes an integer value (the default is '1') to determine a number of weeks (You can use negative numbers to go back a number of weeks)
Example Input:
```
"CurrentPerson": {
    "FirstVisit": "2/9/2011"
}
```
Example Lava:
```
{{ CurrentPerson | Attribute:'FirstVisit' | NextDayOfTheWeek:'Friday' }}
```
Example Output:
```
2/11/2011
```

#### SundayDate

Returns the Sunday date portion (without any time portion) of the date provided. Keep in mind that Rock considers Sunday to be the last day of the week. This makes sense when calculating church metrics. The `'Now'` keyword can be used in place of a date for the current date.
Example Input:
```
"CurrentPerson": {
    "FirstVisit": "2/14/2011"
}
```
Example Lava:
```
You first visited on the week of {{ CurrentPerson | Attribute:'FirstVisit' | SundayDate }}.
```
Example Output:
```
You first visited on the week of 2/20/2011.
```

#### TimeOfDay

Returns a description of the time of day for an input value that represents a datetime. The keyword `'Now'` can be used to represent the current datetime.
- The return values are:
- Morning (if between 5:00:00 and 11:59:59)
- Afternoon (if between 12:00:00 and 16:59:59)
- Evening (if between 17:00:00 and 20:59:59)
- Night (if between 21:00:00 and 04:59:59)
Example Input:
```
"Person": {
    "NickName": "Ted"
    "ThirdVisit": "2/14/2011 1pm",
    "FourthVisit": "3/18/2011 11:30am"
}
```
Example Lava:
```
{{ Person.NickName }}'s third visit was in the {{ Person | Attribute:'ThirdVisit' | TimeOfDay }}, and the fourth visit was in the {{ Person | Attribute:'FourthVisit' | TimeOfDay }}.
```
Example Output:
```
Ted's first third was in the Afternoon, and the fourth visit was in the Morning.
```

#### ToMidnight

Sets the time portion to midnight (12:00:00 AM).
Example Input:
```
"Person": {
    "LastOfficeVisit": "2/13/2011 8am"
}
```
Example Lava:
```
{{ Person | Attribute:'LastOfficeVisit' | ToMidnight }}
```
Example Output:
```
2/13/2011 12:00:00 AM
```


### Numeric Filters

#### Abs

Returns the absolute value.

#### AsEnum

Converts an integer to its Rock enum value.
Example Lava:
```
{% assign siteType = 0 | AsEnum:'Rock.Model.SiteType' %}
Site Type: {{ siteType }}
```
Example Output:
```
Site Type: Web
```

#### AtLeast

Limits a number to a minimum value.
Example Input:
```
"Image": {
    "Width": 720,
    "Height": 480
}
```
Example Lava:
```
<img src="..." style="width:{{ Image.Width | AtLeast:1080 }}px">
```
Example Output:
```
<img src="..." style="width:1080px">
```

#### AtMost

Limits a number to a maximum value.
Example Input:
```
"Image": {
    "Width": 1920,
    "Height": 1080
}
```
Example Lava:
```
<img src="..." style="height:{{ Image.Height | AtMost:720 }}px">
```
Example Output:
```
<img src="..." style="height:720px">
```

#### Ceiling

Returns the next largest integer.
Example Input:
```
"Values": {
    "NumberOne": 2.6,
    "NumberTwo": 7.2
}
```
Example Lava:
```
The next largest integer of {{ Values.NumberTwo }} is {{ Values.NumberTwo | Ceiling }}.
```
Example Output:
```
The next largest integer of 7.2 is 8.
```

#### DividedBy

Divides by a number. Optional second parameter for rounding precision (v4.0+).
Example Input:
```
"Values": {
    "DivideThis": "12.434",
    "ThisNumber": "6"
}
```
Example Lava:
```
${{ Values.DivideThis | DividedBy:6,2 }}.
```
Example Output:
```
$2.07
```

#### Floor

Returns the next smallest integer.
Example Input:
```
"Values": {
    "NumberOne": 2.6,
    "NumberTwo": 7.2
}
```
Example Lava:
```
The next smallest value of {{ Values.NumberOne }} is {{ Values.NumberOne | Floor }}.
```
Example Output:
```
The next smallest value of 2.6 is 2.
```

#### Format

Formats a number using a pattern or short code (e.g., `'#,##0.00'`).
Example Input:
```
"Values": {
    "LastGift": "1200.23"
}
```
Example Lava:
```
Ted's last gift was for
{{ 'Global' | Attribute:'CurrencySymbol' }}{{ Values.LastGift | Format:'#,##0.00' }}.
```
Example Output:
```
Ted's last gift was for $1,200.23.
```

#### FormatAsCurrency

Formats using the currency symbol from the `OrganizationCurrencyCode` global attribute.

#### Minus

Subtracts.

#### Modulo

Returns the remainder.
Example Input:
```
"Values": {
    "NumberOne": 7,
    "NumberTwo": 3
}
```
Example Lava:
```
The remainder is {{ Values.NumberOne | Modulo:Values.NumberTwo }}.
```
Example Output:
```
The remainder is 1.
```

#### NumberToOrdinal

1 → "1st", 2 → "2nd", 3 → "3rd".

#### NumberToOrdinalWords

1 → "first", 2 → "second", 3 → "third".

#### NumberToRomanNumerals

1 → "I", 2 → "II", 3 → "III".

#### NumberToWords

1 → "one", 2 → "two", 3 → "three".

#### Plus

Adds.

#### RandomNumber

Generates a random number from 0 up to (but not including) the input.

#### Round

Rounds to the nearest integer, or to a specified number of decimal places.
Example Lava:
```
{{ 1.2 | Round }}
{{ 2.7 | Round }}
{{ 183.357 | Round: 2 }}
```
Example Output:
```
1
3
183.36
```

#### Times

Multiplies.

#### ToQuantity

Prefixes the word with a number and pluralizes/singularizes accordingly.
Example Input:
```
"Person": {
    "PhoneNumbers": [
        {
            "NumberFormatted": "(555) 555-5551"
        },
        {
            "NumberFormatted": "(555) 555-5552"
        },
        {
            "NumberFormatted": "(555) 555-5553"
        }
    ]
}
```
Example Lava:
```
{% assign phoneCount = Person.PhoneNumbers | Size %}
Ted has {{ 'phone number' | ToQuantity:phoneCount }}.
```
Example Output:
```
Ted has 3 phone numbers.
```

#### ToString

Converts to a string representation.
Example Input:
```
"Pagination": {
    "NextPage": 2,
    "UrlTemplate": "/page/346?Page=PageNum"
}
```
Example Lava:
```
{% assign nextPageString = Pagination.NextPage | ToString %}
<a href="{{ Pagination.UrlTemplate | Replace:'PageNum', nextPageString }}">Next</a>
```
Example Output:
```
<a href="/page/346?Page=2">Next</a>
```


### Array Filters

#### AddToArray

Adds an item to the end of an array. Creates a new array if the source is null or empty. Accepts any type of item (strings, entity objects, etc.).
Example Input:
```
"Items": [
    "one"
]
```
Example Lava:
```
{% assign array = Items | AddToArray:'two' | AddToArray:'three' %}
<ul>
{% for item in array %}
<li>{{ item }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>one</li>
<li>two</li>
<li>three</li>
</ul>
```

#### AddToDictionary

Adds a key/value pair to a dictionary (creates one if null/empty). Updates existing keys.
Example Lava:
```
{% assign colors = '' | AddToDictionary:'success','green' | AddToDictionary:'warning','orange' | AddToDictionary:'error','red' %}
<div style='color:{{ colors["success"]}}'>
This request is approved.
</div>
<div style='color:{{ colors["warning"]}}'>
This request is incomplete.
</div>
<div style='color:{{ colors["error"]}}'>
This request is denied.
</div>
```
Example Output:
```
<div style='color:green'>
This request is approved.
</div>
<div style='color:orange'>
This request is incomplete.
</div>
<div style='color:red'>
This request is denied.
</div>
```

#### AllKeysFromDictionary

Returns all keys from a dictionary as an array.
Example Input:
```
"Object": {
    "Id": 23,
    "FirstName": "Ted",
    "LastName": "Decker"
}
```
Example Lava:
```
{% assign keys = Object | AllKeysFromDictionary %}
<ul>
{% for key in keys %}
<li>{{ key }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>Id</li>
<li>FirstName</li>
<li>LastName</li>
</ul>
```

#### Compact

Removes empty or null values from an array.
Example Lava:
```
{% assign fruits = '' | AddToArray:'apples' | AddToArray:nil | AddToArray:'oranges' | AddToArray:nil | AddToArray:'peaches' %}
Whole Fruit: {{ fruits | Join:', ' }}.
{% assign squashedFruits = fruits | Compact %}
Squashed Fruit: {{ squashedFruits | Join:', ' }}.
```
Example Output:
```
Whole Fruit: apples, , oranges, , peaches.
Squashed Fruit: apples, oranges, peaches.
```

#### Concat

Joins multiple arrays together.
Example Lava:
```
{% assign primaryColors = 'red, yellow, blue' | Split: ', ' %}
{% assign secondaryColors = 'orange, green, violet' | Split: ', ' %}
{% assign allColors = primaryColors | Concat: secondaryColors %}
{{ allColors | Join:', ' }}
```
Example Output:
```
red, yellow, blue, orange, green, violet
```

#### Contains

Returns `true` if the array contains the specified value.

> [!NOTE]
> "Works only with string arrays" was the original wording here and is **not accurate** — tested
> August 2026, `contains` also works on integer arrays and on plain strings (substring test),
> and it coerces between the two. It is **case-sensitive**. See § "`Split`, `contains`, `Size`,
> and `Default` — measured edges" at the end of this file.
Example Input:
```
"Fruits": [
    "Banana",
    "Orange",
    "Banana",
    "Apple"
]
```
Example Lava:
```
{{ Fruits | Contains:'Banana' }}
```
Example Output:
```
true
```

#### Distinct

Returns unique elements. Unlike `Uniq`, works on complex objects. Optional parameter for the property to compare on.
Example Input:
```
"Items": [
    {
        "Person": {
            "Id": 1,
            "FirstName": "Ted",
            "LastName": "Decker"
        },
        "GroupId": 3
    },
    {
        "Person": {
            "Id": 2,
            "FirstName": "Cindy",
            "LastName": "Decker"
        },
        "GroupId": 4
    },
    {
        "Person": {
            "Id": 1,
            "FirstName": "Ted",
            "LastName": "Decker"
        },
        "GroupId": 4
    },
]
```
Example Lava:
```
{% assign array = Items | Distinct:'Person.Id' %}
<ul>
{% for item in array %}
<li>{{ item.Person.FirstName }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>Ted</li>
<li>Cindy</li>
</ul>
```

#### First

Returns the first item.
Example Input:
```
"CurrentPerson": {
    "PhoneNumbers": [
        {
            "NumberFormatted": "(555) 555-5551"
        },
        {
            "NumberFormatted": "(555) 555-5552"
        },
        {
            "NumberFormatted": "(555) 555-5553"
        }
    ]
}
```
Example Lava:
```
{% assign firstPhone = CurrentPerson.PhoneNumbers | First %}
The first phone number is {{ firstPhone.NumberFormatted }}.
```
Example Output:
```
The first phone number is (555) 555-5551.
```

#### GroupBy

Groups items by a property. Returns a dictionary; use `PropertyToKeyValue` to iterate.
Example Input:
```
"Members": [
    {
        "GroupRole": {
            "Name": "Member"
        },
        "Person": {
            "FirstName": "Alex"
        }
    },
    {
        "GroupRole": {
            "Name": "Leader"
        },
        "Person": {
            "FirstName": "Ted"
        }
    },
    {
        "GroupRole": {
            "Name": "Member"
        },
        "Person": {
            "FirstName": "Cindy"
        }
    }
]
```
Example Lava:
```
{% assign groupedMembers = Members | GroupBy:'GroupRole.Name' %}
<ul>
{% for group in groupedMembers %}
{% assign parts = group | PropertyToKeyValue %}
<li>{{ parts.Key }}</li>
<ul>
{% for member in parts.Value %}
    <li>{{ member.Person.FirstName }}</li>
{% endfor %}
</ul>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>Leader</li>
<ul>
    <li>Ted</li>
</ul>
<li>Member</li>
<ul>
    <li>Alex</li>
    <li>Cindy</li>
</ul>
</ul>
```

#### Index

Retrieves an item by its zero-based index (useful when chaining filters).
Example Input:
```
"CurrentPerson": {
    "PhoneNumbers": [
        {
            "NumberFormatted": "(555) 555-5551"
        },
        {
            "NumberFormatted": "(555) 555-5552"
        },
        {
            "NumberFormatted": "(555) 555-5553"
        }
    ]
}
```
Example Lava:
```
{% assign secondPhone = CurrentPerson.PhoneNumbers | Index:1 %}

{{ secondPhone.NumberFormatted }}
```
Example Output:
```
(555) 555-5552
```

#### Indexer

Array bracket notation for accessing items (e.g., `{{ fruits[2] }}`).
Example Lava:
```
{% assign fruits = "orange apple banana orange" | Split:' ' %}
{{ fruits[2] }}
```
Example Output:
```
banana
```

#### Join

Combines array elements into a string with a separator.
Example Input:
```
"FavoriteColors" : ["Red", "Green", "Orange"]
```
Example Lava:
```
{{ FavoriteColors | Join:', ' }}
```
Example Output:
```
Red, Green, Orange
```

#### Last

Returns the last item.
Example Input:
```
"CurrentPerson": {
    "PhoneNumbers": [
        {
            "NumberFormatted": "(555) 555-5551"
        },
        {
            "NumberFormatted": "(555) 555-5552"
        },
        {
            "NumberFormatted": "(555) 555-5553"
        }
    ]
}
```
Example Lava:
```
{% assign firstPhone = CurrentPerson.PhoneNumbers | Last %}
The last phone number is {{ firstPhone.NumberFormatted }}.
```
Example Output:
```
The last phone number is (555) 555-5553.
```

#### Map

Extracts a single property from each element, creating a string.
Example Input:
```
Campuses {
    {
        Name - Avalon Campus
        ShortCode - AVL
        Id - 1
    },
    {
        Name - Tacoma Campus
        ShortCode - TAC
        Id - 2
    },
    {
        Name - Corolla Campus
        ShortCode - COR
        Id - 3
    }
}
```
Example Lava:
```
{{ Campuses | Map:'Name'  }}
```
Example Output:
```
Avalon CampusTacoma CampusCorolla Campus
```

#### OrderBy

Sorts by one or more property paths. Separate multiple keys with commas. Append ` desc` for descending.
Example Input:
```
"Members": [
    {
        "GroupRole": {
            "Name": "Member",
            "IsLeader": false
        },
        "Person": {
            "FirstName": "Alex"
        }
    },
    {
        "GroupRole": {
            "Name": "Leader",
            "IsLeader": true
        },
        "Person": {
            "FirstName": "Ted"
        }
    },
    {
        "GroupRole": {
            "Name": "Member",
            "IsLeader": false
        },
        "Person": {
            "FirstName": "Cindy"
        }
    }
]
```
Example Lava:
```
{% assign members = Members | OrderBy:'GroupRole.IsLeader desc,Person.FirstName' %}
<ul>
{% for member in members %}
<li>{{ member.Person.FirstName }} - {{ member.GroupRole.Name }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>Ted - Leader</li>
<li>Alex - Member</li>
<li>Cindy - Member</li>
</ul>
```

#### RemoveFromArray

Removes all occurrences of a value from a string array.
Example Input:
```
"Items": [
    "one",
    "two",
    "three"
]
```
Example Lava:
```
{% assign array = Items | RemoveFromArray:'two' %}
<ul>
{% for item in array %}
<li>{{ item }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>one</li>
<li>three</li>
</ul>
```

#### RemoveFromDictionary

Removes a key from a dictionary.
Example Input:
```
"Object": {
    "Id": 23,
    "FirstName": "Ted",
    "LastName": "Decker"
}
```
Example Lava:
```
{% assign data = Object | RemoveFromDictionary:'FirstName' %}
{{ data | ToJSON }}
```
Example Output:
```
{
    "Id": 23,
    "LastName": "Decker"
}
```

#### Reverse

Reverses array order.
Example Lava:
```
{% assign my_array = "apples, oranges, peaches, plums" | Split:", " %}

{{ my_array | Reverse | Join:", " }}
```
Example Output:
```
plums, peaches, oranges, apples
```

#### Select

Returns a single property from each object in a collection.
Example Input:
```
"CurrentPerson": {
    "FullName": "Ted Decker"
    "PhoneNumbers":  [
        {
            Number - 6235555551
            NumberFormatted - (623) 555-5551
            NumberTypeValueId - 12
        },
        {
            Number - 6235555552
            NumberFormatted - (623) 555-5552
            NumberTypeValueId - 13
        },
        {
            Number - 6235555553
            NumberFormatted - (623) 555-5553
            NumberTypeValueId - 136
        }
    ]
}
```
Example Lava:
```
{{ CurrentPerson.NickName }}'s work phone is: {{ CurrentPerson.PhoneNumbers | Where:'NumberTypeValueId', 136 | Select:'NumberFormatted' }}.
```
Example Output:
```
Ted's work phone is: (623) 555-5553.
```

#### Shuffle

Randomizes array order.
Example Input:
```
{
    [0] {
        "Id": 1,
        "Image": "<img src="/GetImage.ashx?Id=1>"
    },
    [1] {
        "Id": 2,
        "Image": "<img src="/GetImage.ashx?Id=2>"
    },
    [2] {
        "Id": 3,
        "Image": "<img src="/GetImage.ashx?Id=3>"
    }
}
```
Example Lava:
```
{% assign randomOrderedAds = Items | Shuffle %}

{% for ad in randomOrderedAds %}
<div class="item">
<a href="{{ LinkedPages.DetailPage }}?Item={{ ad.Id }}">{{ ad.Image }}</a>
</div>
{% endfor %}
```
Example Output:
```
<div class="item">
<a href="AdDetail?Item=2"><img src="/GetImage.ashx?Id=2></a>
</div>

<div class="item">
<a href="AdDetail?Item=3"><img src="/GetImage.ashx?Id=3></a>
</div>

<div class="item">
<a href="AdDetail?Item=1"><img src="/GetImage.ashx?Id=1></a>
</div>
```

#### Size

(On arrays) Returns the number of items.
Example Input:
```
"Person": {
    "PhoneNumbers": [
        {
            "NumberFormatted": "(555) 555-5551"
        },
        {
            "NumberFormatted": "(555) 555-5552"
        },
        {
            "NumberFormatted": "(555) 555-5553"
        }
    ]
}
```
Example Lava:
```
Ted has {{ Person.PhoneNumbers | Size }} phone numbers.
```
Example Output:
```
Ted has 3 phone numbers.
```

#### Slice

(On arrays) Returns a subset starting at a given index. Optional second parameter for length.
Example Input:
```
"List": [
    1,
    2,
    3,
    4,
    5
]
```
Example Lava:
```
{% assign sublist = List | Slice:2,3 %}

<ul>
{% for i in sublist %}
<li>{{ i }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>2</li>
<li>3</li>
<li>4</li>
</ul>
```

#### Sort

Sorts a primitive array. For object arrays, use `OrderBy`.
Example Input:
```
"Fruits": [
    "Banana",
    "Orange",
    "Apple"
]
```
Example Lava:
```
{% assign fruitsSorted1 = Fruits | Sort %}
{% assign fruitsSorted2 = Fruits | Sort | Reverse %}

<ul>
{% for fruit in fruitsSorted1 %}
<li>{{ fruit }}</li>
{% endfor %}
</ul>

<ul>
{% for fruit in fruitsSorted2 %}
<li>{{ fruit }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>Apple</li>
<li>Banana</li>
<li>Orange</li>
</ul>

<ul>
<li>Orange</li>
<li>Banana</li>
<li>Apple</li>
</ul>
```

#### SortByAttribute

Sorts by an attribute value. Optional sort order: `'asc'` (default) or `'desc'` (v7+).
Example Input:
```
Campuses {
    {
        Id: 1
        Name: Avalon Campus
        (with Attribute 'SeatingCapacity': 250)
    },
    {
        Id: 2
        Name: Tacoma Campus
        (with Attribute 'SeatingCapacity': 150)
    },
    {
        Id: 3
        Name: Corolla Campus
        (with Attribute 'SeatingCapacity': 550)
    }
}
```
Example Lava:
```
{% assign sortedItems = Items | SortByAttribute:'SeatingCapacity' %}

<ul>
{% for item in sortedItems %}
<li>{{ item.Name }}: {{ item | Attribute:'SeatingCapacity' }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>Tacoma Campus: 150</li>
<li>Avalon Campus: 250</li>
<li>Corolla Campus: 550</li>
</ul>
```

#### SortNatural

Case-insensitive sort for primitive arrays.
Example Input:
```
"Fruits": [
    "Banana",
    "orange",
    "apple"
]
```
Example Lava:
```
{% assign fruitsSorted1 = Fruits | SortNatural %}
{% assign fruitsSorted1 = Fruits | SortNatural | Reverse %}

<ul>
{% for fruit in fruitsSorted1 %}
<li>{{ fruit }}</li>
{% endfor %}
</ul>

<ul>
{% for fruit in fruitsSorted2 %}
<li>{{ fruit }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>Apple</li>
<li>banana</li>
<li>orange</li>
</ul>

<ul>
<li>orange</li>
<li>banana</li>
<li>Apple</li>
</ul>
```

#### Sum

Sums all numeric values in an array.
Example Input:
```
"Items": [
    { "Name": "Shirt", "Price": 15.25 },
    { "Name": "Sweater", "Price": 25.00 },
    { "Name": "Jacket", "Price": 45.50 }
]
```
Example Lava:
```
Total: ${{ Items | Select:'Price' | Sum }}
```
Example Output:
```
Total: $85.75
```

#### Uniq

Returns unique values from a simple array.
Example Input:
```
"Fruits": [
    "Banana",
    "Orange",
    "Banana",
    "Apple"
]
```
Example Lava:
```
{{ Fruits | Uniq | Join:',' }}
```
Example Output:
```
Banana,Orange,Apple
```

#### Where

Filters a collection by key and value. Optional third parameter `'notequal'` (v12.3+).
Example Input:
```
"CurrentPerson": {
    "FullName": "Ted Decker"
    "PhoneNumbers":  [
        {
            Number - 6235555551
            NumberFormatted - (623) 555-5551
            NumberTypeValueId - 12
        },
        {
            Number - 6235555552
            NumberFormatted - (623) 555-5552
            NumberTypeValueId - 13
        },
        {
            Number - 6235555553
            NumberFormatted - (623) 555-5553
            NumberTypeValueId - 136
        }
    ]
}
```
Example Lava:
```
Example 1:
{{ CurrentPerson.NickName }}'s work phone is: {{ CurrentPerson.PhoneNumbers | Where:'NumberTypeValueId', 136 | Select:'NumberFormatted' }}.

Example 2 (v12.3 and above):
{{ CurrentPerson.NickName }}'s other contact numbers are: {{ CurrentPerson.PhoneNumbers | Where:'NumberTypeValueId', 136, 'notequal' | Select:'NumberFormatted' | Join:', ' }}.
```
Example Output:
```
Ted's work phone is: (623) 555-5553.
Ted's other contact numbers are: (623) 555-5551, (623) 555-5552.
```


### Person Filters

#### Address

Returns an address for the Person. First parameter (required): address type (`Home`, `Work`, `Mailing`, `MapLocation`). Optional second parameter: format string using double-bracket merge fields (`[[Street1]]`, `[[City]]`, `[[State]]`, `[[PostalCode]]`, `[[Country]]`, `[[FormattedAddress]]`, `[[FormattedHtmlAddress]]`, `[[GeoPoint]]`, `[[Latitude]]`, `[[Longitude]]`, `[[Name]]`, `[[Guid]]`).

Example Input:
```
"CurrentPerson": {
    "Id": 12,
    "FullName": "Ted Decker",
    "AnniversaryDate": '',
}
```
Example Lava:
```
Home Address: {{ CurrentPerson | Address:'Home' }}

Work Address: {{ 12 | Address:'Work','[[City]], [[State]]' }}
```
Example Output:
```
Home Address: 11624 N 31st Dr Phoenix, AZ 85029

Work Address: Spokane, WA
```

#### AddSegment

Adds a person to one or more personalization segments (comma-delimited keys). No output. The person may be removed by the next "Update Personalization Data" job run if they don't meet criteria.

Example Lava:
```
{% assign items = CurrentVisitor | PersonalizationItems:'Segments' %}
<p><strong>Before:</strong></p>
{% for item in items %}
<br>{{ item.Type }} - {{ item.Key }}
{% endfor %}
{{ CurrentPerson | AddSegment:'IN_SMALL_GROUP,HAS_GIVEN' }}
<p><strong>After:</strong></p>
{% assign items = CurrentVisitor | PersonalizationItems:'Segments' %}
{% for item in items %}
<br>{{ item.Type }} - {{ item.Key }}
{% endfor %}
```
Example Output:
```
<p><strong>Before:</strong></p>
<br>Segment - ALL_MEN

<p><strong>After:</strong></p>
<br>Segment - ALL_MEN
<br>Segment - IN_SMALL_GROUP
<br>Segment - HAS_GIVEN
```

#### Campus

Returns the person's campus (first one if multiple). Use `'All'` extension for an array of all campuses.

Example Input:
```
"CurrentPerson": {
    "FullName": "Ted Decker",
    "AnniversaryDate": '',
}
```
Example Lava:
```
{% assign personCampus = CurrentPerson | Campus %}
{{ CurrentPerson.NickName }}, your campus is {{ personCampus.Name  }}
```
Example Output:
```
Ted, your campus is Main Campus.
```

#### Children

Returns a list of children for the person. Accepts Person object or PersonId.

Example Input:
```
"CurrentPerson": {
    "Id": 4,
    "FullName": "Ted Decker",
    "AnniversaryDate": '2020-07-20'
}
```
Example Lava:
```
{% assign children = CurrentPerson | Children %}

<ul>
{% for child in children %}
<li>{{ child.FullName }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>Noah Decker</li>
<li>Alex Decker</li>
</ul>
```

#### DeleteUserPreference

Removes a saved user preference by key. No output.

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{{ CurrentPerson | DeleteUserPreference:'block-id-12-last-run-date' }}
```

#### FamilySalutation

Returns the family salutation. Parameters: includeChildren (default false), includeInactive (default true, never shows deceased), useFirstName (default false), finalSeparator (default `'&'`), separator (default `','`).

Example Input:
```
"CurrentPerson": {
    "Id": 4,
    ...
}
```
Example Lava:
```
{{ CurrentPerson | FamilySalutation }}

{{ 4 | FamilySalutation:true,false,true,'and','-' }}
```
Example Output:
```
Ted & Cindy Decker

Theodore Decker - Cynthia Decker - Noah Decker and Alexis Decker
```

#### GeofencingGroupMembers

Returns group members whose groups geofence the person's map location. Parameters: GroupTypeId, GroupRoleId.

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{% assign areaLeaders = CurrentPerson | GeofencingGroupMembers:'24','44'   %}

<ul>
{% for leader in areaLeaders %}
<li>{{ leader.FullName }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>Pete Foster</li>
<li>Ted Decker</li>
</ul>
```

#### GeofencingGroups

Returns groups that geofence the person's map location. Parameter: GroupTypeId.

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{% assign areas = CurrentPerson | GeofencingGroups:'24'  %}

<ul>
{% for area in areas %}
<li>{{ area.Name }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>Area A</li>
<li>Area B</li>
</ul>
```

#### GetPersonAlternateId

Returns the person's alternate ID. Accepts Person object or PersonId.

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
Your person alternate id is: {{ CurrentPerson | GetPersonAlternateId }}.
```
Example Output:
```
Your person alternate id is: 18bf456-f2fc443.
```

#### GetUserPreference

Retrieves a saved user preference by key. Accepts Person object or PersonId.

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{{ CurrentPerson | GetUserPreference:'block-id-12-last-run-date' }}
```
Example Output:
```
4/6/2016
```

#### Group

Returns GroupMember records if a person is in a specific group. Parameters: GroupId, optional GroupMemberStatus (`'Active'`/`'Inactive'`/`'Pending'`/`'All'`, default `'Active'`).

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{% assign groupMembers = CurrentPerson | Group:'29','All' %}

<ul>
{% for groupMember in groupMembers %}
<li>{{ groupMember.Group.Name }} - {{ groupMember.GroupRole.Name }} ( {{ groupMember.GroupMemberStatus }} )</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>General Group 1 - Leader ( Active )</li>
<li>General Group 1 - Member ( Inactive )</li>
</ul>
```

#### Groups

Returns GroupMember models of a specified GroupType. Parameters: GroupTypeId, optional status (default `'Active'`), optional include inactive groups (`'All'`).

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{% assign groupMembers = CurrentPerson | Groups:'29','All' %}

<ul>
{% for groupMember in groupMembers %}
<li>{{ groupMember.Group.Name }} ( {{ groupMember.GroupMemberStatus }} )</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>General Group 1 ( Active )</li>
<li>General Group 2 ( Inactive )</li>
</ul>
```

#### GroupsAttended

Returns groups attended within a GroupType.

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{% assign groups = CurrentPerson | GroupsAttended:'29' %}

<ul>
{% for group in groups %}
<li>{{ group.Name }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>General Group 1</li>
<li>General Group 2</li>
</ul>
```

#### HasSignedDocument

Returns whether the person has signed a specific document. Optional "true text" and "false text" parameters.

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{% assign hasSigned = CurrentPerson | HasSignedDocument:1 %}
{% if hasSigned %}
  {{ CurrentPerson.NickName }} has signed this document.
{% endif %}

Hi {{ CurrentPerson.NickName }}, you {{ CurrentPerson | HasSignedDocument:1,'have signed','need to sign' }}
the waiver for camp.
```
Example Output:
```
Ted has signed this document.

Hi Ted, you have signed the waiver for camp.
```

#### HeadOfHousehold

Returns the head of household for the person.

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{% assign headOfHouse = CurrentPerson | HeadOfHousehold %}
{{ headOfHouse.FullName }}
```
Example Output:
```
Ted Decker
```

#### IsInSecurityRole

Tests whether a person is in a security role (by GroupId). Returns boolean. Logs an exception if the GroupId is not a security role.

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{% assign isInRole = CurrentPerson | IsInSecurityRole: 18 %}
{% if isInRole == true %}
  <p>{{ CurrentPerson.FullName }} is in that Role.</p>
{% else %}
  <p>{{ CurrentPerson.FullName }} is not in that Role.</p>
{% endif %}
```
Example Output:
```
<p>Alisha Marble is in that Role.</p>
```

#### LastAttendedGroupOfType

Returns the full Attendance object for the most recent attendance in a group of the given GroupType. Includes a `StartDateTime` property.

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{% assign lastAttended = CurrentPerson | LastAttendedGroupOfType:'25' %}

{{ CurrentPerson.NickName }} last attended the group '{{ lastAttended.Occurrence.Group.Name }}' on {{ lastAttended.StartDateTime | Date:'dddd, MMMM d, yyyy' }}.
```
Example Output:
```
Ted last attended the group 'Alisha Marble's Group' on Wednesday, May 13, 2015.
```

#### NearestCampus

Returns the nearest campus(es) to a person's geocoded address. Optional parameter for max results (default 1). Returns a single Campus if 1, or an array if more.

Example Lava:
```
{% assign campus = CurrentPerson | NearestCampus %}
The nearest campus to {{ CurrentPerson.NickName }} is: {{ campus.Name }}.

{% assign campusList = CurrentPerson | NearestCampus:2 %}
The two nearest campuses to {{ CurrentPerson.NickName }} are: {{ campusList | Select:'Name' | Join:', ' }}.
```
Example Output:
```
The nearest campus to Ted is: Main Campus.
The two nearest campuses to Ted are: Main Campus, North Campus.
```

#### NearestGroup

Returns the nearest group of a specified GroupType.

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{% assign nearestGroup = CurrentPerson | NearestGroup:'25'  %}

Your nearest group is the {{ nearestGroup.Name }}.
```
Example Output:
```
Your nearest group is the Decker Group.
```

#### NearestGroups

Returns nearest groups with travel information. Requires an active Google API key with Routes API enabled. Parameters: GroupTypeId, MaxResults (default 10), TravelMode (`'drive'`/`'walk'`/`'bicycle'`), ConsiderClosestLocation (default true), MaxDistance. Returns: `StraightLineDistanceInMeters`, `Group`, `Location`, `TravelTimeInMinutes`, `TravelDistanceInMeters`. Input can be Person, PersonId, or lat/long string.

Example Lava:
```
{% assign closeGroups = CurrentPerson | NearestGroups:25,5,'drive' %}

<ul>
{% for result in closeGroups %}
<li>
    <strong>{{ result.Group.Name }}</strong>
    <br>{{ result.Location.Latitude }}, {{ result.Location.Longitude }}
    <br>{{ result.Location.Street1 }}
    <br>Distance: {{ result.StraightLineDistanceInMeters }}
    <br>Travel Time In Minutes: {{ result.TravelTimeInMinutes }}
    <br>Travel Distance In Meters: {{ result.TravelDistanceInMeters }}
</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>

<li>
    <strong>Gilbert Group</strong>
    <br>33.58622, -112.135094
    <br>11022 N 35th Dr
    <br>Distance: 2342
    <br>Travel Time In Minutes: 5
    <br>Travel Distance In Meters: 2567
</li>

...
</ul>
```

#### Parents

Returns the adults in the person's family. Accepts Person object or PersonId (v7+).

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{% assign parents = CurrentPerson | Parents %}
My parents are:
{% for person in parents %}
<li>{{ person.FullName }}</li>
{% endfor %}
```
Example Output:
```
My parents are:
<li>Ted Decker</li>
<li>Cindy Decker</li>
```

#### PersonActionIdentifier

Creates a non-security token identifying a Person and an action. Used by specific blocks (Assessment, Email Preference Entry, Group Schedule Confirmation, Photo Opt Out, RSVP Response, GetCommunication.ashx).

Example Input:
```
"Person": {
    ...
}
```
Example Lava:
```
Your token is: {{ Person | PersonActionIdentifier: 'photo-opt-out' }}
```
Example Output:
```
Your token is: EAAAAEgOBBKHKHzZ7vg2Jl6mSJ!2fQsI6lz3QhqRsjoYp4EgKpdSkvE2gR2nG4yq6l6TJTKBVyJWQudZ!2sdfsfdfsOaj5yGsWNkk!3d
```

#### PersonalizationItems

Returns personalization items (segments and/or request filters) for a person. Optional parameter for types: `'Segments'`, `'RequestFilters'`, or both comma-delimited.

Example Input:
```
**URL:**
http://rock.rocksolidchurchdemo.com?parameter1=true&parameter2=true

**Logged-In User:**
Ted Decker
```
Example Lava:
```
{% assign items = CurrentVisitor | PersonalizationItems:'Segments,RequestFilters' %}
{% for item in items %}
{{ item.Type }} - {{ item.Key }}
{% endfor %}
```
Example Output:
```
Segment - AllMen
Segment - InSmallGroup
Segment - NotYetBaptized
Request Filter - ViewingFromCollegeCampusIP
Request Filter - QUERY_2
```

#### PersonByAliasGuid

Converts a PersonAliasGuid to a full Person object.

Example Input:
```
"Campus" {
    "LeaderPersonAliasGuid": "b22fc07a-e359-8398-4b66-5a83e439f8f6"
    ...
}
```
Example Lava:
```
{% assign campusLeader = Campus.LeaderPersonAliasGuid | PersonByAliasGuid %}

Hello {{ campusLeader.NickName }}!
```
Example Output:
```
Hello Ted!
```

#### PersonByAliasId

Converts a PersonAliasId to a full Person object.

Example Input:
```
"Campus" {
    "LeaderPersonAliasId": 234
    ...
}
```
Example Lava:
```
{% assign campusLeader = Campus.LeaderPersonAliasId | PersonByAliasId %}

Hello {{ campusLeader.NickName }}!
```
Example Output:
```
Hello Ted!
```

#### PersonByGuid

Converts a PersonGuid to a full Person object.

Example Input:
```
"GroupMember" {
    "Person": {
        Guid: "8fedc6ee-8630-41ed-9fc5-c7157fd1eaa4"
    }
    ...
}
```
Example Lava:
```
{% assign groupMemberPerson = GroupMember.Person.Guid | PersonByGuid %}

Hello {{ groupMemberPerson.NickName }}!
```
Example Output:
```
Hello Ted!
```

#### PersonById

Converts a PersonId to a full Person object.

Example Input:
```
"GroupMember" {
    "PersonId": 234
    ...
}
```
Example Lava:
```
{% assign groupMemberPerson = GroupMember.PersonId | PersonById %}

Hello {{ groupMemberPerson.NickName }}!
```
Example Output:
```
Hello Ted!
```

#### PersonByPersonActionIdentifier

Converts a PersonActionIdentifier to a full Person object. Requires the action name parameter.

Example Input:
```
"PersonActionIdentifier": "EAAAAEgOBBKHKHzZ7vg2Jl6mSJ!2fQsI6lz3QhqRsjoYp4EgKpdSkvE2gR2nG4yq6l6TJTKBVyJWQudZ!2sdfsfdfsOaj5yGsWNkk!3d"
```
Example Lava:
```
{% assign person = PersonActionIdentifier | PersonByPersonActionIdentifier: 'photo-opt-out' %}
Welcome {{ person.NickName }}
```
Example Output:
```
Welcome Bill
```

#### PersonByPersonAlternateId

Converts a Person's AlternateId to a full Person object.

Example Input:
```
"PersonAlternateId": "18bf456-f2fc443"
```
Example Lava:
```
{% assign person = PersonAlternateId | PersonByPersonAlternateId %}

Hello {{ person.NickName }}!
```
Example Output:
```
Hello Ted!
```

#### PersonImpersonationToken

Appends an impersonation token (`rckipid`) to a URL. Optional parameters: Minutes (default 30), MaxUsage (default 1), PageId.

Example Lava:
```
{{ 'https://rocksolidchurchdemo.com' | PersonImpersonationToken }}
```
Example Output:
```
https://rocksolidchurchdemo.com?rckipid=EAAAAEgOfZ6BLzZ7vg2Jl6mSJ!2fQsI6lz3QhqRsjoYp4EgKpdSkvE2gR2nG4yq6l6TJTKBVyJWQudZ!2bgxOaj5yGsWNkk!3d
```

#### PersonTokenCreate

Generates an impersonation token without appending to a URL. Same optional parameters as PersonImpersonationToken. Use `null` for defaults.

Example Input:
```
"Person": {
    ...
}
```
Example Lava:
```
{% assign token =  Person | PersonTokenCreate:43200,null,1543 %}
```
Example Output:
```
EAAAAEgOfZ6BLzZ7vg2Jl6mSJ!2fQsI6lz3QhqRsjoYp4EgKpdSkvE2gR2nG4yq6l6TJTKBVyJWQudZ!2bgxOaj5yGsWNkk!3d
```

#### PersonTokenRead

Reads a Person from an impersonation token. Optional parameters: IncrementUsage (default false), PageId.

Example Input:
```
{
    ... normally tokens would be read from the query string
}
```
Example Lava:
```
{% assign token = 'Global' | PageParameter:'rckipid' %}
{% assign person = token | PersonTokenRead:false,1543 %}
{{ person.FullName }}
```
Example Output:
```
Ted Decker
```

#### PhoneNumber

Returns a phone number by type (`'Home'`, `'Mobile'`, `'Work'`). Optional second parameter to show country code.

Example Input:
```
"CurrentPerson": {
    "FullName": "Ted Decker"
    "PhoneNumbers":  [
        {
            Number - 6235555551
            NumberFormatted - (623) 555-5551
            NumberType - Home
        },
        {
            Number - 6235555552
            NumberFormatted - (623) 555-5552
            NumberType - Mobile
        },
        {
            Number - 6235555553
            NumberFormatted - (623) 555-5553
            NumberType - Work
        }
    ]
}
```
Example Lava:
```
Mobile Number: {{ CurrentPerson | PhoneNumber:'Mobile' }}
```
Example Output:
```
Mobile Number: (623) 555-5552
```

#### SetUserPreference

Saves a user preference by key and value. No output.

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{{ CurrentPerson | SetUserPreference:'block-id-12-last-run-date', '4/6/2016' }}
```

#### Spouse

Returns the spouse of the person.

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{% assign spouse = CurrentPerson | Spouse %}
{{ spouse.FullName }}
```
Example Output:
```
Cindy Decker
```

#### Steps

Returns filtered steps for a person. Optional parameters: StepProgram (Id, Guid, or `'all'`), StepStatus (Id, Guid, Name, or `'all'`), StepType (Id, Guid, or `'all'`).

Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{% assign steps = CurrentPerson | Steps: '1','Complete' %}

<ul>
{% for step in steps %}
<li>{{ step.StepType.Name }} ( {{ step.StepStatus.Name }} )</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>Baptism ( Complete )</li>
<li>Starting Point Class ( Complete )</li>
<li>Small Group ( Complete )</li>
</ul>
```

#### ZebraPhoto

Returns a person's photo as ZPL data for Zebra printers. Optional parameters: Size (default 395), Brightness (0–1.99), Contrast (0–1.99), Filename, RotateDegree (90, 180, or 270). Output uses `LOGO.PNG` filename; additional ZPL code is needed for placement.

Example Input:
```
"Person": {
    ...
}
```
Example Lava:
```
^FD{{ Person | ZebraPhoto:'397',1.0,1.0,'LOGO',90 }}^FS
```
Example Output:
```
^FD^FS~DYR:LOGO,P,P,12246,,89504E470A50C317A8C32490DF5A6...90A9CD5B34A9B0FA2A842E095F5CE082^FD^FS
```


### Attribute Filters

See https://community.rockrms.com/lava/filters/attribute-filters for full documentation.


### Other Filters

#### AddCssLink

Adds a CSS link to the page (no duplicates). Supports `~/` for app path and `~~/` for theme root. Optional fingerprinting parameter.
Example Lava:
```
{{ 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css' | AddCssLink }}
```
Example Output:
```
<link type="text/css" rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
```

#### AddLinkTagToHead

Adds a `<link>` tag to the page's HTML head.
Example Input:
```
"CurrentPerson": {
    "PhotoUrl": "/GetImage.ashx?id=55"
}
```
Example Lava:
```
{{ CurrentPerson.PhotoUrl | AddLinkTagToHead:'rel','image_src' }}
```
Example Output:
```
The tag below will be added to the head of the page.
<link rel="image_src" href="/GetImage.ashx?id=55">
```

#### AddMetaTagToHead

Adds a `<meta>` tag to the page's HTML head.
Example Input:
```
"CurrentPerson": {
    "PhotoUrl": "/GetImage.ashx?id=55"
}
```
Example Lava:
```
{{ CurrentPerson.PhotoUrl | AddMetaTagToHead:'property','og:image' }}
```
Example Output:
```
The tag below will be added to the head of the page.
<meta property="og-image" content="/GetImage.ashx?id=55">
```

#### AddResponseHeader

Adds a custom HTTP response header.
Example Lava:
```
{{ 'public, max-age=120' | AddResponseHeader:'cache-control' }}
```
There is no output displayed, but the HTTP response object will have a new header added.

#### AddScriptLink

Adds a script link to the page (no duplicates). Supports `~/` and `~~/`.
Example Lava:
```
{{ 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js' | AddScriptLink }}
```
Example Output:
```
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" type="text/javascript"></script>
```

#### AddToMergeFields

Adds an item to the Lava merge fields.
Example Lava:
```
{{ 'Ted Decker' | AddToMergeFields:'SelectedPerson' }}

{{ SelectedPerson }}
```
Example Output:
```
Ted Decker
```

#### AppendFollowing

Adds `IsFollowing` property to entity command or Persisted Dataset results for the current user. Optional purpose key parameter.
Example Lava:
```
<p>Entity Command Example</p>
{% person where:'Id != 1' limit:'3' iterator:'People' %}
  {% assign followedItems = People | AppendFollowing %}
  <ul>
  {% for item in followedItems %}
<li>{{ item.FullName }} - {{ item.IsFollowing }} </li>
  {% endfor %}
  </ul>
{% endperson %}


<p>Persisted Dataset Example</p>
{% assign data = 'mydataset' | PersistedDataset | AppendFollowing %}
<ul>
{% for item in data %}
  <li>{{ item.Title }} - {{ item.IsFollowing }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<p>Entity Command Example</p>
<ul>
<li>Ted Decker - true</li>
<li>Cindy Decker - false</li>
<li>Noah Decker - false</li>
</ul>

<p>Persisted Dataset Example</p>
<ul>
<li>Friday 3/25 - true</li>
<li>Saturday 3/26 - false</li>
<li>Sunday 3/27 - false</li>
</ul>
```

#### AppendSegments

Adds `IsInSegment` and `MatchingSegments` properties to entity command or Persisted Dataset results. Optional segment key parameter.
Example Lava:
```
<h1>Entity Command Example</h1>
{%- contentchannel where:'Name == "Messages"' -%}
{%- assign channelId = contentchannel.Id -%}
{%- contentchannelitem where:'ContentChannelId == {{ contentchannel.Id }}' iterator:'Items' -%}
{%- assign segments = Items | AppendSegments:'MARRIED' | Sort:'Title' -%}
 <p>{{ CurrentPerson.NickName }}, you might be interested in these messages on the topic of Marriage:</p>
<ul>
    {%- for item in segments -%}
        {%- if item.IsInSegment == true -%}
            <li>{{ item.Title }} [{{ item.MatchingSegments }}]</li>
        {% endif -%}
    {%- endfor -%}
</ul>
{%- endcontentchannelitem -%}
{%- endcontentchannel -%}

<h1>Persisted Dataset Example</h1>
{% assign matchedSegmentItems = 'MyContentChannelItemsDataset' | PersistedDataset | AppendSegments %}
<p>Recommendations for {{ CurrentPerson.NickName }}:</p>
<ul>
  {%- for item in matchedSegmentItems -%}
<li>{{ item.Title }} - {{ item.IsInSegment }}{% if item.MatchingSegments > '' %} [{{ item.MatchingSegments }}]{% endif %}</li>
  {% endfor -%}
</ul>
```
Example Output:
```
<h1>Entity Command Example</h1>
<p>Ted, you might be interested in these messages on the topic of Marriage:</p>
<ul>
  <li>Extended Family [Married]</li>
  <li>How To Make Your Marriage Better Today [Married]</li>
  <li>Immediate Family [Married]</li>
  <li>The Secret That Could Cost You Your Marriage [Married]</li>
</ul>
<h1>Persisted Dataset Example</h1>

<p>Recommendations for Ted:</p>
<ul>
  <li>Of Myths and Money - true [Attender, Has Given]</li>
  <li>Of Faith and Firsts - true [Attender, Has Given]</li>
  <li>Are You Dealing With Insecurity? - false</li>
  <li>Hallelujah! - false</li>
  <li>The Secret That Could Cost You Your Marriage - true [Married]</li>
  <li>How To Make Your Marriage Better Today - true [Married]</li>
  <li>Extended Family - true [Married, Small Group]</li>
  <li>Immediate Family - true [Married]</li>
  <li>Momentum At Home - true [Small Group]</li>
  <li>Momentum At Work - false</li>
  <li>Rich Fool - false</li>
  <li>Two Debtors - false</li>
</ul>
```

#### AppendWatches

Returns watch information for media elements. Adds properties: `HasWatched`, `WatchLength`, `WatchMap`, `MediaId`, `MediaGuid`, `MediaDefaultFileUrl`, `MediaDefaultThumbnailUrl`, `ResumePercentage`, `ResumeLocationInSeconds`, `WatchInteractionGuid`, `WatchInteractionDateTime`. Optional parameters: AttributeKey, WatchWindow (days or start date).
Example Lava:
```
{% contentchannelitem where:'ContentChannelId == 5' sort:'StartDateTime desc' limit:'3' %}

{% assign messagesWithWatches = contentchannelitemItems | AppendWatches:'Media',30 %}

<ul>
{% for item in messagesWithWatches %}

    <li>
        <h4>{{ item.Title }}</h4>
        <p>
            <strong>Has Watched:</strong> {{ item.HasWatched }}<br>
            <strong>Watch Length:</strong> {{ item.WatchLength }}<br>
            <strong>Watch Map:</strong> {{ item.WatchMap | ToJSON }}<br>
            <strong>Watch Interaction Guid:</strong> {{ item.WatchInteractionGuid }}<br>
            <strong>Media Id:</strong> {{ item.MediaId }}<br>
            <strong>Media Guid:</strong> {{ item.MediaGuid }}<br>
            <strong>Media Default Thumbnail URL:</strong> {{ item.MediaDefaultThumbnailUrl }}<br>
            <strong>Media Default File URL:</strong> {{ item.MediaDefaultFileUrl }}<br>
            <strong>Resume Percentage:</strong> {{ item.ResumePercentage }}<br>
            <strong>Resume Location In Seconds:</strong> {{ item.ResumeLocationInSeconds }}<br>

        </p>
    </li>
{% endfor %}
</ul>
{% endcontentchannelitem %}
```
Example Output:
```
<ul>
<li>
    <h4>Of Myths and Money</h4>
    <p>
        <strong>Has Watched:</strong> true<br>
        <strong>Watch Length:</strong> 11.29<br>
        <strong>Watch Map:</strong> "71,550"<br>
        <strong>Watch Interaction Guid:</strong> 376ac970-b281-425f-860a-3f040ebae97c<br>
        <strong>Media Id:</strong> 1<br>
        <strong>Media Guid:</strong> 198a9b5a-32f0-43b0-89ac-996ef9e3d6b6<br>
        <strong>Media Default Thumbnail URL:</strong> https://rockrms.blob.core.windows.net/videos/rock-sample-video.mp4<br>
        <strong>Media Default Thumbnail URL:</strong> https://placehold.co/1920x1080<br>
        <strong>Resume Percentage:</strong> 11.29<br>
        <strong>Resume Location In Seconds:</strong> 7<br>
    </p>
</li>
<li>
    <h4>Of Faith and Firsts</h4>
    <p>
        <strong>Has Watched:</strong> true<br>
        <strong>Watch Length:</strong> 25.81<br>
        <strong>Watch Map:</strong> "121,200,41,260"<br>
        <strong>Media Id:</strong> 2<br>
        <strong>Media Guid:</strong> c36a0866-d172-4c6f-8ba2-a3d8c0c8b892<br>
        <strong>Media Default Thumbnail URL:</strong> https://rockrms.blob.core.windows.net/videos/rock-sample-video.mp4<br>
        <strong>Media Default Thumbnail URL:</strong> https://placehold.co/1920x1080<br>
        <strong>Resume Percentage:</strong> 58.06<br>
        <strong>Resume Location In Seconds:</strong> 36<br>
    </p>
</li>
</ul>
```

#### AsBoolean

Converts input to a Boolean.
Example Input:
```
"Workflow": {
    "Option": "f"
}
```
Example Lava:
```
{% assign isEnabled = Workflow | Attribute:'Option' | AsBoolean %}

{% if isEnabled == true %}
It is enabled.
{% else %}
Nope, it's disabled.
{% endif %}
```
Example Output:
```
Nope, it's disabled.
```

#### AsDateTime

Converts input to a DateTime.
Example Lava:
```
{{ '1/1/2017' | AsDateTime |  DateAdd:3,'d' }}
```
Example Output:
```
1/4/2017 12:00:00 AM
```

#### AsDecimal

Converts input to a decimal.
Example Input:
```
"Workflow": {
    "Miles": "5.0001"
}
```
Example Lava:
```
{% assign miles = Workflow | Attribute:'Miles' | AsDecimal %}

{% if miles > 5.0 %}
{{ miles }} is more than 5.
{% else %}
Less than 5 miles.
{% endif %}
```
Example Output:
```
5.0001 is more than 5.
```

#### AsDouble

Converts input to a double (less precision than decimal).
Example Input:
```
"Workflow": {
    "Precision": "5.00000000000000009"
}
```
Example Lava:
```
{% assign miles = Workflow | Attribute:'Precision'| AsDouble %}

{% if miles > 5.0 %}
{{ miles }} is more than 5.
{% else %}
Well, it looks like {{ miles }} ({{ miles | ToJSON }}) is less than 5 miles.
{% endif %}
```
Example Output:
```
Well, it looks like 5 (5.0) is less than 5 miles.
```

#### AsGuid

Converts input to a Guid. Returns empty string if invalid.
Example Lava:
```
{% assign guidString1 = '8FEDC6EE-8630-41ED-9FC5-C7157FD1EAA4' %}
{% assign guidString2 = '8FEDC6EE863041ED9FC5C7157FD1EAA4' %}
<p>Value 1: {{ guidString1 }}</p>
<p>Value 2: {{ guidString2 }}</p>
{% if guidString1 != guidString2 %}
<p>Compared as Strings, these values are different.</p>
{% endif %}
{% assign guidValue1 = '8FEDC6EE-8630-41ED-9FC5-C7157FD1EAA4' | AsGuid %}
{% assign guidValue2 = '8FEDC6EE863041ED9FC5C7157FD1EAA4' | AsGuid %}
{% if guidValue1 == guidValue2 %}
<p>Compared as Guids, these values are the same.</p>
{% endif %}
```
Example Output:
```
Value 1: 8FEDC6EE-8630-41ED-9FC5-C7157FD1EAA4
Value 2: 8FEDC6EE863041ED9FC5C7157FD1EAA4
Compared as Strings, these values are different.
Compared as Guids, these values are the same.
```

#### AsInteger

Converts input to an integer.
Example Input:
```
"Workflow": {
    "Quantity": "3"
}
```
Example Lava:
```
{% assign quantity = Workflow | Attribute:'Quantity' | AsInteger %}

{% if quantity > 0 %}
There are more than none.
{% else %}
There are none.
{% endif %}
```
Example Output:
```
There are more than none.
```

#### AsString

Converts input to a string.

#### Base64Encode

Encodes a Rock binary file as Base64. Optional image resize parameters (uses ImageResizer). For text-to-Base64, use `ToBase64` instead.
Example Input:
```
"CurrentPerson": {
    "FullName": "Ted Decker",
    "PhotoId": 85,
    "AnniversaryDate": '',
}
```
Example Lava:
```
Base64Format: {{ CurrentPerson.PhotoId | Base64Encode }}<br/>
Base64Format: {{ CurrentPerson.PhotoId | Base64Encode:'h=25&w=25&mode=max&format=jpg' }}
```
Example Output:
```
Base64Format: /9j/4QAYRXhpZgAASUkqAAgAAAAAAAAAAAAAAP/sABFEdWNreQABAAQAAABb......KWv//Z
Base64Format: /9j/4AAQSkZJRgA...210uf/Z
```

#### Client

Returns browser/client information. Parameters: `'ip'`, `'login'`, `'browser'`, `'parmlist'` (for all server variable keys), or any server variable key.
Example Lava:
```
IP Address: {{ 'Global' | Client:'ip' }} <br />
Login: {{ 'Global' | Client:'login' }} <br />
Browser: {{ 'Global' | Client:'browser' }} <br />
```
Example Output:
```
IP Address: 12.34.55.15 (note this is not guaranteed to be the user's IP address, it could be
the users firewall / proxy server)
Login: tdecker
Browser: Windows 10 Other Chrome 57.0.2987
```

#### CreateEntitySet

Creates an EntitySet from entity identifiers. Parameters: EntityType, ExpireInMinutes (default 20), EntitySetPurposeValueId, Note, ParentEntitySetId.
Example Lava:
```
{% person where:'LastName == "Miller" && FirstName ^= "T"' select:'Id' limit:4 %}
{% assign personIdList = personItems %}
{% endperson %}

{% assign entityTypeId = 15 %}

//- 578 is the "Person Merge Request" EntitySet Purpose
{% assign entitySet = personIdList | CreateEntitySet:entityTypeId,5,578,'Please merge.','' %}
Entity Set (Id={{ entitySet.Id }}) was created with {{ personIdList | Size }} people.
```
Example Output:
```
Entity Set (Id=1) was created with 2 people.
```

#### CreateShortLink

Creates a URL short link. Parameters: token (blank for random), siteId (0 for default), overwrite (default false), randomLength, categoryId, isPinned.
Example Input:
```
"ConnectionOpportunity": {
    "Url": "http://www.rocksolidchurchdemo.com/greeters"
}
```
Example Lava:
```
Your personalized link is:
{{ ConnectionOpportunity | Attribute:'Url' | CreateShortLink }}
```
Example Output:
```
Your personalized link is:
http://www.rocksolidchurchdemo.com/HSGFTSF
```

#### Debug

Outputs debug information about available Lava variables. Optional username parameter to restrict visibility.
Example Lava:
```
{{ 'Lava' | Debug }}
{{ 'Lava' | Debug:'tdecker' }}
{{ CurrentPerson | Debug:'tdecker' }}
```

#### EntityFromCachedObject

Converts a cached entity back to a full database entity object.
Example Lava:
```
{% assign cached = Workflow | Attribute:'TargetCampus','Object' %}
{% assign campus = cached | EntityFromCachedObject %}
{{ campus.Location.FormattedAddress }}
```
Example Output:
```
3120 W Cholla St Phoenix, AZ 85029-4113
```

#### FilterFollowed

Returns only followed entities from an AppendFollowing result.
Example Lava:
```
<p>Entity Command Example</p>
{%- person where:'Id != 1' limit:'3' iterator:'People' -%}
  {%- assign followedItems = People | AppendFollowing | FilterFollowed -%}
<ul>
  {%- for item in followedItems -%}
<li>{{ item.FullName }} - {{ item.IsFollowing }} </li>
  {%- endfor -%}
</ul>
{%- endperson -%}

<p>Persisted Dataset Example</p>
{%- assign data = 'mydataset' | PersistedDataset | AppendFollowing | FilterFollowed -%}
<ul>
{%- for item in data -%}
  <li>{{ item.Title }} - {{ item.IsFollowing }}</li>
{%- endfor -%}
</ul>
```
Example Output:
```
<p>Entity Command Example</p>
<ul>
<li>Ted Decker - true</li>
</ul>

<p>Persisted Dataset Example</p>
<ul>
<li>Friday 3/25 - true</li>
</ul>
```

#### FilterUnfollowed

Returns only unfollowed entities from an AppendFollowing result.
Example Lava:
```
<p>Entity Command Example</p>
{%- person where:'Id != 1' limit:'3' iterator:'People' -%}
  {%- assign followedItems = People | AppendFollowing | FilterUnfollowed -%}
<ul>
  {%- for item in followedItems -%}
<li>{{ item.FullName }} - {{ item.IsFollowing }} </li>
  {%- endfor -%}
</ul>
{%- endperson -%}

<p>Persisted Dataset Example</p>
{%- assign data = 'mydataset' | PersistedDataset | AppendFollowing | FilterUnfollowed-%}
<ul>
{%- for item in data -%}
  <li>{{ item.Title }} - {{ item.IsFollowing }}</li>
{%- endfor -%}
</ul>
```
Example Output:
```

<ul> <li>Cindy Decker - false</li> <li>Noah Decker - false</li> </ul> <p>Persisted Dataset Example</p> <ul> <li>Saturday 3/26 - false</li> <li>Sunday 3/27 - false</li> </ul>
```

#### FromBase64

Decodes a Base64 string. Pass `true` for human-readable string output; otherwise returns a byte array.
Example Input:
```
"Object": {
    "Id": 23,
    "Data": "VGVkIERlY2tlcg=="
}
```
Example Lava:
```
{{ Object.Data | FromBase64:true }}
```
Example Output:
```
Ted Decker
```

#### FromCache

Reads objects from Rock's cache. Pass an Id, Guid, or `'All'`. Supported types: DefinedValue, DefinedType, Campus, Category, GroupType, Page, Block, BlockType, EventCalendar, Attribute, NoteType, ContentChannel, EntityType.
Example Input:
```
"CurrentPerson": {
    "CampusId": "2"
}
```
Example Lava:
```
<h4>Current Person's Campus</h4>

{% assign campus = CurrentPerson.PrimaryCampusId | FromCache:'Campus' %}
Current Person's Campus Is: {{ campus.Name }}

{% assign allCampuses = 'All' | FromCache:'Campus' %}
<h4>All Campuses</h4>
<ul>
{% for c in allCampuses %}
<li>{{ c.Name }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<h4>Current Person's Campus</h4>

Current Person's Campus Is: West-side Campus

<h4>All Campuses</h4>

<ul>
<li>Main Campus</li>
<li>West-side Campus</li>
</ul>
```

#### FromIdHash

Converts an IdHash string back to an entity Id. Starting in v17.3, also passes through non-hashed integer strings.
Example Lava:
```
//- Get the IdHash for Ted Decker.
{% person where:'LastName == "Decker" && NickName =="Ted"' %}
...
   {% assign idHash = person.IdKey %}
...
{% endperson %}
Ted's IdHash is: {{ idHash }}.<br>
//- Pass the IdHash to the FromIdHash filter to get the person's Id.
{% assign personFromHash = idHash | FromIdHash | PersonById %}
Hello {{ personFromHash.NickName }}!
```
Example Output:
```
Ted's IdHash is: 5R6B5VmEYw.<br>
Hello Ted!
```

#### FromJSON

Parses a JSON string into a Lava object.
Example Lava:
```
{% capture jsonString %}
{
"Name": "Ted Decker",
"ServingTimes": [
  {
    "Date": "Friday 3/25",
    "Times": [
      "5:30 pm",
      "7:00 pm"
    ]
  },
  {
    "Date": "Saturday 3/26",
    "Times": [
      "4:30 pm",
      "6:00 pm"
    ]
  },
  {
    "Date": "Sunday 3/27",
    "Times": [
      "6:30 am sunrise",
      "9:00 am",
      "10:30 am",
      "12:00 pm"
    ]
  }
]
}
{% endcapture %}


{% assign jsonObject = jsonString | FromJSON %}
{{ jsonObject.Name }}
<ul>
{% for servingTime in jsonObject.ServingTimes %}
  <li>{{ servingTime.Date }}</li>
{% endfor %}
</ul>
```
Example Output:
```
Ted Decker
<ul>
<li>Friday 3/25</li>
<li>Saturday 3/26</li>
<li>Sunday 3/27</li>
</ul>
```

#### GroupByGuid

Converts a GroupGuid to a full Group object.
Example Input:
```
"GroupMember" {
    "Group": {
        Guid: "8fedc6ee-8630-41ed-9fc5-c7157fd1eaa4"
    }
    ...
}
```
Example Lava:
```
{% assign group = GroupMember.Group.Guid | GroupByGuid %}

Group Name: {{ group.Name }}!
```
Example Output:
```
Group Name: Ushers
```

#### GroupById

Converts a GroupId to a full Group object.
Example Input:
```
"GroupMember" {
    "GroupId": 234
    ...
}
```
Example Lava:
```
{% assign group = GroupMember.GroupId | GroupById %}

Group Name: {{ group.Name }}!
```
Example Output:
```
Group Name: Ushers
```

#### GuidToId

Converts one or more Guid identifiers to Id values. Requires EntityType parameter.
Example Lava:
```
{% assign personGuid = '8fedc6ee-8630-41ed-9fc5-c7157fd1eaa4' %}
{% assign personEntityTypeId = '72657ed8-d16e-492e-ac12-144c5e7567e7' | GuidToId:'EntityType' %}
{% assign personId = personGuid | GuidToId:personEntityTypeId %}
Ted Decker's record can be identified by Guid '{{ personGuid }}' or Id '{{ personId }}'.
```
Example Output:
```
Ted Decker's record can be identified by Guid '8fedc6ee-8630-41ed-9fc5-c7157fd1eaa4' or Id '1'.
```

#### HasRightsTo

Checks security on a model. Can accept full models or just an Id with entity type.
Example Lava:
```
{{ 12 | HasRightsTo:'Edit','Rock.Model.Group' }}
```
Example Output:
```
true
```

#### HmacSha1

Creates a SHA-1 HMAC hash. Pass the secret key as a parameter.
Example Lava:
```
{% assign my_secret_string = 'RockIsAwesome!' | HmacSha1:'secret_key' %}
My encoded string is: {{ my_secret_string }}
```
Example Output:
```
My encoded string is: 17dbf467d8f49e9f541c7af8adf26c8422bdb342
```

#### HmacSha256

Creates a SHA-256 HMAC hash.
Example Lava:
```
{% assign my_secret_string = 'RockIsAwesome!' | HmacSha256:'secret_key' %}
My encoded string is: {{ my_secret_string }}
```
Example Output:
```
My encoded string is: 3518d7aa4ad81041e14033f2bbfa317e8f2f5aa26d6f48f719783aeaebe481ae
```

#### ImageUrl

Creates an image URL from an Id or Guid. Optional fallback URL and root URL parameters.
Example Lava:
```
{% contentchannelitem id:'1' %}
<img src="{{ contentchannelitem | Attribute:'Image','RawValue' | ImageUrl }}" />

<img src="{{ contentchannelitem | Attribute:'Image','RawValue' | ImageUrl:'https://via.placeholder.com/150', true }}" />
{% endcontentchannelitem %}

<img src="{{ item | Attribute:'Image','RawValue' | ImageUrl:'https://via.placeholder.com/150' }}" />
```
Example Output:
```
<img src="/GetImage.ashx?Guid=0241ED2F-B527-424C-917C-1142A398711F">

<img src="http://www.rocksolidchurchdemo.com/GetImage.ashx?Guid=0241ED2F-B527-424C-917C-1142A398711F">

<img src="https://via.placeholder.com/150">
```

#### IsFollowed

Tests if an entity is followed by the current person. Returns boolean. Optional purpose key (v13.4) and person override.
Example Lava:
```
{% assign group = 56 | GroupById %}
{% assign followed = group | IsFollowed %}
{% if followed == true %}
  <p>You are following the group {{ group.Name }}.</p>
{% else %}
  <p>You are not currently following the group {{ group.Name }}.</p>
{% endif %}
```
Example Output:
```
<p>You are following the group Serving Teams.</p>
```

#### IsInDataView

Tests if an entity (or entity Id) is in a specified Data View. Returns boolean.
Example Input:
```
"CurrentPerson": {
    ...
}

"Group" {
    "Id": 111,
    "Name" : "Decker Group"
    ...
}
```
Example Lava:
```
{% assign inDataView = CurrentPerson.Id | IsInDataView:'1337' %}
{% if inDataView %}
   That person is in the 1337 data view.
{% endif %}

{% assign inDataView = Group | IsInDataView:'230' %}
{% if inDataView %}
   The '{{Group.Name}}' is in the 230 data view.
{% endif %}
```
Example Output:
```
That person is in the 1337 data view.

The 'Decker Group' is in the 230 data view.
```

#### Md5

Creates an MD5 hash.
Example Input:
```
"Person": {
    "Email": "hi@example.com"
}
```
Example Lava:
```
<img src="https://www.gravatar.com/avatar/{{ Person.Email | Trim | Downcase | Md5 }}" />
```
Example Output:
```
<img src="https://www.gravatar.com/avatar/767fc9c115a1b989744c755db47feb60">
```

#### MetersToMiles

Converts meters to miles. Optional precision parameter (default 1).
Example Lava:
```
7,623 meters is: {{ 7623 | MetersToMiles:2 }} miles
```
Example Output:
```
7,623 meters is: 4.74 miles
```

#### MilesToMeters

Converts miles to meters.
Example Lava:
```
2.4 miles is {{ 2.4 | MilesToMeters }} meters
```
Example Output:
```
2.4 miles is 3862 meters
```

#### Notes

Retrieves notes for an entity. Parameters: NoteTypeId(s) (comma-delimited), SortOrder (`'asc'`/`'desc'`, default `'desc'`), Count. Security is checked based on the current user.
Example Input:
```
"CurrentPerson": {
    ...
}
```
Example Lava:
```
{% assign notes = CurrentPerson | Notes:'4,5','asc',2 %}

Notes
{% for note in notes %}
<p>{{ note.Text }} </p>
{% endfor %}
```
Example Output:
```
Notes
<p>Note one.</p>
<p>Note two.</p>
```

#### Page

Returns page information: `'Title'`, `'BrowserTitle'`, `'Description'`, `'Url'`, `'Id'`, `'Host'`, `'Path'`, `'SiteName'`, `'SiteId'`, `'Theme'`, `'Layout'`, `'Scheme'`, `'Cookies'`, `'QueryString'`.
Example Lava:
```
Title: {{ 'Global' | Page:'Title' }} <br />
BrowserTitle: {{ 'Global' | Page:'BrowserTitle' }} (v9) <br />
Description: {{ 'Global' | Page:'Description' }} (v7 +)<br />
URL: {{ 'Global' | Page:'Url' }} <br />
Page Id: {{ 'Global' | Page:'Id' }} <br />
Host: {{ 'Global' | Page:'Host' }} <br />
Path: {{ 'Global' | Page:'Path' }} <br />
Site Name: {{ 'Global' | Page:'SiteName' }} <br />
Site Id: {{ 'Global' | Page:'SiteId' }} <br />
Theme: {{ 'Global' | Page:'Theme' }} <br />
Layout: {{ 'Global' | Page:'Layout' }} <br />
Scheme: {{ 'Global' | Page:'Scheme' }} <br />
Cookies: {{ 'Global' | Page:'Cookies' }} (v8.4)<br />

{% assign queryParms = 'Global' | Page:'QueryString'  %}
Query Parms <br />
{% for item in queryParms %}
{% assign kvItem = item | PropertyToKeyValue %}
{{ kvItem.Key }}: {{ kvItem.Value }} <br />
{% endfor %}
```
Example Output:
```
Title: Home
BrowserTitle: Home of the Browser's Title
Description: This is the page description
URL: http://localhost:6229/page/1
Page Id: 1
Host: localhost
Path: /page/1
Site Name: External Website
Site Id: 3
Theme: Stark
Layout: Homepage
Scheme: http

Query Parms
Id: 12
SomeOtherId: 23
```

You can also chain `Page:'QueryString'` with `Property:'X'` for a declarative read of a single key without iterating:
```
{% assign id = 'Global' | Page:'QueryString' | Property:'Id' %}
The Id is {{ id }}
```
Example Output: `The Id is 12`

**Caveat:** The Page filter requires `RockPage` context. Inside a Lava Application Endpoint invoked via HTTP (HTMX, direct URL), it returns null. When an endpoint is invoked via `{% renderlavaendpoint %}` from a Block, the filter inherits the Block's context — see the `surface-helix` skill's `Lava-with-Helix.md` > "Merge Fields Inside Lava Application Endpoints" for the full inheritance rule.

#### PageParameter

Returns a page parameter value (integer if numeric, string otherwise).
Example Url:
```
http://rock.rocksolidchurchdemo.com/Group/12
```
Example Lava:
```
The Group Id passed in from the URL is: {{ 'Global' | PageParameter:'GroupId' }}
```
Example Output:
```
The Group Id passed in from the URL is: 12
```

**Caveat:** The PageParameter filter requires `RockPage` context. Inside a Lava Application Endpoint invoked via HTTP (HTMX, direct URL), both filter form (`'Global' | PageParameter:'X'`) and dot-notation form (`PageParameter.X`) return null. When an endpoint is invoked via `{% renderlavaendpoint %}` from a Block, it inherits the Block's context — see the `surface-helix` skill's `Lava-with-Helix.md` > "Merge Fields Inside Lava Application Endpoints" for the full inheritance rule.

#### PageRedirect

Redirects to the provided URL. Adding `?Redirect=false` to the query string prevents the redirect and shows the link instead.
Example Input:
```
"Event": {
    "ExternalUrl": "http://www.rockrms.com",
}
```
Example Lava:
```
{% if CurrentPersonCanEdit %}
<p class="alert alert-warning">If you could not edit you would be redirected to: <a href="{{ Event.ExternalUrl }}">{{ Event.ExternalUrl }}</a>.</p>
{% else %}
{{ Event.ExternalUrl | PageRedirect }}
{% endif %}
```

#### PageRoute

Converts a page identifier to a URL. Parameters can be passed as `'key1=value1^key2=value2'`.
Example Lava:
```
{{ 'Global' | Attribute:'WorkflowEntryPage','RawValue' | PageRoute:'WorkflowTypeId=10^WorkflowId=324' }}
```
Example Output:
```
/WorkflowEntry/10/324
```

#### PersistedDataset

Returns Persisted Dataset data as a Lava object. Note: cached datasets share the in-memory instance.
Example Lava:
```
{% assign data = 'mydataset' | PersistedDataset %}
<ul>
{% for item in data %}
  <li>{{ item.Title }}</li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>Friday 3/25</li>
<li>Saturday 3/26</li>
<li>Sunday 3/27</li>
</ul>
```

#### Postback

Wires up ASP.NET postbacks. Only available on blocks that provide Postback Commands.
Example Input:
```
"Group": {
    "Id": 1
}
```
Example Lava:
```
<a class="btn btn-default btn-sm pull-right" href="#" onclick="{{ Group.Id | Postback:'EditGroup' }}">Edit</a>
```
Example Output:
```
<a class="btn btn-default btn-sm pull-right" href="#" onclick="javascript:__doPostBack('ctl00_main_ctl33_ctl01_ctl06_upnlContent','EditGroup^1'); return false;">Edit</a>
```

#### Property

Returns a property of an object. Supports dot notation.
Example Input:
```
"CurrentPerson": {
    "FullName": "Ted Decker",
    "AnniversaryDate": '',
}
```
Example Lava:
```
{% assign campusLeader = CurrentPerson | Campus | Property:'LeaderPersonAlias.Person' %}

{{ campusLeader.FullName }}
```
Example Output:
```
Ted Decker
```

#### PropertyToKeyValue

Converts a property to a key/value pair for iteration.
Example Input:
```
"CurrentPerson": {
    "Attributes": [
        {
            "FavoriteMovie": "Star Wars"
        },
        {
            "FavoriteStarWarsEpisode": "Episode VI"
        },
        {
            "FavoriteStarWarsCharacter": "Boba Fett"
        }
    ]
}
```
Example Lava:
```
<ul>
{% for attribute in Attributes %}
{% assign attributeParts = attribute | PropertyToKeyValue %}

<li>{{ attributeParts.Key | Humanize | Capitalize }}: {{ attributeParts.Value }} </li>
{% endfor %}
</ul>
```
Example Output:
```
<ul>
<li>Favorite Movie: Star Wars</li>
<li>Favorite Star Wars Episode: Episode VI</li>
<li>Favorite Star Wars Character: Boba Fett</li>
</ul>
```

#### ReadCookie

Reads an HTTP cookie value by name.
Example Lava:
```
You recently told us that your favorite cookie is {{ 'FavoriteCookie' | ReadCookie }} and your favorite color is {{ 'FavoriteColor' | ReadCookie }}.
```
Example Output:
```
You recently told us that your favorite cookie is choc-chip and your favorite color is green.
```

#### RenderStructuredContentAsHtml

Renders structured content (from StructuredContentEditor) as HTML.
Example Input:
```
"StructuredContent": {
    ""time"":1676039688279,
    ""blocks"":[
        {
            ""id"":""a2FYCrj8NG"",
            ""type"":""header"",
            ""data"":{
                ""text"":""Things I love."",
                ""level"":2
            }
        },
        {
            ""id"":""egdM-bpIfg"",
            ""type"":""list"",
            ""data"":{
                ""style"":""ordered"",
                ""items"":[
                    {
                        ""content"":""Reading a good book."",
                        ""items"":[

                        ]
                    },
                    {
                        ""content"":""Helping others."",
                        ""items"":[

                        ]
                    },
                    {
                        ""content"":""Seeing other people laugh."",
                        ""items"":[

                        ]
                    }
                ]
            }
        }
    ],
    ""version"":""2.22.1""
}
```
Example Lava:
```
{{ StructuredContent | RenderStructuredContentAsHtml }}
```
Example Output:
```
<h2>Things I love.</h2>
<ol>
<li>Reading a good book.</li>
<li>Helping others.</li>
<li>Seeing other people laugh.</li>
</ol>
```

#### ResolveRockUrl

Resolves `~/` (app root) and `~~/` (theme root) in URLs.
Example Input:
```
"Person": {
    "Id": 12623
}
```
Example Lava:
```
{% assign personProfilePage = '~/Person/' %}

The link for this person is: '{{ personProfilePage | ResolveRockUrl }}{{ CurrentPerson.Id }}'
```
Example Output:
```
The link for this person is: '/Rock/Person/12623'
( assumes Rock was stored in a virtual directory called 'Rock')
```

#### RockInstanceConfig

Returns instance configuration: `'ApplicationDirectory'`, `'PhysicalDirectory'`, `'MachineName'`, `'IsClustered'`, `'SystemDateTime'`.
Example Lava:
```
Application Directory: {{ 'ApplicationDirectory' | RockInstanceConfig }}
Physical Directory: {{ 'PhysicalDirectory' | RockInstanceConfig }}
Machine Name: {{ 'MachineName' | RockInstanceConfig }}
Is Clustered: {{ 'IsClustered' | RockInstanceConfig }}
System Date/Time: {{ 'SystemDateTime' | RockInstanceConfig | Date:'yyyy-MM-dd HH:mm:ss' }}
```
Example Output:
```
Application Directory: D:\inetpub\wwwroot\Rock\bin
Physical Directory: D:\inetpub\wwwroot\Rock\bin
Machine Name: MYROCKSERVER
Is Clustered: false
System Date/Time: 2020-11-17 10:30:01
```

#### RunLava

Executes Lava code contained in a string. Inherits the parent's security context (including enabled commands).
Example Input:
```
{
"Value": "{% assign test = 'Hello World' %}{{ test }}"
}
```
Example Lava:
```
<p>
{{ Value }}
</p>
<p>
{{ Value | RunLava }}
</p>
```
Example Output:
```
<p>
{% assign test = 'Hello World' %}{{ test }}
</p>
<p>
Hello World
</p>
```

#### SetPageTitle

Sets the page title. Optional parameter: `'BrowserTitle'` or `'PageTitle'` to target only one (v9.0+).
Example Input:
```
"CurrentPerson": {
    "FullName": "Ted Decker",
    ...
}
```
Example Lava:
```
{% capture pageTitle %}Current Person - {{ CurrentPerson.FullName }}{% endcapture %}
{{ pageTitle | SetPageTitle }}
```
Example Output:
```
The page title would be: 'Current User - Ted Decker'.
```

#### SetUrlParameter

Sets a URL parameter and returns the updated URL. Use `'Current'` as input for the current page URL. Optional output format: `'absolute'` or `'relative'`.
Example Lava:
```
Example 1:
{{ 'https://rocksolidchurchdemo.com/reporting/reports/12' | SetUrlParameter:'ReportId','155' }}

Example 2:
{{ 'https://rocksolidchurchdemo.com/reporting/reports' | SetUrlParameter:'CategoryId','101' }}
```
Example Output:
```
Example 1:<br>
https://rocksolidchurchdemo.com/reporting/reports/155
<hr>
Example 2:<br>
https://rocksolidchurchdemo.com/reporting/reports?CategoryId=101
```

##### Inside a Dynamic Data block, every "current URL" source is the API endpoint

`SetUrlParameter` is fine. What is not fine is the thing you feed it. A Dynamic Data block renders its Lava inside an AJAX **BlockActions** call, so every filter that reports "the page the reader is on" reports the endpoint the block was fetched from instead.

Measured on an Obsidian Dynamic Data block (11-SEP-2026):

| Lava | Returns |
|---|---|
| `'Global' \| Page:'Url'` | `https://{your-rock-host}/api/v2/BlockActions/{blockGuid}/{actionGuid}/GetDynamicData` |
| `'Current' \| SetUrlParameter:'CampusId','0'` | that same API URL, with `?CampusId=0` appended |
| `'Global' \| Page:'Path'` | `/api/v2/BlockActions/{blockGuid}/{actionGuid}/GetDynamicData` |
| `'Global' \| Page:'QueryString'` | empty string |

Nothing errors and nothing comes back empty, which is what makes this expensive to find: `SetUrlParameter` does its job correctly on the wrong URL, and the link renders as a perfectly ordinary anchor that navigates into the API and returns JSON.

The workaround is a **relative query string** — `<a href="?Month=2026-08&CampusId=6">` — which the browser resolves against the document URL rather than against anything Lava knows. The trade is that you give up what `SetUrlParameter` was doing for you: choosing `?` versus `&`, and replacing an existing parameter instead of appending a duplicate. So write the whole query string at every link, and only in a block whose parameter set is small enough to enumerate.

`{% capture %}` is the right tool for building those, and each one belongs on a single line — whitespace inside a capture survives into the value, and a newline in the middle of an `href` is a broken link.

```
{% capture url_PrevMonth %}?Month={{ var_PrevMonthKey }}{% if var_IsCampusView %}&CampusId={{ input_CampusId }}{% endif %}{% endcapture %}
```

This applies to the Dynamic Data block specifically because of how it re-renders. A plain HTML Content block renders during the page request, where `Page:'Url'` is the page URL — an HTML Content block's links built with `SetUrlParameter` work fine (see the `surface-htmlcontent` skill). The relative form is worked through in the `surface-dynamicdata` skill's `Current-Url-Is-BlockActions.md`.

#### Sha1

Creates a SHA-1 hash.
Example Lava:
```
{% assign my_secret_string = 'RockIsAwesome!' | Sha1 %}
My encoded string is: {{ my_secret_string }}
```
Example Output:
```
My encoded string is: 845b0f246f221697761d085847fbc056652d03d0
```

#### Sha256

Creates a SHA-256 hash.
Example Lava:
```
{% assign my_secret_string = 'RockIsAwesome!' | Sha256 %}
My encoded string is: {{ my_secret_string }}
```
Example Output:
```
My encoded string is: 06530e8aabeb6becaabcd0c357134f3cd0a340d87500002b0a14929d92e0ac78
```

#### ToBase64

Encodes a string (UTF-8) or byte collection as Base64. For binary files in Rock, use `Base64Encode` instead.
Example Input:
```
"CurrentPerson": {
    "FullName": "Ted Decker",
    "AnniversaryDate": '',
}

"BinaryData": [0, 1, 2, 3, 255]
```
Example Lava:
```
ToBase64: {{ CurrentPerson.FullName | ToBase64 }}<br/>
ToBase64: {{ BinaryData | ToBase64 }}<br/>
```
Example Output:
```
ToBase64: VGVkIERlY2tlcg==
ToBase64: AAECA/8=
```

#### ToIdHash

Returns an alphanumeric IdHash string for a Rock entity. Provides non-sequential identifiers for security.
Example Lava:
```
{% person id:'5' %}
   {{ person.NickName }}'s IdHash is '{{ person | ToIdHash }}' and Id is {{ person.Id }}.
{% endperson %}
```
Example Output:
```
Ted's IdHash is '5R6B5VmEYw' and Id is 5.
```

#### ToJSON

Returns a JSON representation of an object.
Example Input:
```
"CurrentPerson": {
    "NickName": "Ted",
    "LastName": "Decker"
}
```
Example Lava:
```
{{ CurrentPerson | ToJSON }}
```
Example Output:
```
{
    "NickName": "Ted",
    "LastName": "Decker"
}
```

#### UniqueIdentifier

Generates a new GUID string.
Example Lava:
```
{{ '' | UniqueIdentifier }}
```
Example Output:
```
E9206998-3Fb5-4ED1-A372-C593A79C7DD1
```

#### UpdatePersistedDataset

Triggers a persisted dataset to refresh. Optional parameter to delay until persistence completes.
Example Lava:
```
{{ 'DataSetKey' | UpdatePersistedDataset }}
```

#### UploadBinaryFile

Uploads content into a Rock Binary File. Parameters: binaryFileTypeId, filename, mimeType (default `'application/octet-stream'`), format (`'raw'` or `'base64'`), isTemporary (default false), binaryFileId (to update existing).
Example Lava:
```
{% assign content = 'Hello Rock Community' %}
{% assign file = content | UploadBinaryFile:'3', 'hello.txt', 'text/plain' %}
<a href="/GetFile.ashx?Guid={{ file.Guid }}">Download</a>
```
Example Output:
```
<a href="/GetFile.ashx?Guid=48a414ab-23b8-4700-9dda-00c156adb360">Download</a>
```

#### Url

Extracts URL parts: `'host'`, `'port'`, `'segments'`, `'scheme'`/`'protocol'`, `'localpath'`, `'pathandquery'`, `'queryparameter'` (with optional key), `'url'`.
Example Lava:
```
{% assign url = 'https://www.rockrms.com/WorkflowEntry/35?PersonId=2' %}
Testing URL {{ url }}
host - {{ url | Url:'host' }}
port - {{ url | Url:'port' }}
segments - {{ url | Url:'segments' | ToJSON }}
scheme - {{ url | Url:'scheme' }}
protocol - {{ url | Url:'protocol' }}
localpath - {{ url | Url:'localpath' }}
pathandquery - {{ url | Url:'pathandquery' }}
queryparameter no key - {{ url | Url:'queryparameter' }}
queryparameter with key - {{ url | Url:'queryparameter','PersonId' }}
url - {{ url | Url:'url' }}
invalid_part - {{ url | Url:'invalid_part' }}
```
Example Output:
```
Testing URL https://www.rockrms.com/WorkflowEntry/35?PersonId=2
host - www.rockrms.com
port - 443
segments - [ "/", "WorkflowEntry/", "35" ]
scheme - https
protocol - https
localpath - /WorkflowEntry/35
pathandquery - /WorkflowEntry/35?PersonId=2
queryparameter no key -
queryparameter with key - 2
url - https://www.rockrms.com/WorkflowEntry/35?PersonId=2
invalid_part -
```

#### WriteCookie

Sets an HTTP cookie. Parameters: value, optional expiryInMinutes.
Example Lava:
```
{{ 'FavouriteCookie' | WriteCookie:'choc-chip','5' }}
{{ 'FavouriteColor' | WriteCookie:'green' }}
```

#### XamlWrap

Wraps content in CDATA tags for XML compliance.
Example Input:
```
"Item": {
    "Id": 12,
    "Content": '# Heading
The quick brown folx jumped over the lazy dog.
',
}
```
Example Lava:
```
<Rock:Markdown>{{ Item.Content | XamlWrap }}</Rock:Markdown>
```
Example Output:
```
<Rock:Markdown><![CDATA[The quick brown folx jumped over the lazy dog.]]</Rock:Markdown>
```


---


## Lava Tags

Tags control logic and flow within templates.


### Assign / Capture

`assign` creates a variable:
```
{% assign name = 'Ted Decker' %}
{{ name }}
```
Variable names must not contain spaces. Single quotes in raw strings must be encoded as `&#39` or use double quotes for the string.

`capture` stores rendered content as a variable instead of displaying it:
```
{% capture message %}{{ Person.NickName }} is a {{ Person.ConnectionStatusValue.Value }}{% endcapture %}
{{ message }}
```


### If / Else

Basic conditional logic:
```
{% if Person.NickName == 'Ted' %}
    Great Guy!
{% elsif Person.NickName == 'Alisha' %}
    Great Gal!
{% else %}
    Who are you?
{% endif %}
```

Both `elseif` and `elsif` are accepted (no space).

**Warning:** Filters cannot be used directly inside `if` statements. Create a variable first.

#### Operators

| Operator | Meaning |
|----------|---------|
| `==` | Equals |
| `!=` | Not equal |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal |
| `<=` | Less than or equal |
| `or` | Logical OR |
| `and` | Logical AND |
| `contains` | Substring check (case-sensitive) |

#### Checking for Existence

Test if a property exists:
```
{% if Person.CallSign %}
    You have a call sign!
{% endif %}
```

Test if a property is empty:
```
{% if Person.MiddleName == '' %}
    No middle name!
{% endif %}
```

Combined existence and non-empty check:
```
{% if Person.NickName and Person.NickName != empty %}
```

Check for an empty array:
```
{% if Person.PhoneNumbers != empty %}
    You have phone numbers
{% endif %}
```

#### Type Conversion for Comparisons

Always convert values to the correct type before comparing:
```
{% assign isTrained = CurrentPerson | Attribute:'IsTrained' | AsBoolean %}
{% assign age = CurrentPerson | Attribute:'AgeInYears' | AsInteger %}
{% assign date = CurrentPerson | Attribute:'BaptismDate' | AsDateTime %}
```

Without conversion, string "3" is considered greater than number 10 (lexicographic comparison).

Boolean attributes can be `true`, `false`, or `null` (no value stored).

#### Operator Precedence

Operators are evaluated right to left. Parentheses are NOT supported and will break the tag.
```
{% if true or false and false %}
  This evaluates to true — the 'and' is checked first.
{% endif %}
```


### Unless

The inverse of `if`:
```
{% unless Person.NickName == '' %}
    Hi {{ Person.NickName }}
{% endunless %}
```


### Return

Stops all Lava processing (early exit pattern):
```
{% if currentRegistrationCount >= maxRegistrationsAllowed %}
    Sorry, this event is full.
    {% return %}
{% endif %}

Welcome! Let's get you registered.
```


### Case

Switch-style conditional:
```
{% case Person.NickName %}
{% when 'Ted' %}
    Hi Ted!
{% when 'Alisha' or 'Bill' %}
    Hello Marbles!
{% else %}
    Have we met?
{% endcase %}
```


### Cycle

Alternates between values in order. Useful inside `for` loops:
```
{% cycle 'red', 'green', 'blue' %}
```

Named cycle groups allow multiple independent cycles:
```
{% cycle 'colors': 'red', 'green', 'blue' %}
{% cycle 'numbers': 'one', 'two', 'three' %}
```


### For

#### Basics
```
{% for campus in Campuses %}
    {{ campus.Name }}
{% endfor %}
```

#### Helper Variables

| Variable | Meaning |
|----------|---------|
| `forloop.length` | Total iterations |
| `forloop.index` | Current index (1-based) |
| `forloop.index0` | Current index (0-based) |
| `forloop.rindex` | Iterations remaining |
| `forloop.rindex0` | Iterations remaining (0-based) |
| `forloop.first` | True if first iteration |
| `forloop.last` | True if last iteration |

Nested loop parent values: `{{ parentloop.index }}`

#### Control Attributes

| Attribute | Meaning |
|-----------|---------|
| `limit:int` | Limit number of iterations |
| `offset:int` | Start at the nth item |
| `reversed` | Reverse iteration order |

```
{% for campus in Campuses limit:2 offset:1 reversed %}
```

#### Quasi WHILE Loop

Iterate over a numeric range:
```
{% assign campusCount = Campuses | Size | Minus:1 %}
{% for i in (0..campusCount) %}
    {{ Campuses[i].Name }}
{% endfor %}
```

#### Break and Continue

`break` exits the loop; `continue` skips to the next iteration:
```
{% for phone in Person.PhoneNumbers %}
    {% if phone.NumberTypeValue.Value == 'Mobile' %}{% continue %}{% endif %}
    {{ phone.NumberTypeValue.Value }}: {{ phone.NumberFormatted }}
{% endfor %}
```

**Note:** Both tags, if used outside a `for` loop, abort the entire rendering silently.

#### FOR Else

Provides content when the collection is empty:
```
{% for group in groups %}
    {{ group.Name }}
{% else %}
    There are no groups available.
{% endfor %}
```


### Include

Includes an external Lava file:
```
{% include '~~/Assets/Lava/PageNav.lava' %}
```
`~~` = current theme directory, `~` = application root.


### Raw

Disables Lava processing (useful for Mustache.js, Handlebars.js, documentation, or email templates):
```
{% raw %}
    {{ See }} ← displayed literally, not processed
{% endraw %}
```


### Lava Tag

Reverses the default: everything is code unless explicitly output with `echo`:
```
{% lava
    case numberOfGroups
        when 0
            assign recommendedNumber = false
            echo "It's time to get into a group"
        when 1
            assign recommendedNumber = true
            echo "It's great that you're in a group!"
    endcase %}
```

Tips:
- Every tag still needs its end tag.
- `echo variableName` outputs a variable's value.
- You cannot echo a variable and literal text in one `echo` tag; use separate lines.


---


## Lava Commands

Commands extend Lava with powerful capabilities. They must be enabled via block settings or the "Default Enabled Lava Commands" Global Attribute.

Full list of commands:
1. adaptivemessage
2. cache
3. calendarevents
4. dbtransaction
5. entity
6. deleteentity
7. modifyentity
8. eventscheduledinstance
9. httpresponse
10. interactioncontentchannelitemwrite
11. interactionintentwrite
12. interactionwrite
13. javascript
14. personalize
15. printzpl
16. observe
17. search
18. setculture
19. sql
20. stylesheet
21. taglist
22. webrequest
23. workflowactivate
24. renderlavaendpoint


### SQL Command

Runs T-SQL and returns results in a Lava variable.

#### Basic Usage
```
{% sql %}
    SELECT [NickName], [LastName] FROM [Person]
    WHERE [LastName] = 'Decker'
{% endsql %}

{% for item in results %}
    {{ item.NickName }} {{ item.LastName }}
{% endfor %}
```

#### With Lava Variables
Be very careful about SQL injection:
```
{% assign lastName = 'Decker' %}

{% sql %}
    SELECT [NickName], [LastName] FROM [Person]
    WHERE [LastName] = '{{ lastName }}'
{% endsql %}
```

#### UPDATE / DELETE Statements
Use the `statement:'command'` parameter to get row counts:
```
{% sql statement:'command' %}
    DELETE FROM [DefinedValue] WHERE [Id] IN (186,187)
{% endsql %}

{{ results }} {{ 'record' | PluralizeForQuantity:results }} were deleted.
```

**Note:** Even for INSERT/UPDATE, you need to set a `results` attribute. Cache is not automatically flushed for direct SQL changes. DROP statements do work — be careful.

#### Changing the Return Variable
```
{% sql return:'mylist' %}
    SELECT ... FROM ...
{% endsql %}

{% for item in mylist %}...{% endfor %}
```

#### SQL Parameters
Prevent SQL injection by using parameterized queries. Any `parameter:'value'` pair (except `statement` and `return`) becomes a SQL parameter referenced with `@`:
```
{% sql name:'{{ lastName }}' %}
    SELECT [NickName], [LastName] FROM [Person]
    WHERE [LastName] = @name
{% endsql %}
```

#### Timeout
```
{% sql timeout:'60' %}
    SELECT ... FROM [Interaction] ...
{% endsql %}
```

#### Aggregate Functions
Aggregated fields must have an alias:
```
{% sql %}
    SELECT MIN(gm.[CreatedDateTime]) AS "Date"
    FROM [GroupMember] AS gm
    ...
{% endsql %}

{% for item in results %}
    {{ item.Date }}
{% endfor %}
```


### Entity Command

Retrieves data from any Rock entity using a consistent pattern.

#### Basic Usage
```
{% person where:'LastName == "Decker"' %}
    {% for person in personItems %}
        {{ person.FullName }}
    {% endfor %}
{% endperson %}
```

The iterator is named `<entityName>Items` by default.

Pro Tip — open and close the entity command, then iterate separately:
```
{% person where:'LastName == "Decker"' %}
{% endperson %}

{% for person in personItems %}
    {{ person.FullName }}
{% endfor %}
```

#### Parameters

##### Where
Filters by properties or attributes:
```
where:'LastName == "Decker" && Position == "Outreach Pastor"'
```

| Symbol | Meaning |
|--------|---------|
| `==` | Equal |
| `!=` | Not equal |
| `^=` | Starts with |
| `*=` | Contains |
| `*!` | Does not contain |
| `_=` | Is blank |
| `_!` | Is not blank |
| `>` | Greater than |
| `>=` | Greater than or equal |
| `<` | Less than |
| `<=` | Less than or equal |
| `$=` | Ends with |
| `&&` | AND |
| `\|\|` | OR |

**Tip:** `_=` and `_!` ignore the right side and only evaluate the left for null/blank.

Limitation: Nested/grouped conditions (parentheses) are not supported in `where`.

##### Id
Query a single entity by Id:
```
{% person id:'3' %}
    {{ person.FullName }}
{% endperson %}
```
When a single value is returned, you can use the entity name directly without a `for` loop.

##### Ids
Query multiple entities:
```
{% person ids:'3,4,5,50' %}
```

##### DataView
Filter by a Rock Data View:
```
{% person dataview:'1' %}
```

##### EntitySearch
Use a pre-defined entity search, optionally combined with an `expression`:
```
{% person entitysearch:'decker-family' expression:'NickName != "Cindy"' %}
```

##### Expression
More complex filtering (supports navigation properties and aggregates, but not attributes):
```
{% financialtransactiondetail expression:'Transaction.AuthorizedPersonAlias.Person.GivingId == "P01"' %}
{% person expression:'PhoneNumbers.Count() > 1' %}
```

##### Sort
Order results by properties or attributes:
```
sort:'LastName,NickName desc'
```

##### Limit
Limit results (default 1,000):
```
limit:'2'
```

##### DynamicParameters
Use query string values as parameters:
```
{% person dynamicparameters:'Id' %}
```
Unrecognized parameter names become filter expressions from the query string.

##### Iterator
Override the default iterator name:
```
{% person dataview:'1' iterator:'people' %}
    {% for person in people %}...{% endfor %}
{% endperson %}
```

##### Count
Return the record count only:
```
{% contentchannelitem where:'ContentChannelId == 5' count:'true' %}
    {{ count }}
{% endcontentchannelitem %}
```

##### SecurityEnabled
Disable security checks for performance (default is true for all entities except Person):
```
securityenabled:'false'
```

##### LazyLoadEnabled
Toggle lazy loading (true/false). Disabling bypasses full security checking.

##### Include
Eager-load related models:
```
include:'ConnectionStatusValue'
```

##### Select
Create anonymous types:
```
select:'new ( Id AS PersonId, NickName + " " + LastName AS FullName )'
```

##### SelectMany
Flatten nested lists:
```
selectmany:'PhoneNumbers.Select( NumberFormatted ).Distinct()'
```

##### GroupBy
Group results:
```
groupby:'LastName'
select:'new (Key as Key, it AS People)'
```

##### DisableAttributePrefetch
Skip attribute prefetching (saves ~10ms if attributes aren't needed, v15+):
```
disableattributeprefetch:'true'
```

##### PrefetchAttributes
Limit prefetched attributes to a specific list (v15+):
```
prefetchattributes:'Position,Employer'
```

#### Special Cases

1. `person` and `business` are mapped to separate commands with automatic record-type filters.
2. `person` automatically excludes deceased records. Override with `includedeceased:'true'`.
3. With `securityenabled:'false'`, computed fields are not allowed in `select` anonymous types. Since `person` defaults to security disabled, this affects `person` entity select.
4. To use Lava variables in `where`, enclose in double braces: `where:'Status.Value == "{{ tag }}"'`
5. When combining `&&` and `||`, list `&&` conditions last.


### Modify Entity Command

Updates or inserts entity data in the database.

> See [`Lava-ModifyEntity/`](Lava-ModifyEntity/) for entity-specific notes (e.g., creating a Schedule with `id:'0'`).
>
> When two or more writes must succeed or fail together, wrap them in [`{% dbtransaction %}`](#db-transaction-command).

#### Basic Usage
```
{% modifyperson id:'{{ personId }}' %}
    [[ property name:'NickName' ]]{{ nickName }}[[ endproperty ]]
    [[ attribute key:'Employer' ]]{{ employer }}[[ endattribute ]]
{% endmodifyperson %}
```

#### Parameters

- **id** (required) — Entity Id, GUID, or IdKey. Use `0` to create a new entity.
- **securityenabled** (default true) — Enforce entity security. Person entity does not apply security checks.
- **clientvalidationenabled** (default false) — Enable client-side validation.
- **return** — Merge field key for results (default `ModifyResult`).

#### Properties
```
[[ property name:'PropertyName' ]]value[[ endproperty ]]
```
- **name** — Property name (case-sensitive).
- **injectionpreventionenabled** (default true) — Blocks strings containing `</` or script-like content.

#### Attributes
```
[[ attribute key:'AttributeKey' ]]value[[ endattribute ]]
```
- **key** — The attribute key.
- **injectionpreventionenabled** (default true) — Same as properties.

#### Validation Options
Available for both properties and attributes: `isrequired`, `min`, `max`, `minlength`, `maxlength`, `pattern` (C# RegEx), `control`, `validationmessage`.

#### Result Merge Fields
The named return object contains:
- **Success** — Boolean. Gate on this before reading the entity — when `Success` is `false`, the entity is still populated with constructor defaults (`Id` will be `0`).
- **{EntityTypeName}** — The updated entity, keyed directly by the entity's type name (e.g., `modify_NewSchedule.Schedule`, `modify_NewPerson.Person`). NOT wrapped in `.Object` — references like `modify_NewSchedule.Object.Schedule` return null. (Tested April 2026)
- **ErrorMessage** — Error description.
- **ValidationErrors** — Array with `ErrorMessage` and `SourceControl`.

```
{% modifyschedule id:'0' return:'modify_NewSchedule' %}
    [[ property name:'iCalendarContent' ]]{{ var_iCal }}[[ endproperty ]]
{% endmodifyschedule %}

{% if modify_NewSchedule.Success == true %}
    {% assign var_NewScheduleId = modify_NewSchedule.Schedule.Id %}
{% else %}
    <div class="alert alert-warning">
        {{ modify_NewSchedule.ErrorMessage }}
        <ul>
        {% for message in modify_NewSchedule.ValidationErrors %}
            <li>{{ message.ErrorMessage }}</li>
        {% endfor %}
        </ul>
    </div>
{% endif %}
```

#### Service-Layer Hooks (Tested March 2026)
`{% modifyentity %}` fires Rock's service-layer hooks (`PreSaveChanges`, `PostSaveChanges`). `ModifiedDateTime` and `ModifiedByPersonAliasId` are automatically populated.

#### Setting Properties to Null (Tested March 2026)
Provide an empty value between the tags:
```
[[ property name:'ArchivedDateTime' ]][[ endproperty ]]
```

#### Archive/Unarchive Audit Fields Are NOT Automatic (Tested March 2026)
Setting `IsArchived` does NOT auto-populate `ArchivedDateTime` or `ArchivedByPersonAliasId`. These must be set explicitly.

Archive pattern:
```
{% modifygroupmember id:'{{ var_Id }}' securityenabled:'false' %}
    [[ property name:'IsArchived' ]]true[[ endproperty ]]
    [[ property name:'ArchivedDateTime' ]]{{ 'Now' | Date:'yyyy-MM-ddTHH:mm:ss' }}[[ endproperty ]]
    [[ property name:'ArchivedByPersonAliasId' ]]{{ CurrentPerson.PrimaryAliasId }}[[ endproperty ]]
{% endmodifygroupmember %}
```

Unarchive pattern:
```
{% modifygroupmember id:'{{ var_Id }}' securityenabled:'false' %}
    [[ property name:'IsArchived' ]]false[[ endproperty ]]
    [[ property name:'ArchivedDateTime' ]][[ endproperty ]]
    [[ property name:'ArchivedByPersonAliasId' ]][[ endproperty ]]
{% endmodifygroupmember %}
```

#### CRITICAL: `[[ property ]]` Declarations Are Not Reliably Isolated by `{% if %}` Tags (Tested March 2026)

The `{% modifyentity %}` command scans for `[[ property ]]` declarations at a parsing stage that occurs before (or independently of) `{% if %}` evaluation. ALL declarations within the block are registered regardless of conditions.

**Defensive Rule 1:** Mutually exclusive actions must use SEPARATE `{% modifyentity %}` blocks, each guarded by an external `{% if %}`:
```
{% if var_Action == 'UpdateStatus' %}
    {% modifygroupmember id:'{{ var_Id }}' securityenabled:'false' %}
        [[ property name:'GroupMemberStatus' ]]{{ Form.NewStatus }}[[ endproperty ]]
    {% endmodifygroupmember %}
{% endif %}

{% if var_Action == 'ToggleArchive' %}
    {% modifygroupmember id:'{{ var_Id }}' securityenabled:'false' %}
        [[ property name:'IsArchived' ]]true[[ endproperty ]]
    {% endmodifygroupmember %}
{% endif %}
```

**Defensive Rule 2:** Within a single block, each property should appear exactly once. Use `{% if %}` to control the *value*, not whether the declaration exists:
```
{% modifygroupmember id:'{{ var_Id }}' securityenabled:'false' %}
    [[ property name:'IsArchived' ]]{% if Form.CurrentIsArchived == '1' %}false{% else %}true{% endif %}[[ endproperty ]]
{% endmodifygroupmember %}
```

**Defensive Rule 3:** Always use named return variables instead of the default `ModifyResult` (Tested March 2026):
```
{% modifygroup id:'{{ var_GroupId }}' securityenabled:'false' return:'modify_IsActive' %}
    [[ property name:'IsActive' ]]{{ var_WhatValue }}[[ endproperty ]]
{% endmodifygroup %}

{% if modify_IsActive.Success == true %}
    {% assign var_Result = 'success' %}
{% else %}
    {% assign var_Result = 'failure' %}
    {% assign var_ErrorMessage = modify_IsActive.ErrorMessage | Default:'An unexpected error occurred.' %}
{% endif %}
```
The default `ModifyResult` was observed to report success even when a `{% modifygroup %}` modification did not actually persist. Named return variables (`return:'modify_FieldName'`) provide reliable success detection. This is especially important when a template contains multiple `{% modifyentity %}` blocks — even if each is guarded by an external `{% if %}`, the default `ModifyResult` may not reflect the correct block's outcome.

#### `{% modifygroup %}` and Archive Properties (Tested March 2026)

For `{% modifygroupmember %}`, setting `IsArchived`, `ArchivedDateTime`, and `ArchivedByPersonAliasId` together in a single block works correctly (see archive/unarchive patterns above).

For `{% modifygroup %}` (Group entity), the same pattern was observed to silently fail — `IsArchived` did not persist despite the command reporting success. The working pattern for Group is to set `IsArchived` alone in its own block with a named return variable:
```
{% modifygroup id:'{{ var_GroupId }}' securityenabled:'false' return:'modify_IsArchived' %}
    [[ property name:'IsArchived' ]]{{ var_WhatValue }}[[ endproperty ]]
{% endmodifygroup %}
```
When using this simplified pattern, `ArchivedDateTime` and `ArchivedByPersonAliasId` are **not** populated automatically. If audit trail fields are required, they may need to be set in a separate `{% modifygroup %}` call after confirming `IsArchived` was successfully updated.

#### `{% modifyschedule %}` and iCalendarContent on UPDATE (Tested May 2026)

For `{% modifyschedule id:'<existing>' %}` (UPDATE), combining the `iCalendarContent` property write with `EffectiveStartDate` / `EffectiveEndDate` in the same block was observed to silently no-op the `iCalendarContent` write — `modify_*.Success` returned `true`, the Schedule's `[Id]` did not change, but `[Schedule].[iCalendarContent]` in the DB stayed at its prior value. Same shape as the `{% modifygroup %}` / `IsArchived` quirk above.

The working pattern isolates `iCalendarContent` in its own block:
```
{% modifyschedule id:'{{ var_ScheduleId }}' securityenabled:'false' return:'modify_Schedule' %}
    [[ property name:'iCalendarContent' ]]{{ var_iCal }}[[ endproperty ]]
{% endmodifyschedule %}
```

`EffectiveStartDate` / `EffectiveEndDate` are redundant on every Schedule save — `Schedule.SaveHook.PreSave` calls `EnsureEffectiveStartEndDates()`, which re-derives them from the parsed iCal. See [`Lava-ModifyEntity/Schedule.md`](Lava-ModifyEntity/Schedule.md) > "Updating an existing Schedule" for the full account.

#### Setting Entity Attributes (Tested March 2026)

`[[ attribute ]]` declarations can update Rock Entity Attributes (not just database-column Properties) within a `{% modifyentity %}` block. Multiple attributes can be set in a single block.

**Practical example — setting date attributes on a Group:**
```
{% assign var_DateNow = 'Now' | Date:'yyyy-MM-ddTHH:mm:ss.fffzzz' %}
{% assign var_DateNextMonth = 'Now' | DateAdd:1,'M' | Date:'yyyy-MM-ddTHH:mm:ss.fffzzz' %}

{% modifygroup id:'{{ var_GroupId }}' securityenabled:'false' return:'modify_AuditDates' %}
    [[ attribute key:'date_LastAudited' ]]{{ var_DateNow }}[[ endattribute ]]
    [[ attribute key:'date_NextAuditDue' ]]{{ var_DateNextMonth }}[[ endattribute ]]
{% endmodifygroup %}

{% if modify_AuditDates.Success == true %}
    Updated successfully.
{% else %}
    Error: {{ modify_AuditDates.ErrorMessage }}
{% endif %}
```

**Date format for attribute storage:** Rock stores Date attribute values as strings. Use `'Now' | Date:'yyyy-MM-ddTHH:mm:ss.fffzzz'` to produce a full ISO 8601 timestamp with timezone offset. When displaying stored dates back to the user, apply a display format: `{{ storedValue | Date:'MMM d, yyyy' }}`.

**Mixing properties and attributes in one block:** A single `{% modifyentity %}` block can contain both `[[ property ]]` and `[[ attribute ]]` declarations. The three defensive rules documented above apply to **both** `[[ property ]]` AND `[[ attribute ]]` declarations — confirmed empirically on 2026-05-07 in BEMA RoomManagement (project5 v0.4.3 QA, Test Scenario 2):

- A `{% modifyreservation %}` block contained `{%- if var_ReservationTypeId == 13 -%}[[ attribute key:'ParentReservationId' ]]{{ var_ParentReservationGuid }}[[ endattribute ]]{%- endif -%}`.
- AttributeId 55902 is qualifier-scoped to `ReservationTypeId=13`. The user submitted with `ReservationTypeId=other` (so `var_ReservationTypeId == 13` was false).
- Expected: the `[[ attribute ]]` block would be suppressed by the `{% if %}`.
- Actual: modifyentity raised `Failed to create Reservation: No attribute found with the key of : ParentReservationId` and the entire block rolled back.

The bracket parser scans the raw modifyentity body for `[[ ]]` declarations BEFORE Lava processes any surrounding `{% if %}`, so the conditional is dead text inside the body. The fix is the same as for properties: put the `{% if %}` **outside** the modifyentity block and issue a separate `{% modifyentity %}` call (with its own `return:`) for the conditional declaration.

For an attribute like ParentReservationId where the converse — emitting an empty `[[ attribute key:'X' ]][[ endattribute ]]` to clear the value — would also fail because of the same qualifier-scope rejection, there is no in-modifyentity workaround for cascade-clear; you'd need a direct SQL `DELETE` against `[AttributeValue]`.

**The `key:` parameter itself is not Lava-rendered (Tested September 2026).** The rule above is about `{% if %}`
inside the body; the same pre-substitution parse also means the bracket *parameters* are read from raw source.
Writing `[[ attribute key:'{{ var_MyKey }}' ]]` looks up an Attribute whose key is literally the characters
`{{ var_MyKey }}`.

What makes this easy to walk into is that the two parameter positions differ:

| Position | Lava-rendered? |
|---|---|
| The tag line — `{% modifyperson id:'{{ int_PersonId }}' %}` | **Yes** |
| A bracket parameter — `[[ attribute key:'{{ var_MyKey }}' ]]` | **No** |

Measured on a Lava Application Endpoint writing two RegistrationRegistrant Attributes. The failure was:

> Failed to create RegistrationRegistrant: No attribute found with the key of: {{ var_BreakoutLabelAttributeKey }}

— the expression printed verbatim in the error, which is what proves it never reached the Lava engine. The whole
`{% dbtransaction %}` rolled back with it.

**Write every Attribute Key as a literal at the point of use.** Hoisting a key into a variable buys nothing and
costs this.

Note that this produces the *same error message* as the qualifier-scope rejection documented above. `No attribute
found with the key of: X` has (at least) two causes: X is not an Attribute on that entity, or X is scoped by an
`[AttributeQualifier]` the entity does not satisfy. If X reads back as an unrendered Lava expression, it is this
one; if it reads back as a plausible key, check the qualifier.

#### CurrentPerson in Lava Application Endpoints (Tested March 2026)
`CurrentPerson` and its properties (including `CurrentPerson.PrimaryAliasId`) are available inside Lava Application Endpoints.


### DB Transaction Command

Wraps a group of entity writes so that they all commit together or all roll back together. Available starting in **v18.0**.

```
{% dbtransaction %}
    ...entity writes...
{% enddbtransaction %}
```

> See [`Lava-ModifyEntity/DbTransaction.md`](Lava-ModifyEntity/DbTransaction.md) for the mechanism — output suppression on rollback, short-circuit behavior, and the `{% sql %}` interaction. Those behaviors change how the surrounding template has to be written, so read them before using this command.

#### Which commands participate

A command joins the transaction only if it was written to look for it. That is `{% modifyentity %}` and `{% deleteentity %}` — nothing else.

Rock's own documentation says transactions are supported "exclusively for encapsulating Modify Entity commands," but that is inaccurate: `{% deleteentity %}` participates identically.

`{% sql %}` is a partial case. A `{% sql %}` write shares the transaction's database connection and is expected to roll back with it, but it **cannot report failure** — it never sets `TransactionResult.Success = false`. A bad-but-succeeding SQL write therefore commits silently. Route writes through `{% modifyentity %}`.

#### Parameters

- **forcerollback** (default false, v18.0) — always roll back, even on success. A dry-run harness for verifying that a set of writes would not error.
- **enablecontextisolation** (default false, v19.3) — run the transaction in its own database context, so an error cannot leak into subsequent transaction statements. **Not available on v18.2**, our last recorded instance version.

There is **no `return:` parameter.** The result is always published as `TransactionResult`, via a hardcoded merge-field key. Writing `return:'foo'` parses without error and is then read by nothing — it fails silently, and `TransactionResult` still holds the result. This is the one place where the named-return habit from Defensive Rule 3 does not apply.

#### Result Merge Fields

`TransactionResult` is set on both the commit and the rollback path, and is readable after `{% enddbtransaction %}` (not inside the block):

- **Success** — Boolean, defaults to `true`. Set to `false` by any participating command that fails.
- **ErrorMessage** — accumulated with a leading space per failure; pipe through `| Trim` before display.
- **ValidationErrors** — array with `ErrorMessage` and `SourceControl`.

#### Basic Usage

Create a Group and add a member to it, atomically. Note that the error markup sits **outside** the block — content rendered inside is discarded when the transaction rolls back:

```
{% dbtransaction %}

    {% modifygroup id:'0' securityenabled:'false' return:'modify_NewGroup' %}
        [[ property name:'Name' ]]{{ var_GroupName }}[[ endproperty ]]
        [[ property name:'GroupTypeId' ]]{{ var_GroupTypeId }}[[ endproperty ]]
    {% endmodifygroup %}

    {% modifygroupmember id:'0' securityenabled:'false' return:'modify_NewMember' %}
        [[ property name:'PersonId' ]]{{ CurrentPerson.Id }}[[ endproperty ]]
        [[ property name:'GroupId' ]]{{ modify_NewGroup.Group.Id }}[[ endproperty ]]
        [[ property name:'GroupRoleId' ]]{{ var_GroupRoleId }}[[ endproperty ]]
    {% endmodifygroupmember %}

{% enddbtransaction %}

{% if TransactionResult.Success == false %}
    <div class="alert alert-warning">
        <strong>{{ TransactionResult.ErrorMessage | Trim }}</strong><br>
        <ul>
        {% for var_Message in TransactionResult.ValidationErrors %}
            <li>{{ var_Message.ErrorMessage }}</li>
        {% endfor %}
        </ul>
    </div>
{% endif %}
```

Keep the named `return:` on each inner block — those remain useful for reading back a created entity's `Id`, as `modify_NewGroup.Group.Id` does above. But diagnose failures from `TransactionResult`, not from the individual returns: once one write fails, later blocks are skipped and their named returns are never assigned at all.

Omitting the required `GroupRoleId` above is the classic failure — the GroupMember save fails validation, and the already-saved Group is rolled back with it.

#### Enabled Lava Commands

`dbtransaction` has **no checkbox** under a Block's Enabled Lava Commands, the same as `renderlavaendpoint`. The block does not implement `ILavaSecured`, so it is ungated; authorization is enforced entirely by the commands inside it.


### Calendar Events Command

Returns upcoming `EventScheduledInstances` from a calendar.

```
{% calendarevents calendarid:'1' audienceids:'151,152' %}
    {% for item in EventScheduledInstances %}
        {{ item.Name }} on {{ item.Date }} at {{ item.Time }}
    {% endfor %}
{% endcalendarevents %}
```

Each item contains: `EventItemOccurrence`, `Name`, `DateTime`, `Date`, `Time`, `EndDate`, `EndTime`, `Campus`, `Location`, `LocationDescription`, `Description`, `Summary`, `OccurrenceNote`, `DetailPage`, `CalendarNames`, `AudienceNames`.

Parameters:
- **CalendarId** (required)
- **MaxOccurrences** (default 100)
- **DateRange** — Format: `'Xd'`, `'Xw'`, `'Xm'` (days, weeks, months from StartDate)
- **AudienceIds** — Comma-separated DefinedValue Ids
- **CampusIds** — Comma-separated Campus Ids
- **StartDate** (default today)


### Web Request Command

Makes HTTP requests to external systems.

#### Basic Usage
```
{% webrequest url:'https://api.github.com/repos/SparkDevNetwork/Rock/commits' %}
    {% for item in results %}
        {{ item.commit.author.name }}: {{ item.commit.message }}
    {% endfor %}
{% endwebrequest %}
```

#### Parameters
- **url** (required)
- **parameters** — Query string: `'key1^value1|key2^value2'`
- **headers** — Same format as parameters
- **method** — HTTP verb (default `'GET'`, case-insensitive)
- **basicauth** — `'username,password'`
- **body** — Request body content
- **requestcontenttype** — MIME type (e.g., `'application/json'`), overrides Content-Type header
- **responsecontenttype** — `'JSON'` (default), `'XML'`, or `'HTML'`
- **return** — Return variable name (default `'results'`)
- **timeout** — Milliseconds (default 12000)

#### Tips
Build JSON bodies using `capture`, `Trim`, and `StripNewLines`:
```
{% capture output %}
    { "message": "{{ message }}", "person": { "email": "{{ person.Email }}" } }
{% endcapture %}
{% assign bodyoutput = output | Trim | StripNewLines %}

{% webrequest url:'https://url.for.post' method:'POST' body:'{{ bodyoutput }}' requestcontenttype:'application/json' %}
    {{ results | ToJSON }}
{% endwebrequest %}
```


#### Collection filters on a Web Request result

**Rock's collection filters do not recognise the List that `{% webrequest %}` returns.** `Reverse`,
and by extension anything downstream of it, falls through to the filter's *string* branch and
operates on the list object's `ToString()` instead of on its items. The failure is silent and
returns a plausible-looking wrong answer rather than an error.

Measured 2026-08-29 against Asana's `/tasks/{gid}/stories` (10 stories), in
an endpoint that calls an external API:

```
{% assign array_Stories = response_Stories.data | Reverse | Slice:0,50 %}
{{ array_Stories | Size }}          →  48        (not 10)
{% for story in array_Stories %}    →  runs 48 times
    {{ story.text }}                →  empty, for every iteration
```

48 is the character length of `System.Collections.Generic.List` + `` `1[System.Object] ``. `Reverse`
stringified the list, reversed those 48 characters, `Slice:0,50` kept all of them, `Size` counted
them, and the `{% for %}` tag iterated the string one character at a time. A character has no
`.text`, so every field read blank and every `Where` match failed.

Direct property access on a Web Request result is unaffected — `response_Task.data.name` and even
`response_Task.data.assignee.name` resolve correctly. It is specifically **the collection filters
between the response and the loop** that break, which is what makes this hard to spot: the summary
card built from the single-object response renders perfectly while the table built from the array
renders empty rows.

Iterate the response array exactly as it arrives and do the shaping on the `{% for %}` tag instead:

```
{% for story in response_Stories.data reversed %}
    {% if forloop.index > 50 %}{% break %}{% endif %}
    ...
{% endfor %}
```

`reversed` replaces `Reverse`, a `forloop.index` guard replaces `Slice`, and a tally loop replaces
`Where`. If you need the items in a real collection, round-trip them through `ToJSON | FromJSON`
first — `FromJSON` output behaves normally.


### Workflow Activate Command

Launches a new workflow or activates an activity on an existing workflow.

#### Basic Usage
```
{% workflowactivate workflowtype:'21' %}
    Activated workflow #{{ Workflow.Id }}.
{% endworkflowactivate %}
```

Available variables inside the block:
- **Workflow** — The new/existing workflow object
- **Activity** — The new activity (if activating an activity)
- **Error** — Error message (empty if successful)

#### Parameters
- **workflowtype** — WorkflowType Id or Guid (creates new workflow)
- **workflowid** — Existing workflow Id
- **workflowname** — Name for the new workflow (supports Lava)
- **activitytype** — Activity type Id or Guid to activate on an existing workflow
- Any other key/value pairs are treated as workflow/activity attribute values:
```
{% workflowactivate workflowtype:'21' color:'Red' requester:'{{ CurrentPerson.PrimaryAlias.Guid }}' %}
```

#### CRITICAL: Parameters Must Be on a Single Line (Observed August 2026)

Every parameter in the opening `{% workflowactivate %}` tag must sit on one line. Breaking them across lines for readability throws:

```
Lava Error: (Block: workflowactivate) Parameter name is invalid. Parameter name: name
```

**Broken** — one parameter per line:
```
{% workflowactivate
    workflowtype:'618'
    groupid:'{{ var_Row.GroupId }}'
    group:'{{ var_Row.GroupName }}'
    %}
{% endworkflowactivate %}
```

**Working** — all parameters on one line:
```
{% workflowactivate workflowtype:'618' groupid:'{{ var_Row.GroupId }}' group:'{{ var_Row.GroupName }}' %}
{% endworkflowactivate %}
```

**The `name` in that error message is not a Lava parameter.** It is the C# argument name of `LavaElementAttributes.SetValue( string name, string value )`, surfaced by `nameof( name )` — which is why searching the Workflow Activate documentation for a `name` parameter turns up nothing.

**Mechanism.** Rock parses element parameters with a hand-rolled character scanner (`Rock/Lava/LavaElementAttributes.cs` > `GetElementAttributes`) that treats **only the literal space character** as a separator. Newlines and tabs fall through to the scanner's catch-all branch — *"For any other character, assume it is the start of a new parameter."* So each newline opens a parameter that the following indent space immediately closes. That fragment contains no `:`, so it is stored under an empty key.

Parsing `workflowtype:'618'\n    groupid:'790032'` yields:

| Key | Value |
|------|-------|
| `workflowtype` | `618` |
| *(empty string)* | `\n ` |
| `groupid` | `790032` |

`{% workflowactivate %}` is then the only block in Rock that copies its parsed parameters through `LavaElementAttributes.Clone()`, which routes every key through `SetValue()`, which rejects a blank key. Every other block — `{% sql %}`, `{% cache %}`, `{% modifyentity %}`, `{% webrequest %}` — builds the same empty-key entry and simply ignores it. That is why multi-line parameters are harmless everywhere else in Lava and fatal here.

Spaces *inside* `{{ }}` are safe. The scanner tracks Lava regions and skips over them, so filter pipes and the spaces around them never split a parameter.

**Do not use the zero-indentation workaround.** Putting each parameter at column 0 does not throw, because `SetValue()` trims the key before storing it — but the result is worse than the crash. The parsed keys become `"\nworkflowname"`, `"\ngroupid"`, and so on, and only the *cloned* copy gets trimmed. The reserved parameters (`workflowtype`, `workflowname`, `workflowid`, `activitytype`) are read from the **un-cloned** settings, so any reserved parameter after the first line silently resolves to `null`. A `workflowname` on line 2 just vanishes, with no error and no indication anything was dropped.

**Version boundary.** The `settings.Clone()` call was introduced by commit `71d58985` (2023-11-03, merged into `hotfix-1.16.1`), replacing a `GetUnmatchedAttributes()` loop that read the empty key harmlessly. Verified against release tags:

| Rock version | Multi-line parameters |
|--------------|-----------------------|
| 1.16.0 and earlier | Tolerated |
| 1.16.1 through 19.x and `develop` | **Throws** |

Every test in `Rock.Tests.Integration/Core/Lava/Commands/WorkflowActivateTests.cs` uses single-line parameters, which is why this was never caught upstream.

#### Two Silent Failures to Watch For (Observed August 2026)

**Unmatched attribute names are discarded without error.** `SetWorkflowAttributeValues` matches your parameter names against `workflow.Attributes.Keys` — the Attribute **Key**, not the Attribute **Name** — case-insensitively, and skips anything that does not match. A typo in an attribute parameter produces no error message and no output; the value simply never reaches the workflow. Upstream this is deliberate; see the test `WorkflowActivateBlock_WithInvalidAttributeParameter_IgnoresInvalidAttribute`.

**`Workflow.Id` is `0` unless the WorkflowType is persisted.** `WorkflowService.Process` only calls `Add( workflow )` and `SaveChanges()` when `workflow.IsPersisted || workflowType.IsPersisted`. If 'Persisted' is off on the WorkflowType, the workflow runs to completion but is never written to the database, and `{{ Workflow.Id }}` renders `0` for every instance. This matters whenever a template collects the Ids of the workflows it just launched.


---


## Commenting

### Comment Tag
```
{% comment %}
    This content will never be rendered.
{% endcomment %}
```
**Note:** Incorrect Lava inside comment tags still produces errors. Wrap with `raw`/`endraw` to prevent this. Nesting comment tags is not supported.

### Single-line and Multi-line Comments
```
//- This is a single-line comment

/-
    This is a multi-line comment.
    It will be stripped before sending to the browser.
-/
```


---


## Null, Empty, and Blank Value Behavior

This section documents the boolean results of various null/empty checks in Lava.

### Variable is `null` (`{% assign var = null %}`)

| Test | Result |
|------|--------|
| `{% if var %}` | `false` |
| `{% if var == Null %}` | `true` |
| `{% if var == Empty %}` | `false` |
| `{% if var == '' %}` | `false` |

### Variable does not exist

| Test | Result |
|------|--------|
| `{% if var %}` | `false` |
| `{% if var == Null %}` | `true` |
| `{% if var == Empty %}` | `false` |
| `{% if var == '' %}` | `false` |

### Variable is empty string (`{% assign var = '' %}`)

| Test | Result |
|------|--------|
| `{% if var %}` | `true` |
| `{% if var == Null %}` | `false` |
| `{% if var == Empty %}` | `true` |
| `{% if var == '' %}` | `true` |

### Variable has a value (`{% assign var = 'Hello' %}`)

| Test | Result |
|------|--------|
| `{% if var %}` | `true` |
| `{% if var == Null %}` | `false` |
| `{% if var == Empty %}` | `false` |
| `{% if var == '' %}` | `false` |

### Attribute that does not exist

| Test | Result |
|------|--------|
| `{% if var %}` | `true` |
| `{% if var == Null %}` | `false` |
| `{% if var == Empty %}` | `true` |
| `{% if var == '' %}` | `true` |

### Attribute that exists but is blank

Same behavior as "Attribute that does not exist" above.

### Property with `null` value (e.g., `RecordStatusReasonValueId`)

| Test | Result |
|------|--------|
| `{% if var %}` | `false` |
| `{% if var == Null %}` | `true` |
| `{% if var == Empty %}` | `false` |
| `{% if var == '' %}` | `false` |

### Property with empty value (e.g., `MiddleName` = "")

| Test | Result |
|------|--------|
| `{% if var %}` | `true` |
| `{% if var == Null %}` | `false` |
| `{% if var == Empty %}` | `true` |
| `{% if var == '' %}` | `true` |

### Property that does not exist

Same behavior as "Property with null value" above.

### Array with items (size > 0)

| Test | Result |
|------|--------|
| `{% if var_array %}` | `true` |
| `{% if var_array == Null %}` | `false` |
| `{% if var_array == Empty %}` | `false` |
| `{% if var_array == '' %}` | `false` |

### Array with 0 items

| Test | Result |
|------|--------|
| `{% if var_array %}` | `true` |
| `{% if var_array == Null %}` | `true` |
| `{% if var_array == Empty %}` | `true` |
| `{% if var_array == '' %}` | `false` |

### Zero, `'0'`, and type coercion (Tested August 2026)

Tested in a Rock Lava block against the live instance. These settle three things that are easy
to assume wrongly when a Single-Select uses numeric value-halves (`1^Yes,0^No`) — a common
pattern, since numeric halves let you reword the visible labels without rewriting stored
`[AttributeValue]` rows.

| Expression | Result | Reading |
|---|---|---|
| `{{ '0' \| Default:'FELLBACK' }}` | `0` | `Default` does **not** treat `'0'` as absent |
| `{{ '' \| Default:'FELLBACK' }}` | `FELLBACK` | Empty string **does** substitute |
| `{% if '0' %}` | `true` | |
| `{% if '' %}` | `true` | An empty string is **truthy** — see the caveat below |
| `{% if '0' == '0' %}` | `true` | |
| `{% if '0' == 0 %}` | `true` | **`==` coerces across types** |
| `{{ '0' \| AsBoolean }}` | `false` | `AsBoolean` **does** coerce |
| SQL `'0'` (nvarchar) `== '0'` | `true` | |
| SQL `0` (int) `== '0'` | `true` | Boxed SQL ints compare equal to their string form |
| `'0' ==` SQL `0` (int) | `true` | **Symmetric** — coercion does not depend on operand order |
| `{{ SQL 0 \| Default:'FELLBACK' }}` | `0` | Integer zero is not "empty" either |
| `{{ SQL 0 \| Trim }}` | `0` | `Trim` copes with a boxed int; it does not require a string |

**1. `Default` substitutes on null and empty-string only.** It is not a falsiness test. Neither
the string `'0'` nor the integer `0` is replaced. `| Default:''` is therefore safe on a numeric
value-half, and is the right idiom for normalizing a nullable column to `''`.

**2. `==` coerces across types, in both directions.** An integer `1` from a SQL column compares
equal to the string `'1'`, and the reverse holds too — coercion is not sensitive to operand
order. No `| AsString` is needed to make such a comparison work.

> [!NOTE]
> **This resolves the "int-vs-string `==` trap".**
> That trap does not reproduce in this Rock version: `==` coerces symmetrically, and `Trim`
> accepts a boxed int. The `| AsString` there is therefore redundant — but it is being **kept**,
> because it is free, it is correct-by-construction for a value that is only ever meaningful as a
> string, and nobody now knows what the original bug actually was. Only the comment was corrected.
> Do not read the presence of `AsString` elsewhere in the codebase as evidence that this trap is
> real.

**3. An empty string is truthy, but `null` is falsy.** This is the one that bites. `{% if var %}`
is effectively "is this null-or-false", not "does this hold a meaningful value":

- On a **nullable non-string column** (an `[Attribute].[Id]` that may be NULL), `{% if var %}`
  says exactly what you want — null is falsy, any int is truthy.
- On a **string column**, `{% if var %}` is true even when the value is `''`. Always write
  `{% if var != '' %}` there.


### `AsInteger` coercion and failure mode (Tested August 2026)

`AsInteger` is the filter the repo's `input_` convention leans on as its only defense between a
PageParameter and interpolated SQL (see the formatting-standards house rule § "Coerce every
`input_` value before it can reach SQL"). These results confirm that convention is sound, and
pin down exactly *how* it holds.

| Input | Result | Note |
|---|---|---|
| `'-5'` | `-5` | Negatives parse — see the warning below |
| `' 7 '` | `7` | Surrounding whitespace tolerated |
| `'1.9'` | `1` | **Truncates, does not round** |
| `'abc'` | `null` | |
| `'12abc'` | `null` | **No partial parse** — the whole input is discarded, not truncated to `12` |
| `'1 OR 1=1'` | `null` | |
| `'1;DROP TABLE'` | `null` | |
| `'0x10'` | `null` | Hex notation is not recognized |
| `''` | `null` | |
| `null` | `null` | |

**It fails closed, to `null` specifically.** Verified directly: for input `'abc'`, `{% if t ==
null %}` is `true`, `{% if t == '' %}` is `false`, `{% if t %}` is `false`, and `{% if t >= 1 %}`
is `false`. The distinction matters — an empty **string** would have been *truthy* (see the
previous section) and would have sailed through the first half of the standard guard. It is null,
so it does not.

**The security consequence.** A hostile `?c1=1;DROP TABLE Person--` yields `null`, not a partially
parsed number and not the original string. The payload is destroyed rather than shortened, so the
standard pattern is safe as written:

```lava
{% assign input_CampusId = 'Global' | PageParameter:'c1' | AsInteger %}
...
{% if input_CampusId and input_CampusId >= 1 %}AND att.[CampusId] = {{ input_CampusId }}{% endif %}
```

> [!WARNING]
> **The `>= 1` half of that guard is load-bearing — do not "simplify" it away.** `AsInteger`
> accepts negative integers, so `?c1=-5` produces `-5`, which is non-null and therefore passes
> `{% if input_CampusId %}` on its own. Only the `>= 1` comparison rejects it. The two halves
> guard different things: `and input_CampusId` rejects non-numeric garbage, `>= 1` rejects valid
> integers that are not plausible Ids.

**Corollary for other coercing filters.** `AsInteger`'s fail-to-null behavior is *not* evidence
about `AsDecimal` or `AsBoolean`. `AsBoolean` is already known to coerce `'0'` to `false` rather
than failing (previous section). Test before assuming a shared contract.

### The coercion probe

The three "Tested August 2026" sections below were produced by
the `surface-lava-tester` skill's `assets/Lava-Coercion-Probe.lava` — a single-render block that exercises
every behavior recorded here and annotates each line with its expected result. It is checked in
so the findings can be **re-verified rather than re-derived**.

**Re-run it when:**

1. **Rock has been upgraded** — before trusting any of the three sections below. Every value in
   them is version-specific and none of it is contractual.
2. **You are about to rely on a filter edge the `#### FilterName` reference does not state.**
   Read that reference first: two behaviors this probe originally "discovered" were already
   documented in it (`Split`'s `RemoveEmpty` default, and lexical string comparison). The probe
   covers what the reference omits; it is not a substitute for reading it.
3. **You are adding a filter whose failure mode matters** — anything standing between a
   PageParameter and interpolated SQL, in particular.

Three lines in the probe are marked `UNVERIFIED` (the `RemoveEmpty=false` forms of `Split`). They
state what the reference predicts but have never been run; confirm before citing them.

### `Split`, `contains`, `Size`, and `Default` — measured edges (Tested August 2026)

These tests were run before checking the filter reference above, and two of them merely
rediscovered behavior already documented there. Recorded here is only what the canonical entries
do **not** state, each cross-referenced to its entry. **Read the `#### Filter` entry first.**

#### `Split` — already documented; the consequence is not

The [`#### Split`](#split) entry states the signature: `{Pattern}`, `{RemoveEmpty}` **(default
true)**, `{Maximum}`. Everything below follows from that default and is confirmation, not news.

| Input | Size | JSON |
|---|---|---|
| `'a,,b' \| Split:','` | 2 | `["a","b"]` |
| `',a' \| Split:','` | 1 | `["a"]` |
| `'' \| Split:','` | 0 | `[]` — an empty array, **not** `[""]` |
| `null \| Split:','` | 0 | `[]` — does not throw |

> [!WARNING]
> **The one-argument `Split` is unsafe where element POSITION carries meaning.** Since
> `RemoveEmpty` defaults true, `',2026-08-20' | Split:','` yields a **one**-element array whose
> `[0]` is the *end* date — the value silently shifts into the start slot. Pass `false` explicitly
> for positional splits, which is exactly what the `input_` date-range convention in
> the formatting-standards house rule does with `Split:',',false,2`. Membership tests and
> `{% for %}` loops are unaffected.

The two rows the reference entry does not cover: an empty or null input yields a **zero-length**
array, so a `{% for %}` over it simply does not execute.

#### `contains` — the reference entry is incomplete

[`#### Contains`](#contains) says "Works only with string arrays." Measured, it does more:

| Test | Result | Beyond the reference |
|---|---|---|
| `'\|1\|13\|' contains '\|3\|'` | `false` | Confirms the `\|id\|` delimiter idiom |
| `'\|1\|13\|' contains '13'` | `true` | …and why the pipes are needed |
| `'\|1\|13\|' contains 13` (int) | `true` | Coerces, like `==` |
| SQL **int** array `contains '1'` | `true` | **Works on non-string arrays** |
| SQL **int** array `contains 1` | `true` | Coerces either way |
| `'ABC' contains 'abc'` | **`false`** | **Case-sensitive** |
| `null contains 'x'` | `false` | Null-safe; does not throw |

Case-sensitivity and int-array support are both absent from the reference entry.

#### `Size` — reference covers strings only

[`#### Size`](#size) documents the string behavior ("character count including spaces"). Not
covered: `12345 | Size` is **`0`** (an integer has no length), and `null | Size` is `0` without
throwing. So `Size` cannot distinguish empty collection from null from wrong-type — all three
give `0`.

#### `Default` — "null or empty" is imprecise

[`#### Default`](#default) says "if the input is null or empty." More precisely:

| Input | Result |
|---|---|
| `' ' \| Default:'X'` | `X` — **whitespace-only** counts as empty |
| `false \| Default:'X'` | **`False`** — a boolean false passes straight through |
| empty array `\| Default:'X'` | **unchanged** — renders `System.Collections.Generic.List'1[System.Object]` |
| empty SQL row set `\| Default:'X'` | **unchanged** — same type-name output |

Two traps: `false | Default:'Something'` renders the literal text `False`, and piping an empty
**collection** through `Default` prints a raw .NET type name into the page. Never write
`{{ array | Default:'none' }}` — pre-compute `| Size` and branch.

#### Relational operators — already documented

Line ~5086 of this file already states it: *"Without conversion, string "3" is considered greater
than number 10 (lexicographic comparison)."* The measured detail is where the switch happens — if
**either** operand is a number the comparison is numeric; only when **both** are strings is it
lexical (`'10' > '9'` is `false`; `10 > '9'` and `'10' > 9` are both `true`). Note this differs
from `==`, which coerces symmetrically.

#### `Select` on a `{% sql %}` row set

[`#### Select`](#select) is documented for object collections; confirmed to work on `{% sql %}`
rows too, returning a plain array (`rows | Select:'V'` → `[0, 1]`).

### `Map` over `FromJSON` objects — measured edges (Tested August 2026)

`Map` is documented for object collections and had previously been used only against
`{% sql %}` row sets. Probed directly
against objects produced by `FromJSON`, using a fixture shaped like a real ShortCode contract — a
top-level array of objects, each holding a nested array of objects.

#### It works everywhere it was doubted

| Case | Result |
|---|---|
| `{% sql %}` row set (control) | works |
| Top-level `FromJSON` array | works |
| **Nested** `FromJSON` array (`obj.required[0].reasons \| Map:'text'`) | works |
| `Where` → `First` → `Map` on the match's nested array | works |
| JSON **numbers** (`[{"v":1},{"v":2}]` → `1, 2`) | works |
| JSON strings that look numeric (`"228"`) | works |

**The Int64-vs-Int32 boxing trap does not apply to `Map`.** That trap is real for `contains` and
`Where`, which compare a *needle* against boxed values by exact CLR type — `FromJSON` parses a JSON
number as Int64 while a `{% sql %}` column is Int32, so a bare-number needle silently misses (hence
the string-id convention in ShortCodes 150 and 156). `Map` performs no comparison; it projects a
property. Emitting ids as strings is still correct for anything a caller will `Where` on, but it is
not needed merely to survive a `Map`.

#### `Map` does not throw on an empty array — unlike `Where`

`Where` throws on an empty / typeless match set, which is why call sites guard with
`{% if obj.required != empty %}` before filtering. `Map` over an empty array simply returns empty.
The guard is a `Where` requirement, not a general array-filter requirement.

#### A missing key becomes an empty slot, not a skipped element

This is the one genuine gotcha, and it is invisible until it reaches a `Join`:

```
{"missingKey":[{"text":"has one"},{"other":"lacks text"},{"text":"has two"}]}

{{ obj.missingKey | Map:'text' | Join:', ' }}
→ has one, , has two          ← note the empty slot
```

Mapping a key that only *some* elements carry yields doubled separators. When the key is optional,
filter first (`| Where:'text', ...`) or build the string with an explicit `{% for %}` rather than
`Map | Join`. When every element is guaranteed to carry the key — as in 150's `reasons`, where
`text` is always emitted — `Map:'text' | Join:', '` is safe and is the preferred spelling.

#### `Select` is an alias

`obj.required | Select:'resourceName'` returned the same result as `Map`. Either name works; prefer
`Map` for consistency with existing usage.
