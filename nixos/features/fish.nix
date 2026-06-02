{
  # Fish shell configuration plus integrations for the CLI tools the system
  # ships. Imported by `general` (the primary user's login shell is fish), so
  # it is active on every host that pulls in `general`.
  flake.nixosModules.fish = {pkgs, ...}: {
    # zoxide (smart cd) is inert without a shell hook. enableFishIntegration
    # sources `zoxide init fish`; this also installs the zoxide package, so it
    # no longer needs to live in general.nix systemPackages.
    #
    # `--cmd cd` makes zoxide REPLACE `cd`: plain `cd foo` jumps to the
    # best-matching known directory (and still does a normal cd for real paths,
    # `..`, `-`, etc.), while `cdi` is the interactive picker. This also means
    # every `cd` now feeds zoxide's database, so it learns your paths faster.
    # (The `z` / `zi` commands are gone, folded into `cd` / `cdi`.)
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
      flags = ["--cmd" "cd"];
    };

    programs.fish = {
      enable = true;

      shellAliases = {
        ls = "eza --group-directories-first";
        ll = "eza -l --git --group-directories-first";
        la = "eza -la --git --group-directories-first";
        tree = "eza --tree";
        cat = "bat";
        dig = "doggo";
      };

      # Abbreviations expand inline, so history stays readable.
      shellAbbrs = {
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gl = "git pull";
        gd = "git diff";
        gco = "git checkout";
        glog = "git log --oneline --graph --decorate";
        rebuild = "sudo nixos-rebuild switch --flake .";
      };

      interactiveShellInit = ''
        # fzf key bindings: Ctrl-T files, Ctrl-R history, Alt-C cd
        fzf --fish | source

        # fd as fzf's backend: respects .gitignore, skips the cruft
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'
        set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
        set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --exclude .git'

        set -g fish_greeting "" # quiet startup
      '';
    };

    environment.variables = {
      EDITOR = "nvim";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'"; # colorized man pages via bat
    };
  };
}
