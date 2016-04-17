# pair

Pair Programming with Git Authors

`pair` uses git **author** and **committer** to apply the contributions equally to both developers.

## Install

```shell
mkdir ~/.functions
git clone git@github.com:vnegrisolo/pair.git ~/.functions/pair
echo "source ~/.functions/pair/:pair.sh" >> ~/.bashrc
```

## Status

```shell
pair
```

will output something like:

```
| Pair      | Name         | Email          |
| ----      | ----         | -----          |
| Author    | Bill Jr      | bill@mail.com  |
| Committer | Karen Bright | karen@mail.com |
```

## Configure

`pair` accepts github users and fetch your **name** and **email** from github api.

```shell
pair bill karen
```

## Commit

`pair` calls git in order to commit with all the params you wish and swaps **author** and **committer** for every commit.

```shell
pair commit -m 'Something changed'
```

## Development

I chose [rspec](https://github.com/rspec/rspec) as my test framework because I love it.

So I created some abstractions to deal with shell and make our lives easier.

## Github Notes

Github defines some rules to [contributions](https://help.github.com/articles/why-are-my-contributions-not-showing-up-on-my-profile/#contributions-that-are-counted).

TL;TR:

You need to fit in **at least one** of the following:

- You are a **collaborator** on the repository or are a **member of the organization** that owns the repository.
- You have **forked** the repository.
- You have opened a **pull request** or **issue** in the repository.
- You have **starred** the repository.
