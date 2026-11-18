class Arev < Formula
  desc "Asset review loop for AI agents: images, video and PDF reviewed by a human"
  homepage "https://github.com/fsaint/arev"
  url "https://github.com/fsaint/arev/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "7131102b75aa58eb3dd79a5c86f4b69e57f1e0c95e3ed0d04945d1ec0748296d"

  depends_on "node"

  def install
    # Dev dependencies (TypeScript) are needed to build dist/. Install scripts must
    # run so better-sqlite3 compiles its native module against Homebrew's node.
    system "npm", "install", *std_npm_args(prefix: false, ignore_scripts: false)
    system "npm", "run", "build"
    system "npm", "prune", "--omit=dev"
    libexec.install "package.json", "dist", "web", "node_modules"
    (bin/"arev").write_env_script libexec/"dist/cli.js", PATH: "#{Formula["node"].opt_bin}:$PATH"
    pkgshare.install "skills"
  end

  def caveats
    <<~EOS
      To teach Claude Code the review loop, install the skill:
        mkdir -p ~/.claude/skills && cp -r #{opt_pkgshare}/skills/arev ~/.claude/skills/
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/arev -V")
    system bin/"arev", "init"
    assert_path_exists testpath/".arev/arev.db"
    (testpath/"a.png").write "not really a png"
    output = shell_output("#{bin}/arev --json submit a.png --name t --no-open")
    assert_match '"version": 1', output
    assert_match "pending", shell_output("#{bin}/arev status t")
  end
end
