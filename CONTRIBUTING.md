# DCSOps Contribution Guidelines

This document contains information of use to developers looking to
improve DCSOps.  See [README.md](README.md) for an
introduction to this project.

Please note that we expect all participants to abide by the project
[code of conduct](doc/CODE_OF_CONDUCT.md).

## Submitting and Reviewing Code

The DCSOps home repository is
[GitHub](https://github.com/redcross/dcsops).  Please submit [pull
requests](https://help.github.com/articles/about-pull-requests/) (PRs)
there.

Please submit changes via pull request, even if you have direct commit
access to the repository.  The PR process allows us to get additional
eyes on change proposals, and ensures that your changed code builds
cleanly via the automated CI system.

As you work on your branch, try to test it locally to ensure that it
still builds and deploys properly, and that you haven't introduced new
accessibility bugs.  Use [this
checklist](https://www.section508.gov/content/build/website-accessibility-improvement/major-web-issues)
as you look for accessibility problems.

Generally, the more controversial, complex or large a change, the more
opportunity people should have to comment on it.  That means it should
garner more comments/approvals, or it means it should sit longer
before being merged. You can talk with us about a change you'd like to
make before or while you work on it.  We don't have hard rules about
such things, and documentation changes usually don't need to sit as
long as functional changes, but figure a business day or two for an
average patch to get discussed.

As to when to merge a change: that's a judgment call.  Usually one of
the experienced developers does it, but others should feel free to
push the merge button if the conversation around a change has
concluded.  If you're unsure, ask!  "Is this ready to merge?" is often
a useful next step in the conversation.

If your PR fixes a bug or adds a feature, please write a test to go
with the change, and describe in your PR message how reviewers should
test that your change works as expected.

### The "Obvious Fix" rule: committing some minor changes directly to 'main'

Certain kinds of presumed-safe changes may be reviewed post-commit
instead of pre-commit, meaning that they can be committed directly to
`main` without going through a PR, when the committer has push
access to do so.

The purpose of this is to save time for busy developers.  It avoids
the low-but-still-noticeable overhead of the PR review process for
changes where the that process would not provide much additional
protection beyond what post-commit review provides anyway.  In
practice, that means the following kinds of changes:

* Clear typo fixes.

  If there's an obvious typo that doesn't affect code flow (e.g., a
  typo in a code comment, or even in a user-visible string), you can
  just fix it.  However, if the typo affects code behavior, other than
  in how user-visible text is displayed, then it should go through the
  normal PR review process.

* Whitespace and formatting cleanups.

  Commits that are formatting-only and make the code more compliant
  with our coding guidelines can just be committed directly.  There is
  no need to take a reviewer's time with them.

* Developer documentation changes.

  If the substance of a development documentation change is agreed on,
  and it's just a matter of wording, then the change can just be
  committed directly, since after all, it's easy to improve it later.
  (For example, the commit that added this section to this document
  would qualify.)

  Substantive changes to user-facing documentation should, of course,
  still go through the normal PR process.

Developers should always exercise judgement, of course.  It's always
okay to still use a PR for a change qualifies as an "obvious fix", and
if one thinks there is any chance of controversy or disagreement about
the change, then the best thing to do is put it into a PR so it can go
through the regular review process.

### Keep Master Deployable

As implied by the "Deployment" section in [INSTALL.md](INSTALL.md),
the tip (HEAD) of the `main` branch should always be deployable.

Development work should be done on branches, as described in the next
section, and merged to `main` only when it is ready and passing all
tests.

### Branching and Branch Names

We do development on lightweight branches, with each branch
encapsulating one logical changeset (that is, one group of related
commits).  Please try to keep changesets small and well-bounded: a
branch should usually be short-lived, and should be turned into a PR,
reviewed, and merged to `main` as soon as possible.  Keeping
branches short-lived reduces the likelihood of conflicts when it comes
time to merge them back into main.

When a branch is associated with an issue ticket, then the branch name
should start with the issue number and then give a very brief summary,
with hyphens as the separator, e.g.:

    871-fix-volunteer-scheduling

Everything after the issue number is just a reminder what the branch
addresses.  Sometimes a branch may address only part of an issue, and
that's fine: different branches can start with the same issue number,
as long as the summary following the issue number indicates what part
of the issue that particular branch addresses.

If there is no issue number associated with a branch, then don't start
the branch name with a number.

While there are no strict rules on how to summarize a branch's purpose
in its name, it may help to keep in mind some common starting words:
"`fix`", "`feature`", "`refactor`", "`remove`", "`improve`", and "`test`".

#### Feature life cycle

Each feature branch should be started from some point on main, with pull
requests for review before merging into main.  At some point in the future,
the code will make it into the `candidate-production`, and moved into
heroku staging.  Once it passes muster, it will be merged into production
and pushed to heroku production.

'''NOTE''': Please include any database migration information, database updates,
environment variable changes, etc, in the pull request.

#### `main` Branch

This is the development branch, which while always deployable, will have
the latest and greatest merged in development features.

#### `production` Branch

This branch is synced up with the current deployed production heroku branch.
In order to make sure the two are in line, you can add the heroku branch to your
git checkout (after running `heroku login`)

```
$ git remote add heroku-production https://git.heroku.com/dcsops.git
$ git fetch heroku-production
```

It should only be merged when changes have passed muster in the following
`candidate-production` branch.

#### `candidate-production` Branch

This branch is synced up with the current deployed staging heroku branch.
As above, to make sure the two are aligned, you can do:

```
$ git remote add heroku-staging https://git.heroku.com/dcsops-staging.git
$ git fetch heroku-staging
```



### Commit Messages
Please adhere
to [these guidelines](https://chris.beams.io/posts/git-commit/) for
each commit message.  The "Seven Rules" described in that post are:

1. Separate subject from body with a blank line
2. Limit the subject line to 50 characters
3. Capitalize the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line
6. Wrap the body at 72 characters
7. Use the body to explain _what_ and _why_ vs. _how_

Think of the commit message as an introduction to the change.  A
reviewer will read the commit message right before reading the diff
itself, so the commit message's purpose is to put the reader in the
right frame of mind to understand the code change.

The reason for the short initial summary line is to support commands,
such as `git show-branch`, that list changes by showing just the first
line of each one's commit message.

### Indentation and Whitespace

Please uses spaces, never tabs.  Indent code by 2 spaces per level (as
per the [generally-accepted Ruby
standard](http://www.caliban.org/ruby/rubyguide.shtml#indentation)),
and avoid trailing whitespaces.  The file
[.editorconfig](.editorconfig), in the repository's root directory,
encodes these formatting conventions in a way that most text editors
can read.

If you find yourself adjusting existing code -- such as to bring
legacy code into line with these standards -- please first keep
formatting commits separate from commits that contain substantive code
changes.  It's much easier for reviewers to read a code change when
it is not mixed together with formatting changes.

### Licensing Your Contribution

DCSOps is published under the terms of version 3 of the [Affero GNU
General Public License](LICENSE.md) (AGPL).  It is important that the
codebase continue to be publishable under that license.  To make that
possible, here are some guidelines on including 3rd party code in the
codebase.

If you submit code that you wrote or that you have authority to submit
from your employer or institution, you give it to us under version 3
of the AGPL.  If the material you submit is already licensed under a
more permissive license (BSD, MIT, ISC), you can tell us that and give
it to us under that license instead.

Please make the license of the code clear in your pull request.  Tell
us who wrote it, if that isn't just you.  If the code was written for
an employer, tell us that too.  Tell us what license applies to the
code, especially if it differs from the project's AGPL-3.0 license.
If you don't tell us, we will always assume AGPL-3.0.

If you submit code that doesn't come from you or your employer, we
call that "Third-Party Code" and have a few requirements.  If the code
contains a license statement, that's great.  If not, please tell us
the license that applies to the code and provide links to whatever
resources you used to find that out. For some examples, see the
LICENSE and METADATA parts of [Google's guide to introducing
third-party
code](https://opensource.google.com/docs/thirdparty/documentation/#license).

If your submission doesn't include Third Party Code, but instead
depends on it in some other way, we might need a copy of that
software.  Your submission should tell us where and how to get it as
well as the license that applies to that code.  We will archive a copy
of that code if we accept your pull request.

### Expunge Branches Once They Are Merged

Once a branch has been merged to `main`, please delete the branch.
You can do this via the GitHub PR management interface (it offers a
button to delete the branch, once the PR has been merged), or if
necessary you can do it from the command line:

    # Make sure you're not on the branch you want to delete.
    $ git branch | grep '^\* '
    * main

    # No output from this == up-to-date, nothing to fetch.
    $ git fetch --dry-run

    # Delete the branch locally, if necessary.
    $ git branch -d some-now-fully-merged-branch

    # Delete it upstream.
    $ git push origin --delete some-now-fully-merged-branch

## Avoiding Generatable Files In The Repository

As a general rule, we try to keep generated files out of the
repository.  This includes files that result from build processes.  If
we want to memorialize a compiled version of the program, the best way
to do that is with tags or to record that information and put the
saved version somewhere other than this repository.  If a file can be
generated from the materials in the repository using
commonly-available tools, please do not put it in the repository
without raising it for discussion.

## For more project management information, see the wiki.

See the [DCSOps Development
Wiki](https://github.com/redcross/dcsops/wiki) for more information
about how we run the project, records of meetings and decisions, etc.

## Thank you!

DCSOps exists to help Red Cross volunteers and staff serve people in
need as effectively as possible.  We're glad to have your help in
improving it!
