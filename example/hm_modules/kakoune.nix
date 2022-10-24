{ pkgs, ... }:
let
  themeBuilder = palette:
    with palette; ''
      set-face global value rgb:${normal.magenta},default
      set-face global type rgb:${bright.white},default
      set-face global identifier rgb:${normal.cyan},default
      set-face global string rgb:${normal.green},default
      set-face global error rgb:${normal.red},default
      set-face global keyword rgb:${normal.blue},default
      set-face global operator rgb:${normal.blue},default
      set-face global attribute rgb:${bright.blue},default
      set-face global comment rgb:${bright.blue},default
      set-face global meta rgb:${normal.yellow},default
      set-face global Default rgb:${normal.white},default
      set-face global PrimarySelection rgb:${normal.black},rgb:${dark.yellow}
      set-face global SecondarySelection rgb:${normal.black},rgb:${dark.white}
      set-face global PrimaryCursor rgb:${normal.black},rgb:${normal.yellow}
      set-face global SecondaryCursor rgb:${normal.black},rgb:${normal.white}
      set-face global MenuForeground rgb:${normal.white},rgb:${bright.black}
      set-face global MenuBackground default,rgb:${normal.black}
      set-face global MenuInfo default,rgb:${normal.black}
      set-face global Information rgb:${dark.black},rgb:${normal.cyan}
      set-face global StatusLine rgb:${normal.white},rgb:${normal.black}
      set-face global StatusLineMode rgb:${normal.blue},rgb:${normal.black}
      set-face global StatusLineInfo rgb:${normal.blue},rgb:${normal.black}
      set-face global StatusLineValue rgb:${normal.blue},rgb:${normal.black}
      set-face global StatusCursor rgb:${dark.black},rgb:${normal.yellow}
      set-face global Prompt rgb:${normal.cyan},rgb:${normal.black}
      set-face global BufferPadding default,default
    '';

  packages = with pkgs; [
    editorconfig-core-c
    nodePackages.vscode-langservers-extracted
    rnix-lsp
    yaml-language-server

    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    aspellDicts.it

    (pkgs.makeDesktopItem {
      name = "Kakoune";
      exec = "kak %F";
      icon = "kakoune";
      desktopName = "Kakoune";
      comment = "Kakoune text editor";
      terminal = true;
      categories = [ "Development" ];
      mimeTypes = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
    })
  ];

