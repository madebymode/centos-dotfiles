# Dotfiles

CentOS dotfiles.

These dotfiles provision and install a typical dev environment on CentOs 6.x for MODE developers. It includes

1. PHP 5.6
2. MySQL 5.6
3. Apache 2.2
4. Nginx 1.0.5
5. Ruby 2.3.0 (Managed by rbenv)
6. Node 5.6 (manage by nave)
7. Default gems (compass, sass, sass-globbing, rubocop)
8. Default node modules (bower, grunt, gulp)

## About this project

The command is [dotfiles][dotfiles], and this is our "centos-dotfiles" Git repo.

[dotfiles]: bin/dotfiles

## How the "dotfiles" command works

When [dotfiles][dotfiles] is run for the first time, it does a few things:

1. In CentOS, Git is installed if necessary via YUM
1. This repo is cloned into your user directory, under `~/.dotfiles`.
1. Files in `/copy` are copied into `~/`. ([read more](#the-copy-step))
1. Files in `/link` are symlinked into `~/`. ([read more](#the-link-step))
1. You are prompted to choose scripts in `/init` to be executed. The installer attempts to only select relevant scripts, based on the detected OS and the script filename.
1. Your chosen init scripts are executed (in alphanumeric order, hence the funky names). ([read more](#the-init-step))

On subsequent runs, step 1 is skipped, step 2 just updates the already-existing repo, and step 5 remembers what you selected the last time. The other steps are the same.

### Other subdirectories

* The `/backups` directory gets created when necessary. Any files in `~/` that would have been overwritten by files in `/copy` or `/link` get backed up there.
* The `/bin` directory contains executable shell scripts (including the [dotfiles][dotfiles] script) and symlinks to executable shell scripts. This directory is added to the path.
* The `/caches` directory contains cached files, used by some scripts or functions.
* The `/conf` directory just exists. If a config file doesn't **need** to go in `~/`, reference it from the `/conf` directory.
* The `/source` directory contains files that are sourced whenever a new shell is opened (in alphanumeric order, hence the funky names).
* The `/test` directory contains unit tests for especially complicated bash functions.
* The `/vendor` directory contains third-party libraries.

### The "copy" step
Any file in the `/copy` subdirectory will be copied into `~/`. Any file that _needs_ to be modified with personal information (like [copy/.gitconfig](copy/.gitconfig) which contains an email address and private key) should be _copied_ into `~/`. Because the file you'll be editing is no longer in `~/.dotfiles`, it's less likely to be accidentally committed into your public dotfiles repo.

### The "link" step
Any file in the `/link` subdirectory gets symlinked into `~/` with `ln -s`. Edit one or the other, and you change the file in both places. Don't link files containing sensitive data, or you might accidentally commit that data! If you're linking a directory that might contain sensitive data (like `~/.ssh`) add the sensitive files to your [.gitignore](.gitignore) file!

### The "init" step
Scripts in the `/init` subdirectory will be executed. A whole bunch of things will be installed, but _only_ if they aren't already.

#### CentOS
* YUM packages and git-extras via the [init/20_centos_yum.sh](init/20_centos_yum.sh) script
* Node.js, npm and nave via the [init/50_node.sh](init/50_node.sh) script
* Ruby, gems and rbenv via the [init/50_ruby.sh](init/50_ruby.sh) script
* Vim plugins via the [init/50_vim.sh](init/50_vim.sh) script

## Hacking these dotfiles

Because the [dotfiles][dotfiles] script is completely self-contained, you should be able to delete everything else from your dotfiles repo fork, and it will still work. The only thing it really cares about are the `/copy`, `/link` and `/init` subdirectories, which will be ignored if they are empty or don't exist.

If you modify things and notice a bug or an improvement, [file an issue](https://github.com/madebymode/centos-dotfiles/issues) or [a pull request](https://github.com/madebymode/centos-dotfiles/pulls) and let me know.

### CentOS Notes

You should at least update/upgrade YUM with `sudo yum update -y` first.

_Tested in CentOS 6.7_

### Actual installation (for MODE devs)

```sh
bash -c "$(curl -fsSL https://raw.github.com/madebymode/centos-dotfiles/master/bin/dotfiles)" && source ~/.bashrc
```

### Installation (for non-MODE devs)

1. Fork this repo
1. Open a terminal/shell and do this:

```sh
export github_user=YOUR_GITHUB_USER_NAME

bash -c "$(curl -fsSL https://raw.github.com/$github_user/centos-dotfiles/master/bin/dotfiles)" && source ~/.bashrc
```

Since you'll be using the [dotfiles][dotfiles] command on subsequent runs, you'll only have to export the `github_user` variable for the initial install.

There's a lot of stuff that requires admin access via `sudo`, so be warned that you might need to enter your password here or there.

## Aliases and Functions
To keep things easy, the `~/.bashrc` and `~/.bash_profile` files are extremely simple, and should never need to be modified. Instead, add your aliases, functions, settings, etc into one of the files in the `source` subdirectory, or add a new file. They're all automatically sourced when a new shell is opened. Take a look, I have [a lot of aliases and functions](source). I even have a [fancy prompt](source/50_prompt.sh) that shows the current directory, time and current git/svn repo status.

## Scripts
In addition to the aforementioned [dotfiles][dotfiles] script, there are a few other [bin scripts](bin). This includes [nave](https://github.com/isaacs/nave), which is a [git submodule](vendor).

* [dotfiles][dotfiles] - (re)initialize dotfiles. It might ask for your password (for `sudo`).
* [src](link/.bashrc#L8-18) - (re)source all files in `/source` directory
* Look through the [bin](bin) subdirectory for a few more.

## Prompt


![bash prompt](https://cldup.com/aXKm0MbHVW-2000x2000.png)

## Inspiration
<https://github.com/gf3/dotfiles>  
<https://github.com/mathiasbynens/dotfiles>  
<https://github.com/cowboy/dotfiles>

## License

Licensed under the MIT license.  
