# pair

Pair Programming with Git Author and Git Committer.

<img width="411" alt="screen shot 2016-04-18 at 9 07 13 pm" src="https://cloud.githubusercontent.com/assets/1071893/14624535/9972bc64-05a9-11e6-97e4-6ac53cf76e4b.png">

`pair` uses git **author** and **committer** to apply the contributions equally to both developers.

## Install

```bash
mkdir ~/.functions
git clone git@github.com:vnegrisolo/pair.git ~/.functions/pair
echo "source ~/.functions/pair/pair.sh" >> ~/.bashrc
```

## Status

```bash
pair
```

will output something like:

<img width="280" alt="screen shot 2016-04-18 at 9 16 26 pm" src="https://cloud.githubusercontent.com/assets/1071893/14624684/e8f405b2-05aa-11e6-8c07-35aa42b62817.png">

## Configure

`pair` accepts github users and fetch your **name** and **email** from github api.

```bash
pair bill karen
```

If you do not have a name or public email for these users `pair` will show a command line so you can configure it manually, something like:

```bash
pair user_with_no_email
ERROR => You need to set Name and Email for user_with_no_email on Github, or run manually:
  git config --global pair.author.email 'your@email.com'
  git config --global pair.author.name 'Your Name'
```

## Commit

`pair` calls git in order to commit with all the params you wish and swaps **author** and **committer** for every commit.

```bash
pair commit -m 'Something changed'
```

## Reset

```bash
pair reset
```

## Development

I chose [rspec](https://github.com/rspec/rspec) as my test framework because I love it.

So I created some abstractions to deal with shell and make bash developer live easier.

## Github Notes

Github defines some rules to [contributions](https://help.github.com/articles/why-are-my-contributions-not-showing-up-on-my-profile/#contributions-that-are-counted).

TL;TR:

> You need to fit in **at least one** of the following:
> 
> - You are a **collaborator** on the repository or are a **member of the organization** that owns the repository.
> - You have **forked** the repository.
> - You have opened a **pull request** or **issue** in the repository.
> - You have **starred** the repository.