in
{
  programs.bash.shellAliases = { k = "kak"; };
  programs.zsh.shellAliases = { k = "kak"; };
  home.packages = packages;
  programs.kakoune = {
    enable = true;
    config = {
      colorScheme = "nord";
      tabStop = 2;
      indentWidth = 2;
      alignWithTabs = true;
      scrollOff = {
        lines = 5;
        columns = 3;
      };
      ui = {
        setTitle = true;
        changeColors = true;
        enableMouse = true;
      };
      wrapLines = {
        enable = true;
        word = true;
      };
      numberLines = {
        enable = true;
        highlightCursor = true;
      };
      keyMappings = [
        {
          mode = "normal";
          docstring = "Edit file";
          key = "<c-e>";
          effect = ":edit<space>";
        }
        {
          mode = "user";
          docstring = "Code actions";
          key = "a";
          effect = ":lsp-code-actions<ret>";
        }
        {
          mode = "user";
          docstring = "Comment block";
          key = "b";
          effect = ":comment-block<ret>";
        }
        {
          mode = "user";
          docstring = "Comment line";
          key = "l";
          effect = ":comment-line<ret>";
        }
        {
          mode = "user";
          docstring = "Copy to clipboard";
          key = "y";
          effect = "<a-|>${pkgs.xclip}/bin/xclip -i -selection clipboard<ret>";
        }
        {
          mode = "user";
          docstring = "Format code with formatter";
          key = "f";
          effect = ":format<ret>";
        }
        {
          mode = "user";
          docstring = "Format code with LSP";
          key = "F";
          effect = ":lsp-formatting-sync<ret>";
        }
        {
          mode = "user";
          docstring = "Jump to definition";
          key = "d";
          effect = ":lsp-definition<ret>";
        }
        {
          mode = "user";
          docstring = "Rename object";
          key = "r";
          effect = ":lsp-rename-prompt<ret>";
        }
        {
          mode = "user";
          docstring = "Jump to type definition";
          key = "t";
          effect = ":lsp-type-definition<ret>";
        }
        {
          mode = "user";
          docstring = "List project diagnostics";
          key = "i";
          effect = ":lsp-diagnostics<ret>";
        }
        {
          mode = "user";
          docstring = "Paste from clipboard (after)";
          key = "P";
          effect = "<a-!>${pkgs.xclip}/bin/xclip -selection clipboard -o<ret>";
        }
        {
          mode = "user";
          docstring = "Paste from clipboard (before)";
          key = "p";
          effect = "!${pkgs.xclip}/bin/xclip -selection clipboard -o<ret>";
        }
        {
          mode = "user";
          docstring = "Show hover info";
          key = "q";
          effect = ":lsp-hover<ret>";
        }
        {
          mode = "user";
          docstring = "Spellcheck English";
          key = "S";
          effect = ":spell en<ret>";
        }
        {
          mode = "user";
          docstring = "Spellcheck";
          key = "s";
          effect = ":spell ";
        }
        {
          mode = "normal";
          docstring = "Try next snippet placeholder";
          key = "<c-n>";
          effect = "<a-;>: insert-c-n<ret>";
        }
        # { mode = "normal"; docstring = "Search"; key = "/"; effect = "/(?i)"; }
        # { mode = "normal"; docstring = "Reverse search"; key = "<a-/>"; effect = "<a-/>(?i)"; }
      ];
      hooks = with pkgs; [
        {
          name = "BufCreate";
          option = ".*";
          commands = "editorconfig-load";
        }
        # { name = "ModuleLoaded"; option = "auto-pairs"; commands = "auto-pairs-enable"; }
        {
          name = "ModuleLoaded";
          option = "powerline";
          commands = "powerline-enable; powerline-start";
        }
        {
          name = "BufSetOption";
          option = "filetype=latex";
          commands = "set-option buffer formatcmd latexindent";
        }
        {
          name = "BufSetOption";
          option = "filetype=python";
          commands = "set-option buffer formatcmd 'black -'";
        }
        {
          name = "BufSetOption";
          option = "filetype=(markdown|html|json|yaml|css|scss|less)";
          commands = "set-option buffer formatcmd prettier";
        }
        {
          name = "BufSetOption";
          option = "filetype=rust";
          commands = "set-option buffer formatcmd 'rustfmt'";
        }
        {
          name = "BufSetOption";
          option = "filetype=sh";
          commands = "set-option buffer formatcmd 'rustfmt'";
        }
      ];
      # TODO add more formatters from https://github.com/mawww/kakoune/wiki/Format
    };
    extraConfig = builtins.concatStringsSep "\n" [
      "# Custom commands"
      "add-highlighter global/ regex \\h+$ 0:Error                   # Highlight trailing spaces"
      "eval %sh{kak-lsp --kakoune -s $kak_session}"
      "lsp-enable"
      ''
        def -hidden insert-c-n %{
          try %{
             lsp-snippets-select-next-placeholders
             exec '<a-;>d'
          } catch %{
             exec -with-hooks '<c-n>'
          }
        }
      ''
      "require-module powerline"
      "require-module connect-broot"
      "require-module connect-lf"
      "require-module connect-rofi"
    ];
    plugins = with pkgs.kakounePlugins; [
      prelude-kak
      kak-lsp
      auto-pairs-kak
      powerline-kak
      connect-kak
    ];
  };

  # THEME FILE
  xdg.configFile."kak/colors/nord.kak".text =
    themeBuilder (pkgs.lib.rice.palette.toRgbShortHex pkgs.rice.colorPalette);

  xdg.configFile."kak-lsp/kak-lsp.toml".text = ''
    snippet_support = false
    verbosity = 2
    [server]
    timeout = 1800 # seconds = 30 minutes

    [language.c_cpp]
    filetypes = ["c", "cpp"]
    roots = ["compile_commands.json", ".clangd"]
    command = "clangd"
    offset_encoding = "utf-8"

    [language.json]
    filetypes = ["json"]
    roots = ["package.json"]
    command = "vscode-json-language-server"
    args = ["--stdio"]

    [language.yaml]
    filetypes = ["yaml"]
    roots = [".git"]
    command = "yaml-language-server"
    args = ["--stdio"]

    [language.yaml.settings]
    # See https://github.com/redhat-developer/yaml-language-server#language-server-settings
    # Defaults are at https://github.com/redhat-developer/yaml-language-server/blob/master/src/yamlSettings.ts
    yaml.format.enable = true

    [language.go]
    filetypes = ["go"]
    roots = ["Gopkg.toml", "go.mod", ".git", ".hg"]
    command = "gopls"
    offset_encoding = "utf-8"
    settings_section = "gopls"

    [language.go.settings.gopls]
    # See https://github.com/golang/tools/blob/master/gopls/doc/settings.md
    # "build.buildFlags" = []

    [language.html]
    filetypes = ["html"]
    roots = ["package.json"]
    command = "vscode-html-language-server"
    args = ["--stdio"]

    [language.css]
    filetypes = ["css"]
    roots = ["package.json", ".git"]
    command = "vscode-css-language-server"
    args = ["--stdio"]

    [language.less]
    filetypes = ["less"]
    roots = ["package.json", ".git"]
    command = "vscode-css-language-server"
    args = ["--stdio"]

    [language.scss]
    filetypes = ["scss"]
    roots = ["package.json", ".git"]
    command = "vscode-css-language-server"
    args = ["--stdio"]

    [language.javascript]
    filetypes = ["javascript"]
    roots = [".flowconfig"]
    command = "flow"
    args = ["lsp"]

    [language.latex]
    filetypes = ["latex"]
    roots = [".git"]
    command = "texlab"
    settings_section = "texlab"

    [language.latex.settings.texlab]
    # See https://github.com/latex-lsp/texlab/blob/master/src/options.rs
    # bibtexFormatter = "texlab"

    [language.nix]
    filetypes = ["nix"]
    roots = ["flake.nix", "shell.nix", ".git"]
    command = "rnix-lsp"

    [language.python]
    filetypes = ["python"]
    roots = ["requirements.txt", "setup.py", ".git", ".hg"]
    command = "pylsp"
    offset_encoding = "utf-8"

    [language.python.settings]
    # See https://github.com/palantir/python-language-server#configuration
    # and https://github.com/palantir/python-language-server/blob/develop/vscode-client/package.json
    # "pyls.configurationSources" = ["flake8"]

    [language.rust]
    filetypes = ["rust"]
    roots = ["Cargo.toml"]
    command = "rust-analyzer"
    settings_section = "rust-analyzer"

    [language.rust.settings.rust-analyzer]
    hoverActions.enable = false # kak-lsp doesn't support this at the moment
    # cargo.features = []
    # See https://rust-analyzer.github.io/manual.html#configuration
    # If you get 'unresolved proc macro' warnings, you have two options
    # 1. The safe choice is two disable the warning:
    diagnostics.disabled = ["unresolved-proc-macro"]
    # 2. Or you can opt-in for proc macro support
    procMacro.enable = true
    cargo.loadOutDirsFromCheck = true
    # See https://github.com/rust-analyzer/rust-analyzer/issues/6448

    [language.bash]
    filetypes = ["sh"]
    roots = [".git", ".hg"]
    command = "bash-language-server"
    args = ["start"]
  '';
}
