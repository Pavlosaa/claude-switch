class ClaudeSwitch < Formula
  desc "Manage installed versions of the Claude Code CLI"
  homepage "https://github.com/Pavlosaa/claude-switch"
  url "https://github.com/Pavlosaa/claude-switch/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "91d8e9bbf21f3e34dcdec840493be427b2da127ebe628478c49f8ce0c855e388"
  license "MIT"
  head "https://github.com/Pavlosaa/claude-switch.git", branch: "main"

  uses_from_macos "curl"

  def install
    bin.install "claude-switch"
  end

  test do
    output = shell_output("#{bin}/claude-switch help")
    assert_match "claude-switch", output
    assert_match "Detected platform", output
  end
end
