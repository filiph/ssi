A tiny pre-processor that supports including files in other files.
Think of it as "C macros for HTML and Markdown files".

This tool uses the ancient 
[Server Side Includes (SSI)](https://en.wikipedia.org/wiki/Server_Side_Includes)
syntax that has its roots in 1993.

Why SSI and not some other syntax?

* SSI was literally designed for the job at hand: including files in other files
* The syntax of SSI directives is very obvious (unlike, say, `m4`)
  and hard to miss: `<!--#include file="..." -->`
* Unlike more complex technologies like `mustache` or `jekyll` or `php`,
  SSI doesn't let you do things that could get you in trouble, 
  such as evaluating expressions or running shell commands.

If you need a templating language that supports rendering collections
and structured data, this tool is not for you.


## Installation

This package is currently not on pub.dev.

```shell
dart pub global activate --source git https://github.com/filiph/ssi --git-ref main
```

This will add `ssi` to your path.


## Usage

The simplest usage is:

```shell
ssi input.txt > output.html 
```

You can list several files, in which case it is as if the files
were concatenated into a single file:

```shell
ssi variables.txt header.shtml content.md footer.shtml > index.html
```


## Practical example

It's probably best to just show you what an `input.txt` file might look like.

```text
<!--#set var="title" value="My Page About Spaceships" -->
<!--#set var="author" value="Filip Hráček" -->

<!--#include file="header.shtml" -->
<!--#include file="article.md" markdown="true" -->
<!--#include file="footer.shtml" -->
```

And `header.shtml` could look like this:

```text
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><!--#echo var="title" --></title>
    <meta name="author" content="<!--#echo var="author" -->">
</head>
<body>
```

Notice how the second `echo` directive is inside an HTML tag parameter value
(`content="..."`).
This would be illegal if this was straight HTML.
But since this file is first consumed by `ssi` (a *pre*-processor),
it's okay. The `ssi` tool *does not care* where it finds directives, and it
will output everything else as is.

`article.md` can be written in Markdown:

```markdown
# <!--#echo var="title" -->

Hi, my name is <!--#echo var="author" --> and this is my tribute to spaceships!

<!--#include file="some_other_text.md" markdown="true" -->
```

Notice how directives work everywhere, and how you can include files
recursively (i.e. includes in other includes).


## Supported SSI directives

You can include files (even recursively).

```
<!--#include file="header.html" -->
```

In a departure from the original SSI specification, 
you can also ask `ssi` to convert Markdown into HTML.

```
<!--#include file="content.md" markdown="true" -->
```

You can set variables.

```
<!--#set var="spaceship" value="Voyager" -->
```

And you can output them.

```
My favorite spaceship is <!--#echo var="spaceship" -->.
```

That's it. There's no looping with `for`, 
there's no running of CGI scripts with `exec`, 
no `config` directives. 
These directives exist in implementations of SSI (e.g. in Apache or nginx)
but they are not applicable for this project.
(We're not writing a dynamic web server, nor are we trying to compete with
the likes of mustache.)

There _might_ be support for the `if` / `elif` / `else` / `endif` directives 
in the future — but it's unlikely.
There also _might_ be support for accessing environment (provided) variables
— but it's not supported right now.
