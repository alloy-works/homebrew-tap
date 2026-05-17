# Homebrew formula for Alloy CLI
# Auto-updated by release workflow — do not edit manually

class Alloy < Formula
  desc "Polyglot FaaS platform for orchestrating C++, Python, and Rust DAGs"
  homepage "https://github.com/alloy-works/alloy"
  version "0.1.0-alpha.1"

  on_macos do
    url "https://github.com/alloy-works/alloy/releases/download/v#{version}/alloy-v#{version}-aarch64-apple-darwin.tar.gz"
    sha256 "PLACEHOLDER"
  end

  on_linux do
    on_arm do
      url "https://github.com/alloy-works/alloy/releases/download/v#{version}/alloy-v#{version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "PLACEHOLDER"
    end
    on_intel do
      url "https://github.com/alloy-works/alloy/releases/download/v#{version}/alloy-v#{version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  def install
    bin.install "alloy"
  end

  def caveats
    <<~EOS
      The Alloy CLI is installed.

      To start the backend (team members with Docker + GHCR access):
        docker login ghcr.io
        docker run -d -p 50052:50052 --shm-size=4g --name alloy-dev ghcr.io/alloy-works/alloy:dev
        alloy status

      To connect to a remote Alloy server:
        alloy status --endpoint https://your-lattice:50052
    EOS
  end

  test do
    assert_match "Alloy orchestration platform", shell_output("#{bin}/alloy --help")
  end
end
