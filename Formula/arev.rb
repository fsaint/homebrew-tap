class Arev < Formula
  desc "Asset review loop for AI agents: images, video and PDF reviewed by a human"
  homepage "https://github.com/fsaint/arev"
  url "https://github.com/fsaint/arev/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "5549c2b6636cee67c62bb564329a8ab808f93f86a8da0609c538cb0583355c59"

  depends_on "node"

  def install
    # Dev dependencies (TypeScript) are needed to build dist/; better-sqlite3 is
    # compiled against Homebrew's node.
    system "npm", "install", *std_npm_args(prefix: false)
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
  end
end
